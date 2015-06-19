class Field < ActiveRecord::Base
  belongs_to :user
  has_many :timeslots
  validates :name, presence: true, uniqueness: {scope: :user_id}
  has_many :matches

  def available_timeslots(options={})
    range_start = options[:start]
    range_end = options[:end]

    slots = self.timeslots.where(match_id: nil)

    if range_start.present? && range_end.present?
      slots = slots.where(start_at: range_start..range_end)
    elsif range_start.present?
      slots = slots.where('start_at > ?', range_start)
    elsif range_end.present?
      slots = slots.where('start_at < ?', range_end)
    end

    slots = slots.all.pluck(:start_at, :id)
    
    self_id = self.id
    slots.map! do |s|
      s[0] = s[0].to_date
      s << self_id
    end
  end

end
