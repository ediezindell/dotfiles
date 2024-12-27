#!/bin/bash

file=$1

dotfile="${PWD}/${file}"
homefile="${HOME}/${file}"

if [ ! -e "${homefile}" ]; then
  echo "error! ${homefile} is not exist!"
  exit 1
fi

if [ ! -h "${homefile}" -a -e "${dotfile}" ]; then
  echo "error! ${dotfile} is exist, but ${homefile} is not symlink!"
  exit 1
fi

if [ -h "${homefile}" -a -e "${dotfile}" -a "$(readlink ${homefile})" = "${dotfile}" ]; then
  echo "${homefile} is already imported!"
  exit 0
fi

echo "${file} is not exist, import to ${dotfile}..."
mv "${homefile}" "${dotfile}"
ln -s "${dotfile}" "${homefile}"
echo "completed."

