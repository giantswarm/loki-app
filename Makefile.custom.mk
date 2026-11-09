##@ Chart tests

# The unit tests render the upstream loki subchart, which is gitignored under
# helm/loki/charts/. Fetch it before `helm-test` runs. `helm dependency update`
# needs no `helm repo add`, unlike `helm dependency build`.
helm-test: helm-dependency-update

.PHONY: helm-dependency-update
helm-dependency-update: ## Fetch the chart dependencies.
	helm dependency update helm/loki
