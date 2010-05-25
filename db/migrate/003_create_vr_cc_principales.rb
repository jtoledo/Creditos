class CreateVrCcPrincipales < ActiveRecord::Migration
  def self.up
    create_table :vr_cc_principales do |t|
    end
  end

  def self.down
    drop_table :vr_cc_principales
  end
end
