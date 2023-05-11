autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

alias mac_dns_cache_cleaner='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias mac_xcode_install='xcode-select --install'
alias mac_route_show_ipv4='netstat -rn -f inet'