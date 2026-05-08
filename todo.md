# TODOs

## Commands

- `/progress` to handle checklists
- `/accurate` no assumptions, every claim has reference, question my statements, code > docs, ignore planning, why you coudln't verify (?maybe, it might stop telling me?), only answer the specific question in the merit, to the point, no extra context nobody asked

## Sup

* `ln -s dev-docs` in prj
* `qa` as a subagent in plan
  * no docker instructions, prep db etc, step-by-step, my user...

## Meta

- `/qk` quick subagent refactor in light model

- Subagents??
- Use extended thinking in skills and commands
- GLOBAL.md: extract skills
- skill? `/pr-learn - /pr-review`: at the end of fixing stuff, update a file with the rules, then we run it before pushing
- My tone `/pr-comments` (with examples)
- Review for token optimisation. Consider parsing tokens, but particularly output (generation) tokens from the instructions
- stretch: I might mention something during the commands interactions, eg: stretch story, feature, refactor, we should store that in a stretch artifact (one section for each command). maybe hardcode commands, eg: find-current-epic.
- `a-refactor` before `a-criterion`

## Agile plan

- The process needs to be way more interactive
- The process needs more "self-review"
- Stories need "when shit happens" ACs
- Consider extra architecture docs in `./planning/architecture/`
- No `.plan.md`, just `.md`
- Criterion ultimate line of defence for reviewing architecture and ui
- New `/a-board` to update the board using `./planning/current.json` (don't touch worked on stories)
