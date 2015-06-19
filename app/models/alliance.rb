class Alliance < ActiveRecord::Base
  belongs_to :match
  has_and_belongs_to_many :teams
  after_destroy :destroy_match

  private
  def destroy_match
    match.destroy if (match && !match.destroyed?)
  end
end
