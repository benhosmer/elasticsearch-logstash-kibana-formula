{% set elk_gpg_key_url = salt['pillar.get']('elk_gpg_key_url', 'https://packages.elastic.co/GPG-KEY-elasticsearch') %}
{% set logstash_repo_url = salt['pillar.get']('logstash_repo_url', 'http://packages.elastic.co/logstash/2.2/centos') %}
{% set elastic_repo_url = salt['pillar.get']('elastic_repo_url', 'https://packages.elastic.co/elasticsearch/2.x/centos') %}
{% set kibana_repo_url = salt['pillar.get']('kibana_repo_url', 'http://packages.elastic.co/kibana/4.4/centos') %}

java-jdk-install:
  pkg.installed:
    - pkgs:
      - java-1.8.0-openjdk

elk-repo-gpg-key:
  file.managed:
    - name: /etc/pki/rpm-gpg/GPG-KEY-elasticsearch
    - source: {{ elk_gpg_key_url }}
    - source_hash: md5=41c14e54aa0d201ae680bb34c199be98

elastic-repo:
  pkgrepo.managed:
    - humanname: Elasticsearch
    - name: elasticsearch
    - baseurl: {{ elastic_repo_url }}
    - gpgcheck: 1
    - gpgkey: file:///etc/pki/rpm-gpg/GPG-KEY-elasticsearch

logstash-repo:
  pkgrepo.managed:
    - humanname: Logstash
    - name: logstash
    - baseurl: {{ logstash_repo_url }}
    - gpgcheck: 1
    - gpgkey: file:///etc/pki/rpm-gpg/GPG-KEY-elasticsearch

kibana-repo:
  pkgrepo.managed:
    - humanname: kibana
    - name: kibana
    - baseurl: {{ kibana_repo_url }}
    - gpgcheck: 1
    - gpgkey: file:///etc/pki/rpm-gpg/GPG-KEY-elasticsearch

elk-pkgs:
 pkg.installed:
   - pkgs:
     - elasticsearch
     - logstash
     - kibana
   - require:
     - pkgrepo: elastic-repo
     - pkgrepo: logstash-repo
     - pkgrepo: kibana
     - file: elk-repo-gpg-key

elasticsearch-service:
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - pkg: java-jdk-install
      - pkg: elk-pkgs

logstash-service:
  service.running:
    - name: logstash
    - enable: True
    - require:
      - pkg: java-jdk-install
      - pkg: elk-pkgs

kibana-service:
  service.running:
    - name: kibana
    - enable: True
    - require:
      - pkg: java-jdk-install
      - pkg: elk-pkgs

elasticsearch-conf:
 file.managed:
   - name: /etc/elasticsearch/elasticsearch.yml
   - source: salt://elk/elasticsearch.yml
   - require:
     - pkg: elk-pkgs
   - template: jinja

logstash-conf:
 file.managed:
   - name: /etc/logstash/conf.d/logstash.conf
   - source: salt://elk/logstash.conf
   - require:
     - pkg: elk-pkgs
   - template: jinja

kibana-conf:
 file.managed:
   - name: /opt/kibana/config/kibana.yml
   - source: salt://elk/kibana.yml
   - require:
     - pkg: elk-pkgs
   - template: jinja

