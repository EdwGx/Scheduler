class CreateAlliances < ActiveRecord::Migration
  def change
    create_table :alliances do |t|
      t.belongs_to :match, index: true

      t.boolean :home, default: false, null: false
      t.string :result, limit: 8
      t.integer :point, default: 0

      t.timestamps null: false
    end
  end
end
