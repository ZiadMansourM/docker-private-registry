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


<details>
<summary>🚨 Show Day One Log</summary>

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

</details>

----------


# 🐳 Day 02/03: docker-private-registry - [API](https://registry.sreboy.com/v2/)

```Console
*** My goal for the second day was to:
$ Create a docker-registry on AWS EC2 instance as a test enviroment.
$ Test delete images from docker-private registry.
```


<details>
<summary>🚨 Show Day Two Log</summary>


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

</details>

---------------------


# 🐳 Day 03/03: docker-private-registry - [API](https://registry.sreboy.com/v2/)

```Console
*** My goal for the second day was to:
$ [1]: Retrive all repositories' (Tags && Digests) using registry API.
silver-image:20221007.1_10:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
silver-image:latest:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
$ [2]: Create Bash script generate.sh to create dummy image tags and push all tags.
{HOST}/${IMAGE_NAME}:${TODAY}.${DAILY_RUN_NUM}_${RUN_NUM}
$ [3]: Test delete images from docker-private registry.
https://stackoverflow.com/questions/25436742/how-to-delete-images-from-a-private-docker-registry
$ [4]: Create bash script mark_digests.sh that calls registry API and delete inactive or old tags "Sort => Delete":
FIRST_STEP
production-image:20221016.1_1:sha256:71b4eba1665a13d9ad27b02a9480296335dc5937cdd6cc2b4709262bbc1a576a
production-image:20221016.1_2:sha256:b52d978b938250d92ac5349ba3f36d19322e0a1212e58fd13a07a7410119a00f
production-image:20221016.1_3:sha256:6ebb5facb37d39fd695e3572691b88e075a6abf5b5ab7bb834c3fb2cb4e34948
production-image:20221016.1_4:sha256:073b3de8d288dbfc7df5bc5494c9869685953d58a2077649b9b04ed2d0a83916
production-image:20221016.1_5:sha256:4efbdb5d520cd14766a56249307a2ed5b7179ffd00df146d302f91f167b271cf
production-image:20221016.1_6:sha256:1914883789acdd2e0b25e084e94dc2887e53fb8cdd2d74db0c26d15b68b565c2
production-image:20221016.1_7:sha256:6b493b7e5b07551f0daf3d503534596f478cd920e7020d48bb6d6322c4ca37f2
production-image:20221016.1_8:sha256:296c094412f868500a8c522e190f1302db9f4079e11291e01d596ce0a122a7bc
production-image:20221016.1_9:sha256:6588c859f407a074e2c4db2b62352d1ca5cc79d03d88aea0cc9d6f4a41f7be3f
production-image:20221016.1_10:sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7
production-image:latest:sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7
SECOND_STEP
220221016.1_1 till 20221016.1_7 here will be DELETED
$ [5]: Study how mark_digests.sh will react to images with multi tags that doesn't follow naming convention.
$ [6]: Create a bash script to free dick space called garbage_collect.sh.
$ [7]: Push tag to the same repo that you deleted tags from.
$ [8]: Create script ci_clean.sh to clean CI server.
$ [9]: Automate "mark_digests.sh, garbage_collect.sh, ci_clean.sh" on github actions workflow with schedule.
```

<details>
<summary>🚨 Show Day Three Log</summary>

## 🦦 Checklist of the day
- [X] Create bash script [generate.sh](https://github.com/ZiadMansourM/docker-private-registry/blob/master/scripts/generate.sh) that:


<details>
<summary>🧐 Show Output</summary>

```Console
ziadh@Ziads-MacBook-Air clean_master % ./scripts/generate.sh 
sha256:18fbf635b5e09cdbbd8454cb170fef6a4e22be6f887429192704689023bbe8e0
Deleted Containers:
124196f2b4c8d7230c0c1d42c5d22efa9b934998e9e1e8748d5bb01544e4f445

Total reclaimed space: 0B
sha256:4da06046d1119a4060f7feb5a6b03138977b7c39782cf1f7e899a288ce538bb2
Deleted Containers:
4ce4f19e87decd65016594d936600ab1e63dfba13e3354ec9f07467fe229ac39

Total reclaimed space: 0B
sha256:949aff9d65fe994dd9c5dca4f401cb5e13c85171e12e37ae94919852099ef526
Deleted Containers:
355c4b11b1130557224cf8c1c6045ac3ab4bb689c1165534112fb42ee5e1bcbb

Total reclaimed space: 0B
sha256:2486237503e15c2ff36c6bdda8edc255296bc98a3bc81de09dd7614828ea8c8c
Deleted Containers:
ee4a64d7bbc81ca7f688fb97fd373114b4ac3731a161829ce89dd2050ca57b89

Total reclaimed space: 0B
sha256:c114149236cc06f02e863f87ce68cdd88987b15a2207968f6c54f8f544db272e
Deleted Containers:
05c8b5a59dd737d006c08e08614171ec16fbf5106a946c0dcc442d2f77d930dc

Total reclaimed space: 0B
sha256:73e5452efbb749844df577a2d2a99fbfcb796503405eaf3a7b3d262f7107d3c1
Deleted Containers:
580461ee21bfc5610722b7f1989e4c0897bb721fad8ea095e117dff69e4d29fb

Total reclaimed space: 0B
sha256:ff29a2f3391c201fdcf93266dbd193297612e79f6b860ca1831acf7c12072570
Deleted Containers:
9c1fd40a780bbebbb6f169535a7393671e64b79253bf6a2e4dd9c88654857951

Total reclaimed space: 0B
sha256:414586ced36fd5fefb5cf14f17c846b2bc867bc4b93368db81280d4f1a6a2789
Deleted Containers:
494e73fb7d9d0a6bc64e705e84b782de5f336e06dd47c0b31f2bf01a46ae5439

Total reclaimed space: 0B
sha256:5eaeea9317cfd542f70266c424fabc4265e9f3eb18f2959711c5617d56912581
Deleted Containers:
fd198acc688d9ce6b1ea9a5ffd43a17c9302da8aea4cea11de4dd194275b88c8

Total reclaimed space: 0B
sha256:fa133f806baed3fd1e361bb05c289346a0f6e83c990b636d7098d9f0983d2dfc
Deleted Containers:
eef78164a373f30ecc2c57302b1a7ab372886f4179a11cdfe8c668853145457e

Total reclaimed space: 0B
foo_1
foo_10
foo_2
foo_3
foo_4
foo_5
foo_6
foo_7
foo_8
foo_9
The push refers to repository [registry.sreboy.com/production-image]
abddab176b9a: Pushed 
5d3e392a13a0: Mounted from silver-image 
20221016.1_1: digest: sha256:71b4eba1665a13d9ad27b02a9480296335dc5937cdd6cc2b4709262bbc1a576a size: 734
a5ca65ab906f: Pushed 
a69308cba2ad: Pushed 
f3e1547f89a4: Pushed 
d216e5aa938f: Pushed 
7da4d5bfc486: Pushed 
2f7bd36ec15c: Pushed 
ba436780b9b5: Pushed 
c01321fa7d22: Pushed 
12283a55e4a8: Pushed 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_10: digest: sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7 size: 2588
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_2: digest: sha256:b52d978b938250d92ac5349ba3f36d19322e0a1212e58fd13a07a7410119a00f size: 940
c01321fa7d22: Layer already exists 
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_3: digest: sha256:6ebb5facb37d39fd695e3572691b88e075a6abf5b5ab7bb834c3fb2cb4e34948 size: 1146
ba436780b9b5: Layer already exists 
c01321fa7d22: Layer already exists 
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_4: digest: sha256:073b3de8d288dbfc7df5bc5494c9869685953d58a2077649b9b04ed2d0a83916 size: 1352
2f7bd36ec15c: Layer already exists 
ba436780b9b5: Layer already exists 
c01321fa7d22: Layer already exists 
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_5: digest: sha256:4efbdb5d520cd14766a56249307a2ed5b7179ffd00df146d302f91f167b271cf size: 1558
7da4d5bfc486: Layer already exists 
2f7bd36ec15c: Layer already exists 
ba436780b9b5: Layer already exists 
c01321fa7d22: Layer already exists 
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_6: digest: sha256:1914883789acdd2e0b25e084e94dc2887e53fb8cdd2d74db0c26d15b68b565c2 size: 1764
d216e5aa938f: Layer already exists 
7da4d5bfc486: Layer already exists 
2f7bd36ec15c: Layer already exists 
ba436780b9b5: Layer already exists 
c01321fa7d22: Layer already exists 
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_7: digest: sha256:6b493b7e5b07551f0daf3d503534596f478cd920e7020d48bb6d6322c4ca37f2 size: 1970
f3e1547f89a4: Layer already exists 
d216e5aa938f: Layer already exists 
7da4d5bfc486: Layer already exists 
2f7bd36ec15c: Layer already exists 
ba436780b9b5: Layer already exists 
c01321fa7d22: Layer already exists 
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_8: digest: sha256:296c094412f868500a8c522e190f1302db9f4079e11291e01d596ce0a122a7bc size: 2176
a69308cba2ad: Layer already exists 
f3e1547f89a4: Layer already exists 
d216e5aa938f: Layer already exists 
7da4d5bfc486: Layer already exists 
2f7bd36ec15c: Layer already exists 
ba436780b9b5: Layer already exists 
c01321fa7d22: Layer already exists 
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
20221016.1_9: digest: sha256:6588c859f407a074e2c4db2b62352d1ca5cc79d03d88aea0cc9d6f4a41f7be3f size: 2382
a5ca65ab906f: Layer already exists 
a69308cba2ad: Layer already exists 
f3e1547f89a4: Layer already exists 
d216e5aa938f: Layer already exists 
7da4d5bfc486: Layer already exists 
2f7bd36ec15c: Layer already exists 
ba436780b9b5: Layer already exists 
c01321fa7d22: Layer already exists 
12283a55e4a8: Layer already exists 
abddab176b9a: Layer already exists 
5d3e392a13a0: Layer already exists 
latest: digest: sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7 size: 2588
```

</details>

- [X] Create bash script [list.sh](https://github.com/ZiadMansourM/docker-private-registry/blob/master/scripts/list.sh) that calls registry API and list all repositories on the registry plus all (Tags && Digests) withen that repository.

```Console
ziadh@Ziads-MacBook-Air clean_master % ./scripts/list.sh    
hello-image:2:sha256:45e778c30b2c810b1b0d7ddac3119d4424b17db362448c879c0195a22bbfe1ed
hello-image:latest:sha256:45e778c30b2c810b1b0d7ddac3119d4424b17db362448c879c0195a22bbfe1ed
-------------
production-image:20221016.1_1:sha256:71b4eba1665a13d9ad27b02a9480296335dc5937cdd6cc2b4709262bbc1a576a
production-image:20221016.1_2:sha256:b52d978b938250d92ac5349ba3f36d19322e0a1212e58fd13a07a7410119a00f
production-image:20221016.1_3:sha256:6ebb5facb37d39fd695e3572691b88e075a6abf5b5ab7bb834c3fb2cb4e34948
production-image:20221016.1_4:sha256:073b3de8d288dbfc7df5bc5494c9869685953d58a2077649b9b04ed2d0a83916
production-image:20221016.1_5:sha256:4efbdb5d520cd14766a56249307a2ed5b7179ffd00df146d302f91f167b271cf
production-image:20221016.1_6:sha256:1914883789acdd2e0b25e084e94dc2887e53fb8cdd2d74db0c26d15b68b565c2
production-image:20221016.1_7:sha256:6b493b7e5b07551f0daf3d503534596f478cd920e7020d48bb6d6322c4ca37f2
production-image:20221016.1_8:sha256:296c094412f868500a8c522e190f1302db9f4079e11291e01d596ce0a122a7bc
production-image:20221016.1_9:sha256:6588c859f407a074e2c4db2b62352d1ca5cc79d03d88aea0cc9d6f4a41f7be3f
production-image:20221016.1_10:sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7
production-image:latest:sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7
-------------
silver-image:20221007.1_1:
silver-image:20221007.1_2:
silver-image:20221007.1_3:
silver-image:20221007.1_4:
silver-image:20221007.1_5:
silver-image:20221007.1_6:
silver-image:20221007.1_7:
silver-image:20221007.1_8:sha256:10e312f5da57219d6e7679d20f083696ab28976674af75662a469fd2b3c7c946
silver-image:20221007.1_9:sha256:8b6197ddd8f55b4bac7499852a29a6ab02ce70f074c8d029a5ba45f4c31c2453
silver-image:20221007.1_10:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
silver-image:latest:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
-------------
test-image:1:sha256:a3db5309fb6bdd5511699b51fb27b3e3a9e2d1e0aa21ae0dc280d6e81a71fa1e
test-image:2:sha256:5838622a7a600001ea5ecba77b30c20f563855b974126089a46f4d8a632095fd
test-image:3:sha256:d54695c0b88d1b006f70388ce0b61cc3b1a0ad7d977cc848b8c1fcd3b5958043
test-image:latest:sha256:d54695c0b88d1b006f70388ce0b61cc3b1a0ad7d977cc848b8c1fcd3b5958043
-------------
ziadh@Ziads-MacBook-Air clean_master %
```
- [X] Test delete images from the docker-private-registry - [link](https://stackoverflow.com/questions/25436742/how-to-delete-images-from-a-private-docker-registry).
- [X] Create bash script [mark_digests.sh](https://github.com/ZiadMansourM/docker-private-registry/blob/master/scripts/mark_digests.sh) that calls registry API and delete inactive or old tags:
```Console
ziadh@Ziads-MacBook-Air clean_master % ./scripts/mark_digests.sh 
Nothing to delete in hello-image only 2 TAGS exists
Deleting production-image:20221016.1_1:sha256:71b4eba1665a13d9ad27b02a9480296335dc5937cdd6cc2b4709262bbc1a576a
Successfully deleted production-image:20221016.1_1:sha256:71b4eba1665a13d9ad27b02a9480296335dc5937cdd6cc2b4709262bbc1a576a
Deleting production-image:20221016.1_2:sha256:b52d978b938250d92ac5349ba3f36d19322e0a1212e58fd13a07a7410119a00f
Successfully deleted production-image:20221016.1_2:sha256:b52d978b938250d92ac5349ba3f36d19322e0a1212e58fd13a07a7410119a00f
Deleting production-image:20221016.1_3:sha256:6ebb5facb37d39fd695e3572691b88e075a6abf5b5ab7bb834c3fb2cb4e34948
Successfully deleted production-image:20221016.1_3:sha256:6ebb5facb37d39fd695e3572691b88e075a6abf5b5ab7bb834c3fb2cb4e34948
Deleting production-image:20221016.1_4:sha256:073b3de8d288dbfc7df5bc5494c9869685953d58a2077649b9b04ed2d0a83916
Successfully deleted production-image:20221016.1_4:sha256:073b3de8d288dbfc7df5bc5494c9869685953d58a2077649b9b04ed2d0a83916
Deleting production-image:20221016.1_5:sha256:4efbdb5d520cd14766a56249307a2ed5b7179ffd00df146d302f91f167b271cf
Successfully deleted production-image:20221016.1_5:sha256:4efbdb5d520cd14766a56249307a2ed5b7179ffd00df146d302f91f167b271cf
Deleting production-image:20221016.1_6:sha256:1914883789acdd2e0b25e084e94dc2887e53fb8cdd2d74db0c26d15b68b565c2
Successfully deleted production-image:20221016.1_6:sha256:1914883789acdd2e0b25e084e94dc2887e53fb8cdd2d74db0c26d15b68b565c2
Deleting production-image:20221016.1_7:sha256:6b493b7e5b07551f0daf3d503534596f478cd920e7020d48bb6d6322c4ca37f2
Successfully deleted production-image:20221016.1_7:sha256:6b493b7e5b07551f0daf3d503534596f478cd920e7020d48bb6d6322c4ca37f2
Deleting silver-image:20221007.1_1:
Failed to delete<404>: silver-image:20221007.1_1:
Deleting silver-image:20221007.1_2:
Failed to delete<404>: silver-image:20221007.1_2:
Deleting silver-image:20221007.1_3:
Failed to delete<404>: silver-image:20221007.1_3:
Deleting silver-image:20221007.1_4:
Failed to delete<404>: silver-image:20221007.1_4:
Deleting silver-image:20221007.1_5:
Failed to delete<404>: silver-image:20221007.1_5:
Deleting silver-image:20221007.1_6:
Failed to delete<404>: silver-image:20221007.1_6:
Deleting silver-image:20221007.1_7:
Failed to delete<404>: silver-image:20221007.1_7:
Nothing to delete in test-image only 4 TAGS exists
ziadh@Ziads-MacBook-Air clean_master % ./scripts/list.sh                                    
hello-image:2:sha256:45e778c30b2c810b1b0d7ddac3119d4424b17db362448c879c0195a22bbfe1ed
hello-image:latest:sha256:45e778c30b2c810b1b0d7ddac3119d4424b17db362448c879c0195a22bbfe1ed
-------------
production-image:20221016.1_8:sha256:296c094412f868500a8c522e190f1302db9f4079e11291e01d596ce0a122a7bc
production-image:20221016.1_9:sha256:6588c859f407a074e2c4db2b62352d1ca5cc79d03d88aea0cc9d6f4a41f7be3f
production-image:20221016.1_10:sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7
production-image:latest:sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7
-------------
silver-image:20221007.1_1:
silver-image:20221007.1_2:
silver-image:20221007.1_3:
silver-image:20221007.1_4:
silver-image:20221007.1_5:
silver-image:20221007.1_6:
silver-image:20221007.1_7:
silver-image:20221007.1_8:sha256:10e312f5da57219d6e7679d20f083696ab28976674af75662a469fd2b3c7c946
silver-image:20221007.1_9:sha256:8b6197ddd8f55b4bac7499852a29a6ab02ce70f074c8d029a5ba45f4c31c2453
silver-image:20221007.1_10:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
silver-image:latest:sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679
-------------
test-image:1:sha256:a3db5309fb6bdd5511699b51fb27b3e3a9e2d1e0aa21ae0dc280d6e81a71fa1e
test-image:2:sha256:5838622a7a600001ea5ecba77b30c20f563855b974126089a46f4d8a632095fd
test-image:3:sha256:d54695c0b88d1b006f70388ce0b61cc3b1a0ad7d977cc848b8c1fcd3b5958043
test-image:latest:sha256:d54695c0b88d1b006f70388ce0b61cc3b1a0ad7d977cc848b8c1fcd3b5958043
-------------
ziadh@Ziads-MacBook-Air clean_master % 
```

- [X] Create a bash script to free dick space called [garbage_collect.sh](https://github.com/ZiadMansourM/docker-private-registry/blob/master/scripts/garbage_collect.sh) that:
#### ⚠️ --dry-run


<details>
<summary>🧐 Show Output</summary>

```Console
ziadh@Ziads-MacBook-Air clean_master % cat ./scripts/garbage_collect.sh | ssh docker-registry
ID=df6f4d3612e1
hello-image
hello-image: marking manifest sha256:45e778c30b2c810b1b0d7ddac3119d4424b17db362448c879c0195a22bbfe1ed 
hello-image: marking blob sha256:b8f9afbe6d5d6f4b7c2e44d30608829493e8e87820157772fdd64b6e84437095
hello-image: marking blob sha256:d6cb415e2683249f7884ee5367306b023c72f907afeca2a30ca19c8de5f4f7d9
hello-image: marking blob sha256:4f2d2f291256a0f88dca16d524ef038732c1d826353b1e5d7b9645a8933fe2c0
hello-image: marking blob sha256:df68eda342813dc9b3568f4b95c1ae03a1de5b74ab82260b4bd314fbb89d1bf3
production-image
production-image: marking manifest sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7 
production-image: marking blob sha256:fa133f806baed3fd1e361bb05c289346a0f6e83c990b636d7098d9f0983d2dfc
production-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
production-image: marking blob sha256:dbd982a5d219b09d93ad578130a6288a44a33177155fd8b3db5585d3bca4e2e6
production-image: marking blob sha256:ac4d9ad5b868e840b2a3415bfb13f352ccd77b0696633aa2fb0e81a782648a8e
production-image: marking blob sha256:93519bfae770eb8e499e4a97e16ff44471878d65b198ce73c8f1a002862f34da
production-image: marking blob sha256:908ecdfdaf9d1b2b19a754ae8c042f2850f64e0a83ae987ee070206e8da567a7
production-image: marking blob sha256:ddea90c61eefd4aababaf5f3477d0775a0a456469aba09fdcbe642f29962ebe4
production-image: marking blob sha256:2da0da98f501468ad137e600d5da4efccbf27183ed33d50163954e820159a5fb
production-image: marking blob sha256:c1b39b67fe233e3f0fb6ff1368b45725b4d9832ac2c1849704aa957e59e3e289
production-image: marking blob sha256:b87a34d3a1a9ae30313c6491e5a8aadadb0776cc75c6a33e3941acb33d43bdf8
production-image: marking blob sha256:32e387898ab9608863698cdf7bb97954b3bd29460809c1207ee8ca695bc4eb12
production-image: marking blob sha256:96937f9f2cf28b1506f8ec93810e2db5484bf0a46fa9ddec1cbc949946fd1db3
production-image: marking manifest sha256:296c094412f868500a8c522e190f1302db9f4079e11291e01d596ce0a122a7bc 
production-image: marking blob sha256:414586ced36fd5fefb5cf14f17c846b2bc867bc4b93368db81280d4f1a6a2789
production-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
production-image: marking blob sha256:dbd982a5d219b09d93ad578130a6288a44a33177155fd8b3db5585d3bca4e2e6
production-image: marking blob sha256:ac4d9ad5b868e840b2a3415bfb13f352ccd77b0696633aa2fb0e81a782648a8e
production-image: marking blob sha256:93519bfae770eb8e499e4a97e16ff44471878d65b198ce73c8f1a002862f34da
production-image: marking blob sha256:908ecdfdaf9d1b2b19a754ae8c042f2850f64e0a83ae987ee070206e8da567a7
production-image: marking blob sha256:ddea90c61eefd4aababaf5f3477d0775a0a456469aba09fdcbe642f29962ebe4
production-image: marking blob sha256:2da0da98f501468ad137e600d5da4efccbf27183ed33d50163954e820159a5fb
production-image: marking blob sha256:c1b39b67fe233e3f0fb6ff1368b45725b4d9832ac2c1849704aa957e59e3e289
production-image: marking blob sha256:b87a34d3a1a9ae30313c6491e5a8aadadb0776cc75c6a33e3941acb33d43bdf8
production-image: marking manifest sha256:6588c859f407a074e2c4db2b62352d1ca5cc79d03d88aea0cc9d6f4a41f7be3f 
production-image: marking blob sha256:5eaeea9317cfd542f70266c424fabc4265e9f3eb18f2959711c5617d56912581
production-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
production-image: marking blob sha256:dbd982a5d219b09d93ad578130a6288a44a33177155fd8b3db5585d3bca4e2e6
production-image: marking blob sha256:ac4d9ad5b868e840b2a3415bfb13f352ccd77b0696633aa2fb0e81a782648a8e
production-image: marking blob sha256:93519bfae770eb8e499e4a97e16ff44471878d65b198ce73c8f1a002862f34da
production-image: marking blob sha256:908ecdfdaf9d1b2b19a754ae8c042f2850f64e0a83ae987ee070206e8da567a7
production-image: marking blob sha256:ddea90c61eefd4aababaf5f3477d0775a0a456469aba09fdcbe642f29962ebe4
production-image: marking blob sha256:2da0da98f501468ad137e600d5da4efccbf27183ed33d50163954e820159a5fb
production-image: marking blob sha256:c1b39b67fe233e3f0fb6ff1368b45725b4d9832ac2c1849704aa957e59e3e289
production-image: marking blob sha256:b87a34d3a1a9ae30313c6491e5a8aadadb0776cc75c6a33e3941acb33d43bdf8
production-image: marking blob sha256:32e387898ab9608863698cdf7bb97954b3bd29460809c1207ee8ca695bc4eb12
silver-image
silver-image: marking manifest sha256:10e312f5da57219d6e7679d20f083696ab28976674af75662a469fd2b3c7c946 
silver-image: marking blob sha256:4941a4f73bf6b5df0f8cfc48a1a7a406ff2456d4864a4e4bc2fff0c06fdb5902
silver-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
silver-image: marking blob sha256:4254897e0ee1ff435b70f2049bbf39fbce706dc7d778c6409c4cd26fcaddfa32
silver-image: marking blob sha256:ba5d72e362bca8461f48c68a62f4fa7bd9350742eab9e4cd0e3b7049a13c8cb2
silver-image: marking blob sha256:9ac7bdb8e41a92f61984dd8357c4884b725fe90c1ddaf2b843d4bfc3a6b6d4d6
silver-image: marking blob sha256:f6959cc40267d933a41ec47797adbc0645c728f4e7ea48fedad7f74bf3a60d49
silver-image: marking blob sha256:2ae3c563be11d4339a199f5808b3d953ee8a77c1a926f843d128fbeb7e972bd5
silver-image: marking blob sha256:d822245669341db2ecca17eafccff99142e583b6ea6f79dac077dbf318a5a7ee
silver-image: marking blob sha256:65c9d3277e6befb97351173c5eeb13f6182f5813c24e21ee3e1c5d996bf0fa51
silver-image: marking blob sha256:b436bdfa179f30d558fc8bb5028da2ee9825255ebdf934790d6c659e5e6055ee
silver-image: marking manifest sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679 
silver-image: marking blob sha256:e111aff8da5ed14e95d68593e31edc42f0d9ce6d95af9bb146be0be2be6d8f86
silver-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
silver-image: marking blob sha256:4254897e0ee1ff435b70f2049bbf39fbce706dc7d778c6409c4cd26fcaddfa32
silver-image: marking blob sha256:ba5d72e362bca8461f48c68a62f4fa7bd9350742eab9e4cd0e3b7049a13c8cb2
silver-image: marking blob sha256:9ac7bdb8e41a92f61984dd8357c4884b725fe90c1ddaf2b843d4bfc3a6b6d4d6
silver-image: marking blob sha256:f6959cc40267d933a41ec47797adbc0645c728f4e7ea48fedad7f74bf3a60d49
silver-image: marking blob sha256:2ae3c563be11d4339a199f5808b3d953ee8a77c1a926f843d128fbeb7e972bd5
silver-image: marking blob sha256:d822245669341db2ecca17eafccff99142e583b6ea6f79dac077dbf318a5a7ee
silver-image: marking blob sha256:65c9d3277e6befb97351173c5eeb13f6182f5813c24e21ee3e1c5d996bf0fa51
silver-image: marking blob sha256:b436bdfa179f30d558fc8bb5028da2ee9825255ebdf934790d6c659e5e6055ee
silver-image: marking blob sha256:73a06754f38ba74783e1298bd1733f8a7616c01e428428df4fb1c51896683484
silver-image: marking blob sha256:54b6b388e94c9295104d5dd676681abf6c41fd76ec6c267bc3210b13110a0d0e
silver-image: marking manifest sha256:8b6197ddd8f55b4bac7499852a29a6ab02ce70f074c8d029a5ba45f4c31c2453 
silver-image: marking blob sha256:b0f64127739f35ea181dedbf1edf571c2cb58994266933182e8ae1f33a4891d1
silver-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
silver-image: marking blob sha256:4254897e0ee1ff435b70f2049bbf39fbce706dc7d778c6409c4cd26fcaddfa32
silver-image: marking blob sha256:ba5d72e362bca8461f48c68a62f4fa7bd9350742eab9e4cd0e3b7049a13c8cb2
silver-image: marking blob sha256:9ac7bdb8e41a92f61984dd8357c4884b725fe90c1ddaf2b843d4bfc3a6b6d4d6
silver-image: marking blob sha256:f6959cc40267d933a41ec47797adbc0645c728f4e7ea48fedad7f74bf3a60d49
silver-image: marking blob sha256:2ae3c563be11d4339a199f5808b3d953ee8a77c1a926f843d128fbeb7e972bd5
silver-image: marking blob sha256:d822245669341db2ecca17eafccff99142e583b6ea6f79dac077dbf318a5a7ee
silver-image: marking blob sha256:65c9d3277e6befb97351173c5eeb13f6182f5813c24e21ee3e1c5d996bf0fa51
silver-image: marking blob sha256:b436bdfa179f30d558fc8bb5028da2ee9825255ebdf934790d6c659e5e6055ee
silver-image: marking blob sha256:73a06754f38ba74783e1298bd1733f8a7616c01e428428df4fb1c51896683484
test-image
test-image: marking manifest sha256:5838622a7a600001ea5ecba77b30c20f563855b974126089a46f4d8a632095fd 
test-image: marking blob sha256:9d53651dd49b3512643a54ca9ee24f00f1ba295c602aae0978233dc0d646b965
test-image: marking blob sha256:00f50047d6061c27e70588a5aab89adada756e87d782a6c6bd08b4139eb8ea10
test-image: marking blob sha256:403c4db99b08d9b39f2a403876c111f2220f81d852095e5523147f0b0a276a33
test-image: marking blob sha256:829f640dc595f57f22909a1cfa8c47822eb9f09b403462294eaa4bb93c4f2c64
test-image: marking manifest sha256:a3db5309fb6bdd5511699b51fb27b3e3a9e2d1e0aa21ae0dc280d6e81a71fa1e 
test-image: marking blob sha256:5fe9cf0be56d92fce19fb4e0037ec84b1b46e355c641957ddd19b57cc8c0b0f3
test-image: marking blob sha256:00f50047d6061c27e70588a5aab89adada756e87d782a6c6bd08b4139eb8ea10
test-image: marking blob sha256:403c4db99b08d9b39f2a403876c111f2220f81d852095e5523147f0b0a276a33
test-image: marking manifest sha256:d54695c0b88d1b006f70388ce0b61cc3b1a0ad7d977cc848b8c1fcd3b5958043 
test-image: marking blob sha256:c67c567989a2d9dcd55ff8f7effaa1655fdfd596bf28fb19083f64dc8eb785f6
test-image: marking blob sha256:00f50047d6061c27e70588a5aab89adada756e87d782a6c6bd08b4139eb8ea10
test-image: marking blob sha256:403c4db99b08d9b39f2a403876c111f2220f81d852095e5523147f0b0a276a33
test-image: marking blob sha256:829f640dc595f57f22909a1cfa8c47822eb9f09b403462294eaa4bb93c4f2c64
test-image: marking blob sha256:1b69d5a2551fe43a1dde135896163568d68c6c891af8cf64ddae741f4eaa4909

48 blobs marked, 21 blobs and 0 manifests eligible for deletion
blob eligible for deletion: sha256:71b4eba1665a13d9ad27b02a9480296335dc5937cdd6cc2b4709262bbc1a576a
blob eligible for deletion: sha256:b52d978b938250d92ac5349ba3f36d19322e0a1212e58fd13a07a7410119a00f
blob eligible for deletion: sha256:c18311aa18495d6b85c3541d39b254136822c0764e793188656877ae337b7f3b
blob eligible for deletion: sha256:073b3de8d288dbfc7df5bc5494c9869685953d58a2077649b9b04ed2d0a83916
blob eligible for deletion: sha256:4da06046d1119a4060f7feb5a6b03138977b7c39782cf1f7e899a288ce538bb2
blob eligible for deletion: sha256:4efbdb5d520cd14766a56249307a2ed5b7179ffd00df146d302f91f167b271cf
blob eligible for deletion: sha256:6b493b7e5b07551f0daf3d503534596f478cd920e7020d48bb6d6322c4ca37f2
blob eligible for deletion: sha256:18fbf635b5e09cdbbd8454cb170fef6a4e22be6f887429192704689023bbe8e0
blob eligible for deletion: sha256:600b48b04b110ca327b0dbcedd986c4f1f01c4491de564f0c6bd3a165c6d62c8
blob eligible for deletion: sha256:94e64f98cba7102e7570dbbe8ea78e750084fdce8dd3f8b31d239727a682ddaa
blob eligible for deletion: sha256:73e5452efbb749844df577a2d2a99fbfcb796503405eaf3a7b3d262f7107d3c1
blob eligible for deletion: sha256:949aff9d65fe994dd9c5dca4f401cb5e13c85171e12e37ae94919852099ef526
blob eligible for deletion: sha256:1914883789acdd2e0b25e084e94dc2887e53fb8cdd2d74db0c26d15b68b565c2
blob eligible for deletion: sha256:2486237503e15c2ff36c6bdda8edc255296bc98a3bc81de09dd7614828ea8c8c
blob eligible for deletion: sha256:31a5d0539b42ad28dbd7d798858a4b23c33ab7fcc56d64584048d9bc1dcb2327
blob eligible for deletion: sha256:6ebb5facb37d39fd695e3572691b88e075a6abf5b5ab7bb834c3fb2cb4e34948
blob eligible for deletion: sha256:ff29a2f3391c201fdcf93266dbd193297612e79f6b860ca1831acf7c12072570
blob eligible for deletion: sha256:082a039afb5daa3c82bf953fc14059e19bf25c68560bd5651c8bbf38b1c9d7ba
blob eligible for deletion: sha256:9c796eecf2b9d178204c0e98295121203da156ef702a9ec04c1afb3c387660e9
blob eligible for deletion: sha256:9f29da67fdbf1ae21f1ad0df18452f87f543a3a74ca5f05b5c223c9ce852161a
blob eligible for deletion: sha256:c114149236cc06f02e863f87ce68cdd88987b15a2207968f6c54f8f544db272e
ziadh@Ziads-MacBook-Air clean_master % 
```

</details>

#### ⚠️ removed --dry-run


<details>
<summary>🧐 Show Output</summary>


```Console
ziadh@Ziads-MacBook-Air clean_master % cat ./scripts/garbage_collect.sh | ssh docker-registry
ID=df6f4d3612e1
hello-image
hello-image: marking manifest sha256:45e778c30b2c810b1b0d7ddac3119d4424b17db362448c879c0195a22bbfe1ed 
hello-image: marking blob sha256:b8f9afbe6d5d6f4b7c2e44d30608829493e8e87820157772fdd64b6e84437095
hello-image: marking blob sha256:d6cb415e2683249f7884ee5367306b023c72f907afeca2a30ca19c8de5f4f7d9
hello-image: marking blob sha256:4f2d2f291256a0f88dca16d524ef038732c1d826353b1e5d7b9645a8933fe2c0
hello-image: marking blob sha256:df68eda342813dc9b3568f4b95c1ae03a1de5b74ab82260b4bd314fbb89d1bf3
production-image
production-image: marking manifest sha256:163d50f50d389ea7d187cd4eed62bb66f50672c0ef7a6b8cdd51a3aef955dea7 
production-image: marking blob sha256:fa133f806baed3fd1e361bb05c289346a0f6e83c990b636d7098d9f0983d2dfc
production-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
production-image: marking blob sha256:dbd982a5d219b09d93ad578130a6288a44a33177155fd8b3db5585d3bca4e2e6
production-image: marking blob sha256:ac4d9ad5b868e840b2a3415bfb13f352ccd77b0696633aa2fb0e81a782648a8e
production-image: marking blob sha256:93519bfae770eb8e499e4a97e16ff44471878d65b198ce73c8f1a002862f34da
production-image: marking blob sha256:908ecdfdaf9d1b2b19a754ae8c042f2850f64e0a83ae987ee070206e8da567a7
production-image: marking blob sha256:ddea90c61eefd4aababaf5f3477d0775a0a456469aba09fdcbe642f29962ebe4
production-image: marking blob sha256:2da0da98f501468ad137e600d5da4efccbf27183ed33d50163954e820159a5fb
production-image: marking blob sha256:c1b39b67fe233e3f0fb6ff1368b45725b4d9832ac2c1849704aa957e59e3e289
production-image: marking blob sha256:b87a34d3a1a9ae30313c6491e5a8aadadb0776cc75c6a33e3941acb33d43bdf8
production-image: marking blob sha256:32e387898ab9608863698cdf7bb97954b3bd29460809c1207ee8ca695bc4eb12
production-image: marking blob sha256:96937f9f2cf28b1506f8ec93810e2db5484bf0a46fa9ddec1cbc949946fd1db3
production-image: marking manifest sha256:296c094412f868500a8c522e190f1302db9f4079e11291e01d596ce0a122a7bc 
production-image: marking blob sha256:414586ced36fd5fefb5cf14f17c846b2bc867bc4b93368db81280d4f1a6a2789
production-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
production-image: marking blob sha256:dbd982a5d219b09d93ad578130a6288a44a33177155fd8b3db5585d3bca4e2e6
production-image: marking blob sha256:ac4d9ad5b868e840b2a3415bfb13f352ccd77b0696633aa2fb0e81a782648a8e
production-image: marking blob sha256:93519bfae770eb8e499e4a97e16ff44471878d65b198ce73c8f1a002862f34da
production-image: marking blob sha256:908ecdfdaf9d1b2b19a754ae8c042f2850f64e0a83ae987ee070206e8da567a7
production-image: marking blob sha256:ddea90c61eefd4aababaf5f3477d0775a0a456469aba09fdcbe642f29962ebe4
production-image: marking blob sha256:2da0da98f501468ad137e600d5da4efccbf27183ed33d50163954e820159a5fb
production-image: marking blob sha256:c1b39b67fe233e3f0fb6ff1368b45725b4d9832ac2c1849704aa957e59e3e289
production-image: marking blob sha256:b87a34d3a1a9ae30313c6491e5a8aadadb0776cc75c6a33e3941acb33d43bdf8
production-image: marking manifest sha256:6588c859f407a074e2c4db2b62352d1ca5cc79d03d88aea0cc9d6f4a41f7be3f 
production-image: marking blob sha256:5eaeea9317cfd542f70266c424fabc4265e9f3eb18f2959711c5617d56912581
production-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
production-image: marking blob sha256:dbd982a5d219b09d93ad578130a6288a44a33177155fd8b3db5585d3bca4e2e6
production-image: marking blob sha256:ac4d9ad5b868e840b2a3415bfb13f352ccd77b0696633aa2fb0e81a782648a8e
production-image: marking blob sha256:93519bfae770eb8e499e4a97e16ff44471878d65b198ce73c8f1a002862f34da
production-image: marking blob sha256:908ecdfdaf9d1b2b19a754ae8c042f2850f64e0a83ae987ee070206e8da567a7
production-image: marking blob sha256:ddea90c61eefd4aababaf5f3477d0775a0a456469aba09fdcbe642f29962ebe4
production-image: marking blob sha256:2da0da98f501468ad137e600d5da4efccbf27183ed33d50163954e820159a5fb
production-image: marking blob sha256:c1b39b67fe233e3f0fb6ff1368b45725b4d9832ac2c1849704aa957e59e3e289
production-image: marking blob sha256:b87a34d3a1a9ae30313c6491e5a8aadadb0776cc75c6a33e3941acb33d43bdf8
production-image: marking blob sha256:32e387898ab9608863698cdf7bb97954b3bd29460809c1207ee8ca695bc4eb12
silver-image
silver-image: marking manifest sha256:10e312f5da57219d6e7679d20f083696ab28976674af75662a469fd2b3c7c946 
silver-image: marking blob sha256:4941a4f73bf6b5df0f8cfc48a1a7a406ff2456d4864a4e4bc2fff0c06fdb5902
silver-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
silver-image: marking blob sha256:4254897e0ee1ff435b70f2049bbf39fbce706dc7d778c6409c4cd26fcaddfa32
silver-image: marking blob sha256:ba5d72e362bca8461f48c68a62f4fa7bd9350742eab9e4cd0e3b7049a13c8cb2
silver-image: marking blob sha256:9ac7bdb8e41a92f61984dd8357c4884b725fe90c1ddaf2b843d4bfc3a6b6d4d6
silver-image: marking blob sha256:f6959cc40267d933a41ec47797adbc0645c728f4e7ea48fedad7f74bf3a60d49
silver-image: marking blob sha256:2ae3c563be11d4339a199f5808b3d953ee8a77c1a926f843d128fbeb7e972bd5
silver-image: marking blob sha256:d822245669341db2ecca17eafccff99142e583b6ea6f79dac077dbf318a5a7ee
silver-image: marking blob sha256:65c9d3277e6befb97351173c5eeb13f6182f5813c24e21ee3e1c5d996bf0fa51
silver-image: marking blob sha256:b436bdfa179f30d558fc8bb5028da2ee9825255ebdf934790d6c659e5e6055ee
silver-image: marking manifest sha256:5481b25ec3be8bd7015b40788a0d4a3fdeecd94066fa2e8f55e12c6e77905679 
silver-image: marking blob sha256:e111aff8da5ed14e95d68593e31edc42f0d9ce6d95af9bb146be0be2be6d8f86
silver-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
silver-image: marking blob sha256:4254897e0ee1ff435b70f2049bbf39fbce706dc7d778c6409c4cd26fcaddfa32
silver-image: marking blob sha256:ba5d72e362bca8461f48c68a62f4fa7bd9350742eab9e4cd0e3b7049a13c8cb2
silver-image: marking blob sha256:9ac7bdb8e41a92f61984dd8357c4884b725fe90c1ddaf2b843d4bfc3a6b6d4d6
silver-image: marking blob sha256:f6959cc40267d933a41ec47797adbc0645c728f4e7ea48fedad7f74bf3a60d49
silver-image: marking blob sha256:2ae3c563be11d4339a199f5808b3d953ee8a77c1a926f843d128fbeb7e972bd5
silver-image: marking blob sha256:d822245669341db2ecca17eafccff99142e583b6ea6f79dac077dbf318a5a7ee
silver-image: marking blob sha256:65c9d3277e6befb97351173c5eeb13f6182f5813c24e21ee3e1c5d996bf0fa51
silver-image: marking blob sha256:b436bdfa179f30d558fc8bb5028da2ee9825255ebdf934790d6c659e5e6055ee
silver-image: marking blob sha256:73a06754f38ba74783e1298bd1733f8a7616c01e428428df4fb1c51896683484
silver-image: marking blob sha256:54b6b388e94c9295104d5dd676681abf6c41fd76ec6c267bc3210b13110a0d0e
silver-image: marking manifest sha256:8b6197ddd8f55b4bac7499852a29a6ab02ce70f074c8d029a5ba45f4c31c2453 
silver-image: marking blob sha256:b0f64127739f35ea181dedbf1edf571c2cb58994266933182e8ae1f33a4891d1
silver-image: marking blob sha256:9b18e9b68314027565b90ff6189d65942c0f7986da80df008b8431276885218e
silver-image: marking blob sha256:4254897e0ee1ff435b70f2049bbf39fbce706dc7d778c6409c4cd26fcaddfa32
silver-image: marking blob sha256:ba5d72e362bca8461f48c68a62f4fa7bd9350742eab9e4cd0e3b7049a13c8cb2
silver-image: marking blob sha256:9ac7bdb8e41a92f61984dd8357c4884b725fe90c1ddaf2b843d4bfc3a6b6d4d6
silver-image: marking blob sha256:f6959cc40267d933a41ec47797adbc0645c728f4e7ea48fedad7f74bf3a60d49
silver-image: marking blob sha256:2ae3c563be11d4339a199f5808b3d953ee8a77c1a926f843d128fbeb7e972bd5
silver-image: marking blob sha256:d822245669341db2ecca17eafccff99142e583b6ea6f79dac077dbf318a5a7ee
silver-image: marking blob sha256:65c9d3277e6befb97351173c5eeb13f6182f5813c24e21ee3e1c5d996bf0fa51
silver-image: marking blob sha256:b436bdfa179f30d558fc8bb5028da2ee9825255ebdf934790d6c659e5e6055ee
silver-image: marking blob sha256:73a06754f38ba74783e1298bd1733f8a7616c01e428428df4fb1c51896683484
test-image
test-image: marking manifest sha256:5838622a7a600001ea5ecba77b30c20f563855b974126089a46f4d8a632095fd 
test-image: marking blob sha256:9d53651dd49b3512643a54ca9ee24f00f1ba295c602aae0978233dc0d646b965
test-image: marking blob sha256:00f50047d6061c27e70588a5aab89adada756e87d782a6c6bd08b4139eb8ea10
test-image: marking blob sha256:403c4db99b08d9b39f2a403876c111f2220f81d852095e5523147f0b0a276a33
test-image: marking blob sha256:829f640dc595f57f22909a1cfa8c47822eb9f09b403462294eaa4bb93c4f2c64
test-image: marking manifest sha256:a3db5309fb6bdd5511699b51fb27b3e3a9e2d1e0aa21ae0dc280d6e81a71fa1e 
test-image: marking blob sha256:5fe9cf0be56d92fce19fb4e0037ec84b1b46e355c641957ddd19b57cc8c0b0f3
test-image: marking blob sha256:00f50047d6061c27e70588a5aab89adada756e87d782a6c6bd08b4139eb8ea10
test-image: marking blob sha256:403c4db99b08d9b39f2a403876c111f2220f81d852095e5523147f0b0a276a33
test-image: marking manifest sha256:d54695c0b88d1b006f70388ce0b61cc3b1a0ad7d977cc848b8c1fcd3b5958043 
test-image: marking blob sha256:c67c567989a2d9dcd55ff8f7effaa1655fdfd596bf28fb19083f64dc8eb785f6
test-image: marking blob sha256:00f50047d6061c27e70588a5aab89adada756e87d782a6c6bd08b4139eb8ea10
test-image: marking blob sha256:403c4db99b08d9b39f2a403876c111f2220f81d852095e5523147f0b0a276a33
test-image: marking blob sha256:829f640dc595f57f22909a1cfa8c47822eb9f09b403462294eaa4bb93c4f2c64
test-image: marking blob sha256:1b69d5a2551fe43a1dde135896163568d68c6c891af8cf64ddae741f4eaa4909

48 blobs marked, 21 blobs and 0 manifests eligible for deletion
blob eligible for deletion: sha256:082a039afb5daa3c82bf953fc14059e19bf25c68560bd5651c8bbf38b1c9d7ba
blob eligible for deletion: sha256:949aff9d65fe994dd9c5dca4f401cb5e13c85171e12e37ae94919852099ef526
blob eligible for deletion: sha256:94e64f98cba7102e7570dbbe8ea78e750084fdce8dd3f8b31d239727a682ddaa
blob eligible for deletion: sha256:9f29da67fdbf1ae21f1ad0df18452f87f543a3a74ca5f05b5c223c9ce852161a
blob eligible for deletion: sha256:c18311aa18495d6b85c3541d39b254136822c0764e793188656877ae337b7f3b
blob eligible for deletion: sha256:18fbf635b5e09cdbbd8454cb170fef6a4e22be6f887429192704689023bbe8e0
blob eligible for deletion: sha256:1914883789acdd2e0b25e084e94dc2887e53fb8cdd2d74db0c26d15b68b565c2
time="2022-10-16T22:35:14.653452148Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/08/082a039afb5daa3c82bf953fc14059e19bf25c68560bd5651c8bbf38b1c9d7ba" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.655413576Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/94/949aff9d65fe994dd9c5dca4f401cb5e13c85171e12e37ae94919852099ef526" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.655994712Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/94/94e64f98cba7102e7570dbbe8ea78e750084fdce8dd3f8b31d239727a682ddaa" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.656540121Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/9f/9f29da67fdbf1ae21f1ad0df18452f87f543a3a74ca5f05b5c223c9ce852161a" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.65707149Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/c1/c18311aa18495d6b85c3541d39b254136822c0764e793188656877ae337b7f3b" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.657588489Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/18/18fbf635b5e09cdbbd8454cb170fef6a4e22be6f887429192704689023bbe8e0" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
blob eligible for deletion: sha256:31a5d0539b42ad28dbd7d798858a4b23c33ab7fcc56d64584048d9bc1dcb2327
blob eligible for deletion: sha256:6ebb5facb37d39fd695e3572691b88e075a6abf5b5ab7bb834c3fb2cb4e34948
blob eligible for deletion: sha256:73e5452efbb749844df577a2d2a99fbfcb796503405eaf3a7b3d262f7107d3c1
time="2022-10-16T22:35:14.658148873Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/19/1914883789acdd2e0b25e084e94dc2887e53fb8cdd2d74db0c26d15b68b565c2" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.658700154Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/31/31a5d0539b42ad28dbd7d798858a4b23c33ab7fcc56d64584048d9bc1dcb2327" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.659215867Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/6e/6ebb5facb37d39fd695e3572691b88e075a6abf5b5ab7bb834c3fb2cb4e34948" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
blob eligible for deletion: sha256:9c796eecf2b9d178204c0e98295121203da156ef702a9ec04c1afb3c387660e9
blob eligible for deletion: sha256:073b3de8d288dbfc7df5bc5494c9869685953d58a2077649b9b04ed2d0a83916
blob eligible for deletion: sha256:2486237503e15c2ff36c6bdda8edc255296bc98a3bc81de09dd7614828ea8c8c
blob eligible for deletion: sha256:4efbdb5d520cd14766a56249307a2ed5b7179ffd00df146d302f91f167b271cf
blob eligible for deletion: sha256:600b48b04b110ca327b0dbcedd986c4f1f01c4491de564f0c6bd3a165c6d62c8
blob eligible for deletion: sha256:71b4eba1665a13d9ad27b02a9480296335dc5937cdd6cc2b4709262bbc1a576a
blob eligible for deletion: sha256:c114149236cc06f02e863f87ce68cdd88987b15a2207968f6c54f8f544db272e
blob eligible for deletion: sha256:4da06046d1119a4060f7feb5a6b03138977b7c39782cf1f7e899a288ce538bb2
blob eligible for deletion: sha256:6b493b7e5b07551f0daf3d503534596f478cd920e7020d48bb6d6322c4ca37f2
blob eligible for deletion: sha256:b52d978b938250d92ac5349ba3f36d19322e0a1212e58fd13a07a7410119a00f
blob eligible for deletion: sha256:ff29a2f3391c201fdcf93266dbd193297612e79f6b860ca1831acf7c12072570
time="2022-10-16T22:35:14.65976539Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/73/73e5452efbb749844df577a2d2a99fbfcb796503405eaf3a7b3d262f7107d3c1" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.660380953Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/9c/9c796eecf2b9d178204c0e98295121203da156ef702a9ec04c1afb3c387660e9" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.660929196Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/07/073b3de8d288dbfc7df5bc5494c9869685953d58a2077649b9b04ed2d0a83916" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.661548813Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/24/2486237503e15c2ff36c6bdda8edc255296bc98a3bc81de09dd7614828ea8c8c" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.66208873Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/4e/4efbdb5d520cd14766a56249307a2ed5b7179ffd00df146d302f91f167b271cf" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.662677492Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/60/600b48b04b110ca327b0dbcedd986c4f1f01c4491de564f0c6bd3a165c6d62c8" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.663245079Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/71/71b4eba1665a13d9ad27b02a9480296335dc5937cdd6cc2b4709262bbc1a576a" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.663860794Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/c1/c114149236cc06f02e863f87ce68cdd88987b15a2207968f6c54f8f544db272e" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.664432194Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/4d/4da06046d1119a4060f7feb5a6b03138977b7c39782cf1f7e899a288ce538bb2" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.66501462Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/6b/6b493b7e5b07551f0daf3d503534596f478cd920e7020d48bb6d6322c4ca37f2" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.665617542Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/b5/b52d978b938250d92ac5349ba3f36d19322e0a1212e58fd13a07a7410119a00f" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
time="2022-10-16T22:35:14.666188151Z" level=info msg="Deleting blob: /docker/registry/v2/blobs/sha256/ff/ff29a2f3391c201fdcf93266dbd193297612e79f6b860ca1831acf7c12072570" go.version=go1.16.15 instance.id=bbf43fcf-4a4d-4aa3-862f-9d41e6384d43 service=registry 
ziadh@Ziads-MacBook-Air clean_master % 
```

</details>

- [X] Create script [ci_clean.sh](https://github.com/ZiadMansourM/docker-private-registry/blob/master/scripts/ci_clean.sh) to clean CI server.
```Console
ziadh@Ziads-MacBook-Air clean_master % ./scripts/ci_clean.sh
Delete Stoped containers ...
Total reclaimed space: 0B
REPO=production-image...
deleting registry.sreboy.com/production-image:20221016.1_1 with ID: 18fbf635b5e0
deleting registry.sreboy.com/production-image:20221016.1_2 with ID: 4da06046d111
deleting registry.sreboy.com/production-image:20221016.1_3 with ID: 949aff9d65fe
deleting registry.sreboy.com/production-image:20221016.1_4 with ID: 2486237503e1
deleting registry.sreboy.com/production-image:20221016.1_5 with ID: c114149236cc
deleting registry.sreboy.com/production-image:20221016.1_6 with ID: 73e5452efbb7
deleting registry.sreboy.com/production-image:20221016.1_7 with ID: ff29a2f3391c
REPO=silver-image...
deleting registry.sreboy.com/silver-image:20221007.1_1 with ID: 600b48b04b11
deleting registry.sreboy.com/silver-image:20221007.1_2 with ID: 94e64f98cba7
deleting registry.sreboy.com/silver-image:20221007.1_3 with ID: 31a5d0539b42
deleting registry.sreboy.com/silver-image:20221007.1_4 with ID: c18311aa1849
deleting registry.sreboy.com/silver-image:20221007.1_5 with ID: 082a039afb5d
deleting registry.sreboy.com/silver-image:20221007.1_6 with ID: 9f29da67fdbf
deleting registry.sreboy.com/silver-image:20221007.1_7 with ID: 9c796eecf2b9
REPO=hello-image...
Nothing to delete in hello-image only 3 TAGS exists
ziadh@Ziads-MacBook-Air clean_master % 
```
- [ ] Study how mark_digests.sh will react to images with multi tags that doesn't follow naming convention.
- [ ] Push to the same repo that you deleted from.
- [ ] Automate "mark_digests.sh, garbage_collect.sh, ci_clean.sh" on github actions workflow with schedule.

</details>
