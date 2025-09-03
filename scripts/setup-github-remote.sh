#!/bin/bash

# GitHub Remote Setup Script for motos.cat
# Configures remote repository and handles authentication

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="https://github.com/coopeu/MotosCat.git"
GITHUB_SSH="git@github.com:coopeu/MotosCat.git"
GITHUB_USER="coopeu"
GITHUB_EMAIL="coopeu@coopeu.com"

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

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  GitHub Remote Setup - motos.cat${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Function to check if we're in the correct directory
check_project_directory() {
    if [ ! -f "Gemfile" ] || [ ! -f "config/application.rb" ]; then
        print_error "Not in a Rails project directory!"
        print_error "Please run this script from the motos.cat project root."
        exit 1
    fi
    
    if [ ! -d ".git" ]; then
        print_error "Not in a Git repository!"
        print_error "Please initialize Git first with: git init"
        exit 1
    fi
    
    print_success "Found Rails project with Git repository"
}

# Function to configure Git user
configure_git_user() {
    print_status "Configuring Git user information..."
    
    # Check if user is already configured
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        print_status "Git user already configured:"
        echo "  Name: $current_name"
        echo "  Email: $current_email"
        
        read -p "Use existing configuration? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            git config --global user.name "$GITHUB_USER"
            git config --global user.email "$GITHUB_EMAIL"
            print_success "Updated Git user configuration"
        fi
    else
        git config --global user.name "Ferran Cabrer i Vilagut"
        git config --global user.email "$GITHUB_EMAIL"
        print_success "Configured Git user information"
    fi
}

# Function to check and configure remote
configure_remote() {
    print_status "Configuring GitHub remote repository..."
    
    # Check if origin remote exists
    if git remote get-url origin >/dev/null 2>&1; then
        local current_remote=$(git remote get-url origin)
        print_status "Remote 'origin' already exists: $current_remote"
        
        if [ "$current_remote" != "$GITHUB_REPO" ] && [ "$current_remote" != "$GITHUB_SSH" ]; then
            print_warning "Remote URL doesn't match expected GitHub repository"
            read -p "Update remote URL to $GITHUB_REPO? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                git remote set-url origin "$GITHUB_REPO"
                print_success "Updated remote URL"
            fi
        else
            print_success "Remote URL is correctly configured"
        fi
    else
        git remote add origin "$GITHUB_REPO"
        print_success "Added GitHub remote repository"
    fi
    
    # Display remote configuration
    echo ""
    print_status "Current remote configuration:"
    git remote -v
}

# Function to check repository status
check_repository_status() {
    print_status "Checking repository status..."
    
    # Check if there are commits
    if ! git rev-parse HEAD >/dev/null 2>&1; then
        print_error "No commits found in repository!"
        print_error "Please create at least one commit before pushing to GitHub."
        exit 1
    fi
    
    # Show current branch and commits
    local current_branch=$(git branch --show-current)
    local commit_count=$(git rev-list --count HEAD)
    
    print_success "Repository status:"
    echo "  Current branch: $current_branch"
    echo "  Total commits: $commit_count"
    echo ""
    
    # Show recent commits
    print_status "Recent commits:"
    git log --oneline -5
    echo ""
}

# Function to check authentication
check_authentication() {
    print_status "Checking GitHub authentication..."
    
    # Test if we can access GitHub
    if git ls-remote origin >/dev/null 2>&1; then
        print_success "GitHub authentication is working"
        return 0
    else
        print_warning "GitHub authentication required"
        return 1
    fi
}

# Function to provide authentication instructions
show_authentication_instructions() {
    echo ""
    print_warning "GitHub Authentication Required"
    echo ""
    echo "To push to GitHub, you need to authenticate. Choose one of these methods:"
    echo ""
    echo "1. Personal Access Token (Recommended):"
    echo "   - Go to: https://github.com/settings/tokens"
    echo "   - Click 'Generate new token (classic)'"
    echo "   - Select scopes: repo, workflow"
    echo "   - Copy the token and use it as your password when prompted"
    echo ""
    echo "2. SSH Key (Advanced):"
    echo "   - Generate SSH key: ssh-keygen -t ed25519 -C '$GITHUB_EMAIL'"
    echo "   - Add to GitHub: https://github.com/settings/ssh/new"
    echo "   - Update remote: git remote set-url origin $GITHUB_SSH"
    echo ""
    echo "3. GitHub CLI (Alternative):"
    echo "   - Install: https://cli.github.com/"
    echo "   - Authenticate: gh auth login"
    echo ""
}

# Function to attempt push
attempt_push() {
    print_status "Attempting to push to GitHub..."
    
    local current_branch=$(git branch --show-current)
    
    echo ""
    print_status "This will push the following to GitHub:"
    echo "  Repository: $GITHUB_REPO"
    echo "  Branch: $current_branch"
    echo "  Commits: $(git rev-list --count HEAD)"
    echo ""
    
    read -p "Proceed with push? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_warning "Push cancelled by user"
        return 1
    fi
    
    # Attempt to push
    if git push -u origin "$current_branch"; then
        print_success "Successfully pushed to GitHub!"
        echo ""
        print_success "Repository is now available at:"
        echo "  https://github.com/coopeu/MotosCat"
        echo ""
        return 0
    else
        print_error "Push failed - authentication required"
        return 1
    fi
}

# Function to verify GitHub repository
verify_github_repository() {
    print_status "Verifying GitHub repository..."
    
    # Check if we can fetch from remote
    if git fetch origin >/dev/null 2>&1; then
        print_success "Successfully connected to GitHub repository"
        
        # Show remote branches
        echo ""
        print_status "Remote branches:"
        git branch -r
        
        # Show repository URL
        echo ""
        print_success "Repository accessible at:"
        echo "  https://github.com/coopeu/MotosCat"
        
        return 0
    else
        print_error "Cannot connect to GitHub repository"
        return 1
    fi
}

# Function to show final summary
show_summary() {
    echo ""
    print_success "GitHub Remote Setup Complete!"
    echo ""
    echo "Repository Details:"
    echo "  Local Path: $(pwd)"
    echo "  GitHub URL: https://github.com/coopeu/MotosCat"
    echo "  Remote URL: $(git remote get-url origin)"
    echo "  Current Branch: $(git branch --show-current)"
    echo "  Total Commits: $(git rev-list --count HEAD)"
    echo ""
    echo "Next Steps:"
    echo "  1. Visit: https://github.com/coopeu/MotosCat"
    echo "  2. Verify all files are uploaded correctly"
    echo "  3. Set up branch protection rules (optional)"
    echo "  4. Configure GitHub Actions for CI/CD (optional)"
    echo ""
    echo "Smart Git Commands:"
    echo "  ./scripts/git-smart-commit.sh status"
    echo "  ./scripts/git-smart-commit.sh push"
    echo "  ./scripts/git-smart-commit.sh full"
    echo ""
}

# Main execution
main() {
    print_header
    
    # Step 1: Verify environment
    check_project_directory
    
    # Step 2: Configure Git user
    configure_git_user
    
    # Step 3: Configure remote
    configure_remote
    
    # Step 4: Check repository status
    check_repository_status
    
    # Step 5: Check authentication
    if check_authentication; then
        # Step 6: Attempt push
        if attempt_push; then
            # Step 7: Verify repository
            verify_github_repository
            # Step 8: Show summary
            show_summary
        else
            show_authentication_instructions
        fi
    else
        show_authentication_instructions
        echo ""
        print_status "After setting up authentication, run:"
        echo "  git push -u origin main"
        echo "  # or use the smart Git script:"
        echo "  ./scripts/git-smart-commit.sh push"
    fi
}

# Execute main function
main "$@"
