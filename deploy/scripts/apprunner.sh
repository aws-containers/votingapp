#!/bin/bash
set -euo pipefail

source "./libs/common.sh"

ensure_env ".apprunner.env"
source ".apprunner.env"

read_aws_account_id
init_state_bucket

tf_working_dir="./../terraform/apprunner"

function apply() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  -backend-config="key=terraform/apps/votingapp/${environment}/apprunner.tfstate" \
  && \
  terraform -chdir="${tf_working_dir}" apply -auto-approve \
  -var="region=${aws_region}" \
  -var="environment=${environment}" \
  -var="ecr_repo_url=${ecr_repo_url}" \
  -var="should_use_ecr=${should_use_ecr}" \
  -var="github_connection_arn=${github_connection_arn}" \
  -var="github_code_branch=${github_code_branch}" \
  -var="github_code_repo_url=${github_code_repo_url}"
}

function destroy() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  -backend-config="key=terraform/apps/votingapp/${environment}/apprunner.tfstate" \
  && \
  terraform -chdir="${tf_working_dir}" destroy -auto-approve \
  -var="region=${aws_region}" \
  -var="environment=${environment}" \
  -var="ecr_repo_url=${ecr_repo_url}" \
  -var="should_use_ecr=${should_use_ecr}" \
  -var="github_connection_arn=${github_connection_arn}" \
  -var="github_code_branch=${github_code_branch}" \
  -var="github_code_repo_url=${github_code_repo_url}"
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

  *)
    help
  ;;
esac
