# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

    {%- if a.environ.airflow.content %}
        {%- set sls_archive_install = tplroot ~ '.archive.install' %}
        {%- set sls_package_install = tplroot ~ '.package.install' %}

include:
  - {{ sls_archive_install if a.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

airflow-config-install-environ_file:
  file.managed:
    - name: {{ a.dir.airflow.environ }}/{{ a.environ.airflow.file }}
    - source: {{ files_switch(['environ.sh.jinja'],
                              lookup='airflow-config-install-environ_file'
                 )
              }}
    - makedirs: True
    - template: jinja
    - context:
        environ: {{ a.environ.airflow.content|json }}
    - watch_in:
        {%- for svcname in a.service.airflow.enabled %}
      - service: airflow-service-running-{{ svcname }}
        {%- endfor %}
        {%- if grains.os != 'Windows' %}
    - mode: '0640'
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
        {%- endif %}
    - require:
      - sls: {{ sls_archive_install if a.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

    {%- else %}

airflow-environ-install-not-provided:
  test.show_notification:
    - text: |
        No environment configuration was provided for {{ salt['grains.get']('finger', grains.os_family) }}

    {%- endif %}
