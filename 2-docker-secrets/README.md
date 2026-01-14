# Part 2: Separate Docker Secrets from the Env Files

**What changes**: Remove the password from .env and create a secrets file.


* * *

## Env File

As you can see we no longer have our gitlab root password in this file.

But you will still need to edit `GITLAB_HOST_IP` to match your Docker host you're running the compose file on.

```ini

# ============================================================================
# GITLAB ACCESS
# ============================================================================

# Hostname for GitLab - use your server's IP
GITLAB_HOST_IP=192.168.1.55

# Port to access GitLab web interface on your host machine
GITLAB_PORT=80

# SSH port for Git operations (git clone, push, pull via SSH)
GITLAB_SSH_PORT=2222

# ============================================================================
# BACKUP CONFIGURATION
# ============================================================================

# Path on host machine where GitLab backups will be stored
BACKUP_PATH=/mnt/backups/borg/gitlab


```

Where is our password? SHHHHHH. Secret.


* * *

## Secrets Folder

A secrets folder allows us to set fine grain permissions ontop an area where we want to keep data safe, and then access only directly from Docker's secrets.

```
.
|-- .env
|-- docker-compose.yml
`-- secrets
    `-- gitlab_root_password.txt
```

And there's our secret. In the `./secrets` folder inside the `gitlab_root_password.txt` file.

```bash
$ cat ./secrets/gitlab_root_password.txt 
HEYOUchangeThisPassword
```

Amazing.



* * *

## Changes Made to Support a Secret File

We were able to do this because we made some changes in the `docker-compose.yml` to support this new secrets file.


* * *

### Step 1: Docker Secrets File


First step to get the secret into the container is to tell your docker compose project what file you want to use, and what to call this secret. We'll call our secret `gitlab_root_password`

```yaml
secrets:
  gitlab_root_password:
    file: ./secrets/gitlab_root_password.txt
```


* * *

### Step 2: Put the secret inside the container

The second step is to mount the secret we named in our compose file inside our container. Docker does this by mounting it as a file inside container at: `/run/secrets/` (the location is automatically chosen by Docker)

```yaml
    secrets:
      - gitlab_root_password
```


* * *

### Step 3: Put the secret into our config

Docker uses yaml for configuration, but GitLab uses Ruby.

So you need to be sure you're putting your secret in correctly.

We're just using a docker compose file, so we have to place the config in this file.

The new addition will read secrets from mounted files via File.read() into the Omnibus config, and then removing any extra lines:

```yaml
      GITLAB_OMNIBUS_CONFIG: |
        gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab_root_password').gsub("\n", "")
```


* * *

## Container Env Var from Docker with Secrets File

Now that we have a docker secret we dont see our secret inside the container anymore

Let's take a look...


![Docker secrets file loaded](https://raw.githubusercontent.com/MarcusHoltz/marcusholtz.github.io/main/assets/img/posts/docker_secrets-2.png)



* * *

## Moving to the Last Part, Secrets in gitlab.rb

When you have seen how to load secrets as files into the container, you may continue to the next part - [3-secrets-in-gitlab.rb](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/3-secrets-in-gitlab.rb).


