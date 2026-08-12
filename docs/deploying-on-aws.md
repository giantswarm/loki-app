# Deploying on AWS

The recommended deployment mode is using S3 storage mode. Assuming your cluster
has `kiam` (https://github.com/uswitch/kiam), `cert-manager` and `external-dns` included, you should be good to use
the instructions below to setup S3 bucket and the necessary permissions in your
AWS account.

Make sure to create this config for the *cluster* where you are deploying Loki, and not at installation-level.

## Prepare AWS S3 storage.
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

Create bucket policy to enforce tls in-transit:

```bash
# Create policy
BUCKET_POLICY_DOC='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EnforceSSLOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::'"$BUCKET_NAME"'",
                "arn:aws:s3:::'"$BUCKET_NAME"'/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}'

aws --profile="$AWS_PROFILE" s3api put-bucket-policy --bucket $BUCKET_NAME --policy "$BUCKET_POLICY_DOC"
```

## Prepare AWS IAM policy.
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

## Prepare AWS IAM role

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
PRINCIPAL_ARN="$(aws --profile="$AWS_PROFILE" iam get-role --role-name "$CLUSTER_NAME"-IAMManager-Role | sed -n 's/.*Arn.*"\(arn:.*\)".*/\1/p')"
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

## Create role

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

## Link IAM role to Kubernetes

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

## Install the app

* Fill in the values from previous step in your config (`values.yaml`) file:
  * role annotation for S3
  * cluster ID
  * node pool ID
  * and your custom setup

* Install the app using your values.
  Don't forget to use the same namespace as you prepared above for the installation.
