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
FROM ubuntu:xenial

RUN apt-get update && \
	apt-get install -y s3fs nginx wget && \
	apt-get -y autoremove && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/lists/* 

RUN wget -O /bin/tini -q https://github.com/krallin/tini/releases/download/v0.14.0/tini-static-amd64 \
    && chmod +x /bin/tini \
    && echo "b2d2b6d7f570158ae5eccbad9b98b5e9f040f853  /bin/tini" \
    | sha1sum -c -


RUN groupadd -g 1000 nginx \
    && useradd -m nginx -u 1000 -g 1000 \
    && mkdir -p /bucket \
    && rm -rf /etc/nginx/conf.d/default.conf  \
    && chmod -R ugo+r /usr/share/nginx  \
    && mv /usr/share/nginx/html /usr/share/nginx/html.org \
    && install -o nginx -g nginx -d /usr/share/nginx/html 

ADD files/nginx.conf /etc/nginx/nginx.conf

ENV	FUSE_OPTIONS= \
	IAM_PROFILE= \
	AWS_ACCESS_KEY_ID= \
	AWS_SECRET_ACCESS_KEY= \
	BUCKET_TO_MOUNT=  \
	MOUNT_POINT=/usr/share/nginx/html

LABEL   SERVICE_NAME=s3-reverse-proxy \
	SERVICE_80_TAGS=http \
	SERVICE_80_CHECK_HTTP=/nginx_status \
	SERVICE_80_CHECK_INTERVAL=60s

ADD	files/entrypoint.sh /

EXPOSE  80

ENTRYPOINT ["/bin/tini", "-g", "--", "/entrypoint.sh"]
