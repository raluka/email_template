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

  describe 'POST on /api/v1/templates' do
    context 'with valid parameters' do
      it 'creates a template' do
        post '/api/v1/templates', {
          id: 1605161,
          title: 'Create template test',
          body: 'Body for create email template test with valid parameters'
        }.to_json
        expect(last_response).to be_ok
        get '/api/v1/templates/1605161'
        attributes = JSON.parse(last_response.body)
        expect(attributes['title']).to eq('Create template test')
        expect(attributes['body']).to eq('Body for create email template test with valid parameters')
      end
    end

    context 'with invalid parameters' do
      it 'raises error' do
        post '/api/v1/templates', {
          id: 1605162,
          body: 'Body for create email template test with invalid parameters'
        }.to_json
        expect(last_response.status).to be 400
      end
    end
  end

  describe 'PUT on /api/v1/templates/:id' do
    before(:each) do
      EmailTemplate.create(
        id: 1605163,
        title: 'Email template test for update',
        body: 'Text to be updated for email test')
    end

    it 'updates an email template' do
      put '/api/v1/templates/1605163', {
        body: 'Updated text for email test'
      }.to_json
      expect(last_response).to be_ok
      get '/api/v1/templates/1605163'
      attributes = JSON.parse(last_response.body)
      expect(attributes['body']).to eq('Updated text for email test')
    end

    it "returns 404 error for template that doesn't exist" do
      put '/api/v1/templates/1605153', {
        body: 'Error text for email test'
      }.to_json
      expect(last_response.status).to be 404
    end

    it 'returns 400 error for updating non-existent attributes' do
      put '/api/v1/templates/1605163', {
        body: nil
      }.to_json
      expect(last_response.status).to be 400
    end
  end

  describe 'DELETE on /api/v1/templates/:id' do
    it 'deletes an existing email template' do
      EmailTemplate.create(
       id: 1605164,
       title: 'Template to be destroyed',
       body: 'Text to be deleted with template'
      )
      delete '/api/v1/templates/1605164'
      expect(last_response).to be_ok
      get '/api/v1/templates/1605164'
      expect(last_response.status).to be 404
    end
  end
end
