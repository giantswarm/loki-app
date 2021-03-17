## pytest-kube

```bash
docker build -t local/pytest-kube .
```

```bash
# upgrade all dependencies
docker run \
  -v $PWD:/pytest \
  local/pytest-kube \
    sh -c "rm -f requirements.txt && pip-compile --generate-hashes"
```
