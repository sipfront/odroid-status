# IMPORTANT: these two must be set after sourcing!
sf_val_path=""
sf_dir_path=""

. $(dirname "$0")/etc/config.inc

sf_blink_pid=""

sf_log() {
    msg="$@"
    echo $(date)":" "$msg"
}

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
        echo 1 > "$sf_val_path"
        sleep "$interval_on"
        echo 0 > "$sf_val_path"
        sleep "$interval_off"
    done
}

sf_blink() {
    interval_on=$1
    interval_off=$2
    if [ "$sf_blink_pid" = "" ]; then
        sf_output_blink "$1" "$2" &
        sf_blink_pid=$!
    fi    
}

sf_init() {
    echo "exporting gpio pin $pin..."
    echo $pin > /sys/class/gpio/export
    echo out > "$sf_dir_path"
    sf_output_off

    echo "test gpio..."
    # blink sequence to show if all works
    for i in $(seq 1 5); do
        sf_output_on
        sleep 0.1
        sf_output_off
        sleep 0.1
    done

    sf_output_off
}
