## Second iteration

### QA ideas

`a-criterion` (and any steps after it) may discover bugs in code **we wrote** (i.e. code produced by earlier `a-criterion` runs in the same or a previous epic). Ignore issues from features not yet implemented.

When a bug is found, append it to `./planning/<epic-slug>/qa-ideas.md`:

```markdown
- [ ] **<short title>** — <description of the bug and where it was found> (`<file-path>:<line>`)
```

Create the file if it doesn't exist. Never remove existing entries.

Maybe just `/a-review` does all?

```
a-unhappy-path -> a-unhappy-path-n -> a-security -> a-security-n -> a-bug -> a-bug-n -> a-qa -> a-qa-n
```

## Details

We have already worked on some of these, but each new command might require to update one or more of the others.

And I appreciate your input and help to make them the most efficient to work with you.

But we will create them sequentially, one at a time, over the course of many sessions. Note this file has a section just for your thoughts, that I'd be happy for you to keep updated with your notes and suggestions for work to come. Feel free to edit "below the line".

Before we implement a command, write your comments "below the line".

I think we might benefit from a separate file to group these commands as project. Is it possible to nest sub-folders in the command directory? what would you suggest here?

## My suggestion

- Ensure we use all the Claude template keywords and tags appropriately
- Make sure we explicitly state to use (and list) the relevant skills
- Make sure each command is aware of the previous and next one, what they can, and cannot do (eg: write code)

### Possible improvements to consider

- `a-global-architecture` to generate the global architecture map from the codebase, very high level
- Idea: `a-idea` to brainstorm??
- eg: `a-epic` finds epic for later
  - Nice-to-have
