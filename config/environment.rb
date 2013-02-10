# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Discourse::Application.initialize!


ActionMailer::Base.smtp_settings = {
	:user_name => YAML::load(File.open("#{Rails.root}/config/other_credentials.yml"))["sendgriduser"],
	:password => YAML::load(File.open("#{Rails.root}/config/other_credentials.yml"))["sendgridpass"],
	:domain => "triangleror.com",
	:address => "smtp.sendgrid.net",
	:port => 587,
	:authentication => :plain,
	:enable_starttls_auto => true
} 
