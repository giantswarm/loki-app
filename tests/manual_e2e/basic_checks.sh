#!/bin/bash

echo "Checking if loki app is in deployed state"

deployed=$(kubectl get app -n giantswarm loki -o yaml | yq .status.release.status)

if [[ "$deployed" != "deployed" ]]; then
  echo "loki app is not in deployed state. Please fix the app before retrying"
  exit 1
else
  echo "loki app is indeed in deployed state"
fi

echo "Checking if loki-canary is enabled"

canary=$(kubectl get cm -n giantswarm loki-chart-values -oyaml | yq .data.values | yq .loki.lokiCanary.enabled)

if [[ "$canary" != "true" ]]; then
  echo "loki-canary is not enabled. Please enable it before retrying"
  exit 1
else
  echo "loki-canary is indeed enabled"
fi

echo "Checking if all loki pods are up and running"

lokiComponents=("read" "write" "backend" "gateway")

for component in "${lokiComponents[@]}"; do
  podStatus=$(kubectl get pods -n loki -l app.kubernetes.io/name=loki,app.kubernetes.io/component=$component -o yaml | yq .items[].status.phase)

  for status in $podStatus; do
    if [[ "$status" != "Running" ]]; then
      echo "A $component pod is not running. Please check it before retrying"
      exit 1
    fi
  done
done

echo "All loki pods are up and running"
