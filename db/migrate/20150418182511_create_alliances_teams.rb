class CreateAlliancesTeams < ActiveRecord::Migration
  def change
    create_table :alliances_teams do |t|
      t.belongs_to :alliance, index: true
      t.belongs_to :team, index: true
    end
  end
end
