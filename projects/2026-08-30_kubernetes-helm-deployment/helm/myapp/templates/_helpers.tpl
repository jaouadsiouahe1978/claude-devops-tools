{{- define "myapp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "myapp.labels" -}}
app: {{ include "myapp.fullname" . }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{- define "myapp.selectorLabels" -}}
app: {{ include "myapp.fullname" . }}
release: {{ .Release.Name }}
{{- end }}
