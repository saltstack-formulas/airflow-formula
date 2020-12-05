# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

    {%- if d.config.airflow.content %}
        {%- set sls_service_running = tplroot ~ '.service.running' %}

include:
  - {{ sls_service_running }}

airflow-service-security-managed:
  file.managed:
    - name: {{ d.dir.airflow.tmp }}{{ d.div }}{{ d.security.airflow.script }}
    - source: {{ files_switch(['security.py.jinja'],
                              lookup='airflow-service-security-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0700'
    - user: {{ d.identity.airflow.user }}
        {%- endif %}
    - context:
        python: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow{{ d.div }}bin{{ d.div }}python
        user: {{ d.security.airflow.user }}
        email: {{ d.security.airflow.email }}
        pass: {{ d.security.airflow.pass }}
    - require:
      - sls: {{ sls_service_running }}
  cmd.run:
    - names:
      - {{ d.dir.airflow.tmp }}{{ d.div }}{{ d.security.airflow.script }}
      - rm {{ d.dir.airflow.tmp }}{{ d.div }}{{ d.security.airflow.script }}
        {%- if grains.os != 'Windows' %}
    - runas: {{ d.identity.airflow.user }}
        {%- endif %}
    - require:
      - file: airflow-service-security-managed

    {%- else %}

airflow-service-install-none:
  test.show_notification:
    - text: |
        No security configuration was provided for {{ salt['grains.get']('finger', grains.os_family) }}

    {%- endif %}
