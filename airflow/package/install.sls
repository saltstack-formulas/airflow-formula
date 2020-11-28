# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

        {%- if d.pkg.airflow.pips %}

airflow-package-install-pips:
  pip.installed
    - names: {{ d.pkg.airflow.pips|json }}
    - reload_modules: True
    - require_in:
      - pip: airflow-package-install-pip-installed

        {%- endif %}
        {%- if d.pkg.airflow.deps %}

airflow-package-install-pkg-deps:
  pkg.installed:
    - name: {{ d.pkg.airflow.deps|json }}
    - refresh: {{ d.misc.refresh }}
    - require_in:
      - pip: airflow-package-install-pip-installed

        {%- endif %}

airflow-package-install-pip-installed:
  pip.installed
    - name: {{ d.pkg.airflow.name|json }}{{
    - reload_modules: {{ d.misc.reload }}
        {%- if d.pkg.airflow.pips %}
    - constraint: {{ d.pkg.airflow.constraint_file }}
        {%- endif %}
