{{/*
Expand the name of the chart.
*/}}
{{- define "loki.name" -}}
{{- $default := "loki" }}
{{- coalesce .Values.nameOverride .Values.loki.nameOverride $default | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Whether to render Cilium-specific policies. The upstream chart removed
`networkPolicy.flavor` in its v15, so the switch lives at the top level now.
`loki.networkPolicy.flavor: kubernetes` is still honoured as an opt-out for values files
written against loki-app 0.46.x and earlier.
Returns a string, so compare it: `eq (include "loki.ciliumPolicies" .) "true"`.
*/}}
{{- define "loki.ciliumPolicies" -}}
{{- $legacyKubernetesFlavor := eq (dig "networkPolicy" "flavor" "" .Values.loki) "kubernetes" -}}
{{- and .Values.ciliumNetworkPolicy.enabled (not $legacyKubernetesFlavor) -}}
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
application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | default "atlas" | quote }}
giantswarm.io/service-type: "managed"
helm.sh/chart: {{ include "loki.chart" . }}
{{- end }}

{{/*
`gatewayRoute.additionalRules`, with the `requestMirror` filter appended to each rule when enabled.
*/}}
{{- define "loki.gatewayRoute.additionalRules" -}}
{{- $route := .Values.gatewayRoute }}
{{- $rules := list }}
{{- range $rule := $route.additionalRules }}
{{- /* Copy first — `set` would write the filter into .Values. */}}
{{- $r := deepCopy $rule }}
{{- if $route.requestMirror.enabled }}
{{- /* Not $route.filters: those feed the default rule, which rejects
       requests missing X-Scope-OrgID — only rejections would be copied. */}}
{{- $requestMirror := dict "backendRef" $route.requestMirror.backendRef }}
{{- $_ := set $r "filters" (append (default list $r.filters) (dict "type" "RequestMirror" "requestMirror" $requestMirror)) }}
{{- end }}
{{- $rules = append $rules $r }}
{{- end }}
{{- with $rules }}{{ tpl (toYaml .) $ }}{{ end }}
{{- end }}
