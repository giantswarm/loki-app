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
Get AWS Account ID from AWSClusterControllerIdentity
*/}}
{{- define "loki.storage.awsAccountId" -}}
{{- $clusterName := .Values.loki.loki.storage.provisioning.clusterName -}}
{{- $clusterNamespace := .Values.loki.loki.storage.provisioning.clusterNamespace -}}
{{- $accountId := "" -}}
{{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
{{- if $awsCluster -}}
  {{- if $awsCluster.spec.identityRef -}}
    {{- $identityName := $awsCluster.spec.identityRef.name -}}
    {{- $identityNamespace := $clusterNamespace -}}
    {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSClusterControllerIdentity" "" $identityName -}}
    {{- if $identity -}}
      {{- $accountId = $identity.spec.awsAccountID -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $accountId -}}
{{- end -}}

{{/*
Get OIDC Provider URL from cluster
*/}}
{{- define "loki.storage.oidcProvider" -}}
{{- $clusterName := .Values.loki.loki.storage.provisioning.clusterName -}}
{{- $clusterNamespace := .Values.loki.loki.storage.provisioning.clusterNamespace -}}
{{- $oidcProvider := "" -}}
{{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
{{- if $awsCluster -}}
  {{- if $awsCluster.spec.identityRef -}}
    {{- $identityName := $awsCluster.spec.identityRef.name -}}
    {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSClusterControllerIdentity" "" $identityName -}}
    {{- if and $identity $identity.spec.oidc -}}
      {{- $oidcProvider = $identity.spec.oidc.issuerURL | trimPrefix "https://" -}}
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
{{- toYaml $allTags -}}
{{- end -}}

{{/*
Service account IAM annotations
Merges user-provided annotations with IAM role annotation when storage provisioning is enabled
*/}}
{{- define "loki.serviceAccount.annotations" -}}
{{- $annotations := .Values.loki.serviceAccount.annotations | default dict -}}
{{- if and (include "loki.storage.provisioning.enabled" .) (include "loki.storage.provisioning.isAWS" .) .Values.loki.loki.storage.provisioning.iam.enabled -}}
{{- $roleArn := include "loki.storage.iamRoleArn" . -}}
{{- $_ := set $annotations "eks.amazonaws.com/role-arn" $roleArn -}}
{{- end -}}
{{- toYaml $annotations -}}
{{- end -}}
