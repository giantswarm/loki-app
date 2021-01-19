[![CircleCI](https://circleci.com/gh/giantswarm/{APP-NAME}-app.svg?style=shield)](https://circleci.com/gh/giantswarm/{APP-NAME}-app)

# loki-app chart

This chart provides a distributed loki setup based on this
[upstream chart](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed).
It tunes a bunch of options from the upstream to make the chart easier to deploy.

This chart is meant to be used with S3 compatible storage only. Access to the S3
storage must be ensured for the chart to work. The chart includes annotations
necessary to make it work with AWS S3 using [KIAM](https://github.com/uswitch/kiam).

## Requirements

* You need to ensure that pods deployed can access S3 storage. Support for AWS S3
  is included in the chart (see below).

### Deploying on AWS

1. Make sure that [kiam-app](https://github.com/giantswarm/kiam-app) is deployed in
   your cluster.
2. Prepare AWS S3 storage. Create a new private S3 bucket based in the same region
   as your instances. Ex. `gs-loki-storage`.
   * encryption is not required, but strongly recommended: Loki won't encrypt your data
   * consider creating private access point for S3 - traffic volume might be
     considerable
   * it is recommended to use S3 bucket class for frequent access (`S3 standard`)
   * create a retention policy for the bucket; currently, loki won't delete
     file in S3 for you ([check here](https://grafana.com/docs/loki/latest/operations/storage/retention/) and [here](https://grafana.com/docs/loki/latest/operations/storage/table-manager/)).
3. Prepare AWS role.
   * Create a Policy in IAM with the following permissions
   * (adjust for your bucket name) and name it for ex. `gs-loki-storage`:

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
                        "s3:DeleteObject"
                    ],
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
     case of `kiam` to access resources from the policy). Set trust to allow 
     entities (instances) to assume it. Ex. trust relationship:

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

4. Create app config file

## Credit

* <https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed>
