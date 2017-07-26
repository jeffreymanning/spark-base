# Spark 2.2.0 base layer
Forked from https://github.com/radanalyticsio/openshift-spark

## Components:
* Spark 2.2.0
    * Uses NSS_WRAPPER
        * forked elements from atbentley/docker-nss-wrapper
        * modify /etc/passwd so arbitrary UIDs can run and still have a username.
        * useful in environments such as Openshift which randomise the UID for each container
    * Spark Configuration
        * Reverse proxy configuration
        * Metrics (jolokia-jvm-1.3.6-agent.jar) configured on demand
    * Use templates
        * specify the Kubernertes/Openshift deployment
        * generally not designed for use outside of Kube
* Java 8 (1.8.0_141) JRE server + Maven 3.5.0 + Python 2.7.5
    * Oracle Java "1.8.0_141" JRE Runtime Environment for Server
      Java(TM) SE Runtime Environment (build 1.8.0_141-b15)
      Java Home: $JAVA_HOME is setup (/usr)
    * Apache Maven 3.5.0
      Maven home: /usr/apache-maven-3.5.0
    * Python 2.7.5 (Default Centos7 install)
    * Other tools: tar curl net-tools build-essential git wget unzip vim  

## Pull the image from Docker Repository

```bash
docker pull jeffreymanning/spark-base
```

## Base the image to build add-on components

```Dockerfile
FROM jeffreymanning/spark-base
```

## Run the image
Use the associated templates (yml files)
Examples shortly

## Build and Run your own image
Say, you will build the image "my/spark-base".

```bash
docker build -t <my>/spark-base .
```
alternatively,
```bash
make build
```
alternatively,
```bash
make push (leverages build)
```

## Shell into the Docker instance
```bash
docker exec -it <some-spark-base> /bin/bash
```
