{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- set sls_package_clean = tplroot ~ '.package.clean' %}

include:
  - {{ sls_service_clean }}

airflow-config-clean:
  file.absent:
    - names:
      - {{ a.dir.airflow.environ ~ '/' ~ a.environ.airflow.file }}
      - {{ a.dir.airflow.airhome }}/{{ a.config.airflow.file }}
      - {{ a.dir.airflow.airhome }}/{{ a.config.airflow.webserver }}
      - {{ a.dir.airflow.airhome }}/config/airflow_local_settings.py
    - require:
      - sls: {{ sls_service_clean }}
      - sls: {{ sls_package_clean }}

    {%- if a.identity.airflow.create_user_group == true %}
  user.absent:
    - name: {{ a.identity.airflow.user }}
      {%- if grains.os_family == 'MacOS' %}
    - onlyif: '/usr/bin/dscl . list {{ a.dir.airflow.base }} | grep {{ a.identity.airflow.user }} >/dev/null 2>&1'
      {%- endif %}
  group.absent:
    - name: {{ a.identity.airflow.group }}
    - onchanges:
      - user: airflow-config-clean
    {%- endif %}
