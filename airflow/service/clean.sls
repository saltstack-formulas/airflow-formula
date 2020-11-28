# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow with context %}

airflow-service-clean-service-dead:
  service.dead:
    - name: {{ airflow.service.name }}
    - enable: False
