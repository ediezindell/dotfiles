function b() {
  branches=$(git branch --sort=-committerdate)
  echo $branches | cat -n
  read branchNumber\?"Enter Branch Number: "
  git switch $(echo $branches | cut -c 3- | awk NR==$branchNumber)
}
