#!/bin/bash

HOST=registry.sreboy.com
USER=docker
PASSWORD=silver
NUM_IMAGES=4 # Latest, 1st, 2nd, 3rd

REPOS=$(\
    curl -sS --user $USER:$PASSWORD  https://$HOST/v2/_catalog \
    | python3 -c "import sys, json; data=json.load(sys.stdin)['repositories']; [print(repo) for repo in data]"\
)

for REPO in $REPOS
do
    TAGS=$(\
        curl -sS --user $USER:$PASSWORD  https://$HOST/v2/$REPO/tags/list \
        | python3 -c "import sys, json; data=json.load(sys.stdin)['tags']; [print(tag) for tag in data]"\
    )
    TAGS=$(echo $TAGS | xargs -n1 | sort --version-sort | xargs)
    ARRAY=($TAGS)
    LEN="$((${#ARRAY[@]}-$NUM_IMAGES))"
    if [[ "$LEN" -gt "0" ]]; then
        D_TAGS=("${ARRAY[@]:0:$LEN}")
        for TAG in ${D_TAGS[@]}
        do
            DIGIST=$(\
                curl -sS --user $USER:$PASSWORD \
                -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
                https://$HOST/v2/$REPO/manifests/$TAG \
                | python3 -c "import sys, json; print(json.load(sys.stdin)['config']['digest'])"\
            )
            echo $REPO:$TAG:$DIGIST
        done
    fi
done