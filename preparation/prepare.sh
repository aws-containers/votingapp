#!/bin/bash

export TABLE_NAME="votingapp-restaurants"
export IAM_ROLE="votingapp-role"
export ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account) 
if [ -z ${AWS_REGION} ]; then echo "you need to export the AWS_REGION variable"; exit; fi

aws dynamodb create-table \
    --table-name $TABLE_NAME \
    --attribute-definitions AttributeName=name,AttributeType=S \
    --key-schema AttributeName=name,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $AWS_REGION 

echo "waiting a few seconds for the table to be available"
sleep 10 

aws dynamodb put-item \
    --table-name $TABLE_NAME \
    --item '{"name": {"S": "ihop"}, "restaurantcount": {"N": "0"}}' \
    --region $AWS_REGION 
    
aws dynamodb put-item \
    --table-name $TABLE_NAME \
    --item '{"name": {"S": "outback"}, "restaurantcount": {"N": "0"}}' \
    --region $AWS_REGION 

aws dynamodb put-item \
    --table-name $TABLE_NAME \
    --item '{"name": {"S": "bucadibeppo"}, "restaurantcount": {"N": "0"}}' \
    --region $AWS_REGION 

aws dynamodb put-item \
    --table-name $TABLE_NAME \
    --item '{"name": {"S": "chipotle"}, "restaurantcount": {"N": "0"}}' \
    --region $AWS_REGION 


aws iam create-role --role-name $IAM_ROLE --assume-role-policy-document file://apprunner-trust-policy.json
sed -e "s@ACCOUNT_ID@$ACCOUNT_ID@g" -e "s@AWS_REGION@$AWS_REGION@g" -e "s@TABLE_NAME@$TABLE_NAME@g" votingapp-ddb-policy.json > filled-votingapp-ddb-policy.json
aws iam create-policy --policy-name votingapp-ddb-policy --policy-document file://./filled-votingapp-ddb-policy.json
rm  filled-votingapp-ddb-policy.json
aws iam attach-role-policy --role-name $IAM_ROLE --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/votingapp-ddb-policy
