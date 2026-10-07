# Eclaire for Node.js

Install Eclaire's C engine from npm. The package compiles the native library
during installation using CMake and the host C compiler, then exposes its
library and header paths to Node applications and native FFI bindings.

```sh
npm install @brain-fuel/eclaire
```

```js
import { clayCommit, headerPath, nativeLibraryPath, version } from '@brain-fuel/eclaire';

console.log({ version, clayCommit });
console.log(nativeLibraryPath());
console.log(headerPath());
```

This package supplies the C ABI; it does not wrap that ABI in a JavaScript UI
API. Use it with your preferred Node FFI package or from a native application.
Every Eclaire release pins one Clay commit, available as `clayCommit`.

## Select a native target

The install script builds the host target by default. Set `ECLAIRE_TARGET` to
build another target when the required toolchain is installed:

```sh
ECLAIRE_TARGET=ios-arm64 npm install @brain-fuel/eclaire
ECLAIRE_TARGET=android-arm64 ANDROID_NDK_HOME=/path/to/ndk npm install @brain-fuel/eclaire
```

The same setup can be rerun after installation with `npm run build:native --
--target ios-simulator-arm64`. Supported targets are `host`, `macos-universal`,
`ios-arm64`, `ios-simulator-arm64`, `ios-simulator-x86_64`, `android-arm64`,
`android-arm`, `android-x86_64`, and `android-x86`. iOS targets require Xcode;
Android targets require the Android NDK. Set `ECLAIRE_CMAKE_ARGS` to pass extra
CMake arguments.

Node.js 18+, CMake 3.16+, and a C11 compiler are required. See the
[Eclaire repository](https://github.com/brain-fuel/eclaire) for the C ABI and
the other language packages.
