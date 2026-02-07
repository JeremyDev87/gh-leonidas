#!/usr/bin/env bash
# gh leonidas update — Update Leonidas workflow files to the latest version

run_update() {
  local force=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force=true ;;
      -h|--help)
        echo "Usage: gh leonidas update [--force]"
        echo ""
        echo "Update Leonidas workflow files to the latest version."
        echo ""
        echo "FLAGS"
        echo "  -f, --force   Update without prompting for confirmation"
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
  info "Updating Leonidas for ${repo}..."
  echo ""

  # Check if installed
  if [[ ! -f ".github/workflows/leonidas-plan.yml" ]]; then
    error "Leonidas is not installed. Run 'gh leonidas setup' first."
    return 1
  fi

  if [[ "$force" != true ]]; then
    warn "This will overwrite your workflow files with the latest templates."
    warn "Your .github/leonidas.md (system prompt) will NOT be overwritten."
    echo ""
    if ! confirm "Continue?"; then
      info "Update cancelled."
      return 0
    fi
    echo ""
  fi

  local ext_dir
  ext_dir="$(get_extension_dir)"
  local template_dir="${ext_dir}/templates"
  local updated=0

  # Update workflow files
  local workflows=("leonidas-plan.yml" "leonidas-execute.yml" "leonidas-track.yml")
  for wf in "${workflows[@]}"; do
    if diff -q "${template_dir}/${wf}" ".github/workflows/${wf}" &>/dev/null; then
      info "  .github/workflows/${wf} (already up to date)"
    else
      cp "${template_dir}/${wf}" ".github/workflows/${wf}"
      success "  .github/workflows/${wf} (updated)"
      ((updated++))
    fi
  done
  echo ""

  if [[ "$updated" -eq 0 ]]; then
    success "All workflow files are already up to date."
  else
    success "${updated} file(s) updated."
    echo ""
    echo "Don't forget to commit and push the changes."
  fi
}
