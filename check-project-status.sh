#!/bin/sh

inc=$(dirname $0)/check-status.inc.sh
if ! [ -r "$inc" ]; then
        echo "$inc not found!"
            exit 1
fi
. "$inc"

if [ -z "$SF_API_KEY" ] || [ -z "$SF_API_SECRET" ]; then
    echo "Both SF_API_KEY and SF_API_SECRET must be set!"
    exit 1
fi
auth="$SF_API_KEY:$SF_API_SECRET"

if [ -z "$SF_PROJECT_ID" ]; then
    echo "SF_PROJECT_ID must be set!"
    exit 1
fi
project_id="$SF_PROJECT_ID"

pin=481 # GPIOX.5 / pin 7 (4th on row 1)
env=${SF_ENV:-prod}

sf_dir_path="/sys/class/gpio/gpio${pin}/direction"
sf_val_path="/sys/class/gpio/gpio${pin}/value"

if [ "$env" = "prod" ]; then
    base="app.sipfront.com"
elif [ "$env" = "dev" ]; then
    base="app.dev.sipfront.com"
else
    echo "Invalid environment, must be prod or dev!"
    exit 1
fi

url="https://${base}/api/v2/projects/${project_id}/status/last"
tmpfile="/tmp/out-$$.json"

# handle SIGINT
trap "sf_shutdown" 2

while [ 1 ]; do
    interval=5;
    
    curl --user "$auth" -H 'Accept: application/json' "$url" --output "$tmpfile" 2>/dev/null
    has_running=$(cat "$tmpfile" | jq 'any(.tests[]; .run.status == "running")' 2>/dev/null)
    has_failed=$(cat "$tmpfile" | jq 'any(.tests[]; .run.status == "failed")' 2>/dev/null)
    if [ "$has_running" = "true" ]; then
        sf_log "has running..."
        sf_blink 0.2 0.8
    elif [ "$has_failed" = "true" ]; then
        sf_log "has failed..."
        sf_output_on
    else
        sf_log "no running or failed..."
        sf_output_off
    fi
    sleep "$interval"
done
