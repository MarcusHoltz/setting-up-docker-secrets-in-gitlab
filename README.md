# Homelab Guide to Setting up Docker Secrets with GitLab


![Setting up Docker Secrets, dont let them be exposed](https://raw.githubusercontent.com/MarcusHoltz/marcusholtz.github.io/main/assets/img/header/header--docker--using-docker-secrets-with-gitlab.jpg)


If you're running GitLab in Docker, you've probably stored your root password in an `.env` file. This works, but anyone inside the container or with Docker access can see your credentials in plain text.

This repository was made to help you set up GitLab Omnibus with Docker Secrets stored **outside** of an `.env` file or in `Gitlab.rb`.

You can find the article that goes along with this repository at:

[blog.holtzweb.com/posts/docker-secrets-with-gitlab-omnibus](https://blog.holtzweb.com/posts/docker-secrets-with-gitlab-omnibus)


* * *

## Quick Start

Copy the files and follow the steps in each example below:

- [0-install-docker](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/0-install-docker)

- [1-basic-env](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/1-basic-env)

- [2-docker-secrets](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/2-docker-secrets)

- [3-secrets-in-gitlab.rb](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/3-secrets-in-gitlab.rb)


* * *

## Requirements

Be sure you have Docker and the compose plugin installed. If not, I have included a step [0-install-docker](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/0-install-docker).

This script is for a fresh Debian LXC to setup a new user, docker, some additional software.


* * *

## Each Folder Builds on Previous Example

This repository contains three folders, each demonstrating a different approach. We will be going through each one, in order. Every folder will require edits to run.


* * *

### Example 1). Basic .env Setup

**Folder:** [1-basic-env](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/1-basic-env)

This is the insecure method. Everything, including your password, lives in the `.env` file and gets loaded into the container environment. The `docker-compose.yml` contains all the GitLab configuration inline using `GITLAB_OMNIBUS_CONFIG`.


* * *

### Example 2). Docker Secrets

**Folder:** [2-docker-secrets](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/2-docker-secrets)

Your password moves to `./secrets/gitlab_root_password.txt`. Docker mounts it securely at `/run/secrets/` inside the container, where GitLab reads it using Ruby's `File.read()`. The password never appears in environment variables.

> The password is still stored in plain text on the host filesystem, be sure you've restrcted it accordingly.


* * *

### Example 3). External Configuration File

**Folder:** [3-secrets-in-gitlab.rb](https://github.com/MarcusHoltz/setting-up-docker-secrets-in-gitlab/tree/main/3-secrets-in-gitlab.rb)

Extending Docker Secrets by moving all GitLab configuration out of `docker-compose.yml` into the `gitlab-config.rb` file. Your `.env` file expands to include all the tuning parameters, making everything configurable without touching Ruby or YAML files after initial setup.


* * *

## Complete

Once complete you can continue to the second half of this project, [GitLab Omnibus with Runner and TLS](#).
