{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- set sls_package_clean = tplroot ~ '.package.clean' %}

include:
  - {{ sls_service_clean }}

airflow-config-clean:
  file.absent:
    - names:
      - {{ d.dir.airflow.environ ~ d.div ~ d.environ.airflow.file }}
      - {{  d.dir.airflow.airhome }}{{ d.div }}{{ d.config.airflow.file }}
      - {{  d.dir.airflow.airhome }}{{ d.div }}{{ d.config.airflow.webserver }}
      - {{  d.dir.airflow.airhome }}{{ d.div }}config{{ d.div }}airflow_local_settings.py
    - require:
      - sls: {{ sls_service_clean }}
      - sls: {{ sls_package_clean }}

    {%- if d.identity.airflow.skip_user_state == false %}
  user.absent:
    - name: {{ d.identity.airflow.user }}
      {%- if grains.os_family == 'MacOS' %}
    - onlyif: '/usr/bin/dscl . list {{ d.dir.airflow.base }} | grep {{ d.identity.airflow.user }} >/dev/null 2>&1'
      {%- endif %}
  group.absent:
    - name: {{ d.identity.airflow.group }}
    - onchanges:
      - user: airflow-config-clean
    {%- endif %}
