# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
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
    - refresh: {{ a.misc.refresh }}

    {%- endif %}
    {%- if a.pkg.airflow.remove %}

airflow-package-install-pkg-removed:
  pkg.removed:
    - names: {{ a.pkg.airflow.remove|yaml }}

    {%- endif %}
    {%- if a.pkg.airflow.deps %}

airflow-package-install-pkg-deps:
  pkg.installed:
    - names: {{ a.pkg.airflow.deps|json }}
    - refresh: {{ a.misc.refresh }}
    - require_in:
      - file: airflow-package-install-virtualenv-clean

    {%- endif %}

airflow-package-install-virtualenv-clean:
  file.absent:
    - name: {{ a.dir.airflow.virtualenv }}
    - force: True
    - retry: {{ a.retry_option|json }}   # weird; removal (root rm -fr) fails intermittently?
    - onlyif: test -d {{ a.dir.airflow.virtualenv }}
    - require_in:
      - file: airflow-package-install-virtualenv

airflow-package-install-virtualenv:
  file.directory:
    - name: {{ a.dir.airflow.virtualenv }}
            {%- if grains.os|lower != 'windows' %}
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
    - mode: '0755'
    - makedirs: True
    - recurse:
        - user
        - group
        - mode
            {%- endif %}
    - require_in:
      - virtualenv: airflow-package-install-virtualenv
      - pip: airflow-package-install-pip-installed

  virtualenv.managed:
    - name: {{ a.dir.airflow.virtualenv }}
    - user: {{ a.identity.airflow.user }}
    - runas: {{ a.identity.airflow.user }}
    - python: python3
    - venv_bin: {{ a.config.airflow.venv_cmd or 'virtualenv' }}
    - no_deps: {{ a.pkg.airflow.no_pips_deps }}
    - constraint: {{ a.pkg.airflow.constraint_file }}
    - require:
      - sls: {{ sls_config_users }}
    - require_in:
      - pip: airflow-package-install-pip-installed
        {%- if a.pkg.airflow.pips %}
    - pip_pkgs: {{ a.pkg.airflow.pips|json }}
        {%- endif %}

airflow-package-install-pip-installed:
  pip.installed:
        {%- if a.pkg.airflow.extras is iterable %}
    - name: {{ a.pkg.airflow.name }}{{ a.pkg.airflow.extras|list|replace("'","") }}=={{ a.pkg.airflow.version }}
        {%- else %}
    - name: {{ a.pkg.airflow.name }}
        {%- endif %}
    - bin_env: {{ a.dir.airflow.virtualenv }}
    - env_vars:
      AIRFLOW_GPL_UNIDECODE: 'yes'
    - reload_modules: {{ a.misc.reload }}
    - user: {{ a.identity.airflow.user }}
    - constraint: {{ a.pkg.airflow.constraint_file }}
    - require_in:
      - sls: {{ sls_service_running }}
      - sls: {{ sls_alternatives_install }}
    - require:
      - sls: {{ sls_config_users }}
