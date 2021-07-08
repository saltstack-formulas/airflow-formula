# frozen_string_literal: true

control 'airflow configuration' do
  title 'should match desired lines'

  describe file('/home/airflow/dags') do
    it { should exist }
    it { should be_directory }
    its('mode') { should cmp '0775' }
    its('type') { should eq :directory }
  end
  describe file('/home/airflow/airflow') do
    it { should exist }
    it { should be_directory }
    its('type') { should eq :directory }
  end
  describe file('/home/airflow/airflow/airflow.cfg') do
    it { should be_file }
    it { should be_owned_by 'airflow' }
    it { should be_grouped_into 'airflow' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'dags_folder = /home/airflow/dags' }
  end
  describe file('/home/airflow/airflow/webserver_config.py') do
    it { should be_file }
    it { should be_owned_by 'airflow' }
    it { should be_grouped_into 'airflow' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'AUTH_TYPE = AUTH_DB' }
  end
end
