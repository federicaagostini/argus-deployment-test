#!/bin/sh

set -xe

platforms="centos6 centos7"
workdir=${PWD}

echo "Build images for all-in-one deployment"

cd ${workdir}/all-in-one/docker

for plat in ${platforms}; do
	docker build --no-cache -t argus-deployment-test:$plat --file="Dockerfile.$plat" .
done

echo "Build images for distributed deployment"
cd ${workdir}/distributed

for plat in ${platforms}; do
	docker-compose -f argus-${plat}/docker-compose.yml build --no-cache
done
