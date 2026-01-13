# =======================================================
# UTILITAIRES GÉNÉRAUX
# =======================================================

# Crée un dossier et rentre dedans immédiatement
# Usage: mkcd mon_dossier/sous_dossier
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Fonction wrapper pour 'trash' compatible Linux/Mac
# Permet d'utiliser la commande 'trash' partout
trash() {
  if command -v trash-put &> /dev/null; then
    # Version Linux (trash-cli)
    trash-put "$@"
  elif command -v trash &> /dev/null; then
    # Version Mac (brew) ou autre
    command trash "$@"
  else
    echo "Erreur: Aucune commande 'trash' ou 'trash-put' trouvée."
    return 1
  fi
}