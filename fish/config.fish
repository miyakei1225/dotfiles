if status is-interactive
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    end
end

set -gx ANDROID_HOME $HOME/Library/Android/sdk
for path_entry in $ANDROID_HOME/emulator $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools
    fish_add_path --append $path_entry
end

if test -n "$GOOGLE_APPLICATION_CREDENTIALS"
    set -gx GOOGLE_APPLICATION_CREDENTIALS $GOOGLE_APPLICATION_CREDENTIALS
else if test -f $HOME/.config/gcloud/application_default_credentials.json
    set -gx GOOGLE_APPLICATION_CREDENTIALS $HOME/.config/gcloud/application_default_credentials.json
end

set -g theme_display_date no
set -g theme_display_git_ahead_verbose yes
set -g theme_display_git_dirty_verbose yes
set -g theme_display_git_stashed_verbose yes
set -g theme_display_git_default_branch yes
set -g theme_git_default_branches master main
set -g theme_display_node yes
set -g theme_nerd_fonts yes
set -g theme_display_vi no

set -gx PATH $HOME/.nodebrew/current/bin $PATH
set -gx GOPATH $HOME/go
fish_add_path $GOPATH/bin
set -gx TENV_AUTO_INSTALL true

if test -d /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
    set -gx JAVA_8_HOME /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
    function java8
        set -gx JAVA_HOME $JAVA_8_HOME
    end
end

if test -x $HOME/.jenv/bin/jenv
    fish_add_path $HOME/.jenv/bin
    status --is-interactive; and jenv init - fish | source
end

if type -q direnv
    direnv hook fish | source
end

if string match -q -- "$TERM_PROGRAM" kiro; and type -q kiro
    set -l kiro_integration (kiro --locate-shell-integration-path fish 2>/dev/null)
    test -n "$kiro_integration"; and test -f "$kiro_integration"; and source "$kiro_integration"
end
