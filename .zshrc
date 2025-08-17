# ----- SOCKS Proxy complex function -----
# Main func imported (chrome_socks5) starts SSH SOCKS5 tunnel and launches Chrome with proxying via tunnel.
source ~/.zsh_functions/chrome.zsh

# ----- SOCKS5 Proxy aliases -----
alias socks5_tunnel="ssh -D 1080 -C -N user@site.com"
alias proxy_enable="networksetup -setsocksfirewallproxy "Wi-Fi" 127.0.0.1 1080 && networksetup -setsocksfirewallproxystate Wi-Fi on"
alias proxy_disable="networksetup -setsocksfirewallproxystate Wi-Fi off"
alias proxy="proxy_enable && socks5_tunnel"
alias proxy_chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --proxy-server=socks5://127.0.0.1:1080 http://2ip.ru"
