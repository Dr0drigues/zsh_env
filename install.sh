#!/bin/bash
# ==============================================================================
# Script : install.sh
# Description : Bootstrapping de l'environnement de développement (Zsh, Tools)
# Auteur : Concepteur & Développeur Sénior
# Support : MacOS (Homebrew), Debian/Ubuntu (apt), Fedora (dnf)
# ==============================================================================

# --- Couleurs & UI ---
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
NC=$'\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Détection OS & Package Manager ---
OS="$(uname -s)"
PKG_MANAGER=""
INSTALL_CMD=""

detect_platform() {
    case "${OS}" in
        Linux*)
            if [ -f /etc/debian_version ]; then
                PKG_MANAGER="apt"
                INSTALL_CMD="sudo apt-get install -y"
                log_info "Système détecté : Linux (Debian/Ubuntu)"
            elif [ -f /etc/fedora-release ]; then
                PKG_MANAGER="dnf"
                INSTALL_CMD="sudo dnf install -y"
                log_info "Système détecté : Linux (Fedora)"
            else
                log_error "Distribution Linux non supportée automatiquement."
                exit 1
            fi
            ;;
        Darwin*)
            PKG_MANAGER="brew"
            INSTALL_CMD="brew install"
            log_info "Système détecté : MacOS"
            
            # Vérification présence Homebrew
            if ! command -v brew &> /dev/null; then
                log_warn "Homebrew n'est pas installé. Installation en cours..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            ;;
        *)
            log_error "OS inconnu : ${OS}"
            exit 1
            ;;
    esac
}

# --- Fonction d'installation générique ---
install_tool() {
    local tool_name=$1      # Nom pour l'affichage
    local brew_pkg=$2       # Nom du paquet Brew
    local apt_pkg=$3        # Nom du paquet Apt
    local dnf_pkg=$4        # Nom du paquet Dnf (souvent idem apt)
    
    # Si le binaire existe déjà, on skip (sauf demande de force update, mais restons simple)
    if command -v "$tool_name" &> /dev/null; then
        log_success "$tool_name est déjà installé."
        return
    fi

    echo -ne "${YELLOW}Installation de $tool_name...${NC} "
    
    local pkg=""
    case "$PKG_MANAGER" in
        brew) pkg="$brew_pkg" ;;
        apt)  pkg="$apt_pkg" ;;
        dnf)  pkg="$dnf_pkg" ;;
    esac

    # Si le nom du paquet est vide pour cet OS, on tente une install manuelle ou on skip
    if [ -z "$pkg" ]; then
        echo ""
        log_warn "Pas de paquet connu pour $tool_name sur $PKG_MANAGER."
        return
    fi

    # Exécution de l'installation (rediriger stderr vers stdout pour le log si besoin)
    if $INSTALL_CMD "$pkg" &> /dev/null; then
        echo -e "${GREEN}Fait.${NC}"
    else
        echo -e "${RED}Échec.${NC}"
        log_error "Impossible d'installer $pkg"
    fi
}

# --- Main Script ---

echo -e "${BOLD}=== Initialisation de l'environnement de Dev ===${NC}\n"

detect_platform

# Mise à jour des index de paquets (Linux uniquement)
if [ "$PKG_MANAGER" == "apt" ]; then
    log_info "Mise à jour des dépôts apt..."
    sudo apt-get update -qq
fi

echo ""
log_info "Vérification des outils core..."

# Liste des outils : Nom_Binaire | Paquet_Brew | Paquet_Apt | Paquet_Dnf

# 1. Shell & Utils de base
install_tool "git"      "git"       "git"       "git"
install_tool "curl"     "curl"      "curl"      "curl"
install_tool "zsh"      "zsh"       "zsh"       "zsh"
install_tool "jq"       "jq"        "jq"        "jq"

# 2. Modern Tools (La demande utilisateur)
install_tool "eza"      "eza"       "eza"       "eza"  # Sur Debian/Ubuntu récent, sinon voir cargo
install_tool "starship" "starship"  ""          ""     # Souvent absent des vieux repos apt
install_tool "zoxide"   "zoxide"    "zoxide"    "zoxide"
install_tool "fzf"      "fzf"       "fzf"       "fzf"
install_tool "bat"      "bat"       "bat"       "bat"  # "cat" avec des ailes

# --- Installation manuelle pour les outils souvent absents d'APT/DNF ---

# Starship (Script officiel si non trouvé via gestionnaire)
if ! command -v starship &> /dev/null; then
    log_info "Installation manuelle de Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Configuration Finale
echo ""
log_info "Configuration..."

# Vérification du dossier scripts
SCRIPTS_DIR="$HOME/scripts"
if [ ! -d "$SCRIPTS_DIR" ]; then
    mkdir -p "$SCRIPTS_DIR"
    log_success "Dossier $SCRIPTS_DIR créé."
fi

# Rappel pour l'utilisateur
echo -e "\n${BOLD}=== Installation Terminée ===${NC}"
echo -e "Pour finaliser l'installation, assurez-vous que votre ${BOLD}.zshrc${NC} source bien le fichier rc.zsh :"
echo -e "${BLUE}source \"$PWD/rc.zsh\"${NC}"
echo ""
echo -e "Redémarrez votre terminal ou lancez : ${BOLD}zsh${NC}"