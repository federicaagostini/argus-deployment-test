#!/bin/bash

set -x

PLATFORM="${PLATFORM:-centos7}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"
DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-""}

netname="argus"$PLATFORM"_default"
testdir="$PWD/argus-$PLATFORM"
pdp_admin_passwd="pdpadmin_password"
pap_host="argus-pap-$PLATFORM.cnaf.test"
pdp_host="argus-pdp-$PLATFORM.cnaf.test"
pep_host="argus-pep-$PLATFORM.cnaf.test"

DOCKER_NET_NAME="${DOCKER_NET_NAME:-$netname}"
REGISTRY=""

container_name=argus-ts-$PLATFORM-$$
workdir=$PWD

## Clean before run
docker rm $container_name
docker-compose -f $testdir/docker-compose.yml stop
docker-compose -f $testdir/docker-compose.yml rm -f

## Create more entropy
list=`docker ps -aq -f status=exited -f name=haveged | xargs`
if [ ! -z "$list"]; then
	docker rm $list
fi

id=`docker ps -q -f status=running -f name=haveged`
if [ -z "$id" ]; then
	docker run --name=haveged --privileged -d harbur/haveged
fi

if [ -n "${DOCKER_REGISTRY_HOST}" ]; then
	export REGISTRY=${DOCKER_REGISTRY_HOST}/
	## Pull images
	docker-compose -f $testdir/docker-compose.yml pull
else
	## Build locally
	docker-compose -f $testdir/docker-compose.yml build --no-cache
fi

export REGISTRY

## Run Argus service in detached mode
docker-compose -f $testdir/docker-compose.yml up -d --no-build

sleep 120

## Get testsuite
tmpdir="/tmp/tester_$$/argus-robot-testsuite"
git clone https://github.com/marcocaberletti/argus-robot-testsuite.git $tmpdir
cd $tmpdir
git checkout $TESTSUITE_BRANCH

if [ -n "${DOCKER_REGISTRY_HOST}" ]; then
	docker pull ${DOCKER_REGISTRY_HOST}/italiangrid/argus-testsuite
else
	cd $tmpdir/docker
	sh build-image.sh
fi

cd $workdir

container_name=argus-ts-$PLATFORM-$$

docker run --net=$DOCKER_NET_NAME \
	--name=$container_name \
	-e T_PDP_ADMIN_PASSWORD=$pdp_admin_passwd \
	-e PAP_HOST=$pap_host \
	-e PDP_HOST=$pdp_host \
	-e PEP_HOST=$pep_host \
	-e TESTSUITE_BRANCH=$TESTSUITE_BRANCH \
	-e TIMEOUT=600 \
	${REGISTRY}italiangrid/argus-testsuite:latest
	
## Stop services
docker-compose -f $testdir/docker-compose.yml stop

## Copy reports, logs and configuration
rm -rfv $workdir/argus_*

logdir=$workdir/argus_logs
confdir=$workdir/argus_conf
reportdir=$workdir/argus_reports

mkdir $logdir $confdir $reportdir

docker cp argus-pap-$PLATFORM.cnaf.test:/var/log/argus/pap/ $logdir
docker cp argus-pap-$PLATFORM.cnaf.test:/etc/argus/pap/ $confdir

docker cp argus-pdp-$PLATFORM.cnaf.test:/var/log/argus/pdp/ $logdir
docker cp argus-pdp-$PLATFORM.cnaf.test:/etc/argus/pdp/ $confdir

docker cp argus-pep-$PLATFORM.cnaf.test:/var/log/argus/pepd/ $logdir
docker cp argus-pep-$PLATFORM.cnaf.test:/etc/argus/pepd/ $confdir

docker cp $container_name:/home/tester/argus-robot-testsuite/reports $reportdir
