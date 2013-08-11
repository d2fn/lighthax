require 'httparty'

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
