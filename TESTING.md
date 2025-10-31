# How to test before a new release

## local tests

- make sure to use the right dependencies (`helm dep up helm/loki/`)
- helm template with default values (`helm template helm/loki`)
- helm template with some real values
  - retrieve real values: `kubectl -n giantswarm get cm loki-chart-values -oyaml | yq '.data.values' > realvalues.yaml`
  - helm template: `helm template helm/loki -f realvalues.yaml`

## kind tests (via ats)

Prerequisites:
- have docker runinng on your laptop
- have kind installed (https://kind.sigs.k8s.io/)
- have ats repository cloned (https://github.com/giantswarm/app-test-suite)

Steps:
- be in the root of the loki-app repository
- package chart with `helm package helm/loki/ --version 0.0`
- run ats with `../app-test-suite/dats.sh --chart-file loki-0.0.tgz`

Debugging:
- These actions should run in a separate terminal while `ats` is running
- get your cluster's ID with `kind get cluster`
- retrieve its kubeconfig with `kind get kubeconfig --name [clusterID] > kind.kubeconfig`
- set kubeconfig with `export KUBECONFIG=kind.kubeconfig`
- then you can use `kubectl` to query your kind cluster.

## in-cluster tests

See [manual E2E documentation](tests/manual_e2e/README.md)
