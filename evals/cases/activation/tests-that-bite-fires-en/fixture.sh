#!/usr/bin/env bash
# Copies the sample notes project into the empty workspace.
set -eu
cp -R "$(dirname "$0")/../../../activation/sandbox/." .
