# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

airflow-config-users-install-group:
  group.present:
    - name: {{ d.identity.airflow.group }}
    - require_in:
      - user: airflow-config-users-install-user

airflow-config-users-install-user:
  user.present:
    - name: {{ d.identity.airflow.user }}
    - groups:
      - {{ d.identity.airflow.group }}
        {%- if grains.os != 'Windows' %}
    - shell: /bin/bash
            {%- if grains.os_family == 'MacOS' %}
    - unless: /usr/bin/dscl . list {{ d.dir.airflow.home }} | grep {{ d.identity.airflow.user }} >/dev/null 2>&1
            {%- endif %}
        {%- endif %}
