#!/bin/bash

REPOS=$(\
    curl -sS --user docker:silver  https://registry.sreboy.com/v2/_catalog \
    | python3 -c "import sys, json; data=json.load(sys.stdin)['repositories']; [print(repo) for repo in data]"\
)

for REPO in $REPOS
do
    TAGS=$(\
        curl -sS --user docker:silver  https://registry.sreboy.com/v2/$REPO/tags/list \
        | python3 -c "import sys, json; data=json.load(sys.stdin)['tags']; [print(tag) for tag in data]"\
    )
    for TAG in $TAGS
    do
        DIGIST=$(\
            curl -sS --user docker:silver \
            -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
            https://registry.sreboy.com/v2/$REPO/manifests/$TAG \
            | python3 -c "import sys, json; print(json.load(sys.stdin)['config']['digest'])"\
        )
        echo $REPO:$TAG:$DIGIST
    done
    echo ---------------------------
done