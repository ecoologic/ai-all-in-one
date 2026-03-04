I want to create a global command to address PR comments:

check all the PR comments, group them by similarity and repetition, and order them by importance,

then present a numbered list with the path:line-number the line of code and the comment

eg:

- api/src/utils/database/migrations/scripts/00086-data-partners.ts:1
  - export function AddDataPartnerDialog({
    - This name is wrong whatever...

Do not try to solve the issue (important) ,we'll do that separately after user input
