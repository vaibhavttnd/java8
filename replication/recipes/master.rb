#assuming percona,xtrabackup installed,my.cnf edit done.

execute 'innobackup' do
  command 'innobackupex --no-timestamp --user=root --password=v /home/ubuntu/base/'
  notifies :run, 'execute[scp-backup]', :immediately
#  action :nothing
end

#mysql start
#service "mysql" do
#  action :start
#  notifies :run, 'execute[install]', :immediately
#  action :nothing
#end


#mysql stop
#service "mysql" do
#  action :stop
#  notifies :run, 'execute[]', :immediately
#  action :nothing
#end


#Note : pem file should be present

execute 'scp-backup' do
  command 'sudo scp -r -i /home/ubuntu/vaibhav.pem /home/ubuntu/base/ ubuntu@52.207.246.181:/home/ubuntu/base'
  #add ip
#  notifies :run, 'execute[mysql]', :immediately
  action :nothing
end

#here template can be used
execute 'scp-cnf' do
  command 'sudo scp -r -i vaibhav.pem /etc/mysql/my.cnf ubuntu@52.207.246.181:/etc/mysql/my.cnf'
  #add ip
#  notifies :run, 'execute[install]', :immediately
  action :nothing
end



file '/home/ubuntu/user.sql' do
  content 'CREATE USER \'repl\'@\'localhost\' IDENTIFIED BY \'v\';'
  mode '0755'
  owner 'root'
  group 'root'
  notifies :run, 'execute[create-user]', :immediately
#  action :nothing
end


file '/home/ubuntu/permission.sql' do
  content "GRANT REPLICATION SLAVE ON *.*  TO 'repl'@'52.207.246.181'IDENTIFIED BY 'v';"
#add ip
  mode '0755'
  owner 'root'
  group 'root'
  notifies :run, 'execute[grant-user]', :immediately
end


execute 'grant-user' do
  command "sudo mysql -u root -pv < /home/ubuntu/permission.sql"
  #notifies :run, 'execute[xtrabackup]', :immediately
  action :nothing
end


execute 'create-user' do
  command "sudo mysql -u root -pv < /home/ubuntu/user.sql"
  notifies :run, 'execute[grant-user]', :immediately
  action :nothing
end

