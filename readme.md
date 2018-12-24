docker build -t cloudmail_s3ql:v1

docker run --rm -it -p 0.0.0.0:5900:5900 --device=/dev/fuse:/dev/fuse --cap-add SYS_ADMIN --security-opt seccomp=unconfined --security-opt apparmor=unconfined cloudmail_s3ql:v1

-e VNCPASS=changeme
-v /path/to/diskXXX:/cloud
