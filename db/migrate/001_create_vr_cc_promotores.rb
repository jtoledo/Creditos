class CreateVrCcPromotores < ActiveRecord::Migration
  def self.up
    create_table :vr_cc_promotores do |t|
    end
  end

  def self.down
    drop_table :vr_cc_promotores
  end
end
