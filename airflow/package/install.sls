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

    {%- if d.pkg.airflow.deps %}

airflow-package-install-pkg-deps:
  pkg.installed:
    - names: {{ d.pkg.airflow.deps|json }}
    - refresh: {{ d.misc.refresh }}
    - require_in:
      - pip: airflow-package-install-pip-installed

    {%- endif %}
    {%- if d.pkg.airflow.pips %}

airflow-package-install-pips:
  pip.installed:
    - names: {{ d.pkg.airflow.pips|json }}
    - reload_modules: {{ d.misc.reload }}
    - user: {{ d.identity.airflow.user }}
    - require_in:
      - pip: airflow-package-install-pip-installed
    - require:
      - sls: {{ sls_config_users }}

    {%- endif %}

airflow-package-install-pip-installed:
  pip.installed:
        {%- if d.pkg.airflow.extras is iterable %}
    - name: {{ d.pkg.airflow.name }} {{ d.pkg.airflow.extras|list|replace("'","") }}
        {%- else %}
    - name: {{ d.pkg.airflow.name }}
        {%- endif %}
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
