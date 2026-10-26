#!/usr/bin/env bash
# Run a kaem script over a workspace laid out like stage0-posix.
#
#   --script   the commands to run, one per line, exactly as kaem would
#   --<name>   any other input, placed at ./<name>
#
# Whatever the script leaves at ./out is the step's product.
set -euo pipefail

caos get /cas/args/script

workspace=/tmp/workspace
mkdir "$workspace"
for input in /cas/args/*; do
  name=${input##*/}
  case $name in base | worker1 | script) continue ;; esac
  caos get -r "$input"
  cp -rL "$input" "$workspace/$name"
done
chmod -R u+w "$workspace"
# A bare file is an earlier step's product, which is a program; a blob has no
# mode of its own to say so.
find "$workspace" -maxdepth 1 -type f -exec chmod +x {} +

cd "$workspace"
sh -ex /cas/args/script
caos put out /cas/out
