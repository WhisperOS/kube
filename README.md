# Containerized Highly Available Kubernetes

Best practices for Kubernetes deployments.

Feel free to check out the docker hub [org](https://hub.docker.com/u/whisperos)

To build the containers run:

    make REPO="$PRIVATE_REPO_URI"

See the docs for an [architectural overview](https://github.com/WhisperOS/kubes/tree/master/docs)

And the associated [Static Pod Manifests](https://github.com/WhisperOS/kubes/blob/master/docs/kubeconfigs/manifest.yml)

## VERSIONS

  - Kubernetes: 1.13.0
  - Etcd:       3.3.10
  - Keepalived: 2.0.10
  - Haproxy:    1.8.14
  - Strongswan: 5.7.1
  - Frr:        6.0
