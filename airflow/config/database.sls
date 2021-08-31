# -*- coding: utf-8 -*-
# vim: ft=sls
---
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set sls_service_running = tplroot ~ '.service.running' %}

include:
  - {{ sls_service_running }}

airflow-config-database-managed:
    {%- if a.pkg.airflow.version.split('.')[0]|int == 1 %}
  file.managed:
    - name: {{ a.dir.airflow.tmp }}/{{ a.database.airflow.script }}
    - source: {{ files_switch(['security.py.jinja'],
                              lookup='airflow-config-database-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0700'
    - user: {{ a.identity.airflow.user }}
        {%- endif %}
    - context:
        python: {{ a.dir.airflow.virtualenv }}/bin/python
        user: {{ a.database.airflow.user }}
        email: {{ a.database.airflow.email }}
        pass: {{ a.database.airflow.pass }}
    - require:
      - sls: {{ sls_service_running }}
  cmd.run:
    - names:
      - {{ a.dir.airflow.tmp }}/{{ a.database.airflow.script }}
      - rm {{ a.dir.airflow.tmp }}/{{ a.database.airflow.script }}
        {%- if grains.os != 'Windows' %}
    - runas: {{ a.identity.airflow.user }}
        {%- endif %}
    - require:
      - file: airflow-config-database-managed

    {%- else %}

  cmd.run:
    - name: {{ a.dir.airflow.virtualenv }}/bin/airflow users create --username {{ a.database.airflow.user }} --firstname first --lastname last --role Admin --email {{ a.database.airflow.email }} --password {{ a.database.airflow.pass }}  # noqa 204
        {%- if grains.os != 'Windows' %}
    - runas: {{ a.identity.airflow.user }}
    - retry: {{ a.retry_option|json }}
        {%- endif %}

    {%- endif %}
