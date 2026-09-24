# IoT
## Instructions

> [!WARNING]
> These instructions will setup the cluster on your local machine using k3d, so make sure you have docker installed.

Before running the following commands, make sure that you have docker installed and running, and create a `.passwd` file in bonus folder with the ansible vault password.

To create the cluster, run `./cluster create <cluster-name>`.

To delete the cluster, run `./cluster delete <cluster-name>`.