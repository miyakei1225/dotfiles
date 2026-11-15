#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backup/$(date +%Y%m%d%H%M%S)"
install_fish=false
install_apps=false
install_inshellisense=false

for arg in "$@"; do
  case "$arg" in
    --with-fish) install_fish=true ;;
    --with-apps) install_apps=true ;;
    --with-inshellisense) install_inshellisense=true ;;
    *) printf 'Usage: %s [--with-fish] [--with-apps] [--with-inshellisense]\n' "$0" >&2; exit 2 ;;
  esac
done

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

git config --global user.name "miyakei1225"
git config --global user.email "miyakeionigiri@yahoo.co.jp"

if $install_apps || $install_fish || $install_inshellisense; then
  if ! command -v brew >/dev/null 2>&1; then
    printf 'Homebrew is required to install applications. Install Homebrew first.\n' >&2
    exit 1
  fi
fi

if $install_apps; then
  for app in raycast karabiner-elements visual-studio-code cursor aerospace iterm2; do
    case "$app" in
      raycast) app_bundle="Raycast.app"; brew_cask="$app" ;;
      karabiner-elements) app_bundle="Karabiner-Elements.app"; brew_cask="$app" ;;
      visual-studio-code) app_bundle="Visual Studio Code.app"; brew_cask="$app" ;;
      cursor) app_bundle="Cursor.app"; brew_cask="$app" ;;
      aerospace) app_bundle="AeroSpace.app"; brew_cask="nikitabobko/tap/aerospace" ;;
      iterm2) app_bundle="iTerm.app"; brew_cask="$app" ;;
    esac

    if brew list --cask "$brew_cask" >/dev/null 2>&1 \
      || [[ -d "/Applications/$app_bundle" ]] \
      || [[ -d "$HOME/Applications/$app_bundle" ]]; then
      printf 'Already installed: %s\n' "$app"
    else
      brew install --cask "$brew_cask"
    fi
  done

  if brew list --formula herdr >/dev/null 2>&1 || command -v herdr >/dev/null 2>&1; then
    printf 'Already installed: herdr\n'
  else
    brew install herdr
  fi

  if brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
    printf 'Already installed: font-meslo-lg-nerd-font\n'
  else
    brew install --cask font-meslo-lg-nerd-font
  fi

  if [[ -d /Applications/iTerm.app || -d "$HOME/Applications/iTerm.app" ]]; then
    if pgrep -x iTerm2 >/dev/null 2>&1; then
      printf 'iTerm2 is running; quit it and rerun ./install.sh --with-apps to configure the default profile.\n'
    elif defaults export com.googlecode.iterm2 /dev/null >/dev/null 2>&1; then
      iterm_prefs="$(mktemp)"
      trap 'rm -f "$iterm_prefs"' EXIT
      defaults export com.googlecode.iterm2 "$iterm_prefs"
      python3 "$repo_dir/iterm2/configure-profile.py" "$iterm_prefs" "$repo_dir/iterm2/Iceberg.itermcolors"
      defaults import com.googlecode.iterm2 "$iterm_prefs"
      rm -f "$iterm_prefs"
      trap - EXIT
      printf 'Set the default iTerm2 profile to MesloLGS NF with the dark Iceberg color scheme.\n'
    else
      printf 'iTerm2 has not created preferences yet; open it once, quit it, then rerun ./install.sh --with-apps to configure the profile.\n'
    fi
  fi

fi

if $install_apps || $install_inshellisense; then
  brew tap microsoft/inshellisense https://github.com/microsoft/inshellisense
  if brew list --formula inshellisense >/dev/null 2>&1; then
    printf 'Already installed: inshellisense\n'
  else
    brew install inshellisense
  fi

  is init fish >/dev/null
fi

if $install_fish; then
  if ! command -v fish >/dev/null 2>&1; then
    brew install fish
  fi

  fish_path="$(command -v fish)"
  if ! grep -Fxq "$fish_path" /etc/shells; then
    printf 'Adding Fish to /etc/shells: %s\n' "$fish_path"
    printf '%s\n' "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi

  current_shell="$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')"
  if [[ "$current_shell" == "$fish_path" ]]; then
    printf 'Fish is already the login shell.\n'
  else
    chsh -s "$fish_path"
    printf 'Set Fish as the login shell. Open a new terminal session to use it.\n'
  fi

  "$fish_path" -c 'if not functions -q fisher; curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; end; and fisher update'
fi
