module RubyAuthMetamask
  class UsersController < ApplicationController
    def signin
      @message = "ruby_auth_metamask:#{SecureRandom.hex}"
      session[:message] = @message
    end

    def verify
    end
  end
end
