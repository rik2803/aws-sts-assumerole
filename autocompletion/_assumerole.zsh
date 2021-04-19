#compdef assumerole

# To configure:
#   * Copy this file to ${ZSH}/completions/_assumerole
#   * Restart the shell with "exec zsh"
#   * Enjoy

function _assumerole {
  _arguments '1: :->aws_profile'
  _arguments "1:profiles:($(/usr/local/bin/assumerole accountlist_text | tr '\r\n' ' ' | tr -dc '[:alnum:]-_\. ' | sed 's/32m//g' | sed 's/0m//g'))"
}

_assumerole "$@"