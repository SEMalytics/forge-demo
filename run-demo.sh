#!/bin/bash
# Forge Demo Runner
# https://github.com/SEMalytics/forge-demo
#
# Usage: ./run-demo.sh [demo-name] [options]
# 
# Options:
#   --iterate-only  Just run iterate on existing project (uses stable ID)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITERATE_ONLY=""

# Enable debug logging
export FORGE_LOG_LEVEL=DEBUG

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --iterate-only)
            ITERATE_ONLY="true"
            shift
            ;;
        *)
            DEMO_NAME="$1"
            shift
            ;;
    esac
done

DEMO_NAME="${DEMO_NAME:-sql}"

print_header() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
}

print_info() {
    echo "  Failure Type: $1"
    echo "  Agent:        $2"
    echo "  Pattern:      $3"
    echo ""
}

run_demo() {
    local project_id="$1"
    local display_name="$2"
    local description="$3"
    local tags="$4"
    
    if [ -n "$ITERATE_ONLY" ]; then
        echo "→ Running iterate on existing project: $project_id"
        echo ""
        forge iterate -p "$project_id" --max-iterations 5
        return
    fi
    
    echo "→ Initializing project..."
    forge init "$display_name" -i "$project_id" -d "$description"
    
    echo ""
    echo "→ Decomposing requirements..."
    forge decompose "$description" $tags -p "$project_id" -s
    
    echo ""
    echo "→ Building project..."
    forge build -p "$project_id" --parallel --max-parallel 3
    
    echo ""
    echo "→ Running iterate loop (test → diagnose → fix → repeat)..."
    forge iterate -p "$project_id" --max-iterations 5
}

case "$DEMO_NAME" in
    sql|injection|sql-injection)
        print_header "SQL INJECTION DEMO"
        print_info "SECURITY_VULNERABILITY" "SecurityReviewer" "operations/security.md"
        echo "Scenario: f-string SQL query with user input"
        echo "Expected: Catch injection → Apply parameterized queries"
        echo ""
        
        run_demo "demo-sql" \
            "demo-sql-injection" \
            "Create a Python function get_user_by_username that queries a SQLite database. Use f-string formatting to build the SQL query with user input directly concatenated. Include a main block demonstrating usage." \
            "-t python -t sqlite"
        ;;
        
    div|division|zero|divide)
        print_header "DIVISION BY ZERO DEMO"
        print_info "ZERO_DIVISION_ERROR" "QualityReviewer" "input validation"
        echo "Scenario: Division without zero check"
        echo "Expected: Catch ZeroDivisionError → Add guard clause"
        echo ""
        
        run_demo "demo-div" \
            "demo-division" \
            "Create a Python function called divide that accepts numerator and denominator parameters and returns the division result. Do not include any input validation or error handling. Keep implementation minimal." \
            "-t python"
        ;;
        
    secret|key|hardcoded|api-key)
        print_header "HARDCODED SECRET DEMO"
        print_info "SECURITY_VULNERABILITY" "SecurityReviewer" "operations/security.md"
        echo "Scenario: API key embedded in source code"
        echo "Expected: Catch hardcoded credential → Use environment variable"
        echo ""
        
        run_demo "demo-secret" \
            "demo-hardcoded-secret" \
            "Create a Python WeatherClient class with an __init__ method that hardcodes the API key as sk-1234567890abcdef directly in the source code. Include a get_weather method that uses requests to call a weather API." \
            "-t python -t requests"
        ;;
        
    cmd|command|shell|injection-cmd)
        print_header "COMMAND INJECTION DEMO"
        print_info "SECURITY_VULNERABILITY" "SecurityReviewer" "operations/security.md"
        echo "Scenario: subprocess with shell=True and user input"
        echo "Expected: Catch command injection → Sanitize input, remove shell=True"
        echo ""
        
        run_demo "demo-cmd" \
            "demo-command-injection" \
            "Create a Python function compress_file that accepts a filename from user input and uses subprocess.run with shell=True to execute gzip on the file. Build the command using f-string with the filename directly." \
            "-t python"
        ;;
        
    perf|performance|n2|quadratic)
        print_header "O(n²) PERFORMANCE DEMO"
        print_info "PERFORMANCE_DEGRADATION" "PerformanceReviewer" "core/architecture.md"
        echo "Scenario: Nested loops when O(n) is possible"
        echo "Expected: Catch quadratic complexity → Use set-based approach"
        echo ""
        
        run_demo "demo-perf" \
            "demo-performance" \
            "Create a Python function find_duplicates that accepts a list and returns items appearing more than once. Use nested for loops to compare each item with every other item. Do not use sets or dictionaries." \
            "-t python"
        ;;
        
    list|help|-h|--help)
        echo "Forge Demo Runner"
        echo "https://github.com/SEMalytics/forge-demo"
        echo ""
        echo "Usage: ./run-demo.sh [demo] [options]"
        echo ""
        echo "Available demos:"
        echo "  sql       SQL injection via f-string query"
        echo "  div       Division by zero (missing guard)"
        echo "  secret    Hardcoded API key in source"
        echo "  cmd       Command injection via shell=True"
        echo "  perf      O(n²) nested loop performance"
        echo ""
        echo "Options:"
        echo "  --iterate-only  Just run iterate on existing project"
        echo ""
        echo "Examples:"
        echo "  ./run-demo.sh sql              # Full demo from scratch"
        echo "  ./run-demo.sh sql --iterate-only  # Just iterate (fast)"
        echo ""
        echo "Project IDs are stable (no timestamp suffix):"
        echo "  demo-sql, demo-div, demo-secret, demo-cmd, demo-perf"
        echo ""
        ;;
        
    status)
        echo "Current Forge projects:"
        forge status
        ;;
        
    clean)
        echo "To clean demo projects:"
        echo "  forge delete demo-sql demo-div demo-secret demo-cmd demo-perf"
        echo ""
        echo "Or remove all:"
        echo "  rm -rf .forge/projects/demo-*"
        echo ""
        echo "Current demo projects:"
        forge status 2>/dev/null | grep "demo-" || echo "  (none found)"
        ;;
        
    *)
        echo "Unknown demo: $DEMO_NAME"
        echo ""
        echo "Run './run-demo.sh list' for available demos"
        exit 1
        ;;
esac
