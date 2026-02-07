#!/usr/bin/env bash
# gh leonidas uninstall — Remove Leonidas from the current repository

run_uninstall() {
  local force=false
  local keep_label=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force=true ;;
      --keep-label) keep_label=true ;;
      -h|--help)
        echo "Usage: gh leonidas uninstall [--force] [--keep-label]"
        echo ""
        echo "Remove Leonidas workflow files from the current repository."
        echo ""
        echo "FLAGS"
        echo "  -f, --force       Remove without prompting for confirmation"
        echo "  --keep-label      Keep the 'leonidas' label"
        return 0
        ;;
      *)
        error "Unknown flag: $1"
        return 1
        ;;
    esac
    shift
  done

  require_gh_auth
  require_repo_context

  local repo
  repo="$(get_repo_owner_name)"
  info "Uninstalling Leonidas from ${repo}..."
  echo ""

  if [[ "$force" != true ]]; then
    warn "This will remove the following files:"
    echo "  - .github/workflows/leonidas-plan.yml"
    echo "  - .github/workflows/leonidas-execute.yml"
    echo "  - .github/workflows/leonidas-track.yml"
    echo "  - .github/leonidas.md"
    if [[ "$keep_label" != true ]]; then
      echo "  - '${LEONIDAS_LABEL}' label"
    fi
    echo ""
    if ! confirm "Continue?"; then
      info "Uninstall cancelled."
      return 0
    fi
    echo ""
  fi

  local removed=0

  # Remove workflow files
  local files=(
    ".github/workflows/leonidas-plan.yml"
    ".github/workflows/leonidas-execute.yml"
    ".github/workflows/leonidas-track.yml"
    ".github/leonidas.md"
  )
  for f in "${files[@]}"; do
    if [[ -f "$f" ]]; then
      rm "$f"
      success "  Removed ${f}"
      ((removed++))
    else
      info "  ${f} (not found, skipped)"
    fi
  done
  echo ""

  # Remove label
  if [[ "$keep_label" != true ]]; then
    info "Removing label..."
    if gh label delete "${LEONIDAS_LABEL}" --yes 2>/dev/null; then
      success "  Label '${LEONIDAS_LABEL}' removed"
    else
      info "  Label '${LEONIDAS_LABEL}' not found or already removed"
    fi
    echo ""
  fi

  # Summary
  echo "============================================"
  success "Leonidas has been removed (${removed} files deleted)"
  echo "============================================"
  echo ""
  echo "Don't forget to commit and push the changes."
  echo ""
  echo "To reinstall: gh leonidas setup"
}
