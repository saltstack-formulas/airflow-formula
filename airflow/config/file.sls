# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

  {%- if a.config.airflow.content %}
      {%- set sls_archive_install = tplroot ~ '.archive.install' %}
      {%- set sls_package_install = tplroot ~ '.package.install' %}
      {%- set airflow_cfg_jinja = 'airflowV' ~ a.pkg.airflow.version.split('.')[0]|int ~ '.cfg.jinja' %}

include:
  - {{ sls_archive_install if a.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

airflow-config-file-managed:
  file.managed:
    - name: {{  a.dir.airflow.airhome }}{{ a.div }}{{ a.config.airflow.file }}
    - source: {{ files_switch([ airflow_cfg_jinja ],
                              lookup='airflow-config-file-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0644'
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
        {%- endif %}
    - context:
        airflow_home: {{ a.dir.airflow.airhome }}
        airversion: {{ a.pkg.airflow.version.split('.')[0]|int }}
        flask: {{ a.config.airflow.flask|json }}
        content: {{ a.config.airflow.content|json }}
    - require:
      - sls: {{ sls_archive_install if a.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

airflow-config-config-managed:
  file.managed:
    - name: {{ a.dir.airflow.airhome }}{{ a.div }}config{{ a.div }}airflow_local_settings.py
    - source: {{ files_switch(['local_settings.py.jinja'],
                              lookup='airflow-config-config-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0644'
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
        {%- endif %}
    - context:
        color: {{ a.config.airflow.state_colors|json }}
    - require:
      - sls: {{ sls_archive_install if a.pkg.airflow.use_upstream|lower == 'archive' else sls_package_install }}

airflow-config-bash-profile-managed:
  file.replace:
    - name: {{ a.dir.airflow.userhome }}/.bash_profile
    - pattern: '"^PATH=(.*):$HOME/.local/bin(.*)"'
    - repl: 'PATH=$HOME/.local/bin:\1:\2'
    - append_if_not_found: True
    - not_found_content: 'export PATH=$HOME/.local/bin:$PATH'
    - onlyif: test -f {{ a.dir.airflow.userhome }}/.bash_profile

airflow-config-dags-directory:
  file.directory:
    - makedirs: True
        {%- if 'dags_folder' in a.config.airflow.content.core %}
    - name: {{ a.config.airflow.content.core.dags_folder }}
        {%- else %}
    - name: {{ a.dir.airflow.userhome ~ a.div ~ 'dags' }}
        {%- endif %}
        {%- if grains.os != 'Windows' %}
    - mode: '0775'
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
    - recurse:
        - user
        - group
        - mode
        {%- endif %}

  {%- else %}

airflow-config-install-none:
  test.show_notification:
    - text: |
        No configuration was provided for {{ salt['grains.get']('finger', grains.os_family) }}

  {%- endif %}
