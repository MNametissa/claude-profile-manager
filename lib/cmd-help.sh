# Help commands

cmd_help() {
    cat << 'EOF'
Claude Profile Manager

USAGE
  claude -u <profile> [args...]       Run claude with specific profile
  claude -u <profile> --yolo          Run without permission prompts
  claude-profiles <command>           Manage profiles

PROFILES
  list                          List all profiles
  add <name>                    Create profile
  remove <name>                 Remove profile
  rename <old> <new>            Rename profile
  clone <src> <dst> [--linked]  Clone profile (--linked shares resources)
  info [name]                   Show profile details
  usage [name]                  Show disk usage
  diff <p1> <p2>                Compare profiles
  current                       Show active profile
  default [name]                Get/set default

IMPORT/EXPORT
  export <name> [file]          Export to zip (excl. credentials)
  import <file> [name]          Import from zip

RESOURCE SHARING
  link-all [profile]            Link all resources to shared
  unlink-all [profile]          Unlink all (copy back to local)
  link-status [profile]         Show link status

  Individual:
    link-projects [profile]     Share conversations
    link-instructions [profile] Share CLAUDE.md
    link-history [profile]      Share session history
    link-todos [profile]        Share todos
    link-permissions [profile]  Share settings.json

  Sync (one-time copy):
    sync-instructions <src> <dst>
    sync-settings <src> <dst>
    merge-history <p1> <p2>

AGENTS & SKILLS
  agents [profile]              List agents
  skills [profile]              List skills
  examples                      List bundled examples
  show <type> <name>            Show content
  install <type> <name> [dst]   Install example (dst: profile | --global)
  uninstall <type> <name>       Remove from profile
  globalize <type> <name>       Move to global, symlink back
  localize <type> <name>        Copy global to local
  share <type> <name> <prof>    Link global to profile
  unshare <type> <name> <prof>  Remove link

PERMISSIONS
  permissions [profile]         Show rules
  permissions-init [profile]    Initialize permissions
  preset <name> [profile]       Apply preset (safe|dev|readonly|reset)
  allow <rule> [profile]        Add allow rule
  deny <rule> [profile]         Add deny rule
  ask <rule> [profile]          Add ask rule

TRUST
  trust [profile]               Skip all prompts permanently
  untrust [profile]             Restore prompts

SYSTEM
  path                          Show install location
  self-uninstall                Remove profile manager
  help                          This help
  help extended                 Detailed help
EOF
}

cmd_help_extended() {
    cat << 'EOF'
Claude Profile Manager - Extended Help

STANDALONE USAGE
  Profiles work without the manager:
    CLAUDE_CONFIG_DIR=~/.claude-work claude

RESOURCE SHARING
  Share resources across profiles via ~/.claude-shared/

  Quick start:
    claude-profiles clone work team --linked

  Or link existing profile:
    claude-profiles link-all work
    claude-profiles link-status work

  Stop sharing:
    claude-profiles unlink-all work

AGENTS & SKILLS WORKFLOW
  1. claude-profiles examples
  2. claude-profiles install agent dev-rules --global
  3. claude-profiles share agent dev-rules work
  4. claude -u work --agent dev-rules

PERMISSION RULES
  Examples:
    claude-profiles allow 'Bash(npm *)'
    claude-profiles deny 'Bash(sudo *)'
    claude-profiles preset dev work

LOCATIONS
  Profiles:   ~/.claude-<name>/
  Shared:     ~/.claude-shared/
  Manager:    ~/.local/share/claude-profile-manager/
EOF
}
