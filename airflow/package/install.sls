# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- set sls_config_users = tplroot ~ '.config.users' %}
{%- set sls_service_running = tplroot ~ '.service.install' %}
{%- set sls_alternatives_install = tplroot ~ '.alternatives.install' %}

include:
  - {{ sls_config_users }}
  - {{ sls_service_running }}

    {%- if grains.os_family|lower == 'arch' %}

airflow-package-install-base-devel:
  pkg.group_installed:
    - name: base-devel
    - refresh: {{ d.misc.refresh }}

    {%- endif %}
    {%- if d.pkg.airflow.deps %}

airflow-package-install-pkg-deps:
  pkg.installed:
    - names: {{ d.pkg.airflow.deps|json }}
    - refresh: {{ d.misc.refresh }}
    - require_in:
      - file: airflow-package-install-virtualenv-clean

    {%- endif %}

airflow-package-install-virtualenv-clean:
  file.absent:
    - name: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow
    - force: True
    - onlyif: test -d {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow
    - require_in:
      - file: airflow-package-install-virtualenv

airflow-package-install-virtualenv:
  file.directory:
    - name: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow
    - user: {{ d.identity.airflow.user }}
    - group: {{ d.identity.airflow.group }}
    - mode: '0755'
    - require_in:
      - virtualenv: airflow-package-install-virtualenv
      - pip: airflow-package-install-pip-installed
  virtualenv.managed:
    - name: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow
    - user: {{ d.identity.airflow.user }}
    - python: python3
    - require:
      - sls: {{ sls_config_users }}
    - require_in:
      - pip: airflow-package-install-pip-installed
        {%- if d.pkg.airflow.pips %}
    - pip_pkgs: {{ d.pkg.airflow.pips|json }}
        {%- endif %}

airflow-package-install-pip-installed:
  pip.installed:
        {%- if d.pkg.airflow.extras is iterable %}
    - name: {{ d.pkg.airflow.name }} {{ d.pkg.airflow.extras|list|replace("'","") }}
        {%- else %}
    - name: {{ d.pkg.airflow.name }}
        {%- endif %}
    - bin_env: {{ d.dir.airflow.home }}{{ d.div }}{{ d.identity.airflow.user }}{{ d.div }}airflow
    - reload_modules: {{ d.misc.reload }}
    - user: {{ d.identity.airflow.user }}
        {%- if d.pkg.airflow.pips %}
    - constraint: {{ d.pkg.airflow.constraint_file }}
        {%- endif %}
    - require_in:
      - sls: {{ sls_service_running }}
      - sls: {{ sls_alternatives_install }}
    - require:
      - sls: {{ sls_config_users }}
