# C, F#, and Haskell browser demos

All three demos follow [the shared showcase contract](showcase.json), use the same DOM structure, and share the same stylesheet and image. The count starts at zero. Action IDs 100 and 101 decrement/increment; 102 toggles the labeled details section. The details image, alt text, scroll region, copy, responsive dimensions, and keyboard behavior match.

The F# and Haskell hosts use Bolero and Miso WebAssembly respectively. The C host owns the same model/actions in WebAssembly and runs the Clay-backed C ABI layout pass on startup, resize, and state changes. Each language keeps its own UI update logic while rendering the same browser experience.

Build all hosts in dependency order with `make build` from the project root. Run native C and browser interaction plus responsive geometry checks with `make test`. The parity test starts temporary servers on free local ports, drives each page in Chromium, compares the desktop and mobile element geometry, and checks counter and checkbox behavior.

`make test` installs the locked browser test dependency with npm. On macOS the test uses installed Google Chrome; elsewhere use a Playwright browser via `npx playwright install chromium`.

To run each host in a separate terminal:

```sh
cd elmish-clay/examples/c/browser
./build.sh
python3 -m http.server 5092 -d static
```

```sh
cd elmish-clay/examples/fsharp/browser
dotnet run --no-launch-profile --project ElmishClay.Browser.fsproj --urls http://127.0.0.1:5093
```

```sh
cd elmish-clay/examples/haskell/browser
./build.sh
python3 -m http.server 5094 -d public
```

Open <http://localhost:5092>, <http://localhost:5093>, and <http://localhost:5094>. Alternatively, `make serve` builds and supervises all three servers in the foreground. Stop them with Ctrl-C in that terminal or run `make stop` from another terminal. Use `make status` to check them. `make serve-c`, `make serve-fsharp`, and `make serve-haskell` start one host; pair them with `make stop-c`, `make stop-fsharp`, or `make stop-haskell`. Override ports with `PORT_C`, `PORT_FSHARP`, or `PORT_HASKELL`. The Haskell app uses the GHC WASM environment also used by the sibling `ricestax/web` project. See each host's README for toolchain notes.
