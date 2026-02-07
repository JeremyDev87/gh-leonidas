#!/usr/bin/env bash
# gh leonidas setup — Install Leonidas into the current repository

run_setup() {
  local force=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force=true ;;
      -h|--help)
        echo "Usage: gh leonidas setup [--force]"
        echo ""
        echo "Install Leonidas workflow files into the current repository."
        echo ""
        echo "FLAGS"
        echo "  -f, --force   Overwrite existing files without prompting"
        return 0
        ;;
      *)
        error "Unknown flag: $1"
        return 1
        ;;
    esac
    shift
  done

  info "Setting up Leonidas..."
  echo ""

  # Precondition checks
  require_gh_auth
  require_repo_context

  local repo
  repo="$(get_repo_owner_name)"
  info "Repository: ${repo}"
  echo ""

  local template_dir="${EXTENSION_DIR}/templates"

  # Check if already installed
  if [[ -f ".github/workflows/leonidas-plan.yml" ]] && [[ "$force" != true ]]; then
    warn "Leonidas workflow files already exist."
    if ! confirm "Overwrite existing files?"; then
      info "Setup cancelled."
      return 0
    fi
  fi

  # Create directories
  mkdir -p .github/workflows

  # Copy workflow files
  info "Copying workflow files..."
  cp "${template_dir}/leonidas-plan.yml" .github/workflows/leonidas-plan.yml
  success "  .github/workflows/leonidas-plan.yml"

  cp "${template_dir}/leonidas-execute.yml" .github/workflows/leonidas-execute.yml
  success "  .github/workflows/leonidas-execute.yml"

  cp "${template_dir}/leonidas-track.yml" .github/workflows/leonidas-track.yml
  success "  .github/workflows/leonidas-track.yml"

  # Copy system prompt
  info "Copying system prompt..."
  if [[ -f ".github/leonidas.md" ]] && [[ "$force" != true ]]; then
    warn "  .github/leonidas.md already exists (skipped)"
  else
    cp "${template_dir}/leonidas.md" .github/leonidas.md
    success "  .github/leonidas.md"
  fi
  echo ""

  # Create label
  info "Creating 'leonidas' label..."
  if gh label list --json name --jq '.[].name' 2>/dev/null | grep -qx "${LEONIDAS_LABEL}"; then
    success "  Label '${LEONIDAS_LABEL}' already exists"
  else
    if gh label create "${LEONIDAS_LABEL}" \
      --color "${LEONIDAS_LABEL_COLOR}" \
      --description "${LEONIDAS_LABEL_DESC}" 2>/dev/null; then
      success "  Label '${LEONIDAS_LABEL}' created"
    else
      warn "  Failed to create label (you may need to create it manually)"
    fi
  fi
  echo ""

  # Check for ANTHROPIC_API_KEY secret
  info "Checking ANTHROPIC_API_KEY secret..."
  if gh secret list --json name --jq '.[].name' 2>/dev/null | grep -qx "ANTHROPIC_API_KEY"; then
    success "  ANTHROPIC_API_KEY is set"
  else
    warn "  ANTHROPIC_API_KEY is not set"
    echo ""
    echo "  To set it, run:"
    echo "    gh secret set ANTHROPIC_API_KEY"
    echo ""
    echo "  Or set it in GitHub: Settings > Secrets and variables > Actions"
  fi
  echo ""

  # Summary
  echo "============================================"
  success "Leonidas setup complete!"
  echo "============================================"
  echo ""
  echo "Next steps:"
  echo "  1. Set ANTHROPIC_API_KEY secret (if not already done)"
  echo "  2. Customize .github/leonidas.md for your project"
  echo "  3. Commit and push the new files"
  echo "  4. Create an issue with the 'leonidas' label to test"
  echo ""
  echo "Learn more: https://github.com/JeremyDev87/leonidas"
}
