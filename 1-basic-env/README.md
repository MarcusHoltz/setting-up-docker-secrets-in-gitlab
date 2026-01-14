# Part 1: Docker Env Files

This is the insecure method. Everything, including your password, lives in the `.env` file and gets loaded into the container.


* * *

## 0). Be Sure You've Setup the Lab Environment

Be sure you have installed Docker and the compose plugin.

If you have not yet, please setup the lab enviornment inside 0-install-docker.


- Edit: `0_create_user_install_docker.sh`

- Run: `0_create_user_install_docker.sh`

- Review: `docker compose version`


* * *


## 1). Docker Env File in 1-basic-env

Head into the `01-basic-env` folder.

Here we have a `docker-compose.yml` file. It is super messy, we wont pay attention to it for now.

We'll take a look at the `.env` file.


* * *

The `.env` file holds all of the settings you can use inside of the `docker-compose.yml`

Docker loads the environment variables from the file into the docker compose project.

Look for the: 

- `GITLAB_HOST_IP`

- `GITLAB_ROOT_PASSWORD`


* * *

### Env File

```ini
# ============================================================================
# GITLAB ACCESS
# ============================================================================

# Hostname for GitLab - use your docker server's IP
GITLAB_HOST_IP=192.168.1.55

# Port to access GitLab web interface on your host machine
GITLAB_PORT=80

# SSH port for Git operations (git clone, push, pull via SSH)
GITLAB_SSH_PORT=2222

# ============================================================================
# GITLAB AUTHENTICATION
# ============================================================================

# Root admin password - CHANGE THIS to a strong password before deploying
GITLAB_ROOT_PASSWORD=HEYOUchangeThisPassword

# ============================================================================
# BACKUP CONFIGURATION
# ============================================================================

# Path on host machine where GitLab backups will be stored
BACKUP_PATH=/mnt/backups/borg/gitlab
```

Please change the `GITLAB_HOST_IP` to that of your Docker host you're running the compose file on, and and the `GITLAB_ROOT_PASSWORD` to that of your choice.


* * *

### Container Env Var from Docker

The `.env` file loads our `.env` file, all of it, into the container for use inside the container.

Let's take a look from the Docker perspective...


![Docker .env secrets exposed](https://raw.githubusercontent.com/MarcusHoltz/marcusholtz.github.io/main/assets/img/posts/docker_secrets-1.png)


Whoopsie. We've exposed a lot of information most of it not important, except, wait, there's a password. Oh no! Good thing someone blured that out! Phew.

Let's move on to the next example to see what we can do about that.


* * *

## Moving to the Next Part, Docker Secrets

When you have demonstrated how .env files store and move environment variables into the container, you may continue to the next part - [2-docker-secrets](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/2-docker-secrets).



