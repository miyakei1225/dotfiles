#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backup/$(date +%Y%m%d%H%M%S)"
install_fish=false

if [[ "${1:-}" == "--with-fish" ]]; then
  install_fish=true
elif [[ -n "${1:-}" ]]; then
  printf 'Usage: %s [--with-fish]\n' "$0" >&2
  exit 2
fi

link_config() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    printf 'Skipping missing source: %s\n' "$source"
    return
  fi

  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    printf 'Already linked: %s\n' "$target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local backup="$backup_root/${target#"$HOME"/}"
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    printf 'Backed up %s to %s\n' "$target" "$backup"
  fi

  ln -s "$source" "$target"
  printf 'Linked %s -> %s\n' "$target" "$source"
}

link_config "$repo_dir/fish" "$HOME/.config/fish"
link_config "$repo_dir/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
link_config "$repo_dir/git/ignore" "$HOME/.config/git/ignore"
link_config "$repo_dir/claude/agents" "$HOME/.claude/agents"
link_config "$repo_dir/claude/commands" "$HOME/.claude/commands"

if $install_fish; then
  if ! command -v brew >/dev/null 2>&1; then
    printf 'Homebrew is required to install Fish. Install Homebrew first.\n' >&2
    exit 1
  fi

  if ! command -v fish >/dev/null 2>&1; then
    brew install fish
  fi

  fish_path="$(command -v fish || true)"
  if [[ -z "$fish_path" ]]; then
    fish_path="$(brew --prefix fish)/bin/fish"
  fi
  "$fish_path" -c 'if not functions -q fisher; curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; end; and fisher update'
fi
