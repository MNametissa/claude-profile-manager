# Help command

cmd_help() {
    cat << 'EOF'
Claude Profile Manager

USAGE:
    claude -u <profile> [claude-args...]     Run claude with specific profile
    claude [claude-args...]                  Run claude with default profile

    claude-profiles <command> [args...]      Manage profiles

COMMANDS:
    list, ls                    List all profiles
    add <name>                  Create new profile
    remove <name>               Remove profile
    rename <old> <new>          Rename a profile
    info [name]                 Show profile details
    usage [name]                Show disk usage breakdown
    diff <p1> <p2>              Compare two profiles
    export <name> [file]        Export profile to zip
    import <file> [name]        Import profile from zip
    current                     Show current active profile
    default [name]              Get/set default profile
    path                        Show installation path
    help                        Show this help

AGENTS & SKILLS:
    agents [profile]            List agents in profile
    skills [profile]            List skills in profile
    globalize <type> <name>     Make agent/skill global
    localize <type> <name>      Make global agent/skill local
    share <type> <name> <prof>  Share global with profile
    unshare <type> <name> <prof> Remove shared from profile

    <type> = agent | skill

EXAMPLES:
    claude -u work              Start claude with 'work' profile
    claude -u team1             Start claude with 'team1' profile
    claude                      Start claude with default profile

    claude-profiles add work    Create 'work' profile
    claude-profiles list        Show all profiles
    claude-profiles info work   Show 'work' profile details

    claude-profiles globalize agent reviewer
    claude-profiles share agent reviewer work

ENVIRONMENT:
    CLAUDE_DEFAULT_PROFILE      Set default profile (default: personal)
EOF
}
