import React, {type ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import {
  useDocById,
} from '@docusaurus/theme-common/internal';
import isInternalUrl from '@docusaurus/isInternalUrl';

import type {Props} from '@theme/DocCard';
import Heading from '@theme/Heading';
import type {
  PropSidebarItemLink,
} from '@docusaurus/plugin-content-docs';

import { usePluginData } from '@docusaurus/useGlobalData';
import Translate from '@docusaurus/Translate';
import ChallengeMeta from '../../ChallengeMeta';
import styles from './styles.module.css';

function ChallengeLayout({
  docId,
  href,
  icon,
  title,
  description,
}: {
  docId: string;
  href: string;
  icon: ReactNode;
  title: string;
  description?: string;
}): JSX.Element {
  const metadata = usePluginData('docusaurus-plugin-content-docs').metadata[docId];
  let fm;
  if (metadata) {
    fm = metadata.frontMatter;
  }
  return (
    <div className={clsx(styles.challengeContainer)}>
      <Link href={href}
        className='challenge'>
        <Heading
          as="h2"
          className={clsx('text--truncate', styles.challengeTitle)}
          title={title}>
          <label>{fm && fm.cid}</label> {icon} {title}
        </Heading>
      </Link>
      <div className={clsx(styles.challengeDescription)}>
        {description && (
          <p>
            {description}
          </p>
        )}
        <ChallengeMeta metadata={metadata} isInDoc={false} className={clsx('text--truncate', styles.challengeMeta)} />
        <Link href={href} className={clsx(styles.detailsBtn)}>
          <Translate id='common.button.details'>详细内容</Translate>
        </Link>
      </div>
    </div>
  );
}

function ChallengeLink({item}: {item: PropSidebarItemLink}): JSX.Element {
  const icon = isInternalUrl(item.href) ? '' : '🔗';
  const doc = useDocById(item.docId ?? undefined);
  return (
    <ChallengeLayout
      docId={item.docId}
      href={item.href}
      icon={icon}
      title={item.label}
      description={item.description ?? doc?.description}
    />
  );
}

export default function ChallengeItem({item}: Props): JSX.Element {
  switch (item.type) {
    case 'link':
      return <ChallengeLink item={item} />;
    default:
      throw new Error(`unknown item type ${JSON.stringify(item)}`);
  }
}
