# Knative

This example shows how to setup and manage eventing using Terraform by directly
managing Knative resources. The gcloud CLI is still used in some places for convenience. See [Knative-GCP](https://github.com/google/knative-gcp) for more detailed setup instructions.

This actuates the following resources:

* A GKE cluster named `events-example-cluster-knative` with eventing installed.
* A Pub/Sub topic named `test-topic-knative`.
* An event-display service in the namespace `default`.
* A Broker named `default` in the namespace `default`.
* A CloudPubSubSource named `default` in the namespace `default`, sourcing messages from the topic `test-topic-knative` and sinking messages to the Broker `default`.
* A Trigger named `default` in the namespace `default`, filtering Pub/Sub messages, and sinking them to the event-display service.

## Instructions

In order to run this, first initialize Terraform:

```shell
terraform init
```

Due to a bug in [terraform-provider-kubernetes-alpha](https://github.com/hashicorp/terraform-provider-kubernetes-alpha), eventing must be initialized in a separate step before the Kubernetes manifests are applied:

```shell
terraform apply -target=null_resource.events_init
```

Then, apply the rest of the configuration:

```shell
terraform apply
```

Now, to verify that eventing is working properly, publish a message to the Pub/Sub topic:

```shell
gcloud pubsub topics publish test-topic-knative --message='Hello world!'
```

Observe it through the event-display service:
```shell
kubectl logs -l role=event-display -c user-container
```
