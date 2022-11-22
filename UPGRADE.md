# Upgrade guides

# Procedure to upgrade from loki-app v0.4.x to v0.5.x

## Basic upgrade procedure

1. Retrieve current `values.yaml`
   * for manual/happa deployments you could do it with a command like `k get cm -n [mycluster] loki-user-values -oyaml | yq '.data.values'` on the management cluster
   * for gitops deployments, you should have it in git
1. keep a backup: `cp values.yaml values.yaml_0.4`
1. prepare your new values file (see "Most notable changes" section hereafter for details on what to change)
1. open grafana, check that you can access your logs
1. uninstall loki
1. install newer loki version, with new values
1. check in grafana that you can still access old and new logs

__Note:__

Uninstalling before re-installing is not mandatory. You can also change config and app version at the same time. Works well with Flux for instance.

## Details

### Your `values.yaml` file need some adjustments.

Most notable changes:
* We changed the base chart from [loki-distributed](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed) to [loki (ex simple-scalable)](https://github.com/grafana/loki/tree/main/production/helm/loki)
* The change of chart leads to a change of achitecture. The component's names are not the same, and the persistent volumes change. A bit of recent data may be lost in the migration.
* We switched to using a subchart. This changes the layout of your `values.yaml`:
  * most of the settings are moving under a `loki` section. Actually that's all the upstream-specific chart configuration.
  * except what is not specific to upstream chart, like `global`, `multiTenantAuth`, `imagePullSecrets` and `giantswarm` settings
  * note that you will probably have a `loki` section inside another `loki` section
* You can look at the default and sample `values` files to understand the changes:
  * with `loki-app` v0.4.x:
    * [upstream values (loki-distributed 0.48.5)](https://github.com/grafana/helm-charts/blob/loki-distributed-0.48.5/charts/loki-distributed/values.yaml)
    * [default giantswarm values](https://github.com/giantswarm/loki-app/blob/3d777f261a7f820721c6732295aab56c809f4281/helm/loki/values.yaml)
    * [giantswarm sample configs](https://github.com/giantswarm/loki-app/blob/3d777f261a7f820721c6732295aab56c809f4281/sample_configs/values-gs.yaml)
  * with `loki-app` v0.5.x:
    * [upstream values (official loki 3.2.1)](https://github.com/grafana/loki/blob/helm-loki-3.2.1/production/helm/loki/values.yaml)
    * [giantswarm default values](https://github.com/giantswarm/loki-app/blob/release-v0.5.x/helm/loki/values.yaml)
    * [giantswarm sample configs](https://github.com/giantswarm/loki-app/tree/release-v0.5.x/sample_configs)

### New Loki defaults to multi-tenant mode.

If you set an orgid when sending logs, you now have to make sure you set it also when reading logs.
You can read multiple tenants with orgid built like this: `tenant1|tenant2`
Logs sent with no tenant are stored as tenant `fake`.
You can see all your tenants by listing your object storage. Here, I have `fake`, `tenant1` and `tenant2` tenants:
```
fake/
tenant1/
tenant2/
index/
loki_cluster_seed.json
```

## Rollback

You can rollback to your previous Loki version, and see your old logs.
However, because of multi-tenancy, seeing logs that were stored with the new version may require some config tweaking.
