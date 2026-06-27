class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order
    @user = order.user
    @items = order.order_items.includes(:product)

    mail(to: order.email.presence || @user&.email, subject: "Confirmación de pedido ##{order.id}")
  end

  def shipped(order)
    @order = order
    @user = order.user
    @tracking_number = order.tracking_number

    mail(to: order.email.presence || @user&.email, subject: "Tu pedido ##{order.id} fue enviado")
  end
end
