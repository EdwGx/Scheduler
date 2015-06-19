class Team < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true, :uniqueness => {:scope => :user_id}
  has_and_belongs_to_many :alliances, :dependent => :destroy
  has_one :field, dependent: :nullify
  has_many :players, dependent: :destroy, after_add: [:set_empty_info]
  serialize :players_info, JSON

  before_create :generate_registration_token

  def generate_registration_token
    i = 0
    self.registration_token = loop do
      token = SecureRandom.hex((0.009 * (i**2) + 3.1).floor)
      break token unless Team.exists?(registration_token: token)
      i += 1
    end
  end

  private
  def set_empty_info(player)
    byebug
    player.info = [nil] * self.players_info.count
    player.save
  end
end
