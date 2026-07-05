#!/usr/bin/env bash

set -e

swift build
codesign --entitlements entitlements.plist --sign - .build/debug/virtualisation-macOs
