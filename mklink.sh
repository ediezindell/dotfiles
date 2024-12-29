#!/bin/bash

files=.*
for file in ${files}; do
  filepath="${PWD}/${file}"
  homefile="${HOME}/${file}"

  test $file == "." && continue
  test $file == ".." && continue
  test $file == ".config" && continue
  test $file == ".git" && continue
  test $file == ".gitmodules" && continue

  if [ ! -a "${homefile}" -a ! -h "${homefile}" ]; then
    echo "${file} not exist, make symbolic link to ${homefile}"
    ln -s "${filepath}" "${homefile}"
  else
    echo "${file} exist, skip"
  fi
done

configfiles=.config/*
for file in ${configfiles}; do
  filepath="${PWD}/${file}"
  homefile="${HOME}/${file}"

  test $file == "." && continue
  test $file == ".." && continue

  if [ ! -a "${homefile}" -a ! -h "${homefile}" ]; then
    echo "${file} not exist, make symbolic link to ${homefile}"
    ln -s "${filepath}" "${homefile}"
  else
    echo "${file} exist, skip"
  fi
done

ln -s "${PWD}/bin" "${HOME}/bin"
chmod -R +x "${PWD}/bin"
