#!/usr/bin/env bash
# Shared utility functions for gh-leonidas

# Exported constants (used by sourcing scripts)
# shellcheck disable=SC2034
LEONIDAS_VERSION="1.0.0"
# shellcheck disable=SC2034
LEONIDAS_LABEL="leonidas"
# shellcheck disable=SC2034
LEONIDAS_LABEL_COLOR="E99695"
# shellcheck disable=SC2034
LEONIDAS_LABEL_DESC="Leonidas AI automation"

# --- Colors & Output ---

_supports_color() {
  [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]
}

info() {
  if _supports_color; then
    printf "\033[1;34m[info]\033[0m %s\n" "$*"
  else
    printf "[info] %s\n" "$*"
  fi
}

success() {
  if _supports_color; then
    printf "\033[1;32m[ok]\033[0m %s\n" "$*"
  else
    printf "[ok] %s\n" "$*"
  fi
}

warn() {
  if _supports_color; then
    printf "\033[1;33m[warn]\033[0m %s\n" "$*" >&2
  else
    printf "[warn] %s\n" "$*" >&2
  fi
}

error() {
  if _supports_color; then
    printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2
  else
    printf "[error] %s\n" "$*" >&2
  fi
}

# --- Precondition Checks ---

require_gh_auth() {
  if ! gh auth status &>/dev/null; then
    error "Not authenticated with GitHub CLI."
    error "Run 'gh auth login' first."
    exit 1
  fi
}

require_repo_context() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    error "Not inside a git repository."
    error "Run this command from within a GitHub repository."
    exit 1
  fi

  if ! git remote get-url origin &>/dev/null; then
    error "No 'origin' remote found."
    error "This repository must have a GitHub remote."
    exit 1
  fi

  # Always operate from the repository root
  cd "$(git rev-parse --show-toplevel)" || exit 1
}

get_repo_owner_name() {
  gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null
}

# --- Helpers ---

confirm() {
  local prompt="${1:-Continue?}"
  printf "%s [y/N] " "$prompt"
  read -r response
  [[ "$response" =~ ^[Yy]$ ]]
}

# Note: EXTENSION_DIR is set by the main gh-leonidas script before sourcing this file.
