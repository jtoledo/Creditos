class CreateVrCcEstsolicitudes < ActiveRecord::Migration
  def self.up
    create_table :vr_cc_estsolicitudes do |t|
    end
  end

  def self.down
    drop_table :vr_cc_estsolicitudes
  end
end
