# Agent container for devices running Junos Evolved

## Puppet agent

Puppet-agent is natively installed on Junos Evolved. The container is intended to replace
native puppet-agent installation. Thus, giving the user power to mount or unmount the package
on demand. The container is currently based out of a ruby-2.3.0 base image.

## Image contents

The docker container will contain the following gems and their dependencies:

* puppet
* junos-ez-stdlib

## Steps to setup puppet-agent container on devices running Junos Evolved

### 1. To start docker on Junos Evolved

```shell
[vrf:none] root@host-device:~# systemctl start docker@vrf0
[vrf:none] root@host-device:~# export DOCKER_HOST=unix:///run/docker-vrf0.sock
[vrf:none] root@host-device:~#
```

### 2. To start the container

```shell
[vrf:none] root@host-device:~#docker run --rm -d --network=host --cap-add=NET_ADMIN --mount source=jnet,destination=/usr/evo --env-file=/run/docker-vrf0/jnet.env -e PATH="/usr/local/bundle/bin:$PATH" -e NETCONF_USER=USER_HERE --name=puppet-agent Juniper/puppet-agent:latest
Unable to find image 'Juniper/puppet-agent:latest' locally
latest: Pulling from Juniper/puppet-agent
a20850499053: Pull complete
45fafcc4d947: Pull complete
43cb0e5bcce7: Pull complete
db3f235b985b: Pull complete
54c4fe133adf: Pull complete
714f4236261e: Pull complete
88a2e799342d: Pull complete
2aa1d79e9c70: Pull complete
bee8e7e10429: Pull complete
c8cb2af9aa6d: Pull complete
f8c9680250a0: Pull complete
667eedd81efe: Pull complete
ec8ed239af78: Pull complete
fcb4f89ccdbf: Pull complete
beb877dceff1: Pull complete
baf690409398: Pull complete
7bb7d69f2608: Pull complete
Digest: sha256:7a49eb39c5d69964dc14c39d65e05610eabff850bf09fa1a2f2ce9d87c0377ee
Status: Downloaded newer image for Juniper/puppet-agent:latest
root@host-device:/puppet-agent#
```

The container will use the host network to communicate with the puppet server, it will also share the same hostname as of the host.

### 3. Authenticating container to host

Key-based SSH authentication is used to authenticate the container to host.

```shell
[vrf:none] root@host-device:~#docker exec -it puppet-agent ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
Generating public/private rsa key pair.
Created directory '/root/.ssh'.
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
aa:69:77:b0:47:b0:c4:8f:90:39:f7:0d:04:61:ca:d1 root@host-device
The key's randomart image is:
+---[RSA 2048]----+
|    ..+o         |
|   . +E .        |
|    o+ .         |
|    = = .        |
|     = *So       |
|      +.+ .      |
|      .+         |
|    .oo o        |
|   .o. o         |
+-----------------+
[vrf:none] root@host-device:~#docker cp puppet-agent:/root/.ssh/id_rsa.pub .
[vrf:none] root@host-device:~#cat id_rsa.pub >> .ssh/authorized_keys
[vrf:none] root@host-device:~#
```

### 4. Verifying the connection

```shell
root@host-device:/puppet-agent# ssh puppet@localhost
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is 3c:3c:ed:5c:ce:ee:34:09:79:22:d3:cd:af:d0:68:4a.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
--- JUNOS 19.2-20190212.3-EVO Linux re0 4.8.28-WR2.2.1_standard #1 SMP PREEMPT Tue Feb 5 10:44:31 PST 2019 x86_64 x86_64 x86_64 GNU/Linux
puppet@host-device>
```

### 5. Edit puppet agent configuration

```shell
root@host-device:/puppet-agent# cat /etc/puppet/puppet.conf
[main]
    # The Puppet log directory.
    # The default value is '$vardir/log'.
    logdir = /var/log/puppet

    # Where Puppet PID files are kept.
    # The default value is '$vardir/run'.
    rundir = /var/run/puppet

    # Where SSL certificates are kept.
    # The default value is '$confdir/ssl'.
    ssldir = $vardir/ssl

[agent]
    server = puppet-master.domain.name
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '$confdir/classes.txt'.
    classfile = $vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '$confdir/localconfig'.
    localconfig = $vardir/localconfig
root@host-device:/puppet-agent#

The server variable has to be set accordingly by the user.
```

### 6. To start the puppet agent

```shell
root@host-device:/puppet-agent# puppet agent -t
/usr/local/bundle/gems/puppet-3.7.3/lib/puppet/defaults.rb:465: warning: duplicated key at line 466 ignored: :queue_type
Info: Creating a new SSL key for host-device.domain.name
Info: csr_attributes file loading from /etc/puppet/csr_attributes.yaml
Info: Creating a new SSL certificate request for host-device.domain.name
Info: Certificate Request fingerprint (SHA256): 7A:23:A3:39:DC:80:F4:8D:55:DC:57:07:0E:51:90:B2:6B:EE:4D:50:24:E4:6B:65:16:90:0F:0D:54:B4:6F:72
Exiting; no certificate found and waitforcert is disabled
root@host-device:/puppet-agent#
```

### 7. Configuring NETCONF_USER

```shell
root@host-device:/puppet-agent# export NETCONF_USER=puppet
root@host-device:/puppet-agent#
```

The user will be used to establish an SSH connection with device.

Note: The user must have configure, control and view permissions.

```shell
[edit]
root@host-device# show system login class test
permissions [ configure control view ];

[edit]
root@host-device#
```

### 8. Accepting keys

```shell
puppet-master#puppet cert sign host-device.domain.name
Notice: Signed certificate request for host-device.domain.name
Notice: Removing file Puppet::SSL::CertificateRequest host-device.domain.name at '/var/lib/puppet/ssl/ca/requests/host-device.domain.name.pem'
puppet-master#
```

Now the container is authenticated and ready to be used as the puppet agent for the host device.

## Chef Agent

Chef-agent is natively installed on Junos Evolved. The container is intended to replace
native chef-agent installation. Thus, giving the user power to mount or unmount the package
on demand. The container is currently based out of a ruby-2.3.0 base image.

### 1. Commands to build the container image

```bash
cd chef-client
docker build .
```

### 2. To start the chef-client container please use

```bash
docker run -d --rm --name=chef-client --mount source=jnet,destination=/usr/evo,readonly --env-file /run/docker/jnet/jnet.env -e PATH="/usr/local/bundle/bin:$PATH" -e NETCONF_USER=USER_HERE --network=host --cap-add=NET_ADMIN Juniper/chef-client:latest
```

### 3. Setup instructions

* Change the username to the desired username

* Chef-client will establish a `NETCONF` session with the `localhost`. User will have to run the following commands to establish a password-less connection with host device.

* Generate SSH-Keys:

`docker exec -it chef-client ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa`

* Copy the public key from container:

`docker cp CONTAINER_ID:/root/.ssh/id_rsa.pub .`

* Add the key to `authorized_keys`:

`cat ~/.ssh/id_rsa.pub >> authorized_keys`
