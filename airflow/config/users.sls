# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}

    {%- if a.identity.airflow.skip_user_state == false %}

airflow-config-users-install-group:
  group.present:
    - name: {{ a.identity.airflow.group }}

airflow-config-users-install-user:
  user.present:
    - name: {{ a.identity.airflow.user }}
    - groups:
      - {{ a.identity.airflow.group }}
        {%- if grains.os != 'Windows' %}
    - shell: /bin/bash
            {%- if grains.os_family == 'MacOS' %}
    - unless: /usr/bin/dscl . list {{ a.dir.airflow.base }} | grep {{ a.identity.airflow.user }} >/dev/null 2>&1
            {%- endif %}
        {%- endif %}
    - require:
      - group: airflow-config-users-install-group

    {%- else %}

airflow-config-users-skip-user:
  test.show_notification:
    - text: |
        Skipping user/group creation because 'skip_user_state' was requested

    {%- endif %}
