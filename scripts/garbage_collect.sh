#!/bin/bash

# SSH to server and run garbage collection

ID=$(sudo docker ps -q)
echo ID=$ID
# sudo docker exec -u root $ID bin/registry garbage-collect --dry-run --delete-untagged /etc/docker/registry/config.yml
sudo docker exec -u root $ID bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml