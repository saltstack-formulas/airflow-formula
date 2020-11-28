# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

    {%- if grains.kernel|lower == 'linux' and d.pkg.airflow.use_upstream|lower == 'archive' %}
        {%- from tplroot ~ "/files/macros.jinja" import format_kwargs with context %}
        {%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
        {%- set sls_config_users = tplroot ~ '.config.users' %}
        {%- set sls_service_running = tplroot ~ '.service.install' %}

include:
  - {{ sls_config_users }}
  - {{ sls_service_running }}

        {%- if 'deps' in d.pkg.airflow and d.pkg.airflow.deps %}
airflow-archive-install-deps:
  pkg.installed:
    - names: {{ d.pkg.airflow.deps|json }}
    - reload_modules: {{ d.misc.reload }}
    - require_in:
      - file: airflow-archive-install
        {%- endif %}

airflow-archive-install:
  file.directory:
    - name: {{ d.pkg.airflow.path }}
    - makedirs: True
    - clean: {{ d.misc.clean }}
    - require_in:
      - archive: airflow-archive-install
    - mode: 755
    - user: {{ d.identity.airflow.user }}
    - group: {{ d.identity.airflow.group }}
    - recurse:
        - user
        - group
        - mode
    - require:
      - sls: {{ sls_config_users }}
  archive.extracted:
    {{- format_kwargs(d.pkg.airflow['archive']) }}
    - retry: {{ d.retry_option|json }}
    - enforce_toplevel: false
    - trim_output: true
    - user: {{ d.identity.airflow.user }}
    - group: {{ d.identity.airflow.group }}
    - recurse:
        - user
        - group
    - require:
      - file: airflow-archive-install
    - require_in:
      - sls: {{ sls_service_running }}

        {%- if d.linux.altpriority|int == 0 or grains.os_family in ('Arch', 'MacOS') %}
            {%- for cmd in d.pkg.airflow.commands|unique %}

airflow-archive-install-symlink-{{ cmd }}:
  file.symlink:
    - name: /usr/local/bin/{{ cmd }}
    - target: {{ d.pkg.airflow.path }}/bin/{{ cmd }}
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
