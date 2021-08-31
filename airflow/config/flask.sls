# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

    {%- if a.config.airflow.flask %}

airflow-webserver-file-managed:
  file.managed:
    - name: {{  a.dir.airflow.airhome }}/{{ a.config.airflow.webserver }}
    - source: {{ files_switch(['webserver_config.py.jinja'],
                              lookup='airflow-webserver-file-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0644'
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
        {%- endif %}
    - context:
        flask: {{ a.config.airflow.flask|json }}

    {%- else %}

airflow-webserver-install-none:
  test.show_notification:
    - text: |
        No custom configuration was provided for flask-appbuilder webserver, so airflow uses defaults.

    {%- endif %}
