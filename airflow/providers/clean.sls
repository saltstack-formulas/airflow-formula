# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

    {%- if d.pkg.airflow.providers %}

airflow-providers-remove-pip-removeed:
  pip.removed:
    - names: {{ d.pkg.airflow.providers }}
    - bin_env: {{ d.dir.airflow.virtualenv }}
    - reload_modules: {{ d.misc.reload }}
    - user: {{ d.identity.airflow.user }}

    {%- else %}

airflow-providers-remove-no-list-of-providers-given:
  test.show_notification:
    - text: |
        Nothing to do. No list of providers was given in 'airflow:pkg:airflow:providers' pillar data.

    {%- endif %}
