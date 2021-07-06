#!/bin/bash
# this script is not run ready, only documentation for commands to run

AWS_REGION=eu-west-2
PROJECT_TAG="autoscaling_test"  # TODO add tags (project: autoscaling_test) to resources

# create vpc and subnet
VPC_CIDR="10.0.0.0/16"

VPC_RESPONSE=$(aws --region "$AWS_REGION" ec2 create-vpc \
     --cidr-block "$VPC_CIDR"
)

VPC_ID=$(echo "$VPC_RESPONSE" | jq ".Vpc.VpcId")

aws --region "$AWS_REGION" ec2 delete-vpc \
    --vpc-id "$VPC_ID"

SUBNET_CIDR="10.0.0.0/24"

SUBNET_RESPONSE=$(aws --region "$AWS_REGION" ec2 create-subnet \
     --cidr-block "$SUBNET_CIDR" \
     --vpc-id "$VPC_ID"
)

SUBNET_ID=$(echo "$SUBNET_RESPONSE"| jq ".Subnet.SubnetId")

aws --region "$AWS_REGION" ec2 delete-subnet \
    --subnet-id "$SUBNET_ID"

# TODO maybe create subnet group

# init broker
BROKER_NAME="celery_autoscale_broker"
BROKER_USER="admin"
BROKER_PASSWORD="123456789012"

BROKER_RESPONSE=$(aws --region "$AWS_REGION" mq create-broker \
    --broker-name $BROKER_NAME \
    --engine-type RABBITMQ \
    --engine-version "3.8.11" \
    --host-instance-type "mq.t3.micro" \
    --subnet-ids "$SUBNET_ID"\
    --deployment-mode SINGLE_INSTANCE \
    --users "[{\"Username\": \"$BROKER_USER\", \"Password\": \"$BROKER_PASSWORD\"}]")

BROKER_ID=$(echo "$BROKER_RESPONSE" | jq ".BrokerId")
BROKER_ARN=$(echo "$BROKER_RESPONSE" | jq ".BrokerArn")

aws --region "$AWS_REGION" mq delete-broker \
    --broker-id "$BROKER_ID"


# init results backend
RESULTS_NAME="celery-autoscaling-results"


RESULTS_RESPONSE=$(aws --region "$AWS_REGION" elasticache create-cache-cluster \
    --cache-cluster-id "$RESULTS_NAME" \
    --engine "redis" \
    --cache-node-type "cache.t3.micro" \
    --num-cache-nodes 1
    )

RESULTS_ID=$(echo "$RESULTS_RESPONSE" | jq ".CacheCluster.CacheClusterId")

aws --region "$AWS_REGION" elasticache delete-cache-cluster \
    --cache-cluster-id "$RESULTS_ID"

# init kubernetes cluster
# TODO write init kubernetes cluster commands
