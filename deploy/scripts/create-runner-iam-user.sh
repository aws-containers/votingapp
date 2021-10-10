#!/bin/bash
set -euo pipefail

source "./libs/common.sh"

ensure_env ".runner.env"
source ".runner.env"

read_aws_account_id
init_state_bucket

tf_working_dir="./../terraform/runner"

function apply() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" apply -auto-approve \
  -var="region=${aws_region}" \
  -var="ecr_repo_name=${ecr_repo_name}"
}

function destroy() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" destroy -auto-approve \
  -var="region=${aws_region}" \
  -var="ecr_repo_name=${ecr_repo_name}"
}

function show_secret() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" output -json iam_access_key_secret
}

help() {
  printf "./run.sh <apply|destroy|show_secret>\n"
}

case ${1-help} in
  "destroy")
    destroy
  ;;

  "apply")
    apply
  ;;

  "show_secret")
    show_secret
  ;;

  *)
    help
  ;;
esac
