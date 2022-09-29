# Procedure for upstream upgrade

* change the `loki-upstream` version in Chart dependencies (`helm/loki/Chart.yaml`)
* re-generate `helm/loki/values.schema.json`:
  * `helm schema-gen values.yaml > values.schema.json` to re-generate the file.
  * `helm schema-gen helm/loki/values.yaml > helm/loki/values.schema.json` to re-generate the file.
  * `sed -i 's/"type": "null"/"type": ["string", "null"]/g' helm/loki/values.schema.json` to accept strings for all null values.
* if new paths are defined by loki API, update `nginxConfig` in example values.
