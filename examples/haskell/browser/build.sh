#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ -f "$HOME/.ghc-wasm/env" ]]; then
  . "$HOME/.ghc-wasm/env"
fi
command -v wasm32-wasi-cabal >/dev/null || { echo "Miso's GHC WASM toolchain is required. See README.md." >&2; exit 1; }
wasm32-wasi-cabal build
cp ../../browser/showcase.css static/showcase.css
cp ../../browser/night-sky.svg static/night-sky.svg
rm -rf public && cp -r static public
wasm="$(wasm32-wasi-cabal list-bin elmish-clay-web | tail -n 1)"
"$(wasm32-wasi-ghc --print-libdir)/post-link.mjs" --input "$wasm" --output public/ghc_wasm_jsffi.js
cp "$wasm" public/elmish-clay-web.wasm
printf 'Built browser app in %s/public\n' "$PWD"
