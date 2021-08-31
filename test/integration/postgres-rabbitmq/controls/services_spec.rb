# frozen_string_literal: true

control 'airflow systemd files' do
  impact 0.5
  title 'should be configured correctly'

  describe file('/usr/lib/systemd/system/airflow-scheduler.service') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'User=airflow' }
    its('content') { should include 'Description=airflow-scheduler service' }
    # rubocop:disable Layout/LineLength
    its('content') { should include 'ExecStart=/home/airflow/.local/bin/airflow scheduler' }
    # rubocop:enable Layout/LineLength
  end

  describe file('/usr/lib/systemd/system/airflow-webserver.service') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'User=airflow' }
    its('content') { should include 'Description=airflow-webserver service' }
    # rubocop:disable Layout/LineLength
    its('content') { should include 'ExecStart=/home/airflow/.local/bin/airflow webserver' }
    # rubocop:enable Layout/LineLength
  end

  describe file('/usr/lib/systemd/system/airflow-celery-flower.service') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'User=airflow' }
    its('content') { should include 'Description=airflow-celery-flower service' }
    # rubocop:disable Layout/LineLength
    its('content') { should include 'ExecStart=/home/airflow/.local/bin/airflow celery flower' }
    # rubocop:enable Layout/LineLength
  end

  describe file('/usr/lib/systemd/system/airflow-celery-worker.service') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'User=airflow' }
    its('content') { should include 'Description=airflow-celery-worker service' }
    # rubocop:disable Layout/LineLength
    its('content') { should include 'ExecStart=/home/airflow/.local/bin/airflow celery worker' }
    # rubocop:enable Layout/LineLength
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
    it { should be_running }
  end
end

control 'Rabbitmq service' do
  impact 0.5
  title 'should be running and enabled'
  require 'rspec/retry'

  describe service('rabbitmq-server') do
    it { should be_installed }
    it { should be_enabled }
  end

  describe 'service(rabbitmq)' do
    it 'should be running', retry: 60, retry_wait: 5 do
      expect(service('rabbitmq-server').running?).to eq true
    end
  end

  describe 'port(5672)' do
    it 'should be listening', retry: 60, retry_wait: 3 do
      expect(port(8080).listening?).to eq true
    end
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
