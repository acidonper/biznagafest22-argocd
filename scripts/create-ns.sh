#!/bin/bash

for i in {0..9}
do 
    oc new-project jump-app-dev-$i
    oc label namespace jump-app-dev-$i argocd.argoproj.io/managed-by=argocd --overwrite 
    
done
