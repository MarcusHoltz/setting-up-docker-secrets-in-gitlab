# Part 3: Secrets in the gitlab.rb

Your docker-compose file can be cumbersome to maintain without adding other software's configuration to it.

We should put the `GITLAB_OMNIBUS_CONFIG` into it's own file.

Luckily there's a file made just for that, `gitlab.rb`

This will additionally allow us to put the rest of the values we saw in the docker-compose file into our .env file and never mess with the `gitlab.rb` after it's been initialy edited. 

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

* * *

## gitlab.rb

The new file is the gitlab.rb. We're using that to take the GitLab config out of docker-compose.

The config is packed full of comments to help explain what each part does, but you dont have to change a thing!


* * *

### What does this look like now

Now that we have a docker secret we dont see our secret inside the container and we're not using docker compose to manipulate the docker secret, we're doing it with our gitlab.rb 

Let's take a look...

![Docker secrets loaded using our gitlab.rb](https://raw.githubusercontent.com/MarcusHoltz/marcusholtz.github.io/main/assets/img/posts/docker_secrets-3.png)

Great job!!


* * *

## Complete

You made sure to keep a password out of your working enviornment. Well done.


* * *

### Next Steps

Once complete you can continue to the second half of this project, [GitLab Omnibus with Runner and TLS](https://github.com/MarcusHoltz/docker-gitlab-runner).
