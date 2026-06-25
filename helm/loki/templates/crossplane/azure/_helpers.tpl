
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
Full Azure resource ID of the Loki blob container. Used as the (container-scoped)
role assignment scope, so the identity only gets blob access to Loki's own container
rather than the whole storage account.
*/}}
{{- define "loki.crossplane.azure.containerId" -}}
{{- $accountId := include "loki.crossplane.azure.storageAccountId" . -}}
{{- printf "%s/blobServices/default/containers/%s" $accountId .Values.crossplane.azure.container.name -}}
{{- end -}}

{{/*
OIDC issuer URL for the Federated Identity Credential. Prefers the explicit
crossplane.azure.workloadIdentity.oidcIssuerUrl value; otherwise auto-detects the
cluster's kube-apiserver --service-account-issuer from kube-system/kubeadm-config.

The kubeadm ClusterConfiguration stores apiServer.extraArgs in one of two shapes,
and we handle both:

  # v1beta4 (Kubernetes 1.31+): a list of {name, value} entries. A flag may repeat
  # (the apiserver accepts multiple --service-account-issuer); the first one is the
  # primary OIDC issuer, so we take it.
  apiServer:
    extraArgs:
      - name: service-account-issuer
        value: https://oidcissuerXXXX.blob.core.windows.net/oidc-test/
      - name: service-account-issuer
        value: https://kubernetes.default.svc.cluster.local

  # v1beta3 and earlier: a map of flag -> value (single value per flag).
  apiServer:
    extraArgs:
      service-account-issuer: https://oidcissuerXXXX.blob.core.windows.net/oidc-test/

Returns empty if it cannot be resolved (e.g. during `helm template` with no cluster).
*/}}
{{- define "loki.crossplane.azure.oidcIssuer" -}}
{{- $issuer := .Values.crossplane.azure.workloadIdentity.oidcIssuerUrl | default "" -}}
{{- if not $issuer -}}
  {{- $kubeadmConfig := lookup "v1" "ConfigMap" "kube-system" "kubeadm-config" -}}
  {{- if and $kubeadmConfig $kubeadmConfig.data -}}
    {{- $clusterConfiguration := get $kubeadmConfig.data "ClusterConfiguration" | fromYaml -}}
    {{- $apiServerArgs := dig "apiServer" "extraArgs" list $clusterConfiguration -}}
    {{- if kindIs "slice" $apiServerArgs -}}
      {{- /* take the first service-account-issuer: it is the primary (OIDC) issuer */ -}}
      {{- range $arg := $apiServerArgs -}}{{- if and (not $issuer) (eq (dig "name" "" $arg) "service-account-issuer") -}}{{- $issuer = $arg.value -}}{{- end -}}{{- end -}}
    {{- else if kindIs "map" $apiServerArgs -}}
      {{- $issuer = dig "service-account-issuer" "" $apiServerArgs -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $issuer -}}
{{- end -}}
