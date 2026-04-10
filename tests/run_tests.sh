#!/usr/bin/env bash
# run_tests.sh — Eval runner for react-native-best-practices skill
# Requires: jq, claude CLI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
EVALS_FILE="$SCRIPT_DIR/evals.json"

PASS=0
FAIL=0
TOTAL=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================================="
echo "  React Native Best Practices — Skill Evals"
echo "=================================================="
echo ""

# Check dependencies
if ! command -v jq &>/dev/null; then
  echo -e "${RED}ERROR: jq is required. Install with: apt install jq${NC}"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo -e "${YELLOW}WARNING: claude CLI not found. Skipping LLM calls, testing assertions logic only.${NC}"
  MOCK_MODE=true
else
  MOCK_MODE=false
fi

NUM_TESTS=$(jq 'length' "$EVALS_FILE")
echo "Running $NUM_TESTS test cases..."
echo ""

for i in $(seq 0 $((NUM_TESTS - 1))); do
  TOTAL=$((TOTAL + 1))

  ID=$(jq -r ".[$i].id" "$EVALS_FILE")
  PROMPT=$(jq -r ".[$i].prompt" "$EVALS_FILE")
  ASSERTIONS=$(jq -r ".[$i].assertions[]" "$EVALS_FILE")

  echo -n "[$ID] "

  if [ "$MOCK_MODE" = true ]; then
    # Mock mode: skip LLM, just report structure
    echo -e "${YELLOW}SKIP${NC} (claude CLI not available)"
    continue
  fi

  # Call claude CLI
  RESPONSE=$(claude -p "$PROMPT" --allowedTools Read --plugin-dir "$PLUGIN_DIR" 2>/dev/null || echo "")

  if [ -z "$RESPONSE" ]; then
    echo -e "${RED}FAIL${NC} — No response from claude"
    FAIL=$((FAIL + 1))
    continue
  fi

  # Check each assertion
  ALL_PASS=true
  FAILED_ASSERTIONS=()

  while IFS= read -r assertion; do
    # Convert \| to | so grep -E treats it as alternation (not literal pipe)
    clean="${assertion//\\|/|}"
    if ! echo "$RESPONSE" | grep -qiE "$clean"; then
      ALL_PASS=false
      FAILED_ASSERTIONS+=("$assertion")
    fi
  done <<< "$ASSERTIONS"

  if [ "$ALL_PASS" = true ]; then
    echo -e "${GREEN}PASS${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${NC}"
    for fa in "${FAILED_ASSERTIONS[@]}"; do
      echo "       Missing: $fa"
    done
    FAIL=$((FAIL + 1))
  fi

done

echo ""
echo "=================================================="
echo -e "Results: ${GREEN}$PASS PASSED${NC} / ${RED}$FAIL FAILED${NC} / $TOTAL TOTAL"
echo "=================================================="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
