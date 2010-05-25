require File.dirname(__FILE__) + '/../test_helper'

class VrCcSolicitudTest < Test::Unit::TestCase
  fixtures :vr_cc_solicituds

	NEW_VR_CC_SOLICITUD = {}	# e.g. {:name => 'Test VrCcSolicitud', :description => 'Dummy'}
	REQ_ATTR_NAMES 			 = %w( ) # name of fields that must be present, e.g. %(name description)
	DUPLICATE_ATTR_NAMES = %w( ) # name of fields that cannot be a duplicate, e.g. %(name description)

  def setup
    # Retrieve fixtures via their name
    # @first = vr_cc_solicituds(:first)
  end

  def test_raw_validation
    vr_cc_solicitud = VrCcSolicitud.new
    if REQ_ATTR_NAMES.blank?
      assert vr_cc_solicitud.valid?, "VrCcSolicitud should be valid without initialisation parameters"
    else
      # If VrCcSolicitud has validation, then use the following:
      assert !vr_cc_solicitud.valid?, "VrCcSolicitud should not be valid without initialisation parameters"
      REQ_ATTR_NAMES.each {|attr_name| assert vr_cc_solicitud.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"}
    end
  end

	def test_new
    vr_cc_solicitud = VrCcSolicitud.new(NEW_VR_CC_SOLICITUD)
    assert vr_cc_solicitud.valid?, "VrCcSolicitud should be valid"
   	NEW_VR_CC_SOLICITUD.each do |attr_name|
      assert_equal NEW_VR_CC_SOLICITUD[attr_name], vr_cc_solicitud.attributes[attr_name], "VrCcSolicitud.@#{attr_name.to_s} incorrect"
    end
 	end

	def test_validates_presence_of
   	REQ_ATTR_NAMES.each do |attr_name|
			tmp_vr_cc_solicitud = NEW_VR_CC_SOLICITUD.clone
			tmp_vr_cc_solicitud.delete attr_name.to_sym
			vr_cc_solicitud = VrCcSolicitud.new(tmp_vr_cc_solicitud)
			assert !vr_cc_solicitud.valid?, "VrCcSolicitud should be invalid, as @#{attr_name} is invalid"
    	assert vr_cc_solicitud.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    end
 	end

	def test_duplicate
    current_vr_cc_solicitud = VrCcSolicitud.find_first
   	DUPLICATE_ATTR_NAMES.each do |attr_name|
   		vr_cc_solicitud = VrCcSolicitud.new(NEW_VR_CC_SOLICITUD.merge(attr_name.to_sym => current_vr_cc_solicitud[attr_name]))
			assert !vr_cc_solicitud.valid?, "VrCcSolicitud should be invalid, as @#{attr_name} is a duplicate"
    	assert vr_cc_solicitud.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
		end
	end
end

