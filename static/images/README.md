# The store & usage conventions for media files

- Media files in different sections are placed in directories with their own names.
  - posts for posts
  - challenges for challenges
- The name of a common media file for all languages should not have a language suffix.
- The name of a language-specific media file should have a `.<code>` suffix,
  for example: `the-common-name.en.png` .
- The media file can be accessed from the path `/images/{posts,challenges}/<the-file-name>` .
