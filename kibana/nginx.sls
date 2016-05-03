{% set nginx_yum_domain = salt['pillar.get']('nginx_yum_domain', 'http://nginx.org') %}


nginx-repo:
  pkgrepo.managed:
    - humanname: nginx
    - baseurl: {{ nginx_yum_domain }}/packages/centos/7/x86_64/
    - gpgcheck: 0

nginx:
  pkg.installed:
    - name: nginx
    - require:
      - pkgrepo: nginx-repo
    - fromrepo: nginx-repo

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

# This is needed for htpasswd utility
httpd-tools:
  pkg.installed:
    - name: httpd-tools

nginx-auth:
  webutil.user_exists:
    - name: rbt
    - password: GjjCNUQKc2E
    - htpasswd_file: /etc/nginx/elk-nginx-auth.passwd
    - require:
      - pkg: nginx
      - pkg: httpd-tools

start-nginx:
  service.running:
    - name: nginx
    - require:
      - file: nginx-conf
    - enable: true
    - reload: true
    - watch:
      - file: nginx-conf
      - webutil: nginx-auth

{% if salt['cmd.retcode']('which firewalld') !== 0 %}
install-firewalld:
  pkg.installed:
    - name: firewalld

stop-iptables:
  service.dead:
    - name: iptables
    - enable: False
{% endif %}

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
      - 443/tcp

