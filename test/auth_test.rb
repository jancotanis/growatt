require 'dotenv'
require 'logger'
require 'test_helper'


describe 'authentication' do

  it '#1 use wrong username/password' do
    assert_raises Growatt::AuthenticationError do
      client = Growatt.client( { username: "xxx"+Growatt.username, password: Growatt.password } )
      client.login
      flunk( 'AuthenticationError expected' )
    end
  end
  it '#2 use correct username/password' do
    client = Growatt.client( { username: Growatt.username, password:Growatt.password } )
    client.login
  end

end
