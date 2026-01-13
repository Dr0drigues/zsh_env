# Vérifie les dépendances recommandées et suggère l'installation
check_env_health() {
    local dependencies=(git eza starship fzf zoxide jq curl)
    local missing=()

    echo "\nChecking Environment Health..."
    for dep in $dependencies; do
        if ! command -v $dep &> /dev/null; then
            missing+=($dep)
            echo "$dep est manquant"
        else
            echo "$dep est installé"
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "\nOutils manquants pour une expérience optimale :"
        echo "   brew install ${missing[*]}" # ou apt install
    else
        echo "\nTout est opérationnel !"
    fi
}