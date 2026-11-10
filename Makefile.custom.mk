##@ Chart tests

# No recipe on purpose: this line adds a prerequisite to the generated `helm-test`
# target, whose recipe is in Makefile.gen.app.mk. The unit tests render the upstream
# loki subchart, which is gitignored under helm/loki/charts/, so it is fetched first.
# `helm dependency update` needs no `helm repo add`, unlike `helm dependency build`.
# Remove this file once devctl generates the fetch (giantswarm/devctl#3615).
helm-test: helm-dependency-update

.PHONY: helm-dependency-update
helm-dependency-update: ## Fetch the chart dependencies.
	helm dependency update helm/loki
