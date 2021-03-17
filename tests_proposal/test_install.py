import yaml
from functools import partial
import time
import random
import string
from textwrap import dedent, indent
# from pathlib import Path
# from typing import Optional

from pytest_kube import forward_requests, wait_for_rollout, app_template

import logging
LOGGER = logging.getLogger(__name__)


app_name_suffix = ''.join(random.choices(string.ascii_lowercase, k=5))

# https://docs.pytest.org/en/latest/example/simple.html#incremental-testing-test-steps


# @pytest.mark.usefixtures("kubernetes_cluster", "random_namespace")
class TestInstall:

    # @pytest.mark.skip()
    def test_simple_installation(self, kubernetes_cluster, random_namespace):

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
            "catalog": "giantswarm",
            "version": "0.1.1-alpha2",
            "namespace": app_destination_namespace,
            "app_resource_namespace": app_resource_namespace,
            # "values_for_configmap": {}
        }

        # for convinience read in values in yaml format
        app_data["values_for_configmap"] = yaml.safe_load(dedent(f"""
            global:
              dnsService: "coredns"
            rbac:
              pspEnabled: true
            storage: filesystem

            serviceMonitor:
              enabled: true
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

            gateway:
              replicas: 1
              basicAuth:
                enabled: true
                username: "loki"
                password: "my-brother-is-thor"

            ingester:
              replicas: 1

            querier:
              replicas: 1

            # multi-tenant on
        """))

        kubectl_n("create", input=yaml.safe_dump_all(app_template(**app_data)), output=None)
        LOGGER.info(f"App resource {app_name} created")

        # compactor
        wait_for_rollout(kubectl_n, f"deployment/{app_name}-compactor")
        LOGGER.info(f"deployment/{app_name}-compactor is ready")

        # distributor
        wait_for_rollout(kubectl_n, f"deployment/{app_name}-distributor")
        LOGGER.info(f"deployment/{app_name}-distributor is ready")

        # gateway
        wait_for_rollout(kubectl_n, f"deployment/{app_name}-gateway")
        LOGGER.info(f"deployment/{app_name}-gateway is ready")

        # query-frontend
        wait_for_rollout(kubectl_n, f"deployment/{app_name}-query-frontend")
        LOGGER.info(f"deployment/{app_name}-query-frontend is ready")

        # querier
        wait_for_rollout(kubectl_n, f"statefulset/{app_name}-querier")
        LOGGER.info(f"statefulset/{app_name}-querier is ready")

        # ingester
        wait_for_rollout(kubectl_n, f"statefulset/{app_name}-ingester")
        LOGGER.info(f"statefulset/{app_name}-ingester is ready")


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

        # FIXME test access to ServiceMonitor


    def test_promtail_installation(self, kubernetes_cluster, random_namespace):

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
              enabled: true

            # make promtail print config on start
            extraArgs:
            - -log-config-reverse-order

            # Information about the Loki endpoint to connect to. Currently the chart supports
            # only a single upstream connection.
            config:
              lokiAddress: "http:///loki-{app_name_suffix}-gateway/api/v1/push"
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
                  external_labels:
                    installation: ginger
                    cluster: my-test-promtail
        """))

        kubectl_n("create", input=yaml.safe_dump_all(app_template(**app_data)), output=None)
        LOGGER.info(f"App resource {app_name} created")

        # ingester
        wait_for_rollout(kubectl_n, f"daemonset/{app_name}")
        LOGGER.info(f"statefulset/{app_name} is ready")

        # FIXME test access to ServiceMonitor


    # def test_kube_prometheus_installation(self, kubernetes_cluster, random_namespace):

    #     app_name = f"promtail-{app_name_suffix}"

    #     app_data = {
    #         "name": app_name,
    #         "name_in_catalog": "promtail",
    #         "catalog": "giantswarm",
    #         "version": "0.1.1-alpha3",
    #         "namespace": app_destination_namespace,
    #         "app_resource_namespace": app_resource_namespace,
    #         # "values_for_configmap": {}
    #     }

    #     # for convinience read in values in yaml format
    #     app_data["values_for_configmap"] = yaml.safe_load(dedent(f"""
