class CreateCcProductos < ActiveRecord::Migration
  def self.up
    create_table :cc_productos do |t|
    end
  end

  def self.down
    drop_table :cc_productos
  end
end
