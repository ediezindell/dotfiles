function node_install() {
  if [ -f .node-version ]; then
    CWD_NODE_VERSION=$(cat .node-version)
    echo $CWD_NODE_VERSION
    # volta install node@$CWD_NODE_VERSION
  fi
}

function bm() {
  if [ ! -d .git ]; then
    branches=$(git branch --sort=-committerdate | awk '{print $NF}')
  else
    touch .git/memo
    branches=$(git branch --sort=-committerdate | awk '{print $NF}' | xargs -L1 -I{} grep "{}" .git/memo)
  fi
  echo $branches | cat -n
  read branchNumber\?"Enter Branch Number: "
  git switch $(echo $branches | cut -d, -f1 | awk NR==$branchNumber)
}
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

function pmc() {
  if [ -e package-lock.json ]; then
    echo "npm"
  elif [ -e yarn.lock ]; then
    echo "yarn"
  elif [ -e pnpm-lock.yaml ]; then
    echo "pnpm"
  else
    echo "?"
  fi
}

add-zsh-hook chpwd node_install

