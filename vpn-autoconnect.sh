# source this file in your .zshrc and export VPN_NAME
# export VPN_NAME="<your vpn service name>"

vpn-status() { networksetup -showpppoestatus "$VPN_NAME" }
vpn-connected() { [ $(vpn-status) = 'connected' ] }
vpn-disconnected() { [ $(vpn-status) = 'disconnected' ] }
vpn-hup() { tail -n10 /var/log/ppp.log | grep -q '\[DISCONNECT\]' }

vpn-connect() { networksetup -connectpppoeservice "$VPN_NAME" }
vpn-disconnect() { networksetup -disconnectpppoeservice "$VPN_NAME" }
vpn-log() { echo "$(date -R): $@" }

vpn-autoconnect() {
    prev_state='undefined'
    while true; do
        if vpn-disconnected && vpn-hup; then
            state='idle'
        else
            state='watching'
        fi

        if [ "$prev_state" != "$state" ]; then
            vpn-log $state
            prev_state=$state
        fi

        if [ "$state" = "watching" ] && vpn-disconnected; then
            vpn-log 'reconnecting...'
            vpn-connect
        fi

        sleep 2
    done
}

alias vpns=vpn-status
alias vpnc=vpn-connect
alias vpnd=vpn-disconnect
alias vpna=vpn-autoconnect
