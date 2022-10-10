# Procedure to upgrade from loki-app v0.4.x to v0.5.x

## Basic upgrade procedure

1. Retrieve current `values.yaml`
   * for manual/happa deployments you could do it with a command like `k get cm -n [mycluster] loki-user-values -oyaml | yq '.data.values'` on the management cluster
   * for gitops deployments, you should have it in git
1. keep a backup: `cp values.yaml values.yaml_0.4`
1. prepare your new values file
1. open grafana, check that you can access your logs
1. uninstall loki
1. install newer loki version, with new values
1. check in grafana that you can still access old and new logs

To be tested when we have old and new loki in the same catalog: upgrade without uninstalling.

## Notes:

### Your `values.yaml` file need some adjustments.

Most notable changes:
* We changed the base chart from [loki-distributed](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed) to [loki (ex simple-scalable)](https://github.com/grafana/loki/tree/main/production/helm/loki)
* The change of chart leads to a change of achitecture. The component's names are not the same, and the persistent volumes change. A bit of recent data may be lost in the migration.
* We switched to using a subchart. This changes the layout of your `values.yaml`, as all upstream-specific configuration will be set in a `loki` subtree. See example `values` files.

### New Loki defaults to multi-tenant mode.

If you set an orgid when sending logs, you now have to make sure you set it also when reading logs.
You can read multiple tenants with orgid built like this: `tenant1|tenant2`
Logs sent with no tenant are stored as tenant `fake`.
You can see all your tenants by listing your object storage. Here, I have `fake` and `gauss` tenants:
```
fake/
gauss/
index/
loki_cluster_seed.json
```

## Rollback

You can rollback to your previous Loki version, and see your old logs.
However, because of multi-tenancy, seeing logs that were stored with the new version may require some config tweaking.
