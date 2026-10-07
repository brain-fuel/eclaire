#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
target="${1:-host}"
build_dir="$root/build/native/$target"
args=( -DECLAIRE_BUILD_TESTS=OFF )

case "$target" in
  host) ;;
  macos-universal)
    args+=( -DCMAKE_OSX_ARCHITECTURES=arm64\;x86_64 )
    ;;
  ios-arm64)
    args+=( -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphoneos -DCMAKE_OSX_ARCHITECTURES=arm64 -DECLAIRE_LIBRARY_TYPE=STATIC )
    ;;
  ios-simulator-arm64)
    args+=( -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphonesimulator -DCMAKE_OSX_ARCHITECTURES=arm64 -DECLAIRE_LIBRARY_TYPE=STATIC )
    ;;
  ios-simulator-x86_64)
    args+=( -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphonesimulator -DCMAKE_OSX_ARCHITECTURES=x86_64 -DECLAIRE_LIBRARY_TYPE=STATIC )
    ;;
  android-arm64)
    : "${ANDROID_NDK_HOME:=${ANDROID_NDK_ROOT:-}}"
    [[ -n "$ANDROID_NDK_HOME" ]] || { echo 'Set ANDROID_NDK_HOME to an Android NDK.' >&2; exit 1; }
    args+=( -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM="${ANDROID_PLATFORM:-android-24}" )
    ;;
  android-arm)
    : "${ANDROID_NDK_HOME:=${ANDROID_NDK_ROOT:-}}"
    [[ -n "$ANDROID_NDK_HOME" ]] || { echo 'Set ANDROID_NDK_HOME to an Android NDK.' >&2; exit 1; }
    args+=( -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" -DANDROID_ABI=armeabi-v7a -DANDROID_PLATFORM="${ANDROID_PLATFORM:-android-24}" )
    ;;
  android-x86_64)
    : "${ANDROID_NDK_HOME:=${ANDROID_NDK_ROOT:-}}"
    [[ -n "$ANDROID_NDK_HOME" ]] || { echo 'Set ANDROID_NDK_HOME to an Android NDK.' >&2; exit 1; }
    args+=( -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" -DANDROID_ABI=x86_64 -DANDROID_PLATFORM="${ANDROID_PLATFORM:-android-24}" )
    ;;
  android-x86)
    : "${ANDROID_NDK_HOME:=${ANDROID_NDK_ROOT:-}}"
    [[ -n "$ANDROID_NDK_HOME" ]] || { echo 'Set ANDROID_NDK_HOME to an Android NDK.' >&2; exit 1; }
    args+=( -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" -DANDROID_ABI=x86 -DANDROID_PLATFORM="${ANDROID_PLATFORM:-android-24}" )
    ;;
  *)
    echo "Unknown target '$target'. See README.md for target names." >&2
    exit 2
    ;;
esac

if [[ -n "${ECLAIRE_CMAKE_ARGS:-}" ]]; then
  read -r -a extra_args <<<"$ECLAIRE_CMAKE_ARGS"
  args+=("${extra_args[@]}")
fi
cmake -S "$root" -B "$build_dir" "${args[@]}"
cmake --build "$build_dir" --config Release
cmake --install "$build_dir" --prefix "$build_dir/install"
printf 'Built Eclaire for %s in %s\n' "$target" "$build_dir/install"
