# Use official when supported - https://github.com/aws/amazon-ssm-agent/issues/135
FROM --platform=linux/arm64/v8 amazonlinux:2023

WORKDIR /

RUN yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
#RUN dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm

# TODO edit template to save logs to CW https://docs.aws.amazon.com/systems-manager/latest/userguide/monitoring-ssm-agent.html

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
