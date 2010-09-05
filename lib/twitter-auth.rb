require 'rubygems'
require "cgi"
require 'base64'
require 'openssl'
require 'net/https'
require 'nokogiri'
module TwitterAuth
  def self.escape(value) 
      CGI.escape(value.to_s).gsub("%7E", '~').gsub("+", "%20") 
    end

  def self.signature(base_string, consumer_secret,token_secret='') 
    digest  = OpenSSL::Digest::Digest.new('sha1')
    secret = "#{TwitterAuth.escape(consumer_secret)}&#{TwitterAuth.escape(token_secret)}" 
     Base64.encode64(OpenSSL::HMAC.digest(digest, secret, base_string)).chomp.gsub("\n", "")
  end  
  
  def self.sign!(callback, oauth_consumer_key, base_uri, nonce, time, secret)
    httpMethod = "POST"
    sorted_query_params = [
      ["oauth_callback", escape(callback)], 
      ["oauth_consumer_key", oauth_consumer_key], 
      ["oauth_nonce", nonce], 
      ["oauth_signature_method", "HMAC-SHA1"], 
      ["oauth_timestamp", time], 
      ["oauth_version", '1.0']
    ]
    escaped_params = sorted_query_params.collect{|k,v| escape(k) + "%3D" + escape(v.to_s)}.join("%26")       
    sig = (httpMethod + "&" + escape(base_uri) + "&" + escaped_params)
    signature(sig, secret)
  end
 
 def self.parse_response(data)
   parsed_response = {}
   data = data.split("&")
   data = data.collect{|k| k.split("=")}
   data.each{|k,v| parsed_response[k] = v}
   parsed_response
 end
 
  def self.request_token(callback, consumer_key, secret, base_uri, nonce=(Time.now.to_i * 99999).to_s, time=(Time.now.to_i))
    sig = sign!(callback, consumer_key, base_uri, nonce, time, secret)
    params = ["oauth_nonce=\"#{nonce}\"", "oauth_callback=\"#{escape callback}\"", "oauth_signature_method=\"HMAC-SHA1\"", "oauth_timestamp=\"#{time}\"", "oauth_consumer_key=\"#{consumer_key}\"", "oauth_signature=\"#{escape(sig)}\"", "oauth_version = \"1.0\""]
    uri = URI.parse(base_uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    headers = {"Authorization" => "OAuth " + params.join(', ')}
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    response, data = http.request(request)
    parsed_data = parse_response(data)
    user_authorization_url(parsed_data['oauth_token'])
  end
  
  def self.user_authorization_url(token)
    puts "http://api.twitter.com/oauth/authorize?oauth_token=" + token
  end
end