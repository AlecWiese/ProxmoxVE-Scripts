#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://overseerr-oidc.dev/
# Note: This is the OIDC-enabled fork of Overseerr from https://github.com/ankarhem/overseerr-oidc

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  git \
  ca-certificates \
  gnupg
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing Yarn"
$STD npm install -g yarn
msg_ok "Installed Yarn"

msg_info "Installing Overseerr-OIDC (Patience)"
git clone -q https://github.com/ankarhem/overseerr-oidc.git /opt/overseerr-oidc
cd /opt/overseerr-oidc || exit
$STD yarn install
$STD yarn build
msg_ok "Installed overseerr-oidc"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/overseerr-oidc.service
[Unit]
Description=Overseerr-oidc Service
After=network.target

[Service]
Type=exec
WorkingDirectory=/opt/overseerr-oidc
ExecStart=/usr/bin/yarn start

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now overseerr-oidc
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
