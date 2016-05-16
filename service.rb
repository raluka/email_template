# service.rb - contains the entire service
require 'active_record'
require 'sinatra'
require_relative 'models/email_template'
require 'logger'

# setting up a logger. levels: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
log = Logger.new(STDOUT)
log.level == Logger::DEBUG

# setting up the environment
env_index = ARGV.index("-e")
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV['SINATRA_ENV'] || 'development'
log.debug "env: #{env}"

# connecting to database
use ActiveRecord::ConnectionAdapters::ConnectionManagement # close connection to the DDBB properly
databases = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(databases[env])
log.debug "#{databases[env]['database']} database connection established."

# # create a fixture data for test env only
# if env == 'test'
#   EmailTemplate.delete_all
#   EmailTemplate.create(id: 1, title: 'Fixture data title', body: 'Fixture data body')
#   log.debug 'fixture data created in test database.'
# end

# HTTP entry points

# get an email template by id
get '/api/v1/templates/:id' do
  email_template = EmailTemplate.find_by(id: params[:id])
  if email_template
    email_template.to_json
  else
    error 404, {error: 'Template not found'}.to_json
  end
end

# create email template
post '/api/v1/templates' do
  begin
    email_template = EmailTemplate.create(JSON.parse(request.body.read))
    if email_template.valid?
      email_template.to_json
    else
      error 400, email_template.errors.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end

# update email template
put '/api/v1/templates/:id' do
  email_template = EmailTemplate.find_by(id: params[:id])
  if email_template
    if email_template.update_attributes(JSON.parse(request.body.read))
      email_template.to_json
    else
      error 400, email_template.errors.to_json
    end
  else
    error 404, {error: 'Email Template not found'}.to_json
  end
end

# destroy existing email template

delete '/api/v1/templates/:id' do
  email_template = EmailTemplate.find_by(id: params[:id])
  if email_template
    email_template.destroy
    email_template.to_json
  else
    error 404, {error: 'Email Template not found'}.to_json
  end
end
