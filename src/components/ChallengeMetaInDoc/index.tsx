import React from 'react';
import { useDoc } from '@docusaurus/theme-common/internal';
import ChallengeMeta from '../ChallengeMeta';

export default function ChallengeMetaInDoc(): JSX.Element {
  const d = useDoc();
  return (
    <ChallengeMeta metadata={d.metadata} isInDoc={true} />
  )
}
