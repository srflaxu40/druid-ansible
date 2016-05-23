#!/bin/bash

# Coordinator:
ansible-playbook -i ./hosts ec2.yml -e "tag_name=druid-coordinator type=m4.4xlarge" -vvvvv -u ubuntu --tags deploy --vault-password-file ~/.ansible-vault-password.txt

sleep 60

ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy" -e "tag_name=druid_coordinator druid_role=coordinator druid_metadata_password=abc123 zk_host=52.53.183.198 pg_host=54.183.120.87" --vault-password-file ~/.ansible-vault-password.txt

exit

# Overlord:
ansible-playbook -i ./hosts ec2.yml -e "tag_name=druid-overlord type=m4.4xlarge" -vvvvv -u ubuntu --tags deploy --vault-password-file ~/.ansible-vault-password.txt

sleep 60

ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy" -e "tag_name=druid_overlord druid_role=overlord druid_metadata_password=abc123 zk_host=52.53.183.198 pg_host=54.183.120.87" --vault-password-file ~/.ansible-vault-password.txt

# Historical:
ansible-playbook -i ./hosts ec2.yml -e "tag_name=druid-historical-01 type=m4.4xlarge" -vvvvv -u ubuntu --tags deploy --vault-password-file ~/.ansible-vault-password.txt

sleep 60

ansible-playbook -i ./hosts ec2.yml -e "tag_name=druid-historical-02 type=m4.4xlarge" -vvvvv -u ubuntu --tags deploy --vault-password-file ~/.ansible-vault-password.txt

sleep 60

ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy" -e "tag_name=druid_historical_01 druid_role=historical druid_metadata_password=abc123 zk_host=52.53.183.198 pg_host=54.183.120.87" --vault-password-file ~/.ansible-vault-password.txt

ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy" -e "tag_name=druid_historical_02 druid_role=historical druid_metadata_password=abc123 zk_host=52.53.183.198 pg_host=54.183.120.87" --vault-password-file ~/.ansible-vault-password.txt

# Broker:
ansible-playbook -i ./hosts ec2.yml -e "tag_name=druid-broker type=m4.4xlarge" -vvvvv -u ubuntu --tags deploy --vault-password-file ~/.ansible-vault-password.txt

sleep 60

ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy" -e "tag_name=druid_broker druid_role=broker druid_metadata_password=abc123 zk_host=52.53.183.198 pg_host=54.183.120.87" --vault-password-file ~/.ansible-vault-password.txt

# Middle Manager:
ansible-playbook -i ./hosts ec2.yml -e "tag_name=druid-middle-manager-01 type=m4.4xlarge" -vvvvv -u ubuntu --tags deploy --vault-password-file ~/.ansible-vault-password.txt

sleep 60

ansible-playbook -i ./hosts ec2.yml -e "tag_name=druid-middle-manager-02 type=m4.4xlarge" -vvvvv -u ubuntu --tags deploy --vault-password-file ~/.ansible-vault-password.txt

sleep 60

ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy" -e "tag_name=druid_middle_manager_01 druid_role=middle-manager druid_metadata_password=abc123 zk_host=52.53.183.198 pg_host=54.183.120.87" --vault-password-file ~/.ansible-vault-password.txt

ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy" -e "tag_name=druid_middle_manager_02 druid_role=middle-manager druid_metadata_password=abc123 zk_host=52.53.183.198 pg_host=54.183.120.87" --vault-password-file ~/.ansible-vault-password.txt

# spin up tranq node
ansible-playbook -i ./hosts ec2.yml -e "tag_name=druid-tranquility type=m4.4xlarge" -vvvvv -u ubuntu --tags deploy --vault-password-file ~/.ansible-vault-password.txt

sleep 60

ansible-playbook tranq.yml -i ec2.py -u ubuntu -vvvvv --tags "configure,deploy" -e "tag_name=druid_tranquility"


