# Se déplacer à la racine du dépôt Git actuel
gr() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$root" ]; then
    echo "Pas dans un dépôt Git."
  else
    cd "$root"
  fi
}