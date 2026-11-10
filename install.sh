#!/usr/bin/env bash
# agent-harness installer
#   ./install.sh                      core skills -> Codex + Claude Code (user level)
#   ./install.sh --with ml,ui         core + optional groups (ml | ui | parallel | process | all)
#   ./install.sh --project DIR        install into DIR/.agents/skills instead of the home folder
#   ./install.sh --auto               keep upstream auto-invocation (default: skills run only when called by name)
#   ./install.sh init [DIR]           copy working files (PLAN.md ...) into a workspace, never overwriting;
#                                     writes AGENTS.md only when the workspace has none
#   ./install.sh list                 show what is available / installed
#   ./install.sh uninstall            remove only what this script installed
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARK=".agent-harness"
AUTO=0
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
CLAUDE_DIR="$HOME/.claude/skills"

say()  { printf '%s\n' "$*"; }
warn() { printf 'skip: %s\n' "$*" >&2; }

skill_dirs() {            # $1 = comma separated optional groups
  local g
  find "$HERE/skills" -mindepth 1 -maxdepth 1 -type d | sort
  [ -z "${1:-}" ] && return 0
  for g in ${1//,/ }; do
    if [ "$g" = "all" ]; then
      find "$HERE/optional" -mindepth 2 -maxdepth 2 -type d | sort
    elif [ -d "$HERE/optional/$g" ]; then
      find "$HERE/optional/$g" -mindepth 1 -maxdepth 1 -type d | sort
    else
      warn "unknown group '$g' (ml | ui | parallel | process | all)"
    fi
  done
}

explicit_only() {         # $1 = installed skill dir. The agent may run it only when the user names it.
  local y="$1/agents/openai.yaml" s="$1/SKILL.md"
  if ! grep -qs 'allow_implicit_invocation' "$y"; then          # Codex
    if grep -qs '^policy:' "$y"; then
      warn "$y has a policy block; left as is"
    else
      mkdir -p "$1/agents"
      [ -s "$y" ] && [ -n "$(tail -c1 "$y")" ] && echo >> "$y"
      printf 'policy:\n  allow_implicit_invocation: false\n' >> "$y"
    fi
  fi
  # Claude Code
  if [ -f "$s" ] && ! grep -q '^disable-model-invocation:' "$s"; then
    sed -i.bak '0,/^name:.*$/s//&\ndisable-model-invocation: true/' "$s" && rm -f "$s.bak"
  fi
}

install_into() {          # $1 = target skills dir, $2 = groups
  local target="$1" src name dst n=0
  mkdir -p "$target"
  while IFS= read -r src; do
    name="$(basename "$src")"; dst="$target/$name"
    if [ -e "$dst" ] && [ ! -e "$dst/$MARK" ]; then
      warn "$dst already exists and is not ours"; continue
    fi
    rm -rf "$dst"; cp -R "$src" "$dst"; : > "$dst/$MARK"; n=$((n + 1))
    [ "$AUTO" = 1 ] || explicit_only "$dst"
  done < <(skill_dirs "$2")
  say "installed $n skills -> $target"
}

cmd_skills() {
  local groups="" project="" codex=1 claude=1
  while [ $# -gt 0 ]; do
    case "$1" in
      --with)        groups="${2:-}"; shift 2 ;;
      --project)     project="${2:-}"; shift 2 ;;
      --codex-only)  claude=0; shift ;;
      --claude-only) codex=0; shift ;;
      --auto)        AUTO=1; shift ;;
      *) say "unknown option: $1"; exit 2 ;;
    esac
  done
  if [ -n "$project" ]; then
    install_into "$project/.agents/skills" "$groups"
    say "note: .agents/ now lives inside the workspace. Add it to .gitignore if it should not be committed."
  else
    [ "$codex" = 1 ]  && install_into "$CODEX_DIR" "$groups"
    [ "$claude" = 1 ] && install_into "$CLAUDE_DIR" "$groups"
  fi
  say "Codex: type \$skill-name or pick from /skills.  Claude Code: /skill-name."
  [ "$AUTO" = 1 ] || say "Skills run only when you call them by name (use --auto to keep upstream auto-invocation)."
  say "Start a new session so the skill list is reloaded."
}

cmd_init() {
  local ws="${1:-.}" f rel existing=""
  mkdir -p "$ws/review"
  for f in PLAN.md RESULTS.md DECISIONS.md ARCHITECTURE.md PITCH.md check.sh \
           review/R1.md review/R2.md review/R3.md; do
    rel="$ws/$f"
    if [ -e "$rel" ]; then warn "$rel exists"; else
      cp "$HERE/templates/$f" "$rel"; say "created $rel"
      [ "$f" = check.sh ] && chmod +x "$rel"
    fi
  done
  for f in "$ws/AGENTS.md" "$ws/AGENTS.override.md" "$ws/.codex/AGENTS.md" "$ws/.codex/AGENTS.override.md" "$ws/CLAUDE.md"; do
    [ -e "$f" ] && { say "found existing instructions: $f  <- read this first"; existing=1; }
  done
  if [ -n "$existing" ]; then
    if [ -e "$ws/AGENTS.append.md" ]; then warn "$ws/AGENTS.append.md exists"
    else cp "$HERE/templates/AGENTS.md" "$ws/AGENTS.append.md"; say "created $ws/AGENTS.append.md"; fi
    say "The existing instructions were left untouched. AGENTS.append.md is NOT applied: paste only the lines that do not conflict."
  else
    cp "$HERE/templates/AGENTS.md" "$ws/AGENTS.md"; say "created $ws/AGENTS.md (no instructions file in this folder; check for others the platform injects). Start a new session so it is read."
  fi
}

cmd_list() {
  local d
  say "core:";     find "$HERE/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | sed 's/^/  /'
  for d in "$HERE"/optional/*/; do
    say "optional/$(basename "$d"):"; find "$d" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | sed 's/^/  /'
  done
  for d in "$CODEX_DIR" "$CLAUDE_DIR"; do
    [ -d "$d" ] || continue
    say "installed in $d:"; find "$d" -mindepth 2 -maxdepth 2 -name "$MARK" -exec dirname {} \; | xargs -r -n1 basename | sort | sed 's/^/  /'
  done
}

cmd_uninstall() {
  local d m
  for d in "$CODEX_DIR" "$CLAUDE_DIR" "${1:+$1/.agents/skills}"; do
    [ -n "$d" ] && [ -d "$d" ] || continue
    while IFS= read -r m; do rm -rf "$(dirname "$m")"; say "removed $(dirname "$m")"; done \
      < <(find "$d" -mindepth 2 -maxdepth 2 -name "$MARK")
  done
}

case "${1:-skills}" in
  init)      shift; cmd_init "$@" ;;
  list)      cmd_list ;;
  uninstall) shift; cmd_uninstall "$@" ;;
  skills)    shift || true; cmd_skills "$@" ;;
  -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//' ;;
  --*)       cmd_skills "$@" ;;
  *)         say "unknown command: $1"; exit 2 ;;
esac
