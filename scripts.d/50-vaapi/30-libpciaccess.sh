#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git"
SCRIPT_COMMIT="d6a319c7de36b1afe7822640f8e3c0c533f75176"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=shared
        -Dzlib=enabled
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    gen-implib "$FFBUILD_PREFIX"/lib/{libpciaccess.so.0,libpciaccess.a}
    rm "$FFBUILD_PREFIX"/lib/libpciaccess.so*

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/pciaccess.pc
}
