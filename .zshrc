# ----- SOCKS5 Proxy -----
source ~/.zsh_functions/chrome.zsh  		# Functions for launching Crome with SOCKS5 proxy. Main func imported: chrome_socks5.
alias socks5_tunnel="sh ~/sh/socks5_tunnel.sh"	# Make tunnel  
alias proxy_enable="sh ~/sh/proxy_enable.sh"	# Proxy on
alias proxy_disable="sh ~/sh/proxy_disable.sh"	# Proxy off
alias proxy="proxy_enable && socks5_tunnel"
alias proxy_chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --proxy-server="socks5://127.0.0.1:1080" http://2ip.ru
