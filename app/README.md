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

