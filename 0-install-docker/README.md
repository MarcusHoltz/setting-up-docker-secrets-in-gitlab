# Part 0: Install Docker

Before we begin, you must have Docker and the compose plugin installed.

I have included [0_create_user_install_docker.sh](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/blob/main/0-install-docker/0_create_user_install_docker.sh) to install Docker and setup a new user.

* * *

## 0_create_user_install_docker.sh details

This script is for a Debian LXC - for quick setup of:

- Creates user (if doesnt already exist)

- Installs Docker and plugins

- Configures .bashrc with history and shortcuts

- Installs Tmux and assorted tools (lazydocker)

- Places the 0_create_user_install_docker.sh in home directory of new user


* * *

## 0_create_user_install_docker.sh script

For ease of use, the `0_create_user_install_docker.sh` script includes everything you need to run docker under a new user on a Debian LXC.

There are some configuration changes that can be set, namely:

- `USERNAME`

- `PASSWORD`

- `GROUP`

- `DEFAULT_DEBIAN_CODENAME`

* * *

> Please see the explanations included in the script:

* * *

```bash
# ==============================================================================
# SCRIPT: New User & System Bootstrap
# DESCRIPTION:
#   This script automates the setup of a new Debian/Ubuntu environment.
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
```

* * *

## Moving to the Next Part

When you have Docker and compose plugin installed, you may continue to the next part - [1-basic-env](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/1-basic-env).

