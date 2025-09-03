# Git Workflow Guide for motos.cat

## Overview

This document outlines the intelligent Git workflow system implemented for the motos.cat project, featuring automated commit message generation, branch management, and development best practices.

## Smart Git Script

The project includes a comprehensive Git automation script at `scripts/git-smart-commit.sh` that provides:

### 🤖 Intelligent Commit Messages

The script analyzes changed files and generates conventional commit messages automatically:

```bash
# Automatic commit message generation
./scripts/git-smart-commit.sh commit

# Custom commit message
./scripts/git-smart-commit.sh commit "feat(payments): Add Stripe webhook handling"
```

#### Commit Types Generated

| File Pattern | Commit Type | Scope | Description |
|--------------|-------------|-------|-------------|
| `test/` | `test` | `payments/security/core` | Test suite additions |
| `app/models/concerns/file_validatable.rb` | `feat` | `security` | File validation system |
| `stripe/payment/webhook` | `feat` | `payments` | Payment integration |
| `.rubocop.yml` | `style` | `quality` | Code quality improvements |
| `Gemfile/package.json` | `build` | `deps` | Dependency updates |
| `config/` | `config` | `setup` | Configuration changes |
| `db/migrate` | `feat` | `database` | Database schema updates |
| `app/controllers/` | `feat` | `api` | Controller logic |
| `app/models/` | `feat` | `models` | Data model updates |
| `app/views/` | `feat` | `ui` | User interface changes |
| `README.md` | `docs` | `readme` | Documentation updates |

### 🌿 Branch Management

#### Branch Naming Conventions

The script suggests intelligent branch names based on changes:

```bash
# Create feature branch with suggested name
./scripts/git-smart-commit.sh branch create

# Examples of generated branch names:
# feature/stripe-integration
# test/comprehensive-tests
# feature/file-upload-security
# chore/code-quality
```

#### Branch Types

- **`feature/`** - New features and enhancements
- **`test/`** - Test suite additions and improvements
- **`chore/`** - Maintenance and code quality improvements
- **`fix/`** - Bug fixes
- **`docs/`** - Documentation updates

### 🔄 Complete Workflow Commands

#### Basic Operations

```bash
# Check repository status
./scripts/git-smart-commit.sh status

# Smart file staging (prioritizes important files)
./scripts/git-smart-commit.sh add

# Intelligent commit
./scripts/git-smart-commit.sh commit

# Push current branch
./scripts/git-smart-commit.sh push

# Initialize repository structure
./scripts/git-smart-commit.sh init
```

#### Branch Operations

```bash
# Create new branch with intelligent naming
./scripts/git-smart-commit.sh branch create

# List all branches
./scripts/git-smart-commit.sh branch list

# Switch to existing branch
./scripts/git-smart-commit.sh branch switch <branch-name>
```

#### Complete Workflow

```bash
# Full workflow: add, commit, and push
./scripts/git-smart-commit.sh full

# With custom commit message
./scripts/git-smart-commit.sh full "feat(ui): Improve user registration form"
```

## Repository Structure

### Main Branches

- **`main`** - Production-ready code
- **`develop`** - Integration branch for features (if using GitFlow)

### Feature Development Workflow

1. **Create Feature Branch**
   ```bash
   ./scripts/git-smart-commit.sh branch create
   ```

2. **Make Changes and Commit**
   ```bash
   # Make your changes
   ./scripts/git-smart-commit.sh commit
   ```

3. **Push and Create PR**
   ```bash
   ./scripts/git-smart-commit.sh push
   # Create pull request through GitHub interface
   ```

## Commit Message Format

The script follows the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Examples

```bash
feat(payments): Add Stripe payment integration

- Implement checkout session creation
- Add webhook handling for payment events
- Support subscription and one-time payments
- Include comprehensive error handling

Files changed:
- app/controllers/charges_controller.rb
- app/services/stripe_service.rb
- config/routes.rb
```

```bash
test(security): Add comprehensive file upload validation tests

- Test malicious file detection
- Validate MIME type and extension checking
- Test file size and dimension limits
- Include script injection prevention tests

Files changed:
- test/models/concerns/file_validatable_test.rb
- test/models/user_test.rb
- test/factories.rb
```

## File Staging Intelligence

The script prioritizes important files during staging:

### High Priority Files
- `app/` - Application code
- `config/` - Configuration files
- `db/` - Database migrations
- `test/` - Test files
- `lib/` - Library code
- `Gemfile` - Dependencies
- `README.md` - Documentation
- `.rubocop.yml` - Code quality configuration

### Interactive Staging

The script asks for confirmation before staging:
- Untracked files not matching important patterns
- Large numbers of files
- Potentially sensitive files

## Git Hooks Integration

### Pre-commit Hooks (Recommended)

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Run RuboCop before commit
bundle exec rubocop --auto-correct

# Run tests before commit
bundle exec rails test

# Run security scan
bundle exec brakeman -q
```

### Commit Message Validation

Add to `.git/hooks/commit-msg`:

```bash
#!/bin/bash
# Validate commit message format
commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Use: type(scope): description"
    exit 1
fi
```

## Best Practices

### 1. Commit Frequency
- Make small, focused commits
- Commit working code frequently
- Use the smart commit script for consistency

### 2. Branch Management
- Use descriptive branch names
- Keep branches focused on single features
- Delete merged branches regularly

### 3. Code Quality
- Run tests before committing
- Use RuboCop for code style consistency
- Include security scans in workflow

### 4. Documentation
- Update README for significant changes
- Document new features and APIs
- Include migration guides for breaking changes

## Integration with Development Tools

### VS Code Integration

Add to `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Git Smart Commit",
            "type": "shell",
            "command": "./scripts/git-smart-commit.sh",
            "args": ["commit"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ]
}
```

### Aliases

Add to your shell configuration (`.bashrc`, `.zshrc`):

```bash
# Git smart commit aliases
alias gsc='./scripts/git-smart-commit.sh'
alias gscf='./scripts/git-smart-commit.sh full'
alias gscb='./scripts/git-smart-commit.sh branch'
```

## Troubleshooting

### Common Issues

1. **Script not executable**
   ```bash
   chmod +x scripts/git-smart-commit.sh
   ```

2. **No remote configured**
   ```bash
   git remote add origin <repository-url>
   ```

3. **Merge conflicts**
   ```bash
   git status
   # Resolve conflicts manually
   git add .
   ./scripts/git-smart-commit.sh commit "fix: Resolve merge conflicts"
   ```

### Recovery Commands

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# View commit history
git log --oneline -10

# View file changes
git diff HEAD~1
```

## Security Considerations

### Sensitive Files

The `.gitignore` is configured to exclude:
- Environment variables (`.env` files)
- Database credentials
- API keys and secrets
- Coverage reports
- Temporary files
- IDE configurations

### Pre-commit Security

Always run security scans before committing:

```bash
# Security scan
bundle exec brakeman

# Dependency vulnerability check
bundle audit

# Secret detection (if using tools like git-secrets)
git secrets --scan
```

This intelligent Git workflow ensures consistent, high-quality commits while maintaining security and development best practices for the motos.cat project.
