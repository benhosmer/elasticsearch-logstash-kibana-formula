{% set nginx_yum_domain = salt['pillar.get']('nginx_yum_domain', 'http://nginx.org') %}


nginx-repo:
  pkgrepo.managed:
    - humanname: nginx
    - baseurl: {{ nginx_yum_domain }}/packages/centos/7/x86_64/
    - gpgcheck: 0
    {% if pillar['c2senv'] == True %}
    {% if "https" in pillar['nginx_yum_domain'] %}
    - proxy: {{ pillar['proxies']['https'] }}
    {% else %}
    - proxy: {{ pillar['proxies']['http'] }}
    {% endif %}
    {% endif %} 

nginx:
  pkg.installed:
    - name: nginx
    - require:
      - pkgrepo: nginx-repo

disable-default-conf:
  file.absent:
    - names:
      - /etc/nginx/conf.d/default.conf
      - /etc/nginx/conf.d/example_ssl.conf

{% if pillar['elk_ssl'] == True %}
nginx-conf:
  file.managed:
    - name: /etc/nginx/conf.d/elk-ssl.conf
    - source: salt://elk/elk-nginx-ssl.conf
    - template: jinja
    - require:
      - pkg: nginx
{% else %}
nginx-conf:
  file.managed:
    - name: /etc/nginx/conf.d/elk.conf
    - source: salt://elk/elk-nginx.conf
    - template: jinja
    - require:
      - pkg: nginx
{% endif %}
  
start-nginx:
  service.running:
    - name: nginx
    - require:
      - file: nginx-conf
    - enable: true
    - reload: true
    - watch:
      - file: nginx-conf

firewalld-running:
  service.running:
    - name: firewalld
    - enable: True
    - watch:
      - firewalld: public-zone

# Open the firewall to allow http traffic
public-zone:
  firewalld.present:
    - name: public
    - services:
      - http
    - ports:
      - 80/tcp    
      #- 443/tcp

