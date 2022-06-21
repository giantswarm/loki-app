# Procedure for upstream upgrade

## List of custom changes on upstream

* livenessProbes on all services - Upstream PR here: https://github.com/grafana/helm-charts/pull/1511
* labels:
  * `giantswarm.io/monitoring_basic_sli: "true"`
    * in various templates
  * `giantswarm.io/monitoring: "true"`
    * in various templates
  * `giantswarm.io/service-type: "managed"`
    * in `_helpers.tpl`
    * in `multi-tenant-proxy/multi-tenant-proxy.yaml`
* annotation `giantswarm.io/monitoring-port` with specific ports
    * in the templates that have `giantswarm.io/monitoring: "true"` label
* resources limits/requests

## On our custom values.yml examples:

* gateway.nginxconfig: proxy_pass rules route to the loki-multi-tenant-proxy containers (on different ports) rather to each individual component.
