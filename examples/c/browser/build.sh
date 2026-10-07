#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ -f "$HOME/.ghc-wasm/env" ]]; then . "$HOME/.ghc-wasm/env"; fi
CC="${CC:-wasm32-wasi-clang}"
command -v "$CC" >/dev/null || { echo "A WASI C compiler is required (for example, the wasi-sdk bundled with ~/.ghc-wasm/env)." >&2; exit 1; }
mkdir -p static
cp ../../browser/showcase.css static/showcase.css
cp ../../browser/night-sky.svg static/night-sky.svg
"$CC" -O2 -std=c11 -I../../../include \
  -Wl,--export=demo_count -Wl,--export=demo_expanded -Wl,--export=demo_action -Wl,--export=demo_init -Wl,--export=demo_layout -Wl,--export=ecl_last_error \
  -I../../../third_party/clay src/demo.c ../../../src/elmish_clay.c -lm -o static/elmish-clay-c.wasm
printf 'Built C browser demo in %s/static\n' "$PWD"
