#!/bin/bash

NS_COUNT=0
DEPLOY_COUNT=0
SVC_COUNT=0
ROUTE_COUNT=0
POD_COUNT=0

echo "################################"
echo "## ArgoCD - Deployment Status ##"
echo "################################"
echo ""

for i in {0..9}
do 
    namespace=jump-app-dev-${i}

    GOLANG_ROUTE=$(oc get route back-golang-v1 -o jsonpath='{.spec.host}' -n ${namespace})
    echo "## Application ${i} "
    echo "Testing Golang App in namespace ${namespace} (${GOLANG_ROUTE})"
    curl https://${GOLANG_ROUTE} -k
    echo ""
    echo ""

done

for i in {0..9}
do 
    namespace=jump-app-dev-${i}

    oc get project ${namespace} >> /dev/null
    if [ $? -eq 0 ]
    then
      NS_COUNT=$(($NS_COUNT + 1))
    fi

    TMP_DEPLOY_COUNT=$(oc get deployment -n ${namespace}  | grep -v NAME | wc -l)
    if [ $? -eq 0 ]
    then
      DEPLOY_COUNT=$(($DEPLOY_COUNT + $TMP_DEPLOY_COUNT))
    fi
     
    TMP_SVC_COUNT=$(oc get service -n ${namespace} | grep -v NAME | wc -l)
    if [ $? -eq 0 ]
    then
      SVC_COUNT=$(($SVC_COUNT + $TMP_SVC_COUNT))
    fi

    TMP_ROUTE_COUNT=$(oc get route -n ${namespace} | grep -v NAME | wc -l)
    if [ $? -eq 0 ]
    then
      ROUTE_COUNT=$(($ROUTE_COUNT + $TMP_ROUTE_COUNT))
    fi

    TMP_POD_COUNT=$(oc get pods -n ${namespace} | grep -v NAME | wc -l)
    if [ $? -eq 0 ]
    then
      POD_COUNT=$(($POD_COUNT + $TMP_POD_COUNT))
    fi

done

echo "#############"
echo "## SUMMARY ##"
echo "#############"
echo ""
echo "Applications: ${NS_COUNT}"
echo "Namespaces: ${NS_COUNT}"
echo "Deployments: ${DEPLOY_COUNT}"
echo "Services: ${SVC_COUNT}"
echo "Routes: ${ROUTE_COUNT}"
echo "Pods: ${POD_COUNT}"