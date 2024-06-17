import useDocusaurusContext from '@docusaurus/useDocusaurusContext';

const getCurrentLocale = () => {
  const { i18n } = useDocusaurusContext();
  return i18n.currentLocale;
};

export default getCurrentLocale;
