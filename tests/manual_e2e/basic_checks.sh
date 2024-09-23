#!/bin/bash

# Helper function - prints an error message and exits
exit_error() {
    echo "Error: $*"
    exit 1
}

echo "Checking if loki app is in deployed state"

appStatus=$(kubectl get app -n giantswarm loki -o yaml | yq .status.release.status)

[[ "$appStatus" != "deployed" ]] \
  && exit_error "loki app is not in deployed state. Please fix the app before retrying"

echo "loki app is indeed in deployed state"
echo "Checking if loki-canary is enabled"

canary=$(kubectl get cm -n giantswarm loki-chart-values -oyaml | yq .data.values | yq .loki.lokiCanary.enabled)

[[ "$canary" != "true" ]] \
  && exit_error "loki-canary is not enabled. Please enable it before retrying"

echo "loki-canary is indeed enabled"
echo "Checking if all loki pods are up and running"

lokiComponents=("read" "write" "backend" "gateway" "canary")

for component in "${lokiComponents[@]}"; do
  podStatus=$(kubectl get pods -n loki -l app.kubernetes.io/name=loki,app.kubernetes.io/component=$component -o yaml | yq .items[].status.phase)

  [[ -z "$podStatus" ]] && exit_error "No $component pods found. Please check it before retrying"

  for status in $podStatus; do
    [[ "$status" != "Running" ]] \
      && exit_error "A $component pod is not running. Please check it before retrying"
  done
done

echo "All loki pods are up and running"
