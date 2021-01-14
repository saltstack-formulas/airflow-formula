# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

    {%- if d.pkg.airflow.providers %}

airflow-providers-install-pip-installed:
  pip.installed:
    - names: {{ d.pkg.airflow.providers }}
    - bin_env: {{ d.dir.airflow.virtualenv }}
    - env_vars:
      AIRFLOW_GPL_UNIDECODE: 'yes'
    - reload_modules: {{ d.misc.reload }}
    - user: {{ d.identity.airflow.user }}

    {%- else %}

airflow-providers-install-no-list-of-providers-given:
  test.show_notification:
    - text: |
        Nothing to do. No list of providers was given in 'airflow:pkg:airflow:providers' pillar data.

    {%- endif %}
