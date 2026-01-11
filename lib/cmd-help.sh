# Help commands

cmd_help() {
    cat << 'EOF'
Claude Profile Manager

USAGE
    claude -u <profile> [args...]       Run claude with specific profile
    claude-profiles <command> [args...] Manage profiles

PROFILES
    list, ls                    List all profiles
    add <name>                  Create new profile
    remove <name>               Remove profile
    rename <old> <new>          Rename a profile
    info [name]                 Show profile details
    usage [name]                Show disk usage breakdown
    diff <p1> <p2>              Compare two profiles
    current                     Show active profile
    default [name]              Get/set default profile

IMPORT/EXPORT
    export <name> [file]        Export profile to zip
    import <file> [name]        Import profile from zip

AGENTS & SKILLS
    agents [profile]            List agents in profile
    skills [profile]            List skills in profile
    examples                    List bundled examples
    show <type> <name>          Show agent/skill content
    install <type> <name> [target]
    uninstall <type> <name> [profile]
    globalize <type> <name>     Move to global, symlink back
    localize <type> <name>      Copy global back to local
    share <type> <name> <prof>  Link global to profile
    unshare <type> <name> <prof>

    <type>   = agent | skill
    [target] = profile | --global

TRUST (skip permission prompts)
    trust [profile]             Trust profile (skip all prompts)
    untrust [profile]           Untrust profile (restore prompts)

    Or one-time: claude -u work --yolo

SYSTEM
    path                        Show installation path
    self-uninstall              Remove profile manager
    help                        This help
    help extended               Detailed help

Run 'claude-profiles help extended' for more details.
EOF
}

cmd_help_extended() {
    cat << 'EOF'
Claude Profile Manager - Extended Help

STANDALONE USAGE (without profile manager)
    Exported profiles work without the profile manager.
    Just extract and use CLAUDE_CONFIG_DIR:

    unzip claude-profile-work.zip -d ~
    CLAUDE_CONFIG_DIR=~/.claude-work claude

    Or for a whole session:
    export CLAUDE_CONFIG_DIR=~/.claude-work
    claude

EXPORT/IMPORT DETAILS
    Export creates a zip of ~/.claude-<name>/ excluding:
    - .credentials.json (security)
    - statsig/ (telemetry cache)

    After importing, run 'claude -u <name>' to authenticate.

AGENTS & SKILLS WORKFLOW
    1. See available:     claude-profiles examples
    2. Install to profile: claude-profiles install agent dev-rules work
       Or globally:        claude-profiles install agent dev-rules --global
    3. Share global:       claude-profiles share agent dev-rules neo
    4. Use in claude:      claude --agent dev-rules

PROFILE LOCATIONS
    Profiles:       ~/.claude-<name>/
    Global shared:  ~/.claude-shared/agents/
                    ~/.claude-shared/skills/
    Manager:        ~/.local/share/claude-profile-manager/

UNINSTALLING
    claude-profiles self-uninstall

    This removes:
    - Source line from ~/.bashrc or ~/.zshrc
    - ~/.local/share/claude-profile-manager/

    It does NOT remove:
    - Your profiles (~/.claude-*)
    - Global agents/skills (~/.claude-shared/)
EOF
}
