{{/*
Expand the name of the chart.
*/}}
{{- define "multitier.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "multitier.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "multitier.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "multitier.labels" -}}
helm.sh/chart: {{ include "multitier.chart" . }}
{{ include "multitier.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "multitier.selectorLabels" -}}
app.kubernetes.io/name: {{ include "multitier.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "multitier.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "multitier.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Frontend full name
*/}}
{{- define "multitier.frontend.fullname" -}}
{{ include "multitier.fullname" . }}-{{ .Values.frontend.name }}
{{- end }}

{{/*
Backend full name
*/}}
{{- define "multitier.backend.fullname" -}}
{{ include "multitier.fullname" . }}-{{ .Values.backend.name }}
{{- end }}

{{/*
Database full name
*/}}
{{- define "multitier.database.fullname" -}}
{{ include "multitier.fullname" . }}-{{ .Values.database.name }}
{{- end }}
