import React from 'react';
import clsx from 'clsx';
import type {Props} from '@theme/Footer/Layout';
import Translate from '@docusaurus/Translate';
import Link from '@docusaurus/Link';

export default function FooterLayout({
  style,
  links,
  logo,
  copyright,
}: Props): JSX.Element {
  return (
    <footer
      className={clsx('footer', {
        'footer--dark': style === 'dark',
      })}>
      <div className="container container-fluid">
        {links}
        {(logo || copyright) && (
          <div className="footer__bottom text--center">
            {logo && <div className="margin-bottom--sm">{logo}</div>}
            <div className="cc-license">
              <Translate id="common.footer.cc.prefix">除另有说明外，本网站内容采用</Translate>&ensp;
              <Link className="footer__link-item" to="https://creativecommons.org/licenses/by-nc-sa/4.0/"><Translate id="common.footer.cc.license">知识共享 署名-非商业性使用-相同方式共享 4.0 国际许可协议</Translate></Link>&ensp;
              <Translate id="common.footer.cc.suffix">进行许可。</Translate>
            </div>
            {copyright}
          </div>
        )}
      </div>
    </footer>
  );
}
