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
{{ include "loki.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | default "atlas" | quote }}
giantswarm.io/service-type: "managed"
helm.sh/chart: {{ include "loki.chart" . }}
{{- end }}
