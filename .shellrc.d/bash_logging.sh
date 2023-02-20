#!/bin/bash
bash_logging() {
    local default_color msg_severity msg_severity_color msg_content msg_content_color allowed_severity
    local msg_enrich
    default_color='\033[0m'
    msg_severity=$(echo "$1" | tr "[[:lower:]]" "[[:upper:]]")
    msg_severity="${msg_severity:-DEBUG}"
    LOGGING_ALLOWED_SEVERITY="${LOGGING_ALLOWED_SEVERITY:-DEBUG}"
    allowed_severity=$(echo "$LOGGING_ALLOWED_SEVERITY" | tr "[[:upper:]]" "[[:lower:]]")
    case $msg_severity in
    DEBUG)
        if [[ ! -z $allowed_severity && $allowed_severity != "debug" ]]; then
            return 0
        fi
        msg_severity_color="\033[0;36m"
        msg_content_color="\033[1;36m"
        ;;
    INFO)
        if [[ ! -z $allowed_severity && $allowed_severity != "debug" && $allowed_severity != "info" ]]; then
            return 0
        fi
        msg_severity_color="\033[0;32m"
        msg_content_color="\033[1;32m"
        ;;
    WARN)
        if [[ ! -z $allowed_severity && $allowed_severity != "debug" && $allowed_severity != "info" && \
        $allowed_severity != "warn" ]]; then
            return 0
        fi
        msg_severity_color="\033[0;33m"
        msg_content_color="\033[1;33m"
        ;;
    ERROR)
        if [[ ! -z $allowed_severity && $allowed_severity != "debug" && $allowed_severity != "info" && \
        $allowed_severity != "warn" && $allowed_severity != "error" ]]; then
            return 0
        fi
        msg_severity_color="\033[1;31m"
        msg_content_color="\033[1;91m"
        ;;
    *)
        msg_severity_color="\033[0;31m"
        msg_content_color="\033[1;31m"
        echo -e """${msg_severity_color}ERROR: \"bash_logging\" failed.
        ${msg_content_color}Allowed parameters: \"DEBUG\", \"INFO\", \"WARN\", \"ERROR\".
        \"msg_severity\" was set to: \"$msg_severity\".${default_color}""" >&2
        return 1
        ;;
    esac
    msg_content="$2"
    msg_enrich="${msg_severity_color}$(date -u "+%d.%m.%Y %H:%M:%S %Z") $msg_severity:${msg_content_color} $msg_content ${default_color}"
    if [[ "$msg_severity" == "ERROR" ]]; then
        echo -e "$msg_enrich" >&2
    else
        echo -e "$msg_enrich"
    fi
}
