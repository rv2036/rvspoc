import React from 'react';
import clsx from 'clsx';
import {
  useCurrentSidebarCategory,
  filterDocCardListItems,
} from '@docusaurus/theme-common';
import ChallengeItem from './ChallengeItem';
import type {Props} from '@theme/DocCardList';

export default function ChallengesList(props: Props): JSX.Element {
  const {className} = props;
  const category = useCurrentSidebarCategory();
  const items = category.items;
  const filteredItems = filterDocCardListItems(items);
  return (
    <section className={clsx(className)}>
      {filteredItems.map((item, index) => (
        <article key={index} className="margin-bottom--lg">
          <ChallengeItem item={item} />
        </article>
      ))}
    </section>
  );
}
