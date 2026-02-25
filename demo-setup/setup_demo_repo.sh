#!/bin/bash
# ============================================================================
# DevConf Demo Repository Setup Script
# ============================================================================
# This script helps you set up a demo repository for DevConf presentation
# Usage: ./setup_demo_repo.sh <github-username> <repo-choice>
#
# Example: ./setup_demo_repo.sh tanwigeetika ansible-creator
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_step() {
    echo -e "\n${BLUE}==> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <github-username> <repo-choice>"
    echo ""
    echo "Repo choices:"
    echo "  ansible-creator  - Smaller codebase, recommended for demo"
    echo "  ansible-lint     - Larger codebase, may need scope limiting"
    echo ""
    echo "Example: $0 tanwigeetika ansible-creator"
    exit 1
fi

GITHUB_USER="$1"
REPO_CHOICE="$2"

# Set repo-specific variables
case "$REPO_CHOICE" in
    "ansible-creator")
        UPSTREAM_REPO="ansible/ansible-creator"
        REPO_NAME="ansible-creator"
        CODEBASE_FOCUS="src/ansible_creator/"
        ;;
    "ansible-lint")
        UPSTREAM_REPO="ansible/ansible-lint"
        REPO_NAME="ansible-lint"
        CODEBASE_FOCUS="src/ansiblelint/"
        ;;
    *)
        print_error "Unknown repo choice: $REPO_CHOICE"
        echo "Use 'ansible-creator' or 'ansible-lint'"
        exit 1
        ;;
esac

FORK_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}"
DEMO_DIR="${HOME}/devconf-demo/${REPO_NAME}"

echo ""
echo "=============================================="
echo "  DevConf Demo Setup"
echo "=============================================="
echo "  GitHub User:    $GITHUB_USER"
echo "  Repository:     $REPO_NAME"
echo "  Fork URL:       $FORK_URL"
echo "  Demo Directory: $DEMO_DIR"
echo "=============================================="
echo ""

# Step 1: Fork reminder
print_step "Step 1: Forking the Repository"
echo ""
echo "Please make sure you have forked the repository:"
echo "  1. Go to: https://github.com/${UPSTREAM_REPO}"
echo "  2. Click 'Fork' button"
echo "  3. Fork to your account: ${GITHUB_USER}"
echo ""
read -p "Have you forked the repository? (y/n): " forked

if [ "$forked" != "y" ] && [ "$forked" != "Y" ]; then
    print_warning "Please fork the repository first, then run this script again."
    exit 1
fi
print_success "Repository forked"

# Step 2: Clone the fork
print_step "Step 2: Cloning Your Fork"
mkdir -p "${HOME}/devconf-demo"
if [ -d "$DEMO_DIR" ]; then
    print_warning "Directory already exists: $DEMO_DIR"
    read -p "Remove and re-clone? (y/n): " reclone
    if [ "$reclone" == "y" ] || [ "$reclone" == "Y" ]; then
        rm -rf "$DEMO_DIR"
    else
        cd "$DEMO_DIR"
        print_success "Using existing directory"
    fi
fi

if [ ! -d "$DEMO_DIR" ]; then
    git clone "$FORK_URL" "$DEMO_DIR"
    print_success "Repository cloned"
fi

cd "$DEMO_DIR"

# Step 3: Create workflows directory
print_step "Step 3: Creating GitHub Workflows Directory"
mkdir -p .github/workflows
print_success "Workflows directory created"

# Step 4: Create the workflow file
print_step "Step 4: Creating Workflow File"
cat > .github/workflows/gemini-labeled-issue-analysis.yml << 'WORKFLOW_EOF'
# AI Issue Triage - Label-Based Single Issue Analysis
# Triggers when an issue is labeled with "Gemini Analyze"
# For DevConf Demo

name: AI Labeled Issue Analysis

on:
  issues:
    types: [labeled, opened]

jobs:
  analyze-issue:
    if: contains(github.event.issue.labels.*.name, 'Gemini Analyze')
    runs-on: ubuntu-latest
    permissions:
      issues: write
      contents: read
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        
      - name: Clone AI-Issue-Triage repository
        uses: actions/checkout@v4
        with:
          repository: tanwigeetika1618/AI-Issue-Triage
          path: ai-triage
          
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          
      - name: Install repomix
        run: npm install -g repomix
        
      - name: Read triage config
        id: config
        run: |
          if [ -f "triage.config.json" ]; then
            REPO_URL=$(jq -r '.repository.url // empty' triage.config.json)
            REPOMIX_OUTPUT=$(jq -r '.repomix.output_path // "repomix-output.txt"' triage.config.json)
            CUSTOM_PROMPT=$(jq -r '.analysis.custom_prompt_path // empty' triage.config.json)
            GEMINI_MODEL=$(jq -r '.gemini.model // empty' triage.config.json)
            
            echo "repo_url=$REPO_URL" >> $GITHUB_OUTPUT
            echo "repomix_output=$REPOMIX_OUTPUT" >> $GITHUB_OUTPUT
            echo "custom_prompt=$CUSTOM_PROMPT" >> $GITHUB_OUTPUT
            echo "gemini_model=$GEMINI_MODEL" >> $GITHUB_OUTPUT
          else
            echo "repomix_output=repomix-output.txt" >> $GITHUB_OUTPUT
          fi
          
      - name: Generate codebase file with repomix
        run: |
          REPO_URL="${{ steps.config.outputs.repo_url }}"
          OUTPUT_PATH="${{ steps.config.outputs.repomix_output }}"
          
          if [ -n "$REPO_URL" ]; then
            repomix --remote "$REPO_URL" --output "$OUTPUT_PATH"
          else
            repomix --output "$OUTPUT_PATH"
          fi
          
      - name: Install Python dependencies
        run: |
          cd ai-triage
          pip install -r requirements.txt
          pip install -e .
          
      - name: Check for prompt injection
        id: security_check
        continue-on-error: true
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          cd ai-triage
          
          TITLE="${{ github.event.issue.title }}"
          BODY="${{ github.event.issue.body }}"
          
          # Run prompt injection check
          python -m utils.security.prompt_injection "$TITLE" "$BODY" > ../prompt_injection_result.json 2> ../prompt_injection_debug.log || true
          
          # Parse results
          if [ -f "../prompt_injection_result.json" ]; then
            HAS_INJECTION=$(jq -r '.has_prompt_injection // false' ../prompt_injection_result.json)
            RISK_LEVEL=$(jq -r '.risk_level // "safe"' ../prompt_injection_result.json)
            
            echo "has_injection=$HAS_INJECTION" >> $GITHUB_OUTPUT
            echo "risk_level=$RISK_LEVEL" >> $GITHUB_OUTPUT
          else
            echo "has_injection=false" >> $GITHUB_OUTPUT
            echo "risk_level=safe" >> $GITHUB_OUTPUT
          fi
          
      - name: Check if bypass label exists
        id: bypass_check
        run: |
          LABELS='${{ toJson(github.event.issue.labels.*.name) }}'
          if echo "$LABELS" | grep -q "Gemini Analyze : Bypass Prompt Injection Check"; then
            echo "bypass=true" >> $GITHUB_OUTPUT
          else
            echo "bypass=false" >> $GITHUB_OUTPUT
          fi
          
      - name: Post security warning if needed
        if: steps.security_check.outputs.has_injection == 'true' && steps.bypass_check.outputs.bypass != 'true'
        uses: actions/github-script@v7
        with:
          script: |
            const riskLevel = '${{ steps.security_check.outputs.risk_level }}';
            const isHighRisk = riskLevel === 'high' || riskLevel === 'critical';
            
            let emoji = '🟢';
            if (riskLevel === 'critical') emoji = '🔴';
            else if (riskLevel === 'high') emoji = '🟠';
            else if (riskLevel === 'medium') emoji = '🟡';
            
            const comment = `## 🛡️ Security Check Result

${emoji} **Risk Level:** \`${riskLevel.toUpperCase()}\`

${isHighRisk ? '⚠️ **Analysis blocked due to potential prompt injection.**\n\nIf this is a false positive, a maintainer can add the \`Gemini Analyze : Bypass Prompt Injection Check\` label.' : '⚠️ **Warning:** Potential prompt injection patterns detected, but proceeding with analysis.'}

---
<sub>🤖 Automated security check by AI Issue Triage</sub>`;

            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: comment
            });
            
            // Add security label
            const labelName = isHighRisk ? 'Prompt injection blocked' : 'Prompt injection warning';
            const labelColor = isHighRisk ? 'd73a4a' : 'fbca04';
            
            try {
              await github.rest.issues.createLabel({
                owner: context.repo.owner,
                repo: context.repo.repo,
                name: labelName,
                color: labelColor,
                description: 'AI-generated: Security concern detected'
              });
            } catch (e) {}
            
            await github.rest.issues.addLabels({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              labels: [labelName]
            });
            
      - name: Skip analysis if high risk
        if: (steps.security_check.outputs.risk_level == 'high' || steps.security_check.outputs.risk_level == 'critical') && steps.bypass_check.outputs.bypass != 'true'
        run: |
          echo "Skipping analysis due to high security risk"
          exit 0
          
      - name: Fetch existing issues for duplicate check
        id: fetch_issues
        uses: actions/github-script@v7
        with:
          script: |
            const issues = await github.rest.issues.listForRepo({
              owner: context.repo.owner,
              repo: context.repo.repo,
              state: 'open',
              per_page: 100
            });
            
            const existingIssues = issues.data
              .filter(issue => issue.number !== context.issue.number)
              .map(issue => ({
                issue_id: String(issue.number),
                title: issue.title,
                description: issue.body || '',
                status: 'open',
                created_date: issue.created_at,
                url: issue.html_url
              }));
            
            require('fs').writeFileSync('existing_issues.json', JSON.stringify(existingIssues, null, 2));
            return existingIssues.length;
            
      - name: Check for duplicates
        id: duplicate_check
        if: (steps.security_check.outputs.risk_level != 'high' && steps.security_check.outputs.risk_level != 'critical') || steps.bypass_check.outputs.bypass == 'true'
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          cd ai-triage
          
          MODEL_ARG=""
          if [ -n "${{ steps.config.outputs.gemini_model }}" ]; then
            MODEL_ARG="--model ${{ steps.config.outputs.gemini_model }}"
          fi
          
          python -m cli.duplicate_check \
            --title "${{ github.event.issue.title }}" \
            --description "${{ github.event.issue.body }}" \
            --issues ../existing_issues.json \
            $MODEL_ARG \
            --format json > ../duplicate_result.json 2>&1 || true
          
          if [ -f "../duplicate_result.json" ]; then
            IS_DUPLICATE=$(jq -r '.is_duplicate // false' ../duplicate_result.json)
            echo "is_duplicate=$IS_DUPLICATE" >> $GITHUB_OUTPUT
          else
            echo "is_duplicate=false" >> $GITHUB_OUTPUT
          fi
          
      - name: Post duplicate result if found
        if: steps.duplicate_check.outputs.is_duplicate == 'true'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const result = JSON.parse(fs.readFileSync('duplicate_result.json', 'utf8'));
            
            const similarity = Math.round((result.similarity_score || 0) * 100);
            const confidence = Math.round((result.confidence_score || 0) * 100);
            const originalIssue = result.duplicate_of;
            
            let comment = `## 🔍 Duplicate Detection Report

🔄 **Status:** DUPLICATE DETECTED

### 📊 Similarity Metrics
| Metric | Score |
|--------|-------|
| Similarity | ${similarity}% |
| Confidence | ${confidence}% |

### 🎯 Original Issue
${originalIssue ? `[#${originalIssue.issue_id}](${originalIssue.url}) - ${originalIssue.title}` : 'Unknown'}

### 💡 Recommendation
${result.recommendation || 'Consider closing this as duplicate.'}

---
<sub>🤖 Duplicate detection by AI Issue Triage</sub>`;

            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: comment
            });
            
            // Add duplicate label
            try {
              await github.rest.issues.createLabel({
                owner: context.repo.owner,
                repo: context.repo.repo,
                name: 'Duplicate',
                color: 'cfd3d7',
                description: 'AI-generated: This issue appears to be a duplicate'
              });
            } catch (e) {}
            
            await github.rest.issues.addLabels({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              labels: ['Duplicate']
            });
            
      - name: Run AI analysis
        if: steps.duplicate_check.outputs.is_duplicate != 'true' && ((steps.security_check.outputs.risk_level != 'high' && steps.security_check.outputs.risk_level != 'critical') || steps.bypass_check.outputs.bypass == 'true')
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          cd ai-triage
          
          CUSTOM_PROMPT_ARG=""
          if [ -n "${{ steps.config.outputs.custom_prompt }}" ] && [ -f "../${{ steps.config.outputs.custom_prompt }}" ]; then
            CUSTOM_PROMPT_ARG="--custom-prompt ../${{ steps.config.outputs.custom_prompt }}"
          fi
          
          MODEL_ARG=""
          if [ -n "${{ steps.config.outputs.gemini_model }}" ]; then
            MODEL_ARG="--model ${{ steps.config.outputs.gemini_model }}"
          fi
          
          python -m cli.analyze \
            --title "${{ github.event.issue.title }}" \
            --description "${{ github.event.issue.body }}" \
            --source-path "../${{ steps.config.outputs.repomix_output }}" \
            $CUSTOM_PROMPT_ARG \
            $MODEL_ARG \
            --format json \
            --output ../analysis_result.json
          
          python -m cli.analyze \
            --title "${{ github.event.issue.title }}" \
            --description "${{ github.event.issue.body }}" \
            --source-path "../${{ steps.config.outputs.repomix_output }}" \
            $CUSTOM_PROMPT_ARG \
            $MODEL_ARG \
            --format text \
            --output ../analysis_result.txt
            
      - name: Post analysis comment
        if: steps.duplicate_check.outputs.is_duplicate != 'true' && ((steps.security_check.outputs.risk_level != 'high' && steps.security_check.outputs.risk_level != 'critical') || steps.bypass_check.outputs.bypass == 'true')
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const analysisText = fs.readFileSync('analysis_result.txt', 'utf8');
            
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: analysisText
            });
            
      - name: Add labels based on analysis
        if: steps.duplicate_check.outputs.is_duplicate != 'true' && ((steps.security_check.outputs.risk_level != 'high' && steps.security_check.outputs.risk_level != 'critical') || steps.bypass_check.outputs.bypass == 'true')
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const analysis = JSON.parse(fs.readFileSync('analysis_result.json', 'utf8'));
            
            const typeLabels = {
              'bug': { name: 'Type : Bug', color: 'd73a4a' },
              'enhancement': { name: 'Type : Enhancement', color: 'a2eeef' },
              'feature_request': { name: 'Type : Feature request', color: '0e8a16' }
            };
            
            const severityLabels = {
              'critical': { name: 'Severity : Critical', color: 'b60205' },
              'high': { name: 'Severity : High', color: 'd93f0b' },
              'medium': { name: 'Severity : Medium', color: 'fbca04' },
              'low': { name: 'Severity : Low', color: '0e8a16' }
            };
            
            const labelsToAdd = [];
            
            if (analysis.issue_type && typeLabels[analysis.issue_type]) {
              const label = typeLabels[analysis.issue_type];
              try {
                await github.rest.issues.createLabel({
                  owner: context.repo.owner,
                  repo: context.repo.repo,
                  name: label.name,
                  color: label.color,
                  description: 'AI-generated: Issue type'
                });
              } catch (e) {}
              labelsToAdd.push(label.name);
            }
            
            if (analysis.severity && severityLabels[analysis.severity]) {
              const label = severityLabels[analysis.severity];
              try {
                await github.rest.issues.createLabel({
                  owner: context.repo.owner,
                  repo: context.repo.repo,
                  name: label.name,
                  color: label.color,
                  description: 'AI-generated: Severity level'
                });
              } catch (e) {}
              labelsToAdd.push(label.name);
            }
            
            if (labelsToAdd.length > 0) {
              await github.rest.issues.addLabels({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                labels: labelsToAdd
              });
            }
            
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: analysis-artifacts-${{ github.event.issue.number }}
          path: |
            analysis_result.json
            analysis_result.txt
            prompt_injection_result.json
            prompt_injection_debug.log
            duplicate_result.json
            existing_issues.json
            ${{ steps.config.outputs.repomix_output }}
          retention-days: 30
WORKFLOW_EOF
print_success "Workflow file created"

# Step 5: Create triage.config.json
print_step "Step 5: Creating Configuration File"
cat > triage.config.json << EOF
{
  "repository": {
    "url": "https://github.com/${GITHUB_USER}/${REPO_NAME}",
    "description": "AI-powered issue triage demo for DevConf Pune 2026"
  },
  "repomix": {
    "output_path": "repomix-output.txt"
  },
  "analysis": {
    "custom_prompt_path": "prompt.txt"
  },
  "gemini": {
    "model": "gemini-2.0-flash-001"
  }
}
EOF
print_success "Configuration file created"

# Step 6: Create custom prompt
print_step "Step 6: Creating Custom Prompt"
if [ "$REPO_CHOICE" == "ansible-creator" ]; then
cat > prompt.txt << 'PROMPT_EOF'
You are an expert software engineer analyzing a code issue for Ansible Creator - a CLI tool that helps scaffold Ansible content (collections, roles, playbooks).

ISSUE DETAILS:
Title: {title}
Description: {issue_description}

CODEBASE CONTENT:
{codebase_content}

ANALYSIS REQUIREMENTS:
1. **Issue Classification**: Determine if this is a 'bug', 'enhancement', or 'feature_request'
2. **Severity Assessment**: Rate as 'low', 'medium', 'high', or 'critical'
3. **Root Cause Analysis**: Identify the primary cause and contributing factors
4. **Code Location Identification**: Find relevant files, functions, and classes in src/ansible_creator/
5. **Solution Proposal**: Suggest specific code changes with rationale

RESPONSE FORMAT (JSON):
{{
    "issue_type": "bug|enhancement|feature_request",
    "severity": "low|medium|high|critical",
    "root_cause_analysis": {{
        "primary_cause": "Main reason for the issue",
        "contributing_factors": ["factor1", "factor2"],
        "affected_components": ["component1", "component2"],
        "related_code_locations": [
            {{
                "file_path": "path/to/file.py",
                "line_number": 123,
                "function_name": "function_name",
                "class_name": "ClassName"
            }}
        ]
    }},
    "proposed_solutions": [
        {{
            "description": "Solution description",
            "code_changes": "Specific code changes needed",
            "location": {{
                "file_path": "path/to/file.py",
                "line_number": 123,
                "function_name": "function_name",
                "class_name": "ClassName"
            }},
            "rationale": "Why this solution works"
        }}
    ],
    "confidence_score": 0.85,
    "analysis_summary": "Brief summary of the analysis"
}}

ANALYSIS GUIDELINES:
- Focus on the Ansible Creator codebase structure (src/ansible_creator/)
- Key modules: cli.py (CLI handling), config.py (configuration), utils.py (utilities)
- Consider Python CLI patterns and argparse usage
- Look for Jinja2 template handling in the templates/ directory
- Provide actionable, specific solutions with real file paths from the codebase
- If you cannot find the exact file, say so rather than hallucinating

Please analyze the issue and provide your response in the exact JSON format specified above.
PROMPT_EOF
else
cat > prompt.txt << 'PROMPT_EOF'
You are an expert software engineer analyzing a code issue for Ansible Lint - a linting tool for Ansible playbooks, roles, and collections.

ISSUE DETAILS:
Title: {title}
Description: {issue_description}

CODEBASE CONTENT:
{codebase_content}

ANALYSIS REQUIREMENTS:
1. **Issue Classification**: Determine if this is a 'bug', 'enhancement', or 'feature_request'
2. **Severity Assessment**: Rate as 'low', 'medium', 'high', or 'critical'
3. **Root Cause Analysis**: Identify the primary cause and contributing factors
4. **Code Location Identification**: Find relevant files, functions, and classes in src/ansiblelint/
5. **Solution Proposal**: Suggest specific code changes with rationale

RESPONSE FORMAT (JSON):
{{
    "issue_type": "bug|enhancement|feature_request",
    "severity": "low|medium|high|critical",
    "root_cause_analysis": {{
        "primary_cause": "Main reason for the issue",
        "contributing_factors": ["factor1", "factor2"],
        "affected_components": ["component1", "component2"],
        "related_code_locations": [
            {{
                "file_path": "path/to/file.py",
                "line_number": 123,
                "function_name": "function_name",
                "class_name": "ClassName"
            }}
        ]
    }},
    "proposed_solutions": [
        {{
            "description": "Solution description",
            "code_changes": "Specific code changes needed",
            "location": {{
                "file_path": "path/to/file.py",
                "line_number": 123,
                "function_name": "function_name",
                "class_name": "ClassName"
            }},
            "rationale": "Why this solution works"
        }}
    ],
    "confidence_score": 0.85,
    "analysis_summary": "Brief summary of the analysis"
}}

ANALYSIS GUIDELINES:
- Focus on the Ansible Lint codebase structure (src/ansiblelint/)
- Key modules: rules/ (lint rules), runner.py (execution), config.py (configuration)
- Consider Python linting patterns and rule implementations
- Look at how existing rules are structured for consistency
- Provide actionable, specific solutions with real file paths from the codebase
- If you cannot find the exact file, say so rather than hallucinating

Please analyze the issue and provide your response in the exact JSON format specified above.
PROMPT_EOF
fi
print_success "Custom prompt created"

# Step 7: Summary
print_step "Step 7: Setup Complete!"
echo ""
echo "=============================================="
echo "  NEXT STEPS"
echo "=============================================="
echo ""
echo "1. Add your Gemini API key to GitHub:"
echo "   - Go to: ${FORK_URL}/settings/secrets/actions"
echo "   - Click 'New repository secret'"
echo "   - Name: GEMINI_API_KEY"
echo "   - Value: <your-gemini-api-key>"
echo ""
echo "2. Create the 'Gemini Analyze' label:"
echo "   - Go to: ${FORK_URL}/labels"
echo "   - Create: 'Gemini Analyze' (green: #0E8A16)"
echo ""
echo "3. Commit and push the changes:"
echo "   cd $DEMO_DIR"
echo "   git add ."
echo "   git commit -m 'Add AI issue triage for DevConf demo'"
echo "   git push origin main"
echo ""
echo "4. Test by creating an issue:"
echo "   - Go to: ${FORK_URL}/issues/new"
echo "   - Create a test issue"
echo "   - Add the 'Gemini Analyze' label"
echo "   - Watch the magic happen!"
echo ""
echo "=============================================="
echo ""
print_success "Setup script completed!"
echo ""
echo "Demo directory: $DEMO_DIR"
echo ""

