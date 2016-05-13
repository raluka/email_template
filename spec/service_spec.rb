ENV['SINATRA_ENV'] = 'test'

require File.dirname(__FILE__) + '/../service'
require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

describe 'service' do
  before(:each) do
    EmailTemplate.delete_all
  end

  describe 'GET on api/v1/templates/:id' do
    before(:each) do
      EmailTemplate.create(
        id: 130516,
        title: 'Test title template',
        body: 'Test body for email template'
      )
    end

    it 'returns an email template by id' do
      get '/api/v1/templates/130516'
      expect(last_response).to be_ok
      attributes = JSON.parse(last_response.body)
      expect(attributes['id']).to eq(130516)
    end

    it 'returns an email template with title' do
      get '/api/v1/templates/130516'
      expect(last_response).to be_ok
      attributes = JSON.parse(last_response.body)
      expect(attributes['title']).to eq('Test title template')
    end

    it 'returns an email template with body' do
      get '/api/v1/templates/130516'
      expect(last_response).to be_ok
      attributes = JSON.parse(last_response.body)
      expect(attributes['body']).to eq('Test body for email template')
    end

    it "returns 404 for an email template that does'n exist" do
      get '/api/v1/templates/foo'
      expect(last_response.status).to be 404
    end
  end
end
