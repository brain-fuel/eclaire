# Haskell browser showcase

This Miso 1.14 WebAssembly host follows the shared content, element/action IDs, DOM structure, layout, and interactions in [the showcase contract](../../browser/showcase.json). It uses the same Miso WASI loader setup as the sibling [`ricestax/web`](../../../../ricestax/web) project.

The toolchain must be installed and available at `~/.ghc-wasm/env`, or `wasm32-wasi-cabal` and `wasm32-wasi-ghc` must already be on PATH. Build and serve it with:

```sh
cd elmish-clay/examples/haskell/browser
./build.sh
python3 -m http.server 5094 -d public
```

Open <http://localhost:5094>. Stop the server with Ctrl-C. The first build may download Cabal dependencies. The loader imports the small WASI browser shim from jsDelivr.
