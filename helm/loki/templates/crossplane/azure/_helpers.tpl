
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

{{/*
Name of the User-Assigned Managed Identity used for workload identity.
Derived from the container name. Azure identity names allow up to 128 chars.
*/}}
{{- define "loki.crossplane.azure.identityName" -}}
{{- printf "%s-identity" .containerName | trunc 128 | trimSuffix "-" -}}
{{- end -}}

{{/*
Full Azure resource ID of the Loki storage account. Used as the scope for the
storage Blob role assignment. Deterministic from subscription + resource group +
sanitized storage account name.
*/}}
{{- define "loki.crossplane.azure.storageAccountId" -}}
{{- $subscriptionId := include "loki.crossplane.azure.subscriptionId" . -}}
{{- $resourceGroup := .Values.crossplane.azure.resourceGroup -}}
{{- $storageAccountName := include "loki.crossplane.azure.storageAccountName" (dict "containerName" .Values.crossplane.azure.container.name) -}}
{{- printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Storage/storageAccounts/%s" $subscriptionId $resourceGroup $storageAccountName -}}
{{- end -}}

{{/*
OIDC issuer URL for the Federated Identity Credential. Prefers the explicit
crossplane.azure.workloadIdentity.oidcIssuerUrl value; otherwise auto-detects the
cluster's kube-apiserver --service-account-issuer from kube-system/kubeadm-config
(handles both the kubeadm v1beta4 list form and the older map form of extraArgs).
Returns empty if it cannot be resolved (e.g. during `helm template` with no cluster).
*/}}
{{- define "loki.crossplane.azure.oidcIssuer" -}}
{{- $issuer := .Values.crossplane.azure.workloadIdentity.oidcIssuerUrl | default "" -}}
{{- if not $issuer -}}
  {{- $cm := lookup "v1" "ConfigMap" "kube-system" "kubeadm-config" -}}
  {{- if and $cm $cm.data -}}
    {{- $cc := get $cm.data "ClusterConfiguration" | fromYaml -}}
    {{- $args := dig "apiServer" "extraArgs" list $cc -}}
    {{- if kindIs "slice" $args -}}
      {{- range $a := $args -}}{{- if eq (dig "name" "" $a) "service-account-issuer" -}}{{- $issuer = $a.value -}}{{- end -}}{{- end -}}
    {{- else if kindIs "map" $args -}}
      {{- $issuer = dig "service-account-issuer" "" $args -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $issuer -}}
{{- end -}}
