class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.datetime :start_at
      t.integer :duration
      t.belongs_to :tournament, index: true, null: false
      t.belongs_to :field, index: true
      t.timestamps null: false
    end
  end
end
