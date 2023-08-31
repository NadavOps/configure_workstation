autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

alias mac_dns_cache_cleaner='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias mac_xcode_install='xcode-select --install'
alias mac_show_route_ipv4='netstat -rn -f inet'
alias mac_show_ports='netstat -anvp tcp | awk "NR<3 || /LISTEN/"'
