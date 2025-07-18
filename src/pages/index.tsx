import React, {useEffect, useRef} from 'react';
import clsx from 'clsx';
import {useThemeConfig} from '@docusaurus/theme-common';
import ErrorBoundary from '@docusaurus/ErrorBoundary';
import {
  PageMetadata,
  SkipToContentFallbackId,
  ThemeClassNames,
} from '@docusaurus/theme-common';
import {
  useHideableNavbar,
  useNavbarMobileSidebar,
} from '@docusaurus/theme-common/internal';
import {useKeyboardNavigation} from '@docusaurus/theme-common/internal';
import SkipToContent from '@theme/SkipToContent';
import AnnouncementBar from '@theme/AnnouncementBar';
import Footer from '@theme/Footer';
import LayoutProvider from '@theme/Layout/Provider';
import ErrorPageContent from '@theme/ErrorPageContent';
import type {Props} from '@theme/Layout';
import Translate, {translate} from '@docusaurus/Translate';
import NavbarMobileSidebar from '@theme/Navbar/MobileSidebar';
import type {Props as NavbarProps} from '@theme/Navbar/Layout';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Heading from '@theme/Heading';
import NavbarContent from '@theme/Navbar/Content';
import Link from '@docusaurus/Link';
import BrowserOnly from '@docusaurus/BrowserOnly';
import HomeBlogList from '../components/HomeBlogList';

import styles from './styles.module.css';
import './index.scss';

function Layout(props: Props): JSX.Element {
  const {
    children,
    noFooter,
    wrapperClassName,
    // Not really layout-related, but kept for convenience/retro-compatibility
    title,
    description,
  } = props;

  useKeyboardNavigation();

  return (
    <LayoutProvider>
      <PageMetadata title={title} description={description} />
      <SkipToContent />
      <AnnouncementBar />
      <Navbar />
      <div
        id={SkipToContentFallbackId}
        className={clsx(
          ThemeClassNames.wrapper.main,
          styles.mainWrapper,
          wrapperClassName,
        )}>
        <ErrorBoundary fallback={(params) => <ErrorPageContent {...params} />}>
          {children}
        </ErrorBoundary>
        {!noFooter && <Footer />}
      </div>
    </LayoutProvider>
  );
}

function NavbarBackdrop(props: ComponentProps<'div'>) {
  return (
    <div
      role="presentation"
      {...props}
      className={clsx('navbar-sidebar__backdrop', props.className)}
    />
  );
}

function NavbarLayout({children}: NavbarProps): JSX.Element {
  const {
    navbar: {hideOnScroll, style},
  } = useThemeConfig();
  const mobileSidebar = useNavbarMobileSidebar();
  const {navbarRef, isNavbarVisible} = useHideableNavbar(hideOnScroll);
  return (
    <nav
      ref={navbarRef}
      aria-label={translate({
        id: 'theme.NavBar.navAriaLabel',
        message: 'Main',
        description: 'The ARIA label for the main navigation',
      })}
      className={clsx(
        'navbar',
        'navbar--fixed-top',
        hideOnScroll && [
          styles.navbarHideable,
          !isNavbarVisible && styles.navbarHidden,
        ],
        {
          'navbar--dark': style === 'dark',
          'navbar--primary': style === 'primary',
          'navbar-sidebar--show': mobileSidebar.shown,
        },
        'in-home-page',
      )}>
      {children}
      <NavbarBackdrop onClick={mobileSidebar.toggle} />
      <NavbarMobileSidebar />
    </nav>
  );
}

function Navbar(): JSX.Element {
  return (
    <NavbarLayout>
      <NavbarContent />
    </NavbarLayout>
  );
}

interface SponsorProps {
  icon: string;
  url: string;
  classn: string;
}

function Sponsor(props: SponsorProps): JSX.Element {
  const {
    icon,
    url,
    classn
  } = props;
  const cn = classn + " sponsor"
  return (
    <a className={cn} href={url}>
      <img src={icon} />
    </a>
  )
}

function HomepageHeader(): JSX.Element {
  const {siteConfig} = useDocusaurusContext();
  return (
    <div id="cover">
      <BrowserOnly fallback={<div>Loading...</div>}>
        {() => {
          const HomeCanvas = require('../components/HomeCanvas').default;
          return <HomeCanvas />;
        }}
      </BrowserOnly>
      <header className="cover">
        <div className="container">
          <Heading as="h1" className="cover-title">
            <Translate id="common.title">RISC-V 软件移植及优化挑战赛</Translate>
            <sup id="year-badge">2025</sup>
          </Heading>
          <div id="rvspoc-description">
            <Translate id="common.description.prefix">为了推动 RISC-V 软件生态更快地发展，吸引更多的开发者加入到 RISC-V 生态中来，</Translate><Link className="host-link" to="https://kubuds.io"><Translate id="common.host.name">苦芽科技</Translate></Link><Translate id="common.description.suffix">发起了本届挑战赛。RISC-V 软件移植及优化挑战赛 (RVSPOC) 以桌面和服务器软件生态为重点，在编译器、运行时环境、AI 软件栈等多个方面公开提出一系列比赛题目，邀请全球开发者完成挑战并赢取奖金。</Translate>
          </div>
          {/* <div id="registration">
            <a className="link-button link-button-eye-catching" href="https://www.wenjuan.com/s/7zaAFz8/" target="_blank"><Translate id="common.registration">比赛报名入口</Translate></a>
          </div> */}
	  <div id="challenges"><Link to='/challenges' className="link-button"><Translate id="common.challenges.link">赛题列表</Translate></Link></div>
          <div id="blank_line">
          </div> 
          <span><b>主办单位：</b>上海苦芽科技有限公司</span>
          <span><b>协办单位：</b>广州市智能软件产业研究院</span>
          <div id="contant"><Translate id="common.email.label">赞助咨询邮箱：</Translate><Link to="mailto:rvspoc@kubuds.cn">rvspoc@kubuds.cn</Link></div>
          <div id="contant"><Translate id="common.weixin.label">赛事官方公众号：</Translate>苦芽科技</div>
          <div>
            <Sponsor classn="" icon="/img/kubuds-qr.jpg" url="https://kubuds.io/"/>
          </div>
          <div id="placeholder"></div>
          <div id="sponsors">
          <label><Translate id="common.sponsor">赞助商</Translate></label>
          <div>
            <Sponsor classn="" icon="/img/sponsors-tba.png"/>
            <Sponsor classn="" icon="/img/sponsors-tba.png"/>
          </div>
          </div> 
        </div>
      </header>
    </div>
  );
}

export default function Home(): JSX.Element {
  const {siteConfig} = useDocusaurusContext();
  let screenWidth: number;
  let screenHeight: number;
  let navbar: (HTMLElement | null) = null;
  let cover: (HTMLElement | null) = null;

  useEffect(() => {
    const adjustCoverSize = () => {
      if (navbar == null) {
        navbar = document.querySelector('nav.navbar');
      }
      if (cover == null) {
        cover = document.querySelector('div#cover');
      }
      screenWidth = window.innerWidth;
      screenHeight = window.innerHeight;
      const navbarHeight = getComputedStyle(navbar).height;
      cover.style.minWidth = screenWidth + 'px';
      cover.style.minHeight = screenHeight + 'px';
      cover.style.paddingTop = navbarHeight;
    };

    const renderCanvas = () => {
      adjustCoverSize();
    }

    if (document.readyState === 'loading') {
      window.addEventListener('DOMContentLoaded', renderCanvas);
    } else {
      renderCanvas();
    }
    window.addEventListener('resize', renderCanvas);
  }, []);

  return (
    <Layout
      title={`${siteConfig.title}`}
      description="2025 RISC-V Software Porting and Optimization Championship"
      wrapperClassName="in-home-page">
      <HomepageHeader />
      <main>
        <HomeBlogList />
      </main>
    </Layout>
  );
}
