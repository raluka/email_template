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
