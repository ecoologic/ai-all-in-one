#!/usr/bin/env bash
# PreToolUse Bash hook: auto-allow read-only commands when cwd is under ~/dev
# Stays silent (exit 0, no output) for anything not clearly read-only,
# letting the normal permission flow take over.
set -u

input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")

case "$PWD" in
  "$HOME/dev"|"$HOME/dev/"*) ;;
  *) exit 0 ;;
esac

[ -z "$cmd" ] && exit 0

# Strip safe stderr-only redirects so they don't trigger the > check below.
clean="${cmd//2>&1/}"
clean="${clean//>&2/}"
clean="${clean//2>\/dev\/null/}"

# Reject: any output redirect, process substitution, command chaining,
# subshell expansion, in-place sed, find -delete.
case "$clean" in
  *">"*|*"<("*|*";"*|*"&&"*|*"||"*|*'$('*|*'`'*|*"sed -i"*|*"-delete"*) exit 0 ;;
esac

# Reject: mutating commands appearing anywhere as a whole word.
padded=" $clean "
for bad in tee dd xargs sudo mv cp mkdir touch rm chmod chown ln cd; do
  case "$padded" in *" $bad "*) exit 0 ;; esac
done

allow_re='^(grep|rg|ls|cat|head|tail|wc|find|file|stat|du|df|which|pwd|tree|diff|echo|printf|type|whoami|hostname|date|uname|env|true|false)$'
git_sub_re='^(status|diff|log|show|blame|ls-files|branch|rev-parse|remote|config|tag|describe)$'

IFS='|' read -ra stages <<<"$cmd"
for stage in "${stages[@]}"; do
  stage="${stage#"${stage%%[![:space:]]*}"}"
  read -r head sub _ <<<"$stage"
  if [ "$head" = "git" ]; then
    [[ "$sub" =~ $git_sub_re ]] || exit 0
  elif [ "$head" = "sed" ]; then
    [ "$sub" = "-n" ] || exit 0
  else
    [[ "$head" =~ $allow_re ]] || exit 0
  fi
done

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"read-only command in ~/dev"}}\n'
