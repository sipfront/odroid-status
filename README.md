# About

In this repo, you can find a collection of scripts to query the [Sipfront](https://sipfront.com) API and trigger
the output of a GPIO pin.

# Installation

1. Copy this repo to /usr/local/odroid-status.
   ```
   sudo cp -r $(pwd) /usr/local/odroid-status
   ```
1. Copy the systemd service files in etc/* to /lib/systemd/system/
   ```
   sudo cp $(pwd)/etc/*.service /lib/systemd/system/
   ```
1. Configure the test and project to watch
   ```
   sudo cfg="/usr/local/odroid-status/etc/config.inc"
   sudo cat > "$cfg" << EOF
SF_API_KEY=your-api-key
SF_API_SECRET=your-api-secret
SF_TEST_ID=your-test-id-to-check
SF_PROJECT_ID=your-project-id-to-check
EOF
   sudo chmod 600 "$cfg"
   ```

1. Enable the relevant services
   ```
   sudo systemctl daemon-reload
   sudo systemctl enable sipfront-check-test.service
   # or if you monitor a whole project:
   # sudo systemctl enable sipfront-check-project.service
   ```
