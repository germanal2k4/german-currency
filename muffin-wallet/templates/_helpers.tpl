{{/*
Simple naming helpers.
*/}}
{{- define "muffin-wallet.release-name" -}}
{{ .Release.Name }}
{{- end }}

{{- define "muffin-wallet.resource-name" -}}
{{- printf "%s-%s" .Release.Name .Values.appLabel -}}
{{- end }}

{{- define "muffin-wallet.labels" -}}
app: {{ .Values.appLabel }}
{{- end }}

{{- define "muffin-wallet.selector" -}}
app: {{ .Values.appLabel }}
{{- end }}
