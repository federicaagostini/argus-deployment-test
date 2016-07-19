#!/bin/sh

set -xe

DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-"cloud-vm128.cloud.cnaf.infn.it"}

platforms="centos6 centos7"
services="pap pdp pep bdii"

echo "Push images for all-in-one deployment"

for plat in ${platforms}; do
	image_name=argus-deployment-test:$plat
	dest=${DOCKER_REGISTRY_HOST}/italiangrid/argus-deployment-test:$plat
	
	docker tag $image_name $dest
	docker push $dest
done

echo "Push images for distributed deployment"

for plat in ${platforms}; do
	for srv in $services; do
		docker tag argus-${srv}-${plat} ${DOCKER_REGISTRY_HOST}/italiangrid/argus-${srv}-${plat}
		docker push ${DOCKER_REGISTRY_HOST}/italiangrid/argus-${srv}-${plat}
	done
done
