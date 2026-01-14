# ============================================================================
# GitLab Omnibus Configuration
# This file is Ruby code that gets executed by GitLab
# Please make edits in the .env file or in the ./secrets folder
# ============================================================================

# ============================================================================
# External URL - the main frontend connection - how users will access GitLab
# ============================================================================
# Note: Do NOT use '=' sign here! NO = after external_url
external_url "http://#{ENV['GITLAB_HOST_IP']}:#{ENV['GITLAB_PORT']}"

# ============================================================================
# INITIAL ROOT USER (First Boot Only)
# ============================================================================
# These credentials are ONLY used when GitLab initializes for the first time
# After first boot, changing these won't update the root account
# Ruby is reading Docker ENV + docker secrets below (must match secret name in docker)
gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab_root_password').gsub("\n", "")

# ============================================================================
# SSH CONFIGURATION
# ============================================================================
# Port advertised for Git SSH operations (git clone ssh://...)
# .to_i converts string to integer (required for port numbers)
gitlab_rails['gitlab_shell_ssh_port'] = ENV['GITLAB_SSH_PORT'].to_i

# ============================================================================
# NETWORK SECURITY
# ============================================================================
# Convert comma-separated strings to Ruby arrays
# .split(',') splits on commas, .map(&:strip) removes whitespace
gitlab_rails['monitoring_whitelist'] = ENV['MONITORING_WHITELIST'].split(',').map(&:strip)
gitlab_rails['allowed_hosts'] = ENV['ALLOWED_HOSTS'].split(',').map(&:strip)
gitlab_rails['trusted_proxies'] = ENV['TRUSTED_PROXIES'].split(',').map(&:strip)

# ============================================================================
# PUMA WEB SERVER (Homelab Optimized)
# ============================================================================
# Puma serves the Rails application
puma['worker_processes'] = ENV['PUMA_WORKER_PROCESSES'].to_i
puma['worker_timeout'] = ENV['PUMA_WORKER_TIMEOUT'].to_i
puma['listen'] = '0.0.0.0'  # Listen on all interfaces
puma['port'] = 8080          # Internal port (proxied by nginx)

# ============================================================================
# POSTGRESQL DATABASE (Homelab Optimized)
# ============================================================================
# Memory allocated for database caching
postgresql['shared_buffers'] = ENV['POSTGRESQL_SHARED_BUFFERS']

# ============================================================================
# SIDEKIQ BACKGROUND JOBS (Homelab Optimized)
# ============================================================================
# Sidekiq processes async tasks (CI/CD, emails, repo maintenance)
sidekiq['max_concurrency'] = ENV['SIDEKIQ_MAX_CONCURRENCY'].to_i
sidekiq['concurrency'] = ENV['SIDEKIQ_CONCURRENCY'].to_i

# ============================================================================
# MONITORING
# ============================================================================
# Prometheus metrics endpoint
# == 'true' converts string to boolean
prometheus_monitoring['enable'] = ENV['PROMETHEUS_ENABLED'] == 'true'

# ============================================================================
# SSL/TLS CONFIGURATION
# ============================================================================
# Let's Encrypt automatic SSL - disabled for HTTP-only setup
letsencrypt['enable'] = ENV['LETSENCRYPT_ENABLED'] == 'true'

# ============================================================================
# GITLAB PAGES
# ============================================================================
# Static site hosting feature - disabled
gitlab_pages['enable'] = ENV['GITLAB_PAGES_ENABLED'] == 'true'

# ============================================================================
# NGINX WEB SERVER (HTTP Only)
# ============================================================================
# Nginx acts as the front-end reverse proxy
nginx['enable'] = true
nginx['listen_port'] = 80              # HTTP port
nginx['listen_https'] = false          # No HTTPS listener
nginx['redirect_http_to_https'] = false # Don't force HTTPS

# ============================================================================
# GITLAB WORKHORSE
# ============================================================================
# Workhorse handles Git HTTP operations, file uploads, websockets
gitlab_workhorse['listen_network'] = 'tcp'
gitlab_workhorse['listen_addr'] = ENV['WORKHORSE_LISTEN_ADDR']
gitlab_workhorse['auth_backend'] = 'http://localhost:8080'  # Connects to Puma
gitlab_workhorse['api_limit_per_min'] = 0     # Unlimited API calls
gitlab_workhorse['api_queue_limit'] = 0       # Unlimited queue
gitlab_workhorse['api_queue_duration'] = '30s' # Request timeout

# ============================================================================
# UI DEFAULTS
# ============================================================================
# Default theme for new users
gitlab_rails['gitlab_default_theme'] = ENV['GITLAB_DEFAULT_THEME'].to_i

# Default color mode (light/dark/auto)
gitlab_rails['gitlab_default_color_mode'] = ENV['GITLAB_DEFAULT_COLOR_MODE']

# ============================================================================
# TELEMETRY
# ============================================================================
# Send usage statistics to GitLab
# != 'true' means "if NOT true, then enable" (double negative = opt-out by default)
gitlab_rails['initial_gitlab_product_usage_data'] = ENV['DISABLE_USAGE_DATA'] != 'true'
