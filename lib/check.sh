#!/usr/bin/env bash
# gh leonidas check — Verify Leonidas installation status

run_check() {
  require_gh_auth
  require_repo_context

  local repo
  repo="$(get_repo_owner_name)"
  info "Checking Leonidas installation for ${repo}..."
  echo ""

  local pass=0
  local fail=0

  # Check workflow files
  local workflows=("leonidas-plan.yml" "leonidas-execute.yml" "leonidas-track.yml")
  for wf in "${workflows[@]}"; do
    if [[ -f ".github/workflows/${wf}" ]]; then
      success "  .github/workflows/${wf}"
      pass=$((pass + 1))
    else
      error "  .github/workflows/${wf} (missing)"
      fail=$((fail + 1))
    fi
  done

  # Check system prompt
  if [[ -f ".github/leonidas.md" ]]; then
    success "  .github/leonidas.md"
    ((pass++))
  else
    error "  .github/leonidas.md (missing)"
    ((fail++))
  fi
  echo ""

  # Check label
  info "Label:"
  if gh label list --json name --jq '.[].name' 2>/dev/null | grep -qx "${LEONIDAS_LABEL}"; then
    success "  '${LEONIDAS_LABEL}' label exists"
    ((pass++))
  else
    error "  '${LEONIDAS_LABEL}' label not found"
    ((fail++))
  fi
  echo ""

  # Check secret
  info "Secret:"
  if gh secret list --json name --jq '.[].name' 2>/dev/null | grep -qx "ANTHROPIC_API_KEY"; then
    success "  ANTHROPIC_API_KEY is set"
    ((pass++))
  else
    error "  ANTHROPIC_API_KEY is not set"
    ((fail++))
  fi
  echo ""

  # Check authorization in execute workflow
  info "Security:"
  if [[ -f ".github/workflows/leonidas-execute.yml" ]]; then
    if grep -q "author_association == 'OWNER'" ".github/workflows/leonidas-execute.yml"; then
      success "  Authorization check present in execute workflow"
      pass=$((pass + 1))
    else
      warn "  No authorization check in execute workflow"
      echo "    See: https://github.com/JeremyDev87/leonidas/blob/main/.github/SECURITY_PATCH.md"
      fail=$((fail + 1))
    fi
  fi
  echo ""

  # Summary
  echo "============================================"
  echo "  Results: ${pass} passed, ${fail} failed"
  echo "============================================"

  if [[ "$fail" -eq 0 ]]; then
    success "Leonidas is properly configured!"
  else
    warn "Some checks failed. Run 'gh leonidas setup' to fix."
  fi

  [[ "$fail" -eq 0 ]] && return 0 || return 1
}
