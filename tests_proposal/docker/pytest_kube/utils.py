import yaml
import json
from textwrap import dedent, indent
import time
import requests

import logging
LOGGER = logging.getLogger(__name__)


# FIXME
# wait_for_response?

def forward_requests(kubernetes_cluster, namespace, forward_to, port, rel_url="", retries=3, **kwargs):
    method = "POST" if "json" in kwargs else "GET"

    while retries:
        try:
            with kubernetes_cluster.port_forward(forward_to, port, namespace=namespace, retries=1) as f_port:
                res = requests.request(method, f"http://localhost:{f_port}{rel_url}", **kwargs)
                res.raise_for_status()
                try:
                    return res.json()
                except json.decoder.JSONDecodeError:
                    return res.text

        except OSError as e:
            LOGGER.warning(f"ConnectionError: {repr(e)}")
            # reraise if out of retries
            if e and retries == 0:
                raise e
        except Exception as e:
            LOGGER.warning(repr(e))
            # reraise if out of retries
            if e and retries == 0:
                raise e

        retries -= 1
        LOGGER.info(f"retries left: {retries}")


# FIXME also allow selector instead of name?
def wait_for_rollout(kubectl_fn, name, **kwargs):
    while True:
        try:
            if len(kubectl_fn(f"get {name}", **kwargs)) > 0:
                kubectl_fn(f"rollout status {name}", **kwargs, output=None)
                LOGGER.info(f"{name} is ready")
                return 
        except Exception as e:
            # FIXME following message is probably on stderr
            # Error from server (NotFound): deployments.apps "aqua-app-server-eaofv-console" not found
            if not repr(e).startswith("Error from server (NotFound)"):
                LOGGER.error(repr(e))
        time.sleep(5)


def app_template(name, name_in_catalog, catalog, version, namespace, values_for_configmap=None, 
                 values_for_secret=None, app_resource_namespace=None):

    # app_name = name
    # app_version = version

    app_destination_namespace = namespace
    if not app_resource_namespace:
        app_resource_namespace = app_destination_namespace

    manifests = []

    app_manifest = yaml.safe_load(dedent(f"""
      apiVersion: application.giantswarm.io/v1alpha1
      kind: App
      metadata:
        labels:
          app-operator.giantswarm.io/version: 0.0.0
        name: {name}
        namespace: {app_resource_namespace}
      spec:
        catalog: {catalog}
        name: {name_in_catalog}
        namespace: {app_destination_namespace}
        version: {version}
        # userConfig:
        #   configMap: 
        #     name: {name}-userconfig
        #     namespace: {app_resource_namespace}
        #   secret: 
        #     name: {name}-usersecret
        #     namespace: {app_resource_namespace}
        kubeConfig:
          inCluster: true
    """))

    manifests.append(app_manifest)

    if values_for_configmap:
        if "userConfig" not in app_manifest["spec"]:
            app_manifest["spec"]["userConfig"] = {}    

        app_manifest["spec"]["userConfig"]["configMap"] = {
            "name": f"{name}-userconfig",
            "namespace": f"{app_resource_namespace}"
        }

        app_configmap_manifest = yaml.safe_load(dedent(f"""
            apiVersion: v1
            kind: ConfigMap
            metadata:
              name: {name}-userconfig
              namespace: {app_resource_namespace}
            data:
              values: ""
        """))

        app_configmap_manifest["data"]["values"] = yaml.safe_dump(values_for_configmap)
        manifests.append(app_configmap_manifest)

    # if values_for_secret:
    #     if "secret" not in app_manifest["spec"]:
    #         app_manifest["spec"]["secret"] = {}    

    #     app_manifest["spec"]["secret"]["configMap"] = {
    #         "name": f"{name}-secret",
    #         "namespace": f"{app_resource_namespace}"
    #     }

    #     app_secret_manifest = yaml.safe_load(dedent(f"""
    #         apiVersion: v1
    #         kind: Secret
    #         metadata:
    #           name: {name}-secret
    #           namespace: {app_resource_namespace}
    #         data:
    #           values: ""
    #     """))

    #     # FIXME encode base64
    #     app_secret_manifest["data"]["values"] = yaml.safe_dump(values_for_secret)
    #     manifests.append(app_secret_manifest)

    return manifests
