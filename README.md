# aws-bastion

Fargate container and script to trigger a bastion. Only runs when needed.

## Features

- no ssh needed
- auto fallback to trigger sso login
- only runs when needed (1min interval)
- Connect to multiple env at once

## Prerequisites

- Get access to AWS console
- Install AWS CLI v2 by following the steps in this [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Install AWS CLI Session Manager plugin [AWS Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

## Setup

1. Setup ECS Task definition (see task-definition.json & task-iam.json)
2. Copy aws-bastion.sh where you need it.
3. Setup and alias for easy running

```zshrc
function rds-dev {
  ./aws-bastion.sh --region ca-central-1 --profile ORG-development \
   --cluster operations --task-definition ops-bastion \
   --network-configuration '{"awsvpcConfiguration":{"subnets":["subnet-***private***","subnet-***private***"],"securityGroups":["sg-***singleuse***"]}}' \
   --local-port 5432 --remote-port 9999 --remote-host datastream-serverless-aurora-postgresql.cluster-*******.ca-central-1.rds.amazonaws.com
}
alias rds-dev=rds-dev
```

## Run

```bash
rds-dev
```

## TODO

- Pass [Security Hub ECS.5 | ECS containers should be limited to read-only access to root filesystems](https://github.com/aws/amazon-ssm-agent/issues/588)
- Allow picking of sg using name
- Allow picking of subnets using name
- Ability to auto-disconnect when when container closes unexpectedly
