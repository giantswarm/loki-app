import yaml
from functools import partial
import time
import random
import string
from textwrap import dedent, indent
# from pathlib import Path
# from typing import Optional

import pytest
from pytest_kube import forward_requests, wait_for_rollout, app_template

import logging
LOGGER = logging.getLogger(__name__)


app_name_suffix = ''.join(random.choices(string.ascii_lowercase, k=5))

# https://docs.pytest.org/en/latest/example/simple.html#incremental-testing-test-steps

# FIXME random_namespace_factory
# prefix and labels

# @pytest.mark.usefixtures("kubernetes_cluster", "random_namespace")
# class TestInstall:

def ensure_appcatalog(kubectl):
    app_catalog = dedent("""
        apiVersion: application.giantswarm.io/v1alpha1
        kind: AppCatalog
        metadata:
          name: giantswarm
          labels:
            app-operator.giantswarm.io/version: 1.0.0
            application.giantswarm.io/catalog-type: stable
            application.giantswarm.io/catalog-visibility: public
        spec:
          title: Giant Swarm Catalog
          description: This catalog holds Apps managed by Giant Swarm.
          logoURL: /images/repo_icons/managed.png
          storage:
            URL: https://giantswarm.github.io/giantswarm-catalog/
            type: helm
    """)

    kubectl("apply", input=app_catalog, output=None)
    LOGGER.info(f"App catalog applied")


@pytest.mark.smoke
def test_simple_installation(kubernetes_cluster, random_namespace, chart_version):

    app_destination_namespace = random_namespace
    app_resource_namespace = app_destination_namespace

    LOGGER.info(f"Destination namespace is [[ {app_destination_namespace} ]]")

    # shortcut function with fixed namespace
    kubectl_n = partial(kubernetes_cluster.kubectl, namespace=app_destination_namespace)

    # create loki

    app_name = f"loki-{app_name_suffix}"
    # app_name = f"loki"

    app_data = {
        "name": app_name,
        "name_in_catalog": "loki",
        "catalog": "chartmuseum",
        "version": chart_version,
        "namespace": app_destination_namespace,
        "app_resource_namespace": app_resource_namespace,
        # "values_for_configmap": {}
    }

    dns_service_name = kubernetes_cluster.kubectl("get service", selector="k8s-app in (coredns, kube-dns)", namespace="kube-system", output="go-template='{{ (index .items 0).metadata.name }}'")
    LOGGER.info(f"Using [[ {dns_service_name} ]] as resolver")

    # for convinience read in values in yaml format
    app_data["values_for_configmap"] = yaml.safe_load(dedent(f"""
        global:
          dnsService: {dns_service_name}
        rbac:
          pspEnabled: true
        storage: filesystem

        _shared_config: &shared-conf
          persistence:
            storageClass: ""

        serviceMonitor:
          enabled: false
          # groups:
          #   - name: loki-rules
          #     rules:
          #       - record: job:loki_request_duration_seconds_bucket:sum_rate
          #         expr: sum(rate(loki_request_duration_seconds_bucket[1m])) by (le, job)
          #       - record: job_route:loki_request_duration_seconds_bucket:sum_rate
          #         expr: sum(rate(loki_request_duration_seconds_bucket[1m])) by (le, job, route)
          #       - record: node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate
          #         expr: sum(rate(container_cpu_usage_seconds_total[1m])) by (node, namespace, pod, container)

        # memcachedExporter:
        #   enabled: true

        distributor:
          replicas: 1

        gateway:
          replicas: 1
          basicAuth:
            enabled: true
            username: "loki"
            password: "my-brother-is-thor"

        ingester:
          <<: *shared-conf
          # at least 2 live replicas required
          replicas: 2

        compactor: *shared-conf

        ruler: *shared-conf

        querier:
          <<: *shared-conf
          replicas: 1

        # multi-tenant on
    """))

    kubectl_n("create", input=yaml.safe_dump_all(app_template(**app_data)), output=None)
    LOGGER.info(f"App resource {app_name} created")

    wait_for_rollout(kubectl_n, f"deployment/{app_name}-compactor")
    wait_for_rollout(kubectl_n, f"deployment/{app_name}-distributor")
    wait_for_rollout(kubectl_n, f"deployment/{app_name}-gateway")
    wait_for_rollout(kubectl_n, f"deployment/{app_name}-query-frontend")
    wait_for_rollout(kubectl_n, f"statefulset/{app_name}-querier")
    wait_for_rollout(kubectl_n, f"statefulset/{app_name}-ingester")

    # service: gateway

    # shortcut to the loki-gateway service
    forward_to_gateway = partial(
        forward_requests,
        kubernetes_cluster,
        namespace=app_destination_namespace,
        forward_to=f"service/{app_name}-gateway",
        port=80,
        # auth=("admin", "admin")
    )

    # wait for gateway becoming "OK"
    while True:
        api_result = forward_to_gateway(rel_url="/")
        LOGGER.info(f"api_result: {api_result}")

        if api_result == "OK":
            break
        time.sleep(5)

    # FIXME test moar api

    # kubectl port-forward -n pytest-bxatt service/loki-drppq-gateway 3100:80
    #
    # curl -s \
    #   --user loki:my-brother-is-thor \
    #   --header "X-Scope-OrgID: 1" \
    #   --get --data-urlencode 'query=sum(rate({job="varlogs"}[10m])) by (level)' \
    #   "http://localhost:3100/loki/api/v1/query" | jq

    # FIXME test access to ServiceMonitor


@pytest.mark.smoke
def test_promtail_installation(kubernetes_cluster, random_namespace):

    ensure_appcatalog(kubernetes_cluster.kubectl)

    app_destination_namespace = random_namespace
    app_resource_namespace = app_destination_namespace

    LOGGER.info(f"Destination namespace is [[ {app_destination_namespace} ]]")

    # shortcut function with fixed namespace
    kubectl_n = partial(kubernetes_cluster.kubectl, namespace=app_destination_namespace)

    app_name = f"promtail-{app_name_suffix}"

    app_data = {
        "name": app_name,
        "name_in_catalog": "promtail",
        "catalog": "giantswarm",
        "version": "0.1.1-alpha3",
        "namespace": app_destination_namespace,
        "app_resource_namespace": app_resource_namespace,
        # "values_for_configmap": {}
    }

    # for convinience read in values in yaml format
    app_data["values_for_configmap"] = yaml.safe_load(dedent(f"""
        rbac:
          create: true
          pspEnabled: true

        serviceMonitor:
          enabled: false

        # make promtail print config on start
        extraArgs:
        - -log-config-reverse-order

        # Information about the Loki endpoint to connect to. Currently the chart supports
        # only a single upstream connection.
        config:
          lokiAddress: "http://loki-{app_name_suffix}-gateway/loki/api/v1/push"
          snippets:
            extraClientConfigs: |
              tenant_id: 1
              # basic auth data
              basic_auth:
                username: loki
                password: my-brother-is-thor
              backoff_config:
                max_period: 10m
              # this set of labels will be added to every log entry forwarded by this promtail
              # instance
              # external_labels:
              #   installation: ginger
              #   cluster: my-test-promtail
    """))

    kubectl_n("create", input=yaml.safe_dump_all(app_template(**app_data)), output=None)
    LOGGER.info(f"App resource {app_name} created")

    # ingester
    wait_for_rollout(kubectl_n, f"daemonset/{app_name}")

    # FIXME test access to ServiceMonitor


@pytest.mark.smoke
def test_kube_prometheus_installation(kubernetes_cluster, random_namespace):

    ensure_appcatalog(kubernetes_cluster.kubectl)

    app_destination_namespace = random_namespace
    app_resource_namespace = app_destination_namespace

    LOGGER.info(f"Destination namespace is [[ {app_destination_namespace} ]]")

    # shortcut function with fixed namespace
    kubectl_n = partial(kubernetes_cluster.kubectl, namespace=app_destination_namespace)

    app_name = f"kube-prometheus-{app_name_suffix}"

    app_data = {
        "name": app_name,
        "name_in_catalog": "prometheus-operator-app",
        "catalog": "giantswarm",
        "version": "0.7.0",
        "namespace": app_destination_namespace,
        "app_resource_namespace": app_resource_namespace,
        # "values_for_configmap": {}
    }

    # for convenience read in values in yaml format
    app_data["values_for_configmap"] = yaml.safe_load(dedent(f"""
      # see https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml

      global:
        rbac:
          create: true
          pspEnabled: true

      kubeStateMetrics:
        enabled: true

      nodeExporter.enabled:
        enabled: true

      grafana.enabled:
        enabled: true

        ## Deploy default dashboards.
        ##
        defaultDashboardsEnabled: true

        adminPassword: prom-operator

        sidecar:
          dashboards:
            enabled: true
            label: grafana_dashboard

          datasources:
            enabled: true
            defaultDatasourceEnabled: true

        ## Configure additional grafana datasources (passed through tpl)
        ## ref: http://docs.grafana.org/administration/provisioning/#datasources
        additionalDataSources:
        # - name: prometheus-sample
        #   access: proxy
        #   basicAuth: true
        #   basicAuthPassword: pass
        #   basicAuthUser: daco
        #   editable: false
        #   jsonData:
        #       tlsSkipVerify: true
        #   orgId: 1
        #   type: prometheus
        #   url: https://{{ printf "%s-prometheus.svc" .Release.Name }}:9090
        #   version: 1

        - name: loki
          type: loki
          access: proxy
          url: http://loki-{app_name_suffix}-gateway
          basicAuth: true
          basicAuthUser: loki
          jsonData:
            httpHeaderName1: 'X-Scope-OrgID'
          secureJsonData:
            basicAuthPassword: my-brother-is-thor
            # FIXME Should this the same as tenant-id for promtail? yes
            httpHeaderValue1: '1'

      prometheusOperator:
        enabled: true

        ## Namespaces to scope the interaction of the Prometheus Operator and the apiserver (allow list).
        ## This is mutually exclusive with denyNamespaces. Setting this to an empty object will disable the configuration
        ##
        namespaces: {{}}
          # releaseNamespace: true
          # additional:
          # - kube-system

        # image:
        #   repository: quay.io/prometheus-operator/prometheus-operator
        #   tag: v0.46.0
        #   sha: ""
        #   pullPolicy: IfNotPresent

        # prometheusConfigReloaderImage:
        #   repository: quay.io/prometheus-operator/prometheus-config-reloader
        #   tag: v0.46.0
        #   sha: ""

      prometheus:
        enabled: true

        prometheusSpec:
          # image:
          #   repository: quay.io/prometheus/prometheus
          #   tag: v2.24.0
          #   sha: ""


          ## ServiceMonitors to be selected for target discovery.
          ## If {{}}, select all ServiceMonitors
          ##
          serviceMonitorSelector: {{}}
          ## Example which selects ServiceMonitors with label "prometheus" set to "somelabel"
          # serviceMonitorSelector:
          #   matchLabels:
          #     prometheus: somelabel

          ## Namespaces to be selected for ServiceMonitor discovery.
          ##
          serviceMonitorNamespaceSelector: {{}}
          ## Example which selects ServiceMonitors in namespaces with label "prometheus" set to "somelabel"
          # serviceMonitorNamespaceSelector:
          #   matchLabels:
          #     prometheus: somelabel


          ## How long to retain metrics
          ##
          retention: 10d

          ## Maximum size of metrics
          ##
          retentionSize: ""
    """))

    kubectl_n("create", input=yaml.safe_dump_all(app_template(**app_data)), output=None)
    LOGGER.info(f"App resource {app_name} created")

    wait_for_rollout(kubectl_n, f"deployment/{app_name}-grafana")
    wait_for_rollout(kubectl_n, f"deployment/{app_name}-kube-state-metrics")
    wait_for_rollout(kubectl_n, f"deployment/{app_name}-prom-operator")
    wait_for_rollout(kubectl_n, f"statefulset/prometheus-{app_name}-prom-prometheus")
    wait_for_rollout(kubectl_n, f"statefulset/alertmanager-{app_name}-prom-alertmanager")
    # wait_for_rollout(kubectl_n, f"daemonset/{app_name}-prometheus-node-exporter")

    # FIXME wait_for more?
    # prometheus-operator-app-crd-install-vnv86?
    # prometheus-operator-app-crd-install-jxd6m
    # ^also this seems to be started several times..

# test if all pod images are from qyuai/giantswarm?
