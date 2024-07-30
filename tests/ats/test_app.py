import logging
from typing import List, Tuple

import pytest
import pykube
from pytest_helm_charts.clusters import Cluster
from pytest_helm_charts.k8s.deployment import wait_for_deployments_to_run
from pytest_helm_charts.k8s.stateful_set import wait_for_stateful_sets_to_run


logger = logging.getLogger(__name__)

namespace_name = "loki"
write_sts_name = "loki-write"
backend_sts_name = "loki-backend"
read_deployment_name = "loki-read"
gateway_deployment_name = "loki-gateway"

timeout: int = 560

@pytest.mark.smoke
def test_api_working(kube_cluster: Cluster) -> None:
    """Very minimalistic example of using the [kube_cluster](pytest_helm_charts.fixtures.kube_cluster)
    fixture to get an instance of [Cluster](pytest_helm_charts.clusters.Cluster) under test
    and access its [kube_client](pytest_helm_charts.clusters.Cluster.kube_client) property
    to get access to Kubernetes API of cluster under test.
    Please refer to [pykube](https://pykube.readthedocs.io/en/latest/api/pykube.html) to get docs
    for [HTTPClient](https://pykube.readthedocs.io/en/latest/api/pykube.html#pykube.http.HTTPClient).
    """
    assert kube_cluster.kube_client is not None
    assert len(pykube.Node.objects(kube_cluster.kube_client)) >= 1

# scope "module" means this is run only once, for the first test case requesting! It might be tricky
# if you want to assert this multiple times
@pytest.fixture(scope="module")
def ic_components(kube_cluster: Cluster) -> Tuple[List[pykube.Deployment], List[pykube.StatefulSet]]:
    logger.info("Waiting for loki components to be deployed..")

    components_ready = wait_for_ic_components(kube_cluster)

    logger.info("loki components are deployed..")

    return components_ready

def wait_for_ic_components(kube_cluster: Cluster) -> Tuple[List[pykube.Deployment], List[pykube.StatefulSet]]:
    deployments = wait_for_deployments_to_run(
        kube_cluster.kube_client,
        [read_deployment_name, gateway_deployment_name],
        namespace_name,
        timeout,
    )
    statefulsets = wait_for_stateful_sets_to_run(
        kube_cluster.kube_client,
        [write_sts_name, backend_sts_name],
        namespace_name,
        timeout,
    )
    return (deployments, statefulsets)

@pytest.fixture(scope="module")
def pods(kube_cluster: Cluster) -> List[pykube.Pod]:
    pods = pykube.Pod.objects(kube_cluster.kube_client)

    pods = pods.filter(namespace=namespace_name, selector={
                       'app.kubernetes.io/name': 'loki', 'app.kubernetes.io/instance': 'loki'})

    return pods

# when we start the tests on circleci, we have to wait for pods to be available, hence
# this additional delay and retries

@pytest.mark.smoke
@pytest.mark.upgrade
@pytest.mark.flaky(reruns=5, reruns_delay=10)
def test_pods_available(ic_components: Tuple[List[pykube.Deployment], List[pykube.StatefulSet]]):
    # loop over the list of deployments
    for d in ic_components[0]:
        assert int(d.obj["status"]["readyReplicas"]) == int(d.obj["spec"]["replicas"])

    # loop over the list of statefulsets
    for s in ic_components[1]:
        assert int(s.obj["status"]["readyReplicas"]) == int(s.obj["spec"]["replicas"])

# when we start the tests on circleci, we have to wait for pods to be available, hence
# this additional delay and retries
