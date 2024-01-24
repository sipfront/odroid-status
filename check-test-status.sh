#!/bin/sh

inc=$(dirname $0)/check-status.inc.sh
if ! [ -r "$inc" ]; then
    echo "$inc not found!"
    exit 1
fi
. "$inc"

pin=481 # GPIOX.5 / pin 7 (4th on row 1)
auth=$1
test_id=$2
env=${3:-prod}

sf_dir_path="/sys/class/gpio/gpio${pin}/direction"
sf_val_path="/sys/class/gpio/gpio${pin}/value"

if [ -z "$auth" ] || [ -z "$test_id" ]; then
    echo "Usage: $0 <user:pass> <testid>"
    exit 1
fi

if [ "$env" = "prod" ]; then
    base="app.sipfront.com"
elif [ "$env" = "dev" ]; then
    base="app.dev.sipfront.com"
else
    echo "Invalid environment, must be prod or dev!"
    exit 1
fi

url="https://${base}/api/v2/tests/${test_id}/status/last"
tmpfile="/tmp/out-$$.json"

# handle SIGINT
trap "sf_shutdown" 2

sf_init

while [ 1 ]; do
    interval=5;

    curl --user "$auth" -H 'Accept: application/json' "$url" --output "$tmpfile" 2>/dev/null
    status=$(cat "$tmpfile" | jq -r .run.status)
    if [ "$status" = "running" ]; then
        echo "running..."
        sf_blink 0.2 0.8
    elif [ "$status" = "passed" ]; then
        echo "passed..."
        sf_output_off 
    elif [ "$status" = "failed" ]; then
        echo "failed..."
        sf_output_on
    fi
    sleep "$interval"
done


