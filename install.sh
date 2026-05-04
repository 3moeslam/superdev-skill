#!/usr/bin/env bash
#
# install.sh — install superdev-skills into ~/.claude/skills/
#
# Usage:
#   ./install.sh           # copy each skill (default)
#   ./install.sh --link    # symlink each skill (development mode)
#   ./install.sh --help
#
# Idempotent: safely re-runnable. Existing files of the same name are backed up
# to <name>.bak.<timestamp> before being replaced.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.claude/skills"
SKILLS=(superdev team-code-review)
MODE="copy"

usage() {
  sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --link) MODE="link" ;;
    --help|-h) usage ;;
    *) echo "unknown option: $1" >&2; usage ;;
  esac
  shift
done

mkdir -p "${TARGET_DIR}"

backup_if_exists() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    local stamp
    stamp=$(date +%Y%m%d-%H%M%S)
    local backup="${path}.bak.${stamp}"
    echo "  backing up existing: ${path} -> ${backup}"
    mv "$path" "$backup"
  fi
}

install_skill() {
  local skill="$1"
  local src="${REPO_ROOT}/${skill}"
  local dst="${TARGET_DIR}/${skill}"

  if [[ ! -d "$src" ]]; then
    echo "  skip: source missing: $src" >&2
    return
  fi

  backup_if_exists "$dst"

  if [[ "$MODE" == "link" ]]; then
    ln -s "$src" "$dst"
    echo "  linked: $dst -> $src"
  else
    cp -R "$src" "$dst"
    echo "  copied: $src -> $dst"
  fi
}

echo "Installing superdev-skills (${MODE}) into ${TARGET_DIR}"
for skill in "${SKILLS[@]}"; do
  install_skill "$skill"
done

echo
echo "Done. Restart your Claude Code session (or run /skills reload) to pick up the new skills."
echo "Activate superdev with /superdev <task> or /plan <task>."
echo "Run a multi-agent code review with /team-code-review branch."
