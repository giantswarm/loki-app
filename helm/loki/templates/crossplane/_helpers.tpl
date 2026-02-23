
{{/*
Crossplane enabled check
*/}}
{{- define "loki.crossplane.enabled" -}}
{{- if and .Values.crossplane.enabled .Values.crossplane.clusterName -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Crossplane is AWS/CAPA
*/}}
{{- define "loki.crossplane.isAWS" -}}
{{- if eq .Values.crossplane.provider "aws" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Crossplane is Azure/CAPZ
*/}}
{{- define "loki.crossplane.isAzure" -}}
{{- if eq .Values.crossplane.provider "azure" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Merge tags from cluster CR with user-provided tags
Returns tags as a map: {foo: "bar"}
*/}}
{{- define "loki.crossplane.tags" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $provider := .Values.crossplane.provider -}}
{{- $tags := dict -}}
{{- if eq $provider "aws" -}}
  {{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
  {{- if $awsCluster -}}
    {{- if $awsCluster.spec.additionalTags -}}
      {{- range $key, $value := $awsCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if eq $provider "azure" -}}
  {{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
  {{- if $azureCluster -}}
    {{- if $azureCluster.spec.additionalTags -}}
      {{- range $key, $value := $azureCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
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
