# ==============================================================================
# Commandes utilitaires ZSH_ENV
# ==============================================================================

# Couleurs
_zsh_cmd_green=$'\033[0;32m'
_zsh_cmd_red=$'\033[0;31m'
_zsh_cmd_yellow=$'\033[1;33m'
_zsh_cmd_blue=$'\033[0;34m'
_zsh_cmd_cyan=$'\033[0;36m'
_zsh_cmd_bold=$'\033[1m'
_zsh_cmd_nc=$'\033[0m'

# ==============================================================================
# zsh-env-list : Lister les outils installes
# ==============================================================================
zsh-env-list() {
    echo -e "${_zsh_cmd_bold}=== Outils installes ===${_zsh_cmd_nc}\n"

    # Liste des outils a verifier
    local tools=(
        "git:Git:Gestionnaire de versions"
        "zsh:Zsh:Shell"
        "curl:cURL:Transfert de donnees"
        "jq:jq:Processeur JSON"
        "eza:eza:ls moderne"
        "starship:Starship:Prompt personnalise"
        "zoxide:Zoxide:Navigation intelligente (z)"
        "fzf:FZF:Recherche fuzzy"
        "bat:Bat:cat avec coloration"
        "nu:Nushell:Shell moderne"
        "trash:Trash:Corbeille CLI"
        "nvm:NVM:Node Version Manager"
        "sdk:SDKMAN:SDK Manager (Java, etc.)"
        "docker:Docker:Conteneurisation"
    )

    local installed=0
    local missing=0

    for tool_info in "${tools[@]}"; do
        local cmd="${tool_info%%:*}"
        local rest="${tool_info#*:}"
        local name="${rest%%:*}"
        local desc="${rest#*:}"

        if command -v "$cmd" &> /dev/null; then
            local version=""
            case "$cmd" in
                git) version=$(git --version 2>/dev/null | awk '{print $3}') ;;
                zsh) version=$ZSH_VERSION ;;
                eza) version=$(eza --version 2>/dev/null | head -1 | awk '{print $1}') ;;
                starship) version=$(starship --version 2>/dev/null | awk '{print $2}') ;;
                bat) version=$(bat --version 2>/dev/null | awk '{print $2}') ;;
                nu) version=$(nu --version 2>/dev/null) ;;
                fzf) version=$(fzf --version 2>/dev/null | awk '{print $1}') ;;
                jq) version=$(jq --version 2>/dev/null | sed 's/jq-//') ;;
                nvm) version=$(nvm --version 2>/dev/null) ;;
                sdk) version="installed" ;;
                docker) version=$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',') ;;
                *) version="" ;;
            esac
            printf "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} %-12s ${_zsh_cmd_cyan}%-10s${_zsh_cmd_nc} %s\n" "$name" "$version" "$desc"
            ((installed++))
        else
            printf "  ${_zsh_cmd_red}✗${_zsh_cmd_nc} %-12s ${_zsh_cmd_yellow}%-10s${_zsh_cmd_nc} %s\n" "$name" "manquant" "$desc"
            ((missing++))
        fi
    done

    echo ""
    echo -e "${_zsh_cmd_bold}Resume:${_zsh_cmd_nc} ${_zsh_cmd_green}$installed installes${_zsh_cmd_nc} | ${_zsh_cmd_yellow}$missing manquants${_zsh_cmd_nc}"

    if [ $missing -gt 0 ]; then
        echo -e "\nPour installer les outils manquants: ${_zsh_cmd_bold}~/.zsh_env/install.sh${_zsh_cmd_nc}"
    fi
}

# ==============================================================================
# zsh-env-completion-add : Ajouter une completion personnalisee
# ==============================================================================
zsh-env-completion-add() {
    local name="$1"
    local cmd="$2"

    if [ -z "$name" ] || [ -z "$cmd" ]; then
        echo -e "${_zsh_cmd_bold}Usage:${_zsh_cmd_nc} zsh-env-completion-add <nom> <commande>"
        echo ""
        echo -e "${_zsh_cmd_cyan}Exemples:${_zsh_cmd_nc}"
        echo "  zsh-env-completion-add bun \"bun completions\""
        echo "  zsh-env-completion-add deno \"deno completions zsh\""
        echo "  zsh-env-completion-add turbo \"turbo completion zsh\""
        echo ""
        echo -e "Les completions sont stockees dans: ${_zsh_cmd_bold}~/.zsh_env/completions.zsh${_zsh_cmd_nc}"
        return 1
    fi

    local config_file="$ZSH_ENV_DIR/completions.zsh"

    # Verifier si la completion existe deja
    if grep -q "\"$name:" "$config_file" 2>/dev/null; then
        echo -e "${_zsh_cmd_yellow}[WARN]${_zsh_cmd_nc} La completion '$name' existe deja."
        return 1
    fi

    # Ajouter la completion au fichier
    # On insère avant la parenthèse fermante
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS : sed -i nécessite une extension explicite
        sed -i '' '/^)$/i\
    "'"$name:$cmd"'"
' "$config_file"
    else
        # Linux
        sed -i '/^)$/i\    "'"$name:$cmd"'"' "$config_file"
    fi

    echo -e "${_zsh_cmd_green}[OK]${_zsh_cmd_nc} Completion '$name' ajoutee."
    echo -e "Lancez ${_zsh_cmd_bold}zsh-env-completions${_zsh_cmd_nc} pour la charger."
}

# ==============================================================================
# zsh-env-completion-remove : Supprimer une completion personnalisee
# ==============================================================================
zsh-env-completion-remove() {
    local name="$1"

    if [ -z "$name" ]; then
        echo -e "${_zsh_cmd_bold}Usage:${_zsh_cmd_nc} zsh-env-completion-remove <nom>"
        return 1
    fi

    local config_file="$ZSH_ENV_DIR/completions.zsh"

    if ! grep -q "\"$name:" "$config_file" 2>/dev/null; then
        echo -e "${_zsh_cmd_yellow}[WARN]${_zsh_cmd_nc} La completion '$name' n'existe pas."
        return 1
    fi

    # Supprimer la ligne contenant cette completion
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/\"$name:/d" "$config_file"
    else
        sed -i "/\"$name:/d" "$config_file"
    fi

    echo -e "${_zsh_cmd_green}[OK]${_zsh_cmd_nc} Completion '$name' supprimee."
}

# ==============================================================================
# zsh-env-completions : Charger les auto-completions
# ==============================================================================
zsh-env-completions() {
    echo -e "${_zsh_cmd_bold}=== Chargement des completions ===${_zsh_cmd_nc}\n"

    local loaded=0

    # Docker
    if command -v docker &> /dev/null; then
        if docker completion zsh &> /dev/null; then
            source <(docker completion zsh)
            echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} Docker"
            ((loaded++))
        fi
    fi

    # kubectl
    if command -v kubectl &> /dev/null; then
        source <(kubectl completion zsh)
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} Kubectl"
        ((loaded++))
    fi

    # helm
    if command -v helm &> /dev/null; then
        source <(helm completion zsh)
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} Helm"
        ((loaded++))
    fi

    # gh (GitHub CLI)
    if command -v gh &> /dev/null; then
        source <(gh completion -s zsh)
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} GitHub CLI"
        ((loaded++))
    fi

    # glab (GitLab CLI)
    if command -v glab &> /dev/null; then
        source <(glab completion -s zsh)
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} GitLab CLI"
        ((loaded++))
    fi

    # terraform
    if command -v terraform &> /dev/null; then
        complete -o nospace -C terraform terraform
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} Terraform"
        ((loaded++))
    fi

    # aws
    if command -v aws_completer &> /dev/null; then
        complete -C aws_completer aws
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} AWS CLI"
        ((loaded++))
    fi

    # gcloud
    if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
        source "$HOME/google-cloud-sdk/completion.zsh.inc"
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} Google Cloud SDK"
        ((loaded++))
    fi

    # npm (eval au lieu de source pour éviter l'erreur _arguments)
    if command -v npm &> /dev/null; then
        eval "$(npm completion 2>/dev/null)" 2>/dev/null
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} npm"
        ((loaded++))
    fi

    # pnpm
    if command -v pnpm &> /dev/null; then
        source <(pnpm completion zsh 2>/dev/null)
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} pnpm"
        ((loaded++))
    fi

    # rustup & cargo
    if command -v rustup &> /dev/null; then
        source <(rustup completions zsh 2>/dev/null)
        source <(rustup completions zsh cargo 2>/dev/null)
        echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} Rustup/Cargo"
        ((loaded++))
    fi

    # Completions personnalisees
    local custom_file="$ZSH_ENV_DIR/completions.zsh"
    if [ -f "$custom_file" ]; then
        source "$custom_file"

        local custom_loaded=0
        for entry in "${_ZSH_ENV_CUSTOM_COMPLETIONS[@]}"; do
            # Ignorer les lignes vides ou commentees
            [[ -z "$entry" || "$entry" == \#* ]] && continue

            local name="${entry%%:*}"
            local cmd="${entry#*:}"

            if command -v "$name" &> /dev/null; then
                # Capture la sortie de la commande puis eval avec stderr supprimé
                local comp_script
                comp_script=$($cmd 2>/dev/null)
                if [ -n "$comp_script" ]; then
                    { eval "$comp_script"; } 2>/dev/null
                    echo -e "  ${_zsh_cmd_green}✓${_zsh_cmd_nc} $name ${_zsh_cmd_cyan}(custom)${_zsh_cmd_nc}"
                    ((loaded++))
                    ((custom_loaded++))
                else
                    echo -e "  ${_zsh_cmd_red}✗${_zsh_cmd_nc} $name ${_zsh_cmd_yellow}(erreur)${_zsh_cmd_nc}"
                fi
            fi
        done

        if [ $custom_loaded -gt 0 ]; then
            echo ""
            echo -e "${_zsh_cmd_cyan}$custom_loaded completion(s) personnalisee(s)${_zsh_cmd_nc}"
        fi
    fi

    echo ""
    echo -e "${_zsh_cmd_bold}$loaded completions chargees${_zsh_cmd_nc}"

    # Recharger le systeme de completion
    autoload -Uz compinit && compinit -C
}

# ==============================================================================
# zsh-env-help : Afficher l'aide
# ==============================================================================
zsh-env-help() {
    cat << EOF
${_zsh_cmd_bold}=== Commandes ZSH_ENV ===${_zsh_cmd_nc}

${_zsh_cmd_cyan}zsh-env-list${_zsh_cmd_nc}
    Liste les outils installes et leur version

${_zsh_cmd_cyan}zsh-env-completions${_zsh_cmd_nc}
    Charge les auto-completions pour les outils disponibles

${_zsh_cmd_cyan}zsh-env-completion-add <nom> <commande>${_zsh_cmd_nc}
    Ajoute une completion personnalisee
    Ex: zsh-env-completion-add bun "bun completions"

${_zsh_cmd_cyan}zsh-env-completion-remove <nom>${_zsh_cmd_nc}
    Supprime une completion personnalisee

${_zsh_cmd_cyan}zsh-env-status${_zsh_cmd_nc}
    Affiche le statut et la configuration de zsh_env

${_zsh_cmd_cyan}zsh-env-update${_zsh_cmd_nc}
    Force la verification et mise a jour de zsh_env

${_zsh_cmd_cyan}zsh-env-help${_zsh_cmd_nc}
    Affiche cette aide

${_zsh_cmd_bold}Configuration:${_zsh_cmd_nc} ~/.zsh_env/config.zsh
${_zsh_cmd_bold}Completions:${_zsh_cmd_nc}   ~/.zsh_env/completions.zsh
${_zsh_cmd_bold}Recharger:${_zsh_cmd_nc}     ss (ou source ~/.zshrc)
EOF
}
