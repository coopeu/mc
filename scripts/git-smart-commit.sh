#!/bin/bash

# Git Smart Commit Script for motos.cat
# Provides intelligent commit messages and branch management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MAIN_BRANCH="main"
DEVELOP_BRANCH="develop"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to analyze changes and generate intelligent commit message
generate_commit_message() {
    local changes_summary=""
    local commit_type=""
    local scope=""
    local description=""
    
    # Analyze staged changes
    local added_files=$(git diff --cached --name-only --diff-filter=A | wc -l)
    local modified_files=$(git diff --cached --name-only --diff-filter=M | wc -l)
    local deleted_files=$(git diff --cached --name-only --diff-filter=D | wc -l)
    local renamed_files=$(git diff --cached --name-only --diff-filter=R | wc -l)
    
    # Get list of changed files
    local changed_files=$(git diff --cached --name-only)
    
    # Determine commit type and scope based on changed files
    if echo "$changed_files" | grep -q "test/"; then
        if echo "$changed_files" | grep -q "stripe\|payment\|webhook"; then
            commit_type="test"
            scope="payments"
            description="Add comprehensive Stripe payment flow tests"
        elif echo "$changed_files" | grep -q "file.*valid\|upload"; then
            commit_type="test"
            scope="security"
            description="Add file upload validation tests"
        else
            commit_type="test"
            scope="core"
            description="Add comprehensive test suite"
        fi
    elif echo "$changed_files" | grep -q "app/models/concerns/file_validatable.rb"; then
        commit_type="feat"
        scope="security"
        description="Add comprehensive file upload validation system"
    elif echo "$changed_files" | grep -q "stripe\|payment\|webhook"; then
        commit_type="feat"
        scope="payments"
        description="Implement Stripe payment integration"
    elif echo "$changed_files" | grep -q "rubocop\|\.rubocop\.yml"; then
        commit_type="style"
        scope="quality"
        description="Configure RuboCop and fix code style issues"
    elif echo "$changed_files" | grep -q "Gemfile\|package\.json"; then
        commit_type="build"
        scope="deps"
        description="Update project dependencies"
    elif echo "$changed_files" | grep -q "config/"; then
        commit_type="config"
        scope="setup"
        description="Update application configuration"
    elif echo "$changed_files" | grep -q "db/migrate\|db/schema"; then
        commit_type="feat"
        scope="database"
        description="Update database schema"
    elif echo "$changed_files" | grep -q "app/controllers/"; then
        commit_type="feat"
        scope="api"
        description="Update controller logic"
    elif echo "$changed_files" | grep -q "app/models/"; then
        commit_type="feat"
        scope="models"
        description="Update data models"
    elif echo "$changed_files" | grep -q "app/views/"; then
        commit_type="feat"
        scope="ui"
        description="Update user interface"
    elif echo "$changed_files" | grep -q "README\|\.md$"; then
        commit_type="docs"
        scope="readme"
        description="Update documentation"
    else
        commit_type="chore"
        scope="misc"
        description="General maintenance and updates"
    fi
    
    # Create detailed description based on file analysis
    local detailed_description=""
    
    if [ $added_files -gt 0 ]; then
        detailed_description="${detailed_description}Add $added_files new files. "
    fi
    
    if [ $modified_files -gt 0 ]; then
        detailed_description="${detailed_description}Modify $modified_files existing files. "
    fi
    
    if [ $deleted_files -gt 0 ]; then
        detailed_description="${detailed_description}Remove $deleted_files files. "
    fi
    
    # Generate conventional commit message
    local commit_message="${commit_type}(${scope}): ${description}"
    
    if [ -n "$detailed_description" ]; then
        commit_message="${commit_message}

${detailed_description}

Files changed:
$(echo "$changed_files" | head -10 | sed 's/^/- /')
$([ $(echo "$changed_files" | wc -l) -gt 10 ] && echo "... and $(($(echo "$changed_files" | wc -l) - 10)) more files")"
    fi
    
    echo "$commit_message"
}

# Function to suggest branch name based on changes
suggest_branch_name() {
    local changed_files=$(git diff --name-only)
    local branch_prefix=""
    local branch_suffix=""
    
    if echo "$changed_files" | grep -q "test/"; then
        branch_prefix="test"
        if echo "$changed_files" | grep -q "stripe\|payment"; then
            branch_suffix="stripe-payment-tests"
        else
            branch_suffix="comprehensive-tests"
        fi
    elif echo "$changed_files" | grep -q "file_validatable\|upload.*valid"; then
        branch_prefix="feature"
        branch_suffix="file-upload-security"
    elif echo "$changed_files" | grep -q "stripe\|payment"; then
        branch_prefix="feature"
        branch_suffix="stripe-integration"
    elif echo "$changed_files" | grep -q "rubocop"; then
        branch_prefix="chore"
        branch_suffix="code-quality"
    else
        branch_prefix="feature"
        branch_suffix="general-improvements"
    fi
    
    echo "${branch_prefix}/${branch_suffix}"
}

# Function to check repository status
check_repo_status() {
    print_status "Checking repository status..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a Git repository"
        exit 1
    fi
    
    # Check if there are any commits
    if ! git rev-parse HEAD > /dev/null 2>&1; then
        print_warning "No commits found. This appears to be a fresh repository."
        return 1
    fi
    
    return 0
}

# Function to initialize repository if needed
init_repository() {
    print_status "Initializing repository structure..."
    
    # Create main branch if it doesn't exist
    if ! git show-ref --verify --quiet refs/heads/$MAIN_BRANCH; then
        print_status "Creating $MAIN_BRANCH branch..."
        git checkout -b $MAIN_BRANCH
    fi
    
    # Set up .gitignore if it doesn't exist
    if [ ! -f .gitignore ]; then
        print_status "Creating .gitignore..."
        cat > .gitignore << 'EOF'
# Dependencies
/node_modules
/vendor/bundle

# Production
/dist
/build
/public/assets

# Environment variables
.env
.env.local
.env.production

# Logs
/log/*
!/log/.keep
/tmp/*
!/tmp/.keep

# Storage
/storage/*
!/storage/.keep

# Coverage
/coverage

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF
    fi
}

# Function to stage files intelligently
smart_add() {
    print_status "Analyzing files to stage..."
    
    # Get untracked and modified files
    local untracked_files=$(git ls-files --others --exclude-standard)
    local modified_files=$(git diff --name-only)
    
    # Stage important files first
    local important_patterns=(
        "app/"
        "config/"
        "db/"
        "test/"
        "lib/"
        "Gemfile"
        "package.json"
        "README.md"
        ".rubocop.yml"
    )
    
    for pattern in "${important_patterns[@]}"; do
        if echo "$untracked_files $modified_files" | grep -q "$pattern"; then
            git add "$pattern" 2>/dev/null || true
            print_status "Staged files matching: $pattern"
        fi
    done
    
    # Ask about remaining files
    local remaining_files=$(git ls-files --others --exclude-standard)
    if [ -n "$remaining_files" ]; then
        print_warning "Remaining untracked files:"
        echo "$remaining_files" | head -10
        
        read -p "Stage all remaining files? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            print_success "Staged all files"
        fi
    fi
}

# Function to create intelligent commit
smart_commit() {
    local custom_message="$1"
    
    # Check if there are staged changes
    if git diff --cached --quiet; then
        print_warning "No staged changes found. Staging files..."
        smart_add
    fi
    
    # Check again after staging
    if git diff --cached --quiet; then
        print_error "No changes to commit"
        exit 1
    fi
    
    # Generate or use custom commit message
    local commit_message
    if [ -n "$custom_message" ]; then
        commit_message="$custom_message"
    else
        print_status "Generating intelligent commit message..."
        commit_message=$(generate_commit_message)
    fi
    
    # Show commit message preview
    print_status "Commit message preview:"
    echo "----------------------------------------"
    echo "$commit_message"
    echo "----------------------------------------"
    
    # Ask for confirmation
    read -p "Proceed with this commit? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_warning "Commit cancelled"
        exit 0
    fi
    
    # Create commit
    git commit -m "$commit_message"
    print_success "Commit created successfully"
}

# Function to manage branches
branch_management() {
    local operation="$1"
    local branch_name="$2"
    
    case "$operation" in
        "create")
            if [ -z "$branch_name" ]; then
                branch_name=$(suggest_branch_name)
                print_status "Suggested branch name: $branch_name"
                read -p "Use this branch name? (Y/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Nn]$ ]]; then
                    read -p "Enter branch name: " branch_name
                fi
            fi
            
            git checkout -b "$branch_name"
            print_success "Created and switched to branch: $branch_name"
            ;;
        "list")
            print_status "Available branches:"
            git branch -a
            ;;
        "switch")
            if [ -z "$branch_name" ]; then
                print_error "Branch name required"
                exit 1
            fi
            git checkout "$branch_name"
            print_success "Switched to branch: $branch_name"
            ;;
        *)
            print_error "Unknown branch operation: $operation"
            exit 1
            ;;
    esac
}

# Main function
main() {
    local operation="$1"
    shift
    
    case "$operation" in
        "status")
            git status
            ;;
        "add")
            smart_add
            ;;
        "commit")
            smart_commit "$*"
            ;;
        "push")
            local current_branch=$(git branch --show-current)
            git push -u origin "$current_branch"
            print_success "Pushed to origin/$current_branch"
            ;;
        "init")
            init_repository
            ;;
        "branch")
            branch_management "$@"
            ;;
        "full")
            # Full workflow: add, commit, push
            if ! check_repo_status; then
                init_repository
            fi
            smart_add
            smart_commit "$*"
            
            read -p "Push to remote? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                local current_branch=$(git branch --show-current 2>/dev/null || echo "$MAIN_BRANCH")
                git push -u origin "$current_branch" 2>/dev/null || print_warning "Remote push failed (remote may not be configured)"
            fi
            ;;
        *)
            echo "Usage: $0 {status|add|commit|push|init|branch|full} [args]"
            echo ""
            echo "Operations:"
            echo "  status              - Show git status"
            echo "  add                 - Smart file staging"
            echo "  commit [message]    - Intelligent commit with optional custom message"
            echo "  push                - Push current branch to origin"
            echo "  init                - Initialize repository structure"
            echo "  branch create|list|switch [name] - Branch management"
            echo "  full [message]      - Complete workflow: add, commit, push"
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
