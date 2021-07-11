from pathlib import Path
import pytest
from .kubernetes_cluster import KubernetesCluster
import random
import string


@pytest.fixture(scope="session")
def kubernetes_cluster(request):
    """Provide a Kubernetes cluster as test fixture"""

    kubeconfig = request.config.getoption("--kubeconfig")
    cluster = KubernetesCluster(kubeconfig)

    kubeconfig = request.config.getoption("--kubeconfig-management")
    cluster.management = None
    if kubeconfig:
        management = KubernetesCluster(kubeconfig)
        cluster.management = management

    return cluster


@pytest.fixture(scope="class")
# @pytest.fixture(scope="function")
def random_namespace(request, kubernetes_cluster):
    kubectl = kubernetes_cluster.kubectl
    name = f"pytest-{''.join(random.choices(string.ascii_lowercase, k=5))}"

    kubectl(f"create namespace {name}")
    yield name

    if not request.config.getoption("keep_namespace"):
        kubectl(f"delete namespace {name}", output=None)


# FIXME provide factory to choose namespace with possible random postfix
# https://docs.pytest.org/en/stable/fixture.html#factories-as-fixtures
#
# @pytest.fixture(scope="class")
# def random_namespace_factory(request, kubernetes_cluster, name, random_postfix=true):
#     pass


def pytest_addoption(parser):
    parser.addoption(
        "--kubeconfig",
        default=None,
        help=(
            "If provided, use the specified kubeconfig "
            "instead of the default one"
        ),
    )

    parser.addoption(
        "--kubeconfig-management",
        default=None,
        help=(
            "If provided, use the specified kubeconfig "
            "to access the management cluster"
        ),
    )

    parser.addoption(
        "--keep-namespace",
        default=None,
        action="store_true",
        help="Keep the pytest namespace (do not delete after test run)",
    )
