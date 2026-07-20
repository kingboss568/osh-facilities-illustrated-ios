#!/bin/zsh
set -euo pipefail

cd "${CI_PRIMARY_REPOSITORY_PATH:?}"
./scripts/verify_1_1_update.sh
test -d OSHFacilitiesIllustrated.xcodeproj
print "Xcode Cloud preflight OK: OSH Facilities 1.1"
