# frozen_string_literal: true

module Admin
  class OrdersController < BaseController
    def index
      @orders = policy_scope(Order).includes(:user, order_items: :product).recent
      authorize Order
    end

    def show
      @order = Order.includes(order_items: :product).find(params[:id])
      authorize @order
    end

    def new
      @order = Order.new(status: "completed", payment_method: "cash")
      @order.order_items.build
      authorize @order
      @products = Product.active.order(:name)
      @users = User.students.order(:first_name, :last_name)
    end

    def create
      @order = Order.new(order_params)
      authorize @order

      @order.order_items.each do |item|
        item.unit_price = Product.find_by(id: item.product_id)&.price || 0
      end
      @order.calculate_total!

      if @order.save
        deduct_stock(@order) if @order.status == "completed"
        redirect_to admin_order_path(@order), notice: "Pedido creado."
      else
        @products = Product.active.order(:name)
        @users = User.students.order(:first_name, :last_name)
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @order = Order.find(params[:id])
      authorize @order

      previous_shipping_status = @order.shipping_status

      if @order.update(update_params)
        notify_shipped(@order) if @order.shipping_status == "shipped" && previous_shipping_status != "shipped"
        redirect_to admin_order_path(@order), notice: "Pedido actualizado."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def order_params
      params.require(:order).permit(:user_id, :status, :payment_method, :notes,
        order_items_attributes: [ :product_id, :quantity ])
    end

    def update_params
      params.require(:order).permit(:shipping_status, :tracking_number, :notes)
    end

    def deduct_stock(order)
      order.order_items.each do |item|
        item.product.decrement!(:stock_quantity, item.quantity) if item.product.stock_quantity >= item.quantity
      end
    end

    def notify_shipped(order)
      OrderMailer.shipped(order).deliver_later if order.email.present? || order.user&.email.present?
    end
  end
end
