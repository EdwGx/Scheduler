class CreateTimeslots < ActiveRecord::Migration
  def change
    create_table :timeslots do |t|
      t.belongs_to :field, index: true
      t.belongs_to :match, index: true
      t.datetime :start_at
      t.integer :duration
      t.datetime :end_at
      t.timestamps null: false
    end
  end
end
