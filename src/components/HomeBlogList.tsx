import type { BlogPost } from '@docusaurus/plugin-content-blog';
import { usePluginData } from '@docusaurus/useGlobalData';
import Link from '@docusaurus/Link';
import { format } from 'date-fns';
import { enUS, zhCN } from "date-fns/locale";
import type { Locale } from "date-fns/locale";
import getCurrentLocale from '../hooks/currentLocale';

interface blogItem {
  post: BlogPost,
  locale: Locale,
  dateFmt: string,
}

function HomeBlogSection(item: blogItem): JSX.Element {
  const { metadata } = item.item.post;
  const currentDate = new Date(metadata.date);
  const dateStr = format(currentDate, item.item.dateFmt, {locale: item.item.locale});
  return (
    <div className="blog-item">
        <time dateTime={metadata.date}>{dateStr}</time>
        <Link className="blog-title" to={metadata.permalink}><h2>{metadata.title}</h2></Link>
        <div className="blog-desc">{metadata.description}</div>
    </div>
  )
}

export default function HomeBlogList(): JSX.Element {
  const blogData = usePluginData('docusaurus-plugin-content-blog');
  const { posts, postsCount } = blogData;
  let locale: Locale = zhCN;
  let dateFmt: string = 'MMMM d 日，yyyy';
	switch (getCurrentLocale()) {
    case 'en':
      locale = enUS;
      dateFmt = 'MMM d, yyyy';
      break;
	}
  return (
    <div id="blog-list" className="container">
      {
        posts.map((post: BlogPost, index: number) => (
          <HomeBlogSection key={index} item={{post: post, locale: locale, dateFmt: dateFmt} as blogItem} />
        ))
      }
    </div>
  )
}
