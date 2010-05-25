class CreateVrCcClientes < ActiveRecord::Migration
  def self.up
    create_table :vr_cc_clientes do |t|
    end
  end

  def self.down
    drop_table :vr_cc_clientes
  end
end
