import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
let target = process.env.ECLAIRE_TARGET || 'host';
const targetIndex = args.indexOf('--target');
if (targetIndex >= 0) target = args[targetIndex + 1];

const buildDir = join(root, 'build', 'native', target);
const installDir = join(buildDir, 'install');
const cmakeArgs = ['-S', root, '-B', buildDir, '-DECLAIRE_BUILD_TESTS=OFF'];
switch (target) {
  case 'host':
    break;
  case 'macos-universal':
    cmakeArgs.push('-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64');
    break;
  case 'ios-arm64':
    cmakeArgs.push('-DCMAKE_SYSTEM_NAME=iOS', '-DCMAKE_OSX_SYSROOT=iphoneos', '-DCMAKE_OSX_ARCHITECTURES=arm64', '-DECLAIRE_LIBRARY_TYPE=STATIC');
    break;
  case 'ios-simulator-arm64':
  case 'ios-simulator-x86_64':
    cmakeArgs.push('-DCMAKE_SYSTEM_NAME=iOS', '-DCMAKE_OSX_SYSROOT=iphonesimulator', `-DCMAKE_OSX_ARCHITECTURES=${target.endsWith('arm64') ? 'arm64' : 'x86_64'}`, '-DECLAIRE_LIBRARY_TYPE=STATIC');
    break;
  case 'android-arm64':
  case 'android-arm':
  case 'android-x86_64':
  case 'android-x86': {
    const ndk = process.env.ANDROID_NDK_HOME || process.env.ANDROID_NDK_ROOT;
    if (!ndk) throw new Error('Set ANDROID_NDK_HOME to an Android NDK to build an Android target.');
    const abi = {
      'android-arm64': 'arm64-v8a',
      'android-arm': 'armeabi-v7a',
      'android-x86_64': 'x86_64',
      'android-x86': 'x86',
    }[target];
    cmakeArgs.push(`-DCMAKE_TOOLCHAIN_FILE=${join(ndk, 'build', 'cmake', 'android.toolchain.cmake')}`, `-DANDROID_ABI=${abi}`, `-DANDROID_PLATFORM=${process.env.ANDROID_PLATFORM || 'android-24'}`);
    break;
  }
  default:
    throw new Error(`Unknown ECLAIRE_TARGET '${target}'.`);
}
if (process.env.ECLAIRE_CMAKE_ARGS) cmakeArgs.push(...process.env.ECLAIRE_CMAKE_ARGS.trim().split(/\s+/));

function run(command, commandArgs) {
  const result = spawnSync(command, commandArgs, { stdio: 'inherit', cwd: root });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}

mkdirSync(buildDir, { recursive: true });
run('cmake', cmakeArgs);
run('cmake', ['--build', buildDir, '--config', 'Release']);
run('cmake', ['--install', buildDir, '--prefix', installDir]);

const manifest = readFileSync(join(root, 'eclaire.toml'), 'utf8');
const version = manifest.match(/^version = "([^"]+)"$/m)?.[1];
console.log(`Built Eclaire ${version} native library for ${target} at ${installDir}`);
