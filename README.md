# druid_ansible

---

# Setting up the Ansible Environment:
* In order to run this playbook, you must first export the following environment variables,
  or pass them to ansible on the command line.  Ansible takes the default variables set in the
  role, but we override them where necessary.  In the case of AWS keys, we export them in restricted environments (Jenkins) or a user's local macbook:
  * `AWS_ACCESS_KEY_ID`
  * `AWS_SECRET_ACCESS_KEY`
  
* Please note that variables passed at the CML take precedence in overriding all downstream variables.
* When running as a user other than the default `ubuntu` user (ie jenkins), be sure to set the `ANSIBLE_CONFIG` path to your
  `ansible.cfg` file.  A default `ansible.cfg` is given in this project / repo.  Export `export ANSIBLE_CONFIG=./ansible.cfg` to enable its use.

* SSH KEYS:
  * To run commands on your local mac, you need access to the `ubuntu` SSH key the instance was launched with, or the Jenkins user key in S3.
  * If you use the `ubuntu` key, you'll need to set the disable host key checking variable prior to your ansible play running:
    `export ANSIBLE_HOST_KEY_CHECKING=False`
  * You will also need to add the following parameter to your `ansible-playbook` execution:
    `--private-key <path to ubuntu key>`

## Running Ansible to create EC2 nodes for orchestration:
* Note - this module requires Python's Boto Module.
* To create an ec2 node to be later provisioned with Druid, run:

  `ansible-playbook -i ./hosts ec2.yml -e "role=overlord tag_name=druid-overlord tag_environment=staging" -vvvvv -u ubuntu --tags "configure,deploy" --vault-password-file ~/.vault_pass.txt`

  * Where `tag_name` is the "Name" tag you wish your instance to be tagged.
  * `tag_environment` is the environment to tag the instance with.
  * Both environment variables must be set.
  * Spin up multiple instances with the count parameter supplied as an environment variable.  This is 1 by default.

## Configuring Druid Roles (overlord / middle-manager / coordinator / broker / historical):

* To configure the ec2 node with Druid / Java / Configs, but not start Druid run:

  `ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure" -e "aws_access_key=<AWS KEY> aws_secret_access_key=<SECRETY KEY> tag_name=druid_overlord tag_environment=staging druid_role=overlord druid_metadata_password=<REDACTED> zk_host=<HOST IP OR FQDN> pg_host=<HOST OR FQDN>" --vault-password-file ~/.vault_pass.txt`

  * Notice that we used the `druid_role` overlord, and also passed our super secret password via the command line.
  * Also, notice you can override the set zk_host and pg_host variables as well...

* You can override any variables in ansible via the command-line which takes utmost precedence.

* To configure the ec2 node with Druid and required configuration, and also start Druid on the node run:

  `ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy" -e "aws_access_key=<AWS KEY> aws_secret_access_key=<SECRETY KEY> tag_name=druid_overlord tag_environment=staging druid_role=overlord druid_metadata_password=<REDACTED> zk_host=<HOST IP OR FQDN> pg_host=<HOST OR FQDN>" --vault-password-file ~/.vault_pass.txt`

## To test the Druid role / nodes are up and the port is allocated, run the `tests` task:

   `ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "configure,deploy,test" -e "aws_access_key=<AWS KEY> aws_secret_access_key=<SECRETY KEY> tag_name=druid_overlord tag_environment=staging druid_role=overlord druid_metadata_password=<REDACTED> zk_host=<HOST OR FQDN> pg_host=<HOST OR FQDN>"` 

* To just run the tests:

   `ansible-playbook druid.yml -i ec2.py -u ubuntu -vvvv --tags "test" -e "aws_access_key=<AWS KEY> aws_secret_access_key=<SECRETY KEY> tag_name=druid_overlord tag_environment=staging druid_role=overlord druid_metadata_password=<REDACTED> zk_host=<HOST OR FQDN> pg_host=<HOST OR FQDN>"`

## Configuring Tranquility:

* To configure Druid-Tranquility and install Java run:

  `ansible-playbook tranq.yml -i ec2.py -u ubuntu -vvvvv --tags "configure" -e "tag_name=druid_tranquility tag_environment=staging"`

  * Where `tag_name` is the "Name" tag you wish your instance to be tagged.

* To configure Druid-Tranquility, install Java, and startup tranquility run:

  `ansible-playbook tranq.yml -i ec2.py -u ubuntu -vvvvv --tags "configure,deploy" -e "tag_name=druid_tranquility tag_environment=staging"`

## Configuring PostgreSQL:

* To configure the postgres database from an ec2 instance created using the above ec2.yml playbook run:
  * If you do not override the postgres password, the password used will be the one located under the postgres role in vars/pg_pass.yml

  `ansible-playbook pg.yml -i ec2.py -u ubuntu -vv --tags "configure,deploy" -e "tag_name=druid_postgres tag_environment=staging druid_metadata_password=<REDACTED YOUR PASSWORD>" --vault-password-file ~/.vault_pass.txt`

* To configure just the database of an existing postgres database instance in ec2 run:

  `ansible-playbook pg.yml -i ec2.py -u ubuntu -vv --tags "deploy" -e "tag_name=druid_postgres tag_environment=staging druid_metadata_password=<REDACTED YOUR PASSWORD>" --vault-password-file ~/.vault_pass.txt`

## Configuring Zookeeper:

* To configure zookeeper, run the zk.yml playbook:

  `ansible-playbook zk.yml -i ec2.py -u ubuntu -vvvvv --tags "configure,deploy" -e "tag_name=druid_zookeeper tag_environment=staging"`

---

# Running packer with ansible (see packer installation instructions on the web):

* Run the following shell script `pack_druid.sh` like below (with your specific parameters) to pack Druid with Packer:

```
./pack_druid.sh \
overlord \
abc123 \
52.53.173.236 \
druid-zk-1010326426.us-west-1.elb.amazonaws.com \
druid_overlord \
AKIAJ5ZPSECRET \
RbKGATy3CISrMGp/nSECRET \
us-west-1 \
ami-06116566 \
t2.large \
sg-93a670f7 \
subnet-61869a27 \
/opt/packer/ \
~/.ansible-vault.txt
```

* , And for packing tranquility:

`
./pack_tranquility.sh druid-tranq 52.53.183.198 druid-tranq <AWS KEY> <SECRET KEY> us-west-1 ami-06116566 t2.large sg-93a670f7 subnet-61869a27 /opt/packer
`

* Note the <PACKER PATH> variable in these example are specific to building packer on Jenkins.  If you were running this locally, you would simply use './'.
* The scripts use the parameters as below.  Please look at each pack_* shell script for more information on USAGE:

```
#!/bin/bash
 
# USAGE:
# ./pack_druid.sh <DRUID_ROLE> <PG_PASS> <PG_HOST> <ZK_HOST> <TAG_NAME> <AWS KEY> <AWS SECRET KEY> 
#                 <REGION> <SOURCE AMI> <INSTANCE TYPE> <SECURITY GROUP ID> <SUBNET ID> <VAULT FILE> <PACKER PATH>

export RUN_LIST="configure,deploy,test"
export DRUID_ROLE="$1"
export PG_PASS="$2"
export PG_HOST="$3"
export ZK_HOST="$4"
export PACKER_PATH="${14:-/usr/local/bin/}"


packer build \
    -var "aws_access_key=$6" \
    -var "aws_secret_key=$7" \
    -var "RUN_LIST=${RUN_LIST}" \
    -var "DRUID_ROLE=${DRUID_ROLE}" \
    -var "PG_PASS=${PG_PASS}" \
    -var "ZK_HOST=${ZK_HOST}" \
    -var "PG_HOST=${PG_HOST}" \
    -var "tag_name=$5" \
    -var "region=$8" \
    -var "source_ami=$9" \
    -var "instance_type=${10}" \
    -var "security_group_id=${11}" \
    -var "subnet_id=${12}" \
    -var "vault_file=${13}" \
    druid_nodes.json
```

---

# Ansible Vault Things:

  * In order to encrypt any file under this repo, use the following command:

  `ansible-vault encrypt <file to encrypt> --vault-password-file ~/.ansible-vault-password.txt`
  
  * The .vault_pass.txt file is literally just a key=value prior to aes encryption that overrides the `pg_pass` variable
    in the postgres role.

  * To decrypt use:

  `ansible-vault encrypt decrypt --vault-password-file ~/.ansible-vault-password.txt`

  * AES-256 encryption is used by default with `ansible-vault`

  * To use encrypted files or structures in an ansible play, use the following flag with your ansible-playbook command:

    `--vault-password-file ~/.vault_pass.txt`

---

# Uploading to AWS S3 with AES encryption:

* Upload:

  `aws s3 cp --sse-c-key <AES ENC KEY> --sse-c AES256 ./ubuntu s3://your-domain-druid/`

* Download:

  `aws s3 cp --sse-c-key <AES ENC KEY> --sse-c AES256 s3://your-domain-druid/ubuntu .`

---

# User-Data:

* The user data file (userdata.txt) is used and uploaded to S3.  The `druid-create-and-attach-launch-config` job in production Jenkins utilizes this file as user-data for instances it brings up.
* It is vital to keep this file as it ensures hostnames and post-baking attributes are set properly.

