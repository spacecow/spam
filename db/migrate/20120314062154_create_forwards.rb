class CreateForwards < ActiveRecord::Migration
  def self.up
    create_table :forwards do |t|
      t.string :address
      t.timestamps
    end
  end

  def self.down
    drop_table :forwards
  end
end
