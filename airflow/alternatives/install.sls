# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}

    {%- if grains.kernel == 'Linux' and d.linux.altpriority|int > 0 and grains.os_family not in ('Arch',) %}
        {%- set sls_archive_install = tplroot ~ '.archive.install' %}

include:
  - {{ sls_archive_install }}

        {%- for cmd in d.pkg.airflow.commands|unique %}

airflow-archive-alternatives-install-bin-{{ cmd }}:
            {%- if grains.os_family not in ('Suse', 'Arch') %}
  alternatives.install:
    - name: link-airflow-{{ cmd }}
    - link: /usr/local/bin/{{ cmd }}
    - order: 10
    - path: {{ d.pkg.airflow['path'] }}/{{ cmd }}
    - priority: {{ d.linux.altpriority }}
            {%- else %}
  cmd.run:
    - name: update-alternatives --install /usr/local/bin/{{ cmd }} link-airflow-{{ cmd }} {{ d.pkg.airflow['path'] }}/{{ cmd }} {{ d.linux.altpriority }} # noqa 204
            {%- endif %}

    - onlyif:
      - test -f {{ d.pkg.airflow['path'] }}/{{ cmd }}
    - unless: update-alternatives --list |grep ^link-airflow-{{ cmd }} || false
    - require:
      - sls: {{ sls_archive_install }}
    - require_in:
      - alternatives: airflow-archive-alternatives-set-bin-{{ cmd }}

airflow-archive-alternatives-set-bin-{{ cmd }}:
  alternatives.set:
    - unless: {{ grains.os_family in ('Suse', 'Arch') }} || false
    - name: link-airflow-{{ cmd }}
    - path: {{ d.pkg.airflow.path }}/{{ cmd }}
    - onlyif: test -f {{ d.pkg.airflow['path'] }}/{{ cmd }}

        {%- endfor %}
    {%- endif %}
