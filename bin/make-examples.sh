#!/bin/zsh

relax=$(realpath "bin/relax")

process_example() {
    $relax --platform kotlin --one-time
    $relax --platform swift --one-time
}

for d in Examples/*/; do
    echo "# $d"
    pushd "$d"
    process_example
    popd
done
