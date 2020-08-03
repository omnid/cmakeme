#!/usr/bin/env bash
# Usage: git_hash.bash [OUTPUT]
# Creates git_hash.h, a file containing git hashes for the git repository
# Defines GIT_HASH, the hash of the latest commit and GIT_HASH_DIRTY a boolean
# that is true if there are uncommitted changes
# outputs to the file [OUTPUT]
mypath=$(readlink -f $(dirname $0))
cd $mypath

# find the top-level directory for the project
git_dir=$(git rev-parse --show-toplevel)/

# get the sha1 of the current HEAD
head_sha1=$(git rev-parse HEAD)

# get if the repository is dirty
git diff --quiet HEAD
dirty=$?

# create a temporary index and add all unstaged changes to this index
temp_index=$(mktemp)
cp $git_dir/.git/index $temp_index

# make git use the temporary index file 
export GIT_INDEX_FILE=$temp_index
cd $git_dir
git add -u

output=$1
if [ -z $output ]
then
    output=/dev/stdout
fi

cat > "$output" <<EOF
// Automatically generated by git_hash.bash
// DO NOT MODIFY. EVERY FILE this is included in will
/// this in, for example, a library, then every time the git hash changes
/// the library will need to be recompiled.
#ifndef GIT_HASH_INCLUDE_GUARD
#define GIT_HASH_INCLUDE_GUARD
#define GIT_HASH_HEAD "$head_sha1"
#define GIT_HASH_DIRTY $dirty
#endif
EOF

