#!/bin/bash

FILE=$(readlink -f ./res/survey.yaml)
DIR=$(dirname $FILE)
LOG_FILE=$DIR/commit_count.txt

rm -f $LOG_FILE
touch $LOG_FILE
len=$(yq ".items | length" $FILE)
tmp_dir=$(mktemp -d)
cd $tmp_dir
for e in $(seq 0 $(($len - 1))); do
    repo=$(yq eval ".items[$e].repository" $FILE)
    team=$(yq eval ".items[$e].team_name" $FILE)
    handle=$(yq eval ".items[$e].github_handle" $FILE)

    git clone --single-branch --branch main https://github.com/osscameroon/$repo > /dev/null 2>&1
    cd $repo
    echo -e "Count: $(git rev-list --count main), \c" >> $LOG_FILE
    if [ ! -z "$team" ]; then
        echo -e "team: $team, \c">> $LOG_FILE
    elif [ ! -z "$handle" ]; then
        echo -e "handle: $handle, \c">> $LOG_FILE
    fi
    echo -e "repo: $repo">> $LOG_FILE

    cd ..
done
cd ..
rm -rf $tmp_dir

echo "Participant commit count"
sort -n -k2 -r $LOG_FILE
