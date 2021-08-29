# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}

    {%- if grains.kernel|lower == 'linux' and 'airflow' in a.service and a.service.airflow.names %}
        {%- set sls_config_users = tplroot ~ '.config.users' %}
        {%- set sls_service_running = tplroot ~ '.service.running' %}
        {%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_config_users }}
  - {{ sls_service_running }}

        {%- for svcname in a.service.airflow.names %}

airflow-service-install-managed-{{ svcname }}:
  file.managed:
    - name: {{ a.dir.airflow.service }}{{ a.div }}{{ svcname }}.service
    - source: {{ files_switch(['systemd.ini.jinja'],
                              lookup='airflow-service-install-managed-' ~ svcname
                 )
              }}
    - mode: '0644'
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
    - makedirs: True
    - template: jinja
    - context:
        desc: {{ svcname|replace('.',' ') }} service
        doc: 'https://airflow.apache.org/docs/stable/installation.html'
        type: simple
        user: {{ a.identity.airflow.user }}
        group: {{ a.identity.airflow.group }}
        workdir: {{ a.dir.airflow.virtualenv }}
        start: {{ a.dir.airflow.virtualenv }}{{ a.div }}bin{{ a.div }}{{ svcname|replace('-',' ') }}
        stop: ''
        name: {{ svcname }}
        queues: '{{ a.service.airflow.queues|join(',') }}'
        pgpass: '{{ a.database.airflow.pass }}'
    - watch_in:
      - cmd: airflow-service-install-daemon-reload
    - require_in:
      - cmd: airflow-service-install-daemon-reload

        {%- endfor %}

airflow-service-install-daemon-reload:
  cmd.run:
    - name: systemctl daemon-reload

    {%- endif %}
