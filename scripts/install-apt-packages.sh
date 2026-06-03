#!/usr/bin/env bash
#
# Install shared Debian/Ubuntu packages needed by the setup scripts.
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

require_root
require_apt

apt-get -o Acquire::Retries=3 update
apt-get install -y --no-install-recommends ca-certificates curl gnupg
