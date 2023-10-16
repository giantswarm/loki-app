# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Added caching with `memcached` for query results.

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

### Changed

- Documentation minor updates and fixes
- Documentation: how to test your Loki deployment

## [0.3.2] - 2022-03-09

### Fixed

- Increase ingester probe initialDelay to 300 seconds

## [0.3.3] - 2021-11-04

- Update app metadata

## [0.3.2] - 2021-10-22

- Update app metadata

## [0.3.3] - 2021-10-15

- Same as v0.3.2, repeated because of CI issues

## [0.3.2] - 2021-10-15

### Changed

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

[Unreleased]: https://github.com/giantswarm/loki-app/compare/v0.12.4...HEAD
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
[0.3.2]: https://github.com/giantswarm/loki-app/compare/v0.3.3...v0.3.2
[0.3.3]: https://github.com/giantswarm/loki-app/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/giantswarm/loki-app/compare/v0.3.3...v0.3.2
[0.3.3]: https://github.com/giantswarm/loki-app/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/giantswarm/loki-app/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/giantswarm/loki-app/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/loki-app/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/giantswarm/loki-app/compare/v0.1.2-beta...v0.2.0
[0.1.2-beta]: https://github.com/giantswarm/loki-app/compare/v0.1.1-alpha2...v0.1.2-beta
[0.1.1-alpha2]: https://github.com/giantswarm/loki-app/compare/v0.1.1-alpha...v0.1.1-alpha2
[0.1.1-alpha]: https://github.com/giantswarm/loki-app/compare/v0.1.0-alpha...v0.1.1-alpha
[0.1.0-alpha]: https://github.com/giantswarm/loki-app/compare/v0.1.0...v0.1.0-alpha
[0.1.0]: https://github.com/giantswarm/loki-app/releases/tag/v0.1.0
