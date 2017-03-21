#!/bin/bash
#   Copyright 2017  Xebia Nederland B.V.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
[[ -z $BUCKET_TO_MOUNT ]] && echo "ERROR: BUCKET_TO_MOUNT is not set." >&2 && exit 1

if [[ -n $IAM_ROLE ]]  ; then
	FUSE_OPTIONS="$FUSE_OPTIONS -o iam_role=$IAM_ROLE"
else
	[[ -z $AWS_SECRET_ACCESS_KEY ]] && echo "ERROR: AWS_SECRET_ACCESS_KEY is not set." >&2 && exit 1
	[[ -z $AWS_ACCESS_KEY_ID ]] && echo "ERROR: AWS_ACCESS_KEY_ID is not set." >&2 && exit 1
        echo "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" > /etc/passwd-s3fs
        chmod 0600 /etc/passwd-s3fs
fi

service nginx start

mkdir -p /tmp/fuse
exec s3fs $BUCKET_TO_MOUNT /usr/share/nginx/html  \
	-f \
	-o ro \
	-o allow_other \
	-o uid=1000 \
	-o gid=1000 \
	-o umask=0022 \
	-o mp_umask=0022 \
 	-o use_cache=/tmp/fuse \
	$FUSE_OPTIONS
