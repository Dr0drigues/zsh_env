export WORK_DIR="$HOME/work"
export SCRIPTS_DIR="$ZSH_ENV_DIR/scripts"

# =======================================================
# HISTORIQUE ZSH
# =======================================================
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000

# Options d'historique
setopt EXTENDED_HISTORY          # Enregistrer le timestamp
setopt HIST_EXPIRE_DUPS_FIRST    # Supprimer les doublons en premier si limite atteinte
setopt HIST_IGNORE_DUPS          # Ignorer les commandes consecutives identiques
setopt HIST_IGNORE_SPACE         # Ignorer les commandes commencant par espace
setopt HIST_VERIFY               # Montrer la commande avant execution depuis l'historique
setopt SHARE_HISTORY             # Partager l'historique entre sessions

# SOPS/Age - Chemin vers la cle de chiffrement
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# Liste des dossiers critiques à garantir
required_dirs=(
    "$WORK_DIR"
    "$HOME/.config"
    "$SCRIPTS_DIR"
)

for dir in $required_dirs; do
    if [ ! -d "$dir" ]; then
        # On crée silencieusement le dossier manquant
        mkdir -p "$dir"
    fi
done