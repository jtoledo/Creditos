require File.dirname(__FILE__) + '/../test_helper'

class VrCcSolicitudeTest < Test::Unit::TestCase
  fixtures :vr_cc_solicitudes

	NEW_VR_CC_SOLICITUDE = {}	# e.g. {:name => 'Test VrCcSolicitude', :description => 'Dummy'}
	REQ_ATTR_NAMES 			 = %w( ) # name of fields that must be present, e.g. %(name description)
	DUPLICATE_ATTR_NAMES = %w( ) # name of fields that cannot be a duplicate, e.g. %(name description)

  def setup
    # Retrieve fixtures via their name
    # @first = vr_cc_solicitudes(:first)
  end

  def test_raw_validation
    vr_cc_solicitude = VrCcSolicitude.new
    if REQ_ATTR_NAMES.blank?
      assert vr_cc_solicitude.valid?, "VrCcSolicitude should be valid without initialisation parameters"
    else
      # If VrCcSolicitude has validation, then use the following:
      assert !vr_cc_solicitude.valid?, "VrCcSolicitude should not be valid without initialisation parameters"
      REQ_ATTR_NAMES.each {|attr_name| assert vr_cc_solicitude.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"}
    end
  end

	def test_new
    vr_cc_solicitude = VrCcSolicitude.new(NEW_VR_CC_SOLICITUDE)
    assert vr_cc_solicitude.valid?, "VrCcSolicitude should be valid"
   	NEW_VR_CC_SOLICITUDE.each do |attr_name|
      assert_equal NEW_VR_CC_SOLICITUDE[attr_name], vr_cc_solicitude.attributes[attr_name], "VrCcSolicitude.@#{attr_name.to_s} incorrect"
    end
 	end

	def test_validates_presence_of
   	REQ_ATTR_NAMES.each do |attr_name|
			tmp_vr_cc_solicitude = NEW_VR_CC_SOLICITUDE.clone
			tmp_vr_cc_solicitude.delete attr_name.to_sym
			vr_cc_solicitude = VrCcSolicitude.new(tmp_vr_cc_solicitude)
			assert !vr_cc_solicitude.valid?, "VrCcSolicitude should be invalid, as @#{attr_name} is invalid"
    	assert vr_cc_solicitude.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    end
 	end

	def test_duplicate
    current_vr_cc_solicitude = VrCcSolicitude.find_first
   	DUPLICATE_ATTR_NAMES.each do |attr_name|
   		vr_cc_solicitude = VrCcSolicitude.new(NEW_VR_CC_SOLICITUDE.merge(attr_name.to_sym => current_vr_cc_solicitude[attr_name]))
			assert !vr_cc_solicitude.valid?, "VrCcSolicitude should be invalid, as @#{attr_name} is a duplicate"
    	assert vr_cc_solicitude.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
		end
	end
end

