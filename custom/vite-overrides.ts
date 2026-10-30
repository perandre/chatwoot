import fs from 'node:fs';
import path from 'node:path';
import type { Plugin } from 'vite';
import { aliases } from '../vite.shared';

// Fork overlay for the frontend: a file at custom/javascript/<path> replaces app/javascript/<path>
// wherever it is imported. Imports inside an override resolve as if it lived at the original path.
const appDir = path.resolve(__dirname, '../app/javascript');
const customDir = path.resolve(__dirname, 'javascript');
const appAliases = Object.keys(aliases).filter(key =>
  aliases[key].startsWith(appDir)
);

// Only app code can be overridden; package imports (vue, @vueuse/core, …) pass straight through.
const isAppImport = (source: string) =>
  source.startsWith('.') ||
  source.startsWith('/') ||
  appAliases.some(key => source === key || source.startsWith(`${key}/`));

export default function customOverrides(): Plugin {
  return {
    name: 'custom-overrides',
    enforce: 'pre',
    async resolveId(source, importer, options) {
      if (!isAppImport(source)) return null;

      const originalImporter = importer?.startsWith(customDir)
        ? importer.replace(customDir, appDir)
        : importer;
      const resolved = await this.resolve(source, originalImporter, {
        ...options,
        skipSelf: true,
      });
      if (!resolved?.id.startsWith(appDir)) return resolved;

      const override = resolved.id.replace(appDir, customDir);
      return fs.existsSync(override) ? override : resolved;
    },
  };
}
