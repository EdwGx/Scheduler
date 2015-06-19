class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.belongs_to :user, index: true, null: false
      t.boolean :allow_registration, default: false ,null: false
      t.string :registration_token, index: true
      t.string :players_info, default: '[]'
      t.timestamps null: false
    end
  end
end
