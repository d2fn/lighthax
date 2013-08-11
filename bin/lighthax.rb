#!/usr/bin/env ruby

$:.unshift File.expand_path "../../lib", __FILE__

require 'sinatra'
require 'json'

require 'lighthax/rwhttp'
require 'lighthax/lights'

address = ENV['RW_ADDRESS']
user = ENV['RW_USER']
pass = ENV['RW_PASS']

rwhttp = RwHttp.new(address, user, pass)
lights = Lights.new(rwhttp)

set :bind, "0.0.0.0"

get '/fixtures' do
  content_type :json
  lights.fixtures.to_json
end

get '/lights' do
  content_type :json
  lights.lights.to_json
end

get '/lights/:serial' do
  content_type :json
  lights.light(params[:serial]).to_json
end

post '/lights/:serial/brightness/:level' do
  content_type :json
  lights.set_light_brightness(params[:serial], params[:level]).to_json
end

get '/locations' do
  content_type :json
  lights.list_locations.to_json
end

get '/locations/:id' do
  content_type :json
  lights.location_by_id(params[:id].to_i).to_json
end

post '/locations/:id/brightness/:level' do
  content_type :json
  lights.set_location_brightness(params[:id], params[:level]).to_json
end

get '/serial_numbers' do
  content_type :json
  lights.serial_numbers.to_json
end

get '/serial_numbers_to_names' do
  content_type :json
  lights.serial_number_to_name.to_json
end

get '/names_to_serial_numbers' do
  content_type :json
  lights.name_to_serial_number.to_json
end

post '/blink_on' do
  content_type :json
  lights.blink_on(lights.serial_numbers).to_json
end

post '/blink_off' do
  content_type :json
  lights.blink_off(lights.serial_numbers).to_json
end

