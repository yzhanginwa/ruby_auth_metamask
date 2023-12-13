require "test_helper"

module RubyAuthMetamask
  class UsersControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get signin" do
      get users_signin_url
      assert_response :success
    end
  end
end
