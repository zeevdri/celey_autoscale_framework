{{- define "celeryWorkerApp.appName" -}}
{{ include "celery-autoscale.name" . }}-{{ .Values.appName }}
{{- end }}

{{- define "celeryWorkerApp.workerName" -}}
{{ include "celeryWorkerApp.appName" . }}-worker
{{- end }}

{{- define "celeryWorkerApp.scalerName" -}}
{{ include "celeryWorkerApp.appName" . }}-scaler
{{- end }}

{{- define "celeryWorkerApp.fullname" -}}
{{ include "celery-autoscale.fullname" . }}-{{ .Values.appName }}
{{- end }}

{{- define "celeryWorkerApp.deploymentFullName" -}}
{{ include "celeryWorkerApp.fullname" . -}}-worker
{{- end -}}

{{- define "celeryWorkerApp.scalerFullName" -}}
{{ include "celeryWorkerApp.fullname" . }}-scaler
{{- end -}}

{{- define "celeryWorkerApp.labels" -}}
helm.sh/chart: {{ include "celery-autoscale.chart" . }}
{{ include "celeryWorkerApp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "celeryWorkerApp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "celeryWorkerApp.workerName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "celeryWorkerApp.worker" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "celeryWorkerApp.deploymentFullName" . }}
  namespace {{ .Values.namespace | default "celery-autoscale" }}
  labels:
    {{- include "celeryWorkerApp.labels" . | nindent 4 }}
spec:
  replicas: {{ default .Values.replicaCount 0 }}
  selector:
    matchLabels:
      {{- include "celeryWorkerApp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      name: {{ include "celeryWorkerApp.workerName" . }}
      labels:
        {{- include "celeryWorkerApp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ include "celeryWorkerApp.workerName" . }}
          image: "{{ .Values.workerImage.repository }}:{{ .Values.workerImage.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.workerImage.pullPolicy }}
          command: ['sh', '-c']
          args: ['celery -A tasks worker --loglevel INFO --queues $(WORKER_QUEUE) -n ${HOSTNAME} -c 1']
          readinessProbe:
            exec:
              command: ['sh', '-c', 'celery', '-A', 'tasks', 'inspect', 'ping', '-d', 'celery@${HOSTNAME}']
            initialDelaySeconds: 10
            timeoutSeconds: 5
            periodSeconds: 3
          livenessProbe:
            exec:
              command: ['sh', '-c', 'celery', '-A', 'tasks', 'inspect', 'ping', '-d', 'celery@${HOSTNAME}']
            initialDelaySeconds: 10
            timeoutSeconds: 5
            periodSeconds: 3
            failureThreshold: 5
            successThreshold: 1
          env:
          - name: CELERY_BROKER_URL
            value: amqp://celery-broker:5672//
          - name: CELERY_RESULTS_BACKEND
            value: redis://celery-results:6379/0
          - name: WORKER_QUEUE
            value: {{ .Values.queueName }}
            {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      restartPolicy: Always
{{- end }}


{{- define "celeryWorkerApp.scaler" -}}
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: {{ include "celeryWorkerApp.scalerFullName" . }}
  namespace {{ .Values.namespace | default "celery-autoscale" }}
spec:
  scaleTargetRef:
    apiVersion:    apps/v1
    kind:          Deployment
    name:          {{ include "celeryWorkerApp.deploymentFullName" . }}
  pollingInterval: {{ .Values.scalerPollingInterval | default 30 }}
  cooldownPeriod:  {{ .Values.scalerCooldownPeriod | default 300 }}
  minReplicaCount: {{ .Values.minReplicaCount | default 0 }}
  maxReplicaCount: {{ .Values.maxReplicaCount | default 100 }}
  triggers:
    - type: rabbitmq
      metadata:
        protocol: http
        mode: QueueLength
        value: {{ .Values.scalerTasksPerWorker | default 1 | quote }}
        queueName: {{ .Values.queueName }}
      authenticationRef:
        name: {{ .Values.brokerScalerAuthName }}
{{- end }}

{{- define "celeryWorkerApp.app" -}}
---

{{ template "celeryWorkerApp.worker" . }}
...

---

{{ template "celeryWorkerApp.scaler" . }}


{{- end }}