#!/bin/bash

set -x

PLATFORM="${PLATFORM:-centos7}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"

netname="argus"$PLATFORM"_default"
testdir="$PWD/argus-$PLATFORM"
pdp_admin_passwd="pdpadmin_password"
pap_host="argus-pap-$PLATFORM.cnaf.test"
pdp_host="argus-pdp-$PLATFORM.cnaf.test"
pep_host="argus-pep-$PLATFORM.cnaf.test"

DOCKER_NET_NAME="${DOCKER_NET_NAME:-$netname}"

container_name=argus-ts-$PLATFORM-$$

## Clean before run
docker rm $container_name
docker-compose -f $testdir/docker-compose.yml stop
docker-compose -f $testdir/docker-compose.yml rm -f

## Run Argus service in detached mode
docker-compose -f $testdir/docker-compose.yml up --build -d

## Get testsuite
tmpdir="/tmp/tester_$$/argus-robot-testsuite"
git clone https://github.com/marcocaberletti/argus-robot-testsuite.git $tmpdir
cd $tmpdir
git checkout $TESTSUITE_BRANCH
cd $tmpdir/docker
sh build-image.sh

cd $testdir/../..

container_name=argus-ts-$PLATFORM-$$

docker run --net=$DOCKER_NET_NAME \
	--name=$container_name \
	-e T_PDP_ADMIN_PASSWORD=$pdp_admin_passwd \
	-e PAP_HOST=$pap_host \
	-e PDP_HOST=$pdp_host \
	-e PEP_HOST=$pep_host \
	-e TESTSUITE_BRANCH=$TESTSUITE_BRANCH \
	-e TIMEOUT=600 \
	italiangrid/argus-testsuite:latest
	
## Stop services
docker-compose -f $testdir/docker-compose.yml stop

## Copy reports, logs and configuration
rm -rf $PWD/argus_*
mkdir $PWD/argus_logs $PWD/argus_conf $PWD/argus_reports

docker cp argus-pap-$PLATFORM.cnaf.test:/var/log/argus/pap/ $PWD/argus_logs
docker cp argus-pap-$PLATFORM.cnaf.test:/etc/argus/pap/ $PWD/argus_conf

docker cp argus-pdp-$PLATFORM.cnaf.test:/var/log/argus/pdp/ $PWD/argus_logs
docker cp argus-pdp-$PLATFORM.cnaf.test:/etc/argus/pdp/ $PWD/argus_conf

docker cp argus-pep-$PLATFORM.cnaf.test:/var/log/argus/pepd/ $PWD/argus_logs
docker cp argus-pep-$PLATFORM.cnaf.test:/etc/argus/pepd/ $PWD/argus_conf

docker cp $container_name:/home/tester/argus-robot-testsuite/reports $PWD/argus_reports


