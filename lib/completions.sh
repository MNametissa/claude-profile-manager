# Bash completions

if [[ -n "$BASH_VERSION" ]]; then
    _claude_profiles_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"

        if [[ $COMP_CWORD -eq 1 ]]; then
            COMPREPLY=($(compgen -W "list add remove rename info usage diff export import current default path help" -- "$cur"))
        elif [[ $COMP_CWORD -eq 2 ]] && [[ "$prev" =~ ^(remove|rename|info|usage|export|default)$ ]]; then
            local profiles=$(list_profiles)
            COMPREPLY=($(compgen -W "$profiles" -- "$cur"))
        elif [[ $COMP_CWORD -eq 3 ]] && [[ "${COMP_WORDS[1]}" == "diff" ]]; then
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
