# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.33.1] - 2025-10-14

### Changed

- Upgraded upstream chart from 6.39.0 to 6.42.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.33.0] - 2025-10-02

### Removed

- Remove loki canary now that the deployment change is merged upstream.

## [0.32.0] - 2025-10-01

### Changed

- Upgraded upstream chart from 6.29.0 to 6.39.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

### Removed

- Remove `multi tenant proxy` from the loki app because we stopped supporting it.

## [0.31.2] - 2025-09-30

### Added

- Add `CiliumNetworkPolicy` to allow communication between Loki and the Mimir ruler.

### Changed

- Refactor existing CNPs to align them with upstream.

## [0.31.1] - 2025-09-01

### Changed

- Load k8s-sidecar and go-dnsmasq container images from gsoci.azurecr.io by default

## [0.31.0] - 2025-08-11

### Added

- Add `fallback` section to `loki-read` and `loki-gateway` ScaledObject resources templates.

## [0.30.1] - 2025-07-28

### Fixed

- Fix keda cpu and memory triggers by making value a string instead of an int.

## [0.30.0] - 2025-07-28

### Changed

- Make Keda triggers configurable from the values.

## [0.29.2] - 2025-07-10

### Changed

- Change the names of Keda related fields in the values to match mimir upstream.

## [0.29.1] - 2025-07-09

### Changed

- Disable `ScaledObject` resources and enable back hpa for read and gateway components.

## [0.29.0] - 2025-07-09

### Added

- Add `ScaledObject` resources for `loki-read` and `loki-gateway`.

### Changed

- Replace HPA scaling for `loki-read` and `loki-gateway` in favor of Keda

## [0.28.1] - 2025-05-09

### Changed

- Upgraded upstream chart from 6.27.0 to 6.29.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

### Fixed

- ensured `.loki.enabled: false` prevents creating any resource

## [0.28.0] - 2025-02-24

### Changed

- Upgraded upstream chart from 6.25.1 to 6.27.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
  - This upgrades Loki from 3.3.2 to 3.4.2

## [0.27.0] - 2025-02-17

### Changed

- Upgraded upstream chart from 6.19.0 to 6.25.1 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
  - This upgrades Loki from 3.2.0 to 3.3.2
  - Minio chart from 4.0.15 to 5.4.0, upgrading minio from RELEASE.2022-09-17T00-09-45Z to RELEASE.2024-12-18T13-15-44Z
    - => beware, this is a huge step, please carefully test the upgrade if you're using MinIO!
  - grafana-agent-operator from 0.3.15 to 0.5.1
  - rollout_operator from 0.13.0 to 0.23.0

## [0.26.0] - 2024-10-17

### Changed

- Upgraded upstream chart from 6.16.0 to 6.18.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
  - This upgrades Loki from 3.1.0 to 3.2.0.

## [0.25.2] - 2024-10-09

### Fixed

- Fix circleci config.

## [0.25.1] - 2024-10-08

### Changed

- Upgraded upstream chart from 6.12.0 to 6.16.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.25.0] - 2024-09-26

### Added

- Support for canary deploymnent

### Changed

- Upgraded upstream chart from 6.10.0 to 6.12.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.24.0] - 2024-09-24

### Added

- Add "manual e2e" testing procedure.
- Add PR message template referring to the manual testing procedure.

## [0.23.0] - 2024-09-10

### Added

- Add helm chart templating test in ci pipeline.
- Add tests with ats in ci pipeline.

## [0.22.0] - 2024-08-12

### Changed

- Upgraded upstream chart from 6.7.4 to 6.10.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.21.0] - 2024-07-18

### Changed

- Upgraded upstream chart from 6.6.4 to 6.7.1 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
  - Upgrade loki from 3.0.0 to 3.1.0

## [0.20.2] - 2024-06-27

### Changed

- Upgraded upstream chart from 6.5.2 to 6.6.4 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.20.1] - 2024-06-12

### Changed

- Updated HPAs in the values so that it also takes into account memory for scaling the pods.

## [0.20.0] - 2024-06-03

- Upgraded upstream chart from 5.47.2 to 6.5.2 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information. This upgrades Loki from Loki 2.9.6 to Loki 3.0.0 which brings along a lot of breaking changes. Please check the following links before upgrading:
  - Upgrading from Loki 2.9 to Loki 3: https://grafana.com/docs/loki/latest/setup/upgrade/#300
  - Upgraded upstream chart from 5.x to 6.x: https://grafana.com/docs/loki/latest/setup/upgrade/upgrade-to-6x/

## [0.19.2] - 2024-05-27

### Changed

- Upgraded upstream chart from 5.47.2 to 5.48.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.19.1] - 2024-04-09

### Changed

- Updated the coredns cilium networpolicy to allow egress traffic to `k8s-dns-node-cache` pods.

## [0.19.0] - 2024-04-03

### Added

- Add CiliumNetworkPolicy for Acme challenge.

### Changed

- Upgraded upstream chart from 5.43.6 to 5.47.2 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
  - Upgrade loki from 2.9.4 to 2.9.6. 

## [0.18.2] - 2024-03-07

### Changed

- Upgraded upstream chart from 5.43.5 to 5.43.6 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.18.1] - 2024-03-06

### Changed

- Upgraded upstream chart from 5.43.4 to 5.43.5 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.18.0] - 2024-03-05

### Changed

- Upgraded upstream chart from 5.43.1 to 5.43.4 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Remove custom CNPs and use upstream ones instead.

## [0.17.1] - 2024-02-29

### Changed

- use new multi-tenant-proxy, named `grafana-multi-tenant-proxy`

## [0.17.0] - 2024-02-26

### Changed

- Enable ciliumNetworkPolicies by default. If your cluster does not support cilium, disable this in the values or postpone the upgrade until cilium is installed.

### Fixed

- Helm chart generation when loki is disabled and CNPs are enabled

## [0.16.2] - 2024-02-22

### Fixed

- Fix read pods by adding another CNP to allow those egress access to world.

## [0.16.1] - 2024-02-21

### Added

- Add additional ciliumNetworkPolicies for backend and write pods.

## [0.16.0] - 2024-02-19

### Added

- Auto reload multi-tenant-proxy config when it changes.
- Upgraded upstream chart from 5.43.1 to 5.43.2 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

### Fixed

- Fix multi-tenant-proxy labels to be able to use the ciliumnetworkpolicies and to align with the other components.

## [0.15.3] - 2024-02-15

### Added

- Add coredns egress networkpolicy.
- Upgraded upstream chart from 5.42.3 to 5.43.1 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.15.2] - 2024-02-14

### Changed

- Upgraded upstream chart from 5.42.2 to 5.42.3 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information to fix an issue with network policies.

## [0.15.1] - 2024-02-12

### Changed

- Upgraded loki from 2.9.3 to 2.9.4 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.
- Upgraded upstream chart from 5.41.8 to 5.42.2 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.15.0] - 2024-02-08

### Changed

- Upgraded upstream chart from 5.41.4 to 5.41.8 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Add environment variables to loki-multi-tenant-proxy (OAUTH_URL).
- Bump loki-multi-tenant-proxy to 0.3.0.

## [0.14.11] - 2024-01-22

### Added

- Deploy on CAPV.

## [0.14.10] - 2024-01-15

### Fixed

- Fix loki installation app installation failing when loki is disabled.

## [0.14.9] - 2024-01-15

### Added

- Add MinIO's `ciliumnetworkpolicy` and `networkpolicy` templates.
- Add sample values for EKS testing.
- Add doc in README on deploying Loki for testing only on a new cluster.

## [0.14.8] - 2024-01-09

### Changed

- Configure `gsoci.azurecr.io` as the default container image registry.
- Upgraded loki from 2.9.2 to 2.9.3 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.
- Upgraded upstream chart from 5.40.0 to 5.41.4 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.14.7] - 2023-12-12

### Fixed

- Fix requests/limits for sidecar container (fixes backend HPA)
- Add requests/limits for dnsmasq container (fixes gateway HPA)

### Changed

- Upgrade multi-tenant-proxy to use a structured logger and make it a WARN logger by default to only log errors.

## [0.14.6] - 2023-12-11

### Changed

- Upgraded upstream chart from 5.39.0 to 5.40.1 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.14.5] - 2023-12-04

### Changed

- Upgraded upstream chart from 5.37.0 to 5.39.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Moved `serviceAccount` field in the `loki` section in the values.
- push to capz collection
- push to CAPVCD collection

## [0.14.4] - 2023-11-22

### Changed

- Upgraded upstream chart from 5.36.3 to 5.37.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.14.3] - 2023-11-22

### Fixed

- Add securityContext to dnsmasq container in loki-gateway.

## [0.14.2] - 2023-11-21

### Fixed

- Add dnsmasq as extraContainer to loki-gateway.
- Upgraded loki from 2.9.2 to 2.9.3 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.
- Upgraded upstream chart from 5.34.0 to 5.36.3 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.14.1] - 2023-10-31

### Changed

- Deploy to CAPA app collection.

## [0.14.0] - 2023-10-19

### Changed

- Upgraded upstream chart from 5.29.0 to 5.34.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Upgraded loki from 2.9.1 to 2.9.2 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.
- Resource usage improvements (requests and limits, and HPA tuning)
- multi-tenant-proxy: toggle for credentials provisioning
- multi-tenant-proxy: enforce org-id according to the user - can be changed back with `.Values.multiTenantAuth.write.enforceOrgId`

## [0.13.0] - 2023-10-17

### Changed

- Added caching with `memcached` in default values (disabled).
- Added documentation for using cache.

## [0.12.4] - 2023-10-16

### Changed

- Upgraded upstream chart from 5.26.0 to 5.29.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.12.3] - 2023-10-05

### Changed

- Remove custom `giantswarm` service for monitoring in favor of upstream `servicemonitor`
- Moved `imagePullSecrets` to `multiTenantAuth.image.pullSecrets`

### Fixed

- Fix loki-backend sidecar pod security standard violations.

### Changed

- Upgraded upstream chart from 5.23.0 to 5.26.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.12.2] - 2023-09-26

### Changed

- Upgraded upstream chart from 5.22.0 to 5.23.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.12.1] - 2023-09-15

### Changed

- Upgraded upstream chart from 5.20.0 to 5.22.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Upgraded loki from 2.9.0 to 2.9.1 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.

## [0.12.0] - 2023-09-12

### Changed

- Upgraded upstream chart from 5.15.0 to 5.20.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Upgraded loki from 2.8.4 to 2.9.0 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.

### Fixed

- Fix multi-tenant-proxy HPA by setting resources settings in all of the 3 mtproxy containers.

## [0.11.1] - 2023-08-25

### Changed

- Upgraded upstream chart from 5.14.1 to 5.15.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Add PSP annotation to allow all seccomp profiles.

## [0.11.0] - 2023-08-21

### Changed

- Upgraded upstream chart from 5.10.0 to 5.14.1 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Upgraded loki from 2.8.3 to 2.8.4 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.

## [0.10.0] - 2023-08-10

### Changed

- Upgraded upstream chart from 5.6.4 to 5.10.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Upgraded loki from 2.8.2 to 2.8.3 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.

## [0.9.4] - 2023-06-28

### Added

- Add restricted seccomp profile.

## [0.9.3] - 2023-06-13

### Fixed

- Push to control-plane-catalog to fix deployment via collections

## [0.9.2] - 2023-06-13

### Changed

- Upgraded upstream chart from 5.5.0 to 5.6.4 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Gateway HPA defaults to minimum 2 replicas
- Added `.loki.enabled` in values so we can disable Loki by changing the values
- Adjusted resources requests/limits for `read`, `backend` and `gateway` components
- enabled HPA for read, write and backend
- multi-tenant-proxy: homogeneization of deployment labels
- Pushing to AWS collection

## [0.9.1] - 2023-05-17

### Changed

- Added documentation concerning the use of IRSA in README.

## [0.9.0] - 2023-05-15

- tuned requests/limits
- enabled HPA for gateway and loki-multi-tenant proxy

## [0.8.1] - 2023-05-15

### Changed

- Upgraded upstream chart from 5.0.0 to 5.5.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- upgraded Loki from 2.8.0 to 2.8.2 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.
- Loss of compability with Kubernetes <= 1.21
- Switched to 3-targets mode - see [comment in upstream values](https://github.com/grafana/loki/blob/helm-loki-5.1.0/production/helm/loki/values.yaml#L769) for more information

## [0.8.0] - 2023-04-06

### Changed

- Upgraded upstream chart from 4.10.0 to 5.0.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- upgraded Loki from 2.7.5 to 2.8.0 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.

## [0.7.1] - 2023-03-30

## [0.7.0] - 2023-03-07

### Changed

- Upgraded upstream chart from 4.8.0 to 4.10.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- Loki upgraded from 2.7.3 to 2.7.5

### Fixed

- Fix role/PSP mapping

### Changed

-⚠️ [BREAKING] changed the way to setup multi-tenant-proxy:
  - set `loki.gateway.nginxConfig.customReadUrl`, `loki.gateway.nginxConfig.customWriteUrl` and `loki.gateway.nginxConfig.customBackendUrl` if you use the multiTenantProxy. See default values and sample configs to have the right values.
  - For more detailed info, see [upgrade notes](https://github.com/giantswarm/loki-app/blob/master/README.md#from-06x-to-07x)
- Upgraded upstream chart from 4.6.0 to 4.8.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.6.1] - 2023-02-13

### Changed

- Upgraded upstream chart from 4.4.2 to 4.6.0 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- upgraded Loki from 2.7.2 to 2.7.3 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.

## [0.6.0] - 2023-02-06

### Changed

- Upgraded upstream chart from 3.2.1 to 4.4.2 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.
- upgraded Loki from 2.6.1 to 2.7.2 - see [changelog](https://github.com/grafana/loki/blob/main/CHANGELOG.md) for more information.
- ⚠️  [breaking changes](https://github.com/giantswarm/loki-app/blob/master/README.md#from-05x-to-06x)
  - nginx file definition for loki-multi-tenant has moved to a helper template.
- sample configs: updated schema version to v12 (brings performance improvements for S3 - see https://grafana.com/blog/2022/04/11/new-in-grafana-loki-2.5-faster-queries-more-log-sources-so-long-s3-rate-limits-and-more/)
- azure sample values fixed
- doc improvements

## [0.5.3] - 2022-11-28

### Changed

- nothing, the only goal of this release is to actually release to public catalogs

## [0.5.2] - 2022-11-28

### Changed:

- CI: use app-build-suite again
- Push Loki SSD (new chart) to public catalogs

### Fixed

- Chart info: maintainers
- Chart info: icon
- Improve upgrade path from 0.4 to 0.5

## [0.5.1] - 2022-10-25

### Changed

- Upgraded upstream chart from 3.0.7 to 3.2.1 - see [changelog](https://github.com/grafana/loki/blob/main/production/helm/loki/CHANGELOG.md) for more information.

## [0.5.0] - 2022-10-13

### Changed

- Changed upstream chart, from loki-distributed to standard loki (former simple-scalable) - Switching from unsupported community chart to loki-supported *official chart*.
- Upgrade Loki from 2.5.0 to 2.6.1
- ⚠️  Major upgrade, [breaking changes](https://github.com/giantswarm/loki-app/blob/master/README.md#from-04x-to-05x)
  - PVCs change as we switch from distributed (ingester, compactor, distributor...) to simple-scalable (just read and write pods)
  - values structure changes. We rely on a subchart, meaning most of previous setup goes to a `loki` section. See example files for extra info.

### Fixed

- Azure sample config file: storage setup
- Sample config files: placement for compactor

## [0.4.3] - 2022-07-06

### Fixed

- from giantswarm/grafana-helm-charts-upstream: values schema accepts strings in all default-null fields, like "fullnameOverride"

## [0.4.2] - 2022-07-04

### Changed

- Upgrade upstream chart from 0.48.5 to [0.49.0](https://github.com/grafana/helm-charts/releases/tag/loki-distributed-0.49.0)

### Fixed

- Fix schema validation

## [0.4.1] - 2022-06-24

### Fixed

- Set loki `config.auth_enabled` to false by default.

## [0.4.0] - 2022-06-22

## Changed

- Upgrade upstream chart from 0.33.0 to [0.48.5](https://github.com/grafana/helm-charts/releases/tag/loki-distributed-0.48.5)
- Upgrade Loki from 2.2.1 to [2.5.0](https://github.com/grafana/loki/releases/tag/v2.5.0)
- **Breaking**: Upgrade requires manual intervention.

### Changes required in your `values.yaml` file:
- now `ruler`, `distributor` and `queryFrontend` require access to the object storage.
- storage config is more similar to loki config file, and is done on `loki.schemaConfig` and `loki.storageConfig`.
- data format has not changed, so as long as you keep the same schema version and storage setup, you can upgrade/rollback with no data loss.
- feel free to ask us if you need help regarding your specific setup.

### Upgrade procedure
1. create your updated `values.yaml` file.
2. in `happa`, update loki version.
3. in `happa`, replace values with your updated `values.yaml` file.

Notes:
* during upgrade, log histogram can be inconsistent. This only impacts log histogram, and only during upgrade.
* In case of rollback, logs times may be wrong because latest loki version adjusts timestamps.


## [0.3.2] - 2022-06-20

### Fixed

- startup crashloop due to incorrect initialDelay settings.
- Compatibility with Ingress v1 API
- Links in documentation
- Increase ingester probe initialDelay to 300 seconds

### Changed

- Documentation minor updates and fixes
- Documentation: how to test your Loki deployment
- Update icon

## [0.3.1] - 2021-07-26

### Added

- Basic SLI for ingester and querier StatefulSets

## [0.3.0] - 2021-07-09

### Added

- Enable metric scraping
- Prevent running less than three ingester replicas through values schema validation
- Add livenessProbes to all deployments and statefulsets
- Add default requests/limits to resources

## [0.2.0] - 2021-06-08

### Changed

- Upgrade to upstream chart version [0.33.0](https://github.com/grafana/helm-charts/releases/tag/loki-distributed-0.33.0)
- Upgrade loki to version [2.2.1](https://github.com/grafana/loki/releases/tag/v2.2.1)
- Add `loki.existingSecretForConfig` to make it possible to specify an existing secret for loki configuration
- **Breaking**: Upgrades require manual intervention. A change in the `StatefulSet`'s `podManagementPolicy` requires existing pods to be manually deleted. See [this link](https://github.com/giantswarm/loki-app/blob/master/helm/loki/README.md#from-030x-to-0310) for instructions.
- **Breaking**: Configuration path `gateway.nginxConfig` changed to `gateway.nginxConfig.file`.

## [0.1.2-beta] - 2021-03-19

### Added

- Optionally install [loki-multi-tenant-proxy](https://github.com/k8spin/loki-multi-tenant-proxy) to ease multi tenant authentication and authorizaton.

## [0.1.1-alpha2] - 2021-03-15

### Changed

- Change values.yaml to support azure storage
- Upgrade to loki 2.2.0

## [0.1.1-alpha] - 2021-03-04

### Added

- Annotation for routing alerts to team halo

## [0.1.0-alpha] - 2021-01-21

### Changed

- Re-released the App as alpha.

## [0.1.0] - 2021-01-21

### Added

- Initial release of the App.

[Unreleased]: https://github.com/giantswarm/loki-app/compare/v0.33.1...HEAD
[0.33.1]: https://github.com/giantswarm/loki-app/compare/v0.33.0...v0.33.1
[0.33.0]: https://github.com/giantswarm/loki-app/compare/v0.32.0...v0.33.0
[0.32.0]: https://github.com/giantswarm/loki-app/compare/v0.31.2...v0.32.0
[0.31.2]: https://github.com/giantswarm/loki-app/compare/v0.31.1...v0.31.2
[0.31.1]: https://github.com/giantswarm/loki-app/compare/v0.31.0...v0.31.1
[0.31.0]: https://github.com/giantswarm/loki-app/compare/v0.30.1...v0.31.0
[0.30.1]: https://github.com/giantswarm/loki-app/compare/v0.30.0...v0.30.1
[0.30.0]: https://github.com/giantswarm/loki-app/compare/v0.29.2...v0.30.0
[0.29.2]: https://github.com/giantswarm/loki-app/compare/v0.29.1...v0.29.2
[0.29.1]: https://github.com/giantswarm/loki-app/compare/v0.29.0...v0.29.1
[0.29.0]: https://github.com/giantswarm/loki-app/compare/v0.28.1...v0.29.0
[0.28.1]: https://github.com/giantswarm/loki-app/compare/v0.28.0...v0.28.1
[0.28.0]: https://github.com/giantswarm/loki-app/compare/v0.27.0...v0.28.0
[0.27.0]: https://github.com/giantswarm/loki-app/compare/v0.26.0...v0.27.0
[0.26.0]: https://github.com/giantswarm/loki-app/compare/v0.25.2...v0.26.0
[0.25.2]: https://github.com/giantswarm/loki-app/compare/v0.25.1...v0.25.2
[0.25.1]: https://github.com/giantswarm/loki-app/compare/v0.25.0...v0.25.1
[0.25.0]: https://github.com/giantswarm/loki-app/compare/v0.24.0...v0.25.0
[0.24.0]: https://github.com/giantswarm/loki-app/compare/v0.23.0...v0.24.0
[0.23.0]: https://github.com/giantswarm/loki-app/compare/v0.22.0...v0.23.0
[0.22.0]: https://github.com/giantswarm/loki-app/compare/v0.21.0...v0.22.0
[0.21.0]: https://github.com/giantswarm/loki-app/compare/v0.20.2...v0.21.0
[0.20.2]: https://github.com/giantswarm/loki-app/compare/v0.20.1...v0.20.2
[0.20.1]: https://github.com/giantswarm/loki-app/compare/v0.20.0...v0.20.1
[0.20.0]: https://github.com/giantswarm/loki-app/compare/v0.19.2...v0.20.0
[0.19.2]: https://github.com/giantswarm/loki-app/compare/v0.19.1...v0.19.2
[0.19.1]: https://github.com/giantswarm/loki-app/compare/v0.19.0...v0.19.1
[0.19.0]: https://github.com/giantswarm/loki-app/compare/v0.18.2...v0.19.0
[0.18.2]: https://github.com/giantswarm/loki-app/compare/v0.18.1...v0.18.2
[0.18.1]: https://github.com/giantswarm/loki-app/compare/v0.18.0...v0.18.1
[0.18.0]: https://github.com/giantswarm/loki-app/compare/v0.17.1...v0.18.0
[0.17.1]: https://github.com/giantswarm/loki-app/compare/v0.17.0...v0.17.1
[0.17.0]: https://github.com/giantswarm/loki-app/compare/v0.16.2...v0.17.0
[0.16.2]: https://github.com/giantswarm/loki-app/compare/v0.16.1...v0.16.2
[0.16.1]: https://github.com/giantswarm/loki-app/compare/v0.16.0...v0.16.1
[0.16.0]: https://github.com/giantswarm/loki-app/compare/v0.15.3...v0.16.0
[0.15.3]: https://github.com/giantswarm/loki-app/compare/v0.15.2...v0.15.3
[0.15.2]: https://github.com/giantswarm/loki-app/compare/v0.15.1...v0.15.2
[0.15.1]: https://github.com/giantswarm/loki-app/compare/v0.15.0...v0.15.1
[0.15.0]: https://github.com/giantswarm/loki-app/compare/v0.14.11...v0.15.0
[0.14.11]: https://github.com/giantswarm/loki-app/compare/v0.14.10...v0.14.11
[0.14.10]: https://github.com/giantswarm/loki-app/compare/v0.14.9...v0.14.10
[0.14.9]: https://github.com/giantswarm/loki-app/compare/v0.14.8...v0.14.9
[0.14.8]: https://github.com/giantswarm/loki-app/compare/v0.14.7...v0.14.8
[0.14.7]: https://github.com/giantswarm/loki-app/compare/v0.14.6...v0.14.7
[0.14.6]: https://github.com/giantswarm/loki-app/compare/v0.14.5...v0.14.6
[0.14.5]: https://github.com/giantswarm/loki-app/compare/v0.14.4...v0.14.5
[0.14.4]: https://github.com/giantswarm/loki-app/compare/v0.14.3...v0.14.4
[0.14.3]: https://github.com/giantswarm/loki-app/compare/v0.14.2...v0.14.3
[0.14.2]: https://github.com/giantswarm/loki-app/compare/v0.14.1...v0.14.2
[0.14.1]: https://github.com/giantswarm/loki-app/compare/v0.14.0...v0.14.1
[0.14.0]: https://github.com/giantswarm/loki-app/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/giantswarm/loki-app/compare/v0.12.4...v0.13.0
[0.12.4]: https://github.com/giantswarm/loki-app/compare/v0.12.3...v0.12.4
[0.12.3]: https://github.com/giantswarm/loki-app/compare/v0.12.2...v0.12.3
[0.12.2]: https://github.com/giantswarm/loki-app/compare/v0.12.1...v0.12.2
[0.12.1]: https://github.com/giantswarm/loki-app/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/giantswarm/loki-app/compare/v0.11.1...v0.12.0
[0.11.1]: https://github.com/giantswarm/loki-app/compare/v0.11.0...v0.11.1
[0.11.0]: https://github.com/giantswarm/loki-app/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/giantswarm/loki-app/compare/v0.9.4...v0.10.0
[0.9.4]: https://github.com/giantswarm/loki-app/compare/v0.9.3...v0.9.4
[0.9.3]: https://github.com/giantswarm/loki-app/compare/v0.9.2...v0.9.3
[0.9.2]: https://github.com/giantswarm/loki-app/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/giantswarm/loki-app/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/giantswarm/loki-app/compare/v0.8.1...v0.9.0
[0.8.1]: https://github.com/giantswarm/loki-app/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/giantswarm/loki-app/compare/v0.7.1...v0.8.0
[0.7.1]: https://github.com/giantswarm/loki-app/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/giantswarm/loki-app/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/giantswarm/loki-app/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/giantswarm/loki-app/compare/v0.5.3...v0.6.0
[0.5.3]: https://github.com/giantswarm/loki-app/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/giantswarm/loki-app/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/giantswarm/loki-app/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/giantswarm/loki-app/compare/v0.4.3...v0.5.0
[0.4.3]: https://github.com/giantswarm/loki-app/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/giantswarm/loki-app/compare/v0.4.2...v0.4.2
[0.4.2]: https://github.com/giantswarm/loki-app/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/giantswarm/loki-app/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/giantswarm/loki-app/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/giantswarm/loki-app/compare/v0.3.2...v0.3.2
[0.3.1]: https://github.com/giantswarm/loki-app/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/loki-app/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/giantswarm/loki-app/compare/v0.1.2-beta...v0.2.0
[0.1.2-beta]: https://github.com/giantswarm/loki-app/compare/v0.1.1-alpha2...v0.1.2-beta
[0.1.1-alpha2]: https://github.com/giantswarm/loki-app/compare/v0.1.1-alpha...v0.1.1-alpha2
[0.1.1-alpha]: https://github.com/giantswarm/loki-app/compare/v0.1.0-alpha...v0.1.1-alpha
[0.1.0-alpha]: https://github.com/giantswarm/loki-app/compare/v0.1.0...v0.1.0-alpha
[0.1.0]: https://github.com/giantswarm/loki-app/releases/tag/v0.1.0
