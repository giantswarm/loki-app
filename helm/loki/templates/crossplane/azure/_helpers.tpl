
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

{{/*
Get Azure Virtual Network ID from AzureCluster CR
Returns the full Azure resource ID for the VNet
*/}}
{{- define "loki.crossplane.azure.vnetId" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $vnetId := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- if $azureCluster.spec.networkSpec -}}
    {{- if $azureCluster.spec.networkSpec.vnet -}}
      {{- $vnetId = $azureCluster.spec.networkSpec.vnet.id | default "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $vnetId -}}
{{- end -}}
