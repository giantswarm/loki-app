# loki-app chart

[![CircleCI](https://circleci.com/gh/giantswarm/loki-app.svg?style=shield)](https://circleci.com/gh/giantswarm/loki-app)

Giant Swarm offers Loki as a [managed app](#about-giant-swarm-managed-apps). This chart provides a distributed loki setup based on this
[upstream chart](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed).
It tunes a bunch of options from the upstream to make the chart easier to deploy.

This chart is meant to be used with S3 compatible storage only. Access to the S3
storage must be ensured for the chart to work. You can check
[the sample config file](sample_configs/values-gs.yaml) to check for annotations
that can be used to make it work with AWS S3 using
[KIAM](https://github.com/uswitch/kiam). Check [below](#deploying-on-aws) to see
what configuration you need on the AWS side.

## Requirements

* You need to ensure that pods deployed can access S3 storage (as explained above).
* On Giant Swarm clusters, you *have to* run a release that is based on `helm 3`.
  This means you need at least:
  * v12.1.2 for Azure
  * v12.5.1 for AWS
  * v12.3.1 for KVM.

### Deploying on AWS

The recommended deployment mode is using S3 storage mode. Assuming your cluster
has `kiam`, `cert-manager` and `external-dns` included, you should be good to use
the instructions below to setup S3 bucket and the necessary permissions in your
AWS account.

1. Prepare AWS S3 storage. Create a new private S3 bucket based in the same region
   as your instances. Ex. `gs-loki-storage`.
   * encryption is not required, but strongly recommended: Loki won't encrypt your data
   * consider creating private VPC endpoint for S3 - traffic volume might be
     considerable and this might save you some money for the transfer fees,
   * it is recommended to use S3 bucket class for frequent access (`S3 standard`),
   * create a retention policy for the bucket; currently, loki won't delete
     files in S3 for you ([check here](https://grafana.com/docs/loki/latest/operations/storage/retention/) and [here](https://grafana.com/docs/loki/latest/operations/storage/table-manager/)).
2. Prepare AWS role.
   * Create a Policy in IAM with the following permissions (adjust for your bucket name, `gs-loki-storage` used below) and name the Policy for ex. `loki-s3-access`:

        ```json
        {
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
                        "arn:aws:s3:::gs-loki-storage",
                        "arn:aws:s3:::gs-loki-storage/*"
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
        }
        ```

   * create a new IAM Role that allows the necessary instances (k8s masters in the
     case of using `kiam`) to access resources from the policy. Set trust to allow
     the Role used by `kiam` to claim the S3 access role:

        ```json
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::180547736195:role/m2h60-IAMManager-Role"
                },
                "Action": "sts:AssumeRole"
                }
            ]
        }
        ```

3. Create app config file
    Grab the included [sample config file](sample_configs/values-gs.yaml),
    read the comments for options and adjust to your needs. To check all available
    options, please consult the [upstream `values.yaml` file](helm/loki/values.yaml).

    1. Setting external basic auth logins
    If you want to use `gateway.basicAuth.existingSecret` config option, you can create
    the secret with necessary users and passwords by using the following commands:

    ```bash
    echo "passwd01" | htpasswd -i -c.htpasswd tenant01
    echo "passwd02" | htpasswd -i .htpasswd tenant02
    echo "passwd03" | htpasswd -i .htpasswd tenant03
    ...
    kubectl -n loki create secret generic loki-basic-auth --from-file=.htpasswd
    ```

    Then, set `gateway.basicAuth.existingSecret` to `loki-basic-auth`.

4. Prepare the namespace
   Currently, you have to manually pre-create the namespace and annotate it with
   IAM Roles required for pods running in the namespace:

   ```bash
   kubectl create ns loki
   kubectl annotate ns loki iam.amazonaws.com/permitted="loki-s3-access"
   ```

5. Install the app
   Now you can proceed with installing the app the usual way. Don't forget to use
   the same namespace as you prepared above for the installation.

### Deploying on Azure

1. Find the 'Resource group' of your cluster (usually named after cluster id) inside your 'Azure subscription'
1. Create 'Storage Account' on Azure ([How-to](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create)) ['Create storage account'](https://portal.azure.com/#create/Microsoft.StorageAccount)
  - 'Account kind' should be 'BlobStorage'
1. Create a 'Blob service' 'Container' in your storage account
1. Go to the 'Access keys' page of your 'Storage account'
  - Use the 'Storage account name' for `azure_storage.account_name`
  - Use the name of the 'Blob service' 'Container' for `azure_storage.blob_container_name`
  - Use one of the keys for `azure.storage_key`
1. Make a personal copy of the [azure example file](sample_configs/values-gs-azure.yaml) and fill in the values from previous step and also cluster id and node pool ids
1. Install the app using your values.

## Source code origin

The source code in `helm/loki` is a git-subtree coming from the
<https://github.com/giantswarm/grafana-helm-charts-upstream>. Giant Swarm uses that
repository to track and adjust or charts maintained by Grafana Labs.

## About Giant Swarm managed apps

Once your Kubernetes clusters are up and running, you can use dozens of apps to take control of every part of your cluster. For example, apps to configure DNS servers (External DNS), to generate and renew certificates (Cert Manager), to monitor (Prometheus), to log (EFK or Loki), and to trace (Jaeger) your workloads, to keep your clusters secure, to autoscale resources… and many more.

To help with these, we provide managed apps. When using open source tools, one has two choices. Either DIY or contract with upstream enterprise for support (if available). Between these two, there is a gap. This gap is where you (1) want to use an app ‘for real’, (2) need quick and efficient support with engineers, (3) but don't have the use case yet to commit to contract with upstream enterprise. Our managed apps are our customers’ 'one hand to shake’ for all the many apps within this gap.

## Links

- [Loki demo for Giant Swarm customers (YouTube)](https://www.youtube.com/watch?v=KeJwfOiVA7o)
- [Part 1: How the Cloud-Native Stack Helps Writing Minimal Microservices (blog series)](https://www.giantswarm.io/blog/how-the-cloud-native-stack-helps-writing-minimal-microservices/)
- [Achieving cloud-native observability with open-source (on demand demo and slides)](https://www.giantswarm.io/on-demand-webinar-achieving-cloud-native-observability-with-open-source)
- [The radical way Giant Swarm handles Service Level Objectives](https://www.giantswarm.io/blog/the-radical-way-giant-swarm-handles-service-level-objectives)

## Credit

* <https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed>
