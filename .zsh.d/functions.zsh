function node_install() {
  if [ -f .node-version ]; then
    CWD_NODE_VERSION=$(cat .node-version)
    echo $CWD_NODE_VERSION
    # volta install node@$CWD_NODE_VERSION
  fi
}

function bm() {
  if [ -d .git ]; then
    gh pr list > .git/pr-list
    branches=$(cat .git/pr-list | awk -F'\t' '{print $3"\t"$2}')
    echo $branches | cat -n
    read branchNumber\?"Enter Branch Number: "
    git switch $(echo $branches | cut -f1 | awk NR==$branchNumber)
  fi
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

function parseParentDir() {
  cwd=${1:-$( pwd )}
  path=/
  echo $path
  for dir in `echo ${cwd//\// }`; do
    path="${path}${dir}/"
    echo $path
  done
}

function cdp() {
  cwd=${1:-$( pwd )}
  cd $(parseParentDir $cwd | sort -r | fzf)
}

function searchGitRoot() {
  cwd=${1:-$( pwd )}
  for path in `parseParentDir $cwd`; do
    if [ -d "$path/.git" ]; then
      echo $path
    fi
  done
}

function cdr() {
  cwd=${1:-$( pwd )}
  root=`searchGitRoot $cwd`
  if [ -d $root ]; then
    cd $root
  fi
}
