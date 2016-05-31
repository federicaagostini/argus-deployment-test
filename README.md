# argus-deployment-test
A suite for test deployment of Argus services on CentOS-6 and CentOS-7. After service setup, the [Argus functional testsuite](https://github.com/marcocaberletti/argus-robot-testsuite) is runned against the services.

## Synopsis
This test suite provides two type of deployment test:

1. __all-in-one__

   All Argus services are installed on single Docker container. The testsuite is runned on the same host, too.
   
2. __distributed__

   Each Argus service is deployed in a dedicated container, as the functional testsuite.
   
   In this deployment, only tests tagged with "remote" label are executed.


## Configuration
The deployment tests need Docker and docker-compose for run properly: see [official documentation](https://docs.docker.com/engine/installation/) for install them.


## Run tests
For run the deployment test:

 * export the `PLATFORM` variable with one of the values: `centos6` or `centos7`
 * run `deploy.sh` bash script
 
For example, for run distributed deployment test on CentOS 7:

```bash
$ cd argus-deployment-test/distributed
$ PLATFORM=centos7 ./deploy.sh
```

Similarly, for run all-in-one deployment:

```bash
$ cd argus-deployment-test/all-in-one
$ PLATFORM=centos7 ./deploy.sh
```