# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

    {%- if grains.kernel == 'Linux' and d.linux.altpriority|int > 0 and grains.os_family not in ('Arch',) %}
        {%- for cmd in d.pkg.airflow.commands|unique %}

airflow-archive-alternatives-clean-{{ cmd }}:
  alternatives.remove:
    - name: link-airflow-{{ cmd }}
    - path: {{ d.pkg.airflow.path }}/bin/{{ cmd }}
    - onlyif: update-alternatives --list |grep ^link-airflow-{{ cmd }}

        {%- endfor %}
    {%- endif %}
