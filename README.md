# charm-test-infra

*A repo for example scripts, test runners and scripts for OpenStack Charm CI builds, jobs, and automation.*

See also: [OpenStack Charm Guide](https://docs.openstack.org/charm-guide/latest/).


### Resolving virtualenv build dependencies on a fresh Bionic host

```
ubuntu@nuccitheboss-bastion:~$ sudo apt install tox python3-dev libffi-dev libssl-dev build-essential bzr
ubuntu@nuccitheboss-bastion:~$ sudo snap install juju --classic
```

### Resolving virtualenv build dependencies on a fresh Focal/Jammie host

Due to a descrepancy in the `bzr` package between Bionic and Focal/Jammie (see issue #55), there are few extra steps that need to be taken to resolve the virtualenv build dependencies on a fresh Focal/Jammie host.


```
ubuntu@nuccitheboss-bastion:~$ sudo apt install tox python3-dev build-essential wget libffi-dev libssl-dev libbz2-dev libncurses-dev libreadline-dev libsqlite3-dev liblzma-dev zlib1g-dev
ubuntu@nuccitheboss-bastion:~$ sudo snap install juju --classic
ubuntu@nuccitheboss-bastion:~$ curl https://pyenv.run | bash
ubuntu@nuccitheboss-bastion:~$ cat << EOF >> ~/.bashrc
> export PATH="$HOME/.pyenv/bin:$PATH"
> eval "$(pyenv init --path)"
> eval "$(pyenv virtualenv-init -)"
> EOF
ubuntu@nuccitheboss-bastion:~$ source ~/.bashrc
ubuntu@nuccitheboss-bastion:~$ pyenv install 3.10.4
ubuntu@nuccitheboss-bastion:~$ pyenv install 2.7.15
ubuntu@nuccitheboss-bastion:~$ pyenv global 3.10.4 2.7.15
ubuntu@nuccitheboss-bastion:~$ python2 -m pip install paramiko pycrypto
ubuntu@nuccitheboss-bastion:~$ wget https://launchpad.net/bzr/2.7/2.7.0/+download/bzr-2.7.0.tar.gz -O - | tar -xzf -
ubuntu@nuccitheboss-bastion:~$ python2 bzr-2.7.0/setup.py install
ubuntu@nuccitheboss-bastion:~$ export PATH=$HOME/.pyenv/versions/2.7.15/bin:$PATH
```

*It is ugly, but it gets the job done :)*

### Clients virtualenv via Tox

```
ubuntu@nuccitheboss-bastion:~/charm-test-infra$ tox
clients create: /home/ubuntu/charm-test-infra/.tox/clients
clients installdeps: -r/home/ubuntu/charm-test-infra/py3-clients-requirements.txt
clients installed: aiohttp==3.8.1,aiosignal==1.2.0,aodhclient==2.4.1,appdirs==1.4.4,argcomplete==2.0.0,async-generator==1.10,async-timeout==4.0.2,attrs==21.4.0,autopage==0.5.1,Babel==2.10.1,bcrypt==3.2.2,boto3==1.24.7,botocore==1.27.7,cachetools==5.2.0,certifi==2022.5.18.1,cffi==1.15.0,charset-normalizer==2.0.12,cliff==3.10.1,cmd2==2.4.1,colorclass==2.2.2,cryptography==3.3.2,debtcollector==2.5.0,decorator==5.1.1,dnspython==2.2.1,dogpile.cache==1.1.6,fasteners==0.17.3,frozenlist==1.3.0,futurist==1.10.0,gnocchiclient==7.0.7,google-auth==2.7.0,hvac==0.6.4,idna==3.3,importlib-resources==5.7.1,iso8601==1.0.2,Jinja2==3.1.2,jmespath==1.0.0,jsonpatch==1.32,jsonpointer==2.3,jsonschema==4.6.0,juju==2.9.10,juju-deployer==0.11.0,juju-wait==2.8.4,jujubundlelib==0.5.7,jujuclient==0.54.0,jujucrashdump==0.0.0,keystoneauth1==4.6.0,kubernetes==23.6.0,lxml==4.9.0,macaroonbakery==1.3.1,MarkupSafe==2.1.1,mojo==0.4.5,monotonic==1.6,msgpack==1.0.4,multidict==6.0.2,munch==2.5.0,mypy-extensions==0.4.3,netaddr==0.8.0,netifaces==0.11.0,oauthlib==3.2.0,openstacksdk==0.99.0,os-client-config==2.1.0,os-service-types==1.7.0,osc-lib==2.6.0,oslo.concurrency==4.5.1,oslo.config==6.11.3,oslo.context==4.1.0,oslo.i18n==5.1.0,oslo.log==5.0.0,oslo.serialization==4.3.0,oslo.utils==4.13.0,osprofiler==3.4.3,packaging==21.3,paramiko==2.11.0,pbr==5.9.0,pika==1.2.1,prettytable==0.7.2,protobuf==3.20.1,pyasn1==0.4.8,pyasn1-modules==0.2.8,pycparser==2.21,pyinotify==0.9.6,pylxd==2.0.7,pymacaroons==0.13.0,pymongo==4.1.1,PyNaCl==1.5.0,pyOpenSSL==22.0.0,pyparsing==2.4.7,pyperclip==1.8.2,pyRFC3339==1.1,pyrsistent==0.18.1,python-barbicanclient==5.3.0,python-ceilometerclient==2.9.0,python-cinderclient==8.3.0,python-codetree==1.2.1,python-dateutil==2.8.2,python-designateclient==4.5.0,python-glanceclient==4.0.0,python-heatclient==2.5.1,python-ironicclient==4.11.0,python-keystoneclient==4.5.0,python-libmaas==0.6.6,python-manilaclient==1.29.0,python-neutronclient==7.8.0,python-novaclient==18.0.0,python-octaviaclient==1.10.1,python-openstackclient==5.8.0,python-swiftclient==4.0.0,pytz==2022.1,PyYAML==6.0,requests==2.28.0,requests-oauthlib==1.3.1,requests-unixsocket==0.3.0,requestsexceptions==1.4.0,rfc3986==2.0.0,rsa==4.8,s3transfer==0.6.0,simplejson==3.17.6,six==1.16.0,stevedore==3.5.0,tenacity==8.0.1,terminaltables==3.1.10,theblues==0.5.2,toposort==1.7,typing-extensions==4.2.0,typing-inspect==0.7.1,ujson==5.3.0,urllib3==1.26.9,warlock==1.3.3,wcwidth==0.2.5,WebOb==1.8.7,websocket-client==1.3.2,websockets==7.0,wrapt==1.14.1,ws4py==0.5.1,yarl==1.7.2,zaza==0.0.2.dev1,zaza.openstack==0.0.1.dev1,zipp==3.8.0
clients run-test-pre: PYTHONHASHSEED='0'
clients run-test: commands[0] | mojo --version
0.4.5
clients run-test: commands[1] | openstack --version
openstack 5.8.0
_____________________________________________________________________________________________________ summary _____________________________________________________________________________________________________
  clients: commands succeeded
  congratulations :)
ubuntu@nuccitheboss-bastion:~/charm-test-infra$ . clientsrc 
(clients) ubuntu@nuccitheboss-bastion:~/charm-test-infra$ openstack --version
openstack 5.8.0
(clients) ubuntu@nuccitheboss-bastion:~/charm-test-infra$ mojo --version
0.4.5
(clients) ubuntu@nuccitheboss-bastion:~/charm-test-infra$ deactivate
ubuntu@nuccitheboss-bastion:~/charm-test-infra$
```
