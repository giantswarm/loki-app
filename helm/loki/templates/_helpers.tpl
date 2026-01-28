{{/*
Expand the name of the chart.
*/}}
{{- define "loki.name" -}}
{{- $default := "loki" }}
{{- coalesce .Values.nameOverride .Values.loki.nameOverride $default | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "loki.labels" -}}
helm.sh/chart: {{ include "loki.chart" . }}
{{ include "loki.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
giantswarm.io/service-type: "managed"
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | default "atlas" | quote }}
{{- end }}

{{/*
Storage provisioning enabled check
*/}}
{{- define "loki.storage.provisioning.enabled" -}}
{{- if and .Values.loki.loki.storage.provisioning.enabled .Values.loki.loki.storage.provisioning.clusterName -}}
true
{{- end -}}
{{- end -}}

{{/*
Storage provisioning is AWS/CAPA
*/}}
{{- define "loki.storage.provisioning.isAWS" -}}
{{- if eq .Values.loki.loki.storage.provisioning.provider "aws" -}}
true
{{- end -}}
{{- end -}}

{{/*
Get bucket name for a given bucket type (chunks, ruler, admin)
Returns the bucket name from loki.loki.storage.bucketNames configuration
*/}}
{{- define "loki.storage.bucketName" -}}
{{- $bucketType := .bucketType -}}
{{- $root := .root -}}
{{- if eq $bucketType "chunks" -}}
{{- $root.Values.loki.loki.storage.bucketNames.chunks -}}
{{- else if eq $bucketType "ruler" -}}
{{- $root.Values.loki.loki.storage.bucketNames.ruler -}}
{{- else if eq $bucketType "admin" -}}
{{- $root.Values.loki.loki.storage.bucketNames.admin -}}
{{- end -}}
{{- end -}}

{{/*
Get IAM role name
Returns the role name from loki.loki.storage.provisioning.iam.roleName configuration
*/}}
{{- define "loki.storage.iamRoleName" -}}
{{- .Values.loki.loki.storage.provisioning.iam.roleName -}}
{{- end -}}

{{/*
Get AWS Account ID from AWSCluster identity
Supports both AWSClusterRoleIdentity and AWSClusterControllerIdentity
*/}}
{{- define "loki.storage.awsAccountId" -}}
{{- $clusterName := .Values.loki.loki.storage.provisioning.clusterName -}}
{{- $clusterNamespace := .Values.loki.loki.storage.provisioning.clusterNamespace -}}
{{- $accountId := "" -}}
{{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
{{- if $awsCluster -}}
  {{- if $awsCluster.spec.identityRef -}}
    {{- $identityName := $awsCluster.spec.identityRef.name -}}
    {{- $identityKind := $awsCluster.spec.identityRef.kind | default "AWSClusterControllerIdentity" -}}
    {{- if eq $identityKind "AWSClusterRoleIdentity" -}}
      {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSClusterRoleIdentity" "" $identityName -}}
      {{- if $identity -}}
        {{- /* Extract account ID from roleARN like arn:aws:iam::758407694730:role/... */ -}}
        {{- $roleARN := $identity.spec.roleARN -}}
        {{- $parts := regexSplit "::" $roleARN -1 -}}
        {{- if gt (len $parts) 1 -}}
          {{- $accountId = index (regexSplit ":" (index $parts 1) -1) 0 -}}
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSClusterControllerIdentity" "" $identityName -}}
      {{- if $identity -}}
        {{- $accountId = $identity.spec.awsAccountID -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $accountId -}}
{{- end -}}

{{/*
Get OIDC Provider URL from cluster
First tries annotation aws.giantswarm.io/irsa-trust-domains, then falls back to identity
*/}}
{{- define "loki.storage.oidcProvider" -}}
{{- $clusterName := .Values.loki.loki.storage.provisioning.clusterName -}}
{{- $clusterNamespace := .Values.loki.loki.storage.provisioning.clusterNamespace -}}
{{- $oidcProvider := "" -}}
{{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
{{- if $awsCluster -}}
  {{- /* First try to get from annotation (Giant Swarm specific) */ -}}
  {{- if $awsCluster.metadata.annotations -}}
    {{- $oidcProvider = index $awsCluster.metadata.annotations "aws.giantswarm.io/irsa-trust-domains" | default "" -}}
  {{- end -}}
  {{- /* If not found in annotation, try identity ref */ -}}
  {{- if and (not $oidcProvider) $awsCluster.spec.identityRef -}}
    {{- $identityName := $awsCluster.spec.identityRef.name -}}
    {{- $identityKind := $awsCluster.spec.identityRef.kind | default "AWSClusterControllerIdentity" -}}
    {{- if eq $identityKind "AWSClusterControllerIdentity" -}}
      {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSClusterControllerIdentity" "" $identityName -}}
      {{- if and $identity $identity.spec.oidc -}}
        {{- $oidcProvider = $identity.spec.oidc.issuerURL | trimPrefix "https://" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $oidcProvider -}}
{{- end -}}

{{/*
Generate IAM role ARN
*/}}
{{- define "loki.storage.iamRoleArn" -}}
{{- $accountId := include "loki.storage.awsAccountId" . -}}
{{- $roleName := include "loki.storage.iamRoleName" . -}}
{{- printf "arn:aws:iam::%s:role/%s" $accountId $roleName -}}
{{- end -}}

{{/*
Merge tags from AWSCluster CR with user-provided tags
Looks up tags from the AWSCluster CR in the cluster namespace
*/}}
{{- define "loki.storage.tags" -}}
{{- $clusterName := .Values.loki.loki.storage.provisioning.clusterName -}}
{{- $clusterNamespace := .Values.loki.loki.storage.provisioning.clusterNamespace -}}
{{- $tags := list -}}
{{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
{{- if $awsCluster -}}
  {{- if $awsCluster.spec.additionalTags -}}
    {{- range $key, $value := $awsCluster.spec.additionalTags -}}
      {{- $tags = append $tags (dict "key" $key "value" $value) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $defaultTags := list
  (dict "key" "app" "value" "loki")
  (dict "key" "managed-by" "value" "crossplane")
-}}
{{- $userTags := .Values.loki.loki.storage.provisioning.tags | default list -}}
{{- $allTags := concat $tags $defaultTags $userTags -}}
{{- dict "tags" $allTags | toYaml -}}
{{- end -}}

{{/*
Crossplane is Azure/CAPZ
*/}}
{{- define "loki.crossplane.isAzure" -}}
{{- if eq .Values.crossplane.provider "azure" -}}
true
{{- end -}}
{{- end -}}

{{/*
Sanitize storage account name for Azure
Azure storage account names must be:
- Between 3 and 24 characters
- Lowercase letters and numbers only
- Globally unique
*/}}
{{- define "loki.crossplane.azure.storageAccountName" -}}
{{- $containerName := .containerName -}}
{{- $sanitized := regexReplaceAll "[^a-z0-9]" (lower $containerName) "" -}}
{{- $sanitized | trunc 24 -}}
{{- end -}}

{{/*
Get Azure Resource Group from AzureCluster CR
*/}}
{{- define "loki.crossplane.azure.resourceGroup" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $resourceGroup := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- $resourceGroup = $azureCluster.spec.resourceGroup | default "" -}}
{{- end -}}
{{- $resourceGroup -}}
{{- end -}}

{{/*
Get Azure Location from region config
*/}}
{{- define "loki.crossplane.azure.location" -}}
{{- .Values.crossplane.region -}}
{{- end -}}

{{/*
Get Azure Subscription ID from AzureCluster identity
*/}}
{{- define "loki.crossplane.azure.subscriptionId" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $subscriptionId := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- if $azureCluster.spec.subscriptionID -}}
    {{- $subscriptionId = $azureCluster.spec.subscriptionID -}}
  {{- else if $azureCluster.spec.identityRef -}}
    {{- $identityName := $azureCluster.spec.identityRef.name -}}
    {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureClusterIdentity" "" $identityName -}}
    {{- if and $identity $identity.spec.subscriptionID -}}
      {{- $subscriptionId = $identity.spec.subscriptionID -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $subscriptionId -}}
{{- end -}}

{{/*
Merge tags from AzureCluster CR with user-provided tags
Looks up tags from the AzureCluster CR in the cluster namespace
Returns tags as a map suitable for Azure resources
*/}}
{{- define "loki.crossplane.azure.tags" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $tags := dict -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- if $azureCluster.spec.additionalTags -}}
    {{- range $key, $value := $azureCluster.spec.additionalTags -}}
      {{- $_ := set $tags $key $value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $defaultTags := dict
  "app" "loki"
  "managed-by" "crossplane"
-}}
{{- $tags = merge $tags $defaultTags -}}
{{- $userTags := .Values.crossplane.tags | default list -}}
{{- range $tag := $userTags -}}
  {{- $_ := set $tags (index $tag "key") (index $tag "value") -}}
{{- end -}}
{{- $tags | toYaml -}}
{{- end -}}

{{/*
Check if Azure cluster is private
Reads the cluster user-values ConfigMap and checks global.connectivity.network.mode
*/}}
{{- define "loki.crossplane.azure.isPrivateCluster" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $isPrivate := false -}}
{{- $configMapName := printf "%s-user-values" $clusterName -}}
{{- $configMap := lookup "v1" "ConfigMap" "org-giantswarm" $configMapName -}}
{{- if $configMap -}}
  {{- if $configMap.data -}}
    {{- if $configMap.data.values -}}
      {{- $values := $configMap.data.values | fromYaml -}}
      {{- if $values.global -}}
        {{- if $values.global.connectivity -}}
          {{- if $values.global.connectivity.network -}}
            {{- if eq ($values.global.connectivity.network.mode | toString) "private" -}}
              {{- $isPrivate = true -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $isPrivate -}}
{{- end -}}

{{/*
Get Azure Virtual Network name from AzureCluster CR
*/}}
{{- define "loki.crossplane.azure.vnetName" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $vnetName := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- if $azureCluster.spec.networkSpec -}}
    {{- $vnetName = $azureCluster.spec.networkSpec.vnet.name | default "" -}}
  {{- end -}}
{{- end -}}
{{- $vnetName -}}
{{- end -}}

{{/*
Get Azure Subnet name for private endpoints from AzureCluster CR
Falls back to node subnet if no specific subnet is defined
*/}}
{{- define "loki.crossplane.azure.subnetName" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $subnetName := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- if $azureCluster.spec.networkSpec -}}
    {{- if $azureCluster.spec.networkSpec.subnets -}}
      {{- range $subnet := $azureCluster.spec.networkSpec.subnets -}}
        {{- if eq ($subnet.role | toString) "node" -}}
          {{- $subnetName = $subnet.name -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $subnetName -}}
{{- end -}}
