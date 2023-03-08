# Terraform

## Getting Started

This repo will create a very minimal test environment in AWS that will:-

* Create an ECR repository to store our app docker images. (Default name: `bptest`).
* Create a VPC with public and private subnets.
* Create necessary IAM permissions for executing a task, and permissions for the task itself.
* Create a Fargate ECS Cluster
* Create a Task Definition and Service to launch the app.

## Deploying

Run Terraform:

```shell
$ terraform plan
```

Check the output is what you expect, and if you are happy you can rerun with the `apply` parameter.
(Or run the plan with a `-out` and pass that to `apply`)

```shell
$ terraform apply
Plan: 29 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
..
```

The defaults passed to the task can be found in `variables.tf` and can be overridden on the cli for
testing if required:

```shell
$ terraform apply -var=bucket_name="different-bucket-name-please"
```

## Has It Worked?

If Terraform apply has completed without error, you can find if the task has been launched successfully by:

1. Check the list of S3 buckets to see a new bucket was created.
2. Look in the Cloudwatch logs, eg:

```shell
$ aws logs tail /aws/ecs/bptest  --follow
2023-03-08T17:45:55.351000+00:00 ec2/bptest/fe5e76 Arguments received: Bucket name: terraform-bptest. Add Date Suffix: True.
2023-03-08T17:45:55.351000+00:00 ec2/bptest/fe5e76 Will attempt to create a bucket named: terraform-bptest-20230308-174554
2023-03-08T17:45:55.351000+00:00 ec2/bptest/fe5e76 S3 bucket 'terraform-bptest-20230308-174554' created successfully.
```

## Cleaning Up

Run `terraform destroy` to clean up, this will also destroy the ECR repository and any images in there (in real
life you would not be so blasé about destroying artifacts).

```shell
$ terraform destroy
```

## Things You Would Do If This Was To Be A Real Thing Not A Test

* Pin the terraform version.
* Consider `terragrunt` if automating the `remote_state` S3 bucket creation / DynamoDB locking.
* Pin the provider versions.
* Improve the tagging.
* Add some security groups.
* Reduce the S3 IAM permission the task has (currently `AmazonS3FullAccess` which is too many permissions).
* Fix the `darwin_arm64` provider hashes in `.terraform.lock.hcl` to support at least `linux_amd64`.
* Add some CI to do the apply/destroy steps.
* Add some code quality steps to CI (`terraform fmt`, linting etc)
