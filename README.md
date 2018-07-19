# charm-test-infra

*A repo for example scripts, test runners and scripts for OpenStack Charm CI builds, jobs, and automation.*

See also: [OpenStack Charm Guide](https://docs.openstack.org/charm-guide/latest/).


### Resolving virtualenv build dependencies on a fresh Bionic host

```
ubuntu@beisner-bastion:~$ sudo apt install tox python3-dev libffi-dev libssl-dev build-essential bzr
```


### Clients virtualenv via Tox

```
ubuntu@beisner-bastion:~/git/charm-test-infra$ tox
clients create: /home/ubuntu/git/charm-test-infra/.tox/clients
clients installdeps: -r/home/ubuntu/git/charm-test-infra/py3-clients-requirements.txt
clients installed: aodhclient==1.1.0,appdirs==1.4.3,argcomplete==1.9.4,asn1crypto==0.24.0,async-generator==1.9,Babel==2.6.0,bcrypt==3.1.4,certifi==2018.4.16,cffi==1.11.5,chardet==3.0.4,cliff==2.13.0,cmd2==0.9.3,colorama==0.3.9,cryptography==2.3,debtcollector==1.19.0,decorator==4.3.0,deprecation==2.0.5,distro-info==0.0.0,dnspython==1.15.0,dogpile.cache==0.6.6,futures==3.1.1,hvac==0.6.1,idna==2.7,iso8601==0.1.12,Jinja2==2.10,jmespath==0.9.3,jsonpatch==1.23,jsonpointer==2.0,jsonschema==2.6.0,juju==0.9.1,juju-deployer==0.11.0,juju-wait==2.6.4,jujubundlelib==0.5.6,jujuclient==0.54.0,keystoneauth1==3.9.0,macaroonbakery==1.1.3,MarkupSafe==1.0,mojo==0.4.5,monotonic==1.5,msgpack==0.5.6,munch==2.3.2,netaddr==0.7.19,netifaces==0.10.7,openstacksdk==0.16.0,os-client-config==1.31.2,os-service-types==1.2.0,osc-lib==1.11.0,oslo.config==6.3.0,oslo.context==2.21.0,oslo.i18n==3.20.0,oslo.log==3.39.0,oslo.serialization==2.27.0,oslo.utils==3.36.3,packaging==17.1,paramiko==2.4.1,pbr==4.1.0,pkg-resources==0.0.0,prettytable==0.7.2,protobuf==3.6.0,pyasn1==0.4.3,pycparser==2.18,pyinotify==0.9.6,pylxd==2.0.7,pymacaroons==0.13.0,PyNaCl==1.2.1,pyOpenSSL==18.0.0,pyparsing==2.2.0,pyperclip==1.6.2,pyRFC3339==1.1,python-ceilometerclient==2.9.0,python-cinderclient==3.6.1,python-codetree==0.1.6,python-dateutil==2.7.3,python-designateclient==2.9.0,python-glanceclient==2.11.1,python-heatclient==1.16.0,python-keystoneclient==3.17.0,python-neutronclient==6.9.0,python-novaclient==10.3.0,python-openstackclient==3.15.0,python-swiftclient==3.5.0,pytz==2018.5,PyYAML==3.13,requests==2.19.1,requests-unixsocket==0.1.5,requestsexceptions==1.4.0,rfc3986==1.1.0,simplejson==3.16.0,six==1.11.0,stevedore==1.28.0,tenacity==4.12.0,theblues==0.3.8,urllib3==1.23,warlock==1.3.0,wcwidth==0.1.7,websocket-client==0.48.0,websockets==6.0,wrapt==1.10.11,ws4py==0.5.1,zaza==0.0.2.dev1
clients runtests: PYTHONHASHSEED='0'
clients runtests: commands[0] | mojo --version
0.4.5
clients runtests: commands[1] | openstack --version
openstack 3.15.0
________________________________________________________________________________________ summary ________________________________________________________________________________________
  clients: commands succeeded
  congratulations :)
ubuntu@beisner-bastion:~/git/charm-test-infra$


ubuntu@beisner-bastion:~/git/charm-test-infra$ . clientsrc
(clients) ubuntu@beisner-bastion:~/git/charm-test-infra$ openstack --version
openstack 3.15.0
(clients) ubuntu@beisner-bastion:~/git/charm-test-infra$ mojo --version
0.4.5
(clients) ubuntu@beisner-bastion:~/git/charm-test-infra$ deactivate
ubuntu@beisner-bastion:~/git/charm-test-infra$
```
