# loki

![Version: 0.19.1](https://img.shields.io/badge/Version-0.19.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.0.0](https://img.shields.io/badge/AppVersion-3.0.0-informational?style=flat-square)

Helm chart for Grafana Loki in simple, scalable mode

**Homepage:** <https://github.com/giantswarm/loki-app>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| giantswarm/team-atlas | <team-atlas@giantswarm.io> |  |

## Source Code

* <https://github.com/giantswarm/loki-app>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://grafana.github.io/helm-charts | loki | 6.5.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ciliumNetworkPolicy.coredns.enabled | bool | `true` |  |
| global.clusterDomain | string | `"cluster.local"` | configures cluster domain ("cluster.local" by default) |
| global.dnsNamespace | string | `"kube-system"` | configures DNS service namespace |
| global.dnsService | string | `"coredns"` | configures DNS service name |
| global.image.registry | string | `"gsoci.azurecr.io"` | Overrides the Docker registry globally for all images |
| global.priorityClassName | string | `nil` | Overrides the priorityClassName for all pods |
| loki.backend.autoscaling.enabled | bool | `true` |  |
| loki.backend.autoscaling.minReplicas | int | `2` |  |
| loki.backend.autoscaling.targetCPUUtilizationPercentage | int | `90` |  |
| loki.backend.resources.limits.memory | string | `"3Gi"` |  |
| loki.backend.resources.requests.cpu | string | `"200m"` |  |
| loki.backend.resources.requests.memory | string | `"1Gi"` |  |
| loki.chunksCache | object | `{"enabled":true}` | Caching configuration |
| loki.enabled | bool | `true` |  |
| loki.gateway.autoscaling.enabled | bool | `true` |  |
| loki.gateway.autoscaling.minReplicas | int | `2` |  |
| loki.gateway.autoscaling.targetCPUUtilizationPercentage | int | `90` |  |
| loki.gateway.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"seccompProfile":{"type":"RuntimeDefault"}}` | The SecurityContext for gateway containers |
| loki.gateway.deploymentStrategy.rollingUpdate.maxSurge | int | `0` |  |
| loki.gateway.deploymentStrategy.rollingUpdate.maxUnavailable | int | `1` |  |
| loki.gateway.deploymentStrategy.type | string | `"RollingUpdate"` |  |
| loki.gateway.extraContainers[0].args[0] | string | `"--listen"` |  |
| loki.gateway.extraContainers[0].args[1] | string | `"127.0.0.1:8053"` |  |
| loki.gateway.extraContainers[0].args[2] | string | `"--hostsfile=/etc/hosts"` |  |
| loki.gateway.extraContainers[0].args[3] | string | `"--enable-search"` |  |
| loki.gateway.extraContainers[0].args[4] | string | `"--verbose"` |  |
| loki.gateway.extraContainers[0].image | string | `"gsoci.azurecr.io/giantswarm/go-dnsmasq:release-1.0.7"` |  |
| loki.gateway.extraContainers[0].imagePullPolicy | string | `"IfNotPresent"` |  |
| loki.gateway.extraContainers[0].name | string | `"dnsmasq"` |  |
| loki.gateway.extraContainers[0].resources.limits.memory | string | `"100Mi"` |  |
| loki.gateway.extraContainers[0].resources.requests.cpu | string | `"10m"` |  |
| loki.gateway.extraContainers[0].resources.requests.memory | string | `"10Mi"` |  |
| loki.gateway.extraContainers[0].securityContext.allowPrivilegeEscalation | bool | `false` |  |
| loki.gateway.extraContainers[0].securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| loki.gateway.extraContainers[0].securityContext.readOnlyRootFilesystem | bool | `true` |  |
| loki.gateway.extraContainers[0].securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| loki.gateway.image.repository | string | `"giantswarm/nginx-unprivileged"` |  |
| loki.gateway.nginxConfig.resolver | string | `"127.0.0.1:8053 valid=60s"` |  |
| loki.gateway.podSecurityContext | object | `{"fsGroup":101,"runAsGroup":101,"runAsNonRoot":true,"runAsUser":101,"seccompProfile":{"type":"RuntimeDefault"}}` | The SecurityContext for gateway containers |
| loki.gateway.resources.limits.memory | string | `"500Mi"` |  |
| loki.gateway.resources.requests.cpu | string | `"50m"` |  |
| loki.gateway.resources.requests.memory | string | `"50Mi"` |  |
| loki.loki.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"seccompProfile":{"type":"RuntimeDefault"}}` | The SecurityContext for Loki containers |
| loki.loki.image.repository | string | `"giantswarm/loki"` |  |
| loki.loki.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The SecurityContext for Loki pods |
| loki.loki.schemaConfig | object | `{"configs":[{"from":"2024-04-01","index":{"period":"24h","prefix":"index_"},"object_store":"s3","schema":"v13","store":"tsdb"}]}` | Loki Storage schema configuration    Loki 3 requires a schema to be configured so we configure v13, the latest.    Doc is here: https://grafana.com/docs/loki/latest/configure/storage/#schema-config |
| loki.loki.storage | object | `{"bucketNames":{"admin":"admin","chunks":"chunks","ruler":"ruler"}}` | Loki Storage configuration |
| loki.loki.storage.bucketNames | object | `{"admin":"admin","chunks":"chunks","ruler":"ruler"}` | - Loki requires a bucket for chunks and the ruler. TODO(user): Please provide these values if you are using object storage. |
| loki.lokiCanary | object | `{"enabled":false}` | Canary configuration |
| loki.monitoring | object | `{"alerts":{"enabled":false},"dashboards":{"enabled":false},"rules":{"enabled":false},"selfMonitoring":{"enabled":false,"grafanaAgent":{"installOperator":false}},"serviceMonitor":{"enabled":true}}` | Configuration of monitoring components |
| loki.networkPolicy | object | `{"egressKubeApiserver":{"enabled":true},"egressWorld":{"enabled":true},"enabled":true,"flavor":"cilium"}` | Configuration of Loki's network policy |
| loki.networkPolicy.egressKubeApiserver.enabled | bool | `true` | Enable additional cilium egress rules to kube-apiserver for backend. |
| loki.networkPolicy.egressWorld.enabled | bool | `true` | Enable additional cilium egress rules to external world for write, read and backend. |
| loki.rbac.pspAnnotations."seccomp.security.alpha.kubernetes.io/allowedProfileNames" | string | `"*"` |  |
| loki.rbac.pspEnabled | bool | `true` |  |
| loki.read.autoscaling.enabled | bool | `true` |  |
| loki.read.autoscaling.minReplicas | int | `2` |  |
| loki.read.autoscaling.targetCPUUtilizationPercentage | int | `90` |  |
| loki.read.extraArgs[0] | string | `"-querier.multi-tenant-queries-enabled"` |  |
| loki.read.resources.limits.memory | string | `"3Gi"` |  |
| loki.read.resources.requests.cpu | string | `"200m"` |  |
| loki.read.resources.requests.memory | string | `"1Gi"` |  |
| loki.resultsCache.enabled | bool | `true` |  |
| loki.serviceAccount | object | `{"annotations":{},"automountServiceAccountToken":true,"create":true,"imagePullSecrets":[],"labels":{},"name":"loki"}` | Configuration of Loki's service account |
| loki.serviceAccount.annotations | object | `{}` | Annotations for the service account |
| loki.serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| loki.serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| loki.serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the service account |
| loki.serviceAccount.labels | object | `{}` | Labels for the service account |
| loki.serviceAccount.name | string | `"loki"` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template |
| loki.sidecar.image.repository | string | `"gsoci.azurecr.io/giantswarm/k8s-sidecar"` |  |
| loki.sidecar.resources.limits.cpu | string | `"100m"` |  |
| loki.sidecar.resources.limits.memory | string | `"100Mi"` |  |
| loki.sidecar.resources.requests.cpu | string | `"50m"` |  |
| loki.sidecar.resources.requests.memory | string | `"50Mi"` |  |
| loki.sidecar.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| loki.sidecar.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| loki.sidecar.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| loki.sidecar.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| loki.test.enabled | bool | `false` |  |
| loki.write.autoscaling.enabled | bool | `true` |  |
| loki.write.autoscaling.maxReplicas | int | `10` |  |
| loki.write.autoscaling.minReplicas | int | `2` |  |
| loki.write.resources.limits.memory | string | `"4Gi"` |  |
| loki.write.resources.requests.cpu | string | `"500m"` |  |
| loki.write.resources.requests.memory | string | `"3Gi"` |  |


