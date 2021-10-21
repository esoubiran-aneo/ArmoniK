apiVersion: batch/v1
kind: Job
metadata:
  name: single-task
spec:
  template:
    spec:
      containers:
      - args: [Client.dll]
        name: generator
        securityContext:
            {}
        image: {{docker_registry}}{{image_name}}:{{image_tag}}
        imagePullPolicy: IfNotPresent
        resources:
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 100m
              memory: 128Mi
        volumeMounts:
          - name: agent-config-volume
            mountPath: /etc/agent
          - name: redis-certificates-volume
            mountPath: /redis_certificates
        env:
          - name: INTRA_VPC
            value: "1"
      restartPolicy: Never
      volumes:
        - name: agent-config-volume
          configMap:
            name: agent-configmap
        - name: redis-certificates-volume
          hostPath:
            path: {{redis_certificates_directory}}
            type: Directory
      imagePullSecrets:
        - name: regcred
  backoffLimit: 0