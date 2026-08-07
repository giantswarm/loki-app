# Loki App

[![CircleCI](https://circleci.com/gh/giantswarm/loki-app.svg?style=shield)](https://circleci.com/gh/giantswarm/loki-app)

Giant Swarm offers Loki as a [managed app](https://docs.giantswarm.io/changes/managed-apps/). This chart provides a distributed loki setup based on this
[upstream chart](https://github.com/grafana/loki/tree/main/production/helm/loki).
It tunes some options from upstream to make the chart easier to deploy.

This chart is meant to be used with S3 compatible storage only. Access to the S3
storage must be ensured for the chart to work.
* Check [Deploying on AWS](./docs/deploying-on-aws.md) to see what configuration you need on the AWS side.
* or [Deploying on Azure](./docs/deploying-on-azure.md) to see what configuration you need on the Azure side.

**Table of Contents:**

- [Requirements](#requirements)
- [Install](#install)
- [Upgrading](#upgrading)
- [Configuration](#configuration)
- [Pull Requests tests](#pull-requests-tests)
- [Limitations](#limitations)
- [Links](#links)
- [Credit](#credits)

## Requirements

* You need to ensure that pods deployed can access S3 storage (as explained above).
* On Giant Swarm clusters, you *have to* run a release that is based on `helm 3`.
  This means you need at least:
  * v12.1.2 for Azure
  * v12.5.1 for AWS
  * v12.3.1 for KVM.

## Install

There are several ways to install this app onto a workload cluster.

- [Using GitOps to instantiate the App](https://docs.giantswarm.io/advanced/gitops/#installing-managed-apps)
- [Using our web interface](https://docs.giantswarm.io/ui-api/web/app-platform/#installing-an-app).
- By creating an [App resource](https://docs.giantswarm.io/ui-api/management-api/crd/apps.application.giantswarm.io/) in the management cluster as explained in [Getting started with App Platform](https://docs.giantswarm.io/app-platform/getting-started/).

## Upgrading

### Upgrading an existing Release to a new major version

A major chart version change (like v0.5.0 -> v1.0.0) indicates that there is an incompatible breaking change needing manual actions.

Versions before v1.0.0 are not stable, and can even have breaking changes between "minor" versions. (like v0.5.0 -> v0.6.0)

### From 0.19.x to 0.20.x

⚠️ Upgrading to 0.20.x from any older version is a breaking change as described below

- upgrades to Loki 3 which brings along a lot of breaking changes. See the following links for more context:
  - Upgrading from Loki 2.9 to Loki 3 (c.f. https://grafana.com/docs/loki/latest/setup/upgrade/#300) which includes
    - Metric namespace changes
    - New schema v13 is required to be compatible with Open Telemetry
  - Upgraded upstream chart from 5.x to 6.x: https://grafana.com/docs/loki/latest/setup/upgrade/upgrade-to-6x/

Be aware that this upgrade will cause a slight downtime of Loki as the ingress needs to be recreated (https://github.com/grafana/loki/issues/12554)

Current list of open issues around loki 3 upgrade can be found here: https://github.com/grafana/loki/issues/12506

### From 0.6.x to 0.7.x

⚠️ Upgrading to 0.9.x from any older version can be a breaking change as described below

- switch to 3-targets mode (see [comment in upstream values](https://github.com/grafana/loki/blob/helm-loki-5.1.0/production/helm/loki/values.yaml#L769)) may leave unused "loki-read-x" pods, PVCs and PVs.

### From 0.6.x to 0.7.x

⚠️ Upgrading to 0.6.x from any older version can be a breaking change as described below

- nginx file definition has been changed for easier maintenance. But there is a drawback: if you had defined it in your `values`, you should add these values:
    ```
    loki:
      gateway:
        nginxConfig:
          customReadUrl: http://loki-multi-tenant-proxy.default.svc.cluster.local:3100
          customWriteUrl: http://loki-multi-tenant-proxy.default.svc.cluster.local:3101
          customBackendUrl: http://loki-multi-tenant-proxy.default.svc.cluster.local:3100
    ```

### From 0.5.x to 0.6.x

⚠️ Upgrading to 0.6.x from any older version is a breaking change as described below

- nginx file definition for loki-multi-tenant has moved to a helper template. If you had defined it in your `values`, you should:
  - remove `.loki.gateway.nginxConfig.file` from your `values`
  - set `.loki.gateway.nginxConfig.genMultiTenant: true` in your `values`
  - => now we manage maintenance for this template, so you can keep a cleaner `values` config.

### From 0.4.x to 0.5.x

⚠️ Upgrading to 0.5.x from any older version is a breaking change as described below

The chart used as a base moved from a [community chart](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed) to the [officially maintained chart](https://github.com/grafana/loki/tree/main/production/helm/loki).

The structure of the values changed in 0.5.0 as we now rely on helm chart dependency mechanism to manage the application.

#### Basic upgrade procedure

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

#### Details

##### Your `values.yaml` file need some adjustments.

Most notable changes:
* We changed the base chart from [loki-distributed](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed) to [loki (ex simple-scalable)](https://github.com/grafana/loki/tree/main/production/helm/loki)
* The change of chart leads to a change of achitecture. The component's names are not the same, and the persistent volumes change. A bit of recent data may be lost in the migration.
* We switched to using a subchart. This changes the layout of your `values.yaml`:
  * most of the settings are moving under a `loki` section. Actually that's all the upstream-specific chart configuration.
  * except what is not specific to upstream chart, like `global`, `imagePullSecrets` and `giantswarm` settings
  * note that you will probably have a `loki` section inside another `loki` section
* You can look at the default and sample `values` files to understand the changes:
  * with `loki-app` v0.4.x:
    * [upstream values (loki-distributed 0.48.5)](https://github.com/grafana/helm-charts/blob/loki-distributed-0.48.5/charts/loki-distributed/values.yaml)
    * [default giantswarm values](https://github.com/giantswarm/loki-app/blob/3d777f261a7f820721c6732295aab56c809f4281/helm/loki/values.yaml)
    * [giantswarm sample configs](https://github.com/giantswarm/loki-app/blob/3d777f261a7f820721c6732295aab56c809f4281/examples/values-gs.yaml)
  * with `loki-app` v0.5.x:
    * [upstream values (official loki 3.2.1)](https://github.com/grafana/loki/blob/helm-loki-3.2.1/production/helm/loki/values.yaml)
    * [giantswarm default values](https://github.com/giantswarm/loki-app/blob/release-v0.5.x/helm/loki/values.yaml)
    * [giantswarm sample configs](https://github.com/giantswarm/loki-app/tree/release-v0.5.x/sample_configs)

##### New Loki defaults to multi-tenant mode.

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

#### Rollback

You can rollback to your previous Loki version, and see your old logs.
However, because of multi-tenancy, seeing logs that were stored with the new version may require some config tweaking.

## Configuration

As this application is build upon the Grafana loki upstream chart as a dependency, most of the values to override can be found [here](https://github.com/grafana/loki/blob/helm-loki-6.5.2/production/helm/loki/values.yaml).

Some samples can be found [here](./examples/)

### General recommendations

The number of `replicas` in the [default values file](https://github.com/giantswarm/loki-app/blob/master/helm/loki/values.yaml) are generally considered safe.
If you reduce the number of `replicas` below the default recommended values, expect undefined behaviour and problems.

### Prepare config file

1. Create app config file
Grab the included [sample config file](https://github.com/giantswarm/loki-app/blob/master/examples/values-gs.yaml)
or [azure sample config file](https://github.com/giantswarm/loki-app/blob/master/examples/values-gs-azure.yaml),
read the comments for options and adjust to your needs. To check all available
options, please consult the [full `values.yaml` file](https://github.com/giantswarm/loki-app/blob/master/helm/loki/values.yaml).

2. update `nodeSelectorTerms` to match your nodes (if unsure, `kubectl describe nodes [one worker node] | grep machine-`
should give you the right id for `machine-deployment` or `machine-pool` depending on your provider). Beware, there's 2 places to update! (obsolete with SSD)

3. update `gateway.ingress.hosts.host` and `gateway.ingress.tls.host` 

### Caching

When ingesting logs from workload clusters, Loki may have a hard time processing a user's query because of the huge amount of data. This can lead to read pods being overwhelmed and result in a timeout output for the user.

To avoid this, Loki is able to use a `memcached` cluster which will operate - obviously - caching operations to ease the read pods' job. To enable caching, one will have to deploy the `memcached-app` and set up the `loki.loki.memcached` field in the Loki config.

This field is composed of 2 subfields :

* `chunk_cache`, in which one may define the batch size for the chunks stored.
* `results_cache`, in which one may define the validity period for a cached result as well as the timeout for the query requesting it.

Both subfields also need to have their `host` and `service` specified. If you deployed `memcached-app` with its default values :

* `host` should be `memcached-app.loki.svc`. Otherwise, with custom values for `memcached-app`, the `host` value will be memcached's service DNS name.
* `service` should be `memcache`. With custom values for `memcached-app`, the `service` value will be memcached's service port name.

### Bloom filters

Giant Swarm experimented with bloom filters quite early one after the release of Loki 3.1.0 as can be seen [here](https://github.com/giantswarm/roadmap/issues/3563).

You can quite easily enable blooms in your loki instance by setting the following configuration:

```yaml
loki:
  loki:
    structuredConfig:
      bloom_compactor:
        enabled: true
        retention:
          enabled: true
          max_lookback_days: 30
      bloom_gateway:
        enabled: true
        client:
          addresses: dns+loki-backend-headless.loki.svc.cluster.local:9095
    limits_config:
      bloom_gateway_enable_filtering: true
      bloom_compactor_enable_compaction: true
```

We decided against enabling it by default for now for multiple reasons mostly argued upstream https://github.com/grafana/loki/issues/12751#issuecomment-2252127654 and https://github.com/grafana/loki/issues/12751#issuecomment-2252138818:

- bloom filters are under heavy development
- architecture may still change quite often/fast
- documentation is not guaranteed up-to-date
- nobody knows about performance yet...

### Deploying on AWS

The recommended deployment mode uses S3 storage. See [Deploying on AWS](./docs/deploying-on-aws.md) for the S3 bucket, IAM policy and IAM role setup.

### Deploying on Azure

See [Deploying on Azure](./docs/deploying-on-azure.md) for the storage account and blob container setup, and for using Azure Workload Identity instead of a storage account key.

### Deploying on a new cluster for testing purposes

You might find yourself in a situation where you want to deploy Loki on a new cluster for testing purposes only. Depending on the testing requirements, you might need to avoid creating an object storage with a cloud-provider and manage its access permissions for your Loki pods.

Then you should consider deploying Loki with [MinIO](https://min.io/) as an object storage solution. To put it in a nutshell, `MinIO` is an object storage solution with a S3-like API which uses the nodes' volumes to store its data. Thus, when used for testing purposes, one can mock an S3 bucket behavior to have quick and simple object storage access for Loki without the need for complex access permissions.

The good news is that the Loki chart directly provides a `minio` field where one can configure a `minio` deployment to serve as object storage for the Loki pods. Such a configuration is displayed in the `examples/values-eks-testing.yaml` file.

#### Creating access keys for MinIO access

Once Loki is deployed with MinIO, one will have to create a key pair in the MinIO console to grant Loki pods access to the buckets. To achieve this, one will first have to port-forward the adequate service :
```
kubectl port-forward -n loki service/loki-minio-console 8080:9001
```
Change the namespace according to the one in which your loki pods and services are deployed.

Then one will have to access to the minio console at `127.0.0.1:8080`. Go to `identity` --> `user` and create a new user with whatever name and password one wants and attach the correct permissions needed (most likely the `readwrite` one). Then, one will have to click on the newly created, go to `service accounts` and click on `create service account`. This is where one needs to pay attention because both the `Access Key` and the `secret Key` are present in the values mentioned earlier as `loki.loki.storage.s3.accessKeyId` and `loki.loki.storage.s3.secretAccessKey`.

Set the `Access Key` and `secret Key` in the console so that they have the same value as the corresponding fields in the loki values file and voilà ! 

Everything is now set for testing.

### Testing your deployment

#### Reading data with logcli

1. Install latest logcli from https://github.com/grafana/loki/releases

2. Here are a few test queries for Loki, that you should adapt with your URL and credentials:

  * test from WAN
```
# List all streams
logcli --username=Tenant1 --password=1tnaneT --addr="http://loki.nx4tn.k8s.gauss.eu-west-1.aws.gigantic.io" series '{}'
```

  * Test with a port-forward to the gateway:
```
k port-forward -n loki svc/loki-gateway 8080:80
logcli --username=Tenant1 --password=1tnaneT --addr="http://localhost:8080" series '{}'
```

  * You can also test direct access to loki-write
```
# port-forward loki-write to local port 3100
k port-forward -n loki svc/loki-write 3100:3100
# or loki-query-frontend-xxxx port 3100 accepts the same queries

# List all streams
# Note that we use "org-id" rather than "username/password" when we bypass the gateway
$ logcli --org-id="tenant-1" --addr="http://localhost:3100" series '{}'
http://localhost:3100/loki/api/v1/series?end=1654091687961363182&match=%7B%7D&start=1654088087961363182
```

#### Ingesting data with promtail

* Get promtail from https://github.com/grafana/loki/releases
* Create basic promtail config file `promtail-test.yml`:
```yaml
---
server:
  disable: true
positions:
  filename: /tmp/promtail_test_positions.yaml
clients:
  - url: http://localhost:8080/loki/api/v1/push
    # tenant_id: tenant-1
    basic_auth:
      username: Tenant1
      password: 1tnaneT
    tenant_id: tenant-1
scrape_configs:
  - job_name: logfile
    static_configs:
      - targets:
          - localhost
        labels:
          job: logfile
          host: local
          __path__: /tmp/lokitest.log
```
* If you want to bypass the gateway, you can port-forward Loki distributor to localhost:3100
```
k port-forward -n loki svc/loki-distributor 3100:3100
# Don't forget to change your promtail URL, and use tenant_id rather than basic_auth!
```
* Launch promtail
```
promtail --config.file=promtail-test.yml --inspect
```
* Add data to your log file
```
(while true ; do echo "test log line $(date)"; sleep 1; done ) >> /tmp/lokitest.log
```
* Query loki with `logcli` and see your data

## Pull Requests tests

We have a few tips for testing pull requests [here](TESTING.md).

## Limitations

The application and its default values have been tailored to work inside Giant Swarm clusters.
If you want to use it for any other scenario, know that you might need to adjust some values.

## Links

- [Loki demo for Giant Swarm customers (YouTube)](https://www.youtube.com/watch?v=KeJwfOiVA7o)
- [Part 1: How the Cloud-Native Stack Helps Writing Minimal Microservices (blog series)](https://www.giantswarm.io/blog/how-the-cloud-native-stack-helps-writing-minimal-microservices/)
- [Achieving cloud-native observability with open-source (on demand demo and slides)](https://www.giantswarm.io/on-demand-webinar-achieving-cloud-native-observability-with-open-source)
- [The radical way Giant Swarm handles Service Level Objectives](https://www.giantswarm.io/blog/the-radical-way-giant-swarm-handles-service-level-objectives)

## Credit

This application is installing the upstream chart below with defaults to ensure it runs smoothly in Giant Swarm clusters.

* <https://github.com/grafana/loki/tree/main/production/helm/loki>
