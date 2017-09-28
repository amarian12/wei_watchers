class BalanceSubscriptionsController < ApiController

  def create
    account = Account.find_or_create_by address: address
    subscription = subscriber.balance_subscriptions.create({
      account: account,
      end_at: end_at,
    })
    if subscription.save
      success_response xid: subscription.xid
    else
      failure_response subscription.errors.full_messages
    end
  end


  private

  def address
    subscription_params['address']
  end

  def end_at
    Time.at(subscription_params['end_at'].to_i)
  end

  def subscription_params
    @subscription_params ||= params[:subscription] ? JSON.parse(params[:subscription]) : JSON.parse(params[:balance_subscription])
  end

end
