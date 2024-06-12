# Contributing Guidelines

## Required tooling

- [Helm 3](https://helm.sh/docs/intro/install/): Most popular Kubernetes templating tool.
- [Helm Schema-gen](https://github.com/mihaisee/helm-schema-gen.git): can be installed using `helm plugin install https://github.com/mihaisee/helm-schema-gen.git`. This tool is used to generate the json schema of the helm chart

## Upgrading

* change the `loki` upstream version in Chart dependencies (`helm/loki/Chart.yaml`)
* run `helm dependency update helm/loki` to update the Chart.lock file
* re-generate `helm/loki/values.schema.json`:
  * `helm schema-gen helm/loki/values.yaml > helm/loki/values.schema.json` to re-generate the file.
  * `sed -i 's/"type": "null"/"type": ["string", "null"]/g' helm/loki/values.schema.json` to accept strings for all null values.
* if new paths are defined by loki API, update `nginxConfig` in example values.
* update the link in the [`Configuration`](./README.md#configuration) section of the README to point to the new tag configuration.
* run `helm-docs helm/loki`
