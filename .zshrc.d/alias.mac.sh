autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

alias mac_dns_cache_cleaner='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'