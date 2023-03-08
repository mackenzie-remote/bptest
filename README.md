# bptest - Python App

## Usage

The tool has a build in help, run it by passing `--help` or `-h`. Example arguments below:

```shell
usage: main.py [-h] --bucket-name BUCKET_NAME
               [--add-date-suffix | --no-add-date-suffix]

Application to create an S3 bucket

options:
  -h, --help            show this help message and exit
  --bucket-name BUCKET_NAME
                        Name of bucket
  --add-date-suffix, --no-add-date-suffix
                        Add the current date suffix to the bucket name
```

Example usage:


```shell
# Passing the bucket name
$ ./main.py --bucket-name hello-world-4567898765456789
Arguments received: Bucket name: hello-world-4567898765456789. Add Date Suffix: False.
Will attempt to create a bucket named: hello-world-4567898765456789
S3 bucket 'hello-world-4567898765456789' created successfully.

# Passing the bucket name and a date suffix
$ ./main.py --bucket-name hello-world --add-date-suffix
Arguments received: Bucket name: hello-world. Add Date Suffix: True.
Will attempt to create a bucket named: hello-world-20230308-101525
S3 bucket 'hello-world-20230308-101525' created successfully.
```

S3 bucket names must be globally unique, if you want to almost guarantee a unique name pass in the
`--add-date-suffix` argument to append the current date/time to help make sure the bucket name is
actually unique. The script will do some basic bucket name validation before attempting to create
the bucket as well, and truncate it if it exceeds the maximum length of 63 characters.

## Development Environment

This is a basic Python3 application. If you are familiar and comfortable with Python3 development
then you can skip this section. If not, here is a quick set-up guide assuming you are familiar
with the terminal.

Use a tool such as [pyenv](https://github.com/pyenv/pyenv) and install the version listed in the
`.python-version` file in this project.

To install the required modules, it is recommended to use a `virtualenv`. For example:

```shell
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
```

Once that is done you should be able to launch `./main.py` locally.

## Docker

### Building

The application can be built into a Docker container. An example for building the image:

```shell
docker build -t "bptest:$(date +%s)" .
```

### Running locally

The docker image does not have a `CMD` only and `ENTRYPOINT` so we can run it as if it was
a cli tool and pass arguments directly to it:

```shell
$ docker run bptest:1678284003 -h
usage: main.py [-h] --bucket-name BUCKET_NAME
...snip...
```

This is mostly out of scope for this project, but a simple way to test locally assuming your awscli
credentials are in `$HOME/.aws` is to pass this volume argument to the command:

```shell
$ docker run -v$HOME/.aws:/root/.aws:ro bptest:1678284003 -h
usage: main.py [-h] --bucket-name BUCKET_NAME
```

### Pushing to Amazon ECR

We will be pushing this to an Amazon ECR, this is a rough guide for doing this locally, in the
real world this would be wrapped with some guardrails and CI.

Login to ECR:

```shell
$ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 533740943112.dkr.ecr.us-east-1.amazonaws.com
```

Build locally and push using buildx (for those not building on `linux/amd64`):

```shell
$ docker buildx build --platform linux/amd64 --push -t 533740943112.dkr.ecr.us-east-1.amazonaws.com/bptest:latest .
```

The above presumes that the ECR repo already exists, although it's created by Terraform in the next step. To bypass the
chicken and the egg problem you can tell terraform to only create the repo first, then build/push the image, then run
the full terraform run.

```shell
$ terraform apply -target=aws_ecr_repository.bptest
```

# bptest - Terraform

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
