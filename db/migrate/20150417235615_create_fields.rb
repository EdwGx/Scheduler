class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name, null: false
      t.string :location
      t.belongs_to :user, index: true, null: false
      t.belongs_to :team, index: true
      t.timestamps null: false
    end
  end
end
