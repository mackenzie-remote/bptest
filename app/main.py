#!/usr/bin/env python3
import boto3
import datetime
import argparse

parser = argparse.ArgumentParser(description='Application to create an S3 bucket')
parser.add_argument('--bucket-name', type=str, required=True, help='Name of bucket')
parser.add_argument('--add-date-suffix', action=argparse.BooleanOptionalAction, default=False, help='Add the current date suffix to the bucket name')
args = parser.parse_args()

print(f"Arguments received: Bucket name: {args.bucket_name}. Add Date Suffix: {args.add_date_suffix}.")

now = datetime.datetime.now()
date_time = now.strftime("%Y%m%d-%H%M%S")

if args.add_date_suffix:
    bucket_name = f"{args.bucket_name}-{date_time}"
else:
    bucket_name = args.bucket_name

# Basic S3 bucketname validation
# 1. Must be lower-case
bucket_name = bucket_name.lower()

# 2. Max 63 chars
if len(bucket_name) > 63:
    print("Warning: Bucket name is more than 63 characters long. Truncating...")
    bucket_name = bucket_name[:63]

# 3. Can't have leading/trailing hyphens
if bucket_name[0] == '-' or bucket_name[-1] == '-':
    raise Exception(f"ERROR: Bucket name '{bucket_name}' is invalid - can't have a hyphen in its first or last character")

print(f"Will attempt to create a bucket named: {bucket_name}")

# create an S3 client
s3 = boto3.client('s3')

# check if the bucket already exists
bucket_exists = True
try:
    s3.head_bucket(Bucket=bucket_name)
except:
    bucket_exists = False

# if the bucket doesn't exist, create it
if not bucket_exists:
    s3.create_bucket(Bucket=bucket_name)
    print(f"S3 bucket '{bucket_name}' created successfully.")
else:
    raise Exception(f"S3 bucket '{bucket_name}' already exists.")
