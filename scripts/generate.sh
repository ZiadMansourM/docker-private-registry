#!/bin/bash

# Generate tags for testing

RUN_NUM=1
DAILY_RUN_NUM=1
IMAGE_NAME=silver-image
HOST=registry.sreboy.com
TODAY=$(date +%Y%m%d)
REPO=alpine

for i in {1..10}
do
    docker run $REPO /bin/touch /foo_$RUN_NUM
    NEW=${HOST}/${IMAGE_NAME}:${TODAY}.${DAILY_RUN_NUM}_${RUN_NUM}
    docker commit $(docker ps -lq) $NEW
    docker container prune --force
    REPO=$NEW
    ((RUN_NUM++))
done

docker tag $REPO $HOST/$IMAGE_NAME:latest
docker run $HOST/$IMAGE_NAME /bin/ls | grep foo
docker push --all-tags $HOST/$IMAGE_NAME