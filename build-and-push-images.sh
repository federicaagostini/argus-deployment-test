#!/bin/sh

set -xe

DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-"cloud-vm128.cloud.cnaf.infn.it"}

platforms="centos6 centos7"
services="pap pdp pep bdii"
workdir=${PWD}


echo "Process images for all-in-one deployment"

cd ${workdir}/all-in-one/docker

for plat in ${platforms}; do
	image_name=argus-deployment-test:$plat
	dest=${DOCKER_REGISTRY_HOST}/italiangrid/$image_name
	
	echo "Build $image_name..."
	docker build --no-cache -t $image_name --file="Dockerfile.$plat" .
	
	echo "Push $image_name to $dest..."
	docker tag $image_name $dest
	docker push $dest
done


echo "Process images for distributed deployment"

cd ${workdir}/distributed

for plat in ${platforms}; do
	
	echo "Build images for platform $plat..."
	docker-compose -f argus-${plat}/docker-compose.yml build --no-cache
	
	for srv in $services; do
		image_name=italiangrid/argus-${srv}-${plat}
		dest=${DOCKER_REGISTRY_HOST}/italiangrid/argus-${srv}-${plat}
		
		echo "Push $image_name to $dest..."
		docker tag $image_name $dest
		docker push $dest
	done
done
