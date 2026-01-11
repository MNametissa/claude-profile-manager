# Agent and skill sharing commands

GLOBAL_AGENTS_DIR="$HOME/.claude-shared/agents"
GLOBAL_SKILLS_DIR="$HOME/.claude-shared/skills"
EXAMPLES_DIR="$CLAUDE_PM_DIR/examples"

# Install agent/skill from examples to a profile or globally
cmd_install() {
    local type="$1"
    local name="$2"
    local target="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles install <agent|skill> <name> [profile|--global]" >&2
        echo ""
        echo "Available examples:"
        _list_examples
        return 1
    fi

    local source_file target_dir target_label
    local is_global=0

    if [[ "$target" == "--global" || "$target" == "-g" ]]; then
        is_global=1
        target_label="global"
        case "$type" in
            agent|agents) target_dir="$GLOBAL_AGENTS_DIR" ;;
            skill|skills) target_dir="$GLOBAL_SKILLS_DIR" ;;
            *)
                echo "Type must be 'agent' or 'skill'" >&2
                return 1
                ;;
        esac
    else
        local config_dir="$(profile_dir "$target")"
        require_profile "$target" || return 1
        target_label="profile '$target'"
        case "$type" in
            agent|agents) target_dir="$config_dir/agents" ;;
            skill|skills) target_dir="$config_dir/skills" ;;
            *)
                echo "Type must be 'agent' or 'skill'" >&2
                return 1
                ;;
        esac
    fi

    case "$type" in
        agent|agents) source_file="$EXAMPLES_DIR/agents/$name.md" ;;
        skill|skills) source_file="$EXAMPLES_DIR/skills/$name.md" ;;
    esac

    if [[ ! -f "$source_file" ]]; then
        echo "$type '$name' not found in examples" >&2
        echo ""
        echo "Available examples:"
        _list_examples
        return 1
    fi

    local target_file="$target_dir/$name.md"
    if [[ -e "$target_file" ]]; then
        echo "$type '$name' already exists in $target_label" >&2
        return 1
    fi

    mkdir -p "$target_dir"
    cp "$source_file" "$target_file"

    echo "✓ Installed $type '$name' to $target_label"
}

# Uninstall agent/skill from a profile
cmd_uninstall() {
    local type="$1"
    local name="$2"
    local profile_name="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles uninstall <agent|skill> <name> [profile]" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    local target_dir
    case "$type" in
        agent|agents) target_dir="$config_dir/agents" ;;
        skill|skills) target_dir="$config_dir/skills" ;;
        *)
            echo "Type must be 'agent' or 'skill'" >&2
            return 1
            ;;
    esac

    local target_file="$target_dir/$name.md"

    if [[ ! -e "$target_file" ]]; then
        echo "$type '$name' not found in profile '$profile_name'" >&2
        return 1
    fi

    rm -f "$target_file"
    echo "✓ Uninstalled $type '$name' from profile '$profile_name'"
}

# List available examples
cmd_examples() {
    echo "Available examples:"
    echo ""
    _list_examples
}

_list_examples() {
    echo "Agents:"
    if [[ -d "$EXAMPLES_DIR/agents" ]]; then
        for f in "$EXAMPLES_DIR/agents"/*.md; do
            [[ -f "$f" ]] || continue
            echo "  ● $(basename "$f" .md)"
        done
    else
        echo "  (none)"
    fi

    echo ""
    echo "Skills:"
    if [[ -d "$EXAMPLES_DIR/skills" ]]; then
        for f in "$EXAMPLES_DIR/skills"/*.md; do
            [[ -f "$f" ]] || continue
            echo "  ● $(basename "$f" .md)"
        done
    else
        echo "  (none)"
    fi
}

# Show agent/skill content
cmd_show() {
    local type="$1"
    local name="$2"
    local profile_name="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles show <agent|skill> <name> [profile]" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    local file=""

    case "$type" in
        agent|agents)
            if [[ -f "$config_dir/agents/$name.md" ]]; then
                file="$config_dir/agents/$name.md"
            elif [[ -f "$GLOBAL_AGENTS_DIR/$name.md" ]]; then
                file="$GLOBAL_AGENTS_DIR/$name.md"
            fi
            ;;
        skill|skills)
            if [[ -f "$config_dir/skills/$name.md" ]]; then
                file="$config_dir/skills/$name.md"
            elif [[ -f "$GLOBAL_SKILLS_DIR/$name.md" ]]; then
                file="$GLOBAL_SKILLS_DIR/$name.md"
            fi
            ;;
        *)
            echo "Type must be 'agent' or 'skill'" >&2
            return 1
            ;;
    esac

    if [[ -z "$file" || ! -f "$file" ]]; then
        echo "$type '$name' not found" >&2
        return 1
    fi

    echo "=== $name ($type) ==="
    [[ -L "$file" ]] && echo "Location: $(readlink -f "$file")" || echo "Location: $file"
    echo ""
    cat "$file"
}

# List agents or skills
cmd_agents() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    echo "Agents for '$profile_name':"
    echo ""

    if [[ -d "$config_dir/agents" ]]; then
        for agent in "$config_dir/agents"/*.md; do
            [[ -f "$agent" ]] || continue
            local name=$(basename "$agent" .md)
            local status="local"
            [[ -L "$agent" ]] && status="shared"
            printf "  %-20s [%s]\n" "$name" "$status"
        done
    else
        echo "  (none)"
    fi

    echo ""
    echo "Global agents:"
    if [[ -d "$GLOBAL_AGENTS_DIR" ]]; then
        for agent in "$GLOBAL_AGENTS_DIR"/*.md; do
            [[ -f "$agent" ]] || continue
            echo "  ● $(basename "$agent" .md)"
        done
    else
        echo "  (none)"
    fi
}

cmd_skills() {
    local profile_name="${1:-$CLAUDE_DEFAULT_PROFILE}"
    local config_dir="$(profile_dir "$profile_name")"

    require_profile "$profile_name" || return 1

    echo "Skills for '$profile_name':"
    echo ""

    if [[ -d "$config_dir/skills" ]]; then
        for skill in "$config_dir/skills"/*.md; do
            [[ -f "$skill" ]] || continue
            local name=$(basename "$skill" .md)
            local status="local"
            [[ -L "$skill" ]] && status="shared"
            printf "  %-20s [%s]\n" "$name" "$status"
        done
    else
        echo "  (none)"
    fi

    echo ""
    echo "Global skills:"
    if [[ -d "$GLOBAL_SKILLS_DIR" ]]; then
        for skill in "$GLOBAL_SKILLS_DIR"/*.md; do
            [[ -f "$skill" ]] || continue
            echo "  ● $(basename "$skill" .md)"
        done
    else
        echo "  (none)"
    fi
}

# Make agent/skill global (move to shared, symlink back)
cmd_globalize() {
    local type="$1"  # agent or skill
    local name="$2"
    local profile_name="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles globalize <agent|skill> <name> [profile]" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    local source_dir global_dir
    case "$type" in
        agent|agents)
            source_dir="$config_dir/agents"
            global_dir="$GLOBAL_AGENTS_DIR"
            ;;
        skill|skills)
            source_dir="$config_dir/skills"
            global_dir="$GLOBAL_SKILLS_DIR"
            ;;
        *)
            echo "Type must be 'agent' or 'skill'" >&2
            return 1
            ;;
    esac

    local source_file="$source_dir/$name.md"
    local global_file="$global_dir/$name.md"

    if [[ ! -f "$source_file" ]]; then
        echo "$type '$name' not found in profile '$profile_name'" >&2
        return 1
    fi

    if [[ -L "$source_file" ]]; then
        echo "$type '$name' is already shared" >&2
        return 1
    fi

    mkdir -p "$global_dir"
    mv "$source_file" "$global_file"
    ln -s "$global_file" "$source_file"

    echo "✓ Made '$name' global"
    echo "  Location: $global_file"
}

# Remove global status (copy back to local)
cmd_localize() {
    local type="$1"
    local name="$2"
    local profile_name="${3:-$CLAUDE_DEFAULT_PROFILE}"

    if [[ -z "$type" || -z "$name" ]]; then
        echo "Usage: claude-profiles localize <agent|skill> <name> [profile]" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    local source_dir global_dir
    case "$type" in
        agent|agents)
            source_dir="$config_dir/agents"
            global_dir="$GLOBAL_AGENTS_DIR"
            ;;
        skill|skills)
            source_dir="$config_dir/skills"
            global_dir="$GLOBAL_SKILLS_DIR"
            ;;
        *)
            echo "Type must be 'agent' or 'skill'" >&2
            return 1
            ;;
    esac

    local source_file="$source_dir/$name.md"
    local global_file="$global_dir/$name.md"

    if [[ ! -L "$source_file" ]]; then
        echo "$type '$name' is not shared (already local)" >&2
        return 1
    fi

    rm "$source_file"
    cp "$global_file" "$source_file"

    echo "✓ Made '$name' local to profile '$profile_name'"
}

# Share a global agent/skill with a profile
cmd_share() {
    local type="$1"
    local name="$2"
    local profile_name="$3"

    if [[ -z "$type" || -z "$name" || -z "$profile_name" ]]; then
        echo "Usage: claude-profiles share <agent|skill> <name> <profile>" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    local target_dir global_dir
    case "$type" in
        agent|agents)
            target_dir="$config_dir/agents"
            global_dir="$GLOBAL_AGENTS_DIR"
            ;;
        skill|skills)
            target_dir="$config_dir/skills"
            global_dir="$GLOBAL_SKILLS_DIR"
            ;;
        *)
            echo "Type must be 'agent' or 'skill'" >&2
            return 1
            ;;
    esac

    local global_file="$global_dir/$name.md"
    local target_file="$target_dir/$name.md"

    if [[ ! -f "$global_file" ]]; then
        echo "Global $type '$name' not found" >&2
        echo "Available: $(ls "$global_dir"/*.md 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/.md$//' | tr '\n' ' ')" >&2
        return 1
    fi

    if [[ -e "$target_file" ]]; then
        echo "$type '$name' already exists in profile '$profile_name'" >&2
        return 1
    fi

    mkdir -p "$target_dir"
    ln -s "$global_file" "$target_file"

    echo "✓ Shared '$name' with profile '$profile_name'"
}

# Unshare (remove symlink from profile)
cmd_unshare() {
    local type="$1"
    local name="$2"
    local profile_name="$3"

    if [[ -z "$type" || -z "$name" || -z "$profile_name" ]]; then
        echo "Usage: claude-profiles unshare <agent|skill> <name> <profile>" >&2
        return 1
    fi

    local config_dir="$(profile_dir "$profile_name")"
    require_profile "$profile_name" || return 1

    local target_dir
    case "$type" in
        agent|agents) target_dir="$config_dir/agents" ;;
        skill|skills) target_dir="$config_dir/skills" ;;
        *)
            echo "Type must be 'agent' or 'skill'" >&2
            return 1
            ;;
    esac

    local target_file="$target_dir/$name.md"

    if [[ ! -L "$target_file" ]]; then
        echo "$type '$name' is not a shared link in profile '$profile_name'" >&2
        return 1
    fi

    rm "$target_file"
    echo "✓ Unshared '$name' from profile '$profile_name'"
}
