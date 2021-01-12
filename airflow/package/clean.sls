# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}

include:
  - {{ sls_config_clean }}
  - {{ sls_service_clean }}

airflow-package-clean-pip:
  pip.removed:
        {%- if d.pkg.airflow.extras is iterable %}
    - name: {{ d.pkg.airflow.name }} {{ d.pkg.airflow.extras|list|replace("'","") }}
        {%- else %}
    - name: {{ d.pkg.airflow.name }}
        {%- endif %}
    - user: {{ d.identity.airflow.user }}
    - require:
      - sls: {{ sls_service_clean }}
    - require_in:
      - sls: {{ sls_config_clean }}
    - unless:
             {%- if grains.os_family == 'MacOS' %}
      - /usr/bin/dscl . list {{ d.dir.airflow.home }} | grep {{ d.identity.airflow.user }} >/dev/null 2>&1
             {%- elif grains.os != 'Windows' %}
      - getent passwd {{ d.identity.airflow.user }} | true
             {%- endif %}
  file.absent:
    - name: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}.local
    - name: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow
