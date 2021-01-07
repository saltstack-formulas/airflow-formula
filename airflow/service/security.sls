# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set sls_service_running = tplroot ~ '.service.running' %}

include:
  - {{ sls_service_running }}

airflow-service-security-managed:
    {%- if d.pkg.airflow.version.split('.')[0]|int == 1 %}
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

  cmd.run:
    - name: {{ d.config.airflow.path }}{{ d.div }}bin{{ d.div }}airflow users create --username {{ d.security.airflow.user }} --firstname first --lastname last --role Admin --email {{ d.security.airflow.email }} --password {{ d.security.airflow.pass }}
        {%- if grains.os != 'Windows' %}
    - runas: {{ d.identity.airflow.user }}
        {%- endif %}

    {%- endif %}
