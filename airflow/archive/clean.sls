# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}

    {%- if grains.kernel|lower in ('linux',) %}
        {%- set sls_alternatives_clean = tplroot ~ '.alternatives.clean' %}
        {%- set sls_config_clean = tplroot ~ '.config.clean' %}
        {%- set sls_service_clean = tplroot ~ '.service.clean' %}

include:
  - {{ sls_config_clean }}
  - {{ sls_service_clean }}
  - {{ sls_alternatives_clean }}

airflow-airflow-archive-absent:
  file.absent:
    - names:
      - {{ a.dir.airflow.tmp }}
      - {{ a.dir.airflow.lib }}
      - {{ a.dir.airflow.virtualenv }}
        {%- if a.linux.altpriority|int == 0 or grains.os_family in ('Arch', 'MacOS') %}
            {%- for cmd in a.pkg.airflow.commands|unique %}
      - /usr/local/bin/{{ cmd }}
            {%- endfor %}
        {%- endif %}
        {%- if 'service' in a.pkg and 'airflow' in a.pkg.service and a.pkg.service.airflow is mapping %}
            {%- for svcname in a.service.airflow.names %}
      - {{ a.dir.airflow.service }}/{{ svcname }}.service
            {%- endfor %}
        {%- endif %}
    - require:
      - sls: {{ sls_config_clean }}
      - sls: {{ sls_service_clean }}
  cmd.run:
    - name: systemctl daemon-reload

    {%- else %}

airflow-archive-install-other:
  test.show_notification:
    - text: |
        The airflow archive are unavailable/unselected for {{ salt['grains.get']('finger', grains.os_family) }}

    {%- endif %}
