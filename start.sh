#!/bin/bash
umask 000
chown -R dropbox:dropbox /dropbox

# Update Dropbox to latest version unless DBOX_SKIP_UPDATE is set
if [[ -z "$DBOX_SKIP_UPDATE" ]]; then
  echo "Checking for latest Dropbox version..."
  sleep 1
  # Get download link for latest dropbox version
  DL=$(curl -I -s https://www.dropbox.com/download/\?plat\=lnx.x86_64 | grep ocation | awk -F'ocation: ' '{print $2}')
  # Strip CRLF
  DL=${DL//[$'\t\r\n ']}
  # Extract version string
  Latest=$(echo $DL | sed 's/.*x86_64-\([0-9]*\.[0-9]*\.[0-9]*\)\.tar\.gz/\1/')
  # Get current Version
  Current=$(cat /opt/dropbox/VERSION)
  echo "Latest   :" $Latest
  echo "Installed:" $Current
  if [ ! -z "${Latest}" ] && [ ! -z "${Current}" ] && [ $Current != $Latest ]; then
    echo "Downloading Dropbox v$Latest..."
    tmpdir=`mktemp -d`
    curl -# -L $DL | tar xzf - -C $tmpdir
    echo "Installing new version..."
    rm -rf /opt/dropbox/*
    mv $tmpdir/.dropbox-dist/* /opt/dropbox/
    rm -rf $tmpdir
    chmod 755 /opt/dropbox/dropbox-lnx*/*.so
    echo "Dropbox updated to v$Latest"
  else
    echo "Dropbox is up-to-date"
  fi
fi

echo "Starting dropboxd ($(cat /opt/dropbox/VERSION))..."
exec su - dropbox -c /opt/dropbox/dropboxd
