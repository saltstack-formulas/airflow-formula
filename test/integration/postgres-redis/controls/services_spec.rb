# frozen_string_literal: true

control 'airflow systemd files' do
  impact 0.5
  title 'should be configured correctly'

  describe file('/lib/systemd/system/airflow-scheduler.service') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'User=airflow' }
    its('content') { should include 'Description=airflow-scheduler service' }
    its('content') { should include 'ExecStart=/home/airflow/.local/bin/airflow scheduler' }
  end

  describe file('/lib/systemd/system/airflow-webserver.service') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'User=airflow' }
    its('content') { should include 'Description=airflow-webserver service' }
    its('content') { should include 'ExecStart=/home/airflow/.local/bin/airflow webserver' }
  end

  describe file('/lib/systemd/system/airflow-celery-flower.service') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'User=airflow' }
    its('content') { should include 'Description=airflow-celery-flower service' }
    its('content') { should include 'ExecStart=/home/airflow/.local/bin/airflow celery flower' }
  end

  describe file('/lib/systemd/system/airflow-celery-worker.service') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'User=airflow' }
    its('content') { should include 'Description=airflow-celery-worker service' }
    its('content') { should include 'ExecStart=/home/airflow/.local/bin/airflow celery worker' }
  end
end

control 'airflow services' do
  impact 0.5
  title 'should be running and enabled'

  describe service('airflow-celery-worker') do
    it { should be_installed }
    it { should be_enabled }
    # it { should be_running }
  end
  describe port(5555) do
    it { should be_listening }
  end
  describe service('airflow-celery-flower') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe service('airflow-webserver') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe port(8080) do
    it { should be_listening }
  end
  describe service('airflow-scheduler') do
    it { should be_installed }
    it { should be_enabled }
    # it { should be_running }
  end
end

control 'Redis service' do
  impact 0.5
  title 'should be running and enabled'

  describe service('redis') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe port(6379) do
    it { should be_listening }
  end
end

control 'Postgres service' do
  impact 0.5
  title 'should be running and enabled'

  describe service('postgresql') do
    it { should be_enabled }
    it { should be_running }
  end
  describe port(5432) do
    it { should be_listening }
  end
end
