#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

get_opt() {
	local value
	value="$(tmux show-option -gqv "$1")"
	if [ -z "$value" ]; then
		value="$2"
	fi
	echo "$value"
}

tmux bind-key "$(get_opt "@tzs-key-launch" "S")" run-shell "$CURRENT_DIR/zoxide-session.sh"
