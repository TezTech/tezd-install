#! /bin/sh

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/scripts/")"
src_dir="$(dirname "$script_dir")"

. "$script_dir"/version.sh

opam repository set-url tezos --dont-select $opam_repository || \
    opam repository add tezos --dont-select $opam_repository > /dev/null 2>&1

if [ ! -d "$src_dir/_opam" ] ; then
    opam switch create "$src_dir" --repositories=tezos ocaml-base-compiler.$ocaml_version
fi

if [ ! -d "$src_dir/_opam" ] ; then
    echo "Failed to create the opam switch"
    exit 1
fi

eval $(opam env --shell=sh)

if [ "$(ocaml -vnum)" != "$ocaml_version" ]; then
    opam --yes install --unlock-base ocaml-base-compiler.$ocaml_version
fi

opam list --installed opam-depext || opam --yes install opam-depext

opams=$(find "$src_dir/vendors" "$src_dir/src" -name \*.opam -print)

opam --yes install $opams --deps-only --with-test

