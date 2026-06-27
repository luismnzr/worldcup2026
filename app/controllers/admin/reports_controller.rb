module Admin
  class ReportsController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      respond_to do |format|
        format.html
        format.csv { send_csv_export }
      end
    end

    private

    def send_csv_export
      case params[:export]
      when "students"
        send_data students_csv, filename: "students-#{Date.current}.csv", type: "text/csv"
      when "shop"
        send_data shop_csv, filename: "shop-orders-#{Date.current}.csv", type: "text/csv"
      else
        redirect_to admin_reports_path, alert: "Unknown export type."
      end
    end

    def students_csv
      require "csv"
      CSV.generate(headers: true) do |csv|
        csv << [ "Nombre", "Email", "Teléfono", "Registro", "Suscripción" ]
        User.students.order(:last_name).find_each do |u|
          csv << [
            u.full_name,
            u.email,
            u.phone,
            u.created_at.strftime("%Y-%m-%d"),
            u.has_active_subscription? ? "Activa" : "Sin suscripción"
          ]
        end
      end
    end

    def shop_csv
      require "csv"
      CSV.generate(headers: true) do |csv|
        csv << [ "Order #", "Fecha", "Cliente", "Producto", "Cantidad", "Precio Unitario", "Subtotal", "Método de pago", "Estado" ]
        Order.includes(:user, order_items: :product).order(created_at: :desc).find_each do |order|
          order.order_items.each do |item|
            csv << [
              order.id,
              order.created_at.strftime("%Y-%m-%d %H:%M"),
              order.user&.full_name || "Walk-in",
              item.product.name,
              item.quantity,
              item.unit_price,
              item.quantity * item.unit_price,
              order.payment_method,
              order.status
            ]
          end
        end
      end
    end
  end
end
