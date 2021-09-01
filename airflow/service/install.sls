# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}

    {%- if grains.kernel|lower == 'linux' and 'airflow' in a.service and a.service.airflow.names %}
        {%- set sls_config_users = tplroot ~ '.config.users' %}
        {%- set sls_service_running = tplroot ~ '.service.running' %}
        {%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_config_users }}
  - {{ sls_service_running }}

        {%- for svcname in a.service.airflow.names %}

airflow-service-install-managed-{{ svcname }}:
  file.managed:
    - name: {{ a.dir.airflow.service }}/{{ svcname }}.service
    - source: {{ files_switch(['systemd.ini.jinja'],
                              lookup='airflow-service-install-managed-' ~ svcname
                 )
              }}
    - mode: '0644'
    - user: {{ a.identity.rootuser }}
    - group: {{ a.identity.rootgroup }}
    - makedirs: True
    - template: jinja
    - context:
        desc: {{ svcname|replace('.',' ') }} service
        doc: 'https://airflow.apache.org/docs/stable/installation.html'
        type: simple
        user: {{ a.identity.airflow.user }}
        group: {{ a.identity.airflow.group }}
        workdir: {{ a.dir.airflow.virtualenv }}
        start: {{ a.dir.airflow.virtualenv }}/bin/{{ svcname|replace('-',' ') }}
        stop: ''
        name: {{ svcname }}
        queues: '{{ a.service.airflow.queues|join(',') }}'
        pgpass_string: 'PGPASSWORD={{ a.database.airflow.pass }}'
    - watch_in:
      - cmd: airflow-service-install-daemon-reload
    - require_in:
      - cmd: airflow-service-install-daemon-reload
    - onchanges_in:
      - cmd: airflow-service-install-daemon-reload
            {%- if a.linux.selinux %}
      - selinux: airflow-service-install-selinux-fcontext-systemd-present
            {%- endif %}

        {%- endfor %}

airflow-service-install-daemon-reload:
  cmd.run:
    - name: systemctl daemon-reload

        {%- if a.linux.firewall == true %}

airflow-service-install-firewall-running:
  pkg.installed:
    - name: firewalld
    - reload_modules: true
  service.running:
    - name: firewalld
    - enable: True
    - require:
      - pkg: airflow-service-install-firewall-running

            {%- if a.service.airflow.ports and a.service.airflow.ports is iterable %}

airflow-service-install-firewall-present:
  firewalld.present:
    - name: public
    - ports: {{ a.service.airflow.ports|json }}
    - require:
      - pkg: airflow-service-install-firewall-running
      - service: airflow-service-install-firewall-running

            {%- endif %}
        {%- endif %}
        {%- if a.linux.selinux == true %}

airflow-service-install-selinux-fcontext-home-present:
  file.managed:
    - name: '/tmp/homedir_service_t.cil'
    - source: {{ files_switch(['homedir_service_t.cil'],
                              lookup='airflow-service-install-selinux-fcontext-home-present'
                 )
              }}
    - mode: '0644'
    - user: {{ a.identity.airflow.user }}
    - group: {{ a.identity.airflow.group }}
  cmd.run:
    - name: semodule --store targeted --priority 400 -i /tmp/homedir_service_t.cil
    - onlyif: test -x /usr/sbin/semodule
    - require:
      - file: airflow-service-install-selinux-fcontext-home-present
  selinux.fcontext_policy_present:
    - name: '/home/{{ a.identity.airflow.user }}/.local/bin(/.*)?'
    - sel_type: homedir_service_t
    - require:
      - cmd: airflow-service-install-selinux-fcontext-home-present

airflow-service-install-selinux-fcontext-home-applied:
  selinux.fcontext_policy_applied:
    - name: '/home/{{ a.identity.airflow.user }}/.local/bin/*'

airflow-service-install-selinux-fcontext-systemd-present:
  selinux.fcontext_policy_present:
    - name: '{{ a.dir.airflow.service }}(/airflow.*)?'
    - sel_user: system_u
    - sel_type: systemd_unit_file_t
    - onlyif: test -x /usr/sbin/semanage

airflow-service-install-selinux-fcontext-systemd-applied:
  selinux.fcontext_policy_applied:
    - name: '{{ a.dir.airflow.service }}/airflow*'

        {%- endif %}
    {%- endif %}
