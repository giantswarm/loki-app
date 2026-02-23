
{{/*
Sanitize storage account name for Azure
Azure storage account names must be:
- Between 3 and 24 characters
- Lowercase letters and numbers only
- Globally unique
*/}}
{{- define "loki.crossplane.azure.storageAccountName" -}}
{{- $containerName := .containerName -}}
{{- $sanitized := regexReplaceAll "[^a-z0-9]" (lower $containerName) "" -}}
{{- $sanitized | trunc 24 -}}
{{- end -}}


