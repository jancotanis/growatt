require 'digest'
require File.expand_path('error', __dir__)

module Growatt
  # Deals with authentication flow and stores it within global configuration
  module Authentication

    # Authorize to the Growatt portal
    def login()
      if username && password
        _password = hash_password(self.password) #unless is_password_hashed

        _format = self.format
        self.format = 'x-www-form-urlencoded'
        response = post('newTwoLoginAPI.do', {'userName': self.username, 'password': _password})
        self.format = _format
        data = response.body['back']

        if data && data['success']
          @login_data = data
          data
        else
          raise AuthenticationError.new(data['error'])
        end
      else
        raise ConfigurationError, "Username/password not set" unless username || password
      end
    end

  private
    def hash_password(password)
      password_md5 = Digest::MD5.hexdigest(password.encode('utf-8'))
      (0...password_md5.length).step(2) do |i|
        if password_md5[i] == '0'
          password_md5[i] = 'c'
        end
      end
      password_md5
    end
  end
end
