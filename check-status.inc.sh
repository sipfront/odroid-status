# IMPORTANT: these two must be set after sourcing!
sf_val_path=""
sf_dir_path=""


sf_blink_pid=""

sf_shutdown() {
    echo "shutting down"
    sf_cancel_blink
    exit 0
}

sf_cancel_blink() {
    if [ "$sf_blink_pid" != "" ]; then
        kill "$sf_blink_pid" 1>/dev/null 2>/dev/null
        sf_blink_pid=""
    fi
}

sf_output_off() {
    sf_cancel_blink
    echo 0 > "$sf_val_path"
}
sf_output_on() {
    sf_cancel_blink
    echo 1 > "$sf_val_path"
}

sf_output_blink() {
    interval_on=$1
    interval_off=$2

    while true; do
        sf_output_on
        sleep "$interval_on"
        sf_output_off
        sleep "$interval_off"
    done
}

sf_blink() {
    interval_on=$1
    interval_off=$2
    if [ "$blink_pid" = "" ]; then
        sf_output_blink "$1" "$2" &
        sf_blink_pid=$!
    fi    
}

sf_init() {
    if [ -e "$sf_dir_path" ]; then
       echo "gpio pin $pin already exported..."
    else
       echo "exporting gpio pin $pin..."
        echo $pin > /sys/class/gpio/export
    fi
    echo out > "$sf_dir_path"
    sf_output_off
}
