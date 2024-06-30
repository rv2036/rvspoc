import React from 'react';
import clsx from 'clsx';
import Translate from '@docusaurus/Translate';
import AdmonitionTypeWarning from '@theme/Admonition/Type/Warning';
import styles from './styles.module.scss';

export default function ChallengeDraftAnnouncement(): JSX.Element {
  return (
    <AdmonitionTypeWarning className={clsx(styles.challengeDraftAnnouncement)}>
      <Translate id='common.announcement.draft'>本赛题处于草案状态，等待赞助商最终确认。</Translate>
    </AdmonitionTypeWarning>
  )
}
