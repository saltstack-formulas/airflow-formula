# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

    {%- if d.config.airflow.content %}
        {%- set sls_archive_install = tplroot ~ '.archive.install' %}
        {%- set sls_package_install = tplroot ~ '.package.install' %}

include:
  - {{ sls_archive_install if d.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

airflow-config-file-managed:
  file.managed:
    - name: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow{{ d.div }}{{ d.config.airflow.file }}
    - source: {{ files_switch(['airflow.cfg.jinja'],
                              lookup='airflow-config-file-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0644'
    - user: {{ d.identity.airflow.user }}
    - group: {{ d.identity.airflow.group }}
        {%- endif %}
    - context:
        airversion: {{ d.pkg.airflow.version.split('.')[0]|int }}
        config: {{ d.config.airflow.content|json }}
    - require:
      - sls: {{ sls_archive_install if d.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

airflow-config-config-managed:
  file.managed:
    - name: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow{{ d.div }}config{{ d.div }}airflow_local_settings.py
    - source: {{ files_switch(['local_settings.py.jinja'],
                              lookup='airflow-config-config-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0644'
    - user: {{ d.identity.airflow.user }}
    - group: {{ d.identity.airflow.group }}
        {%- endif %}
    - context:
        color: {{ d.config.airflow.state_colors|json }}
    - require:
      - sls: {{ sls_archive_install if d.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

    {%- else %}

airflow-config-install-none:
  test.show_notification:
    - text: |
        No configuration was provided for {{ salt['grains.get']('finger', grains.os_family) }}

    {%- endif %}
