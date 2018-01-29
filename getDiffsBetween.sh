#! /usr/bin/env bash
DIR="$( cd "$(dirname "$0")" ; pwd -P )"
ORIG=$(pwd)


if [ $# -ne '2' ] ; then
    echo "analyzes Server, Core, Schema-Tool, and Web"
    echo "Returns a list of diffs in one branch but not another"
    echo "Usage: "
    echo "    $0 release_08Jan2018ServerWebCut release_22Jan2018ServerWebCut"
    echo
    exit 1
fi

# start of data file
cat <<EOF > staged.py
import IPython
data=[
EOF

# gather diffs from branches
git submodule update --init
for repo in core schema-tool server web ; do
    cd $DIR/$repo && git checkout $1
    for diff in $(git log | egrep 'Differential Revision' | sed 's#    D.*/##') ; do
        echo -n .
        echo "  ('$1', '$repo', '$diff')," >> $DIR/staged.py
    done
    echo
    git checkout $2
    for diff in $(git log | egrep 'Differential Revision' | sed 's#    D.*/##') ; do
        echo -n .
        echo " ('$2', '$repo', '$diff')," >> $DIR/staged.py
    done
    cd $DIR
done

# end of data file
cat <<EOF >> staged.py
]
prev_branch = {x[2] for x in data if x[0] == '$1'}
target_branch = {x[2] for x in data if x[0] == '$2'}
new_diffs = target_branch - prev_branch
print("data: ", len(data))
print("prev_branch: ", len(prev_branch))
print("new_branch: ", len(new_branch))
print("new_diffs: ", len(new_diffs))
IPython.embed()
EOF

cd "$ORIG"

# now go analyze it
python staged.py
