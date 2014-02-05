if [[ ! -o interactive ]]; then
    return
fi

compctl -K _msvm msvm

_msvm() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(msvm commands)"
  else
    completions="$(msvm completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
