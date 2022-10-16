#!/bin/bash

# Deletes all tags but keeps latest 4 tags including 'latest'

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
                curl -v -sS --user $USER:$PASSWORD \
                -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' 2>&1 \
                https://$HOST/v2/$REPO/manifests/$TAG \
                | grep -i "< Docker-Content-Digest:"|awk '{print $3}' \
            )
            IMAGE=$REPO:$TAG:$DIGIST
            echo Deleting $IMAGE
            DIGIST=`echo $DIGIST | sed 's/\\r//g'`
            # echo "'$DIGIST'" | LC_ALL=C cat -vt
            RESPONCE=$(\
                curl -sS -o /dev/null -w "%{http_code}" \
                --user $USER:$PASSWORD \
                -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
                -X DELETE "https://registry.sreboy.com/v2/$REPO/manifests/${DIGIST}" \
            )
            if [[ $RESPONCE -eq "202" ]]; then
                echo "Successfully deleted $IMAGE"
            else
                echo "Failed to delete<$RESPONCE>: $IMAGE"
            fi
        done
    else
        echo "Nothing to delete in $REPO only ${#ARRAY[@]} TAGS exists"
    fi
done

# sudo docker exec -it -u root df6f4d3612e1 bin/registry garbage-collect --dry-run --delete-untagged /etc/docker/registry/config.yml