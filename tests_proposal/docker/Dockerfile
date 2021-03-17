FROM python:3.9-slim

RUN apt update && apt install -y --no-install-recommends curl jq docker.io \
  # kubectl
  && curl -L https://storage.googleapis.com/kubernetes-release/release/v1.20.2/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl \
  # apptestctl
  && curl -L https://github.com/giantswarm/apptestctl/releases/download/v0.6.1/apptestctl-v0.6.1-linux-amd64.tar.gz \
    | tar -zx --strip-components=1 --directory=/usr/local/bin apptestctl-v0.6.1-linux-amd64/apptestctl \
  && pip install pip-tools


WORKDIR /pytest-kube

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY pytest_kube ./pytest_kube
COPY setup.py README.md ./
RUN pip install .

WORKDIR /pytest
CMD ["python", "-m", "pytest"]
