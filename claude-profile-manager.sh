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
source "$CLAUDE_PM_DIR/lib/cmd-permissions.sh"
source "$CLAUDE_PM_DIR/lib/cmd-system.sh"
source "$CLAUDE_PM_DIR/lib/cmd-link.sh"
source "$CLAUDE_PM_DIR/lib/completions.sh"

# Main dispatcher
claude-profiles() {
    local cmd="${1:-list}"
    shift 2>/dev/null || true

    case "$cmd" in
        # Profiles
        list|ls)          cmd_list "$@" ;;
        add|create)       cmd_add "$@" ;;
        remove|rm|delete) cmd_remove "$@" ;;
        rename|mv)        cmd_rename "$@" ;;
        info)             cmd_info "$@" ;;
        usage)            cmd_usage "$@" ;;
        diff)             cmd_diff "$@" ;;
        current)          cmd_current "$@" ;;
        default)          cmd_default "$@" ;;
        # Import/Export
        export)           cmd_export "$@" ;;
        import)           cmd_import "$@" ;;
        # Agents & Skills
        agents)           cmd_agents "$@" ;;
        skills)           cmd_skills "$@" ;;
        examples)         cmd_examples "$@" ;;
        show)             cmd_show "$@" ;;
        install)          cmd_install "$@" ;;
        uninstall)        cmd_uninstall "$@" ;;
        globalize)        cmd_globalize "$@" ;;
        localize)         cmd_localize "$@" ;;
        share)            cmd_share "$@" ;;
        unshare)          cmd_unshare "$@" ;;
        # Permissions
        permissions|perms) cmd_permissions "$@" ;;
        permissions-init)  cmd_permissions_init "$@" ;;
        permissions-preset|preset) cmd_permissions_preset "$@" ;;
        allow)            cmd_allow "$@" ;;
        deny)             cmd_deny "$@" ;;
        ask)              cmd_ask "$@" ;;
        unallow)          cmd_unallow "$@" ;;
        undeny)           cmd_undeny "$@" ;;
        # Trust
        trust)            cmd_trust "$@" ;;
        untrust)          cmd_untrust "$@" ;;
        # Linking/Sharing resources
        link-instructions)   cmd_link_instructions "$@" ;;
        unlink-instructions) cmd_unlink_instructions "$@" ;;
        sync-instructions)   cmd_sync_instructions "$@" ;;
        link-projects)       cmd_link_projects "$@" ;;
        unlink-projects)     cmd_unlink_projects "$@" ;;
        link-history)        cmd_link_history "$@" ;;
        unlink-history)      cmd_unlink_history "$@" ;;
        merge-history)       cmd_merge_history "$@" ;;
        link-todos)          cmd_link_todos "$@" ;;
        unlink-todos)        cmd_unlink_todos "$@" ;;
        link-permissions)    cmd_link_permissions "$@" ;;
        unlink-permissions)  cmd_unlink_permissions "$@" ;;
        sync-settings)       cmd_sync_settings "$@" ;;
        link-all)            cmd_link_all "$@" ;;
        unlink-all)          cmd_unlink_all "$@" ;;
        link-status)         cmd_link_status "$@" ;;
        clone)               cmd_clone "$@" ;;
        # System
        path|where)       cmd_path "$@" ;;
        self-uninstall)   cmd_self_uninstall "$@" ;;
        help|--help|-h)
            if [[ "$1" == "extended" ]]; then
                cmd_help_extended
            else
                cmd_help "$@"
            fi
            ;;
        *)
            echo "Unknown command: $cmd" >&2
            echo "Run 'claude-profiles help' for usage" >&2
            return 1
            ;;
    esac
}

export -f claude-profiles
