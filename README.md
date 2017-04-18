# charm-test-infra

*A repo for test runners and scripts for OpenStack Charm CI builds, jobs, and automation.*

See also: [OpenStack Charm Guide](docs.openstack.org/developer/charm-guide/).


### Clients virtualenv via Tox

```
ubuntu@rby:~/git/charm-test-infra⟫ tox
clients installed: appdirs==1.4.3,argcomplete==1.8.2,Babel==2.4.0,bzr==2.7.0,cliff==2.5.0,cmd2==0.7.0,codetree==0.1.5,debtcollector==1.13.0,deprecation==1.0,funcsigs==1.0.2,functools32==3.2.3.post2,futures==3.1.1,iso8601==0.1.11,Jinja2==2.9.6,jsonpatch==1.15,jsonpointer==1.10,jsonschema==2.6.0,juju-deployer==0.10.0,jujuclient==0.54.0,keystoneauth1==2.19.0,MarkupSafe==1.0,mojo==0.4.5,monotonic==1.3,msgpack-python==0.4.8,netaddr==0.7.19,netifaces==0.10.5,openstacksdk==0.9.15,os-client-config==1.26.0,osc-lib==1.3.0,oslo.config==3.24.0,oslo.i18n==3.15.0,oslo.serialization==2.18.0,oslo.utils==3.25.0,packaging==16.8,pbr==2.1.0,pkg-resources==0.0.0,positional==1.1.1,prettytable==0.7.2,pyparsing==2.2.0,python-cinderclient==2.0.1,python-glanceclient==2.6.0,python-keystoneclient==3.10.0,python-neutronclient==6.2.0,python-novaclient==8.0.0,python-openstackclient==3.9.0,python-swiftclient==3.3.0,pytz==2017.2,PyYAML==3.12,requests==2.12.5,requestsexceptions==1.2.0,rfc3986==0.4.1,simplejson==3.10.0,six==1.10.0,stevedore==1.21.0,unicodecsv==0.14.1,warlock==1.2.0,websocket-client==0.40.0,wrapt==1.10.10
clients runtests: PYTHONHASHSEED='0'
clients runtests: commands[0] | mojo --version
0.4.5
clients runtests: commands[1] | openstack --version
openstack 3.9.0
________________________ summary ________________________
  clients: commands succeeded
  congratulations :)
ubuntu@rby:~/git/charm-test-infra⟫ . clientsrc
(clients) ubuntu@rby:~/git/charm-test-infra⟫ openstack --version
openstack 3.9.0
(clients) ubuntu@rby:~/git/charm-test-infra⟫ mojo --version
0.4.5
(clients) ubuntu@rby:~/git/charm-test-infra⟫
(clients) ubuntu@rby:~/git/charm-test-infra⟫ deactivate
ubuntu@rby:~/git/charm-test-infra⟫
```
