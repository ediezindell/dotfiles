function b() {
  branches=$(git branch --sort=-committerdate)
  echo $branches | cat -n
  read branchNumber\?"Enter Branch Number: "
  git switch $(echo $branches | cut -c 3- | awk NR==$branchNumber)
}
function ba() {
  branches=$(git branch -a --sort=-committerdate)
  echo $branches | cat -n
  read branchNumber\?"Enter Branch Number: "
  echo ${branches//remote\/origin\//}
  git switch $(echo ${branches//remotes\/origin\//} | cut -c 3- | awk NR==$branchNumber)
}

function bg() {
  if [[ $1 =~ '^[0-9]+$' ]]; then
    builtin bg %$1
  else
    builtin bg "$@"
  fi
}
function fg() {
  if [[ $1 =~ '^[0-9]+$' ]]; then
    builtin fg %$1
  else
    builtin fg "$@"
  fi
}
