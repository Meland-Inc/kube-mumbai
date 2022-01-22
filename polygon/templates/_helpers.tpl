{{/*
Expand the name of the chart.
*/}}
{{- define "polygon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "polygon.fullname" -}}
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

{{- define "heimdall.fullname" -}}
{{- include "polygon.fullname" . }}-heimdall
{{- end }}

{{/*
heimdall service address
*/}}
{{- define "heimdall.address" -}}
{{- default .Values.heimdallAddress (include "heimdall.fullname" .) }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "polygon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "polygon.heimdallLabels" -}}
helm.sh/chart: {{ include "polygon.chart" . }}
{{ include "polygon.heimdallSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "polygon.borLabels" -}}
helm.sh/chart: {{ include "polygon.chart" . }}
{{ include "polygon.borSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
bor Selector labels
*/}}
{{- define "polygon.borSelectorLabels" -}}
app.kubernetes.io/name: {{ include "polygon.name" . }}-bor
app.kubernetes.io/instance: {{ .Release.Name }}-bor
{{- end }}

{{/*
Selector labels
*/}}
{{- define "polygon.heimdallSelectorLabels" -}}
app.kubernetes.io/name: {{ include "polygon.name" . }}-heimdall
app.kubernetes.io/instance: {{ .Release.Name }}-heimdall
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "polygon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "polygon.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
