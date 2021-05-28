# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

    {%- if d.config.airflow.flask %}

airflow-webserver-file-managed:
  file.managed:
    - name: {{  d.dir.airflow.airhome }}{{ d.div }}{{ d.config.airflow.webserver }}
    - source: {{ files_switch(['webserver_config.py.jinja'],
                              lookup='airflow-webserver-file-managed'
                 )
              }}
    - makedirs: True
    - template: jinja
        {%- if grains.os != 'Windows' %}
    - mode: '0644'
    - user: {{ d.identity.airflow.user }}
    - group: {{ d.identity.airflow.group }}
        {%- endif %}
    - context:
        flask: {{ d.config.airflow.flask|json }}
        content: {{ d.config.airflow.content|json }}

    {%- else %}

airflow-webserver-install-none:
  test.show_notification:
    - text: |
        No custom configuration was provided for flask-appbuilder webserver, so airflow uses defaults.

    {%- endif %}
