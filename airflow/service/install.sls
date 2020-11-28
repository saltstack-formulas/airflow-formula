# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

    {%- if grains.kernel|lower == 'linux' and 'airflow' in d.service and d.service.airflow.names %}
        {%- set sls_config_users = tplroot ~ '.config.users' %}
        {%- set sls_service_running = tplroot ~ '.service.running' %}
        {%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_config_users }}
  - {{ sls_service_running }}

airflow-service-install-database:
  cmd.run:
    - name: {{ d.pkg.airflow.path }}{{ d.div }}bin{{ d.div }}airflow initdb
    - runas: {{ d.identity.airflow.user }}

        {%- for svcname in d.service.airflow.names %}

airflow-service-install-managed-{{ svcname }}:
  file.managed:
    - name: {{ d.dir.airflow.service }}/{{ svcname }}.service
    - source: {{ files_switch(['systemd.ini.jinja'],
                              lookup='airflow-service-install-managed-' ~ svcname
                 )
              }}
    - mode: '0644'
    - user: {{ d.identity.airflow.user }}
    - group: {{ d.identity.airflow.group }}
    - makedirs: True
    - template: jinja
    - context:
        desc: {{ svcname|replace('.',' ') }} service
        wants: ''
        after: ''
        doc: 'https://airflow.apache.org/docs/stable/installation.html'
        type: simple
        user: {{ d.identity.airflow.user }}
        group: {{ d.identity.airflow.group }}
        workdir: /home/{{ d.identity.airflow.user }}
        start: {{ d.pkg.airflow.path }}/bin/{{ svcname|replace('-',' ') }}
        stop: ''
        name: {{ svcname }}
    - require_in:
      - cmd: airflow-service-install-daemon-reload
      - service: airflow-service-running-{{ svcname }}

        {%- endfor %}

airflow-service-install-daemon-reload:
  cmd.run:
    - name: systemctl daemon-reload

    {%- endif %}
