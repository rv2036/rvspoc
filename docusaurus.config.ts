import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'RVSPOC 2026',
  tagline: '',

  // Set the production url of your site here
  url: 'https://rvspoc.org',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'rv2036', // Usually your GitHub org/user name.
  projectName: 'rvspoc', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  onDuplicateRoutes: 'log',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'zh-Hans',
    locales: ['zh-Hans','en'],
  },

  plugins: [
    'docusaurus-plugin-sass',
    [
      './src/plugin/plugin-content-blog',
      {
        routeBasePath: '',
        showReadingTime: false,
        blogSidebarCount: 0,
      }
    ],
    [
      './src/plugin/plugin-content-docs',
      {
        routeBasePath: '',
        sidebarPath: './sidebars.ts',
        path: 'docs',
     }
    ]
  ],

  presets: [
    [
      'classic',
      {
        docs: false,
        /*
        blog: {
          showReadingTime: false,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          //editUrl: '',
          blogSidebarCount: 0,
        },
        */
        // use the above custom extended blog plugin to get it's data globally
        blog: false,
        theme: {
          customCss: './src/css/custom.scss',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      defaultMode: 'dark',
    },
    navbar: {
      title: 'RISC-V 软件移植及优化挑战赛',
      items: [
        {
          type: 'localeDropdown',
          queryString: '?persistLocale=true', // TODO
          position: 'right',
        },
        {
          position: 'right',
          label: 'FAQ',
          to: "/faq",
        },
				{
          type: 'dropdown',
          label: '往届挑战赛',
          position: 'right',
          items: [
            {
              label: '2023',
              href: 'https://rvspoc.org/2023/',
            },
            {
              label: '2024',
              href: 'https://rvspoc.org/2024/',
            },
            {
              label: '2025',
              href: 'https://rvspoc.org/2025/',
            }
          ],
        },
        {
          href: 'https://github.com/rv2036/rvspoc',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      links: [],
      copyright: `Copyright © 2023 - ${new Date().getFullYear()} RVSPOC`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
