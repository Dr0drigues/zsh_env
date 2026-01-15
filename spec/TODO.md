# Tests ShellSpec - Checklist

## Installation

- [ ] `install.sh` s'exécute sans erreur (mode --default)
- [ ] `install.sh` crée le fichier `config.zsh`
- [ ] `install.sh` modifie le `.zshrc` avec ZSH_ENV_DIR
- [ ] `uninstall.sh` restaure le `.zshrc`

## Chargement

- [ ] `rc.zsh` se source sans erreur
- [ ] Les modules désactivés ne sont pas chargés
- [ ] Les fichiers manquants affichent un warning

## NVM

- [ ] Lazy loading : `node` charge NVM au premier appel
- [ ] Lazy loading : `npm` charge NVM au premier appel
- [ ] Mode normal : NVM chargé au démarrage
- [ ] Auto-switch : détection du `.nvmrc`

## Commandes zsh-env-*

- [ ] `zsh-env-list` affiche les outils installés
- [ ] `zsh-env-status` affiche la configuration
- [ ] `zsh-env-doctor` retourne 0 si tout est OK
- [ ] `zsh-env-help` affiche l'aide
- [ ] `zsh-env-theme list` liste les thèmes
- [ ] `zsh-env-theme <nom>` applique un thème

## Completions

- [ ] `zsh-env-completions` se termine sans erreur
- [ ] `zsh-env-completion-add` ajoute une entrée dans `completions.zsh`
- [ ] `zsh-env-completion-remove` supprime une entrée

## Fonctions utilitaires

- [ ] `mkcd` crée un dossier et y entre
- [ ] `extract` décompresse une archive .tar.gz
- [ ] `extract` décompresse une archive .zip
- [ ] `gr` va à la racine du repo git

## Scripts GitLab

- [ ] `trigger-jobs.sh --help` affiche l'aide
- [ ] `trigger-jobs.sh` échoue sans GITLAB_TOKEN
- [ ] `clone-projects.sh --help` affiche l'aide
