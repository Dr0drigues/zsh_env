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

## Plugins

- [ ] `plugins.zsh` se source sans erreur
- [ ] `ZSH_ENV_PLUGINS=()` vide ne cause pas d'erreur
- [ ] `zsh-plugin-list` s'exécute sans erreur
- [ ] `zsh-plugin-install` sans argument affiche l'usage
- [ ] `zsh-plugin-remove` sans argument affiche l'usage
- [ ] `_zsh_env_plugin_name` extrait le nom depuis `owner/repo`
- [ ] `_zsh_env_plugin_name` extrait le nom depuis une URL complète
- [ ] `_zsh_env_plugin_url` génère l'URL GitHub depuis `owner/repo`
- [ ] `_zsh_env_plugin_url` préfixe avec `ZSH_ENV_PLUGINS_ORG` si pas de `/`
- [ ] `_zsh_env_plugin_url` retourne l'URL telle quelle si `https://`
- [ ] `_zsh_env_find_plugin_file` détecte `*.plugin.zsh`
- [ ] `_zsh_env_find_plugin_file` détecte `init.zsh`
- [ ] `_zsh_env_find_plugin_file` détecte `<nom>.zsh`

## Scripts GitLab

- [ ] `trigger-jobs.sh --help` affiche l'aide
- [ ] `trigger-jobs.sh` échoue sans GITLAB_TOKEN
- [ ] `clone-projects.sh --help` affiche l'aide
