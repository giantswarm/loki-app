{{/*
multi-tenant-proxy common labels
*/}}
{{- define "loki.multiTenantProxyLabels" -}}
{{ include "loki.labels" . }}
app.kubernetes.io/component: multi-tenant-proxy
{{- end }}

{{/*
multi-tenant-proxy selector labels
*/}}
{{- define "loki.multiTenantProxySelectorLabels" -}}
{{ include "loki.selectorLabels" . }}
app.kubernetes.io/component: multi-tenant-proxy
{{- end }}
