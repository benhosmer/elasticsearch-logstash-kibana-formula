# SALT Formula for Elasticsearch, Logstash, Kibana and Filebeat (ELK)

## ELK Server

`# salt 'yourmininonid' state.apply elk`
`# salt 'yourminionid' state.apply elk.nginx` will install NGINX as a proxy

## ELK Client
`# salt 'yourminionid' state.apply elk.filebeat-client` installs the filebeat
client so that your client can connect with the ELK server and send logs.

**NOT COMPLETE**

