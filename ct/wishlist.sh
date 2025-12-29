#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Dunky13/ProxmoxVE/refs/heads/feature/wishlist/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: Dunky13
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/cmintey/wishlist

APP="Wishlist"
var_tags="${var_tags:-sharing}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-5}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors
function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/wishlist ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  NODE_VERSION="24" NODE_MODULE="pnpm" setup_nodejs

  if check_for_gh_release "wishlist" "cmintey/wishlist"; then
    msg_info "Stopping Service"
    systemctl stop wishlist
    msg_ok "Service Stopped"

    cp /opt/wishlist/.env /opt/
    rm -R /opt/wishlist
    fetch_and_deploy_gh_release "wishlist" "cmintey/wishlist" "tarball"

    msg_info "Updating ${APP}"
    cd /opt/wishlist || exit
    mv /opt/.env /opt/wishlist/.env
    $STD pnpm install
    $STD pnpm build
    msg_ok "Updated ${APP}"

    msg_info "Starting Service"
    systemctl start wishlist
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3280${CL}"
