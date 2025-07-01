#!/usr/bin/env bash
set -euo pipefail

BAR_WIDTH=50
TMP_OUT=$(mktemp)

# ---------------------------------------------------------------------------
# Choose the test runner here.
#
# Uncomment or replace one of the TEST_CMD lines to suit your project:
#
#  – ParaTest (parallel, functional tests):
#      TEST_CMD=(vendor/bin/paratest --colors=never --functional)
#
#  – PHPUnit (single-process):
#      TEST_CMD=(vendor/bin/phpunit  --colors=never)
#
#  – Any other script or binary:
#      TEST_CMD=(path/to/custom-runner <opts>)
#
# Keep exactly one TEST_CMD assignment active.
TEST_CMD=(vendor/bin/paratest --colors=never --functional)
# TEST_CMD=(vendor/bin/phpunit  --colors=never)
# ---------------------------------------------------------------------------

# Enhanced ANSI colors and formatting
green=$'\033[0;32m'
red=$'\033[0;31m'
yellow=$'\033[1;33m'
blue=$'\033[0;34m'
cyan=$'\033[0;36m'
magenta=$'\033[0;35m'
bold=$'\033[1m'
dim=$'\033[2m'
reset=$'\033[0m'
clr=$'\033[K'

# Unicode symbols for better visual appeal
check_mark="✓"
cross_mark="✗"
info_mark="ℹ"
warning_mark="⚠"
gear_mark="⚙"
clock_mark="⏱"

completed=0
failed=0
total_seen=0
start_time=$(date +%s)


# Enhanced section divider
print_divider() {
    printf "${dim}%s${reset}\n" "$(printf '─%.0s' $(seq 1 60))"
}

# Improved progress bar with better visual elements
draw() {
    (( total_seen == 0 )) && return

    local pct=$(( (completed + failed)*100/total_seen ))
    (( pct > 100 )) && pct=100

    local passed_fill failed_fill empty
    if (( pct == 100 )); then
        passed_fill=$(( completed*BAR_WIDTH/total_seen ))
        failed_fill=$(( failed*BAR_WIDTH/total_seen ))

        # Adjust for rounding errors
        if (( passed_fill + failed_fill > BAR_WIDTH )); then
            if (( failed > 0 )); then
                failed_fill=$(( BAR_WIDTH - passed_fill ))
            else
                passed_fill=$BAR_WIDTH
            fi
        elif (( passed_fill + failed_fill < BAR_WIDTH )); then
            if (( failed > 0 )); then
                failed_fill=$(( BAR_WIDTH - passed_fill ))
            else
                passed_fill=$BAR_WIDTH
            fi
        fi
        empty=0
    else
        passed_fill=$(( completed*BAR_WIDTH/total_seen ))
        failed_fill=$(( failed*BAR_WIDTH/total_seen ))
        empty=$(( BAR_WIDTH - passed_fill - failed_fill ))
    fi

    # Enhanced progress bar with rounded edges and better symbols
    printf '\r%s %s[' "${cyan}${bold}${reset}"
    (( passed_fill > 0 )) && printf "${green}%0.s█${reset}" $(seq 1 "$passed_fill")
    (( failed_fill > 0 )) && printf "${red}%0.s█${reset}" $(seq 1 "$failed_fill")
    (( empty > 0 )) && printf "${dim}%0.s░${reset}" $(seq 1 "$empty")

    # Color-coded percentage
    local pct_color=""
    if (( pct == 100 )); then
        if (( failed > 0 )); then
            pct_color="${red}${bold}"
        else
            pct_color="${green}${bold}"
        fi
    elif (( pct >= 75 )); then
        pct_color="${green}"
    elif (( pct >= 50 )); then
        pct_color="${yellow}"
    else
        pct_color="${red}"
    fi

    printf '] %s%3d%%%s ' "$pct_color" "$pct" "$reset"

    # Enhanced status display
    if (( failed > 0 )); then
        printf "${green}%s %d${reset} ${red}%s %d${reset} ${dim}of %d${reset}%s" \
            "$check_mark" "$completed" "$cross_mark" "$failed" "$total_seen" "$clr"
    else
        printf "${green}%s %d${reset} ${dim}of %d${reset}%s" \
            "$check_mark" "$completed" "$total_seen" "$clr"
    fi
}

# Calculate and format duration
format_duration() {
    local duration=$1
    if (( duration < 60 )); then
        printf "%.1fs" "$duration"
    elif (( duration < 3600 )); then
        printf "%dm %.1fs" $((duration / 60)) $((duration % 60))
    else
        printf "%dh %dm %.1fs" $((duration / 3600)) $(((duration % 3600) / 60)) $((duration % 60))
    fi
}

# ─── run ParaTest ────────────────────────────────────────────
set +e
paratest_exit_code=0
stdbuf -oL -eL "${TEST_CMD[@]}" "$@" | \
while IFS= read -r line; do
    printf '%s\n' "$line" >>"$TMP_OUT"

    # Progress lines "…  488 / 1227 ( 39%)"
    if [[ $line =~ ([0-9]+)[[:space:]]*/[[:space:]]*([0-9]+) ]]; then
        completed=${BASH_REMATCH[1]}
        total_seen=${BASH_REMATCH[2]}
        draw
    fi
done
paratest_exit_code=${PIPESTATUS[1]}
set -e

# ─── force bar to 100% and extract final results ──────────────
if last_progress=$(grep -oE '[0-9]+[[:space:]]*/[[:space:]]*[0-9]+' "$TMP_OUT" | tail -n1); then
    if [[ $last_progress =~ ([0-9]+)[[:space:]]*/[[:space:]]*([0-9]+) ]]; then
        completed=${BASH_REMATCH[1]}
        total_seen=${BASH_REMATCH[2]}
    fi
fi

# Parse the final test summary for accurate counts
failed=0
if summary_line=$(grep -E 'Tests: *[0-9]+.*Failures: *[0-9]+' "$TMP_OUT" | tail -n1); then
    if [[ $summary_line =~ Tests:[[:space:]]*([0-9]+) ]]; then
        total_tests=${BASH_REMATCH[1]}
        total_seen=$total_tests
    fi
    if [[ $summary_line =~ Failures:[[:space:]]*([0-9]+) ]]; then
        failed=${BASH_REMATCH[1]}
    fi
    if [[ $summary_line =~ Errors:[[:space:]]*([0-9]+) ]]; then
        failed=$((failed + ${BASH_REMATCH[1]}))
    fi
    completed=$((total_seen - failed))
elif summary_line=$(grep -E 'OK.*\([0-9]+ tests?' "$TMP_OUT" | tail -n1); then
    if [[ $summary_line =~ \(([0-9]+) ]]; then
        completed=${BASH_REMATCH[1]}
        total_seen=$completed
        failed=0
    fi
fi

# Final progress bar draw
draw
echo
echo

# Calculate execution time
end_time=$(date +%s)
duration=$((end_time - start_time))
formatted_duration=$(format_duration $duration)

# Results
if (( failed == 0 )); then
    printf "${green}%s All tests passed ${reset}\n" "$check_mark"
else
    printf "${red}%s Tests failed${reset}\n" "$cross_mark"
    printf "${green}  Passed: ${bold}%d${reset}\n" "$completed"
    printf "${red}  Failed: ${bold}%d${reset}\n" "$failed"
fi

echo

# Enhanced summary output with better formatting
summary_output=$(grep -E '^(OK|FAILURES|ERRORS|WARNINGS|Tests:|Assertions:|Deprecations:)' "$TMP_OUT" || true)
if [[ -n "$summary_output" ]]; then

    while IFS= read -r line; do
        if [[ $line =~ ^OK ]]; then
            printf "${green}%s %s${reset}\n" "$check_mark" "$line"
        elif [[ $line =~ ^WARNINGS ]]; then
            printf "${yellow}%s %s${reset}\n" "$warning_mark" "$line"
        fi
    done <<< "$summary_output"
    echo
fi

# Show diagnostic output if there are failures
if echo "$summary_output" | grep -qE '(FAILURES|ERRORS)' || (( paratest_exit_code != 0 )); then
    printf "${red}${bold}%s Detailed failure information:${reset}\n" "$warning_mark"
    echo

    # Filter and format diagnostic output - skip paratest headers and progress lines
    grep -Ev '^\s*[\.DEFIRS]+\s+[0-9]+ / [0-9]+' "$TMP_OUT" | \
    sed '/^$/d' | \
    while IFS= read -r line; do
        if [[ $line =~ ^[0-9]+\) ]]; then
            printf "${red}${bold}%s${reset}\n" "$line"
        elif [[ $line =~ ^Failed ]]; then
            printf "${red}├─ %s${reset}\n" "$line"
        elif [[ $line =~ ^(PHPUnit|Time:|OK|Tests:) ]]; then
            # Skip these lines as they're already shown in summary
            continue
        elif [[ $line =~ ^(ParaTest|Processes:|Runtime:|Configuration:|Random\ Seed:) ]]; then
            # Skip paratest header information
            continue
        elif [[ $line =~ ^[\.DEFIRS\s]*$ ]]; then
            # Skip lines with only test progress dots
            continue
        else
            # Regular diagnostic lines (after filtering out headers)
            printf "${dim}│  %s${reset}\n" "$line"
        fi
    done
    echo
fi

# Final status message
print_divider
if (( failed == 0 && paratest_exit_code == 0 )); then
    printf "${green}${bold}%s Success! All tests completed successfully in %s${reset}\n" \
        "$check_mark" "$formatted_duration"
else
    printf "${red}${bold}%s Testing completed with %d failure(s) in %s${reset}\n" \
        "$cross_mark" "$failed" "$formatted_duration"
fi
print_divider
echo

# Cleanup
rm -f "$TMP_OUT"

# Exit with the same code as paratest
exit $paratest_exit_code

