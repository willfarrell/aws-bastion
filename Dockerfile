# Use official when supported - https://github.com/aws/amazon-ssm-agent/issues/135
FROM --platform=linux/arm64/v8 amazonlinux:2023

WORKDIR /

RUN yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm

COPY ./seelog.xml.template /etc/amazon/ssm/
COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
