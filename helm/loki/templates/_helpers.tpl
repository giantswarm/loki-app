{{/*
Expand the name of the chart.
*/}}
{{- define "loki.name" -}}
loki
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
# application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
application.giantswarm.io/team: atlas
{{- end }}
