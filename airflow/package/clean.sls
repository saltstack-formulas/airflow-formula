# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

airflow-package-clean-pip:
  pip.removed
    - name: {{ d.pkg.airflow.name|json }}
