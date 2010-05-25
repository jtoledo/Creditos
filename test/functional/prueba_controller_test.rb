require File.dirname(__FILE__) + '/../test_helper'
require 'prueba_controller'

# Re-raise errors caught by the controller.
class PruebaController; def rescue_action(e) raise e end; end

class PruebaControllerTest < Test::Unit::TestCase
  def setup
    @controller = PruebaController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
