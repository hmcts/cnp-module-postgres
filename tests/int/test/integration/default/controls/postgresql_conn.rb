# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved

title 'Check Azure Postgresql connection'

control 'azure-postgresql-conn' do

  impact 1.0
  title ' Check that we can connect to postgresql'
  json_obj = json('.kitchen/kitchen-terraform/default-azure/terraform.tfstate')
  random_name = json_obj['modules'][0]['outputs']['random_name']['value'] + '-db-int'
  # Create a PostgreSQL session:
  sql = postgres_session('inspec', '0Tk3049&6k', random_name + ".postgres.database.azure.com")

  describe sql.query('SELECT * FROM postgres') do
    its('output') { should eq '' }
  end
end
