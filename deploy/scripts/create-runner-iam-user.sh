#!/bin/bash
set -euo pipefail

source "./lib/common.sh"

ensure_env ".runner.env"
source ".runner.env"

read_aws_account_id
init_state_bucket

tf_working_dir="./../terraform/runner"

apply() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" apply -auto-approve \
  -var="region=${aws_region}"
}

destroy() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" destroy -auto-approve \
  -var="region=${aws_region}"
}

help() {
  printf "./run.sh <apply|destroy>\n"
}

case ${1-help} in
  "destroy")
    destroy
  ;;

  "apply")
    apply
  ;;

  *)
    help
  ;;
esac
