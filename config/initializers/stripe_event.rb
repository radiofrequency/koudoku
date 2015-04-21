StripeEvent.configure do |events|
  events.subscribe 'charge.failed' do |event|
    stripe_id = event.data.object['customer']
      
    subscription = ::Subscription.find_by_stripe_id(stripe_id)
    if subscription
      subscription.charge_failed
    end
  end
  
  events.subscribe 'invoice.payment_succeeded' do |event|
    stripe_id = event.data.object['customer']
    amount = event.data.object['total'].to_f / 100.0
    subscription = ::Subscription.find_by_stripe_id(stripe_id)
    if subscription
      subscription.payment_succeeded(amount)
    end
  end
  
  events.subscribe 'charge.dispute.created' do |event|
    stripe_id = event.data.object['customer']
    subscription = ::Subscription.find_by_stripe_id(stripe_id)
    if subscription
      subscription.charge_disputed
    end
  end
  
  events.subscribe 'customer.subscription.deleted' do |event|
    stripe_id = event.data.object['customer']
    subscription = ::Subscription.find_by_stripe_id(stripe_id)
    if subscription
      subscription.plan_id = nil
      subscription.save
      subscription.finalize_cancelation!
    end

    # flash[:notice] = "You've successfully cancelled your subscription."
    #  @subscription.plan_id = nil
    #  @subscription.save
    #if subscription
    #  subscription.subscription_owner.try(:cancel)
    #end
  end
end