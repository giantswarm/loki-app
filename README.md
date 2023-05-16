# Loki App

[![CircleCI](https://circleci.com/gh/giantswarm/loki-app.svg?style=shield)](https://circleci.com/gh/giantswarm/loki-app)

Giant Swarm offers Loki as a [managed app](https://docs.giantswarm.io/changes/managed-apps/). This chart provides a distributed loki setup based on this
[upstream chart](https://github.com/grafana/loki/tree/main/production/helm/loki).
It tunes some options from upstream to make the chart easier to deploy.

This chart is meant to be used with S3 compatible storage only. Access to the S3
storage must be ensured for the chart to work.
* Check [below](#deploying-on-aws) to see what configuration you need on the AWS side.
* or [below](#deploying-on-azure) to see what configuration you need on the Azure side.

**Table of Contents:**

- [Requirements](#requirements)
- [Install](#install)
- [Upgrading](#upgrading)
- [Configuration](#configuration)
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

As this application is build upon the Grafana loki upstream chart as a dependency, most of the values to override can be found [here](https://github.com/grafana/loki/blob/helm-loki-3.2.1/production/helm/loki/values.yaml).

Some samples can be found [here](./sample_configs/)

### General recommendations

The number of `replicas` in the [default values file](https://github.com/giantswarm/loki-app/blob/master/helm/loki/values.yaml) are generally considered safe.
If you reduce the number of `replicas` below the default recommended values, expect undefined behaviour and problems.

### Prepare config file

1. Create app config file
Grab the included [sample config file](https://github.com/giantswarm/loki-app/blob/master/sample_configs/values-gs.yaml)
or [azure sample config file](https://github.com/giantswarm/loki-app/blob/master/sample_configs/values-gs-azure.yaml),
read the comments for options and adjust to your needs. To check all available
options, please consult the [full `values.yaml` file](https://github.com/giantswarm/loki-app/blob/master/helm/loki/values.yaml).

2. update `nodeSelectorTerms` to match your nodes (if unsure, `kubectl describe nodes [one worker node] | grep machine-`
should give you the right id for `machine-deployment` or `machine-pool` depending on your provider). Beware, there's 2 places to update! (obsolete with SSD)

3. update `gateway.ingress.hosts.host` and `gateway.ingress.tls.host` 

#### Multi-tenant setup

1. The default GiantSwarm template is prepared for multi-tenancy.
In multi tenant setups<a name="multi-tenant-config"></a>, you can enable [loki-multi-tenant-proxy](https://github.com/k8spin/loki-multi-tenant-proxy)
to manage credentials for different tenants.

Enable the deployment of loki-multi-tenant-proxy by setting `multiTenantAuth.enabled` to `true`.

Write down your credentials in `multiTenantAuth.credentials`.
They should be formatted in your values file like this:

```yaml
multiTenantAuth:
  enabled: true
  credentials: |-
    users:
      - username: Tenant1
        password: 1tnaneT
        orgid: tenant-1
      - username: Tenant2
        password: 2tnaneT
        orgid: tenant-2
```

2. In single tenant setups<a name="single-tenant-config"></a> with simple basic auth logins you want to use the
`gateway.basicAuth.existingSecret` config option.
To create the secret with necessary users and passwords use the following commands:

```bash
echo "passwd01" | htpasswd -i -c.htpasswd user01
echo "passwd02" | htpasswd -i .htpasswd user02
echo "passwd03" | htpasswd -i .htpasswd user03

kubectl -n loki create secret generic loki-basic-auth --from-file=.htpasswd
```
Then, set `gateway.basicAuth.existingSecret` to `loki-basic-auth`.

### Deploying on AWS

The recommended deployment mode is using S3 storage mode. Assuming your cluster
has `kiam` (https://github.com/uswitch/kiam), `cert-manager` and `external-dns` included, you should be good to use
the instructions below to setup S3 bucket and the necessary permissions in your
AWS account.

Make sure to create this config for the *cluster* where you are deploying Loki, and not at installation-level.

#### Prepare AWS S3 storage.
Create a new private S3 bucket based in the same region
as your instances. Ex. `gs-loki-storage`.
* encryption is not required, but strongly recommended: Loki won't encrypt your data
* consider creating private VPC endpoint for S3 - traffic volume might be
  considerable and this might save you some money for the transfer fees,
* it is recommended to use S3 bucket class for frequent access (`S3 standard`),
* create a retention policy for the bucket; currently, loki won't delete
  files in S3 for you ([check here](https://grafana.com/docs/loki/latest/operations/storage/retention/)
  and [here](https://grafana.com/docs/loki/latest/operations/storage/table-manager/)).
* CLI procedure:
```bash
# prepare environment
export CLUSTER_NAME=zj88t
export NODEPOOL_ID=oy9v0
export REGION=eu-central-1
export INSTALLATION=gorilla
export BUCKET_NAME=gs-loki-storage-"$CLUSTER_NAME" # must be globally unique
export AWS_PROFILE=gorilla-atlas # your AWS CLI profile
export LOKI_POLICY="$BUCKET_NAME"-policy
export LOKI_ROLE="$BUCKET_NAME"-role

# create bucket
aws --profile="$AWS_PROFILE" s3 mb s3://"$BUCKET_NAME" --region "$REGION"
```

#### Prepare AWS IAM policy.
Create an IAM Policy in IAM. If you want to use AWS WebUI, copy/paste the contents of `POLICY_DOC` variable.
```bash
# Create policy
POLICY_DOC='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject" ],
            "Resource": [
                "arn:aws:s3:::'"$BUCKET_NAME"'",
                "arn:aws:s3:::'"$BUCKET_NAME"'/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:GetAccessPoint",
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAccessPoints"
            ],
            "Resource": "*"
        }
    ]
}'
aws --profile="$AWS_PROFILE" iam create-policy --policy-name "$LOKI_POLICY" --policy-document "$POLICY_DOC"
```

#### Prepare AWS IAM role

**Up to giantswarm v18**

Create a new IAM Role that allows the necessary instances (k8s masters in the case of using `kiam`) to access resources from the policy. Set trust to allow the Role used by `kiam` to claim the S3 access role. If you want to use AWS WebUI, copy/paste the contents of `POLICY_DOC` variable.
```bash
# Create role
PRINCIPAL_ARN="$(aws --profile="$AWS_PROFILE" iam get-role --role-name "$CLUSTER_NAME"-IAMManager-Role | sed -n 's/.*Arn.*"\(arn:.*\)".*/\1/p')"
ROLE_DOC='{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "AWS": "'"$PRINCIPAL_ARN"'"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}'
```

**From giantswarm v19**

Giant Swarm clusters will use IRSA (Iam Roles for Service Accounts) to allow pods to access S3 buckets' resources. For more details concerning IRSA, you can refer to the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) as well as to the [giant swarm one](https://docs.giantswarm.io/advanced/iam-roles-for-service-accounts).

This means that the role's `Trust Relationship` will be different that the one used for KIAM (cf above) :
```bash
ROLE_DOC='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::'$PRINCIPAL_ARN':oidc-provider/irsa.'$CLUSTER_NAME'.k8s.'$INSTALLATION'.'$REGION'.aws.gigantic.io"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "irsa.'$CLUSTER_NAME'.k8s.'$INSTALLATION'.'$REGION'.aws.gigantic.io:sub": "system:serviceaccount:loki:loki"
                }
            }
        }
    ]
}'
```

#### Create role

Everything is now set to create the role :
```bash
aws --profile="$AWS_PROFILE" iam create-role --role-name "$LOKI_ROLE" --assume-role-policy-document "$ROLE_DOC"
# Attach the policy to the role
LOKI_POLICY_ARN="${PRINCIPAL_ARN%:role/*}:policy/$LOKI_POLICY"
aws --profile="$AWS_PROFILE" iam attach-role-policy --policy-arn "$LOKI_POLICY_ARN" --role-name "$LOKI_ROLE"
```

* Store the role's arn in a variable for the next step :
```bash
LOKI_ROLE_ARN="${PRINCIPAL_ARN%:role/*}:role/$LOKI_ROLE"
```

#### Link IAM role to Kubernetes

**Up to giantswarm v18**

Currently, you have to manually pre-create the namespace and annotate it with
IAM Roles required for pods running in the namespace:

```bash
kubectl create ns loki
kubectl annotate ns loki iam.amazonaws.com/permitted="$LOKI_ROLE_ARN"
```

**From giantswarm v19**

Since IRSA is relying on the use of service accounts to grant access rights to the pods, you don't have to manually create the `loki` namespace as you won't have to annotate it. Instead, you'll have to edit the Chart's values under the `loki` section with the following :
```bash
serviceAccount:
  create: true
  name: loki
  annotations:
    eks.amazonaws.com/role-arn: "$LOKI_ROLE_ARN"
```

This way, all pods using the `loki` service account will be able to access to the S3 bucket created earlier.

#### Install the app

* Fill in the values from previous step in your config (`values.yaml`) file:
  * role annotation for S3
  * cluster ID
  * node pool ID
  * and your custom setup

* Install the app using your values.
  Don't forget to use the same namespace as you prepared above for the installation.

### Deploying on Azure

#### Gather data
Find the 'Subscription name' (usually named after your installation) name and the 'Resource group' of your cluster (usually named after cluster id) inside your 'Azure subscription'
* list subscriptions:
```
az account list -otable
export SUBSCRIPTION_NAME="your subscription"
```
* list resource groups:
```
az group list --subscription "$SUBSCRIPTION_NAME" -otable
export RESOURCE_GROUP="your resource group"
```

#### object storage setup
1. Create 'Storage Account' on Azure ([How-to](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create)) ['Create storage account'](https://portal.azure.com/#create/Microsoft.StorageAccount)
    * 'Account kind' should be 'BlobStorage'
    * Example with Azure CLI:
```
# Chose your storage account name
export STORAGE_ACCOUNT_NAME="loki$RESOURCE_GROUP"
# then create it
az storage account create \
     --subscription "$SUBSCRIPTION_NAME" \
     --name "$STORAGE_ACCOUNT_NAME" \
     --resource-group "$RESOURCE_GROUP" \
     --sku Standard_GRS \
     --encryption-services blob \
     --https-only true \
     --kind BlobStorage \
     --access-tier Hot
```
(It may be required to set the location using the `--location` flag.)

2. Create a 'Blob service' 'Container' in your storage account
    * Example on how to do it with Powershell in Azure portal:
```
export CONTAINER_NAME="$STORAGE_ACCOUNT_NAME"container
az storage container create \
     --subscription "$SUBSCRIPTION_NAME" \
     -n "$CONTAINER_NAME" \
     --public-access off \
     --account-name "$STORAGE_ACCOUNT_NAME"
```

3. Go to the 'Access keys' page of your 'Storage account'
    * Use the 'Storage account name' for `azure_storage.account_name`
    * Use the name of the 'Blob service' 'Container' for `azure_storage.blob_container_name`
    * Use one of the keys for `azure.storage_key`
    * With azure CLI
```
az storage account keys list \
     --subscription "$SUBSCRIPTION_NAME" \
     --account-name "$STORAGE_ACCOUNT_NAME" \
| jq -r '.[]|select(.keyName=="key1").value'
```

#### Install the app

* Fill in the values from previous step in your config (`values.yaml`) file:
  * cluster ID
  * node pool ID
  * and your custom setup

* Install the app using your values.

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
