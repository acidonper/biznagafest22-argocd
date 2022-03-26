# Biznagafest 2022 - ArgoCD Demo

This repository contains the resources and procedures required to install and configure an ArgoCD instance in Openshift (Kubernetes) in order to be able to deploy an application based on a GitOps strategy.

## Components

This demo is based on the following components:

- [Red Hat® OpenShift®](https://www.redhat.com/en/technologies/cloud-computing/openshift) is an enterprise-ready Kubernetes container platform built for an open hybrid cloud strategy. It provides a consistent application platform to manage hybrid cloud, multicloud, and edge deployments.
- [ArgoCD](https://argoproj.github.io/argo-cd/) is a declarative, GitOps continuous delivery tool for Kubernetes following the GitOps pattern of using Git repositories as the source of truth for defining the desired application state. Argo CD automates the deployment of the desired application states in the specified target environments. Application deployments can track updates to branches, tags, or pinned to a specific version of manifests at a Git commit.
- [Helm](https://helm.sh/) is a tool to find, share, and use software built for Kubernetes. Helm helps users manage Kubernetes applications in terms of definition, installing, and upgrading even the most complex Kubernetes application.

## Prerequistes

In order to complete this demo, it is required to have the following software installed:

- [OC Client](https://docs.openshift.com/container-platform/4.9/cli_reference/openshift_cli/getting-started-cli.html)
- [Git](https://git-scm.com)
- [Helm](https://helm.sh/docs/intro/install/)


## Setting Up

In order to deploy the application in a GitOps way, it is required to follow the next steps:

### Install ArgoCD Operator

First of all, it is required to install the ArgoCD Operator which manages ArgoCD in a Kubernets way via YAML files. This component will support the ArgoCD installation and configuration process during this demo.

The following command apply a YAML file in Openshift to deploy the ArgoCD Operator:

```$bash
oc apply -f 00-install-operator.yaml
```

After a few minutes, a new component is deployed in Openshift to manage new ArgoCD instances and their configuration. It is possible to view this new component executing the following command:

```$bash
oc get pod -n openshift-operators
NAME                                                  READY   STATUS    RESTARTS   AGE
gitops-operator-controller-manager-85ccf6bc77-s846l   1/1     Running   2          5m
```

### Install ArgoCD Server

After the ArgoCD operator has been installed, it is time to install ArgoCD itself. It is required to execute the following command to apply the YAML file definition in Openshift in order to give the ArgoCD Operator the definition required to deploy de ArgoCD Server.

```$bash
oc new-project argocd
oc apply -f 01-install-argocd.yaml
```

After few minutes, it is possible to see all ArgoCD Server microservices deployed executing the following command:

```$bash
oc get pod -n argocd
NAME                                  READY   STATUS    RESTARTS   AGE
argocd-application-controller-0       1/1     Running   0          31s
argocd-dex-server-6b78df6b8-4rm6s     1/1     Running   0          31s
argocd-redis-6fb8d68fd5-5xlnm         1/1     Running   0          31s
argocd-repo-server-5f98cb6dcd-kvl77   1/1     Running   0          31s
argocd-server-84449488cb-5c5m4        1/1     Running   0          31s
```

### Deploy Jump App via an ArgoCD Application

Finally, it is required to configure a new ArgoCD Application in order to create all required objects to deploy the final application. In this case, it is configured to deploy _Jump App_ application via Helm.

The following command applies the YAML file definition in order to give the ArgoCD Server the definition required to deoloy the application in Openshift. 

```$bash
oc new-project jump-app-dev
oc label namespace jump-app-dev argocd.argoproj.io/managed-by=argocd --overwrite
oc apply -f 02-install-app-jump-app.yaml
```

After few minutes, ArgoCD has created a set of object that represent the _Jump App_ microservices. The following command illustrates this scenary:

```$bash
oc get pod -n argocd
NAME                                  READY   STATUS    RESTARTS   AGE
back-golang-v1-7599559bc-scgq6        1/1     Running   0          4m28s
back-python-v1-7cc5d84585-jlwjv       1/1     Running   0          4m28s
back-quarkus-v1-77cdcbd89-d67st       1/1     Running   0          4m28s
back-springboot-v1-7bc5cc4b45-r6zzz   1/1     Running   0          4m28s
front-javascript-v1-598cb94bf-9m2px   1/1     Running   0          4m28s
mongo-547c99d7c4-wvgqb                1/1     Running   0          4m28s
```

### Testing Jump App

Once the _Jump App_ pods are _Running_, it is time to check application frontend access via browser. It is required to follow the next steps:

- Obtain _Jump App_ frontend URL

```$bash
oc get route -n argocd | grep front
front-javascript      front-javascript-argocd.apps-crc.testing             front-javascript-v1   http-8080   edge/Redirect          None
front-javascript-v1   front-javascript-v1-argocd.apps-crc.testing          front-javascript-v1   http-8080   edge/Redirect          None
```

- Visit the frontend URL (E.g. front-javascript-argocd.apps-crc.testing)

## Deploy multiple Jump App via an ArgoCD ApplicationSet

For creating multiple Jum App applications is recommended make use of *ApplicationSet*. This object allows customer to create multiple new ArgoCD Applications in order to create all required objects to deploy the final applications.

The following command applies the YAML file definition in order to give the ArgoCD Server the definition required to deploy the multiple applications in Openshift.

```$bash
sh scripts/create-ns.sh
oc apply -f 03-install-app-jump-app-multi.yaml
```

After few minutes, ArgoCD has created a set of object that represent the _Jump App_ microservices. The following command illustrates this scenoary:

```$bash
oc get pod -n jump-app-dev-1
NAME                                  READY   STATUS    RESTARTS   AGE
back-golang-v1-7599559bc-scgq6        1/1     Running   0          4m28s
back-python-v1-7cc5d84585-jlwjv       1/1     Running   0          4m28s
back-quarkus-v1-77cdcbd89-d67st       1/1     Running   0          4m28s
back-springboot-v1-7bc5cc4b45-r6zzz   1/1     Running   0          4m28s
front-javascript-v1-598cb94bf-9m2px   1/1     Running   0          4m28s
mongo-547c99d7c4-wvgqb                1/1     Running   0          4m28s
```

### Testing multiple applications

Once the multiple _Jump App_ applications are _Running_, it is time to check applications automatically using the following command: 

```$bash
scripts/report.sh

...
## Application 9 
Testing Golang App in namespace jump-app-dev-9 (back-golang-v1-jump-app-dev-9.apps.biznagafest.sandbox1207.opentlc.com)
/ - Greetings from Golang!

#############
## SUMMARY ##
#############

Applications: 10
Namespaces: 10
Deployments: 50
Services: 50
Routes: 40
Pods: 50
```

## Interesting Links

- Jump App GitOps Repository -> https://github.com/acidonper/jump-app-gitops.git

## Author

Asier Cidon