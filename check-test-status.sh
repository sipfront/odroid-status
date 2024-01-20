#!/bin/sh

pin=481 # GPIOX.5 / pin 7 (4th on row 1)
auth=$1
test_id=$2
env=${3:-prod}

dir_path="/sys/class/gpio/gpio${pin}/direction"
val_path="/sys/class/gpio/gpio${pin}/value"

if [ -z "$auth" ] || [ -z "$test_id" ]; then
    echo "Usage: $- <user:pass> <testid>"
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

if [ -e "$dir_path" ]; then
   echo "gpio pin $pin already exported..."
else
   echo "exporting gpio pin $pin..."
    echo $pin > /sys/class/gpio/export
fi
echo out > "$dir_path"
echo 0 > "$val_path"

while [ 1 ]; do
    interval=5;
    status=$(curl --user "$auth" -H 'Accept: application/json' "$url" 2>/dev/null | tac | tac | jq -r .run.status)
    if [ "$status" = "running" ]; then
        echo "running..."
        for i in $(seq 1 3); do
            echo 1 > "$val_path"
            sleep 0.2
            echo 0 > "$val_path"
            sleep 0.8
        done
        interval=2
    elif [ "$status" = "passed" ]; then
        echo "passed..."
        echo 0 > "$val_path"
    elif [ "$status" = "failed" ]; then
        echo "failed..."
        echo 1 > "$val_path"
    fi

    sleep "$interval"
done


