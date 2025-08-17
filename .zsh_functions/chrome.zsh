DEFAULT_SSH_HOST="user@site.com""
DEFAULT_SOCKS_PORT=1080
DEFAULT_WEB_PAGE="https://2ip.ru"

# ----- Locate Google Chrome.app (stable only, no beta/canary/etc. are to be searched). -----
# Return full path via stdout, or exits with 1 if not found.
find_chrome_app() {
  local app
  local possible_folders=(
    "/Applications/Google Chrome.app"
    "$HOME/Applications/Google Chrome.app"
  )

  # 1. Search via Spotlight.
  app=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'com.google.Chrome'" | head -n1)

  # 2. If not found, check possible paths.
  if [[ -z "$app" ]]; then
    for c in "${possible_folders[@]}"; do
      [[ -d "$c" ]] && app="$c" && break
    done
  fi

  # 3. Error if not found yet.

  if [[ -z "$app" ]]; then
    echo "ERR: Google Chrome.app not found" >&2
    return 1
  fi

  echo "$app"
}


# ----- Launch Chrome via SOCKS5 at specific web page. -----
# Args: $1 = socks_port, $2 = web_page
launch_chrome_with_socks_proxy() {
  local socks_port="$1"
  local web_page="$2"

  local app bin
  app="$(find_chrome_app)" || return 1
  bin="$app/Contents/MacOS/Google Chrome"

  # If bin is not executable, then exit with error.
  [[ ! -x "$bin" ]] && { echo "ERR: Chrome binary not found: $bin" >&2; return 1; }

  # Open web page with Chrome via SOCKS5 proxy.
  "$bin" --proxy-server="socks5://127.0.0.1:$socks_port" "$web_page"
}


# ----- Start SSH SOCKS5 tunnel, run Chrome, then close the tunnel at the end. -----
chrome_socks5() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF
Usage: chrome-socks5 [ssh_host] [socks_port] [web_page]

Arguments:
  ssh_host    SSH host (default: $DEFAULT_SSH_HOST)
  socks_port  Local SOCKS5 port (default: $DEFAULT_SOCKS_PORT)
  web_page    Web page to open in Chrome (default: $DEFAULT_WEB_PAGE)

Examples:
  chrome-socks5
  chrome-socks5 user@host 1081 https://check.torproject.org
EOF
    return 0
  fi

  local ssh_host="${1:-$DEFAULT_SSH_HOST}"
  local socks_port="${2:-$DEFAULT_SOCKS_PORT}"
  local web_page="${3:-$DEFAULT_WEB_PAGE}"

  echo "Using SSH $ssh_host, port $socks_port, url $web_page"

  # 1. Start SSH tunnel in background and store its PID.
  # - ExitOnForwardFailure=yes  - Exit immediately if port is not alive.
  # - ServerAliveInterval=60    - Keep-alive every 60 seconds.
  # - ServerAliveCountMax=3     - Drop in 3 minutes if not alive.
  ssh \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    -D "127.0.0.1:${socks_port}" \
    -C -N "$ssh_host" \
    >/dev/null 2>&1 &

  local SSH_PID=$!
  trap 'kill "$SSH_PID" 2>/dev/null' EXIT INT TERM

  # 2. Run Chrome foreground - wait while it's running.
  launch_chrome_with_socks_proxy "$socks_port" "$web_page"

  # 3. Teardown after Chrome finishes.
  kill "$SSH_PID" 2>/dev/null
  wait "$SSH_PID" 2>/dev/null
  trap - EXIT
}

