# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

    {%- if d.environ.airflow.content %}
        {%- set sls_archive_install = tplroot ~ '.archive.install' %}
        {%- set sls_package_install = tplroot ~ '.package.install' %}

include:
  - {{ sls_archive_install if d.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

airflow-config-install-environ_file:
  file.managed:
    - name: {{ d.dir.airflow.environ }}{{ d.div }}{{ d.environ.airflow.file }}
    - source: {{ files_switch(['environ.sh.jinja'],
                              lookup='airflow-config-install-environ_file'
                 )
              }}
    - makedirs: True
    - template: jinja
    - context:
        environ: {{ d.environ.airflow.content|json }}
    - watch_in:
        {%- for svcname in d.service.airflow.enabled %}
      - service: airflow-service-running-{{ svcname }}
        {%- endfor %}
        {%- if grains.os != 'Windows' %}
    - mode: '0640'
    - user: {{ d.identity.airflow.user }}
    - group: {{ d.identity.airflow.group }}
        {%- endif %}
    - require:
      - sls: {{ sls_archive_install if d.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

    {%- else %}

airflow-environ-install-not-provided:
  test.show_notification:
    - text: |
        No environment configuration was provided for {{ salt['grains.get']('finger', grains.os_family) }}

    {%- endif %}
