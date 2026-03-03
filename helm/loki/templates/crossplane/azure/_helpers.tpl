
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
Get Azure Subscription ID from values or AzureCluster CR
*/}}
{{- define "loki.crossplane.azure.subscriptionId" -}}
{{- $subscriptionId := .Values.crossplane.azure.subscriptionId | default "" -}}
{{- if not $subscriptionId -}}
  {{- $clusterName := .Values.crossplane.clusterName -}}
  {{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
  {{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
  {{- if $azureCluster -}}
    {{- $subscriptionId = $azureCluster.spec.subscriptionID -}}
  {{- end -}}
{{- end -}}
{{- $subscriptionId -}}
{{- end -}}
