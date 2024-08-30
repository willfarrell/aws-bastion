#!/usr/bin/env bash
set -e

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case ${1} in
        --region)
        AWS_REGION="${2}"
        shift # past argument
        shift # past value
        ;;
        --profile)
        AWS_PROFILE="${2}"
        shift # past argument
        shift # past value
        ;;
        --cluster)
        CLUSTER="${2}"
        shift # past argument
        shift # past value
        ;;
        --task-definition)
        TASK_DEFINITION="${2}"
        shift # past argument
        shift # past value
        ;;
        --network-configuration)
        NETWORK_CONFIGURATION="${2}"
        shift # past argument
        shift # past value
        ;;
        --local-port)
        LOCAL_PORT="${2}"
        shift # past argument
        shift # past value
        ;;
        --remote-port)
        REMOTE_PORT="${2}"
        shift # past argument
        shift # past value
        ;;
        --remote-host)
        REMOTE_HOST="${2}"
        shift # past argument
        shift # past value
        ;;
        
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

AWS_REGION=${AWS_REGION:-${AWS_DEFAULT_REGION}}
AWS_PROFILE=${AWS_PROFILE:-${AWS_DEFAULT_PROFILE}}

if [ -z "${CLUSTER}" ]; then
  # Ref: https://awscli.amazonaws.com/v2/documentation/api/2.1.30/reference/ecs/run-task.html
  echo "--cluster required. The short name or full Amazon Resource Name (ARN) of the cluster on which to run your task. If you do not specify a cluster, the default cluster is assumed.";
  exit 1;
fi

if [ -z "${TASK_DEFINITION}" ]; then
  # Ref: https://awscli.amazonaws.com/v2/documentation/api/2.1.30/reference/ecs/run-task.html
  echo "--service-name or --task-definition required.";
  exit 1;
fi

if [ -z "${NETWORK_CONFIGURATION}" ]; then
  # Ref: https://awscli.amazonaws.com/v2/documentation/api/2.1.30/reference/ecs/run-task.html
  echo "--network-configuration required. The network configuration for the task. This parameter is required for task definitions that use the awsvpc network mode to receive their own elastic network interface, and it is not supported for other network modes.";
  exit 1;
fi

if [ -z "${LOCAL_PORT}" ]; then
  # Ref: https://awscli.amazonaws.com/v2/documentation/api/2.1.30/reference/ecs/run-task.html
  echo "--local-port required. Port to be forwarded";
  exit 1;
fi

if [ -z "${REMOTE_PORT}" ]; then
  # Ref: https://awscli.amazonaws.com/v2/documentation/api/2.1.30/reference/ecs/run-task.html
  echo "--remote-port required. Port to be proxyed to";
  exit 1;
fi

if [ -z "${REMOTE_HOST}" ]; then
  # Ref: https://awscli.amazonaws.com/v2/documentation/api/2.1.30/reference/ecs/run-task.html
  echo "--remote-host required. Where port should be proxyed to";
  exit 1;
fi

# Check if already running
TASK_ARN=$(aws ecs list-tasks \
  --profile ${AWS_PROFILE} --region ${AWS_REGION} \
  --cluster ${CLUSTER} --family ${TASK_DEFINITION} \
  --query 'taskArns[0]' --output text || echo "")

if [ "${TASK_ARN}" == "" ] || [ "${TASK_ARN}" == "None" ]; then
  TASK_ARN=$(aws ecs run-task --profile ${AWS_PROFILE} --region ${AWS_REGION} \
    --task-definition ${TASK_DEFINITION} --cluster ${CLUSTER} --launch-type FARGATE \
    --network-configuration ${NETWORK_CONFIGURATION} --enable-execute-command \
    --query 'tasks[0].taskArn' --output text)
  echo -n "Starting up bastion "
else
  echo -n "Checking on bastion "
fi

while [ "${INSTANCE_ID}" == "" ] || [ "${INSTANCE_ID}" == "None" ]; do
  INSTANCE_ID=$(aws ecs describe-tasks --profile ${AWS_PROFILE} --region ${AWS_REGION} \
    --cluster ${CLUSTER} --tasks ${TASK_ARN} \
    --query 'tasks[0].containers[0].runtimeId' --output text || echo "")
  if [ "${INSTANCE_ID}" == "" ] || [ "${INSTANCE_ID}" == "None" ]; then
    echo -n "."
    sleep 10
  else
    echo " Ready!"
  fi
done

aws ssm start-session --profile ${AWS_PROFILE} --region ${AWS_REGION} \
  --target ecs:${CLUSTER}_${INSTANCE_ID:0:32}_${INSTANCE_ID} \
  --document-name "AWS-StartPortForwardingSessionToRemoteHost" \
  --parameters portNumber=${REMOTE_PORT},localPortNumber=${LOCAL_PORT},host=${REMOTE_HOST}







