# PR Status
This script will check the status of all open PRs in GitHub and post a notification to the user's desktop if any PRs are in a failed state.
Once a fail is detected the script will wait 5 mins before checking again. If the PR is still in a failed state the script will post another notification.
There's a file `~/.pr-status` that stores a current PASS/FAIL -- this can be used separately for other scripts to display the status of the PRs in other ways.

# Installation
The install script will prompt for your GitHub Auth token and store it for the script to use
```
bash install.sh
```

# Uninstallation
The uninstall script will remove the systemd service and the script itself and any stored data
```
bash install.sh --uninstall
```

# Troubleshooting
Check the logs for the service
```
systemctl --user status pr-status.service
```

Restart the service
```
systemctl --user restart pr-status.service
```
