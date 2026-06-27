class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def create_subscription
    plan = SubscriptionPlan.active.find(params[:plan_id])

    if current_user.has_active_subscription?
      flash[:alert] = "Ya tienes una suscripción activa. Adminístrala desde tu perfil."
      redirect_to profile_subscription_path and return
    end

    session = StripeCheckoutService.create_subscription_session(
      user: current_user,
      plan: plan,
      success_url: checkout_success_url(type: "subscription"),
      cancel_url: subscription_plans_url
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue Stripe::StripeError => e
    flash[:alert] = "Error de pago: #{e.message}"
    redirect_to subscription_plans_path
  end

  def create_product
    product = Product.active.find_by!(slug: params[:product_id]) if params[:product_id].to_s.match?(/[a-z\-]/)
    product ||= Product.active.find(params[:product_id])

    if product.stock_quantity <= 0
      flash[:alert] = "Este producto está agotado."
      redirect_to product_path(product) and return
    end

    session = StripeCheckoutService.create_product_session(
      user: current_user,
      product: product,
      success_url: checkout_success_url(type: "product"),
      cancel_url: product_url(product)
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Producto no disponible."
  rescue Stripe::StripeError => e
    flash[:alert] = "Error de pago: #{e.message}"
    redirect_to products_path
  end

  def success
    flash[:notice] = case params[:type]
    when "subscription"
      "¡Suscripción activada!"
    when "product"
      "¡Pago recibido! Te enviamos un correo con los detalles del pedido."
    else
      "¡Pago completado exitosamente!"
    end
    redirect_to profile_path
  end

  def customer_portal
    session = StripeCheckoutService.create_portal_session(
      user: current_user,
      return_url: profile_subscription_url
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue => e
    flash[:alert] = "No se pudo abrir el portal de facturación: #{e.message}"
    redirect_to profile_subscription_path
  end
end
