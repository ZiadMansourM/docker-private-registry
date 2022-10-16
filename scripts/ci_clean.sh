#!/bin/bash

# Clean CI server

echo "Delete Stoped containers ..."
docker container prune --force

HOST=registry.sreboy.com
NUM_IMAGES=4

REPOS=$(docker images --format "{{.Repository}}" | uniq | grep $HOST | cut -d "/" -f 2)

for REPO in $REPOS
do
    echo "REPO=$REPO..."
    TAGS=$(docker images --format "{{.Tag}}" $HOST/$REPO | xargs -n1 | sort --version-sort | xargs)
    ARRAY=($TAGS)
    LEN="$((${#ARRAY[@]}-$NUM_IMAGES))"
    if [[ "$LEN" -gt "0" ]]; then
        D_TAGS=("${ARRAY[@]:0:$LEN}")
        for TAG in ${D_TAGS[@]}
        do
            echo deleting $HOST/$REPO:$TAG with ID: $(docker images -q $HOST/$REPO:$TAG)
            # docker rmi $(docker images -q $HOST/$REPO:$TAG)
        done
    else
        echo "Nothing to delete in $REPO only ${#ARRAY[@]} TAGS exists"
    fi
done