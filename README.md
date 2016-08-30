# Docker nexus haproxy

[![Docker Automated buil](https://img.shields.io/docker/automated/sathlan/nexus-haproxy.svg?maxAge=86400)]()
[![GitHub release](https://img.shields.io/github/release/sathlan/docker-nexus-haproxy.svg?maxAge=86400)]()


Use haproxy to offer a suitable docker registry to use with an
[nexus foss](https://www.sonatype.com/download-oss-sonatype) server.


## Install

You need a nexus server running whose hostname is `nexus` and the
easiest way is to link it to the existing nexus container.

```
# start a nexus server
$ docker run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -t \
     -p 8081:8081 -d --name nexus -h nexus sathlan/nexus

# start the haproxy server
$ docker run \
     -v server.pem /etc/ssl/private/server.pem:z \
     --link nexus \
     -p 443:443 -d --name nexus-haproxy sathlan/nexus-haproxy
```

Or you can provide your own haproxy configuration

```shell
$ docker run \
     -v server.pem:/etc/ssl/private/server.pem:z \
     -v haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:z
     -p 443:443 -d --name nexus-haproxy sathlan/nexus-haproxy
```

## Certificates

The `server.pem` is the concatenation of:
 - server private key    - server.key
 - server certificate    - server.crt
 - authority certificate - ca.crt

```shell
$ cat server.key server.crt ca.crt > server.pem
```

A rake task can do a self signed certificate for testing purpose:

```
$ rake server.pem
```

## Test

```
$ bundle install
$ bundle exec rake spec
```

## License

MIT

