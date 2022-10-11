# 🐳 Day 01/03: docker-private-registry
The following will be daily updated as an activity-log to task-progress.
```Console
*** Problem: We have three servers.
$ Server one is running:
  1) Azure Pipeline on localhost.
  2) Docker registry.
$ Server two and three are:
  - Clients pulling from docker-private-registry.
  - They are controlled by docker swarm.
```

## 🔧 Warm up on some crucial concepts
- One docker image can have multiple manifests, each manifest has a unique digest.
- Manifest: can be defined in this context as list of layers for a particular digest.
- Layers are shared amongst manifests, each manifest maintains a set of references to needed layers.
- As long as a layer is referenced by one manifest, it cannot be garbage collected.

## 🦦 Proposed solutions:
### 🧐 For Azure Pipline
```Console
*** In the case of "a few number of runs per day", I suggest 
a daily cron job that deletes all images for the sake of disk-space.
$ docker rmi $(docker images -a -q)
$ Pros:
  - Stupid Simple.
$ Cons:
  - Doker is built to share layers among manifests.
  - This way repeated work will be redone on a daily manner.
  - That might affect the speed of the first few runnes of the day.
```

### 🧐 For Docker registry
#### First solution:
- [ ] A script will ssh to the first server and gain access to doker-registry shell.
- [ ] List all images using one of the following commands:
```Console
ziadh@Ziads-MacBook-Air ~ % docker images                                                  
REPOSITORY                     TAG       IMAGE ID       CREATED        SIZE
ziadmmh/bigoven-backend        latest    2997db7f8fa9   13 days ago    221MB
ziadmmh/bigoven-frontend       latest    c9fb943bf950   13 days ago    221MB
ziadmmh/bigoven-reverseproxy   latest    820d028cd13e   13 days ago    22.1MB
redis                          latest    07dcd1b2e705   4 months ago   111MB
postgres                       latest    12b9b2057476   4 months ago   355MB
gcr.io/k8s-minikube/kicbase    v0.0.30   6a29e77b4fe6   7 months ago   1.04GB
ziadh@Ziads-MacBook-Air ~ % docker images --format "{{.ID}}:{{.Repository}}:{{.Tag}}" 
2997db7f8fa9:ziadmmh/bigoven-backend:latest
c9fb943bf950:ziadmmh/bigoven-frontend:latest
820d028cd13e:ziadmmh/bigoven-reverseproxy:latest
07dcd1b2e705:redis:latest
12b9b2057476:postgres:latest
6a29e77b4fe6:gcr.io/k8s-minikube/kicbase:v0.0.30
```

```Console
*** 🚨 Questions:
$ Are you always using the latest tag?
$ This solution intends to keep only the latest 10 manifests
and reomves others that their digest might be mentioned in some code!
$ What are the naming convention of docker images on the registry?
lost it from meeting-notes ^^
```

- [ ] Keep only the latest 10 manifests of each docker image stored in the docker registry.

#### Second solution - [link](https://docs.docker.com/registry/garbage-collection/):
- [ ] Use v2 docker registry REST API to delete manifests.
- [ ] Run Garbage collector to delete unrefrenced layers - [link](https://mirror-medium.com/?m=https%3A%2F%2Fmedium.com%2Fm%2Fglobal-identity%3FredirectUrl%3Dhttps%253A%252F%252Fbetterprogramming.pub%252Fcleanup-your-docker-registry-ef0527673e3a).
```Console
*** Garbage Collector:
$ Was added to docker registry v2.4.0.
$ This type of garbage collection is known as:
stop-the-world garbage collection
```


## ➕ ToDo:
- [ ] Spin an EC2 instance and create a test enviroment with [private-docker-registry](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-20-04).
- [ ] Test docker-registry first proposed sollution.
- [ ] Create a github action workflow that runs a bash script using [schedule](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule).
- [ ] See if docker swarm can by any means manage / manipulate stored images on local nodes. So, we can put a plan to clean them.


----------


# 🐳 Day 02/03: docker-private-registry - [API](https://registry.sreboy.com/v2/)
```Console
*** My goal for the second day was to:
$ Create a docker-registry on AWS EC2 instance as a test enviroment.
$ Test delete images from docker-private registry.
```


## 🦦 Checklist of the day
- [X] Read: How To Set Up a Private Docker Registry on Ubuntu 20.04 - [link](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-20-04).
- [X] Read: How To Install Nginx on Ubuntu 20.04 - [link](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04).
- [X] Read: How To Secure Nginx with Let's Encrypt on Ubuntu 20.04 - [link](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04).
- [X] Hosted: docker-private-registry at a subdomain of my SREboy.com domain.
- [X] Spin an EC2 instance and create a test enviroment with [private-docker-registry](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-20-04).

```Console
*** to use my private-docker-registry
$ Host: registry.sreboy.com
$ User: docker
$ Password: silver
$ docker login https://registry.sreboy.com
Authenticating with existing credentials...
Login Succeeded
$ docker pull registry.sreboy.com/test-image
Using default tag: latest
latest: Pulling from test-image
Digest: sha256:a3db5309fb6bdd5511699b51fb27b3e3a9e2d1e0aa21ae0dc280d6e81a71fa1e
Status: Image is up to date for registry.sreboy.com/test-image:latest
registry.sreboy.com/test-image:latest
$ docker run -it registry.sreboy.com/test-image /bin/bash
root@01166b678c4f:/# ls
SUCCESS  bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

✅ The ```SUCCESS``` file, confirms that its the same custom ubuntu based image I create and pushed.

## ➕ ToDo:
- [ ] Test delete images from the docker-private-registry - [link](https://stackoverflow.com/questions/25436742/how-to-delete-images-from-a-private-docker-registry).
- [ ] Create a github action workflow that runs a bash script using [schedule](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule).
- [ ] See if docker swarm can by any means manage / manipulate stored images on local nodes. So, we can put a plan to clean them.



# 🐳 Day 03/03: docker-private-registry - [API](https://registry.sreboy.com/v2/)
#### 🧐 My goal for today was to:
- [ ] Create bash script list.sh that calls registry API and list all repositories on the registry plus all (Tags && Digests) withen that repository.
```Console
$ echo $REPO:$TAG:$DIGIST
silver-image:20221007.1_10:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
silver-image:latest:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
```
- [ ] Create bash script generate.sh that:
```Console
$ Creates a dummy image.
$ Generate many Tags of that image following this pattern:
${HOST}/${IMAGE_NAME}:${TODAY}.${DAILY_RUN_NUM}_${RUN_NUM}
$ Push all tags to registry.sreboy.com
```
- [ ] Test delete images from the docker-private-registry - [link](https://stackoverflow.com/questions/25436742/how-to-delete-images-from-a-private-docker-registry).
- [ ] Create bash script mark_digests.sh that calls registry API and delete inactive or old tags:
```Console
$ [1]: Sort all image tags.
silver-image:20221007.1_8:sha256:10e312f5da57219d6e7679d20f083696ab28976674af75662a469fd2b3c7c946
silver-image:20221007.1_9:sha256:8b6197ddd8f55b4bac7499852a29a6ab02ce70f074c8d029a5ba45f4c31c2453
silver-image:20221007.1_10:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
silver-image:latest:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
$ [2]: Checks number of tags and keeps the latest 4 TAGS inluding latest so 
20221007.1_1 till 20221007.1_7 will be DELETED if existed
```
- [ ] Create a bash script to free dick space called garbage_collect.sh that:
```Console
$ [1]: ssh to server and run the following command;
sudo docker exec -it -u root <REGISTRY_CONTAINER_ID> bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml
$ we need to garbage_collect as deleting a tag from the API only makes it inaccessible from API.
```

## 🦦 Checklist of the day
