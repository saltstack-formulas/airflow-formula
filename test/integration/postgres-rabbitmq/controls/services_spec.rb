# frozen_string_literal: true

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

  describe service('rabbitmq-server') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe port(5672) do
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
