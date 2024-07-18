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
    echo -e "${repo#careathon-2024-} \c">> $LOG_FILE
    echo -e "-> $(git rev-list --count main)" >> $LOG_FILE

    cd ..
done
cd ..
rm -rf $tmp_dir

echo "Participant commit count"
column -t <<< cat $LOG_FILE > $LOG_FILE
sort -n -t ">" -k2 -r $LOG_FILE
