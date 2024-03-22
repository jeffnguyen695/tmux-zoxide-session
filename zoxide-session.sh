#!/usr/bin/env bash

get_opt() {
	local value
	value="$(tmux show-option -gqv "$1")"
	if [ -z "$value" ]; then
		value="$2"
	fi
	echo "$value"
}

print_yellow() {
	printf '[0;33m%s[0m' "$1"
}

format() {
	local icon key
	icon=$1
	key=$2
	padded=$(printf '%s %-10s' "$icon" "$key")
	print_yellow "$padded"
}

# Get config options
preview_location=$(get_opt "@tzs-preview-location" "top")
preview_ratio=$(get_opt "@tzs-preview-ratio" "70%")
window_height=$(get_opt "@tzs-window-height" "65%")
window_width=$(get_opt "@tzs-window-width" "65%")

key_accept_icon=$(get_opt "@tzs-key-accept-icon" "󰿄")
key_new_icon=$(get_opt "@tzs-key-new-icon" "")
key_kill_icon=$(get_opt "@tzs-key-kill-icon" "󱂧")
key_rename_icon=$(get_opt "@tzs-key-rename-icon" "󰑕")
key_find_icon=$(get_opt "@tzs-key-find-icon" "")
key_window_icon=$(get_opt "@tzs-key-window-icon" "")
key_select_up_icon=$(get_opt "@tzs-key-select-up-icon" "")
key_select_down_icon=$(get_opt "@tzs-key-select-up-icon" "")
key_preview_up_icon=$(get_opt "@tzs-key-preview-up-icon" "")
key_preview_down_icon=$(get_opt "@tzs-key-preview-down-icon" "")
key_help_icon=$(get_opt "@tzs-key-help-icon" "")
key_quit_icon=$(get_opt "@tzs-key-quit-icon" "")

key_accept=$(get_opt "@tzs-key-accept" "enter")
key_new=$(get_opt "@tzs-key-new" "ctrl-e")
key_kill=$(get_opt "@tzs-key-kill" "ctrl-x")
key_rename=$(get_opt "@tzs-key-rename" "ctrl-r")
key_find=$(get_opt "@tzs-key-find" "ctrl-f")
key_window=$(get_opt "@tzs-key-window" "ctrl-w")
key_select_up=$(get_opt "@tzs-key-select-up" "ctrl-p")
key_select_down=$(get_opt "@tzs-key-select-down" "ctrl-n")
key_preview_up=$(get_opt "@tzs-key-preview-up" "ctrl-u")
key_preview_down=$(get_opt "@tzs-key-preview-down" "ctrl-d")
key_help=$(get_opt "@tzs-key-help" "ctrl-h")
key_quit=$(get_opt "@tzs-key-quit" "esc")

prompt_sessions=$(get_opt "@tzs-prompt-sessions" "Sessions")
prompt_windows=$(get_opt "@tzs-prompt-windows" "Windows")
prompt_find=$(get_opt "@tzs-prompt-find" "Directories")
prompt_kill_session=$(get_opt "@tzs-prompt-kill-session" "Kill sessions")
prompt_kill_window=$(get_opt "@tzs-prompt-kill-window" "Kill windows")
prompt_rename_session=$(get_opt "@tzs-prompt-rename-session" "Rename session")
prompt_rename_window=$(get_opt "@tzs-prompt-rename-window" "Rename window")
prompt_help=$(get_opt "@tzs-prompt-help" "Help")

header=":: <$(print_yellow $key_help)> for $(print_yellow "Help") | $key_accept_icon <$(print_yellow $key_accept)> | $key_new_icon <$(print_yellow $key_new)> | $key_find_icon <$(print_yellow $key_find)> | $key_window_icon <$(print_yellow $key_window)> | $key_kill_icon <$(print_yellow $key_kill)> | $key_rename_icon <$(print_yellow $key_rename)> | $key_quit_icon <$(print_yellow $key_quit)>"

help=$(printf '
%s Go to selected session / window
             If no match, create a new session from the best matching directory
%s Create a new session with the query as its name
%s Find directories with zoxide
%s List session windows
%s Kill selected session / window
%s Rename selected session / window
%s Back / Quit
%s Select up
%s Select down
%s Scroll preview up
%s Scroll preview down
%s Show help' "$(format "$key_accept_icon" "$key_accept")" "$(format "$key_new_icon" "$key_new")" "$(format "$key_find_icon" "$key_find")" "$(format "$key_window_icon" "$key_window")" "$(format "$key_kill_icon" "$key_kill")" "$(format "$key_rename_icon" "$key_rename")" "$(format "$key_quit_icon" "$key_quit")" "$(format "$key_select_up_icon" "$key_select_up")" "$(format "$key_select_down_icon" "$key_select_down")" "$(format "$key_preview_up_icon" "$key_preview_up")" "$(format "$key_preview_down_icon" "$key_preview_down")" "$(format "$key_help_icon" "$key_help")")

list_sessions='tmux list-sessions | sed -E \"s/:.*$//\"'

list_windows='max_len=-1
for line in \$(tmux list-windows -a -F \"#{session_name}:#{window_index}\"); do
  if [[ \${#line} -gt \$max_len ]]; then
    max_len=\${#line}
  fi
done
tmux list-windows -a -F \"#{p\${max_len}:#{session_name}:#{window_index}}  #{T:tree_mode_format}\"'

handle_find='if [[ ! $FZF_PROMPT =~ '"$prompt_find"' ]]; then 
  echo "clear-query+enable-search+toggle-sort+change-prompt('"$prompt_find"' > )+reload(zoxide query --list)+change-preview(ls --color=always -Cp \{1})"
fi'

handle_window='load_windows="clear-query+enable-search+change-prompt('"$prompt_windows"' > )+reload('"$list_windows"')+change-preview(tmux capture-pane -ep -t \{1})"
if [[ $FZF_PROMPT =~ '"$prompt_find"' ]]; then
  echo "toggle-sort+$load_windows"
elif [[ ! $FZF_PROMPT =~ '"$prompt_windows"' ]]; then
  echo "$load_windows"
fi'

handle_kill='if [[ $FZF_PROMPT =~ '"$prompt_sessions"' ]]; then 
  echo "clear-query+change-prompt('"$prompt_kill_session"' (y/n) > )+reload(echo {+1})+disable-search"
elif [[ $FZF_PROMPT =~ '"$prompt_windows"' ]]; then
  echo "clear-query+change-prompt('"$prompt_kill_window"' (y/n) > )+reload(echo {+1})+disable-search"
fi'

handle_rename='if [[ $FZF_PROMPT =~ '"$prompt_sessions"' ]]; then 
  echo "clear-query+change-prompt('"$prompt_rename_session"' > )+change-preview(echo "New session name: \{q}")+reload(echo {})+disable-search"
elif [[ $FZF_PROMPT =~ '"$prompt_windows"' ]]; then
  echo "clear-query+change-prompt('"$prompt_rename_window"' > )+change-preview(echo "New window name: \{q}")+reload(echo {})+disable-search"
fi'

handle_accept='load_sessions="clear-query+enable-search+change-prompt('"$prompt_sessions"' > )+change-preview(tmux capture-pane -ep -t \{1})+reload('"$list_sessions"')"
load_windows="clear-query+enable-search+change-prompt('"$prompt_windows"' > )+change-preview(tmux capture-pane -ep -t \{1})+reload('"$list_windows"')"

if [[ $FZF_PROMPT =~ '"$prompt_sessions"' ]]; then 
  echo "replace-query+print-query"
elif [[ $FZF_PROMPT =~ '"$prompt_windows"' ]]; then
  echo "transform-query(echo {1})+print-query"
elif [[ $FZF_PROMPT =~ '"$prompt_find"' ]]; then
  echo "replace-query+print-query"
elif [[ $FZF_PROMPT =~ "'"$prompt_kill_session"'" ]]; then
  if [[ $FZF_QUERY == "y" ]]; then
    echo "execute-silent(for sess in \$(echo "{}"); do tmux kill-session -t \$sess; done)+$load_sessions"
  else
    echo "$load_sessions"
  fi
elif [[ $FZF_PROMPT =~ "'"$prompt_kill_window"'" ]]; then
  if [[ $FZF_QUERY == "y" ]]; then
    echo "execute-silent(for win in \$(echo "{}"); do tmux kill-window -t \$win; done)+$load_windows"
  else
    echo "$load_windows"
  fi
elif [[ $FZF_PROMPT =~ "'"$prompt_rename_session"'" ]]; then
  echo "execute-silent(tmux rename-session -t {1} {q})+$load_sessions"
elif [[ $FZF_PROMPT =~ "'"$prompt_rename_window"'" ]]; then
  echo "execute-silent(tmux rename-window -t {1} {q})+$load_windows"
fi'

handle_new='if [[ $FZF_PROMPT =~ '"$prompt_sessions"' ]]; then 
  echo "execute-silent(tmux new-session -ds "{q}")+print-query"
fi'

handle_quit='load_sessions="clear-query+enable-search+change-prompt('"$prompt_sessions"' > )+reload('"$list_sessions"')+change-preview(tmux capture-pane -ep -t \{1})"
load_windows="clear-query+enable-search+change-prompt('"$prompt_windows"' > )+change-preview(tmux capture-pane -ep -t \{1})+reload('"$list_windows"')"

if [[ $FZF_PROMPT =~ '"$prompt_find"' ]]; then
  echo "toggle-sort+$load_sessions"
elif [[ $FZF_PROMPT =~ ('"$prompt_windows"'|'"$prompt_find"'|"'"$prompt_kill_session"'"|"'"$prompt_rename_session"'"|'"$prompt_help"') ]]; then
  echo "$load_sessions"
elif [[ $FZF_PROMPT =~ ("'"$prompt_kill_window"'"|"'"$prompt_rename_window"'") ]]; then
  echo "$load_windows"
else
  echo "abort"
fi'

handle_help="change-prompt($prompt_help > )+reload()+change-preview(echo '$help')"

launch() {
	local sessions
	sessions=$(tmux list-sessions | sed -E "s/:.*$//")

	echo -e "${sessions// /}" | fzf-tmux \
		-p "$window_width,$window_height" \
		--preview-window="${preview_location},${preview_ratio},," \
		--border bold \
		--header="$header" \
		--prompt="$prompt_sessions > " \
		--preview="tmux capture-pane -ep -t {1}" \
		--border-label " Current: $(tmux display-message -p '#S') " \
		--bind 'focus:transform-preview-label:echo [ {1} ]' \
		--bind "$key_window:transform:$handle_window" \
		--bind "$key_find:transform:$handle_find" \
		--bind "$key_kill:transform:$handle_kill" \
		--bind "$key_rename:transform:$handle_rename" \
		--bind "$key_accept:transform:$handle_accept" \
		--bind "$key_new:transform:$handle_new" \
		--bind "$key_quit:transform:$handle_quit" \
		--bind "$key_help:$handle_help" \
		--bind "$key_preview_up:preview-half-page-up" \
		--bind "$key_preview_down:preview-half-page-down" \
		--bind "$key_select_up:up" \
		--bind "$key_select_down:down" \
		--scrollbar '▌▐' \
		--print-query \
		--multi \
		--exit-0
}

handle_output() {
	target=$(echo "$1" | tr -d '\n')
	if [[ -z "$target" ]]; then
		exit 0
	fi

	if ! tmux has-session -t="$target" 2>/dev/null; then
		if test -d "$target"; then
			tmux new-session -ds "${target##*/}" -c "$target"
			target="${target##*/}"
		else
			z_target=$(zoxide query "$target")
			target="${z_target##*/}"
			tmux new-session -ds "$target" -c "$z_target"
		fi
	fi
	tmux switch-client -t "$target"
}

handle_output "$(launch)"
