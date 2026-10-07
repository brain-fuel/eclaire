import { existsSync } from 'node:fs';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const packageRoot = join(dirname(fileURLToPath(import.meta.url)), '..');

function readManifest() {
  const text = requireText(join(packageRoot, 'eclaire.toml'));
  const field = (name) => text.match(new RegExp(`^${name} = "([^"]+)"$`, 'm'))?.[1];
  return { version: field('version'), clayCommit: field('clay_commit') };
}

function requireText(path) {
  return readFileSync(path, 'utf8');
}

const { version, clayCommit } = readManifest();

export { version, clayCommit };

/** Return the directory containing installed Eclaire C libraries for a target. */
export function nativeInstallDirectory(target = process.env.ECLAIRE_TARGET || 'host') {
  return join(packageRoot, 'build', 'native', target, 'install');
}

/** Return the installed native library path for a target, or null when not built. */
export function nativeLibraryPath(target = process.env.ECLAIRE_TARGET || 'host') {
  const libDir = join(nativeInstallDirectory(target), 'lib');
  const candidates = target.startsWith('ios-')
    ? [join(libDir, 'libeclaire.a')]
    : target.startsWith('android-')
      ? [join(libDir, 'libeclaire.so')]
      : process.platform === 'win32'
    ? [join(nativeInstallDirectory(target), 'bin', 'eclaire.dll'), join(libDir, 'eclaire.dll')]
    : process.platform === 'darwin'
      ? [join(libDir, 'libeclaire.dylib'), join(libDir, 'libeclaire.0.dylib')]
      : [join(libDir, 'libeclaire.so'), join(libDir, 'libeclaire.so.0')];
  return candidates.find(existsSync) ?? null;
}

/** Return the installed public C header path. */
export function headerPath(target = process.env.ECLAIRE_TARGET || 'host') {
  return join(nativeInstallDirectory(target), 'include', 'eclaire.h');
}
