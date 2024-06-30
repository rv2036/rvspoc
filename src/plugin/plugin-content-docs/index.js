import path from 'path';
const docsPluginExports = require('@docusaurus/plugin-content-docs');
import { posixPath, normalizeUrl } from '@docusaurus/utils';
import { toFullVersion } from '@docusaurus/plugin-content-docs/lib/versions/index.js'
import { createAllRoutes } from '@docusaurus/plugin-content-docs/lib/routes.js'
import { toGlobalDataVersion } from '@docusaurus/plugin-content-docs/lib/globalData.js'

function createSourceToPermalinkHelper() {
  const sourceToPermalink = new Map();
  function computeSourceToPermalink(content) {
    const allDocs = content.loadedVersions.flatMap((v) => v.docs);
    return new Map(allDocs.map(({source, permalink}) => [source, permalink]));
  }
  // Mutable map update :/
  function update(content) {
    sourceToPermalink.clear();
    computeSourceToPermalink(content).forEach((value, key) => {
      sourceToPermalink.set(key, value);
    });
  }
  return {get: () => sourceToPermalink, update};
}

async function docsPluginEnhanced(context, options) {
  const defaultDocsPluginInstance = await docsPluginExports.default(context, options);
  const sourceToPermalinkHelper = createSourceToPermalinkHelper();
  const {siteDir, generatedFilesDir, baseUrl, siteConfig} = context;
  const pluginDataDirRoot = path.join(
    generatedFilesDir,
    'docusaurus-plugin-content-docs',
  );
  const aliasedSource = (source) => `~docs/${posixPath(path.relative(pluginDataDirRoot, source))}`;


  return {
    ...defaultDocsPluginInstance,
    async contentLoaded({ content, actions }) {
      // default actions
      sourceToPermalinkHelper.update(content);
      const versions = content.loadedVersions.map(toFullVersion);
      await createAllRoutes({
        baseUrl,
        versions,
        options,
        actions,
        aliasedSource,
      });
      // default actions end

      const docs = content.loadedVersions[0].docs;
      const metadata = docs.reduce((acc, doc) => {
        acc[doc.id] = {
          ...doc,
        };
        return acc;
      }, {});

      actions.setGlobalData({
        metadata: metadata,
        path: normalizeUrl([baseUrl, options.routeBasePath]),
        versions: versions.map(toGlobalDataVersion),
        breadcrumbs: options.breadcrumbs,
      });
    },
  }
}

module.exports = Object.assign({}, docsPluginExports, {
  default: docsPluginEnhanced,
})
