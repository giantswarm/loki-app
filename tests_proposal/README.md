# Testing the charts


```bash
kind create cluster
# or giantswarm tenant

apptestctl bootstrap

# if needed in tests
kubectl create -f ./tests_proposal/appcatalog-giantswarm.yaml


# edit the `Chart.yaml`s in helm with the to be tested version
# for example "0.4.2-test1"

# push dev version to chartmuseum. delete before if it already exists
# [!] the following works in fish-shell. couldn't figure out the
# bash aquivalent yet for the timeout/sleep trick
set app_version "0.4.2-test2"

timeout 5 kubectl -n giantswarm port-forward service/chartmuseum-chartmuseum 8080:8080 & ; sleep 1
set app_name "efk-stack-app"
helm package ./helm/$app_name
curl --request DELETE http://localhost:8080/api/charts/$app_name/$app_version
curl --data-binary "@$app_name-$app_version.tgz" http://localhost:8080/api/charts
curl -sS http://localhost:8080/api/charts | jq '."'"$app_name"'"[] | {name, version}'




docker build -t local/pytest-kube ./tests_proposal/docker

# example for noisy output and keeping the namespace
# with the deployed resources
docker run -ti \
  --network host \
  -v $PWD/tests_proposal:/pytest \
  -v $KUBECONFIG:/root/.kube/config \
  local/pytest-kube python -m pytest -s \
    -o log_cli=true -o log_cli_level=INFO \
      ./test_install.py --keep-namespace


# simple run with removing the namespace in the end
docker run -ti \
  -v $PWD/tests_proposal:/pytest \
  -v $KUBECONFIG:/root/.kube/config \
  local/pytest-kube python -m pytest


# leftovers
kubectl get psp -l app.kubernetes.io/name=fluentd-elasticsearch

```
