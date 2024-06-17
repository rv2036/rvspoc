const blogPluginExports = require('@docusaurus/plugin-content-blog');
const { default: defaultBlogPlugin } = blogPluginExports;

async function blogPluginEnhanced(context, options) {
  const defaultBlogPluginInstance = await defaultBlogPlugin(context, options)

  return {
    ...defaultBlogPluginInstance,
    async contentLoaded({ content, actions }) {
      // Create default plugin pages
      await defaultBlogPluginInstance.contentLoaded({ content, actions })

      // Store info to global
      actions.setGlobalData({
        posts: content.blogPosts,
        postsCount: content.blogPosts.length,
      })
    },
  }
}

module.exports = Object.assign({}, blogPluginExports, {
  default: blogPluginEnhanced,
})
