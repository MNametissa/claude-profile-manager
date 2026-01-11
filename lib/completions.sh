# Bash completions

if [[ -n "$BASH_VERSION" ]]; then
    _claude_profiles_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"

        local commands="list add remove rename info usage diff export import current default path help agents skills examples show install uninstall globalize localize share unshare permissions permissions-init permissions-preset allow deny ask unallow undeny trust untrust link-instructions unlink-instructions sync-instructions link-projects unlink-projects link-history unlink-history merge-history link-todos unlink-todos link-permissions unlink-permissions sync-settings link-all unlink-all link-status clone self-uninstall"

        local profile_commands="remove rename info usage export default trust untrust link-instructions unlink-instructions link-projects unlink-projects link-history unlink-history link-todos unlink-todos link-permissions unlink-permissions link-all unlink-all link-status agents skills clone"

        if [[ $COMP_CWORD -eq 1 ]]; then
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        elif [[ $COMP_CWORD -eq 2 ]] && [[ " $profile_commands " =~ " $prev " ]]; then
            local profiles=$(list_profiles)
            COMPREPLY=($(compgen -W "$profiles" -- "$cur"))
        elif [[ $COMP_CWORD -eq 3 ]] && [[ "${COMP_WORDS[1]}" =~ ^(diff|sync-instructions|sync-settings|merge-history|clone)$ ]]; then
            local profiles=$(list_profiles)
            COMPREPLY=($(compgen -W "$profiles" -- "$cur"))
        fi
    }
    complete -F _claude_profiles_completion claude-profiles

    _claude_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"

        if [[ "$prev" == "-u" ]] || [[ "$prev" == "--user" ]]; then
            local profiles=$(list_profiles)
            COMPREPLY=($(compgen -W "$profiles" -- "$cur"))
        fi
    }
    complete -F _claude_completion claude
fi
