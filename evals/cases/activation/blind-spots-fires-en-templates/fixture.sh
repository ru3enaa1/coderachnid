#!/usr/bin/env bash
# Copies the notes sample plus a Thymeleaf template and a stylesheet into the workspace.
set -eu
bash "$(dirname "$0")/../../../activation/web-fixture.sh"
