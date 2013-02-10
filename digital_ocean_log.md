208.68.38.93

#Server Setup

$ git clone git@github.com:discourse/discourse.git triangleror
$ cd triangleror
$ vagrant up
$ bundle install
$ rake db:migrate
$ rake db:seed_fu
Everything worked locally

$ ssh root@ip

apt-get -y update
apt-get -y install curl git-core python-software-properties



## nginx
add-apt-repository ppa:nginx/stable
apt-get -y update
apt-get -y install nginx
service nginx start

# PostgreSQL
apt-get install postgresql-9.1
apt-get install postgresql-contrib-9.1
sudo -u postgres psql
# \password
# create user discourse with password 'secret';
# create database discourse_production owner discourse;
# \q

## Redis
apt-get install redis-server

# Postfix
apt-get -y install telnet postfix

# Node.js
add-apt-repository ppa:chris-lea/node.js
apt-get -y update
apt-get -y install nodejs

#Vim
apt-get install vim

# Add deployer user
addgroup admin
adduser deployer --ingroup admin

# RVM
\curl -L https://get.rvm.io | bash -s stable --ruby


#Gemfile
gem 'unicorn'
gem 'capistrano'

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

#Capfile
attached

#deploy.rb
attached

#unicorn_init.sh
$ chmod -x config/unicorn_init.sh

#unicorn.rb

$ vagrant ssh
$ bundle install

#When Running Bundle Install
sudo apt-get install build-essential
sudo apt-get install libxml2 libxml2-dev libxslt1-dev
sudo apt-get install libffi-dev #did nothing
gem install ffi
sudo apt-get install libreadline-dev
gem install rails


------
# get to know github.com
ssh git@github.com

# after deploy:cold
sudo rm /etc/nginx/sites-enabled/default
sudo service nginx restart
sudo update-rc.d -f unicorn_blog defaults

#Local Setup

#Git
git init
git remote add production ssh-address

# ssh setup
cat ~/.ssh/id_rsa.pub | ssh deployer@208.68.38.93 'cat >> ~/.ssh/authorized_keys'
ssh-add # -K on Mac OS X

# deployment
cap deploy:setup
# edit /home/deployer/apps/blog/shared/config/database.yml on server
cap deploy:cold