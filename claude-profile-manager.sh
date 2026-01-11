#!/bin/bash
# Claude Profile Manager
# Enables multiple Claude Code accounts with simple -u flag
# Usage: claude -u <profile> [args...]

# Determine script location
CLAUDE_PM_DIR="${CLAUDE_PM_DIR:-$HOME/.local/share/claude-profile-manager}"

# Source modules
source "$CLAUDE_PM_DIR/lib/config.sh"
source "$CLAUDE_PM_DIR/lib/utils.sh"
source "$CLAUDE_PM_DIR/lib/claude-wrapper.sh"
source "$CLAUDE_PM_DIR/lib/cmd-list.sh"
source "$CLAUDE_PM_DIR/lib/cmd-add.sh"
source "$CLAUDE_PM_DIR/lib/cmd-remove.sh"
source "$CLAUDE_PM_DIR/lib/cmd-info.sh"
source "$CLAUDE_PM_DIR/lib/cmd-transfer.sh"
source "$CLAUDE_PM_DIR/lib/cmd-default.sh"
source "$CLAUDE_PM_DIR/lib/cmd-help.sh"
source "$CLAUDE_PM_DIR/lib/cmd-share.sh"
source "$CLAUDE_PM_DIR/lib/completions.sh"

# Main dispatcher
claude-profiles() {
    local cmd="${1:-list}"
    shift 2>/dev/null || true

    case "$cmd" in
        list|ls)        cmd_list "$@" ;;
        add|create)     cmd_add "$@" ;;
        remove|rm|delete) cmd_remove "$@" ;;
        rename|mv)      cmd_rename "$@" ;;
        info)           cmd_info "$@" ;;
        usage)          cmd_usage "$@" ;;
        diff)           cmd_diff "$@" ;;
        export)         cmd_export "$@" ;;
        import)         cmd_import "$@" ;;
        current)        cmd_current "$@" ;;
        default)        cmd_default "$@" ;;
        path|where)     cmd_path "$@" ;;
        agents)         cmd_agents "$@" ;;
        skills)         cmd_skills "$@" ;;
        globalize)      cmd_globalize "$@" ;;
        localize)       cmd_localize "$@" ;;
        share)          cmd_share "$@" ;;
        unshare)        cmd_unshare "$@" ;;
        help|--help|-h) cmd_help "$@" ;;
        *)
            echo "Unknown command: $cmd" >&2
            echo "Run 'claude-profiles help' for usage" >&2
            return 1
            ;;
    esac
}

export -f claude-profiles
