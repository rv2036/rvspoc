import React from 'react';
import clsx from 'clsx';
import Translate from '@docusaurus/Translate';
import { usePluginData } from '@docusaurus/useGlobalData';
import { type DocMetadata } from '@docusaurus/plugin-content-docs';
import './style.scss';

export default function ChallengeMeta({
  isInDoc,
  docId,
  metadata,
  className,
}: {
  isInDoc?: boolean;
  docId?: string;
  metadata?: DocMetadata;
  className?: string;
}): JSX.Element {
  let inDoc = 'in-doc-false';
  if (isInDoc) {
    inDoc = 'in-doc-true';
  }
  if (!metadata && docId) {
    metadata = usePluginData('docusaurus-plugin-content-docs').metadata[docId];
  }
  if (!metadata) {
    return null
  }
  const fm = metadata.frontMatter;
  if (!fm) {
    return null
  }
  //console.log(fm);
  return (
    <div className={clsx('challenge-metadata', inDoc, className)}>
      {inDoc === 'in-doc-true' && (
        <div>
          <label><Translate id='common.metadata.cid'>编　　号</Translate></label>
          <span>{fm.cid}</span>
        </div>
      )}
      <div>
        <label><Translate id='common.metadata.award'>奖　　金</Translate></label>
        <span>{fm.award}</span>
      </div>
      <div>
        <label><Translate id='common.metadata.championsCount'>冠军个数</Translate></label>
        <span>{fm.numberOfChampions}</span>
      </div>
    </div>
  )
}
