#!/bin/bash
# this script is not run ready, only documentation for commands to run

AWS_REGION=eu-west-2

# init broker
BROKER_NAME="celery_autoscale_broker"
BROKER_USER="admin"
BROKER_PASSWORD="123456789012"

BROKER_RESPONSE=$(aws --region "$AWS_REGION" mq create-broker \
    --broker-name $BROKER_NAME \
    --engine-type RABBITMQ \
    --engine-version "3.8.11" \
    --host-instance-type "mq.t3.micro" \
    --deployment-mode SINGLE_INSTANCE \
    --users "[{\"Username\": \"$BROKER_USER\", \"Password\": \"$BROKER_PASSWORD\"}]")

BROKER_ID=$(echo "$BROKER_RESPONSE" | jq ".BrokerId")
BROKER_ARN=$(echo "$BROKER_RESPONSE" | jq ".BrokerArn")

aws --region "$AWS_REGION" mq delete-broker \
    --broker-id "$BROKER_ID"

# init results backend
# TODO write init results backend commands

# init kubernetes cluster
# TODO write init kubernetes cluster commands
