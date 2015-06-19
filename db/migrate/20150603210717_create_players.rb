class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :email
      t.string :info, default: '[]'
      t.boolean :verified, default: false ,null: false
      t.belongs_to :team, index: true
    end
  end
end
