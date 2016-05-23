#!/bin/bash

export AWS_ACCESS_KEY_ID=$1

export AWS_SECRET_ACCESS_KEY=$2

id_rsa=$3

ansible-playbook -i ./hosts ec2.yml -vvvv

echo "Waiting for server to boot up in order to ssh..."

sleep 30

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i ec2.py provision_aws.yml --private-key="${id_rsa}" -vvvv -u ubuntu -t deploy
ansible-playbook -i ec2.py provision_aws.yml --private-key="${id_rsa}" -vvvv -u ubuntu -t configure

ansible-playbook -i ec2.py tests.yml --private-key="${id_rsa}" -vvvv -u ubuntu -t testenv
