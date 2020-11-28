# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}

include:
  - {{ sls_service_clean }}

airflow-config-clean:
  file.absent:
    - names:
      - {{ d.dir.airflow.environ }}{{ d.div }}{{ d.environ.airflow.file }}
      - {{ d.dir.airflow.config }}{{ d.div }}{{ d.config.airflow.file }}
    - require:
      - sls: {{ sls_service_clean }}
  user.absent:
    - name: {{ d.identity.airflow.user }}
      {%- if grains.os_family == 'MacOS' %}
    - onlyif: /usr/bin/dscl . list /Users | grep {{ d.identity.airflow.user }} >/dev/null 2>&1
      {%- endif %}
  group.absent:
    - name: {{ d.identity.airflow.group }}
    - require:
       - sls: {{ sls_service_clean }}

