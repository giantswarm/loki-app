##@ Chart tests

# The unit tests render the upstream loki subchart, which is gitignored under
# helm/loki/charts/. Fetch it from Chart.lock before `helm-test` runs.
helm-test: helm-dependency-build

.PHONY: helm-dependency-build
helm-dependency-build: ## Fetch the chart dependencies pinned in Chart.lock.
	helm dependency build helm/loki
