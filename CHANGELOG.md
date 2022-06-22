# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/giantswarm/loki-app/compare/v0.4.0...HEAD
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
