# aws-bastion

Fargate container and script to trigger a bastion. Only runs when needed.

1. Setup ECS Task definition (see task-definition.json & task-iam.json)
2. Copy aws-bastion.sh where you need it.
3. Setup and alias for easy running

```
function rds-dev {
  ./aws-bastion.sh --region ca-central-1 --profile ORG-development \
   --cluster operations --task-definition ops-bastion \
   --network-configuration '{"awsvpcConfiguration":{"subnets":["subnet-***private***","subnet-***private***"],"securityGroups":["sg-***singleuse***"]}}' \
   --local-port 5432 --remote-port 9999 --remote-host datastream-serverless-aurora-postgresql.cluster-*******.ca-central-1.rds.amazonaws.com
}
alias rds-dev=rds-dev
```

## Features

- no ssh needed
- only runs when needed (1min interval)
- Connect to env at once

## TODO

- Setup SSM Agent logs to go to CloudWatch properly
- Allow picking of sg using name
- Allow picking of subnets using name
- Ability to disconnect when when container closes
