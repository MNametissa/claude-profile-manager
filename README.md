# Claude Profile Manager

Manage multiple Claude Code profiles with a simple `-u` flag. Each profile has isolated settings, permissions, history, and credentials.

## Install

```bash
bash install.sh
source ~/.bashrc  # or ~/.zshrc
```

The installer:
- Copies scripts to `~/.local/share/claude-profile-manager/`
- Adds a source line to your shell config
- Offers to reload your shell

## Quick Start

```bash
# Create profiles
claude-profiles add work
claude-profiles add personal

# Use a profile
claude -u work
claude -u personal

# Set default profile
claude-profiles default work
claude
```

## Profile Management

```bash
claude-profiles list                    # List all profiles
claude-profiles add <name>              # Create new profile
claude-profiles remove <name>           # Remove profile
claude-profiles rename <old> <new>      # Rename profile
claude-profiles clone <src> <dest>      # Clone a profile
claude-profiles clone <src> <dest> -l   # Clone with shared resources
claude-profiles default [name]          # Get/set default profile
claude-profiles info [name]             # Show profile details
claude-profiles usage [name]            # Show disk usage
claude-profiles diff <p1> <p2>          # Compare two profiles
```

## Permissions

Manage what Claude can and cannot do per profile:

```bash
# View permissions
claude-profiles permissions [profile]

# Initialize permissions
claude-profiles permissions-init [profile]

# Allow specific operations
claude-profiles allow 'Bash(git *)' [profile]
claude-profiles allow 'Bash(npm *)' [profile]

# Deny dangerous operations
claude-profiles deny 'Bash(rm -rf *)' [profile]
claude-profiles deny 'Bash(sudo *)' [profile]

# Apply presets
claude-profiles permissions-preset safe      # Block dangerous commands
claude-profiles permissions-preset dev       # Allow common dev tools
claude-profiles permissions-preset readonly  # No writes, only reads
claude-profiles permissions-preset reset     # Clear all rules
```

## Resource Sharing

Share resources between profiles:

```bash
# Link individual resources
claude-profiles link-instructions [profile]   # Share CLAUDE.md
claude-profiles link-projects [profile]       # Share conversations
claude-profiles link-history [profile]        # Share command history
claude-profiles link-todos [profile]          # Share todos
claude-profiles link-permissions [profile]    # Share settings.json

# Link all resources
claude-profiles link-all [profile]

# Unlink (copy back to local)
claude-profiles unlink-instructions [profile]
claude-profiles unlink-all [profile]

# View link status
claude-profiles link-status [profile]

# Sync resources between profiles
claude-profiles sync-instructions <src> <dest>
claude-profiles sync-settings <src> <dest>
claude-profiles merge-history <src> <dest>
```

## Export/Import

```bash
# Export profile (excludes credentials)
claude-profiles export work

# Import profile
claude-profiles import claude-profile-work-20240115.zip
claude-profiles import backup.zip newname
```

## Trust Mode

Skip all permission prompts (use with caution):

```bash
claude-profiles trust [profile]    # Enable trust mode
claude-profiles untrust [profile]  # Disable trust mode
```

## Uninstall

```bash
claude-profiles self-uninstall
```

Or manually:
1. Remove the source line from `~/.bashrc` or `~/.zshrc`
2. Delete `~/.local/share/claude-profile-manager/`

Profiles are kept in `~/.claude-<name>/` and can be used standalone:
```bash
CLAUDE_CONFIG_DIR=~/.claude-work claude
```

## Requirements

- Linux or macOS
- Bash or Zsh
- `zip`/`unzip` (for export/import)
- `jq` (for permission management)
