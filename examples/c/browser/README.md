# C browser showcase

This is the C/WebAssembly host for the shared showcase contract. Its C module owns the counter state and action dispatch and runs the Clay-backed C ABI layout pass on startup, resize, and state changes. The browser adapter uses the same semantic DOM structure and stylesheet as F# and Haskell.

```sh
cd eclaire/examples/c/browser
./build.sh
python3 -m http.server 5092 -d static
```

Open <http://localhost:5092>. Stop the server with Ctrl-C. The build uses `wasm32-wasi-clang`, available from the GHC WASM environment at `~/.ghc-wasm/env` on the development machine.
