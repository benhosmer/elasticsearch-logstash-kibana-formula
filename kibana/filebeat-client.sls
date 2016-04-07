{% set elk_gpg_key_url = salt['pillar.get']('elk_gpg_key_url', 'https://packages.elastic.co/GPG-KEY-elasticsearch') %}
{% set filebeat_download_url = salt['pillar.get']('filebeat_download_url',' https://download.elastic.co/beats/filebeat/filebeat-1.1.2-x86_64.rpm') %} 

java-jdk-install:
  pkg.installed:
    - pkgs:
      - java-1.8.0-openjdk

elk-repo-gpg-key:
  file.managed:
    - name: /etc/pki/rpm-gpg/GPG-KEY-elasticsearch
    - source: {{ elk_gpg_key_url }}
    - source_hash: md5=41c14e54aa0d201ae680bb34c199be98

filebeat-pkg:
  pkg.installed:
    - sources:
      - filebeat: {{ filebeat_download_url }}
    - require:
      - file: elk-repo-gpg-key

filebeat-service:
  service.running:
    - name: filebeat
    - enable: True
    - require:
      - pkg: java-jdk-install

filebeat-conf:
  file.managed:
    - name: /etc/filebeat/filebeat.yml
    - source: salt://elk/filebeat.yml
    - require:
      - pkg: filebeat-pkg
    - template: jinja

