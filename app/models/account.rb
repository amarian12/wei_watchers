class Account < ActiveRecord::Base

  include HasEthereumClient

  has_many :balance_subscriptions, inverse_of: :account
  has_many :subscribers, through: :balance_subscriptions

  validates :address, format: /\A0x[0-9a-f]{40}\z/i, uniqueness: true
  validates :balance, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def notify_subscribers(info)
    balance_subscriptions.current.pluck(:subscriber_id).each do |subscriber_id|
      Subscriber.update_balance subscriber_id, info
    end
  end

  def current_balance
    ethereum.account_balance address
  end

end
