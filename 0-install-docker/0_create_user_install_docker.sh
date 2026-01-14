#!/bin/bash

# ==============================================================================
# SCRIPT: New User & System Bootstrap
# DESCRIPTION:
#   This script automates the setup of a new Debian/Ubuntu environment.
#   It performs two phases:
#     1. Root Phase: Installs Docker/Git/Curl. Checks if the target user exists.
#        - If User Missing: Creates user, sets password, grants sudo/docker.
#        - If User Exists: Skips creation, but ADDS them to sudo/docker groups.
#     2. User Phase: Switches to user to configure .bashrc, Tmux, and tools.
#
# USAGE:
#   1. Open the "CONFIGURATION" section below.
#   2. Edit the USERNAME, PASSWORD, and TIMEZONE variables as needed.
#   3. Run as root: sudo ./0_create_user_install_docker.sh
# ==============================================================================

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# --- Target User Details ---
# If this user exists, we will just install Docker and configure their shell.
# If this user does NOT exist, we will create them using the PASSWORD below.
USERNAME="john"
PASSWORD="myuserpassword"
GROUP="john"
SHELL="/bin/bash"
FULL_NAME="John Hamster"

# --- System Preferences ---
# Timezone used for the Tmux status bar clock
TIMEZONE="America/Denver"

# Default fallback for Debian version if detection fails (e.g., for MX Linux/Parrot)
# As of 2026, 'trixie' is Debian 13 (Stable).
DEFAULT_DEBIAN_CODENAME="trixie"

# --- User Environment Settings (.bashrc) ---
# Skin for Midnight Commander (mc)--
MC_SKIN="nicedark"

# Bash History Settings
HIST_SIZE="10000"
HIST_FILE_SIZE="20000"

# ==============================================================================
# END CONFIGURATION
# ==============================================================================

# 1. Universal OS Detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_CODENAME=$VERSION_CODENAME

    # Fallback for systems that don't report a standard codename
    if [ -z "$OS_CODENAME" ] || [ "$OS_ID" = "mx" ] || [ "$OS_ID" = "parrot" ]; then
        OS_CODENAME="$DEFAULT_DEBIAN_CODENAME"
    fi

    # Normalize ID for Docker URLs (Ubuntu vs Debian)
    if [[ "$ID_LIKE" == *"ubuntu"* ]] || [ "$ID" = "ubuntu" ]; then
        DOCKER_REPO_DISTRO="ubuntu"
        # If ubuntu codename missing, default to a recent LTS (adjusted for context)
        [ -z "$OS_CODENAME" ] && OS_CODENAME="noble"
    else
        DOCKER_REPO_DISTRO="debian"
        if [ -z "$OS_CODENAME" ]; then OS_CODENAME="$DEFAULT_DEBIAN_CODENAME"; fi
    fi
else
    # Deep Fallback
    OS_ID="debian"
    OS_CODENAME="$DEFAULT_DEBIAN_CODENAME"
    DOCKER_REPO_DISTRO="debian"
fi

check_user() {
    if [ "$(whoami)" = "$USERNAME" ]; then
        return 0
    else
        return 1
    fi
}

# --- MAIN LOGIC ---

if check_user; then
    # ==============================================================================
    # PHASE 2: USER SETUP (Running as target user)
    # ==============================================================================
    echo "Phase 2: Running setup for user '$USERNAME' on $OS_ID ($OS_CODENAME)..."

    BASHRC="/home/$USERNAME/.bashrc"

    # Check if we already added configs to avoid duplication
    if ! grep -q "MC_SKIN" "$BASHRC"; then
        echo -e "\nexport MC_SKIN=$MC_SKIN\n" >> "$BASHRC"
        echo -e "export PROMPT_COMMAND='history -a'" >> "$BASHRC"
        echo "HISTSIZE=$HIST_SIZE" >> "$BASHRC"
        echo "HISTFILESIZE=$HIST_FILE_SIZE" >> "$BASHRC"
        echo -e '\nremovealldocker() {\n  docker stop $(docker ps -a -q) 2>/dev/null\n  docker rm $(docker ps -a -q) 2>/dev/null\n}' >> "$BASHRC"
        echo -e '\nstartupdocker() {\n  docker compose up --build -d && echo waiting for containers to come up... && while docker ps | grep "health: starting" > /dev/null; do sleep 1; done\n}' >> "$BASHRC"
    fi

    # Install My Personal I-Like-To-Use-Often Tools
    if command -v curl &>/dev/null; then
       # echo "Installing Superfile..."
       # sudo bash -c "$(curl -sL https://superfile.dev/install.sh)"

        echo "Installing Lazydocker..."
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    fi

    # TMUX Setup
    echo -e "\nSetting up Tmux and Friends..."
    sudo apt update
    sudo apt install -y tmux git xsel

    if [ ! -d ~/.tmux/plugins/tpm ]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi

    # Note: We use unquoted EOF here to allow variable expansion for $TIMEZONE
    cat > ~/.tmux.conf << EOF
set -g mouse on
set -g status-right '#(TZ="$TIMEZONE" date +%%H:%%M:%%S)'
set -g history-limit 30000
set-option -g status-bg colour0
set-option -g status-fg colour7
bind-key c new-window -c "#{pane_current_path}"
bind-key % split-window -h -c "#{pane_current_path}"
bind-key '"' split-window -v -c "#{pane_current_path}"
setw -g aggressive-resize on
set-option -g repeat-time 200
bind r {
copy-mode
command-prompt -i -p "(search up)" "send-keys -X search-backward-incremental '%%%'"
}
setw -g alternate-screen on
set -s escape-time 50
set -g base-index 1
setw -g pane-base-index 1
set-window-option -g automatic-rename on
setw -g window-status-current-format "|#I:#W|"
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-resurrect'
run '~/.tmux/plugins/tpm/tpm'
EOF
    tmux source-file ~/.tmux.conf > /dev/null 2>&1

    # Banner
    echo -e "\n################################################################"
    echo -e "               TMUX PLUGIN INSTALLATION REQUIRED"
    echo -e "################################################################"
    echo -e " The setup is almost done, but you must manually install plugins."
    echo -e " PERFORM THESE STEPS AFTER EXITING AND LOGGING IN AS: $USERNAME"
    echo -e " 1. Log out of root (or reboot)."
    echo -e " 2. Log in as user '$USERNAME'."
    echo -e " 3. Type 'tmux' to enter Tmux."
    echo -e " 4. Press 'Ctrl + b' and release it."
    echo -e " 5. Press 'I' (Capital 'i' -> Shift + i) within 3 seconds."
    echo -e " 6. Wait a few seconds as the plugins install."
    echo -e " 7. You may now quit tmux, type 'exit' or hit 'Ctrl + b' and then 'd'."
    echo -e "################################################################\n"

    echo -e "SUCCESS! Setup complete."
    echo -e "Please Reboot or Log out/in."

else
    # ==============================================================================
    # PHASE 1: ROOT SETUP (Running as root/sudo)
    # ==============================================================================

    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: Phase 1 must be run as root. Try 'sudo $0'"
        exit 1
    fi

    echo "Phase 1: System Config ($OS_ID detected)..."

    # 1. Update & Install Critical Tools
    apt update
    if ! apt install -y sudo curl git gnupg ca-certificates; then
        echo "CRITICAL ERROR: Failed to install core tools. Exiting."
        exit 1
    fi

    # 2. Docker Installation (Always run this)
    apt install -y apt-transport-https software-properties-common || true

    # Universal Docker Installation
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker for $DOCKER_REPO_DISTRO ($OS_CODENAME)..."
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL "https://download.docker.com/linux/$DOCKER_REPO_DISTRO/gpg" -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DOCKER_REPO_DISTRO $OS_CODENAME stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

        apt update
        apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    # 3. Optional Tools
    apt install -y mc spice-vdagent qemu-guest-agent iftop || echo "Warning: Optional tools skipped."

    # 4. User Handling (Smart Logic)
    if id "$USERNAME" &>/dev/null; then
        echo "User '$USERNAME' already exists. Skipping creation/password reset."
    else
        echo "Creating user '$USERNAME'..."
        if ! getent group "$GROUP" > /dev/null 2>&1; then
            groupadd "$GROUP"
        fi

        # Determine shell path
        if [ -x "/bin/bash" ]; then USERSHELL="/bin/bash"; else USERSHELL="/usr/bin/bash"; fi

        useradd -m -s "$USERSHELL" -c "$FULL_NAME" -g "$GROUP" "$USERNAME"
        # Only set password for NEW users
        echo "$USERNAME:$PASSWORD" | chpasswd
    fi

    # 5. Group Enforcement (Run for BOTH new and existing users)
    echo "Updating groups for '$USERNAME'..."
    usermod -aG sudo "$USERNAME" 2>/dev/null || usermod -aG wheel "$USERNAME" 2>/dev/null
    usermod -aG docker "$USERNAME" 2>/dev/null || true

    # Ensure passwordless sudo (Optional, convenient for setup)
    mkdir -p /etc/sudoers.d
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$USERNAME > /dev/null
    chmod 0440 /etc/sudoers.d/$USERNAME

    # 6. LXC/Container Fixes
    if command -v ping &>/dev/null; then
        chmod u+s "$(command -v ping)" 2>/dev/null || true
    fi

    # 7. Copy & Handoff
    SCRIPT_NAME=$(basename "$0")
    DEST_SCRIPT="/home/$USERNAME/$SCRIPT_NAME"

    # We only copy the script if it isn't already there
    if [ "$(realpath "$0")" != "$(realpath "$DEST_SCRIPT" 2>/dev/null)" ]; then
        cp "$0" "$DEST_SCRIPT"
        chown "$USERNAME":"$GROUP" "$DEST_SCRIPT"
        chmod +x "$DEST_SCRIPT"
    fi

    echo "Switching to user '$USERNAME'..."
    su - "$USERNAME" -c "$DEST_SCRIPT"
    echo "Done."
fi
