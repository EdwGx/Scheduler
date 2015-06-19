class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string :name, null: false

      t.belongs_to :user, index: true, null: false

      t.datetime :start_at
      t.datetime :end_at
      
      t.timestamps null: false
    end
  end
end
