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
      - {{ d.dir.airflow.home ~ d.div ~ d.identity.airflow.user }}
    - require:
      - sls: {{ sls_service_clean }}
      - sls: {{ sls_package_clean }}
  user.absent:
    - name: {{ d.identity.airflow.user }}
      {%- if grains.os_family == 'MacOS' %}
    - onlyif: '/usr/bin/dscl . list {{ d.dir.airflow.home }} | grep {{ d.identity.airflow.user }} >/dev/null 2>&1'
      {%- endif %}
    - require:
      - file: airflow-config-clean
  group.absent:
    - name: {{ d.identity.airflow.group }}
    - require:
      - user: airflow-config-clean
