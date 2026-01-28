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
Crossplane enabled check
*/}}
{{- define "loki.crossplane.enabled" -}}
{{- if and .Values.crossplane.enabled .Values.crossplane.clusterName -}}
true
{{- end -}}
{{- end -}}

{{/*
Crossplane is AWS/CAPA
*/}}
{{- define "loki.crossplane.isAWS" -}}
{{- if eq .Values.crossplane.provider "aws" -}}
true
{{- end -}}
{{- end -}}


{{/*
Get AWS Account ID from AWSCluster identity
Supports both AWSClusterRoleIdentity and AWSClusterControllerIdentity
*/}}
{{- define "loki.crossplane.awsAccountId" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
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
{{- define "loki.crossplane.oidcProvider" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
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
{{- define "loki.crossplane.iamRoleArn" -}}
{{- $accountId := include "loki.crossplane.awsAccountId" . -}}
{{- $roleName := .Values.crossplane.aws.iam.roleName -}}
{{- printf "arn:aws:iam::%s:role/%s" $accountId $roleName -}}
{{- end -}}

{{/*
Merge tags from AWSCluster CR with user-provided tags
Looks up tags from the AWSCluster CR in the cluster namespace
*/}}
{{- define "loki.crossplane.tags" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
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
{{- $userTags := .Values.crossplane.tags | default list -}}
{{- $allTags := concat $tags $defaultTags $userTags -}}
{{- dict "tags" $allTags | toYaml -}}
{{- end -}}
