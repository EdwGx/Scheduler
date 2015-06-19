class Player < ActiveRecord::Base
  validates :name, presence: true, uniqueness: {scope: :team_id}
  belongs_to :team
  serialize :info, JSON
end
