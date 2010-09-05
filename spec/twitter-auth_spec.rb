require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TwitterAuth" do
  
  before(:each) do
    @callback         = "http://localhost:3005/the_dance/process_callback?service_provider_id=11"
    @consumer_key     = "GDdmIQH6jhtmLUypg82g"
    @nonce            = "QP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk"
    @signature_method = "HMAC-SHA1"
    @timestamp        = '1272323042'
    @version          = '1.0'
    @base_uri         = 'https://api.twitter.com/oauth/request_token'
    @secret           = 'MCD8BKwGdgPHvAuvgvz4EQpqDAtx89grbuNMRd7Eh98'
  end
  it 'should sign the values correctly' do
    sign = TwitterAuth.sign!(@callback, @consumer_key, @base_uri, @nonce, @timestamp, @secret)
    sign.should == "8wUi7m5HFQy76nowoCThusfgB+Q="
  end
  
  it "should escape = to %3D" do
    TwitterAuth.escape("=").should == "%3D"
  end
  
  it "should not return an unauthorized response" do
    base_uri = "https://api.twitter.com/oauth/request_token"
    callback = "http://127.0.0.1:3000"
    consumer_key = "QevVu5cPxjDA9c5ksek7mQ"
    secret = "ZhqEdpoFU0EqUpvA1gkSWLtWf51lxAMzD3JyXmha6E"
    response, data = TwitterAuth.request_token(callback, consumer_key, secret, base_uri)
    response.code.should == '200'
  end
end
