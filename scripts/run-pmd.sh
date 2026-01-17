#!/bin/bash

# FlowOps PMD Analysis Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PMD_VERSION="6.55.0"
PMD_RULESET="pmd-ruleset.xml"
REPORT_FILE="pmd-report.xml"
HTML_REPORT="pmd-report.html"
CSV_REPORT="pmd-report.csv"

# Directories
SOURCE_DIR="."
EXCLUDE_PATTERNS="**/test/**,**/spec/**,**/node_modules/**,**/target/**,**/dist/**,**/build/**"

echo -e "${BLUE}🔍 FlowOps PMD Code Quality Analysis${NC}"
echo -e "${BLUE}=====================================${NC}"

# Check if PMD is installed
if ! command -v pmd &> /dev/null; then
    echo -e "${YELLOW}📦 PMD not found. Installing PMD ${PMD_VERSION}...${NC}"
    
    # Download PMD
    if [ ! -f "pmd-bin-${PMD_VERSION}.zip" ]; then
        wget "https://github.com/pmd/pmd/releases/download/pmd/${PMD_VERSION}/pmd-bin-${PMD_VERSION}.zip"
        unzip "pmd-bin-${PMD_VERSION}.zip"
        rm "pmd-bin-${PMD_VERSION}.zip"
    fi
    
    PMD_CMD="./pmd-bin-${PMD_VERSION}/bin/pmd"
else
    PMD_CMD="pmd"
fi

echo -e "${GREEN}✅ Using PMD: $PMD_CMD${NC}"

# Function to run PMD analysis
run_pmd_analysis() {
    local analysis_type=$1
    local output_format=$2
    
    echo -e "${YELLOW}🔍 Running PMD analysis: $analysis_type${NC}"
    
    $PMD_CMD \
        -d "$SOURCE_DIR" \
        -R "$PMD_RULESET" \
        -f "$output_format" \
        -r "$REPORT_FILE" \
        --exclude-patterns "$EXCLUDE_PATTERNS" \
        --fail-on-violation false \
        --no-cache
}

# Function to generate summary
generate_summary() {
    echo -e "${BLUE}📊 PMD Analysis Summary${NC}"
    echo -e "${BLUE}========================${NC}"
    
    if [ -f "$REPORT_FILE" ]; then
        # Count violations by priority
        HIGH_VIOLATIONS=$(xpath 'count(//violation[@priority="1"])' "$REPORT_FILE" 2>/dev/null || echo "0")
        MEDIUM_VIOLATIONS=$(xpath 'count(//violation[@priority="2"])' "$REPORT_FILE" 2>/dev/null || echo "0")
        LOW_VIOLATIONS=$(xpath 'count(//violation[@priority="3"])' "$REPORT_FILE" 2>/dev/null || echo "0")
        TOTAL_VIOLATIONS=$((HIGH_VIOLATIONS + MEDIUM_VIOLATIONS + LOW_VIOLATIONS))
        
        echo -e "${RED}🔴 High Priority: $HIGH_VIOLATIONS${NC}"
        echo -e "${YELLOW}🟡 Medium Priority: $MEDIUM_VIOLATIONS${NC}"
        echo -e "${GREEN}🟢 Low Priority: $LOW_VIOLATIONS${NC}"
        echo -e "${BLUE}📈 Total Violations: $TOTAL_VIOLATIONS${NC}"
        
        # Calculate quality score
        if [ $TOTAL_VIOLATIONS -eq 0 ]; then
            QUALITY_SCORE="100"
            QUALITY_STATUS="Excellent"
        elif [ $TOTAL_VIOLATIONS -le 5 ]; then
            QUALITY_SCORE="85"
            QUALITY_STATUS="Good"
        elif [ $TOTAL_VIOLATIONS -le 10 ]; then
            QUALITY_SCORE="70"
            QUALITY_STATUS="Fair"
        elif [ $TOTAL_VIOLATIONS -le 20 ]; then
            QUALITY_SCORE="50"
            QUALITY_STATUS="Poor"
        else
            QUALITY_SCORE="25"
            QUALITY_STATUS="Very Poor"
        fi
        
        echo -e "${BLUE}📊 Quality Score: $QUALITY_SCORE/100 ($QUALITY_STATUS)${NC}"
        
        # Show top violations
        echo ""
        echo -e "${YELLOW}🔍 Top Violations:${NC}"
        xpath '//violation[1]' "$REPORT_FILE" 2>/dev/null | while read -r line; do
            FILE=$(echo "$line" | xpath 'string(//violation/@file)' 2>/dev/null)
            LINE=$(echo "$line" | xpath 'string(//violation/@beginline)' 2>/dev/null)
            RULE=$(echo "$line" | xpath 'string(//violation/@rule)' 2>/dev/null)
            PRIORITY=$(echo "$line" | xpath 'string(//violation/@priority)' 2>/dev/null)
            MESSAGE=$(echo "$line" | xpath 'string(//violation/@message)' 2>/dev/null)
            
            PRIORITY_COLOR=""
            if [ "$PRIORITY" = "1" ]; then
                PRIORITY_COLOR="${RED}"
            elif [ "$PRIORITY" = "2" ]; then
                PRIORITY_COLOR="${YELLOW}"
            else
                PRIORITY_COLOR="${GREEN}"
            fi
            
            echo -e "${PRIORITY_COLOR}  $FILE:$LINE - $RULE${NC}"
            echo -e "    $MESSAGE${NC}"
            echo ""
        done
        
        # Quality gate check
        echo ""
        echo -e "${BLUE}🚪 Quality Gate:${NC}"
        if [ $HIGH_VIOLATIONS -gt 0 ]; then
            echo -e "${RED}❌ FAILED: High priority violations detected${NC}"
            echo -e "${RED}   Please fix high priority violations before merging${NC}"
            return 1
        elif [ $TOTAL_VIOLATIONS -gt 20 ]; then
            echo -e "${YELLOW}⚠️  WARNING: Too many violations ($TOTAL_VIOLATIONS)${NC}"
            echo -e "${YELLOW}   Please reduce violations before merging${NC}"
            return 1
        else
            echo -e "${GREEN}✅ PASSED: Code quality is acceptable${NC}"
            return 0
        fi
    else
        echo -e "${RED}❌ No PMD report found${NC}"
        return 1
    fi
}

# Function to show detailed violations
show_detailed_violations() {
    local priority_filter=$1
    
    echo -e "${BLUE}📋 Detailed Violations (Priority $priority_filter and above):${NC}"
    echo -e "${BLUE}===============================================${NC}"
    
    if [ -f "$REPORT_FILE" ]; then
        xpath "//violation[@priority<=$priority_filter]" "$REPORT_FILE" 2>/dev/null | while read -r line; do
            FILE=$(echo "$line" | xpath 'string(//violation/@file)' 2>/dev/null)
            LINE=$(echo "$line" | xpath 'string(//violation/@beginline)' 2>/dev/null)
            RULE=$(echo "$line" | xpath 'string(//violation/@rule)' 2>/dev/null)
            PRIORITY=$(echo "$line" | xpath 'string(//violation/@priority)' 2>/dev/null)
            MESSAGE=$(echo "$line" | xpath 'string(//violation/@message)' 2>/dev/null)
            
            PRIORITY_COLOR=""
            if [ "$PRIORITY" = "1" ]; then
                PRIORITY_COLOR="${RED}"
            elif [ "$PRIORITY" = "2" ]; then
                PRIORITY_COLOR="${YELLOW}"
            else
                PRIORITY_COLOR="${GREEN}"
            fi
            
            echo -e "${PRIORITY_COLOR}📁 $FILE${NC}"
            echo -e "   Line: $LINE"
            echo -e "   Rule: $RULE"
            echo -e "   Priority: $PRIORITY"
            echo -e "   Message: $MESSAGE"
            echo ""
        done
    fi
}

# Function to generate HTML report
generate_html_report() {
    echo -e "${BLUE}📄 Generating HTML report...${NC}"
    
    cat > "$HTML_REPORT" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>FlowOps PMD Analysis Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f4f4f4; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .violation { margin-bottom: 15px; border-left: 4px solid #ddd; padding-left: 15px; }
        .high { border-left-color: #d32f2f; }
        .medium { border-left-color: #f39c12; }
        .low { border-left-color: #388e3c; }
        .file { font-weight: bold; color: #333; }
        .line { color: #666; }
        .rule { color: #666; font-family: monospace; }
        .message { color: #333; margin-top: 5px; }
        .priority { padding: 2px 8px; border-radius: 3px; color: white; font-size: 12px; }
        .high-priority { background: #d32f2f; }
        .medium-priority { background: #f39c12; }
        .low-priority { background: #388e3c; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 FlowOps PMD Analysis Report</h1>
        <p>Generated on $(date)</p>
    </div>
EOF

    # Add violations to HTML
    if [ -f "$REPORT_FILE" ]; then
        xpath '//violation' "$REPORT_FILE" 2>/dev/null | while read -r line; do
            FILE=$(echo "$line" | xpath 'string(//violation/@file)' 2>/dev/null)
            LINE=$(echo "$line" | xpath 'string(//violation/@beginline)' 2>/dev/null)
            RULE=$(echo "$line" | xpath 'string(//violation/@rule)' 2>/dev/null)
            PRIORITY=$(echo "$line" | xpath 'string(//violation/@priority)' 2>/dev/null)
            MESSAGE=$(echo "$line" | xpath 'string(//violation/@message)' 2>/dev/null)
            
            PRIORITY_CLASS=""
            PRIORITY_LABEL=""
            if [ "$PRIORITY" = "1" ]; then
                PRIORITY_CLASS="high"
                PRIORITY_LABEL="High"
            elif [ "$PRIORITY" = "2" ]; then
                PRIORITY_CLASS="medium"
                PRIORITY_LABEL="Medium"
            else
                PRIORITY_CLASS="low"
                PRIORITY_LABEL="Low"
            fi
            
            cat >> "$HTML_REPORT" << EOF
    <div class="violation $PRIORITY_CLASS">
        <div class="file">$FILE</div>
        <div class="line">Line: $LINE</div>
        <div class="rule">$RULE</div>
        <div class="priority $PRIORITY_CLASS-priority">$PRIORITY_LABEL</div>
        <div class="message">$MESSAGE</div>
    </div>
EOF
        done
    fi
    
    cat >> "$HTML_REPORT" << EOF
</body>
</html>
EOF
    
    echo -e "${GREEN}✅ HTML report generated: $HTML_REPORT${NC}"
}

# Main script logic
case "${1:-analyze}" in
    "analyze")
        run_pmd_analysis "xml" "xml"
        generate_summary
        ;;
    "detailed")
        show_detailed_violations "${2:-1}"
        ;;
    "html")
        run_pmd_analysis "xml" "xml"
        generate_html_report
        ;;
    "csv")
        run_pmd_analysis "csv" "csv"
        echo -e "${GREEN}✅ CSV report generated: $CSV_REPORT${NC}"
        ;;
    "all")
        echo -e "${BLUE}🔄 Running complete PMD analysis...${NC}"
        run_pmd_analysis "xml" "xml"
        generate_summary
        generate_html_report
        run_pmd_analysis "csv" "csv"
        ;;
    "help"|"--help"|"-h")
        echo "FlowOps PMD Analysis Script"
        echo ""
        echo "Usage: $0 [COMMAND] [OPTIONS]"
        echo ""
        echo "Commands:"
        echo "  analyze          Run PMD analysis and show summary"
        echo "  detailed [N]    Show detailed violations (priority N and above)"
        echo "  html            Generate HTML report"
        echo "  csv             Generate CSV report"
        echo "  all             Run all analysis types"
        echo "  help            Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 analyze          # Run analysis with summary"
        echo "  $0 detailed 1       # Show high and medium priority violations"
        echo "  $0 html             # Generate HTML report"
        echo "  $0 all              # Run complete analysis"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
