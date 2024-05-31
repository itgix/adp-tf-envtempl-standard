#!/bin/bash

argocd_ns='argocd'
app_of_apps=('infra-services' 'app-auto-deploy')

getSelfHeal() {
  local app=$1
  local ns=$2
  heal_value=$(kubectl get app $app -n $ns -o jsonpath='{.spec.syncPolicy.automated.selfHeal}')
  if [ -z $heal_value ]; then
      heal_value='false'
  fi
  printf $heal_value
}

echo 'Disable self-healing on all argocd applications, starting with app of apps'

for aoa in "${app_of_apps[@]}"; do
  if [ "$(getSelfHeal $aoa $argocd_ns)" == "true" ]; then
    kubectl patch app $aoa --type='json' \
    -p='[{"op": "replace", "path": "/spec/syncPolicy/automated/selfHeal", "value": false}]' \
    -n $argocd_ns
  fi
done

for app in $(kubectl get app -n $argocd_ns -o jsonpath='{.items[*].metadata.name}'); do
  if [ "$(getSelfHeal $app $argocd_ns)" == "true" ]; then
    kubectl patch app $app --type='json' \
    -p='[{"op": "replace", "path": "/spec/syncPolicy/automated/selfHeal", "value": false}]' \
    -n $argocd_ns
  fi
done

echo 'Ingress resources for removal (all namespaces):'

kubectl get ing -A -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}'

echo 'Delete all ingress resources. WAIT for finalizers'

kubectl delete ing --all --all-namespaces --wait=true

echo "Terraform commands:
      terraform init -backend-config=<backend-var-file> -reconfigure
      terraform plan -destroy -var-file=<config-var-file> -out destroy_plan
      "
exit 0
