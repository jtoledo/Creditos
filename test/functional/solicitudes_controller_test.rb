require File.dirname(__FILE__) + '/../test_helper'
require 'solicitudes_controller'

# Re-raise errors caught by the controller.
class SolicitudesController; def rescue_action(e) raise e end; end

class SolicitudesControllerTest < Test::Unit::TestCase
  fixtures :vr_cc_solicitudes

	NEW_VR_CC_SOLICITUDES = {}	# e.g. {:name => 'Test VrCcSolicitudes', :description => 'Dummy'}
	REDIRECT_TO_MAIN = {:action => 'list'} # put hash or string redirection that you normally expect

	def setup
		@controller = SolicitudesController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
		# Retrieve fixtures via their name
		# @first = vr_cc_solicitudes(:first)
		@first = VrCcSolicitudes.find_first
	end

  def test_component
    get :component
    assert_response :success
    assert_template 'solicitudes/component'
    vr_cc_solicitudes = check_attrs(%w(vr_cc_solicitudes))
    assert_equal VrCcSolicitudes.find(:all).length, vr_cc_solicitudes.length, "Incorrect number of vr_cc_solicitudes shown"
  end

  def test_component_update
    get :component_update
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_component_update_xhr
    xhr :get, :component_update
    assert_response :success
    assert_template 'solicitudes/component'
    vr_cc_solicitudes = check_attrs(%w(vr_cc_solicitudes))
    assert_equal VrCcSolicitudes.find(:all).length, vr_cc_solicitudes.length, "Incorrect number of vr_cc_solicitudes shown"
  end

  def test_create
  	vr_cc_solicitudes_count = VrCcSolicitudes.find(:all).length
    post :create, {:vr_cc_solicitudes => NEW_VR_CC_SOLICITUDES}
    vr_cc_solicitudes, successful = check_attrs(%w(vr_cc_solicitudes successful))
    assert successful, "Should be successful"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
    assert_equal vr_cc_solicitudes_count + 1, VrCcSolicitudes.find(:all).length, "Expected an additional VrCcSolicitudes"
  end

  def test_create_xhr
  	vr_cc_solicitudes_count = VrCcSolicitudes.find(:all).length
    xhr :post, :create, {:vr_cc_solicitudes => NEW_VR_CC_SOLICITUDES}
    vr_cc_solicitudes, successful = check_attrs(%w(vr_cc_solicitudes successful))
    assert successful, "Should be successful"
    assert_response :success
    assert_template 'create.rjs'
    assert_equal vr_cc_solicitudes_count + 1, VrCcSolicitudes.find(:all).length, "Expected an additional VrCcSolicitudes"
  end

  def test_update
  	vr_cc_solicitudes_count = VrCcSolicitudes.find(:all).length
    post :update, {:id => @first.id, :vr_cc_solicitudes => @first.attributes.merge(NEW_VR_CC_SOLICITUDES)}
    vr_cc_solicitudes, successful = check_attrs(%w(vr_cc_solicitudes successful))
    assert successful, "Should be successful"
    vr_cc_solicitudes.reload
   	NEW_VR_CC_SOLICITUDES.each do |attr_name|
      assert_equal NEW_VR_CC_SOLICITUDES[attr_name], vr_cc_solicitudes.attributes[attr_name], "@vr_cc_solicitudes.#{attr_name.to_s} incorrect"
    end
    assert_equal vr_cc_solicitudes_count, VrCcSolicitudes.find(:all).length, "Number of VrCcSolicitudess should be the same"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_update_xhr
  	vr_cc_solicitudes_count = VrCcSolicitudes.find(:all).length
    xhr :post, :update, {:id => @first.id, :vr_cc_solicitudes => @first.attributes.merge(NEW_VR_CC_SOLICITUDES)}
    vr_cc_solicitudes, successful = check_attrs(%w(vr_cc_solicitudes successful))
    assert successful, "Should be successful"
    vr_cc_solicitudes.reload
   	NEW_VR_CC_SOLICITUDES.each do |attr_name|
      assert_equal NEW_VR_CC_SOLICITUDES[attr_name], vr_cc_solicitudes.attributes[attr_name], "@vr_cc_solicitudes.#{attr_name.to_s} incorrect"
    end
    assert_equal vr_cc_solicitudes_count, VrCcSolicitudes.find(:all).length, "Number of VrCcSolicitudess should be the same"
    assert_response :success
    assert_template 'update.rjs'
  end

  def test_destroy
  	vr_cc_solicitudes_count = VrCcSolicitudes.find(:all).length
    post :destroy, {:id => @first.id}
    assert_response :redirect
    assert_equal vr_cc_solicitudes_count - 1, VrCcSolicitudes.find(:all).length, "Number of VrCcSolicitudess should be one less"
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_destroy_xhr
  	vr_cc_solicitudes_count = VrCcSolicitudes.find(:all).length
    xhr :post, :destroy, {:id => @first.id}
    assert_response :success
    assert_equal vr_cc_solicitudes_count - 1, VrCcSolicitudes.find(:all).length, "Number of VrCcSolicitudess should be one less"
    assert_template 'destroy.rjs'
  end

protected
	# Could be put in a Helper library and included at top of test class
  def check_attrs(attr_list)
    attrs = []
    attr_list.each do |attr_sym|
      attr = assigns(attr_sym.to_sym)
      assert_not_nil attr,       "Attribute @#{attr_sym} should not be nil"
      assert !attr.new_record?,  "Should have saved the @#{attr_sym} obj" if attr.class == ActiveRecord
      attrs << attr
    end
    attrs.length > 1 ? attrs : attrs[0]
  end
end
