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

{{/* Snippet for the nginx file used by gateway */}}
{{/* duplicated from sub-chart, but with a specific config when using multi-tenant-gateway */}}
{{- define "loki.nginxFile" }}
worker_processes  5;  ## Default: 1
error_log  /dev/stderr;
pid        /tmp/nginx.pid;
worker_rlimit_nofile 8192;

events {
  worker_connections  4096;  ## Default: 1024
}

http {
  client_body_temp_path /tmp/client_temp;
  proxy_temp_path       /tmp/proxy_temp_path;
  fastcgi_temp_path     /tmp/fastcgi_temp;
  uwsgi_temp_path       /tmp/uwsgi_temp;
  scgi_temp_path        /tmp/scgi_temp;

  proxy_http_version    1.1;

  default_type application/octet-stream;
  log_format   {{ .Values.gateway.nginxConfig.logFormat }}

  {{- if .Values.gateway.verboseLogging }}
  access_log   /dev/stderr  main;
  {{- else }}

  map $status $loggable {
    ~^[23]  0;
    default 1;
  }
  access_log   /dev/stderr  main  if=$loggable;
  {{- end }}

  sendfile     on;
  tcp_nopush   on;
  resolver {{ .Values.global.dnsService }}.{{ .Values.global.dnsNamespace }}.svc.{{ .Values.global.clusterDomain }}.;

  {{- with .Values.gateway.nginxConfig.httpSnippet }}
  {{ . | nindent 2 }}
  {{- end }}

  server {
    listen             8080;

    {{- if .Values.gateway.basicAuth.enabled }}
    auth_basic           "Loki";
    auth_basic_user_file /etc/nginx/secrets/.htpasswd;
    {{- end }}

    location = / {
      return 200 'OK';
      auth_basic off;
    }

    {{- if .Values.gateway.nginxConfig.genMultiTenant }} {{/* multitenant-specific nginx config */}}
    location = /api/prom/push {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3101$request_uri;
    }

    location = /api/prom/tail {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

    location ~ /api/prom/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    {{- if .Values.read.legacyReadTarget }}
    location ~ /prometheus/api/v1/alerts.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /prometheus/api/v1/rules.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /ruler/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- else }}
    location ~ /prometheus/api/v1/alerts.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3102$request_uri;
    }
    location ~ /prometheus/api/v1/rules.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3102$request_uri;
    }
    location ~ /ruler/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3102$request_uri;
    }
    {{- end }}

    location = /loki/api/v1/push {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3101$request_uri;
    }

    location = /loki/api/v1/tail {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

    {{- if .Values.read.legacyReadTarget }}
    location ~ /compactor/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- else }}
    location ~ /compactor/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3102$request_uri;
    }
    {{- end }}

    location ~ /distributor/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3101$request_uri;
    }

    location ~ /ring {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3101$request_uri;
    }

    location ~ /ingester/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3101$request_uri;
    }

    {{- if .Values.read.legacyReadTarget }}
    location ~ /store-gateway/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- else }}
    location ~ /store-gateway/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3102$request_uri;
    }
    {{- end }}

    {{- if .Values.read.legacyReadTarget }}
    location ~ /query-scheduler/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /scheduler/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- else }}
    location ~ /query-scheduler/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3102$request_uri;
    }
    location ~ /scheduler/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3102$request_uri;
    }
    {{- end }}

    location ~ /loki/api/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    location ~ /admin/api/.* {
      proxy_pass       http://loki-multi-tenant-proxy.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3101$request_uri;
    }
    {{- else }} {{/* default nginx config */}}
    location = /api/prom/push {
      proxy_pass       http://{{ include "loki.writeFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    location = /api/prom/tail {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

    location ~ /api/prom/.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    {{- if .Values.read.legacyReadTarget }}
    location ~ /prometheus/api/v1/alerts.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /prometheus/api/v1/rules.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /ruler/.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- else }}
    location ~ /prometheus/api/v1/alerts.* {
      proxy_pass       http://{{ include "loki.backendFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /prometheus/api/v1/rules.* {
      proxy_pass       http://{{ include "loki.backendFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /ruler/.* {
      proxy_pass       http://{{ include "loki.backendFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- end }}

    location = /loki/api/v1/push {
      proxy_pass       http://{{ include "loki.writeFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    location = /loki/api/v1/tail {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

    {{- if .Values.read.legacyReadTarget }}
    location ~ /compactor/.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- else }}
    location ~ /compactor/.* {
      proxy_pass       http://{{ include "loki.backendFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- end }}

    location ~ /distributor/.* {
      proxy_pass       http://{{ include "loki.writeFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    location ~ /ring {
      proxy_pass       http://{{ include "loki.writeFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    location ~ /ingester/.* {
      proxy_pass       http://{{ include "loki.writeFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    {{- if .Values.read.legacyReadTarget }}
    location ~ /store-gateway/.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- else }}
    location ~ /store-gateway/.* {
      proxy_pass       http://{{ include "loki.backendFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- end }}

    {{- if .Values.read.legacyReadTarget }}
    location ~ /query-scheduler/.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /scheduler/.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- else }}
    location ~ /query-scheduler/.* {
      proxy_pass       http://{{ include "loki.backendFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    location ~ /scheduler/.* {
      proxy_pass       http://{{ include "loki.backendFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- end }}

    location ~ /loki/api/.* {
      proxy_pass       http://{{ include "loki.readFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }

    location ~ /admin/api/.* {
      proxy_pass       http://{{ include "loki.writeFullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:3100$request_uri;
    }
    {{- end }}

    {{- with .Values.gateway.nginxConfig.serverSnippet }}
    {{ . | nindent 4 }}
    {{- end }}
  }
}
{{- end }}

{{/*
/!\ Giantswarm override to work around a bug in azure where `use_federated_token` fails.
/!\ This was copied from upstream (https://github.com/grafana/loki/blob/helm-loki-4.4.2/production/helm/loki/templates/_helpers.tpl#L179) and ˋuse_federated_token` was removed for azure`
/!\ Added on chart 4.10.0 / Loki 2.7.2 - to be removed when loki supports this (probably 2.8.0)
Generated storage config for loki common config
*/}}
{{- define "loki.commonStorageConfig" -}}
{{- if .Values.minio.enabled -}}
s3:
  endpoint: {{ include "loki.minio" $ }}
  bucketnames: {{ $.Values.loki.storage.bucketNames.chunks }}
  secret_access_key: {{ $.Values.minio.rootPassword }}
  access_key_id: {{ $.Values.minio.rootUser }}
  s3forcepathstyle: true
  insecure: true
{{- else if eq .Values.loki.storage.type "s3" -}}
{{- with .Values.loki.storage.s3 }}
s3:
  {{- with .s3 }}
  s3: {{ . }}
  {{- end }}
  {{- with .endpoint }}
  endpoint: {{ . }}
  {{- end }}
  {{- with .region }}
  region: {{ . }}
  {{- end}}
  bucketnames: {{ $.Values.loki.storage.bucketNames.chunks }}
  {{- with .secretAccessKey }}
  secret_access_key: {{ . }}
  {{- end }}
  {{- with .accessKeyId }}
  access_key_id: {{ . }}
  {{- end }}
  s3forcepathstyle: {{ .s3ForcePathStyle }}
  insecure: {{ .insecure }}
  {{- with .http_config}}
  http_config:
    {{- with .idle_conn_timeout }}
    idle_conn_timeout: {{ . }}
    {{- end}}
    {{- with .response_header_timeout }}
    response_header_timeout: {{ . }}
    {{- end}}
    {{- with .insecure_skip_verify }}
    insecure_skip_verify: {{ . }}
    {{- end}}
    {{- with .ca_file}}
    ca_file: {{ . }}
    {{- end}}
  {{- end }}
{{- end -}}
{{- else if eq .Values.loki.storage.type "gcs" -}}
{{- with .Values.loki.storage.gcs }}
gcs:
  bucket_name: {{ $.Values.loki.storage.bucketNames.chunks }}
  chunk_buffer_size: {{ .chunkBufferSize }}
  request_timeout: {{ .requestTimeout }}
  enable_http2: {{ .enableHttp2 }}
{{- end -}}
{{- else if eq .Values.loki.storage.type "azure" -}}
{{- with .Values.loki.storage.azure }}
azure:
  account_name: {{ .accountName }}
  {{- with .accountKey }}
  account_key: {{ . }}
  {{- end }}
  container_name: {{ $.Values.loki.storage.bucketNames.chunks }}
  use_managed_identity: {{ .useManagedIdentity }}
  {{- with .userAssignedId }}
  user_assigned_id: {{ . }}
  {{- end }}
  {{- with .requestTimeout }}
  request_timeout: {{ . }}
  {{- end }}
{{- end -}}
{{- else -}}
{{- with .Values.loki.storage.filesystem }}
filesystem:
  chunks_directory: {{ .chunks_directory }}
  rules_directory: {{ .rules_directory }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
/!\ Giantswarm override to work around a bug in azure where `use_federated_token` fails.
/!\ This was copied from upstream (https://github.com/grafana/loki/blob/helm-loki-4.4.2/production/helm/loki/templates/_helpers.tpl#L262) and ˋuse_federated_token` was removed for azure`
/!\ Added on chart 4.10.0 / Loki 2.7.2 - to be removed when loki supports this (probably 2.8.0)
Storage config for ruler
*/}}
{{- define "loki.rulerStorageConfig" -}}
{{- if .Values.minio.enabled -}}
type: "s3"
s3:
  bucketnames: {{ $.Values.loki.storage.bucketNames.ruler }}
{{- else if eq .Values.loki.storage.type "s3" -}}
{{- with .Values.loki.storage.s3 }}
type: "s3"
s3:
  {{- with .s3 }}
  s3: {{ . }}
  {{- end }}
  {{- with .endpoint }}
  endpoint: {{ . }}
  {{- end }}
  {{- with .region }}
  region: {{ . }}
  {{- end}}
  bucketnames: {{ $.Values.loki.storage.bucketNames.ruler }}
  {{- with .secretAccessKey }}
  secret_access_key: {{ . }}
  {{- end }}
  {{- with .accessKeyId }}
  access_key_id: {{ . }}
  {{- end }}
  s3forcepathstyle: {{ .s3ForcePathStyle }}
  insecure: {{ .insecure }}
{{- end -}}
{{- else if eq .Values.loki.storage.type "gcs" -}}
{{- with .Values.loki.storage.gcs }}
type: "gcs"
gcs:
  bucket_name: {{ $.Values.loki.storage.bucketNames.ruler }}
  chunk_buffer_size: {{ .chunkBufferSize }}
  request_timeout: {{ .requestTimeout }}
  enable_http2: {{ .enableHttp2 }}
{{- end -}}
{{- else if eq .Values.loki.storage.type "azure" -}}
{{- with .Values.loki.storage.azure }}
type: "azure"
azure:
  account_name: {{ .accountName }}
  {{- with .accountKey }}
  account_key: {{ . }}
  {{- end }}
  container_name: {{ $.Values.loki.storage.bucketNames.ruler }}
  use_managed_identity: {{ .useManagedIdentity }}
  {{- with .userAssignedId }}
  user_assigned_id: {{ . }}
  {{- end }}
  {{- with .requestTimeout }}
  request_timeout: {{ . }}
  {{- end }}
{{- end -}}
{{- else }}
type: "local"
{{- end -}}
{{- end -}}

