
locals {  
  namespace = var.namespace != null ? var.namespace : yamlencode({
      "apiVersion" = "v1"
      "kind"       = "Namespace"
      "metadata" = {
        "name" = "kfserving"
        "labels" = {
          "control-plane"   = "kubeflow"
          "istio-injection" = "disabled"
        }
      }
    })


  kfserving_def = var.kfserving_def != null ? var.kfserving_def : <<EOT
apiVersion: v1
kind: Namespace
metadata:
  labels:
    control-plane: kfserving-controller-manager
    controller-tools.k8s.io: "1.0"
    istio-injection: disabled
  name: kfserving-system
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: (unknown)
  creationTimestamp: null
  name: inferenceservices.serving.kubeflow.org
spec:
  additionalPrinterColumns:
    - JSONPath: .status.url
      name: URL
      type: string
    - JSONPath: .status.conditions[?(@.type=='Ready')].status
      name: Ready
      type: string
    - JSONPath: .status.traffic
      name: Default Traffic
      type: integer
    - JSONPath: .status.canaryTraffic
      name: Canary Traffic
      type: integer
    - JSONPath: .metadata.creationTimestamp
      name: Age
      type: date
  group: serving.kubeflow.org
  names:
    kind: InferenceService
    listKind: InferenceServiceList
    plural: inferenceservices
    shortNames:
      - inferenceservice
    singular: inferenceservice
  scope: Namespaced
  subresources:
    status: {}
  validation:
    openAPIV3Schema:
      description: InferenceService is the Schema for the services API
      properties:
        apiVersion:
          description:
            "APIVersion defines the versioned schema of this representation
            of an object. Servers should convert recognized schemas to the latest
            internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources"
          type: string
        kind:
          description:
            "Kind is a string value representing the REST resource this
            object represents. Servers may infer this from the endpoint the client
            submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds"
          type: string
        metadata:
          type: object
        spec:
          description: InferenceServiceSpec defines the desired state of InferenceService
          properties:
            canary:
              description:
                Canary defines an alternate endpoints to route a percentage
                of traffic.
              properties:
                explainer:
                  description:
                    Explainer defines the model explanation service spec,
                    explainer service calls to predictor or transformer if it is specified.
                  properties:
                    alibi:
                      description: Spec for alibi explainer
                      properties:
                        config:
                          additionalProperties:
                            type: string
                          description: Inline custom parameter settings for explainer
                          type: object
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description: Defaults to latest Alibi Version
                          type: string
                        storageUri:
                          description: The location of a trained explanation model
                          type: string
                        type:
                          description: The type of Alibi explainer
                          type: string
                      required:
                        - type
                      type: object
                    custom:
                      description: Spec for a custom explainer
                      properties:
                        container:
                          description:
                            A single application container that you want
                            to run within a pod.
                          properties:
                            args:
                              description:
                                "Arguments to the entrypoint. The docker
                                image's CMD is used if this is not provided. Variable
                                references $(VAR_NAME) are expanded using the container's
                                environment. If a variable cannot be resolved, the
                                reference in the input string will be unchanged. The
                                $(VAR_NAME) syntax can be escaped with a double $$,
                                ie: $$(VAR_NAME). Escaped references will never be
                                expanded, regardless of whether the variable exists
                                or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            command:
                              description:
                                "Entrypoint array. Not executed within
                                a shell. The docker image's ENTRYPOINT is used if
                                this is not provided. Variable references $(VAR_NAME)
                                are expanded using the container's environment. If
                                a variable cannot be resolved, the reference in the
                                input string will be unchanged. The $(VAR_NAME) syntax
                                can be escaped with a double $$, ie: $$(VAR_NAME).
                                Escaped references will never be expanded, regardless
                                of whether the variable exists or not. Cannot be updated.
                                More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            env:
                              description:
                                List of environment variables to set in
                                the container. Cannot be updated.
                              items:
                                description:
                                  EnvVar represents an environment variable
                                  present in a Container.
                                properties:
                                  name:
                                    description:
                                      Name of the environment variable.
                                      Must be a C_IDENTIFIER.
                                    type: string
                                  value:
                                    description:
                                      'Variable references $(VAR_NAME)
                                      are expanded using the previous defined environment
                                      variables in the container and any service environment
                                      variables. If a variable cannot be resolved,
                                      the reference in the input string will be unchanged.
                                      The $(VAR_NAME) syntax can be escaped with a
                                      double $$, ie: $$(VAR_NAME). Escaped references
                                      will never be expanded, regardless of whether
                                      the variable exists or not. Defaults to "".'
                                    type: string
                                  valueFrom:
                                    description:
                                      Source for the environment variable's
                                      value. Cannot be used if value is not empty.
                                    properties:
                                      configMapKeyRef:
                                        description: Selects a key of a ConfigMap.
                                        properties:
                                          key:
                                            description: The key to select.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the ConfigMap
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                      fieldRef:
                                        description:
                                          "Selects a field of the pod:
                                          supports metadata.name, metadata.namespace,
                                          metadata.labels, metadata.annotations, spec.nodeName,
                                          spec.serviceAccountName, status.hostIP,
                                          status.podIP."
                                        properties:
                                          apiVersion:
                                            description:
                                              Version of the schema the
                                              FieldPath is written in terms of, defaults
                                              to "v1".
                                            type: string
                                          fieldPath:
                                            description:
                                              Path of the field to select
                                              in the specified API version.
                                            type: string
                                        required:
                                          - fieldPath
                                        type: object
                                      resourceFieldRef:
                                        description:
                                          "Selects a resource of the container:
                                          only resources limits and requests (limits.cpu,
                                          limits.memory, limits.ephemeral-storage,
                                          requests.cpu, requests.memory and requests.ephemeral-storage)
                                          are currently supported."
                                        properties:
                                          containerName:
                                            description:
                                              "Container name: required
                                              for volumes, optional for env vars"
                                            type: string
                                          divisor:
                                            description:
                                              Specifies the output format
                                              of the exposed resources, defaults to
                                              "1"
                                            type: string
                                          resource:
                                            description: "Required: resource to select"
                                            type: string
                                        required:
                                          - resource
                                        type: object
                                      secretKeyRef:
                                        description:
                                          Selects a key of a secret in
                                          the pod's namespace
                                        properties:
                                          key:
                                            description:
                                              The key of the secret to
                                              select from.  Must be a valid secret
                                              key.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the Secret
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                    type: object
                                required:
                                  - name
                                type: object
                              type: array
                            envFrom:
                              description:
                                List of sources to populate environment
                                variables in the container. The keys defined within
                                a source must be a C_IDENTIFIER. All invalid keys
                                will be reported as an event when the container is
                                starting. When a key exists in multiple sources, the
                                value associated with the last source will take precedence.
                                Values defined by an Env with a duplicate key will
                                take precedence. Cannot be updated.
                              items:
                                description:
                                  EnvFromSource represents the source of
                                  a set of ConfigMaps
                                properties:
                                  configMapRef:
                                    description: The ConfigMap to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the ConfigMap
                                          must be defined
                                        type: boolean
                                    type: object
                                  prefix:
                                    description:
                                      An optional identifier to prepend
                                      to each key in the ConfigMap. Must be a C_IDENTIFIER.
                                    type: string
                                  secretRef:
                                    description: The Secret to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the Secret must
                                          be defined
                                        type: boolean
                                    type: object
                                type: object
                              type: array
                            image:
                              description:
                                "Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images
                                This field is optional to allow higher level config
                                management to default or override container images
                                in workload controllers like Deployments and StatefulSets."
                              type: string
                            imagePullPolicy:
                              description:
                                "Image pull policy. One of Always, Never,
                                IfNotPresent. Defaults to Always if :v0.3.0 tag is
                                specified, or IfNotPresent otherwise. Cannot be updated.
                                More info: https://kubernetes.io/docs/concepts/containers/images#updating-images"
                              type: string
                            lifecycle:
                              description:
                                Actions that the management system should
                                take in response to container lifecycle events. Cannot
                                be updated.
                              properties:
                                postStart:
                                  description:
                                    "PostStart is called immediately after
                                    a container is created. If the handler fails,
                                    the container is terminated and restarted according
                                    to its restart policy. Other management of the
                                    container blocks until the hook completes. More
                                    info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                                preStop:
                                  description:
                                    "PreStop is called immediately before
                                    a container is terminated due to an API request
                                    or management event such as liveness probe failure,
                                    preemption, resource contention, etc. The handler
                                    is not called if the container crashes or exits.
                                    The reason for termination is passed to the handler.
                                    The Pod's termination grace period countdown
                                    begins before the PreStop hooked is executed.
                                    Regardless of the outcome of the handler, the
                                    container will eventually terminate within the
                                    Pod's termination grace period. Other management
                                    of the container blocks until the hook completes
                                    or until the termination grace period is reached.
                                    More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                              type: object
                            livenessProbe:
                              description:
                                "Periodic probe of container liveness.
                                Container will be restarted if the probe fails. Cannot
                                be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            name:
                              description:
                                Name of the container specified as a DNS_LABEL.
                                Each container in a pod must have a unique name (DNS_LABEL).
                                Cannot be updated.
                              type: string
                            ports:
                              description:
                                List of ports to expose from the container.
                                Exposing a port here gives the system additional information
                                about the network connections a container uses, but
                                is primarily informational. Not specifying a port
                                here DOES NOT prevent that port from being exposed.
                                Any port which is listening on the default "0.0.0.0"
                                address inside a container will be accessible from
                                the network. Cannot be updated.
                              items:
                                description:
                                  ContainerPort represents a network port
                                  in a single container.
                                properties:
                                  containerPort:
                                    description:
                                      Number of port to expose on the pod's
                                      IP address. This must be a valid port number,
                                      0 < x < 65536.
                                    format: int32
                                    type: integer
                                  hostIP:
                                    description:
                                      What host IP to bind the external
                                      port to.
                                    type: string
                                  hostPort:
                                    description:
                                      Number of port to expose on the host.
                                      If specified, this must be a valid port number,
                                      0 < x < 65536. If HostNetwork is specified,
                                      this must match ContainerPort. Most containers
                                      do not need this.
                                    format: int32
                                    type: integer
                                  name:
                                    description:
                                      If specified, this must be an IANA_SVC_NAME
                                      and unique within the pod. Each named port in
                                      a pod must have a unique name. Name for the
                                      port that can be referred to by services.
                                    type: string
                                  protocol:
                                    description:
                                      Protocol for port. Must be UDP, TCP,
                                      or SCTP. Defaults to "TCP".
                                    type: string
                                required:
                                  - containerPort
                                type: object
                              type: array
                            readinessProbe:
                              description:
                                "Periodic probe of container service readiness.
                                Container will be removed from service endpoints if
                                the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            resources:
                              description:
                                "Compute Resources required by this container.
                                Cannot be updated. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              properties:
                                limits:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Limits describes the maximum amount
                                    of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                                requests:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Requests describes the minimum amount
                                    of compute resources required. If Requests is
                                    omitted for a container, it defaults to Limits
                                    if that is explicitly specified, otherwise to
                                    an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                              type: object
                            securityContext:
                              description:
                                "Security options the pod should run with.
                                More info: https://kubernetes.io/docs/concepts/policy/security-context/
                                More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"
                              properties:
                                allowPrivilegeEscalation:
                                  description:
                                    "AllowPrivilegeEscalation controls
                                    whether a process can gain more privileges than
                                    its parent process. This bool directly controls
                                    if the no_new_privs flag will be set on the container
                                    process. AllowPrivilegeEscalation is true always
                                    when the container is: 1) run as Privileged 2)
                                    has CAP_SYS_ADMIN"
                                  type: boolean
                                capabilities:
                                  description:
                                    The capabilities to add/drop when running
                                    containers. Defaults to the default set of capabilities
                                    granted by the container runtime.
                                  properties:
                                    add:
                                      description: Added capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                    drop:
                                      description: Removed capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                  type: object
                                privileged:
                                  description:
                                    Run container in privileged mode. Processes
                                    in privileged containers are essentially equivalent
                                    to root on the host. Defaults to false.
                                  type: boolean
                                procMount:
                                  description:
                                    procMount denotes the type of proc
                                    mount to use for the containers. The default is
                                    DefaultProcMount which uses the container runtime
                                    defaults for readonly paths and masked paths.
                                    This requires the ProcMountType feature flag to
                                    be enabled.
                                  type: string
                                readOnlyRootFilesystem:
                                  description:
                                    Whether this container has a read-only
                                    root filesystem. Default is false.
                                  type: boolean
                                runAsGroup:
                                  description:
                                    The GID to run the entrypoint of the
                                    container process. Uses runtime default if unset.
                                    May also be set in PodSecurityContext.  If set
                                    in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                runAsNonRoot:
                                  description:
                                    Indicates that the container must run
                                    as a non-root user. If true, the Kubelet will
                                    validate the image at runtime to ensure that it
                                    does not run as UID 0 (root) and fail to start
                                    the container if it does. If unset or false, no
                                    such validation will be performed. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  type: boolean
                                runAsUser:
                                  description:
                                    The UID to run the entrypoint of the
                                    container process. Defaults to user specified
                                    in image metadata if unspecified. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                seLinuxOptions:
                                  description:
                                    The SELinux context to be applied to
                                    the container. If unspecified, the container runtime
                                    will allocate a random SELinux context for each
                                    container.  May also be set in PodSecurityContext.  If
                                    set in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  properties:
                                    level:
                                      description:
                                        Level is SELinux level label that
                                        applies to the container.
                                      type: string
                                    role:
                                      description:
                                        Role is a SELinux role label that
                                        applies to the container.
                                      type: string
                                    type:
                                      description:
                                        Type is a SELinux type label that
                                        applies to the container.
                                      type: string
                                    user:
                                      description:
                                        User is a SELinux user label that
                                        applies to the container.
                                      type: string
                                  type: object
                                windowsOptions:
                                  description: Windows security options.
                                  properties:
                                    gmsaCredentialSpec:
                                      description:
                                        GMSACredentialSpec is where the
                                        GMSA admission webhook (https://github.com/kubernetes-sigs/windows-gmsa)
                                        inlines the contents of the GMSA credential
                                        spec named by the GMSACredentialSpecName field.
                                        This field is alpha-level and is only honored
                                        by servers that enable the WindowsGMSA feature
                                        flag.
                                      type: string
                                    gmsaCredentialSpecName:
                                      description:
                                        GMSACredentialSpecName is the name
                                        of the GMSA credential spec to use. This field
                                        is alpha-level and is only honored by servers
                                        that enable the WindowsGMSA feature flag.
                                      type: string
                                  type: object
                              type: object
                            stdin:
                              description:
                                Whether this container should allocate
                                a buffer for stdin in the container runtime. If this
                                is not set, reads from stdin in the container will
                                always result in EOF. Default is false.
                              type: boolean
                            stdinOnce:
                              description:
                                Whether the container runtime should close
                                the stdin channel after it has been opened by a single
                                attach. When stdin is true the stdin stream will remain
                                open across multiple attach sessions. If stdinOnce
                                is set to true, stdin is opened on container start,
                                is empty until the first client attaches to stdin,
                                and then remains open and accepts data until the client
                                disconnects, at which time stdin is closed and remains
                                closed until the container is restarted. If this flag
                                is false, a container processes that reads from stdin
                                will never receive an EOF. Default is false
                              type: boolean
                            terminationMessagePath:
                              description:
                                "Optional: Path at which the file to which
                                the container's termination message will be written
                                is mounted into the container's filesystem. Message
                                written is intended to be brief final status, such
                                as an assertion failure message. Will be truncated
                                by the node if greater than 4096 bytes. The total
                                message length across all containers will be limited
                                to 12kb. Defaults to /dev/termination-log. Cannot
                                be updated."
                              type: string
                            terminationMessagePolicy:
                              description:
                                Indicate how the termination message should
                                be populated. File will use the contents of terminationMessagePath
                                to populate the container status message on both success
                                and failure. FallbackToLogsOnError will use the last
                                chunk of container log output if the termination message
                                file is empty and the container exited with an error.
                                The log output is limited to 2048 bytes or 80 lines,
                                whichever is smaller. Defaults to File. Cannot be
                                updated.
                              type: string
                            tty:
                              description:
                                Whether this container should allocate
                                a TTY for itself, also requires 'stdin' to be true.
                                Default is false.
                              type: boolean
                            volumeDevices:
                              description:
                                volumeDevices is the list of block devices
                                to be used by the container. This is a beta feature.
                              items:
                                description:
                                  volumeDevice describes a mapping of a
                                  raw block device within a container.
                                properties:
                                  devicePath:
                                    description:
                                      devicePath is the path inside of
                                      the container that the device will be mapped
                                      to.
                                    type: string
                                  name:
                                    description:
                                      name must match the name of a persistentVolumeClaim
                                      in the pod
                                    type: string
                                required:
                                  - devicePath
                                  - name
                                type: object
                              type: array
                            volumeMounts:
                              description:
                                Pod volumes to mount into the container's
                                filesystem. Cannot be updated.
                              items:
                                description:
                                  VolumeMount describes a mounting of a
                                  Volume within a container.
                                properties:
                                  mountPath:
                                    description:
                                      Path within the container at which
                                      the volume should be mounted.  Must not contain
                                      ':'.
                                    type: string
                                  mountPropagation:
                                    description:
                                      mountPropagation determines how mounts
                                      are propagated from the host to container and
                                      the other way around. When not set, MountPropagationNone
                                      is used. This field is beta in 1.10.
                                    type: string
                                  name:
                                    description: This must match the Name of a Volume.
                                    type: string
                                  readOnly:
                                    description:
                                      Mounted read-only if true, read-write
                                      otherwise (false or unspecified). Defaults to
                                      false.
                                    type: boolean
                                  subPath:
                                    description:
                                      Path within the volume from which
                                      the container's volume should be mounted. Defaults
                                      to "" (volume's root).
                                    type: string
                                  subPathExpr:
                                    description:
                                      Expanded path within the volume from
                                      which the container's volume should be mounted.
                                      Behaves similarly to SubPath but environment
                                      variable references $(VAR_NAME) are expanded
                                      using the container's environment. Defaults
                                      to "" (volume's root). SubPathExpr and SubPath
                                      are mutually exclusive. This field is beta in
                                      1.15.
                                    type: string
                                required:
                                  - mountPath
                                  - name
                                type: object
                              type: array
                            workingDir:
                              description:
                                Container's working directory. If not specified,
                                the container runtime's default will be used, which
                                might be configured in the container image. Cannot
                                be updated.
                              type: string
                          required:
                            - name
                          type: object
                      required:
                        - container
                      type: object
                    logger:
                      description: Activate request/response logging
                      properties:
                        mode:
                          description: What payloads to log
                          type: string
                        url:
                          description: URL to send request logging CloudEvents
                          type: string
                      type: object
                    maxReplicas:
                      description: This is the up bound for autoscaler to scale to
                      type: integer
                    minReplicas:
                      description:
                        Minimum number of replicas, pods won't scale down
                        to 0 in case of no traffic
                      type: integer
                    parallelism:
                      description:
                        Parallelism specifies how many requests can be
                        processed concurrently, this sets the target concurrency for
                        Autoscaling(KPA). For model servers that support tuning parallelism
                        will use this value, by default the parallelism is the number
                        of the CPU cores for most of the model servers.
                      type: integer
                    serviceAccountName:
                      description:
                        ServiceAccountName is the name of the ServiceAccount
                        to use to run the service
                      type: string
                  type: object
                predictor:
                  description: Predictor defines the model serving spec
                  properties:
                    custom:
                      description: Spec for a custom predictor
                      properties:
                        container:
                          description:
                            A single application container that you want
                            to run within a pod.
                          properties:
                            args:
                              description:
                                "Arguments to the entrypoint. The docker
                                image's CMD is used if this is not provided. Variable
                                references $(VAR_NAME) are expanded using the container's
                                environment. If a variable cannot be resolved, the
                                reference in the input string will be unchanged. The
                                $(VAR_NAME) syntax can be escaped with a double $$,
                                ie: $$(VAR_NAME). Escaped references will never be
                                expanded, regardless of whether the variable exists
                                or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            command:
                              description:
                                "Entrypoint array. Not executed within
                                a shell. The docker image's ENTRYPOINT is used if
                                this is not provided. Variable references $(VAR_NAME)
                                are expanded using the container's environment. If
                                a variable cannot be resolved, the reference in the
                                input string will be unchanged. The $(VAR_NAME) syntax
                                can be escaped with a double $$, ie: $$(VAR_NAME).
                                Escaped references will never be expanded, regardless
                                of whether the variable exists or not. Cannot be updated.
                                More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            env:
                              description:
                                List of environment variables to set in
                                the container. Cannot be updated.
                              items:
                                description:
                                  EnvVar represents an environment variable
                                  present in a Container.
                                properties:
                                  name:
                                    description:
                                      Name of the environment variable.
                                      Must be a C_IDENTIFIER.
                                    type: string
                                  value:
                                    description:
                                      'Variable references $(VAR_NAME)
                                      are expanded using the previous defined environment
                                      variables in the container and any service environment
                                      variables. If a variable cannot be resolved,
                                      the reference in the input string will be unchanged.
                                      The $(VAR_NAME) syntax can be escaped with a
                                      double $$, ie: $$(VAR_NAME). Escaped references
                                      will never be expanded, regardless of whether
                                      the variable exists or not. Defaults to "".'
                                    type: string
                                  valueFrom:
                                    description:
                                      Source for the environment variable's
                                      value. Cannot be used if value is not empty.
                                    properties:
                                      configMapKeyRef:
                                        description: Selects a key of a ConfigMap.
                                        properties:
                                          key:
                                            description: The key to select.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the ConfigMap
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                      fieldRef:
                                        description:
                                          "Selects a field of the pod:
                                          supports metadata.name, metadata.namespace,
                                          metadata.labels, metadata.annotations, spec.nodeName,
                                          spec.serviceAccountName, status.hostIP,
                                          status.podIP."
                                        properties:
                                          apiVersion:
                                            description:
                                              Version of the schema the
                                              FieldPath is written in terms of, defaults
                                              to "v1".
                                            type: string
                                          fieldPath:
                                            description:
                                              Path of the field to select
                                              in the specified API version.
                                            type: string
                                        required:
                                          - fieldPath
                                        type: object
                                      resourceFieldRef:
                                        description:
                                          "Selects a resource of the container:
                                          only resources limits and requests (limits.cpu,
                                          limits.memory, limits.ephemeral-storage,
                                          requests.cpu, requests.memory and requests.ephemeral-storage)
                                          are currently supported."
                                        properties:
                                          containerName:
                                            description:
                                              "Container name: required
                                              for volumes, optional for env vars"
                                            type: string
                                          divisor:
                                            description:
                                              Specifies the output format
                                              of the exposed resources, defaults to
                                              "1"
                                            type: string
                                          resource:
                                            description: "Required: resource to select"
                                            type: string
                                        required:
                                          - resource
                                        type: object
                                      secretKeyRef:
                                        description:
                                          Selects a key of a secret in
                                          the pod's namespace
                                        properties:
                                          key:
                                            description:
                                              The key of the secret to
                                              select from.  Must be a valid secret
                                              key.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the Secret
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                    type: object
                                required:
                                  - name
                                type: object
                              type: array
                            envFrom:
                              description:
                                List of sources to populate environment
                                variables in the container. The keys defined within
                                a source must be a C_IDENTIFIER. All invalid keys
                                will be reported as an event when the container is
                                starting. When a key exists in multiple sources, the
                                value associated with the last source will take precedence.
                                Values defined by an Env with a duplicate key will
                                take precedence. Cannot be updated.
                              items:
                                description:
                                  EnvFromSource represents the source of
                                  a set of ConfigMaps
                                properties:
                                  configMapRef:
                                    description: The ConfigMap to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the ConfigMap
                                          must be defined
                                        type: boolean
                                    type: object
                                  prefix:
                                    description:
                                      An optional identifier to prepend
                                      to each key in the ConfigMap. Must be a C_IDENTIFIER.
                                    type: string
                                  secretRef:
                                    description: The Secret to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the Secret must
                                          be defined
                                        type: boolean
                                    type: object
                                type: object
                              type: array
                            image:
                              description:
                                "Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images
                                This field is optional to allow higher level config
                                management to default or override container images
                                in workload controllers like Deployments and StatefulSets."
                              type: string
                            imagePullPolicy:
                              description:
                                "Image pull policy. One of Always, Never,
                                IfNotPresent. Defaults to Always if :v0.3.0 tag is
                                specified, or IfNotPresent otherwise. Cannot be updated.
                                More info: https://kubernetes.io/docs/concepts/containers/images#updating-images"
                              type: string
                            lifecycle:
                              description:
                                Actions that the management system should
                                take in response to container lifecycle events. Cannot
                                be updated.
                              properties:
                                postStart:
                                  description:
                                    "PostStart is called immediately after
                                    a container is created. If the handler fails,
                                    the container is terminated and restarted according
                                    to its restart policy. Other management of the
                                    container blocks until the hook completes. More
                                    info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                                preStop:
                                  description:
                                    "PreStop is called immediately before
                                    a container is terminated due to an API request
                                    or management event such as liveness probe failure,
                                    preemption, resource contention, etc. The handler
                                    is not called if the container crashes or exits.
                                    The reason for termination is passed to the handler.
                                    The Pod's termination grace period countdown
                                    begins before the PreStop hooked is executed.
                                    Regardless of the outcome of the handler, the
                                    container will eventually terminate within the
                                    Pod's termination grace period. Other management
                                    of the container blocks until the hook completes
                                    or until the termination grace period is reached.
                                    More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                              type: object
                            livenessProbe:
                              description:
                                "Periodic probe of container liveness.
                                Container will be restarted if the probe fails. Cannot
                                be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            name:
                              description:
                                Name of the container specified as a DNS_LABEL.
                                Each container in a pod must have a unique name (DNS_LABEL).
                                Cannot be updated.
                              type: string
                            ports:
                              description:
                                List of ports to expose from the container.
                                Exposing a port here gives the system additional information
                                about the network connections a container uses, but
                                is primarily informational. Not specifying a port
                                here DOES NOT prevent that port from being exposed.
                                Any port which is listening on the default "0.0.0.0"
                                address inside a container will be accessible from
                                the network. Cannot be updated.
                              items:
                                description:
                                  ContainerPort represents a network port
                                  in a single container.
                                properties:
                                  containerPort:
                                    description:
                                      Number of port to expose on the pod's
                                      IP address. This must be a valid port number,
                                      0 < x < 65536.
                                    format: int32
                                    type: integer
                                  hostIP:
                                    description:
                                      What host IP to bind the external
                                      port to.
                                    type: string
                                  hostPort:
                                    description:
                                      Number of port to expose on the host.
                                      If specified, this must be a valid port number,
                                      0 < x < 65536. If HostNetwork is specified,
                                      this must match ContainerPort. Most containers
                                      do not need this.
                                    format: int32
                                    type: integer
                                  name:
                                    description:
                                      If specified, this must be an IANA_SVC_NAME
                                      and unique within the pod. Each named port in
                                      a pod must have a unique name. Name for the
                                      port that can be referred to by services.
                                    type: string
                                  protocol:
                                    description:
                                      Protocol for port. Must be UDP, TCP,
                                      or SCTP. Defaults to "TCP".
                                    type: string
                                required:
                                  - containerPort
                                type: object
                              type: array
                            readinessProbe:
                              description:
                                "Periodic probe of container service readiness.
                                Container will be removed from service endpoints if
                                the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            resources:
                              description:
                                "Compute Resources required by this container.
                                Cannot be updated. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              properties:
                                limits:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Limits describes the maximum amount
                                    of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                                requests:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Requests describes the minimum amount
                                    of compute resources required. If Requests is
                                    omitted for a container, it defaults to Limits
                                    if that is explicitly specified, otherwise to
                                    an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                              type: object
                            securityContext:
                              description:
                                "Security options the pod should run with.
                                More info: https://kubernetes.io/docs/concepts/policy/security-context/
                                More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"
                              properties:
                                allowPrivilegeEscalation:
                                  description:
                                    "AllowPrivilegeEscalation controls
                                    whether a process can gain more privileges than
                                    its parent process. This bool directly controls
                                    if the no_new_privs flag will be set on the container
                                    process. AllowPrivilegeEscalation is true always
                                    when the container is: 1) run as Privileged 2)
                                    has CAP_SYS_ADMIN"
                                  type: boolean
                                capabilities:
                                  description:
                                    The capabilities to add/drop when running
                                    containers. Defaults to the default set of capabilities
                                    granted by the container runtime.
                                  properties:
                                    add:
                                      description: Added capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                    drop:
                                      description: Removed capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                  type: object
                                privileged:
                                  description:
                                    Run container in privileged mode. Processes
                                    in privileged containers are essentially equivalent
                                    to root on the host. Defaults to false.
                                  type: boolean
                                procMount:
                                  description:
                                    procMount denotes the type of proc
                                    mount to use for the containers. The default is
                                    DefaultProcMount which uses the container runtime
                                    defaults for readonly paths and masked paths.
                                    This requires the ProcMountType feature flag to
                                    be enabled.
                                  type: string
                                readOnlyRootFilesystem:
                                  description:
                                    Whether this container has a read-only
                                    root filesystem. Default is false.
                                  type: boolean
                                runAsGroup:
                                  description:
                                    The GID to run the entrypoint of the
                                    container process. Uses runtime default if unset.
                                    May also be set in PodSecurityContext.  If set
                                    in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                runAsNonRoot:
                                  description:
                                    Indicates that the container must run
                                    as a non-root user. If true, the Kubelet will
                                    validate the image at runtime to ensure that it
                                    does not run as UID 0 (root) and fail to start
                                    the container if it does. If unset or false, no
                                    such validation will be performed. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  type: boolean
                                runAsUser:
                                  description:
                                    The UID to run the entrypoint of the
                                    container process. Defaults to user specified
                                    in image metadata if unspecified. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                seLinuxOptions:
                                  description:
                                    The SELinux context to be applied to
                                    the container. If unspecified, the container runtime
                                    will allocate a random SELinux context for each
                                    container.  May also be set in PodSecurityContext.  If
                                    set in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  properties:
                                    level:
                                      description:
                                        Level is SELinux level label that
                                        applies to the container.
                                      type: string
                                    role:
                                      description:
                                        Role is a SELinux role label that
                                        applies to the container.
                                      type: string
                                    type:
                                      description:
                                        Type is a SELinux type label that
                                        applies to the container.
                                      type: string
                                    user:
                                      description:
                                        User is a SELinux user label that
                                        applies to the container.
                                      type: string
                                  type: object
                                windowsOptions:
                                  description: Windows security options.
                                  properties:
                                    gmsaCredentialSpec:
                                      description:
                                        GMSACredentialSpec is where the
                                        GMSA admission webhook (https://github.com/kubernetes-sigs/windows-gmsa)
                                        inlines the contents of the GMSA credential
                                        spec named by the GMSACredentialSpecName field.
                                        This field is alpha-level and is only honored
                                        by servers that enable the WindowsGMSA feature
                                        flag.
                                      type: string
                                    gmsaCredentialSpecName:
                                      description:
                                        GMSACredentialSpecName is the name
                                        of the GMSA credential spec to use. This field
                                        is alpha-level and is only honored by servers
                                        that enable the WindowsGMSA feature flag.
                                      type: string
                                  type: object
                              type: object
                            stdin:
                              description:
                                Whether this container should allocate
                                a buffer for stdin in the container runtime. If this
                                is not set, reads from stdin in the container will
                                always result in EOF. Default is false.
                              type: boolean
                            stdinOnce:
                              description:
                                Whether the container runtime should close
                                the stdin channel after it has been opened by a single
                                attach. When stdin is true the stdin stream will remain
                                open across multiple attach sessions. If stdinOnce
                                is set to true, stdin is opened on container start,
                                is empty until the first client attaches to stdin,
                                and then remains open and accepts data until the client
                                disconnects, at which time stdin is closed and remains
                                closed until the container is restarted. If this flag
                                is false, a container processes that reads from stdin
                                will never receive an EOF. Default is false
                              type: boolean
                            terminationMessagePath:
                              description:
                                "Optional: Path at which the file to which
                                the container's termination message will be written
                                is mounted into the container's filesystem. Message
                                written is intended to be brief final status, such
                                as an assertion failure message. Will be truncated
                                by the node if greater than 4096 bytes. The total
                                message length across all containers will be limited
                                to 12kb. Defaults to /dev/termination-log. Cannot
                                be updated."
                              type: string
                            terminationMessagePolicy:
                              description:
                                Indicate how the termination message should
                                be populated. File will use the contents of terminationMessagePath
                                to populate the container status message on both success
                                and failure. FallbackToLogsOnError will use the last
                                chunk of container log output if the termination message
                                file is empty and the container exited with an error.
                                The log output is limited to 2048 bytes or 80 lines,
                                whichever is smaller. Defaults to File. Cannot be
                                updated.
                              type: string
                            tty:
                              description:
                                Whether this container should allocate
                                a TTY for itself, also requires 'stdin' to be true.
                                Default is false.
                              type: boolean
                            volumeDevices:
                              description:
                                volumeDevices is the list of block devices
                                to be used by the container. This is a beta feature.
                              items:
                                description:
                                  volumeDevice describes a mapping of a
                                  raw block device within a container.
                                properties:
                                  devicePath:
                                    description:
                                      devicePath is the path inside of
                                      the container that the device will be mapped
                                      to.
                                    type: string
                                  name:
                                    description:
                                      name must match the name of a persistentVolumeClaim
                                      in the pod
                                    type: string
                                required:
                                  - devicePath
                                  - name
                                type: object
                              type: array
                            volumeMounts:
                              description:
                                Pod volumes to mount into the container's
                                filesystem. Cannot be updated.
                              items:
                                description:
                                  VolumeMount describes a mounting of a
                                  Volume within a container.
                                properties:
                                  mountPath:
                                    description:
                                      Path within the container at which
                                      the volume should be mounted.  Must not contain
                                      ':'.
                                    type: string
                                  mountPropagation:
                                    description:
                                      mountPropagation determines how mounts
                                      are propagated from the host to container and
                                      the other way around. When not set, MountPropagationNone
                                      is used. This field is beta in 1.10.
                                    type: string
                                  name:
                                    description: This must match the Name of a Volume.
                                    type: string
                                  readOnly:
                                    description:
                                      Mounted read-only if true, read-write
                                      otherwise (false or unspecified). Defaults to
                                      false.
                                    type: boolean
                                  subPath:
                                    description:
                                      Path within the volume from which
                                      the container's volume should be mounted. Defaults
                                      to "" (volume's root).
                                    type: string
                                  subPathExpr:
                                    description:
                                      Expanded path within the volume from
                                      which the container's volume should be mounted.
                                      Behaves similarly to SubPath but environment
                                      variable references $(VAR_NAME) are expanded
                                      using the container's environment. Defaults
                                      to "" (volume's root). SubPathExpr and SubPath
                                      are mutually exclusive. This field is beta in
                                      1.15.
                                    type: string
                                required:
                                  - mountPath
                                  - name
                                type: object
                              type: array
                            workingDir:
                              description:
                                Container's working directory. If not specified,
                                the container runtime's default will be used, which
                                might be configured in the container image. Cannot
                                be updated.
                              type: string
                          required:
                            - name
                          type: object
                      required:
                        - container
                      type: object
                    logger:
                      description: Activate request/response logging
                      properties:
                        mode:
                          description: What payloads to log
                          type: string
                        url:
                          description: URL to send request logging CloudEvents
                          type: string
                      type: object
                    maxReplicas:
                      description: This is the up bound for autoscaler to scale to
                      type: integer
                    minReplicas:
                      description:
                        Minimum number of replicas, pods won't scale down
                        to 0 in case of no traffic
                      type: integer
                    onnx:
                      description: Spec for ONNX runtime (https://github.com/microsoft/onnxruntime)
                      properties:
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    parallelism:
                      description:
                        Parallelism specifies how many requests can be
                        processed concurrently, this sets the target concurrency for
                        Autoscaling(KPA). For model servers that support tuning parallelism
                        will use this value, by default the parallelism is the number
                        of the CPU cores for most of the model servers.
                      type: integer
                    pytorch:
                      description: Spec for PyTorch predictor
                      properties:
                        modelClassName:
                          description: Defaults PyTorch model class name to 'PyTorchModel'
                          type: string
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    serviceAccountName:
                      description:
                        ServiceAccountName is the name of the ServiceAccount
                        to use to run the service
                      type: string
                    sklearn:
                      description: Spec for SKLearn predictor
                      properties:
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    tensorflow:
                      description: Spec for Tensorflow Serving (https://github.com/tensorflow/serving)
                      properties:
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map.
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    tensorrt:
                      description: Spec for TensorRT Inference Server (https://github.com/NVIDIA/triton-inference-server)
                      properties:
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    xgboost:
                      description: Spec for XGBoost predictor
                      properties:
                        nthread:
                          description: Number of thread to be used by XGBoost
                          type: integer
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                  type: object
                transformer:
                  description:
                    Transformer defines the pre/post processing before
                    and after the predictor call, transformer service calls to predictor
                    service.
                  properties:
                    custom:
                      description: Spec for a custom transformer
                      properties:
                        container:
                          description:
                            A single application container that you want
                            to run within a pod.
                          properties:
                            args:
                              description:
                                "Arguments to the entrypoint. The docker
                                image's CMD is used if this is not provided. Variable
                                references $(VAR_NAME) are expanded using the container's
                                environment. If a variable cannot be resolved, the
                                reference in the input string will be unchanged. The
                                $(VAR_NAME) syntax can be escaped with a double $$,
                                ie: $$(VAR_NAME). Escaped references will never be
                                expanded, regardless of whether the variable exists
                                or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            command:
                              description:
                                "Entrypoint array. Not executed within
                                a shell. The docker image's ENTRYPOINT is used if
                                this is not provided. Variable references $(VAR_NAME)
                                are expanded using the container's environment. If
                                a variable cannot be resolved, the reference in the
                                input string will be unchanged. The $(VAR_NAME) syntax
                                can be escaped with a double $$, ie: $$(VAR_NAME).
                                Escaped references will never be expanded, regardless
                                of whether the variable exists or not. Cannot be updated.
                                More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            env:
                              description:
                                List of environment variables to set in
                                the container. Cannot be updated.
                              items:
                                description:
                                  EnvVar represents an environment variable
                                  present in a Container.
                                properties:
                                  name:
                                    description:
                                      Name of the environment variable.
                                      Must be a C_IDENTIFIER.
                                    type: string
                                  value:
                                    description:
                                      'Variable references $(VAR_NAME)
                                      are expanded using the previous defined environment
                                      variables in the container and any service environment
                                      variables. If a variable cannot be resolved,
                                      the reference in the input string will be unchanged.
                                      The $(VAR_NAME) syntax can be escaped with a
                                      double $$, ie: $$(VAR_NAME). Escaped references
                                      will never be expanded, regardless of whether
                                      the variable exists or not. Defaults to "".'
                                    type: string
                                  valueFrom:
                                    description:
                                      Source for the environment variable's
                                      value. Cannot be used if value is not empty.
                                    properties:
                                      configMapKeyRef:
                                        description: Selects a key of a ConfigMap.
                                        properties:
                                          key:
                                            description: The key to select.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the ConfigMap
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                      fieldRef:
                                        description:
                                          "Selects a field of the pod:
                                          supports metadata.name, metadata.namespace,
                                          metadata.labels, metadata.annotations, spec.nodeName,
                                          spec.serviceAccountName, status.hostIP,
                                          status.podIP."
                                        properties:
                                          apiVersion:
                                            description:
                                              Version of the schema the
                                              FieldPath is written in terms of, defaults
                                              to "v1".
                                            type: string
                                          fieldPath:
                                            description:
                                              Path of the field to select
                                              in the specified API version.
                                            type: string
                                        required:
                                          - fieldPath
                                        type: object
                                      resourceFieldRef:
                                        description:
                                          "Selects a resource of the container:
                                          only resources limits and requests (limits.cpu,
                                          limits.memory, limits.ephemeral-storage,
                                          requests.cpu, requests.memory and requests.ephemeral-storage)
                                          are currently supported."
                                        properties:
                                          containerName:
                                            description:
                                              "Container name: required
                                              for volumes, optional for env vars"
                                            type: string
                                          divisor:
                                            description:
                                              Specifies the output format
                                              of the exposed resources, defaults to
                                              "1"
                                            type: string
                                          resource:
                                            description: "Required: resource to select"
                                            type: string
                                        required:
                                          - resource
                                        type: object
                                      secretKeyRef:
                                        description:
                                          Selects a key of a secret in
                                          the pod's namespace
                                        properties:
                                          key:
                                            description:
                                              The key of the secret to
                                              select from.  Must be a valid secret
                                              key.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the Secret
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                    type: object
                                required:
                                  - name
                                type: object
                              type: array
                            envFrom:
                              description:
                                List of sources to populate environment
                                variables in the container. The keys defined within
                                a source must be a C_IDENTIFIER. All invalid keys
                                will be reported as an event when the container is
                                starting. When a key exists in multiple sources, the
                                value associated with the last source will take precedence.
                                Values defined by an Env with a duplicate key will
                                take precedence. Cannot be updated.
                              items:
                                description:
                                  EnvFromSource represents the source of
                                  a set of ConfigMaps
                                properties:
                                  configMapRef:
                                    description: The ConfigMap to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the ConfigMap
                                          must be defined
                                        type: boolean
                                    type: object
                                  prefix:
                                    description:
                                      An optional identifier to prepend
                                      to each key in the ConfigMap. Must be a C_IDENTIFIER.
                                    type: string
                                  secretRef:
                                    description: The Secret to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the Secret must
                                          be defined
                                        type: boolean
                                    type: object
                                type: object
                              type: array
                            image:
                              description:
                                "Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images
                                This field is optional to allow higher level config
                                management to default or override container images
                                in workload controllers like Deployments and StatefulSets."
                              type: string
                            imagePullPolicy:
                              description:
                                "Image pull policy. One of Always, Never,
                                IfNotPresent. Defaults to Always if :v0.3.0 tag is
                                specified, or IfNotPresent otherwise. Cannot be updated.
                                More info: https://kubernetes.io/docs/concepts/containers/images#updating-images"
                              type: string
                            lifecycle:
                              description:
                                Actions that the management system should
                                take in response to container lifecycle events. Cannot
                                be updated.
                              properties:
                                postStart:
                                  description:
                                    "PostStart is called immediately after
                                    a container is created. If the handler fails,
                                    the container is terminated and restarted according
                                    to its restart policy. Other management of the
                                    container blocks until the hook completes. More
                                    info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                                preStop:
                                  description:
                                    "PreStop is called immediately before
                                    a container is terminated due to an API request
                                    or management event such as liveness probe failure,
                                    preemption, resource contention, etc. The handler
                                    is not called if the container crashes or exits.
                                    The reason for termination is passed to the handler.
                                    The Pod's termination grace period countdown
                                    begins before the PreStop hooked is executed.
                                    Regardless of the outcome of the handler, the
                                    container will eventually terminate within the
                                    Pod's termination grace period. Other management
                                    of the container blocks until the hook completes
                                    or until the termination grace period is reached.
                                    More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                              type: object
                            livenessProbe:
                              description:
                                "Periodic probe of container liveness.
                                Container will be restarted if the probe fails. Cannot
                                be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            name:
                              description:
                                Name of the container specified as a DNS_LABEL.
                                Each container in a pod must have a unique name (DNS_LABEL).
                                Cannot be updated.
                              type: string
                            ports:
                              description:
                                List of ports to expose from the container.
                                Exposing a port here gives the system additional information
                                about the network connections a container uses, but
                                is primarily informational. Not specifying a port
                                here DOES NOT prevent that port from being exposed.
                                Any port which is listening on the default "0.0.0.0"
                                address inside a container will be accessible from
                                the network. Cannot be updated.
                              items:
                                description:
                                  ContainerPort represents a network port
                                  in a single container.
                                properties:
                                  containerPort:
                                    description:
                                      Number of port to expose on the pod's
                                      IP address. This must be a valid port number,
                                      0 < x < 65536.
                                    format: int32
                                    type: integer
                                  hostIP:
                                    description:
                                      What host IP to bind the external
                                      port to.
                                    type: string
                                  hostPort:
                                    description:
                                      Number of port to expose on the host.
                                      If specified, this must be a valid port number,
                                      0 < x < 65536. If HostNetwork is specified,
                                      this must match ContainerPort. Most containers
                                      do not need this.
                                    format: int32
                                    type: integer
                                  name:
                                    description:
                                      If specified, this must be an IANA_SVC_NAME
                                      and unique within the pod. Each named port in
                                      a pod must have a unique name. Name for the
                                      port that can be referred to by services.
                                    type: string
                                  protocol:
                                    description:
                                      Protocol for port. Must be UDP, TCP,
                                      or SCTP. Defaults to "TCP".
                                    type: string
                                required:
                                  - containerPort
                                type: object
                              type: array
                            readinessProbe:
                              description:
                                "Periodic probe of container service readiness.
                                Container will be removed from service endpoints if
                                the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            resources:
                              description:
                                "Compute Resources required by this container.
                                Cannot be updated. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              properties:
                                limits:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Limits describes the maximum amount
                                    of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                                requests:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Requests describes the minimum amount
                                    of compute resources required. If Requests is
                                    omitted for a container, it defaults to Limits
                                    if that is explicitly specified, otherwise to
                                    an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                              type: object
                            securityContext:
                              description:
                                "Security options the pod should run with.
                                More info: https://kubernetes.io/docs/concepts/policy/security-context/
                                More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"
                              properties:
                                allowPrivilegeEscalation:
                                  description:
                                    "AllowPrivilegeEscalation controls
                                    whether a process can gain more privileges than
                                    its parent process. This bool directly controls
                                    if the no_new_privs flag will be set on the container
                                    process. AllowPrivilegeEscalation is true always
                                    when the container is: 1) run as Privileged 2)
                                    has CAP_SYS_ADMIN"
                                  type: boolean
                                capabilities:
                                  description:
                                    The capabilities to add/drop when running
                                    containers. Defaults to the default set of capabilities
                                    granted by the container runtime.
                                  properties:
                                    add:
                                      description: Added capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                    drop:
                                      description: Removed capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                  type: object
                                privileged:
                                  description:
                                    Run container in privileged mode. Processes
                                    in privileged containers are essentially equivalent
                                    to root on the host. Defaults to false.
                                  type: boolean
                                procMount:
                                  description:
                                    procMount denotes the type of proc
                                    mount to use for the containers. The default is
                                    DefaultProcMount which uses the container runtime
                                    defaults for readonly paths and masked paths.
                                    This requires the ProcMountType feature flag to
                                    be enabled.
                                  type: string
                                readOnlyRootFilesystem:
                                  description:
                                    Whether this container has a read-only
                                    root filesystem. Default is false.
                                  type: boolean
                                runAsGroup:
                                  description:
                                    The GID to run the entrypoint of the
                                    container process. Uses runtime default if unset.
                                    May also be set in PodSecurityContext.  If set
                                    in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                runAsNonRoot:
                                  description:
                                    Indicates that the container must run
                                    as a non-root user. If true, the Kubelet will
                                    validate the image at runtime to ensure that it
                                    does not run as UID 0 (root) and fail to start
                                    the container if it does. If unset or false, no
                                    such validation will be performed. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  type: boolean
                                runAsUser:
                                  description:
                                    The UID to run the entrypoint of the
                                    container process. Defaults to user specified
                                    in image metadata if unspecified. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                seLinuxOptions:
                                  description:
                                    The SELinux context to be applied to
                                    the container. If unspecified, the container runtime
                                    will allocate a random SELinux context for each
                                    container.  May also be set in PodSecurityContext.  If
                                    set in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  properties:
                                    level:
                                      description:
                                        Level is SELinux level label that
                                        applies to the container.
                                      type: string
                                    role:
                                      description:
                                        Role is a SELinux role label that
                                        applies to the container.
                                      type: string
                                    type:
                                      description:
                                        Type is a SELinux type label that
                                        applies to the container.
                                      type: string
                                    user:
                                      description:
                                        User is a SELinux user label that
                                        applies to the container.
                                      type: string
                                  type: object
                                windowsOptions:
                                  description: Windows security options.
                                  properties:
                                    gmsaCredentialSpec:
                                      description:
                                        GMSACredentialSpec is where the
                                        GMSA admission webhook (https://github.com/kubernetes-sigs/windows-gmsa)
                                        inlines the contents of the GMSA credential
                                        spec named by the GMSACredentialSpecName field.
                                        This field is alpha-level and is only honored
                                        by servers that enable the WindowsGMSA feature
                                        flag.
                                      type: string
                                    gmsaCredentialSpecName:
                                      description:
                                        GMSACredentialSpecName is the name
                                        of the GMSA credential spec to use. This field
                                        is alpha-level and is only honored by servers
                                        that enable the WindowsGMSA feature flag.
                                      type: string
                                  type: object
                              type: object
                            stdin:
                              description:
                                Whether this container should allocate
                                a buffer for stdin in the container runtime. If this
                                is not set, reads from stdin in the container will
                                always result in EOF. Default is false.
                              type: boolean
                            stdinOnce:
                              description:
                                Whether the container runtime should close
                                the stdin channel after it has been opened by a single
                                attach. When stdin is true the stdin stream will remain
                                open across multiple attach sessions. If stdinOnce
                                is set to true, stdin is opened on container start,
                                is empty until the first client attaches to stdin,
                                and then remains open and accepts data until the client
                                disconnects, at which time stdin is closed and remains
                                closed until the container is restarted. If this flag
                                is false, a container processes that reads from stdin
                                will never receive an EOF. Default is false
                              type: boolean
                            terminationMessagePath:
                              description:
                                "Optional: Path at which the file to which
                                the container's termination message will be written
                                is mounted into the container's filesystem. Message
                                written is intended to be brief final status, such
                                as an assertion failure message. Will be truncated
                                by the node if greater than 4096 bytes. The total
                                message length across all containers will be limited
                                to 12kb. Defaults to /dev/termination-log. Cannot
                                be updated."
                              type: string
                            terminationMessagePolicy:
                              description:
                                Indicate how the termination message should
                                be populated. File will use the contents of terminationMessagePath
                                to populate the container status message on both success
                                and failure. FallbackToLogsOnError will use the last
                                chunk of container log output if the termination message
                                file is empty and the container exited with an error.
                                The log output is limited to 2048 bytes or 80 lines,
                                whichever is smaller. Defaults to File. Cannot be
                                updated.
                              type: string
                            tty:
                              description:
                                Whether this container should allocate
                                a TTY for itself, also requires 'stdin' to be true.
                                Default is false.
                              type: boolean
                            volumeDevices:
                              description:
                                volumeDevices is the list of block devices
                                to be used by the container. This is a beta feature.
                              items:
                                description:
                                  volumeDevice describes a mapping of a
                                  raw block device within a container.
                                properties:
                                  devicePath:
                                    description:
                                      devicePath is the path inside of
                                      the container that the device will be mapped
                                      to.
                                    type: string
                                  name:
                                    description:
                                      name must match the name of a persistentVolumeClaim
                                      in the pod
                                    type: string
                                required:
                                  - devicePath
                                  - name
                                type: object
                              type: array
                            volumeMounts:
                              description:
                                Pod volumes to mount into the container's
                                filesystem. Cannot be updated.
                              items:
                                description:
                                  VolumeMount describes a mounting of a
                                  Volume within a container.
                                properties:
                                  mountPath:
                                    description:
                                      Path within the container at which
                                      the volume should be mounted.  Must not contain
                                      ':'.
                                    type: string
                                  mountPropagation:
                                    description:
                                      mountPropagation determines how mounts
                                      are propagated from the host to container and
                                      the other way around. When not set, MountPropagationNone
                                      is used. This field is beta in 1.10.
                                    type: string
                                  name:
                                    description: This must match the Name of a Volume.
                                    type: string
                                  readOnly:
                                    description:
                                      Mounted read-only if true, read-write
                                      otherwise (false or unspecified). Defaults to
                                      false.
                                    type: boolean
                                  subPath:
                                    description:
                                      Path within the volume from which
                                      the container's volume should be mounted. Defaults
                                      to "" (volume's root).
                                    type: string
                                  subPathExpr:
                                    description:
                                      Expanded path within the volume from
                                      which the container's volume should be mounted.
                                      Behaves similarly to SubPath but environment
                                      variable references $(VAR_NAME) are expanded
                                      using the container's environment. Defaults
                                      to "" (volume's root). SubPathExpr and SubPath
                                      are mutually exclusive. This field is beta in
                                      1.15.
                                    type: string
                                required:
                                  - mountPath
                                  - name
                                type: object
                              type: array
                            workingDir:
                              description:
                                Container's working directory. If not specified,
                                the container runtime's default will be used, which
                                might be configured in the container image. Cannot
                                be updated.
                              type: string
                          required:
                            - name
                          type: object
                      required:
                        - container
                      type: object
                    logger:
                      description: Activate request/response logging
                      properties:
                        mode:
                          description: What payloads to log
                          type: string
                        url:
                          description: URL to send request logging CloudEvents
                          type: string
                      type: object
                    maxReplicas:
                      description: This is the up bound for autoscaler to scale to
                      type: integer
                    minReplicas:
                      description:
                        Minimum number of replicas, pods won't scale down
                        to 0 in case of no traffic
                      type: integer
                    parallelism:
                      description:
                        Parallelism specifies how many requests can be
                        processed concurrently, this sets the target concurrency for
                        Autoscaling(KPA). For model servers that support tuning parallelism
                        will use this value, by default the parallelism is the number
                        of the CPU cores for most of the model servers.
                      type: integer
                    serviceAccountName:
                      description:
                        ServiceAccountName is the name of the ServiceAccount
                        to use to run the service
                      type: string
                  type: object
              required:
                - predictor
              type: object
            canaryTrafficPercent:
              description:
                CanaryTrafficPercent defines the percentage of traffic
                going to canary InferenceService endpoints
              type: integer
            default:
              description: Default defines default InferenceService endpoints
              properties:
                explainer:
                  description:
                    Explainer defines the model explanation service spec,
                    explainer service calls to predictor or transformer if it is specified.
                  properties:
                    alibi:
                      description: Spec for alibi explainer
                      properties:
                        config:
                          additionalProperties:
                            type: string
                          description: Inline custom parameter settings for explainer
                          type: object
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description: Defaults to latest Alibi Version
                          type: string
                        storageUri:
                          description: The location of a trained explanation model
                          type: string
                        type:
                          description: The type of Alibi explainer
                          type: string
                      required:
                        - type
                      type: object
                    custom:
                      description: Spec for a custom explainer
                      properties:
                        container:
                          description:
                            A single application container that you want
                            to run within a pod.
                          properties:
                            args:
                              description:
                                "Arguments to the entrypoint. The docker
                                image's CMD is used if this is not provided. Variable
                                references $(VAR_NAME) are expanded using the container's
                                environment. If a variable cannot be resolved, the
                                reference in the input string will be unchanged. The
                                $(VAR_NAME) syntax can be escaped with a double $$,
                                ie: $$(VAR_NAME). Escaped references will never be
                                expanded, regardless of whether the variable exists
                                or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            command:
                              description:
                                "Entrypoint array. Not executed within
                                a shell. The docker image's ENTRYPOINT is used if
                                this is not provided. Variable references $(VAR_NAME)
                                are expanded using the container's environment. If
                                a variable cannot be resolved, the reference in the
                                input string will be unchanged. The $(VAR_NAME) syntax
                                can be escaped with a double $$, ie: $$(VAR_NAME).
                                Escaped references will never be expanded, regardless
                                of whether the variable exists or not. Cannot be updated.
                                More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            env:
                              description:
                                List of environment variables to set in
                                the container. Cannot be updated.
                              items:
                                description:
                                  EnvVar represents an environment variable
                                  present in a Container.
                                properties:
                                  name:
                                    description:
                                      Name of the environment variable.
                                      Must be a C_IDENTIFIER.
                                    type: string
                                  value:
                                    description:
                                      'Variable references $(VAR_NAME)
                                      are expanded using the previous defined environment
                                      variables in the container and any service environment
                                      variables. If a variable cannot be resolved,
                                      the reference in the input string will be unchanged.
                                      The $(VAR_NAME) syntax can be escaped with a
                                      double $$, ie: $$(VAR_NAME). Escaped references
                                      will never be expanded, regardless of whether
                                      the variable exists or not. Defaults to "".'
                                    type: string
                                  valueFrom:
                                    description:
                                      Source for the environment variable's
                                      value. Cannot be used if value is not empty.
                                    properties:
                                      configMapKeyRef:
                                        description: Selects a key of a ConfigMap.
                                        properties:
                                          key:
                                            description: The key to select.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the ConfigMap
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                      fieldRef:
                                        description:
                                          "Selects a field of the pod:
                                          supports metadata.name, metadata.namespace,
                                          metadata.labels, metadata.annotations, spec.nodeName,
                                          spec.serviceAccountName, status.hostIP,
                                          status.podIP."
                                        properties:
                                          apiVersion:
                                            description:
                                              Version of the schema the
                                              FieldPath is written in terms of, defaults
                                              to "v1".
                                            type: string
                                          fieldPath:
                                            description:
                                              Path of the field to select
                                              in the specified API version.
                                            type: string
                                        required:
                                          - fieldPath
                                        type: object
                                      resourceFieldRef:
                                        description:
                                          "Selects a resource of the container:
                                          only resources limits and requests (limits.cpu,
                                          limits.memory, limits.ephemeral-storage,
                                          requests.cpu, requests.memory and requests.ephemeral-storage)
                                          are currently supported."
                                        properties:
                                          containerName:
                                            description:
                                              "Container name: required
                                              for volumes, optional for env vars"
                                            type: string
                                          divisor:
                                            description:
                                              Specifies the output format
                                              of the exposed resources, defaults to
                                              "1"
                                            type: string
                                          resource:
                                            description: "Required: resource to select"
                                            type: string
                                        required:
                                          - resource
                                        type: object
                                      secretKeyRef:
                                        description:
                                          Selects a key of a secret in
                                          the pod's namespace
                                        properties:
                                          key:
                                            description:
                                              The key of the secret to
                                              select from.  Must be a valid secret
                                              key.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the Secret
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                    type: object
                                required:
                                  - name
                                type: object
                              type: array
                            envFrom:
                              description:
                                List of sources to populate environment
                                variables in the container. The keys defined within
                                a source must be a C_IDENTIFIER. All invalid keys
                                will be reported as an event when the container is
                                starting. When a key exists in multiple sources, the
                                value associated with the last source will take precedence.
                                Values defined by an Env with a duplicate key will
                                take precedence. Cannot be updated.
                              items:
                                description:
                                  EnvFromSource represents the source of
                                  a set of ConfigMaps
                                properties:
                                  configMapRef:
                                    description: The ConfigMap to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the ConfigMap
                                          must be defined
                                        type: boolean
                                    type: object
                                  prefix:
                                    description:
                                      An optional identifier to prepend
                                      to each key in the ConfigMap. Must be a C_IDENTIFIER.
                                    type: string
                                  secretRef:
                                    description: The Secret to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the Secret must
                                          be defined
                                        type: boolean
                                    type: object
                                type: object
                              type: array
                            image:
                              description:
                                "Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images
                                This field is optional to allow higher level config
                                management to default or override container images
                                in workload controllers like Deployments and StatefulSets."
                              type: string
                            imagePullPolicy:
                              description:
                                "Image pull policy. One of Always, Never,
                                IfNotPresent. Defaults to Always if :v0.3.0 tag is
                                specified, or IfNotPresent otherwise. Cannot be updated.
                                More info: https://kubernetes.io/docs/concepts/containers/images#updating-images"
                              type: string
                            lifecycle:
                              description:
                                Actions that the management system should
                                take in response to container lifecycle events. Cannot
                                be updated.
                              properties:
                                postStart:
                                  description:
                                    "PostStart is called immediately after
                                    a container is created. If the handler fails,
                                    the container is terminated and restarted according
                                    to its restart policy. Other management of the
                                    container blocks until the hook completes. More
                                    info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                                preStop:
                                  description:
                                    "PreStop is called immediately before
                                    a container is terminated due to an API request
                                    or management event such as liveness probe failure,
                                    preemption, resource contention, etc. The handler
                                    is not called if the container crashes or exits.
                                    The reason for termination is passed to the handler.
                                    The Pod's termination grace period countdown
                                    begins before the PreStop hooked is executed.
                                    Regardless of the outcome of the handler, the
                                    container will eventually terminate within the
                                    Pod's termination grace period. Other management
                                    of the container blocks until the hook completes
                                    or until the termination grace period is reached.
                                    More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                              type: object
                            livenessProbe:
                              description:
                                "Periodic probe of container liveness.
                                Container will be restarted if the probe fails. Cannot
                                be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            name:
                              description:
                                Name of the container specified as a DNS_LABEL.
                                Each container in a pod must have a unique name (DNS_LABEL).
                                Cannot be updated.
                              type: string
                            ports:
                              description:
                                List of ports to expose from the container.
                                Exposing a port here gives the system additional information
                                about the network connections a container uses, but
                                is primarily informational. Not specifying a port
                                here DOES NOT prevent that port from being exposed.
                                Any port which is listening on the default "0.0.0.0"
                                address inside a container will be accessible from
                                the network. Cannot be updated.
                              items:
                                description:
                                  ContainerPort represents a network port
                                  in a single container.
                                properties:
                                  containerPort:
                                    description:
                                      Number of port to expose on the pod's
                                      IP address. This must be a valid port number,
                                      0 < x < 65536.
                                    format: int32
                                    type: integer
                                  hostIP:
                                    description:
                                      What host IP to bind the external
                                      port to.
                                    type: string
                                  hostPort:
                                    description:
                                      Number of port to expose on the host.
                                      If specified, this must be a valid port number,
                                      0 < x < 65536. If HostNetwork is specified,
                                      this must match ContainerPort. Most containers
                                      do not need this.
                                    format: int32
                                    type: integer
                                  name:
                                    description:
                                      If specified, this must be an IANA_SVC_NAME
                                      and unique within the pod. Each named port in
                                      a pod must have a unique name. Name for the
                                      port that can be referred to by services.
                                    type: string
                                  protocol:
                                    description:
                                      Protocol for port. Must be UDP, TCP,
                                      or SCTP. Defaults to "TCP".
                                    type: string
                                required:
                                  - containerPort
                                type: object
                              type: array
                            readinessProbe:
                              description:
                                "Periodic probe of container service readiness.
                                Container will be removed from service endpoints if
                                the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            resources:
                              description:
                                "Compute Resources required by this container.
                                Cannot be updated. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              properties:
                                limits:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Limits describes the maximum amount
                                    of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                                requests:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Requests describes the minimum amount
                                    of compute resources required. If Requests is
                                    omitted for a container, it defaults to Limits
                                    if that is explicitly specified, otherwise to
                                    an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                              type: object
                            securityContext:
                              description:
                                "Security options the pod should run with.
                                More info: https://kubernetes.io/docs/concepts/policy/security-context/
                                More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"
                              properties:
                                allowPrivilegeEscalation:
                                  description:
                                    "AllowPrivilegeEscalation controls
                                    whether a process can gain more privileges than
                                    its parent process. This bool directly controls
                                    if the no_new_privs flag will be set on the container
                                    process. AllowPrivilegeEscalation is true always
                                    when the container is: 1) run as Privileged 2)
                                    has CAP_SYS_ADMIN"
                                  type: boolean
                                capabilities:
                                  description:
                                    The capabilities to add/drop when running
                                    containers. Defaults to the default set of capabilities
                                    granted by the container runtime.
                                  properties:
                                    add:
                                      description: Added capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                    drop:
                                      description: Removed capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                  type: object
                                privileged:
                                  description:
                                    Run container in privileged mode. Processes
                                    in privileged containers are essentially equivalent
                                    to root on the host. Defaults to false.
                                  type: boolean
                                procMount:
                                  description:
                                    procMount denotes the type of proc
                                    mount to use for the containers. The default is
                                    DefaultProcMount which uses the container runtime
                                    defaults for readonly paths and masked paths.
                                    This requires the ProcMountType feature flag to
                                    be enabled.
                                  type: string
                                readOnlyRootFilesystem:
                                  description:
                                    Whether this container has a read-only
                                    root filesystem. Default is false.
                                  type: boolean
                                runAsGroup:
                                  description:
                                    The GID to run the entrypoint of the
                                    container process. Uses runtime default if unset.
                                    May also be set in PodSecurityContext.  If set
                                    in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                runAsNonRoot:
                                  description:
                                    Indicates that the container must run
                                    as a non-root user. If true, the Kubelet will
                                    validate the image at runtime to ensure that it
                                    does not run as UID 0 (root) and fail to start
                                    the container if it does. If unset or false, no
                                    such validation will be performed. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  type: boolean
                                runAsUser:
                                  description:
                                    The UID to run the entrypoint of the
                                    container process. Defaults to user specified
                                    in image metadata if unspecified. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                seLinuxOptions:
                                  description:
                                    The SELinux context to be applied to
                                    the container. If unspecified, the container runtime
                                    will allocate a random SELinux context for each
                                    container.  May also be set in PodSecurityContext.  If
                                    set in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  properties:
                                    level:
                                      description:
                                        Level is SELinux level label that
                                        applies to the container.
                                      type: string
                                    role:
                                      description:
                                        Role is a SELinux role label that
                                        applies to the container.
                                      type: string
                                    type:
                                      description:
                                        Type is a SELinux type label that
                                        applies to the container.
                                      type: string
                                    user:
                                      description:
                                        User is a SELinux user label that
                                        applies to the container.
                                      type: string
                                  type: object
                                windowsOptions:
                                  description: Windows security options.
                                  properties:
                                    gmsaCredentialSpec:
                                      description:
                                        GMSACredentialSpec is where the
                                        GMSA admission webhook (https://github.com/kubernetes-sigs/windows-gmsa)
                                        inlines the contents of the GMSA credential
                                        spec named by the GMSACredentialSpecName field.
                                        This field is alpha-level and is only honored
                                        by servers that enable the WindowsGMSA feature
                                        flag.
                                      type: string
                                    gmsaCredentialSpecName:
                                      description:
                                        GMSACredentialSpecName is the name
                                        of the GMSA credential spec to use. This field
                                        is alpha-level and is only honored by servers
                                        that enable the WindowsGMSA feature flag.
                                      type: string
                                  type: object
                              type: object
                            stdin:
                              description:
                                Whether this container should allocate
                                a buffer for stdin in the container runtime. If this
                                is not set, reads from stdin in the container will
                                always result in EOF. Default is false.
                              type: boolean
                            stdinOnce:
                              description:
                                Whether the container runtime should close
                                the stdin channel after it has been opened by a single
                                attach. When stdin is true the stdin stream will remain
                                open across multiple attach sessions. If stdinOnce
                                is set to true, stdin is opened on container start,
                                is empty until the first client attaches to stdin,
                                and then remains open and accepts data until the client
                                disconnects, at which time stdin is closed and remains
                                closed until the container is restarted. If this flag
                                is false, a container processes that reads from stdin
                                will never receive an EOF. Default is false
                              type: boolean
                            terminationMessagePath:
                              description:
                                "Optional: Path at which the file to which
                                the container's termination message will be written
                                is mounted into the container's filesystem. Message
                                written is intended to be brief final status, such
                                as an assertion failure message. Will be truncated
                                by the node if greater than 4096 bytes. The total
                                message length across all containers will be limited
                                to 12kb. Defaults to /dev/termination-log. Cannot
                                be updated."
                              type: string
                            terminationMessagePolicy:
                              description:
                                Indicate how the termination message should
                                be populated. File will use the contents of terminationMessagePath
                                to populate the container status message on both success
                                and failure. FallbackToLogsOnError will use the last
                                chunk of container log output if the termination message
                                file is empty and the container exited with an error.
                                The log output is limited to 2048 bytes or 80 lines,
                                whichever is smaller. Defaults to File. Cannot be
                                updated.
                              type: string
                            tty:
                              description:
                                Whether this container should allocate
                                a TTY for itself, also requires 'stdin' to be true.
                                Default is false.
                              type: boolean
                            volumeDevices:
                              description:
                                volumeDevices is the list of block devices
                                to be used by the container. This is a beta feature.
                              items:
                                description:
                                  volumeDevice describes a mapping of a
                                  raw block device within a container.
                                properties:
                                  devicePath:
                                    description:
                                      devicePath is the path inside of
                                      the container that the device will be mapped
                                      to.
                                    type: string
                                  name:
                                    description:
                                      name must match the name of a persistentVolumeClaim
                                      in the pod
                                    type: string
                                required:
                                  - devicePath
                                  - name
                                type: object
                              type: array
                            volumeMounts:
                              description:
                                Pod volumes to mount into the container's
                                filesystem. Cannot be updated.
                              items:
                                description:
                                  VolumeMount describes a mounting of a
                                  Volume within a container.
                                properties:
                                  mountPath:
                                    description:
                                      Path within the container at which
                                      the volume should be mounted.  Must not contain
                                      ':'.
                                    type: string
                                  mountPropagation:
                                    description:
                                      mountPropagation determines how mounts
                                      are propagated from the host to container and
                                      the other way around. When not set, MountPropagationNone
                                      is used. This field is beta in 1.10.
                                    type: string
                                  name:
                                    description: This must match the Name of a Volume.
                                    type: string
                                  readOnly:
                                    description:
                                      Mounted read-only if true, read-write
                                      otherwise (false or unspecified). Defaults to
                                      false.
                                    type: boolean
                                  subPath:
                                    description:
                                      Path within the volume from which
                                      the container's volume should be mounted. Defaults
                                      to "" (volume's root).
                                    type: string
                                  subPathExpr:
                                    description:
                                      Expanded path within the volume from
                                      which the container's volume should be mounted.
                                      Behaves similarly to SubPath but environment
                                      variable references $(VAR_NAME) are expanded
                                      using the container's environment. Defaults
                                      to "" (volume's root). SubPathExpr and SubPath
                                      are mutually exclusive. This field is beta in
                                      1.15.
                                    type: string
                                required:
                                  - mountPath
                                  - name
                                type: object
                              type: array
                            workingDir:
                              description:
                                Container's working directory. If not specified,
                                the container runtime's default will be used, which
                                might be configured in the container image. Cannot
                                be updated.
                              type: string
                          required:
                            - name
                          type: object
                      required:
                        - container
                      type: object
                    logger:
                      description: Activate request/response logging
                      properties:
                        mode:
                          description: What payloads to log
                          type: string
                        url:
                          description: URL to send request logging CloudEvents
                          type: string
                      type: object
                    maxReplicas:
                      description: This is the up bound for autoscaler to scale to
                      type: integer
                    minReplicas:
                      description:
                        Minimum number of replicas, pods won't scale down
                        to 0 in case of no traffic
                      type: integer
                    parallelism:
                      description:
                        Parallelism specifies how many requests can be
                        processed concurrently, this sets the target concurrency for
                        Autoscaling(KPA). For model servers that support tuning parallelism
                        will use this value, by default the parallelism is the number
                        of the CPU cores for most of the model servers.
                      type: integer
                    serviceAccountName:
                      description:
                        ServiceAccountName is the name of the ServiceAccount
                        to use to run the service
                      type: string
                  type: object
                predictor:
                  description: Predictor defines the model serving spec
                  properties:
                    custom:
                      description: Spec for a custom predictor
                      properties:
                        container:
                          description:
                            A single application container that you want
                            to run within a pod.
                          properties:
                            args:
                              description:
                                "Arguments to the entrypoint. The docker
                                image's CMD is used if this is not provided. Variable
                                references $(VAR_NAME) are expanded using the container's
                                environment. If a variable cannot be resolved, the
                                reference in the input string will be unchanged. The
                                $(VAR_NAME) syntax can be escaped with a double $$,
                                ie: $$(VAR_NAME). Escaped references will never be
                                expanded, regardless of whether the variable exists
                                or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            command:
                              description:
                                "Entrypoint array. Not executed within
                                a shell. The docker image's ENTRYPOINT is used if
                                this is not provided. Variable references $(VAR_NAME)
                                are expanded using the container's environment. If
                                a variable cannot be resolved, the reference in the
                                input string will be unchanged. The $(VAR_NAME) syntax
                                can be escaped with a double $$, ie: $$(VAR_NAME).
                                Escaped references will never be expanded, regardless
                                of whether the variable exists or not. Cannot be updated.
                                More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            env:
                              description:
                                List of environment variables to set in
                                the container. Cannot be updated.
                              items:
                                description:
                                  EnvVar represents an environment variable
                                  present in a Container.
                                properties:
                                  name:
                                    description:
                                      Name of the environment variable.
                                      Must be a C_IDENTIFIER.
                                    type: string
                                  value:
                                    description:
                                      'Variable references $(VAR_NAME)
                                      are expanded using the previous defined environment
                                      variables in the container and any service environment
                                      variables. If a variable cannot be resolved,
                                      the reference in the input string will be unchanged.
                                      The $(VAR_NAME) syntax can be escaped with a
                                      double $$, ie: $$(VAR_NAME). Escaped references
                                      will never be expanded, regardless of whether
                                      the variable exists or not. Defaults to "".'
                                    type: string
                                  valueFrom:
                                    description:
                                      Source for the environment variable's
                                      value. Cannot be used if value is not empty.
                                    properties:
                                      configMapKeyRef:
                                        description: Selects a key of a ConfigMap.
                                        properties:
                                          key:
                                            description: The key to select.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the ConfigMap
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                      fieldRef:
                                        description:
                                          "Selects a field of the pod:
                                          supports metadata.name, metadata.namespace,
                                          metadata.labels, metadata.annotations, spec.nodeName,
                                          spec.serviceAccountName, status.hostIP,
                                          status.podIP."
                                        properties:
                                          apiVersion:
                                            description:
                                              Version of the schema the
                                              FieldPath is written in terms of, defaults
                                              to "v1".
                                            type: string
                                          fieldPath:
                                            description:
                                              Path of the field to select
                                              in the specified API version.
                                            type: string
                                        required:
                                          - fieldPath
                                        type: object
                                      resourceFieldRef:
                                        description:
                                          "Selects a resource of the container:
                                          only resources limits and requests (limits.cpu,
                                          limits.memory, limits.ephemeral-storage,
                                          requests.cpu, requests.memory and requests.ephemeral-storage)
                                          are currently supported."
                                        properties:
                                          containerName:
                                            description:
                                              "Container name: required
                                              for volumes, optional for env vars"
                                            type: string
                                          divisor:
                                            description:
                                              Specifies the output format
                                              of the exposed resources, defaults to
                                              "1"
                                            type: string
                                          resource:
                                            description: "Required: resource to select"
                                            type: string
                                        required:
                                          - resource
                                        type: object
                                      secretKeyRef:
                                        description:
                                          Selects a key of a secret in
                                          the pod's namespace
                                        properties:
                                          key:
                                            description:
                                              The key of the secret to
                                              select from.  Must be a valid secret
                                              key.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the Secret
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                    type: object
                                required:
                                  - name
                                type: object
                              type: array
                            envFrom:
                              description:
                                List of sources to populate environment
                                variables in the container. The keys defined within
                                a source must be a C_IDENTIFIER. All invalid keys
                                will be reported as an event when the container is
                                starting. When a key exists in multiple sources, the
                                value associated with the last source will take precedence.
                                Values defined by an Env with a duplicate key will
                                take precedence. Cannot be updated.
                              items:
                                description:
                                  EnvFromSource represents the source of
                                  a set of ConfigMaps
                                properties:
                                  configMapRef:
                                    description: The ConfigMap to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the ConfigMap
                                          must be defined
                                        type: boolean
                                    type: object
                                  prefix:
                                    description:
                                      An optional identifier to prepend
                                      to each key in the ConfigMap. Must be a C_IDENTIFIER.
                                    type: string
                                  secretRef:
                                    description: The Secret to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the Secret must
                                          be defined
                                        type: boolean
                                    type: object
                                type: object
                              type: array
                            image:
                              description:
                                "Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images
                                This field is optional to allow higher level config
                                management to default or override container images
                                in workload controllers like Deployments and StatefulSets."
                              type: string
                            imagePullPolicy:
                              description:
                                "Image pull policy. One of Always, Never,
                                IfNotPresent. Defaults to Always if :v0.3.0 tag is
                                specified, or IfNotPresent otherwise. Cannot be updated.
                                More info: https://kubernetes.io/docs/concepts/containers/images#updating-images"
                              type: string
                            lifecycle:
                              description:
                                Actions that the management system should
                                take in response to container lifecycle events. Cannot
                                be updated.
                              properties:
                                postStart:
                                  description:
                                    "PostStart is called immediately after
                                    a container is created. If the handler fails,
                                    the container is terminated and restarted according
                                    to its restart policy. Other management of the
                                    container blocks until the hook completes. More
                                    info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                                preStop:
                                  description:
                                    "PreStop is called immediately before
                                    a container is terminated due to an API request
                                    or management event such as liveness probe failure,
                                    preemption, resource contention, etc. The handler
                                    is not called if the container crashes or exits.
                                    The reason for termination is passed to the handler.
                                    The Pod's termination grace period countdown
                                    begins before the PreStop hooked is executed.
                                    Regardless of the outcome of the handler, the
                                    container will eventually terminate within the
                                    Pod's termination grace period. Other management
                                    of the container blocks until the hook completes
                                    or until the termination grace period is reached.
                                    More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                              type: object
                            livenessProbe:
                              description:
                                "Periodic probe of container liveness.
                                Container will be restarted if the probe fails. Cannot
                                be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            name:
                              description:
                                Name of the container specified as a DNS_LABEL.
                                Each container in a pod must have a unique name (DNS_LABEL).
                                Cannot be updated.
                              type: string
                            ports:
                              description:
                                List of ports to expose from the container.
                                Exposing a port here gives the system additional information
                                about the network connections a container uses, but
                                is primarily informational. Not specifying a port
                                here DOES NOT prevent that port from being exposed.
                                Any port which is listening on the default "0.0.0.0"
                                address inside a container will be accessible from
                                the network. Cannot be updated.
                              items:
                                description:
                                  ContainerPort represents a network port
                                  in a single container.
                                properties:
                                  containerPort:
                                    description:
                                      Number of port to expose on the pod's
                                      IP address. This must be a valid port number,
                                      0 < x < 65536.
                                    format: int32
                                    type: integer
                                  hostIP:
                                    description:
                                      What host IP to bind the external
                                      port to.
                                    type: string
                                  hostPort:
                                    description:
                                      Number of port to expose on the host.
                                      If specified, this must be a valid port number,
                                      0 < x < 65536. If HostNetwork is specified,
                                      this must match ContainerPort. Most containers
                                      do not need this.
                                    format: int32
                                    type: integer
                                  name:
                                    description:
                                      If specified, this must be an IANA_SVC_NAME
                                      and unique within the pod. Each named port in
                                      a pod must have a unique name. Name for the
                                      port that can be referred to by services.
                                    type: string
                                  protocol:
                                    description:
                                      Protocol for port. Must be UDP, TCP,
                                      or SCTP. Defaults to "TCP".
                                    type: string
                                required:
                                  - containerPort
                                type: object
                              type: array
                            readinessProbe:
                              description:
                                "Periodic probe of container service readiness.
                                Container will be removed from service endpoints if
                                the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            resources:
                              description:
                                "Compute Resources required by this container.
                                Cannot be updated. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              properties:
                                limits:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Limits describes the maximum amount
                                    of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                                requests:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Requests describes the minimum amount
                                    of compute resources required. If Requests is
                                    omitted for a container, it defaults to Limits
                                    if that is explicitly specified, otherwise to
                                    an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                              type: object
                            securityContext:
                              description:
                                "Security options the pod should run with.
                                More info: https://kubernetes.io/docs/concepts/policy/security-context/
                                More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"
                              properties:
                                allowPrivilegeEscalation:
                                  description:
                                    "AllowPrivilegeEscalation controls
                                    whether a process can gain more privileges than
                                    its parent process. This bool directly controls
                                    if the no_new_privs flag will be set on the container
                                    process. AllowPrivilegeEscalation is true always
                                    when the container is: 1) run as Privileged 2)
                                    has CAP_SYS_ADMIN"
                                  type: boolean
                                capabilities:
                                  description:
                                    The capabilities to add/drop when running
                                    containers. Defaults to the default set of capabilities
                                    granted by the container runtime.
                                  properties:
                                    add:
                                      description: Added capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                    drop:
                                      description: Removed capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                  type: object
                                privileged:
                                  description:
                                    Run container in privileged mode. Processes
                                    in privileged containers are essentially equivalent
                                    to root on the host. Defaults to false.
                                  type: boolean
                                procMount:
                                  description:
                                    procMount denotes the type of proc
                                    mount to use for the containers. The default is
                                    DefaultProcMount which uses the container runtime
                                    defaults for readonly paths and masked paths.
                                    This requires the ProcMountType feature flag to
                                    be enabled.
                                  type: string
                                readOnlyRootFilesystem:
                                  description:
                                    Whether this container has a read-only
                                    root filesystem. Default is false.
                                  type: boolean
                                runAsGroup:
                                  description:
                                    The GID to run the entrypoint of the
                                    container process. Uses runtime default if unset.
                                    May also be set in PodSecurityContext.  If set
                                    in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                runAsNonRoot:
                                  description:
                                    Indicates that the container must run
                                    as a non-root user. If true, the Kubelet will
                                    validate the image at runtime to ensure that it
                                    does not run as UID 0 (root) and fail to start
                                    the container if it does. If unset or false, no
                                    such validation will be performed. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  type: boolean
                                runAsUser:
                                  description:
                                    The UID to run the entrypoint of the
                                    container process. Defaults to user specified
                                    in image metadata if unspecified. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                seLinuxOptions:
                                  description:
                                    The SELinux context to be applied to
                                    the container. If unspecified, the container runtime
                                    will allocate a random SELinux context for each
                                    container.  May also be set in PodSecurityContext.  If
                                    set in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  properties:
                                    level:
                                      description:
                                        Level is SELinux level label that
                                        applies to the container.
                                      type: string
                                    role:
                                      description:
                                        Role is a SELinux role label that
                                        applies to the container.
                                      type: string
                                    type:
                                      description:
                                        Type is a SELinux type label that
                                        applies to the container.
                                      type: string
                                    user:
                                      description:
                                        User is a SELinux user label that
                                        applies to the container.
                                      type: string
                                  type: object
                                windowsOptions:
                                  description: Windows security options.
                                  properties:
                                    gmsaCredentialSpec:
                                      description:
                                        GMSACredentialSpec is where the
                                        GMSA admission webhook (https://github.com/kubernetes-sigs/windows-gmsa)
                                        inlines the contents of the GMSA credential
                                        spec named by the GMSACredentialSpecName field.
                                        This field is alpha-level and is only honored
                                        by servers that enable the WindowsGMSA feature
                                        flag.
                                      type: string
                                    gmsaCredentialSpecName:
                                      description:
                                        GMSACredentialSpecName is the name
                                        of the GMSA credential spec to use. This field
                                        is alpha-level and is only honored by servers
                                        that enable the WindowsGMSA feature flag.
                                      type: string
                                  type: object
                              type: object
                            stdin:
                              description:
                                Whether this container should allocate
                                a buffer for stdin in the container runtime. If this
                                is not set, reads from stdin in the container will
                                always result in EOF. Default is false.
                              type: boolean
                            stdinOnce:
                              description:
                                Whether the container runtime should close
                                the stdin channel after it has been opened by a single
                                attach. When stdin is true the stdin stream will remain
                                open across multiple attach sessions. If stdinOnce
                                is set to true, stdin is opened on container start,
                                is empty until the first client attaches to stdin,
                                and then remains open and accepts data until the client
                                disconnects, at which time stdin is closed and remains
                                closed until the container is restarted. If this flag
                                is false, a container processes that reads from stdin
                                will never receive an EOF. Default is false
                              type: boolean
                            terminationMessagePath:
                              description:
                                "Optional: Path at which the file to which
                                the container's termination message will be written
                                is mounted into the container's filesystem. Message
                                written is intended to be brief final status, such
                                as an assertion failure message. Will be truncated
                                by the node if greater than 4096 bytes. The total
                                message length across all containers will be limited
                                to 12kb. Defaults to /dev/termination-log. Cannot
                                be updated."
                              type: string
                            terminationMessagePolicy:
                              description:
                                Indicate how the termination message should
                                be populated. File will use the contents of terminationMessagePath
                                to populate the container status message on both success
                                and failure. FallbackToLogsOnError will use the last
                                chunk of container log output if the termination message
                                file is empty and the container exited with an error.
                                The log output is limited to 2048 bytes or 80 lines,
                                whichever is smaller. Defaults to File. Cannot be
                                updated.
                              type: string
                            tty:
                              description:
                                Whether this container should allocate
                                a TTY for itself, also requires 'stdin' to be true.
                                Default is false.
                              type: boolean
                            volumeDevices:
                              description:
                                volumeDevices is the list of block devices
                                to be used by the container. This is a beta feature.
                              items:
                                description:
                                  volumeDevice describes a mapping of a
                                  raw block device within a container.
                                properties:
                                  devicePath:
                                    description:
                                      devicePath is the path inside of
                                      the container that the device will be mapped
                                      to.
                                    type: string
                                  name:
                                    description:
                                      name must match the name of a persistentVolumeClaim
                                      in the pod
                                    type: string
                                required:
                                  - devicePath
                                  - name
                                type: object
                              type: array
                            volumeMounts:
                              description:
                                Pod volumes to mount into the container's
                                filesystem. Cannot be updated.
                              items:
                                description:
                                  VolumeMount describes a mounting of a
                                  Volume within a container.
                                properties:
                                  mountPath:
                                    description:
                                      Path within the container at which
                                      the volume should be mounted.  Must not contain
                                      ':'.
                                    type: string
                                  mountPropagation:
                                    description:
                                      mountPropagation determines how mounts
                                      are propagated from the host to container and
                                      the other way around. When not set, MountPropagationNone
                                      is used. This field is beta in 1.10.
                                    type: string
                                  name:
                                    description: This must match the Name of a Volume.
                                    type: string
                                  readOnly:
                                    description:
                                      Mounted read-only if true, read-write
                                      otherwise (false or unspecified). Defaults to
                                      false.
                                    type: boolean
                                  subPath:
                                    description:
                                      Path within the volume from which
                                      the container's volume should be mounted. Defaults
                                      to "" (volume's root).
                                    type: string
                                  subPathExpr:
                                    description:
                                      Expanded path within the volume from
                                      which the container's volume should be mounted.
                                      Behaves similarly to SubPath but environment
                                      variable references $(VAR_NAME) are expanded
                                      using the container's environment. Defaults
                                      to "" (volume's root). SubPathExpr and SubPath
                                      are mutually exclusive. This field is beta in
                                      1.15.
                                    type: string
                                required:
                                  - mountPath
                                  - name
                                type: object
                              type: array
                            workingDir:
                              description:
                                Container's working directory. If not specified,
                                the container runtime's default will be used, which
                                might be configured in the container image. Cannot
                                be updated.
                              type: string
                          required:
                            - name
                          type: object
                      required:
                        - container
                      type: object
                    logger:
                      description: Activate request/response logging
                      properties:
                        mode:
                          description: What payloads to log
                          type: string
                        url:
                          description: URL to send request logging CloudEvents
                          type: string
                      type: object
                    maxReplicas:
                      description: This is the up bound for autoscaler to scale to
                      type: integer
                    minReplicas:
                      description:
                        Minimum number of replicas, pods won't scale down
                        to 0 in case of no traffic
                      type: integer
                    onnx:
                      description: Spec for ONNX runtime (https://github.com/microsoft/onnxruntime)
                      properties:
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    parallelism:
                      description:
                        Parallelism specifies how many requests can be
                        processed concurrently, this sets the target concurrency for
                        Autoscaling(KPA). For model servers that support tuning parallelism
                        will use this value, by default the parallelism is the number
                        of the CPU cores for most of the model servers.
                      type: integer
                    pytorch:
                      description: Spec for PyTorch predictor
                      properties:
                        modelClassName:
                          description: Defaults PyTorch model class name to 'PyTorchModel'
                          type: string
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    serviceAccountName:
                      description:
                        ServiceAccountName is the name of the ServiceAccount
                        to use to run the service
                      type: string
                    sklearn:
                      description: Spec for SKLearn predictor
                      properties:
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    tensorflow:
                      description: Spec for Tensorflow Serving (https://github.com/tensorflow/serving)
                      properties:
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map.
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    tensorrt:
                      description: Spec for TensorRT Inference Server (https://github.com/NVIDIA/triton-inference-server)
                      properties:
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                    xgboost:
                      description: Spec for XGBoost predictor
                      properties:
                        nthread:
                          description: Number of thread to be used by XGBoost
                          type: integer
                        resources:
                          description:
                            Defaults to requests and limits of 1CPU, 2Gb
                            MEM.
                          properties:
                            limits:
                              additionalProperties:
                                type: string
                              description:
                                "Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                            requests:
                              additionalProperties:
                                type: string
                              description:
                                "Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              type: object
                          type: object
                        runtimeVersion:
                          description:
                            Allowed runtime versions are specified in the
                            inferenceservice config map
                          type: string
                        storageUri:
                          description: The location of the trained model
                          type: string
                      required:
                        - storageUri
                      type: object
                  type: object
                transformer:
                  description:
                    Transformer defines the pre/post processing before
                    and after the predictor call, transformer service calls to predictor
                    service.
                  properties:
                    custom:
                      description: Spec for a custom transformer
                      properties:
                        container:
                          description:
                            A single application container that you want
                            to run within a pod.
                          properties:
                            args:
                              description:
                                "Arguments to the entrypoint. The docker
                                image's CMD is used if this is not provided. Variable
                                references $(VAR_NAME) are expanded using the container's
                                environment. If a variable cannot be resolved, the
                                reference in the input string will be unchanged. The
                                $(VAR_NAME) syntax can be escaped with a double $$,
                                ie: $$(VAR_NAME). Escaped references will never be
                                expanded, regardless of whether the variable exists
                                or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            command:
                              description:
                                "Entrypoint array. Not executed within
                                a shell. The docker image's ENTRYPOINT is used if
                                this is not provided. Variable references $(VAR_NAME)
                                are expanded using the container's environment. If
                                a variable cannot be resolved, the reference in the
                                input string will be unchanged. The $(VAR_NAME) syntax
                                can be escaped with a double $$, ie: $$(VAR_NAME).
                                Escaped references will never be expanded, regardless
                                of whether the variable exists or not. Cannot be updated.
                                More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell"
                              items:
                                type: string
                              type: array
                            env:
                              description:
                                List of environment variables to set in
                                the container. Cannot be updated.
                              items:
                                description:
                                  EnvVar represents an environment variable
                                  present in a Container.
                                properties:
                                  name:
                                    description:
                                      Name of the environment variable.
                                      Must be a C_IDENTIFIER.
                                    type: string
                                  value:
                                    description:
                                      'Variable references $(VAR_NAME)
                                      are expanded using the previous defined environment
                                      variables in the container and any service environment
                                      variables. If a variable cannot be resolved,
                                      the reference in the input string will be unchanged.
                                      The $(VAR_NAME) syntax can be escaped with a
                                      double $$, ie: $$(VAR_NAME). Escaped references
                                      will never be expanded, regardless of whether
                                      the variable exists or not. Defaults to "".'
                                    type: string
                                  valueFrom:
                                    description:
                                      Source for the environment variable's
                                      value. Cannot be used if value is not empty.
                                    properties:
                                      configMapKeyRef:
                                        description: Selects a key of a ConfigMap.
                                        properties:
                                          key:
                                            description: The key to select.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the ConfigMap
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                      fieldRef:
                                        description:
                                          "Selects a field of the pod:
                                          supports metadata.name, metadata.namespace,
                                          metadata.labels, metadata.annotations, spec.nodeName,
                                          spec.serviceAccountName, status.hostIP,
                                          status.podIP."
                                        properties:
                                          apiVersion:
                                            description:
                                              Version of the schema the
                                              FieldPath is written in terms of, defaults
                                              to "v1".
                                            type: string
                                          fieldPath:
                                            description:
                                              Path of the field to select
                                              in the specified API version.
                                            type: string
                                        required:
                                          - fieldPath
                                        type: object
                                      resourceFieldRef:
                                        description:
                                          "Selects a resource of the container:
                                          only resources limits and requests (limits.cpu,
                                          limits.memory, limits.ephemeral-storage,
                                          requests.cpu, requests.memory and requests.ephemeral-storage)
                                          are currently supported."
                                        properties:
                                          containerName:
                                            description:
                                              "Container name: required
                                              for volumes, optional for env vars"
                                            type: string
                                          divisor:
                                            description:
                                              Specifies the output format
                                              of the exposed resources, defaults to
                                              "1"
                                            type: string
                                          resource:
                                            description: "Required: resource to select"
                                            type: string
                                        required:
                                          - resource
                                        type: object
                                      secretKeyRef:
                                        description:
                                          Selects a key of a secret in
                                          the pod's namespace
                                        properties:
                                          key:
                                            description:
                                              The key of the secret to
                                              select from.  Must be a valid secret
                                              key.
                                            type: string
                                          name:
                                            description:
                                              "Name of the referent. More
                                              info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              TODO: Add other useful fields. apiVersion,
                                              kind, uid?"
                                            type: string
                                          optional:
                                            description:
                                              Specify whether the Secret
                                              or its key must be defined
                                            type: boolean
                                        required:
                                          - key
                                        type: object
                                    type: object
                                required:
                                  - name
                                type: object
                              type: array
                            envFrom:
                              description:
                                List of sources to populate environment
                                variables in the container. The keys defined within
                                a source must be a C_IDENTIFIER. All invalid keys
                                will be reported as an event when the container is
                                starting. When a key exists in multiple sources, the
                                value associated with the last source will take precedence.
                                Values defined by an Env with a duplicate key will
                                take precedence. Cannot be updated.
                              items:
                                description:
                                  EnvFromSource represents the source of
                                  a set of ConfigMaps
                                properties:
                                  configMapRef:
                                    description: The ConfigMap to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the ConfigMap
                                          must be defined
                                        type: boolean
                                    type: object
                                  prefix:
                                    description:
                                      An optional identifier to prepend
                                      to each key in the ConfigMap. Must be a C_IDENTIFIER.
                                    type: string
                                  secretRef:
                                    description: The Secret to select from
                                    properties:
                                      name:
                                        description:
                                          "Name of the referent. More info:
                                          https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                          TODO: Add other useful fields. apiVersion,
                                          kind, uid?"
                                        type: string
                                      optional:
                                        description:
                                          Specify whether the Secret must
                                          be defined
                                        type: boolean
                                    type: object
                                type: object
                              type: array
                            image:
                              description:
                                "Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images
                                This field is optional to allow higher level config
                                management to default or override container images
                                in workload controllers like Deployments and StatefulSets."
                              type: string
                            imagePullPolicy:
                              description:
                                "Image pull policy. One of Always, Never,
                                IfNotPresent. Defaults to Always if :v0.3.0 tag is
                                specified, or IfNotPresent otherwise. Cannot be updated.
                                More info: https://kubernetes.io/docs/concepts/containers/images#updating-images"
                              type: string
                            lifecycle:
                              description:
                                Actions that the management system should
                                take in response to container lifecycle events. Cannot
                                be updated.
                              properties:
                                postStart:
                                  description:
                                    "PostStart is called immediately after
                                    a container is created. If the handler fails,
                                    the container is terminated and restarted according
                                    to its restart policy. Other management of the
                                    container blocks until the hook completes. More
                                    info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                                preStop:
                                  description:
                                    "PreStop is called immediately before
                                    a container is terminated due to an API request
                                    or management event such as liveness probe failure,
                                    preemption, resource contention, etc. The handler
                                    is not called if the container crashes or exits.
                                    The reason for termination is passed to the handler.
                                    The Pod's termination grace period countdown
                                    begins before the PreStop hooked is executed.
                                    Regardless of the outcome of the handler, the
                                    container will eventually terminate within the
                                    Pod's termination grace period. Other management
                                    of the container blocks until the hook completes
                                    or until the termination grace period is reached.
                                    More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks"
                                  properties:
                                    exec:
                                      description:
                                        One and only one of the following
                                        should be specified. Exec specifies the action
                                        to take.
                                      properties:
                                        command:
                                          description:
                                            Command is the command line
                                            to execute inside the container, the working
                                            directory for the command  is root ('/')
                                            in the container's filesystem. The command
                                            is simply exec'd, it is not run inside
                                            a shell, so traditional shell instructions
                                            ('|', etc) won't work. To use a shell,
                                            you need to explicitly call out to that
                                            shell. Exit status of 0 is treated as
                                            live/healthy and non-zero is unhealthy.
                                          items:
                                            type: string
                                          type: array
                                      type: object
                                    httpGet:
                                      description:
                                        HTTPGet specifies the http request
                                        to perform.
                                      properties:
                                        host:
                                          description:
                                            Host name to connect to, defaults
                                            to the pod IP. You probably want to set
                                            "Host" in httpHeaders instead.
                                          type: string
                                        httpHeaders:
                                          description:
                                            Custom headers to set in the
                                            request. HTTP allows repeated headers.
                                          items:
                                            description:
                                              HTTPHeader describes a custom
                                              header to be used in HTTP probes
                                            properties:
                                              name:
                                                description: The header field name
                                                type: string
                                              value:
                                                description: The header field value
                                                type: string
                                            required:
                                              - name
                                              - value
                                            type: object
                                          type: array
                                        path:
                                          description:
                                            Path to access on the HTTP
                                            server.
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Name or number of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                        scheme:
                                          description:
                                            Scheme to use for connecting
                                            to the host. Defaults to HTTP.
                                          type: string
                                      required:
                                        - port
                                      type: object
                                    tcpSocket:
                                      description:
                                        "TCPSocket specifies an action
                                        involving a TCP port. TCP hooks not yet supported
                                        TODO: implement a realistic TCP lifecycle
                                        hook"
                                      properties:
                                        host:
                                          description:
                                            "Optional: Host name to connect
                                            to, defaults to the pod IP."
                                          type: string
                                        port:
                                          anyOf:
                                            - type: string
                                            - type: integer
                                          description:
                                            Number or name of the port
                                            to access on the container. Number must
                                            be in the range 1 to 65535. Name must
                                            be an IANA_SVC_NAME.
                                      required:
                                        - port
                                      type: object
                                  type: object
                              type: object
                            livenessProbe:
                              description:
                                "Periodic probe of container liveness.
                                Container will be restarted if the probe fails. Cannot
                                be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            name:
                              description:
                                Name of the container specified as a DNS_LABEL.
                                Each container in a pod must have a unique name (DNS_LABEL).
                                Cannot be updated.
                              type: string
                            ports:
                              description:
                                List of ports to expose from the container.
                                Exposing a port here gives the system additional information
                                about the network connections a container uses, but
                                is primarily informational. Not specifying a port
                                here DOES NOT prevent that port from being exposed.
                                Any port which is listening on the default "0.0.0.0"
                                address inside a container will be accessible from
                                the network. Cannot be updated.
                              items:
                                description:
                                  ContainerPort represents a network port
                                  in a single container.
                                properties:
                                  containerPort:
                                    description:
                                      Number of port to expose on the pod's
                                      IP address. This must be a valid port number,
                                      0 < x < 65536.
                                    format: int32
                                    type: integer
                                  hostIP:
                                    description:
                                      What host IP to bind the external
                                      port to.
                                    type: string
                                  hostPort:
                                    description:
                                      Number of port to expose on the host.
                                      If specified, this must be a valid port number,
                                      0 < x < 65536. If HostNetwork is specified,
                                      this must match ContainerPort. Most containers
                                      do not need this.
                                    format: int32
                                    type: integer
                                  name:
                                    description:
                                      If specified, this must be an IANA_SVC_NAME
                                      and unique within the pod. Each named port in
                                      a pod must have a unique name. Name for the
                                      port that can be referred to by services.
                                    type: string
                                  protocol:
                                    description:
                                      Protocol for port. Must be UDP, TCP,
                                      or SCTP. Defaults to "TCP".
                                    type: string
                                required:
                                  - containerPort
                                type: object
                              type: array
                            readinessProbe:
                              description:
                                "Periodic probe of container service readiness.
                                Container will be removed from service endpoints if
                                the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                              properties:
                                exec:
                                  description:
                                    One and only one of the following should
                                    be specified. Exec specifies the action to take.
                                  properties:
                                    command:
                                      description:
                                        Command is the command line to
                                        execute inside the container, the working
                                        directory for the command  is root ('/') in
                                        the container's filesystem. The command is
                                        simply exec'd, it is not run inside a shell,
                                        so traditional shell instructions ('|', etc)
                                        won't work. To use a shell, you need to explicitly
                                        call out to that shell. Exit status of 0 is
                                        treated as live/healthy and non-zero is unhealthy.
                                      items:
                                        type: string
                                      type: array
                                  type: object
                                failureThreshold:
                                  description:
                                    Minimum consecutive failures for the
                                    probe to be considered failed after having succeeded.
                                    Defaults to 3. Minimum value is 1.
                                  format: int32
                                  type: integer
                                httpGet:
                                  description:
                                    HTTPGet specifies the http request
                                    to perform.
                                  properties:
                                    host:
                                      description:
                                        Host name to connect to, defaults
                                        to the pod IP. You probably want to set "Host"
                                        in httpHeaders instead.
                                      type: string
                                    httpHeaders:
                                      description:
                                        Custom headers to set in the request.
                                        HTTP allows repeated headers.
                                      items:
                                        description:
                                          HTTPHeader describes a custom
                                          header to be used in HTTP probes
                                        properties:
                                          name:
                                            description: The header field name
                                            type: string
                                          value:
                                            description: The header field value
                                            type: string
                                        required:
                                          - name
                                          - value
                                        type: object
                                      type: array
                                    path:
                                      description: Path to access on the HTTP server.
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Name or number of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                    scheme:
                                      description:
                                        Scheme to use for connecting to
                                        the host. Defaults to HTTP.
                                      type: string
                                  required:
                                    - port
                                  type: object
                                initialDelaySeconds:
                                  description:
                                    "Number of seconds after the container
                                    has started before liveness probes are initiated.
                                    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                                periodSeconds:
                                  description:
                                    How often (in seconds) to perform the
                                    probe. Default to 10 seconds. Minimum value is
                                    1.
                                  format: int32
                                  type: integer
                                successThreshold:
                                  description:
                                    Minimum consecutive successes for the
                                    probe to be considered successful after having
                                    failed. Defaults to 1. Must be 1 for liveness.
                                    Minimum value is 1.
                                  format: int32
                                  type: integer
                                tcpSocket:
                                  description:
                                    "TCPSocket specifies an action involving
                                    a TCP port. TCP hooks not yet supported TODO:
                                    implement a realistic TCP lifecycle hook"
                                  properties:
                                    host:
                                      description:
                                        "Optional: Host name to connect
                                        to, defaults to the pod IP."
                                      type: string
                                    port:
                                      anyOf:
                                        - type: string
                                        - type: integer
                                      description:
                                        Number or name of the port to access
                                        on the container. Number must be in the range
                                        1 to 65535. Name must be an IANA_SVC_NAME.
                                  required:
                                    - port
                                  type: object
                                timeoutSeconds:
                                  description:
                                    "Number of seconds after which the
                                    probe times out. Defaults to 1 second. Minimum
                                    value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes"
                                  format: int32
                                  type: integer
                              type: object
                            resources:
                              description:
                                "Compute Resources required by this container.
                                Cannot be updated. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                              properties:
                                limits:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Limits describes the maximum amount
                                    of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                                requests:
                                  additionalProperties:
                                    type: string
                                  description:
                                    "Requests describes the minimum amount
                                    of compute resources required. If Requests is
                                    omitted for a container, it defaults to Limits
                                    if that is explicitly specified, otherwise to
                                    an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/"
                                  type: object
                              type: object
                            securityContext:
                              description:
                                "Security options the pod should run with.
                                More info: https://kubernetes.io/docs/concepts/policy/security-context/
                                More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"
                              properties:
                                allowPrivilegeEscalation:
                                  description:
                                    "AllowPrivilegeEscalation controls
                                    whether a process can gain more privileges than
                                    its parent process. This bool directly controls
                                    if the no_new_privs flag will be set on the container
                                    process. AllowPrivilegeEscalation is true always
                                    when the container is: 1) run as Privileged 2)
                                    has CAP_SYS_ADMIN"
                                  type: boolean
                                capabilities:
                                  description:
                                    The capabilities to add/drop when running
                                    containers. Defaults to the default set of capabilities
                                    granted by the container runtime.
                                  properties:
                                    add:
                                      description: Added capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                    drop:
                                      description: Removed capabilities
                                      items:
                                        description:
                                          Capability represent POSIX capabilities
                                          type
                                        type: string
                                      type: array
                                  type: object
                                privileged:
                                  description:
                                    Run container in privileged mode. Processes
                                    in privileged containers are essentially equivalent
                                    to root on the host. Defaults to false.
                                  type: boolean
                                procMount:
                                  description:
                                    procMount denotes the type of proc
                                    mount to use for the containers. The default is
                                    DefaultProcMount which uses the container runtime
                                    defaults for readonly paths and masked paths.
                                    This requires the ProcMountType feature flag to
                                    be enabled.
                                  type: string
                                readOnlyRootFilesystem:
                                  description:
                                    Whether this container has a read-only
                                    root filesystem. Default is false.
                                  type: boolean
                                runAsGroup:
                                  description:
                                    The GID to run the entrypoint of the
                                    container process. Uses runtime default if unset.
                                    May also be set in PodSecurityContext.  If set
                                    in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                runAsNonRoot:
                                  description:
                                    Indicates that the container must run
                                    as a non-root user. If true, the Kubelet will
                                    validate the image at runtime to ensure that it
                                    does not run as UID 0 (root) and fail to start
                                    the container if it does. If unset or false, no
                                    such validation will be performed. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  type: boolean
                                runAsUser:
                                  description:
                                    The UID to run the entrypoint of the
                                    container process. Defaults to user specified
                                    in image metadata if unspecified. May also be
                                    set in PodSecurityContext.  If set in both SecurityContext
                                    and PodSecurityContext, the value specified in
                                    SecurityContext takes precedence.
                                  format: int64
                                  type: integer
                                seLinuxOptions:
                                  description:
                                    The SELinux context to be applied to
                                    the container. If unspecified, the container runtime
                                    will allocate a random SELinux context for each
                                    container.  May also be set in PodSecurityContext.  If
                                    set in both SecurityContext and PodSecurityContext,
                                    the value specified in SecurityContext takes precedence.
                                  properties:
                                    level:
                                      description:
                                        Level is SELinux level label that
                                        applies to the container.
                                      type: string
                                    role:
                                      description:
                                        Role is a SELinux role label that
                                        applies to the container.
                                      type: string
                                    type:
                                      description:
                                        Type is a SELinux type label that
                                        applies to the container.
                                      type: string
                                    user:
                                      description:
                                        User is a SELinux user label that
                                        applies to the container.
                                      type: string
                                  type: object
                                windowsOptions:
                                  description: Windows security options.
                                  properties:
                                    gmsaCredentialSpec:
                                      description:
                                        GMSACredentialSpec is where the
                                        GMSA admission webhook (https://github.com/kubernetes-sigs/windows-gmsa)
                                        inlines the contents of the GMSA credential
                                        spec named by the GMSACredentialSpecName field.
                                        This field is alpha-level and is only honored
                                        by servers that enable the WindowsGMSA feature
                                        flag.
                                      type: string
                                    gmsaCredentialSpecName:
                                      description:
                                        GMSACredentialSpecName is the name
                                        of the GMSA credential spec to use. This field
                                        is alpha-level and is only honored by servers
                                        that enable the WindowsGMSA feature flag.
                                      type: string
                                  type: object
                              type: object
                            stdin:
                              description:
                                Whether this container should allocate
                                a buffer for stdin in the container runtime. If this
                                is not set, reads from stdin in the container will
                                always result in EOF. Default is false.
                              type: boolean
                            stdinOnce:
                              description:
                                Whether the container runtime should close
                                the stdin channel after it has been opened by a single
                                attach. When stdin is true the stdin stream will remain
                                open across multiple attach sessions. If stdinOnce
                                is set to true, stdin is opened on container start,
                                is empty until the first client attaches to stdin,
                                and then remains open and accepts data until the client
                                disconnects, at which time stdin is closed and remains
                                closed until the container is restarted. If this flag
                                is false, a container processes that reads from stdin
                                will never receive an EOF. Default is false
                              type: boolean
                            terminationMessagePath:
                              description:
                                "Optional: Path at which the file to which
                                the container's termination message will be written
                                is mounted into the container's filesystem. Message
                                written is intended to be brief final status, such
                                as an assertion failure message. Will be truncated
                                by the node if greater than 4096 bytes. The total
                                message length across all containers will be limited
                                to 12kb. Defaults to /dev/termination-log. Cannot
                                be updated."
                              type: string
                            terminationMessagePolicy:
                              description:
                                Indicate how the termination message should
                                be populated. File will use the contents of terminationMessagePath
                                to populate the container status message on both success
                                and failure. FallbackToLogsOnError will use the last
                                chunk of container log output if the termination message
                                file is empty and the container exited with an error.
                                The log output is limited to 2048 bytes or 80 lines,
                                whichever is smaller. Defaults to File. Cannot be
                                updated.
                              type: string
                            tty:
                              description:
                                Whether this container should allocate
                                a TTY for itself, also requires 'stdin' to be true.
                                Default is false.
                              type: boolean
                            volumeDevices:
                              description:
                                volumeDevices is the list of block devices
                                to be used by the container. This is a beta feature.
                              items:
                                description:
                                  volumeDevice describes a mapping of a
                                  raw block device within a container.
                                properties:
                                  devicePath:
                                    description:
                                      devicePath is the path inside of
                                      the container that the device will be mapped
                                      to.
                                    type: string
                                  name:
                                    description:
                                      name must match the name of a persistentVolumeClaim
                                      in the pod
                                    type: string
                                required:
                                  - devicePath
                                  - name
                                type: object
                              type: array
                            volumeMounts:
                              description:
                                Pod volumes to mount into the container's
                                filesystem. Cannot be updated.
                              items:
                                description:
                                  VolumeMount describes a mounting of a
                                  Volume within a container.
                                properties:
                                  mountPath:
                                    description:
                                      Path within the container at which
                                      the volume should be mounted.  Must not contain
                                      ':'.
                                    type: string
                                  mountPropagation:
                                    description:
                                      mountPropagation determines how mounts
                                      are propagated from the host to container and
                                      the other way around. When not set, MountPropagationNone
                                      is used. This field is beta in 1.10.
                                    type: string
                                  name:
                                    description: This must match the Name of a Volume.
                                    type: string
                                  readOnly:
                                    description:
                                      Mounted read-only if true, read-write
                                      otherwise (false or unspecified). Defaults to
                                      false.
                                    type: boolean
                                  subPath:
                                    description:
                                      Path within the volume from which
                                      the container's volume should be mounted. Defaults
                                      to "" (volume's root).
                                    type: string
                                  subPathExpr:
                                    description:
                                      Expanded path within the volume from
                                      which the container's volume should be mounted.
                                      Behaves similarly to SubPath but environment
                                      variable references $(VAR_NAME) are expanded
                                      using the container's environment. Defaults
                                      to "" (volume's root). SubPathExpr and SubPath
                                      are mutually exclusive. This field is beta in
                                      1.15.
                                    type: string
                                required:
                                  - mountPath
                                  - name
                                type: object
                              type: array
                            workingDir:
                              description:
                                Container's working directory. If not specified,
                                the container runtime's default will be used, which
                                might be configured in the container image. Cannot
                                be updated.
                              type: string
                          required:
                            - name
                          type: object
                      required:
                        - container
                      type: object
                    logger:
                      description: Activate request/response logging
                      properties:
                        mode:
                          description: What payloads to log
                          type: string
                        url:
                          description: URL to send request logging CloudEvents
                          type: string
                      type: object
                    maxReplicas:
                      description: This is the up bound for autoscaler to scale to
                      type: integer
                    minReplicas:
                      description:
                        Minimum number of replicas, pods won't scale down
                        to 0 in case of no traffic
                      type: integer
                    parallelism:
                      description:
                        Parallelism specifies how many requests can be
                        processed concurrently, this sets the target concurrency for
                        Autoscaling(KPA). For model servers that support tuning parallelism
                        will use this value, by default the parallelism is the number
                        of the CPU cores for most of the model servers.
                      type: integer
                    serviceAccountName:
                      description:
                        ServiceAccountName is the name of the ServiceAccount
                        to use to run the service
                      type: string
                  type: object
              required:
                - predictor
              type: object
          required:
            - default
          type: object
        status:
          description: InferenceServiceStatus defines the observed state of InferenceService
          properties:
            address:
              description: Ducktype for addressable
              properties:
                url:
                  description:
                    URL is an alias of url.URL. It has custom json marshal
                    methods that enable it to be used in K8s CRDs such that the CRD
                    resource will have the URL but operator code can can work with
                    url.URL struct
                  type: string
            canary:
              additionalProperties:
                description:
                  StatusConfigurationSpec describes the state of the configuration
                  receiving traffic.
                properties:
                  host:
                    description: Host name of the service
                    type: string
                  name:
                    description: Latest revision name that is in ready state
                    type: string
                  replicas:
                    type: integer
                type: object
              description: Statuses for the canary endpoints of the InferenceService
              type: object
            canaryTraffic:
              description: Traffic percentage that goes to canary services
              type: integer
            conditions:
              description:
                Conditions the latest available observations of a resource's
                current state. +patchMergeKey=type +patchStrategy=merge
              items:
                properties:
                  lastTransitionTime:
                    description:
                      LastTransitionTime is the last time the condition
                      transitioned from one status to another. We use VolatileTime
                      in place of metav1.Time to exclude this from creating equality.Semantic
                      differences (all other things held constant).
                    type: string
                  message:
                    description:
                      A human readable message indicating details about
                      the transition.
                    type: string
                  reason:
                    description: The reason for the condition's last transition.
                    type: string
                  severity:
                    description:
                      Severity with which to treat failures of this type
                      of condition. When this is not specified, it defaults to Error.
                    type: string
                  status:
                    description:
                      Status of the condition, one of True, False, Unknown.
                      +required
                    type: string
                  type:
                    description: Type of condition. +required
                    type: string
                required:
                  - type
                  - status
                type: object
              type: array
            default:
              additionalProperties:
                description:
                  StatusConfigurationSpec describes the state of the configuration
                  receiving traffic.
                properties:
                  host:
                    description: Host name of the service
                    type: string
                  name:
                    description: Latest revision name that is in ready state
                    type: string
                  replicas:
                    type: integer
                type: object
              description: Statuses for the default endpoints of the InferenceService
              type: object
            observedGeneration:
              description:
                ObservedGeneration is the 'Generation' of the Service that
                was last processed by the controller.
              format: int64
              type: integer
            traffic:
              description: Traffic percentage that goes to default services
              type: integer
            url:
              description: URL of the InferenceService
              type: string
          type: object
      type: object
  version: v1alpha2
  versions:
    - name: v1alpha2
      served: true
      storage: true
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubeflow-kfserving-edit
  labels:
    rbac.authorization.kubeflow.org/aggregate-to-kubeflow-edit: "true"
    rbac.authorization.kubeflow.org/aggregate-to-kubeflow-admin: "true"
rules:
  - apiGroups:
      - serving.kubeflow.org
    resources:
      - "*"
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kfserving-proxy-role
rules:
  - apiGroups:
      - authentication.k8s.io
    resources:
      - tokenreviews
    verbs:
      - create
  - apiGroups:
      - authorization.k8s.io
    resources:
      - subjectaccessreviews
    verbs:
      - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: null
  name: manager-role
rules:
  - apiGroups:
      - serving.knative.dev
    resources:
      - services
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
  - apiGroups:
      - serving.knative.dev
    resources:
      - services/status
    verbs:
      - get
      - update
      - patch
  - apiGroups:
      - networking.istio.io
    resources:
      - virtualservices
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
  - apiGroups:
      - networking.istio.io
    resources:
      - virtualservices/status
    verbs:
      - get
      - update
      - patch
  - apiGroups:
      - serving.kubeflow.org
    resources:
      - inferenceservices
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
  - apiGroups:
      - serving.kubeflow.org
    resources:
      - inferenceservices/status
    verbs:
      - get
      - update
      - patch
  - apiGroups:
      - ""
    resources:
      - serviceaccounts
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - secrets
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - admissionregistration.k8s.io
    resources:
      - mutatingwebhookconfigurations
      - validatingwebhookconfigurations
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
  - apiGroups:
      - ""
    resources:
      - secrets
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
  - apiGroups:
      - ""
    resources:
      - namespaces
    verbs:
      - get
      - list
      - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kfserving-proxy-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kfserving-proxy-role
subjects:
  - kind: ServiceAccount
    name: default
    namespace: kfserving-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: manager-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: manager-role
subjects:
  - kind: ServiceAccount
    name: default
    namespace: kfserving-system
---
apiVersion: v1
data:
  credentials: |-
    {
       "gcs": {
           "gcsCredentialFileName": "gcloud-application-credentials.json"
       },
       "s3": {
           "s3AccessKeyIDName": "awsAccessKeyID",
           "s3SecretAccessKeyName": "awsSecretAccessKey"
       }
    }
  explainers: |-
    {
        "alibi": {
            "image" : "docker.io/seldonio/kfserving-alibiexplainer",
            "defaultImageVersion": "v0.3.0",
            "allowedImageVersions": [
               "v0.3.0"
            ]
        }
    }
  ingress: |-
    {
        "ingressGateway" : "kubeflow-gateway.kubeflow",
        "ingressService" : "istio-ingressgateway.istio-system.svc.cluster.local"
    }
  logger: |-
    {
        "image" : "gcr.io/kfserving/logger:v0.3.0",
        "memoryRequest": "100Mi",
        "memoryLimit": "1Gi",
        "cpuRequest": "100m",
        "cpuLimit": "1"
    }
  predictors: |-
    {
        "tensorflow": {
            "image": "tensorflow/serving",
            "defaultImageVersion": "1.14.0",
            "defaultGpuImageVersion": "1.14.0-gpu",
            "allowedImageVersions": [
               "1.11.0",
               "1.11.0-gpu",
               "1.12.0",
               "1.12.0-gpu",
               "1.13.0",
               "1.13.0-gpu",
               "1.14.0",
               "1.14.0-gpu"
            ]
        },
        "onnx": {
            "image": "mcr.microsoft.com/onnxruntime/server",
            "defaultImageVersion": "v0.5.1",
            "allowedImageVersions": [
               "v0.5.1"
            ]
        },
        "sklearn": {
            "image": "gcr.io/kfserving/sklearnserver",
            "defaultImageVersion": "v0.3.0",
            "allowedImageVersions": [
               "v0.3.0"
            ]
        },
        "xgboost": {
            "image": "gcr.io/kfserving/xgbserver",
            "defaultImageVersion": "v0.3.0",
            "allowedImageVersions": [
               "v0.3.0"
            ]
        },
        "pytorch": {
            "image": "gcr.io/kfserving/pytorchserver",
            "defaultImageVersion": "v0.3.0",
            "defaultGpuImageVersion": "v0.3.0-gpu",
            "allowedImageVersions": [
               "v0.3.0",
               "v0.3.0-gpu"
            ]
        },
        "tensorrt": {
            "image": "nvcr.io/nvidia/tensorrtserver",
            "defaultImageVersion": "19.05-py3",
            "allowedImageVersions": [
               "19.05-py3"
            ]
        }
    }
  storageInitializer: |-
    {
        "image" : "gcr.io/kfserving/storage-initializer:v0.3.0",
        "memoryRequest": "100Mi",
        "memoryLimit": "1Gi",
        "cpuRequest": "100m",
        "cpuLimit": "1"
    }
  transformers: |-
    {
    }
kind: ConfigMap
metadata:
  name: inferenceservice-config
  namespace: kfserving-system
---
apiVersion: v1
kind: Secret
metadata:
  name: kfserving-webhook-server-secret
  namespace: kfserving-system
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "8443"
    prometheus.io/scheme: https
    prometheus.io/scrape: "true"
  labels:
    control-plane: controller-manager
    controller-tools.k8s.io: "1.0"
  name: kfserving-controller-manager-metrics-service
  namespace: kfserving-system
spec:
  ports:
    - name: https
      port: 8443
      targetPort: https
  selector:
    control-plane: controller-manager
    controller-tools.k8s.io: "1.0"
---
apiVersion: v1
kind: Service
metadata:
  labels:
    control-plane: kfserving-controller-manager
    controller-tools.k8s.io: "1.0"
  name: kfserving-controller-manager-service
  namespace: kfserving-system
spec:
  ports:
    - port: 443
  selector:
    control-plane: kfserving-controller-manager
    controller-tools.k8s.io: "1.0"
---
apiVersion: v1
kind: Service
metadata:
  name: kfserving-webhook-server-service
  namespace: kfserving-system
spec:
  ports:
    - port: 443
      targetPort: 443
  selector:
    control-plane: kfserving-controller-manager
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    control-plane: kfserving-controller-manager
    controller-tools.k8s.io: "1.0"
  name: kfserving-controller-manager
  namespace: kfserving-system
spec:
  selector:
    matchLabels:
      control-plane: kfserving-controller-manager
      controller-tools.k8s.io: "1.0"
  serviceName: controller-manager-service
  template:
    metadata:
      labels:
        control-plane: kfserving-controller-manager
        controller-tools.k8s.io: "1.0"
    spec:
      containers:
        - args:
            - --secure-listen-address=0.0.0.0:8443
            - --upstream=http://127.0.0.1:8080/
            - --logtostderr=true
            - --v=10
          image: gcr.io/kubebuilder/kube-rbac-proxy:v0.4.0
          name: kube-rbac-proxy
          ports:
            - containerPort: 8443
              name: https
        - args:
            - --metrics-addr=127.0.0.1:8080
          command:
            - /manager
          env:
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: SECRET_NAME
              value: kfserving-webhook-server-cert
          image: gcr.io/kfserving/kfserving-controller:v0.3.0
          imagePullPolicy: Always
          name: manager
          ports:
            - containerPort: 443
              name: webhook-server
              protocol: TCP
          resources:
            limits:
              cpu: 100m
              memory: 300Mi
            requests:
              cpu: 100m
              memory: 200Mi
          volumeMounts:
            - mountPath: /tmp/k8s-webhook-server/serving-certs
              name: cert
              readOnly: true
      terminationGracePeriodSeconds: 10
      volumes:
        - name: cert
          secret:
            defaultMode: 420
            secretName: kfserving-webhook-server-cert
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: MutatingWebhookConfiguration
metadata:
  annotations:
    cert-manager.io/inject-ca-from: kfserving-system/serving-cert
  creationTimestamp: null
  name: inferenceservice.serving.kubeflow.org
  namespace: kfserving-system
webhooks:
  - clientConfig:
      caBundle: Cg==
      service:
        name: kfserving-webhook-server-service
        namespace: kfserving-system
        path: /mutate-inferenceservices
    failurePolicy: Fail
    name: inferenceservice.kfserving-webhook-server.defaulter
    rules:
      - apiGroups:
          - serving.kubeflow.org
        apiVersions:
          - v1alpha2
        operations:
          - CREATE
          - UPDATE
        resources:
          - inferenceservices
  - clientConfig:
      caBundle: Cg==
      service:
        name: kfserving-webhook-server-service
        namespace: kfserving-system
        path: /mutate-pods
    failurePolicy: Fail
    name: inferenceservice.kfserving-webhook-server.pod-mutator
    namespaceSelector:
      matchExpressions:
        - key: control-plane
          operator: DoesNotExist
    objectSelector:
      matchExpressions:
        - key: serving.kubeflow.org/inferenceservice
          operator: Exists
    rules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  annotations:
    cert-manager.io/inject-ca-from: kfserving-system/serving-cert
  creationTimestamp: null
  name: inferenceservice.serving.kubeflow.org
  namespace: kfserving-system
webhooks:
  - clientConfig:
      caBundle: Cg==
      service:
        name: kfserving-webhook-server-service
        namespace: kfserving-system
        path: /validate-inferenceservices
    failurePolicy: Fail
    name: inferenceservice.kfserving-webhook-server.validator
    rules:
      - apiGroups:
          - serving.kubeflow.org
        apiVersions:
          - v1alpha2
        operations:
          - CREATE
          - UPDATE
        resources:
          - inferenceservices
---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: serving-cert
  namespace: kfserving-system
spec:
  commonName: kfserving-webhook-server-service.kfserving-system.svc
  dnsNames:
    - kfserving-webhook-server-service.kfserving-system.svc
  issuerRef:
    kind: Issuer
    name: selfsigned-issuer
  secretName: kfserving-webhook-server-cert
---
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: kfserving-system
spec:
  selfSigned: {}



EOT
}