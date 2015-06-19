class Tournament < ActiveRecord::Base
  belongs_to :user
  has_many :matches, :dependent => :destroy
  validates :name, presence: true, uniqueness: {scope: :user_id}
end
