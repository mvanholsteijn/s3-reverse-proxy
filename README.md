## S3 Reverse Proxy

This Docker image contains a NGiNX Reverse Proxy for an S3 bucket. It will run an NGiNX
web server pointing to the directory /usr/share/nginx/html, which is mounted
on the S3 bucket through [s3fs](http://manpages.ubuntu.com/manpages/xenial/man1/s3fs.1.html)


# Running on AWS with IAM Instance Profile
To run the S3 reverse proxy, we advise you to specify the environment variable `IAM_PROFILE` which contains the name of the
IAM Instance profile assigned to the AWS machine running the container. In this way, the credentials will be dynamically assigned and
refreshed.

The environment variable `BUCKET_TO_MOUNT` specifies the name of the S3 bucket to mount.

```
docker run \
	--privileged -ti \
	-p 8182:80 \
	-e IAM_PROFILE=ApplicationServer \
	-e BUCKET_TO_MOUNT=marks-eu-west-1 \
	mvanholsteijn/s3-reverse-proxy:latest
```

# To run outside AWS
If you do not have an IAM Instance Profile, you can specify the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` [environment variables](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment) as the credentials.

```
docker run \
	--privileged -ti \
	-p 8182:80 \
	-e AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id) \
	-e AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)  \
	-e BUCKET_TO_MOUNT=marks-eu-west-1 \
	mvanholsteijn/s3-reverse-proxy:latest
```
