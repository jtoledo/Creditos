require File.dirname(__FILE__) + '/../test_helper'

class VrCcSolicitudesTest < Test::Unit::TestCase
  fixtures :vr_cc_solicitudes

	NEW_VR_CC_SOLICITUDES = {}	# e.g. {:name => 'Test VrCcSolicitudes', :description => 'Dummy'}
	REQ_ATTR_NAMES 			 = %w( ) # name of fields that must be present, e.g. %(name description)
	DUPLICATE_ATTR_NAMES = %w( ) # name of fields that cannot be a duplicate, e.g. %(name description)

  def setup
    # Retrieve fixtures via their name
    # @first = vr_cc_solicitudes(:first)
  end

  def test_raw_validation
    vr_cc_solicitudes = VrCcSolicitudes.new
    if REQ_ATTR_NAMES.blank?
      assert vr_cc_solicitudes.valid?, "VrCcSolicitudes should be valid without initialisation parameters"
    else
      # If VrCcSolicitudes has validation, then use the following:
      assert !vr_cc_solicitudes.valid?, "VrCcSolicitudes should not be valid without initialisation parameters"
      REQ_ATTR_NAMES.each {|attr_name| assert vr_cc_solicitudes.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"}
    end
  end

	def test_new
    vr_cc_solicitudes = VrCcSolicitudes.new(NEW_VR_CC_SOLICITUDES)
    assert vr_cc_solicitudes.valid?, "VrCcSolicitudes should be valid"
   	NEW_VR_CC_SOLICITUDES.each do |attr_name|
      assert_equal NEW_VR_CC_SOLICITUDES[attr_name], vr_cc_solicitudes.attributes[attr_name], "VrCcSolicitudes.@#{attr_name.to_s} incorrect"
    end
 	end

	def test_validates_presence_of
   	REQ_ATTR_NAMES.each do |attr_name|
			tmp_vr_cc_solicitudes = NEW_VR_CC_SOLICITUDES.clone
			tmp_vr_cc_solicitudes.delete attr_name.to_sym
			vr_cc_solicitudes = VrCcSolicitudes.new(tmp_vr_cc_solicitudes)
			assert !vr_cc_solicitudes.valid?, "VrCcSolicitudes should be invalid, as @#{attr_name} is invalid"
    	assert vr_cc_solicitudes.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    end
 	end

	def test_duplicate
    current_vr_cc_solicitudes = VrCcSolicitudes.find_first
   	DUPLICATE_ATTR_NAMES.each do |attr_name|
   		vr_cc_solicitudes = VrCcSolicitudes.new(NEW_VR_CC_SOLICITUDES.merge(attr_name.to_sym => current_vr_cc_solicitudes[attr_name]))
			assert !vr_cc_solicitudes.valid?, "VrCcSolicitudes should be invalid, as @#{attr_name} is a duplicate"
    	assert vr_cc_solicitudes.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
		end
	end
end

