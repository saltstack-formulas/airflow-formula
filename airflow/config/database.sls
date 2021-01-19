# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set sls_service_running = tplroot ~ '.service.running' %}

include:
  - {{ sls_service_running }}

airflow-config-database-managed:
    {%- if d.pkg.airflow.version.split('.')[0]|int == 1 %}
  file.managed:
    - name: {{ d.dir.airflow.tmp }}{{ d.div }}{{ d.database.airflow.script }}
    - source: {{ files_switch(['security.py.jinja'],
                              lookup='airflow-config-database-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0700'
    - user: {{ d.identity.airflow.user }}
        {%- endif %}
    - context:
        python: {{ d.dir.airflow.virtualenv }}{{ d.div }}bin{{ d.div }}python
        user: {{ d.database.airflow.user }}
        email: {{ d.database.airflow.email }}
        pass: {{ d.database.airflow.pass }}
    - require:
      - sls: {{ sls_service_running }}
  cmd.run:
    - names:
      - {{ d.dir.airflow.tmp }}{{ d.div }}{{ d.database.airflow.script }}
      - rm {{ d.dir.airflow.tmp }}{{ d.div }}{{ d.database.airflow.script }}
        {%- if grains.os != 'Windows' %}
    - runas: {{ d.identity.airflow.user }}
        {%- endif %}
    - require:
      - file: airflow-config-database-managed

    {%- else %}

  cmd.run:
    - name: {{ d.dir.airflow.virtualenv }}{{ d.div }}bin{{ d.div }}airflow users create --username {{ d.database.airflow.user }} --firstname first --lastname last --role Admin --email {{ d.database.airflow.email }} --password {{ d.database.airflow.pass }}
        {%- if grains.os != 'Windows' %}
    - runas: {{ d.identity.airflow.user }}
        {%- endif %}

    {%- endif %}
