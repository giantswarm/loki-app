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
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | default "atlas" | quote }}
{{- end }}

{{/* Snippet for the nginx file used by gateway */}}
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
