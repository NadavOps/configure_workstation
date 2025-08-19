autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

alias mac_dns_cache_cleaner='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias mac_xcode_install='xcode-select --install'
alias mac_show_route_ipv4='netstat -rn -f inet'
alias mac_show_ports='netstat -anvp tcp | awk "NR<3 || /LISTEN/"'

mac_caffeinate() {
    if ! command -v caffeinate > /dev/null; then echo "ERROR: caffeinate utility is not found on the system" && return 1; fi
    local timeout=${1:-3600}
	local hours=$(($timeout / 3600))
	local minutes=$((($timeout % 3600) / 60))
    local time=$(date -v+${hours}H -v+${minutes}M +"%H:%M:%S")
    echo "INFO: mac caffeinate for $timeout seconds ($hours hours and $minutes minutes- $time)"
    caffeinate -d -i -m -t $timeout
}
