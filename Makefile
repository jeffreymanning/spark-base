LOCAL_IMAGE=spark-base
SPARK_IMAGE=jeffreymanning/spark-base
versionDef=2.1.0
version=$(1:-$(versionDef))
# If you're pushing to an integrated registry
# in Openshift, SPARK_IMAGE will look something like this
# SPARK_IMAGE=172.30.242.71:5000/myproject/openshift-spark

.PHONY: build clean push test stop create destroy

build:
	docker build -t $(LOCAL_IMAGE):$(version) -t $(LOCAL_IMAGE):latest .

clean:
	docker rmi $(LOCAL_IMAGE)

push: build
	docker tag $(LOCAL_IMAGE) $(SPARK_IMAGE)
	docker push $(SPARK_IMAGE)

test: push ./test/spark-cluster-test.yaml
    oc new-project test  --description="test demo" --display-name="test"
    oc adm policy add-scc-to-user anyuid -z default -n test
	oc process -f ./test/spark-cluster-test.yaml -v SPARK_IMAGE=$(SPARK_IMAGE) > test.active
	oc create -f test.active

stop: test.active
	oc delete -f test.active
	rm template.active

create: push template.yaml
	oc process -f template.yaml -v SPARK_IMAGE=$(SPARK_IMAGE) > template.active
	oc create -f template.active

destroy: template.active
	oc delete -f template.active
	rm template.active
