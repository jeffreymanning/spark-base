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

## Monitoring:
* Web
    * Configure
        * command line: spark-shell --conf spark.eventLog.enabled=true --conf spark.eventLog.dir=dirctory
        * Scala: sparkConf.set("spark.eventLog.enabled", "true")
        * spark-defaults (not recommended): spark.eventLog.enabled           true
    * access
        * simply opening http://<driver-node>:4040  (1,2,3... for successive spark context)
* JSON
    * http://<server-url>:18080/api/v1
    * see https://spark.apache.org/docs/latest/monitoring.html#rest-api
* Metrics
    * set ENABLE_METRICS true (yaml or values.yml)
    * currently configured to JmxSink for viewing in JMX console
    * GraphiteSink coming (to work with Grafana)

## Pull the image from Docker Repository

```bash
docker pull jeffreymanning/spark-base
```

## Base the image to build add-on components

```Dockerfile
FROM jeffreymanning/spark-base
```

## Run the image
There are two (2) basic manual installation options: persistent volumes and dynamic storage.

Clean up and project preparation (PV's are global namespaces)
* docker ps -aqf status=exited | xargs docker rm -v
* docker images -aqf dangling=true | xargs docker rmi
* Stale PVs
    * oc get pvc
    * oc get pv
    * oc delete pv spark-gluster-<....>-logs spark-gluster-<....>-scratch ...
    * oc get storageclass
    * cd oc delete storageclass gluster
* oc delete project <project-name>

New project construction
* oc new-project targeting  --description="AF Targeting demo" --display-name="targeting"
* oc adm policy add-scc-to-user anyuid -z default -n targeting

Use the associated templates (yaml files).
* Persistent Volume
    * oc process -f gluster-cluster.yaml | oc create -f -
    * oc process -f spark-gluster-pv-zeppelin-R.yaml | oc create -f -
* Dynamic Volumes: require construction of storage class
    * oc create -f gluster-secret.yaml
    * oc get storageclass
    * if no gluster storage class: 
        * oc create -f gluster-secret.yaml
     oc process -f spark-gluster-dyn-zeppelin-R.yaml | oc create -f -
* Testing
    * oc process -f ./test/gluster-pv-test.yaml
    * oc process -f gluster-cluster.yaml
    * oc process -f gluster-cluster.yaml | oc create -f -
    * oc process -f ./test/gluster-pv-test.yaml | oc create -f -

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
