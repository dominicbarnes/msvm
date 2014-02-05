_msvm() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(msvm commands)" -- "$word") )
  else
    local command="${COMP_WORDS[1]}"
    local completions="$(msvm completions "$command")"
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _msvm msvm
