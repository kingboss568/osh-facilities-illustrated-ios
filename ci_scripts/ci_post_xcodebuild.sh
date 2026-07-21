#!/bin/zsh
set -euo pipefail

print "Xcode Cloud build completed: ${CI_XCODEBUILD_ACTION:-unknown} / ${CI_BUILD_NUMBER:-unknown}"
