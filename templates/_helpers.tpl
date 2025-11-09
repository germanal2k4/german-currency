{{/*
Release name
*/}}
{{- define "german-currency.release-name" -}}
{{ .Release.Name }}
{{- end }}

{{/*
Resource name
*/}}
{{- define "german-currency.resource-name" -}}
{{- .Release.Name }}-{{ .Values.appLabel -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "german-currency.selector" -}}
app: {{ .Values.appLabel }}
{{- end }}

{{/*
Resource labels
*/}}
{{- define "german-currency.labels" -}}
app: {{ .Values.appLabel }}
{{- end }}

{{/*
Liveness probe template
*/}}
{{- define "german-currency.liveness" -}}
livenessProbe:
  httpGet:
    path: {{ .Values.livenessProbe.httpGet.path }}
    port: {{ .Values.livenessProbe.httpGet.port }}
  initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
{{- end }}

{{/*
Readiness probe template
*/}}
{{- define "german-currency.readiness" -}}
readinessProbe:
  httpGet:
    path: {{ .Values.readinessProbe.httpGet.path }}
    port: {{ .Values.readinessProbe.httpGet.port }}
  initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
{{- end }}
