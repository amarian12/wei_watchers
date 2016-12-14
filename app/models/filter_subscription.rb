class FilterSubscription < ActiveRecord::Base

  belongs_to :filter, inverse_of: :filter_subscription
  belongs_to :subscriber, inverse_of: :filter_subscriptions
  has_many :event_logs, through: :filter

  validates :subscriber, presence: true
  validates :end_at, presence: true
  validates :filter, presence: true
  validates_associated :filter

  scope :current, -> { where "end_at >= now()" }

  def self.reset_current_filters
    current.pluck(:id).each do |id|
      find(id).reset_filter!
    end
  end

  def xid
    filter.xid
  end

  def reset_filter!
    filter.update_attributes!({
      xid: filter.new_on_chain_filter
    })
  end

end
