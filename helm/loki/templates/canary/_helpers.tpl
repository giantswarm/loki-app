{{/*
canary fullname
*/}}
{{- define "loki-canary.fullname" -}}
{{ include "loki.name" . }}-canary
{{- end }}

{{/*
canary common labels
*/}}
{{- define "loki-canary.labels" -}}
{{ include "loki.labels" . }}
app.kubernetes.io/component: canary
{{- end }}

// Canary config is a bit hacky, we expect the replicaset canary to be supported upstream for a proper solution
// See PR: https://github.com/grafana/loki/pull/13362

{{/*
canary selector labels
*/}}
{{- define "loki-canary.selectorLabels" -}}
app.kubernetes.io/component: canary
app.kubernetes.io/instance: loki
app.kubernetes.io/name: loki
{{- end }}

{{/*
Docker image name for loki-canary
*/}}
{{- define "loki-canary.image" -}}
{{ $.Values.global.image.registry }}/giantswarm/loki-canary:{{ .Chart.AppVersion }}
{{- end -}}

{{/*
gateway fullname
*/}}
{{- define "loki.gatewayFullname" -}}
{{ include "loki.fullname" . }}-gateway
{{- end }}

{{/* Determine the public host for the Loki cluster */}}
{{- define "loki.host" -}}
{{- $url := printf "%s.%s.svc.%s.:%s" (include "loki.gatewayFullname" .) .Release.Namespace .Values.global.clusterDomain "80" }}
{{- printf "%s" $url -}}
{{- end -}}
