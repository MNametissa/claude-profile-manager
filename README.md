# Claude Profile Manager

Manage multiple Claude Code profiles with a simple `-u` flag.

## Install

```bash
bash install.sh
```

## Usage

```bash
# Run claude with a specific profile
claude -u work
claude -u team1

# Run with default profile
claude
```

## Commands

```bash
claude-profiles list              # List all profiles
claude-profiles add <name>        # Create new profile
claude-profiles remove <name>     # Remove profile
claude-profiles rename <old> <new>
claude-profiles info [name]       # Show profile details
claude-profiles usage [name]      # Show disk usage
claude-profiles diff <p1> <p2>    # Compare two profiles
claude-profiles export <name>     # Export to zip
claude-profiles import <file>     # Import from zip
claude-profiles default [name]    # Get/set default
claude-profiles path              # Show install location
```

## Uninstall

Remove the source line from your `.bashrc`/`.zshrc` and delete `~/.local/share/claude-profile-manager`.
