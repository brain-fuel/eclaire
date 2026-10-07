# Eclaire

Eclaire is a cross-language semantic UI and layout engine powered by Clay. It exposes a C ABI and a versioned semantic UI contract. The same unmodified Clay header is vendored in `third_party/clay/` and compiled by each language toolchain for its selected target.

## Release identity

Each Eclaire release maps to exactly one Clay revision. [`eclaire.toml`](eclaire.toml) records the Eclaire version, Clay commit, and SHA-256 of the vendored header. Run `make check-release` before building or packaging to verify that map and all language package versions.

## Packages and setup

### Haskell / Stack

The Cabal library and `eclaire` CLI compile the native C core with Stack's active GHC C toolchain.

```sh
stack build
stack install
eclaire --version
```

### F# / .NET

Eclaire is distributed as a NuGet package for `net10.0` and `net10.0-ios`. Its `buildTransitive` target runs CMake while each consuming project builds. Desktop builds copy the shared library beside the application; Android builds add the ABI-specific `.so` as an `AndroidNativeLibrary`; iOS builds a static library and adds it as a `NativeReference`. The consumer needs CMake and a C compiler. Android builds also need the .NET Android workload and an Android NDK; iOS builds need the .NET iOS workload and Xcode. `EclaireCMakeArgs` can override the inferred toolchain arguments.

```sh
make pack-fsharp
dotnet add package Eclaire --version 0.1.1 --source build/nuget
```

For mobile apps, build with a runtime identifier such as `android-arm64`, `android-arm`, `android-x64`, `android-x86`, `ios-arm64`, `iossimulator-arm64`, or `iossimulator-x64`. The package builds the native library for that RID during the app build.

Once published, install it with `dotnet add package Eclaire --version 0.1.1`.

### Rust / Cargo

The Cargo library and CLI compile the native C core with Cargo's target-aware C compiler during setup.

```sh
cargo install --locked --path .
eclaire --version
```

Once published, Rust applications can add `eclaire = "0.1.1"` to `Cargo.toml` and call the Rust FFI facade. Cargo's selected target controls the native build.

### Haskell / Hackage

Use `stack install eclaire` after the package is published to Hackage. From a source checkout, `stack install` builds and installs the local library and CLI.

### Go

The Go package uses cgo to compile the native core with the target C compiler. Install the CLI with:

```sh
go install github.com/brain-fuel/eclaire/cmd/eclaire@v0.1.1
eclaire --version
```

For cross-target builds, set Go's `GOOS`, `GOARCH`, `CGO_ENABLED`, and target C compiler together. GoForge's future Cadence and Quicken adapters will use this package boundary.

### CMake / C

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
cmake --install build --prefix <install-prefix>
```

Consumers can import `eclaire::eclaire` with `find_package(eclaire 0.1 CONFIG REQUIRED)`. Direct CMake builds use the active C compiler. The host must provide a text measurement callback for real font metrics; the fallback is deterministic approximate measurement for smoke tests. The caller owns the Clay arena memory for the initialized context.

## Native target builds

`make build-native-target TARGET=<target>` configures, builds, and installs the C core into a target-specific directory. The native presets cover these desktop and mobile targets:

- `host`
- `macos-universal`
- `ios-arm64`, `ios-simulator-arm64`, `ios-simulator-x86_64`
- `android-arm64`, `android-arm`, `android-x86_64`, `android-x86`

Android builds require `ANDROID_NDK_HOME` (or `ANDROID_NDK_ROOT`). iOS builds require Xcode. Desktop cross-compilers and additional CMake target options can be supplied through `ECLAIRE_CMAKE_ARGS`. The macOS universal, iOS device/simulator, and all four Android ABI presets have been built successfully with Xcode and Android NDK r30.

## Cadence and Quicken

Cadence provides GoForge's target-independent Elm Architecture, model/update loop, and semantic elements. Quicken interprets those programs in browser, terminal, desktop, and mobile hosts. Eclaire is intended to supply shared Clay-backed geometry beneath those renderers while each host retains its platform-native controls, accessibility tree, and app state. The Go package gives GoForge a stable integration point; direct Cadence and Quicken adapters remain follow-on integration work.

## Browser showcase

C, F#, and Haskell browser examples share a semantic showcase contract and compare content, controls, and desktop/mobile geometry. Build all examples with `make build` and run the native plus browser checks with `make test`. The browser checks need Node.js/npm, Playwright, and Chrome or Playwright Chromium.
