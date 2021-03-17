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

            # multi-tenant on
        """))

        kubectl_n("create", input=yaml.safe_dump_all(app_template(**app_data)), output=None)
        LOGGER.info(f"App resource {app_name} created")

        # # client
        # wait_for_rollout(kubectl_n, f"deployment/{app_name}-opendistro-es-client")
        # LOGGER.info(f"deployment/{app_name}-opendistro-es-client is ready")

        # # data
        # wait_for_rollout(kubectl_n, f"statefulset/{app_name}-opendistro-es-data")
        # LOGGER.info(f"statefulset/{app_name}-opendistro-es-data is ready")

        # # master
        # wait_for_rollout(kubectl_n, f"statefulset/{app_name}-opendistro-es-master")
        # LOGGER.info(f"statefulset/{app_name}-opendistro-es-master is ready")

        # # shortcut to the opendistro-es-client service
        # forward_to_es = partial(
        #     forward_requests,
        #     kubernetes_cluster,
        #     namespace=app_destination_namespace,
        #     # forward_to=f"service/{app_name}-opendistro-es-client-service",
        #     forward_to="service/opendistro-es-client-service",
        #     port=9200,
        #     auth=("admin", "admin")
        # )

        # # wait for es cluster becoming "green"
        # while True:
        #     es_health = forward_to_es(rel_url="/_cluster/health")
        #     LOGGER.info(f"es_health: {es_health}")

        #     if es_health and "status" in es_health and es_health["status"] == "green":
        #         break
        #     time.sleep(5)
