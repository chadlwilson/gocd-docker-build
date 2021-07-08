#!/usr/bin/env bash
set -euxo pipefail

gocd_target="${GOCD_TARGET_VERSION:-21.2.0}"

function download_server_zip() {
  curl -fsSLO https://download.gocd.org/releases.json
  jq ".[] | select(.go_version == \"${gocd_target}\")" < releases.json > target.json
  gocd_target_download_url="https://download.gocd.org/binaries/$(jq -r '.go_full_version' < target.json)/$(jq -r '.generic.server.file' < target.json)"

  curl -fsSLO "${gocd_target_download_url}"
  gocd_target_server_zip=$(readlink -f "$(find . -name '*.zip' -print)")
  echo "$(jq -r '.generic.server.sha256sum' < target.json) ${gocd_target_server_zip}" | sha256sum -c
}

function docker_gradle() {
  ./gradlew docker:gocd-server:assemble -PdockerbuildServerZipLocation="${gocd_target_server_zip}"
}

download_server_zip
docker_gradle