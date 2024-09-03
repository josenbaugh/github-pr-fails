#! /bin/bash

CONFFILE=~/.config/github.conf
STATUSFILE=~/.pr-status
SCRIPTDIR=/usr/local/bin/
SYSTEMDDIR=~/.config/systemd/user/

function get_token {
    echo "Please enter your github auth token: "
    read TOKEN
    touch $CONFFILE
    echo $TOKEN > $CONFFILE
}

while getopts ":u-:" opt; do
case $opt in
  u|uninstall)
      UNINSTALL=true
      ;;
  -)
      case "${OPTARG}" in
        uninstall)
            UNINSTALL=true
          ;;
        *)
          echo "Invalid option: --$OPTARG"
          exit 1
          ;;
      esac
      ;;
  \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
esac
done

if [ "$UNINSTALL" = true ]; then
    echo "Uninstalling pr-status service"
    systemctl --user stop pr-status.service || { echo "Cannot stop service"; exit 1;  }
    systemctl --user disable pr-status.service || { echo "Cannot disable service"; exit 1;  }
    systemctl --user daemon-reload || { echo "Cannot reload systemd"; exit 1;  }
    systemctl --user reset-failed || { echo "Cannot reset-failed systemd"; exit 1;  }
    rm $SYSTEMDDIR/pr-status.service || { echo "Cannot remove systemd file"; exit 1;  }
    rm $STATUSFILE || { echo "Cannot remove status file"; exit 1;  }
    rm $CONFFILE || { echo "Cannot remove config file"; exit 1;  }
    exit 0
fi

echo "Installing pr-status service"

if [ -f "$CONFFILE" ]; then
    echo "$CONFFILE exists."
    read -e -p "Would you like to overwrite your existing token? " choice
    [[ "$choice" == [Yy]* ]] && get_token
else
    get_token
fi

sudo cp pr-status.sh $SCRIPTDIR || { echo "Cannot move new script to run location"; exit 1;  }
sudo chmod +x $SCRIPTDIR/pr-status.sh || { echo "Cannot set script executable"; exit 1;  }

touch $STATUSFILE

mkdir -p $SYSTEMDDIR || { echo "Cannot make systemd dir: $SYSTEMDDIR"; exit 1; }
cp pr-status.service $SYSTEMDDIR || { echo "Cannot move systemd file"; exit 1;  }
systemctl --user daemon-reload || { echo "Cannot reload systemd"; exit 1;  }
systemctl --user enable pr-status.service || { echo "Cannot enable systemd service"; exit 1;  }
systemctl --user start pr-status.service || { echo "Cannot start systemd service"; exit 1;  }
systemctl --user restart pr-status.service || { echo "Cannot restart systemd service"; exit 1;  }
echo "Service is ... $(systemctl --user is-enabled pr-status.service)"
