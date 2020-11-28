# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

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
      - {{ d.dir.airflow.tmp }}
      - {{ d.dir.airflow.lib }}
        {%- if 'path' in d.pkg.airflow %}
      - {{ d.pkg.airflow.path }}
        {%- endif %}
        {%- if d.linux.altpriority|int == 0 or grains.os_family in ('Arch', 'MacOS') %}
            {%- for cmd in d.pkg.airflow.commands|unique %}
      - /usr/local/bin/{{ cmd }}
            {%- endfor %}
        {%- endif %}
        {%- if 'service' in d.pkg and 'airflow' in d.pkg.service and d.pkg.service.airflow is mapping %}
            {%- for svcname in d.service.airflow.names %}
      - {{ d.dir.airflow.service }}/{{ svcname }}.service
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
