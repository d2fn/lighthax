#!/usr/bin/env ruby

$:.unshift File.expand_path "../../lib", __FILE__

require 'net/http'
require 'sinatra'
require 'httparty'
require 'json'
require 'lighthax/payload'

class RwHttp
  def initialize(address, u, p)
    @address = address
    @auth = { :username => u, :password => p }
  end
  def get(path)
    puts "#{@address}/#{path}"
    response = HTTParty.get("#{@address}/#{path}", { :basic_auth => @auth, :verify => false, :ssl_version => :TLSv1 })
    JSON.parse(response)
  end
  def post(path, data)
    HTTParty.post("#{@address}/#{path}", { :headers => {'Content-type' => 'application/x-www-form-urlencoded'}, :body => data, :format => :plain, :basic_auth => @auth, :verify => false, :ssl_version => :TLSv1 })
  end
end

class Lights
  attr_accessor :serial_numbers
  attr_accessor :name_to_serial_number
  attr_accessor :serial_number_to_name

  def initialize(rwhttp)
    @rwhttp = rwhttp
  end

  def lights
    if @lights
      @lights
    else
      fixtures
      @lights
    end
  end

  def fixtures
    if @fixtures
      @fixtures
    else
      @fixtures = @rwhttp.get("rApi/fixture")
      parse_fixtures
      @fixtures
    end
  end

  def light(serial)
    @lights[serial]
  end

  def locations
    if @locations
      @locations
    else
      @locations = @rwhttp.get("rApi/location")
      parse_locations
      @locations
    end
  end

  def parse_fixtures
    @serial_numbers = []
    @serial_number_to_name = {}
    @name_to_serial_number = {}
    @lights = {}
    @fixtures.each do |f|
      sn = f["serialNum"]
      name = f["name"]
      f["href"] = "/lights/#{sn}"
      @serial_numbers << sn
      @serial_number_to_name[sn] = name
      @name_to_serial_number[name] = sn
      @lights[sn] = f
    end
  end

  def parse_locations
    @locations = {}
  end

  def set_light_brightness(serial, level)
  end

  def set_location_brightness(id, level)
  end

  def blink_location_on(id)
  end

  def blink_location_off(id)
  end

  def blink_on(serials)
    payload = Lighthax::PayloadGenerator.blink(serials, true).to_json + "====="
    @rwhttp.post("cgi-bin/model.cgi", payload)
  end

  def blink_off(serials)
    payload = Lighthax::PayloadGenerator.blink(serials, false).to_json + "====="
    @rwhttp.post("cgi-bin/model.cgi", payload)
  end
end

address = ENV['RW_ADDRESS']
user = ENV['RW_USER']
pass = ENV['RW_PASS']

rwhttp = RwHttp.new(address, user, pass)
lights = Lights.new(rwhttp)
lights.fixtures

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
  content-type :json
  lights.set_light_brightness(params[:serial], params[:level]).to_json
end

get '/locations' do
  content_type :json
  lights.locations.to_json
end

get '/locations/:id' do
  content_type :json
  lights.locations.to_json
end

post '/locations/:id/brightness/:level' do
  content-type :json
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

