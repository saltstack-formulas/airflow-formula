# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}

    {%- if grains.kernel|lower == 'linux' and a.pkg.airflow.use_upstream|lower == 'archive' %}
        {%- from tplroot ~ "/files/macros.jinja" import format_kwargs with context %}
        {%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
        {%- set sls_config_users = tplroot ~ '.config.users' %}
        {%- set sls_service_running = tplroot ~ '.service.install' %}

include:
  - {{ sls_config_users }}
  - {{ sls_service_running }}

        {%- if 'deps' in a.pkg.airflow and a.pkg.airflow.deps %}
airflow-archive-install-deps:
  pkg.installed:
    - names: {{ a.pkg.airflow.deps|json }}
    - reload_modules: {{ a.misc.reload }}
    - require_in:
      - file: airflow-archive-install
        {%- endif %}

airflow-archive-install:
  file.directory:
    - name: {{ a.dir.airflow.airhome }}
    - makedirs: True
    - clean: {{ a.misc.clean }}
    - require_in:
      - archive: airflow-archive-install
            {%- if grains.os|lower != 'windows' %}
    - mode: 775
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
    - recurse:
        - user
        - group
        - mode
            {%- endif %}
    - require:
      - sls: {{ sls_config_users }}
  archive.extracted:
    {{- format_kwargs(a.pkg.airflow.archive) }}
    - retry: {{ a.retry_option|json }}
    - enforce_toplevel: false
    - trim_output: true
            {%- if grains.os|lower != 'windows' %}
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
    - recurse:
        - user
        - group
            {%- endif %}
    - require:
      - file: airflow-archive-install
    - require_in:
      - sls: {{ sls_service_running }}

        {%- if a.linux.altpriority|int == 0 or grains.os_family in ('Arch', 'MacOS') %}
            {%- for cmd in a.pkg.airflow.commands|unique %}

airflow-archive-install-symlink-{{ cmd }}:
  file.symlink:
    - name: /usr/local/bin/{{ cmd }}
    - target: {{ a.dir.airflow.virtualenv }}/bin/{{ cmd }}
    - force: True
    - onchanges:
      - archive: airflow-archive-install
    - require:
      - archive: airflow-archive-install

            {%- endfor %}
        {%- endif %}
    {%- else %}

airflow-archive-install-other:
  test.show_notification:
    - text: |
        The airflow archive is unavailable/unselected for {{ salt['grains.get']('finger', grains.os_family) }}

    {%- endif %}
