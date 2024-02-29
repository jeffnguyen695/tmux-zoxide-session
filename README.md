# Tmux zoxide Session

Tmux session manager with the power of zoxide.

## ✨ Features

- 🔎 Fuzzy search existing sessions
- 🔨 Preview, rename, kill sessions
- ⭐ Create new session by finding directories with zoxide

## ⚡️ Requirements

- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [fzf](https://github.com/junegunn/fzf)
- [tpm](https://github.com/tmux-plugins/tpm) (optional)

## 📦 Installation

### Install with TPM

Add this plugin to `.tmux.conf` and run `<prefix> Ctrl-I` for TPM to install.

```bash
set -g @plugin 'jeffnguyen695/tmux-zoxide-session'
```

### Install manually

## 🚀 Usage

### Demo

Inside tmux

- `<prefix> S` to launch the popup session manager
- Start typing to fuzzy search sessions
- `Enter` to switch to selected session
- `Ctrl-k` to kill selected session
- `Ctrl-r` to rename selected session
- `Ctrl-u` / `Ctrl-d` to scroll preview up / down
- `Ctrl-w` to switch to window view
- `Ctrl-s` to switch back to session view
- When no existing session found:
  - `Enter` to create new session with best match directory from zoxide
  - `Ctrl-Enter` to create new session without zoxide
  - `Ctrl-f` to find directories with zoxide, hit `Enter` on selected item will create a new session with that directory.
- `Escape` to quit

## ⚙️ Configuration

```bash
# UI
set -g @zoxide-session-preview-location 'top'
set -g @zoxide-session-preview-ratio '75%'

set -g @zoxide-session-window-height '75%'
set -g @zoxide-session-window-width '75%'

# Key bindings
set -g @zoxide-session-key-launch 'S'

set -g @zoxide-session-key-enter 'enter'
set -g @zoxide-session-key-kill 'C-k'
set -g @zoxide-session-key-rename 'C-r'
set -g @zoxide-session-key-up 'C-u'
set -g @zoxide-session-key-down 'C-d'
set -g @zoxide-session-key-find 'C-f'
set -g @zoxide-session-key-window 'C-w'
set -g @zoxide-session-key-sess 'C-s'
set -g @zoxide-session-key-quit 'esc'
```

## Reference

- Heavily inspired by [tmux-sessionx](https://github.com/omerxx/tmux-sessionx)
- Also [tmux-sessionizer](https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer)
