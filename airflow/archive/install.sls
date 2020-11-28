# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import data as d with context %}

    {%- if grains.kernel|lower == 'linux' and d.pkg.airflow.use_upstream|lower == 'archive' and 'archive' in d.pkg.airflow %}
        {%- from tplroot ~ "/files/macros.jinja" import format_kwargs with context %}
        {%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

airflow-software-airflow-archive-install:
        {%- if 'deps' in d.pkg and d.pkg.deps %}
            {%- if grains.os|lower == 'centos' %}
                # https://github.com/saltstack/salt/issues/58920
  pip.installed:
    - name: airflow
            {%- endif %}
  pkg.installed:
    - names: {{ d.pkg.deps|json }}
    - reload_modules: {{ d.misc.reload or true }}
    - require_in:
      - file: airflow-software-airflow-archive-install
        {%- endif %}
  file.directory:
    - name: {{ d.pkg.airflow.path }}
    - makedirs: True
    - clean: {{ d.misc.clean }}
    - require_in:
      - archive: airflow-software-airflow-archive-install
    - mode: 755
    - user: {{ d.identity.rootuser }}
    - group: {{ d.identity.rootgroup }}
    - recurse:
        - user
        - group
        - mode
  archive.extracted:
    - unless: test -x {{ d.pkg.airflow.path }}{{ d.div }}airflow
    {{- format_kwargs(d.pkg.airflow['archive']) }}
    - retry: {{ d.retry_option|json }}
    - enforce_toplevel: false
    - trim_output: true
    - user: {{ d.identity.rootuser }}
    - group: {{ d.identity.rootgroup }}
    - recurse:
        - user
        - group
    - require:
      - file: airflow-software-airflow-archive-install

        {%- if d.linux.altpriority|int == 0 or grains.os_family in ('Arch', 'MacOS') %}
            {%- for cmd in d.pkg.airflow.commands|unique %}

airflow-software-airflow-archive-install-symlink-{{ cmd }}:
  file.symlink:
    - name: /usr/local/bin/{{ cmd }}
    - target: {{ d.pkg.airflow.path }}/{{ cmd }}
    - force: True
    - onchanges:
      - archive: airflow-software-airflow-archive-install
    - require:
      - archive: airflow-software-airflow-archive-install

            {%- endfor %}
        {%- endif %}
        {%- if 'service' in d.pkg.airflow and d.pkg.airflow.service is mapping %}

airflow-software-airflow-archive-install-file-directory:
  file.directory:
    - name: {{ d.dir.lib }}
    - makedirs: True
    - user: {{ d.identity.rootuser }}
    - group: {{ d.identity.rootgroup }}
    - mode: '0755'

airflow-software-airflow-archive-install-managed-service:
  file.managed:
    - name: {{ d.dir.service }}/{{ d.pkg.airflow.service.name }}.service
    - source: {{ files_switch(['systemd.ini.jinja'],
                              lookup=formula ~ '-software-airflow-archive-install-managed-service'
                 )
              }}
    - mode: '0644'
    - user: {{ d.identity.rootuser }}
    - group: {{ d.identity.rootgroup }}
    - makedirs: True
    - template: jinja
    - context:
        desc: {{ d.pkg.airflow.service.name }} service
        name: {{ d.pkg.airflow.service.name }}
        user: {{ d.identity.rootuser }}
        group: {{ d.identity.rootgroup }}
        workdir: {{ d.dir.lib }}
        stop: ''
        start: {{ d.pkg.airflow.path }}/{{ d.pkg.airflow.service.name }}
  cmd.run:
    - name: systemctl daemon-reload
    - require:
      - archive: airflow-software-airflow-archive-install

        {%- endif %}
    {%- else %}

airflow-software-airflow-archive-install-other:
  test.show_notification:
    - text: |
        The airflow archive is unavailable/unselected for {{ salt['grains.get']('finger', grains.os_family) }}

    {%- endif %}
