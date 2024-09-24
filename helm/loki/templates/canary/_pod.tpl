{{/*
Pod template used in Daemonset and Deployment
*/}}
{{- define "canary.podTemplate" -}}
metadata:
  {{- with $.Values.lokiCanary.annotations }}
  annotations:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  labels:
    {{- include "loki-canary.selectorLabels" $ | nindent 4 }}
    {{- with $.Values.lokiCanary.podLabels }}
    {{- toYaml . | nindent 8 }}
    {{- end }}
spec:
  serviceAccountName: {{ include "loki-canary.fullname" $ }}
  {{- with $.Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  securityContext:
    {{- toYaml $.Values.lokiCanary.podSecurityContext | nindent 4 }}
  containers:
    - name: loki-canary
      image: {{ include "loki-canary.image" $ }}
      imagePullPolicy: {{ $.Values.lokiCanary.image.pullPolicy }}
      args:
        - -addr={{- include "loki.host" $ }}
        - -labelname={{ $.Values.lokiCanary.labelname }}
        - -labelvalue=$(POD_NAME)
        {{- if $.Values.loki.auth_enabled }}
        - -user={{ $.Values.monitoring.selfMonitoring.tenant.name }}
        - -tenant-id={{ $.Values.monitoring.selfMonitoring.tenant.name }}
        - -pass={{ $.Values.monitoring.selfMonitoring.tenant.password }}
        {{- end }}
        {{- if $.Values.lokiCanary.push }}
        - -push=true
        {{- end }}
        {{- with $.Values.lokiCanary.extraArgs }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      securityContext:
        {{- toYaml $.Values.lokiCanary.containerSecurityContext | nindent 8 }}
      volumeMounts:
        {{- with $.Values.lokiCanary.extraVolumeMounts }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      ports:
        - name: http-metrics
          containerPort: 3500
          protocol: TCP
      env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        {{- with $.Values.lokiCanary.extraEnv }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- with $.Values.lokiCanary.extraEnvFrom }}
      envFrom:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      readinessProbe:
        httpGet:
          path: /metrics
          port: http-metrics
        initialDelaySeconds: 15
        timeoutSeconds: 1
      {{- with $.Values.lokiCanary.resources}}
      resources:
        {{- toYaml . | nindent 8 }}
      {{- end }}
  {{- with $.Values.lokiCanary.dnsConfig }}
  dnsConfig:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $.Values.lokiCanary.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $.Values.lokiCanary.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  volumes:
  {{- with $.Values.lokiCanary.extraVolumes }}
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
