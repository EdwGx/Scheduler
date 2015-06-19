class Match < ActiveRecord::Base
  has_many :alliances
  belongs_to :field
  belongs_to :tournament
  validates_presence_of :field, :start_at
  has_one :timeslot, :dependent => :nullify

  after_destroy :destroy_alliances

  def home
    self.alliances.find_by(home: true)
  end

  def away
    self.alliances.find_by(home: false)
  end

  def home_team
    home_alliance = self.home
    if home_alliance.nil?
      return nil
    else
     return home_alliance.teams.first
    end
  end

  def away_team
    away_alliance = self.away
    if away_alliance.nil?
      return nil
    else
     return away_alliance.teams.first
    end
  end

  def home_team=(value)
    set_team(value, true)
  end

  def away_team=(value)
    set_team(value, false)
  end

  private
  def teams_existence_and_unqiueness
    flag = true

    if home_team.nil?
      errors.add(:home_team, "must exists")
      flag = false
    end

    if away_team.nil?
      errors.add(:away_team, "must exists")
      flag = false
    end

    if flag
      if home_team.id == away_team.id
        errors.add("Home team and away team cannot be the same")
      end
    end
  end

  def set_team(value,home)
    alliance = self.alliances.find_by(home: home)
    if alliance.nil?
      alliance = Alliance.create(home: home, match_id: self.id)
    end

    alliance.teams.delete_all

    alliance.teams = [value]

    alliance.save
  end

  def destroy_alliances
    self.alliances.each do |a|
      a.destroy unless a.destroyed?
    end
  end
end
