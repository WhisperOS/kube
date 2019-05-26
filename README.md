# Containerized Highly Available Kubernetes

Best practices for Kubernetes deployments.

Feel free to check out the docker hub [org](https://hub.docker.com/u/whisperos)

To build the containers run:

    make REPO="$PRIVATE_REPO_URI"

See the docs for an [architectural overview](https://github.com/WhisperOS/kubes/tree/master/docs)

And the associated [Static Pod Manifests](https://github.com/WhisperOS/kubes/blob/master/docs/kubeconfigs/manifest.yml)

## VERSIONS

  - Kubernetes: 1.14.2
  - Etcd:       3.3.13
  - Keepalived: 2.0.16
  - Haproxy:    1.9.7
  - Strongswan: 5.7.2
  - IPtables:   1.8.2
  - Alpine:     3.9.3
  - Go:         1.12.5
