stopcorespotlightd() {
    while true; do
        sleep 1
        if pgrep -x "corespotlightd" > /dev/null; then
              killall -ABRT corespotlightd
        fi
    done
}
stopcorespotlightd > /dev/null &
