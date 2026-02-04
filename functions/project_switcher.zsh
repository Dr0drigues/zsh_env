# ==============================================================================
# Project Switcher - Changement de contexte projet complet
# ==============================================================================
# Change tout le contexte: dossier, kube context, node version, tmux session
# ==============================================================================

# Fichier de config projet: .proj ou .project.yml
PROJ_CONFIG_NAMES=(".proj" ".project.yml" ".project.yaml")

# Registre des projets connus
PROJ_REGISTRY_FILE="$HOME/.config/zsh_env/projects.yml"

# Cherche un fichier de config projet
_proj_find_config() {
    local dir="${1:-$PWD}"

    for name in "${PROJ_CONFIG_NAMES[@]}"; do
        if [[ -f "$dir/$name" ]]; then
            echo "$dir/$name"
            return 0
        fi
    done

    return 1
}

# Parse une valeur du fichier projet (YAML simple)
_proj_get_value() {
    local file="$1"
    local key="$2"

    grep -E "^${key}:" "$file" 2>/dev/null | sed "s/^${key}:[[:space:]]*//" | tr -d '"' | tr -d "'"
}

# Charge un projet par son chemin
_proj_load_by_path() {
    local proj_dir="$1"
    local config_file

    if [[ ! -d "$proj_dir" ]]; then
        echo "Dossier non trouve: $proj_dir" >&2
        return 1
    fi

    config_file=$(_proj_find_config "$proj_dir")

    # CD au projet
    cd "$proj_dir" || return 1
    echo "Projet: $proj_dir"

    # Si pas de config, juste cd
    if [[ -z "$config_file" ]]; then
        echo "  (pas de fichier .proj)"
        return 0
    fi

    # Lire la config
    local kube_context=$(_proj_get_value "$config_file" "kube_context")
    local node_version=$(_proj_get_value "$config_file" "node_version")
    local tmux_session=$(_proj_get_value "$config_file" "tmux_session")
    local env_file=$(_proj_get_value "$config_file" "env_file")
    local post_cmd=$(_proj_get_value "$config_file" "post_cmd")

    # Appliquer le contexte kube
    if [[ -n "$kube_context" ]]; then
        if command -v kubectl &> /dev/null; then
            if kubectl config use-context "$kube_context" &> /dev/null; then
                echo "  Kube context: $kube_context"
            else
                echo "  Kube context '$kube_context' non trouve" >&2
            fi
        fi
    fi

    # Appliquer la version Node
    if [[ -n "$node_version" ]]; then
        if command -v nvm &> /dev/null || [[ -f "$NVM_DIR/nvm.sh" ]]; then
            [[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"
            [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
            nvm use "$node_version" 2>/dev/null || nvm install "$node_version"
            echo "  Node: $(node -v)"
        fi
    elif [[ -f "$proj_dir/.nvmrc" ]]; then
        # Fallback sur .nvmrc
        if command -v nvm &> /dev/null || [[ -s "$NVM_DIR/nvm.sh" ]]; then
            [[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"
            [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
            nvm use 2>/dev/null
            echo "  Node: $(node -v) (via .nvmrc)"
        fi
    fi

    # Charger un fichier env
    if [[ -n "$env_file" && -f "$proj_dir/$env_file" ]]; then
        set -a
        source "$proj_dir/$env_file"
        set +a
        echo "  Env: $env_file charge"
    fi

    # Session tmux
    if [[ -n "$tmux_session" ]] && command -v tmux &> /dev/null; then
        if [[ -z "$TMUX" ]]; then
            echo "  Tmux: utilisez 'tm $tmux_session' pour la session dediee"
        fi
    fi

    # Commande post
    if [[ -n "$post_cmd" ]]; then
        echo "  Execution: $post_cmd"
        eval "$post_cmd"
    fi

    return 0
}

# Fonction principale
# Usage: proj [name|path]
proj() {
    local target="$1"

    # Sans argument: projet courant ou selection
    if [[ -z "$target" ]]; then
        local config=$(_proj_find_config)
        if [[ -n "$config" ]]; then
            _proj_load_by_path "$PWD"
            return
        fi

        # Selection interactive
        if [[ -f "$PROJ_REGISTRY_FILE" ]] && command -v fzf &> /dev/null; then
            local projects=$(grep -E "^[a-zA-Z0-9_-]+:" "$PROJ_REGISTRY_FILE" | sed 's/:.*//')
            if [[ -n "$projects" ]]; then
                target=$(echo "$projects" | fzf --header="Projets enregistres" --prompt="Projet > ")
                [[ -z "$target" ]] && return 0
            fi
        fi

        if [[ -z "$target" ]]; then
            echo "Usage: proj <name|path>" >&2
            echo "       proj --add [name]    Enregistrer un projet" >&2
            echo "       proj --list          Lister les projets" >&2
            echo "       proj --scan [dir]    Scanner et proposer des projets" >&2
            return 1
        fi
    fi

    # Options
    case "$target" in
        --add|-a)
            proj_add "$2" "$3"
            return
            ;;
        --list|-l)
            proj_list
            return
            ;;
        --remove|-r)
            proj_remove "$2"
            return
            ;;
        --init|-i)
            proj_init
            return
            ;;
        --scan|-s)
            proj_scan "$2" "$3"
            return
            ;;
        --auto)
            proj_auto_register "$2" "$3"
            return
            ;;
        --help|-h)
            proj_help
            return
            ;;
    esac

    # Chemin absolu ou relatif
    if [[ -d "$target" ]]; then
        _proj_load_by_path "$target"
        return
    fi

    # Chemin avec ~
    if [[ -d "${target/#\~/$HOME}" ]]; then
        _proj_load_by_path "${target/#\~/$HOME}"
        return
    fi

    # Chercher dans le registre
    if [[ -f "$PROJ_REGISTRY_FILE" ]]; then
        local path=$(grep -E "^${target}:" "$PROJ_REGISTRY_FILE" | sed "s/^${target}:[[:space:]]*//" | tr -d '"')
        path="${path/#\~/$HOME}"
        if [[ -n "$path" && -d "$path" ]]; then
            _proj_load_by_path "$path"
            return
        fi
    fi

    # Chercher dans WORK_DIR
    if [[ -n "$WORK_DIR" && -d "$WORK_DIR/$target" ]]; then
        _proj_load_by_path "$WORK_DIR/$target"
        return
    fi

    echo "Projet '$target' non trouve." >&2
    return 1
}

# Enregistre un projet
proj_add() {
    local name="$1"
    local path="${2:-$PWD}"

    if [[ -z "$name" ]]; then
        name=$(basename "$path")
        echo -n "Nom du projet [$name]: "
        read input
        [[ -n "$input" ]] && name="$input"
    fi

    # Resoudre le chemin
    path=$(cd "$path" 2>/dev/null && pwd)
    if [[ -z "$path" ]]; then
        echo "Chemin invalide." >&2
        return 1
    fi

    # Creer le dossier config (utilise expansion zsh au lieu de dirname)
    local registry_dir="${PROJ_REGISTRY_FILE:h}"
    [[ ! -d "$registry_dir" ]] && /bin/mkdir -p "$registry_dir"

    # Ajouter ou mettre a jour
    if grep -qE "^${name}:" "$PROJ_REGISTRY_FILE" 2>/dev/null; then
        # Mettre a jour
        sed -i.bak "s|^${name}:.*|${name}: \"$path\"|" "$PROJ_REGISTRY_FILE"
        echo "Projet '$name' mis a jour."
    else
        echo "${name}: \"$path\"" >> "$PROJ_REGISTRY_FILE"
        echo "Projet '$name' enregistre."
    fi

    echo "  Chemin: $path"
}

# Liste les projets enregistres
proj_list() {
    if [[ ! -f "$PROJ_REGISTRY_FILE" ]]; then
        echo "Aucun projet enregistre."
        echo "Utilisez 'proj --add [name] [path]' pour en ajouter."
        return 0
    fi

    echo "Projets enregistres:"
    echo "──────────────────────────────────────────"

    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        local name=$(echo "$line" | cut -d: -f1)
        local path=$(echo "$line" | sed "s/^${name}:[[:space:]]*//" | tr -d '"')
        path="${path/#\~/$HOME}"

        if [[ -d "$path" ]]; then
            printf "  %-15s %s\n" "$name" "$path"
        else
            printf "  %-15s %s \033[31m(manquant)\033[0m\n" "$name" "$path"
        fi
    done < "$PROJ_REGISTRY_FILE"

    echo "──────────────────────────────────────────"
}

# Supprime un projet du registre
proj_remove() {
    local name="$1"

    if [[ -z "$name" ]]; then
        echo "Usage: proj --remove <name>" >&2
        return 1
    fi

    if [[ ! -f "$PROJ_REGISTRY_FILE" ]]; then
        echo "Aucun projet enregistre." >&2
        return 1
    fi

    if ! grep -qE "^${name}:" "$PROJ_REGISTRY_FILE"; then
        echo "Projet '$name' non trouve." >&2
        return 1
    fi

    sed -i.bak "/^${name}:/d" "$PROJ_REGISTRY_FILE"
    echo "Projet '$name' supprime."
}

# Initialise un fichier .proj dans le dossier courant
proj_init() {
    local config_file="$PWD/.proj"

    if [[ -f "$config_file" ]]; then
        echo "Fichier .proj existe deja."
        return 1
    fi

    local default_name=$(basename "$PWD")
    cat > "$config_file" << EOF
# Configuration projet zsh_env
# Utilisez 'proj' pour charger ce contexte

# Nom du projet (utilise pour l'enregistrement auto)
name: $default_name

# Contexte Kubernetes (optionnel)
# kube_context: my-cluster-context

# Version Node (optionnel, sinon utilise .nvmrc)
# node_version: 18

# Session tmux (optionnel)
# tmux_session: $default_name

# Fichier d'environnement a charger (optionnel)
# env_file: .env.local

# Commande a executer apres chargement (optionnel)
# post_cmd: echo "Projet charge!"
EOF

    echo "Fichier .proj cree."
    echo "Editez-le pour configurer votre contexte projet."
}

# Scanne un dossier pour trouver des projets potentiels
proj_scan() {
    local scan_dir="${1:-${WORK_DIR:-$HOME/projects}}"
    local depth="${2:-2}"

    if [[ ! -d "$scan_dir" ]]; then
        echo "Dossier non trouve: $scan_dir" >&2
        return 1
    fi

    echo "Scan de $scan_dir (profondeur: $depth)..."
    echo ""

    local found=()
    local already_registered=()
    local name has_config markers is_registered

    # Chercher les dossiers avec .proj, .git, package.json, etc.
    while IFS= read -r dir; do
        [[ -z "$dir" ]] && continue
        name="${dir:t}"
        has_config=false
        markers=""

        # Detecter les marqueurs de projet
        [[ -f "$dir/.proj" ]] && markers="$markers .proj" && has_config=true
        [[ -f "$dir/.project.yml" ]] && markers="$markers .project.yml" && has_config=true
        [[ -d "$dir/.git" ]] && markers="$markers git"
        [[ -f "$dir/package.json" ]] && markers="$markers node"
        [[ -f "$dir/Cargo.toml" ]] && markers="$markers rust"
        [[ -f "$dir/go.mod" ]] && markers="$markers go"
        [[ -f "$dir/pyproject.toml" || -f "$dir/setup.py" ]] && markers="$markers python"
        [[ -f "$dir/pom.xml" || -f "$dir/build.gradle" ]] && markers="$markers java"

        # Retirer l'espace initial et ignorer si pas de marqueur
        markers="${markers# }"
        [[ -z "$markers" ]] && continue

        # Verifier si deja enregistre
        is_registered=false
        if [[ -f "$PROJ_REGISTRY_FILE" ]]; then
            if grep -q "\"$dir\"" "$PROJ_REGISTRY_FILE" 2>/dev/null; then
                is_registered=true
            fi
        fi

        if $is_registered; then
            already_registered+=("$dir")
        else
            found+=("$dir|$name|$markers")
        fi
    done < <(find "$scan_dir" -maxdepth "$depth" -type d 2>/dev/null)

    # Afficher les resultats
    if [[ ${#found[@]} -eq 0 ]]; then
        echo "Aucun nouveau projet detecte."
        [[ ${#already_registered[@]} -gt 0 ]] && echo "${#already_registered[@]} projet(s) deja enregistre(s)."
        return 0
    fi

    echo "Projets detectes:"
    echo "──────────────────────────────────────────"

    local i=1
    local entry_dir entry_name entry_markers
    for entry in "${found[@]}"; do
        entry_dir=$(echo "$entry" | cut -d'|' -f1)
        entry_name=$(echo "$entry" | cut -d'|' -f2)
        entry_markers=$(echo "$entry" | cut -d'|' -f3)
        printf "  %2d) %-20s [%s]\n" "$i" "$entry_name" "$entry_markers"
        printf "      %s\n" "$entry_dir"
        ((i++))
    done

    echo "──────────────────────────────────────────"
    echo ""

    # Proposer d'enregistrer
    if command -v fzf &> /dev/null; then
        echo "Selection des projets a enregistrer (TAB: toggle, ENTER: valider):"
        local selected=$(printf '%s\n' "${found[@]}" | \
            awk -F'|' '{printf "%-20s [%s] %s\n", $2, $3, $1}' | \
            fzf --multi --header="Projets a enregistrer" --prompt="Select > ")

        [[ -z "$selected" ]] && echo "Aucun projet selectionne." && return 0

        echo ""
        while IFS= read -r line; do
            local name=$(echo "$line" | awk '{print $1}')
            local path=$(echo "$line" | awk '{print $NF}')
            proj_add "$name" "$path"
        done <<< "$selected"
    else
        echo -n "Enregistrer tous ces projets? [y/N] "
        read -r confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            for entry in "${found[@]}"; do
                local dir=$(echo "$entry" | cut -d'|' -f1)
                local name=$(echo "$entry" | cut -d'|' -f2)
                proj_add "$name" "$dir"
            done
        fi
    fi
}

# Auto-enregistre les projets avec fichier .proj
proj_auto_register() {
    local scan_dir="${1:-${WORK_DIR:-$HOME/projects}}"
    local depth="${2:-3}"

    echo "Recherche des fichiers .proj dans $scan_dir..."

    # Creer le dossier config si necessaire
    local registry_dir="${PROJ_REGISTRY_FILE:h}"
    [[ ! -d "$registry_dir" ]] && /bin/mkdir -p "$registry_dir"

    local count=0
    local proj_dir proj_name
    while IFS= read -r proj_file; do
        proj_dir="${proj_file:h}"
        proj_name="${proj_dir:t}"

        # Verifier si deja enregistre
        if [[ -f "$PROJ_REGISTRY_FILE" ]] && grep -q "\"$proj_dir\"" "$PROJ_REGISTRY_FILE" 2>/dev/null; then
            continue
        fi

        # Lire le nom depuis le fichier .proj si defini
        local custom_name
        custom_name=$(_proj_get_value "$proj_file" "name")
        [[ -n "$custom_name" ]] && proj_name="$custom_name"

        echo "  + $proj_name ($proj_dir)"
        echo "${proj_name}: \"$proj_dir\"" >> "$PROJ_REGISTRY_FILE"
        ((count++))
    done < <(find "$scan_dir" -maxdepth "$depth" -name ".proj" -o -name ".project.yml" 2>/dev/null)

    echo ""
    echo "$count projet(s) enregistre(s)."
}

# Aide
proj_help() {
    cat << 'EOF'
Project Switcher - Changement de contexte complet

Usage:
  proj [name|path]       Charge un projet (interactif sans arg)
  proj --add [name]      Enregistre le dossier courant
  proj --list            Liste les projets enregistres
  proj --remove <name>   Supprime un projet du registre
  proj --init            Cree un fichier .proj dans le dossier courant
  proj --scan [dir]      Scanne et propose des projets a enregistrer
  proj --auto [dir]      Auto-enregistre les projets avec .proj

Fichier .proj:
  name: my-project       Nom du projet (optionnel)
  kube_context: ctx      Change le contexte kubectl
  node_version: 18       Change la version Node (nvm)
  tmux_session: name     Suggere une session tmux
  env_file: .env.local   Charge un fichier d'environnement
  post_cmd: "cmd"        Execute une commande apres chargement

Registre: ~/.config/zsh_env/projects.yml
EOF
}
