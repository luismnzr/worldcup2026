module ApplicationHelper
  SHIPPING_STATUS_LABELS = {
    "unfulfilled" => "Por enviar",
    "fulfilled"   => "Preparado",
    "shipped"     => "Enviado",
    "delivered"   => "Entregado"
  }.freeze

  ORDER_STATUS_LABELS = {
    "pending"   => "Pendiente",
    "completed" => "Completado",
    "cancelled" => "Cancelado"
  }.freeze

  def page_title(title)
    content_for(:title) { title }
    content_for(:page_title) { title }
  end

  def pagy_nav_tag(pagy)
    pagy.series_nav.html_safe
  end

  def t_shipping_status(status)
    SHIPPING_STATUS_LABELS[status.to_s] || status.to_s.titleize
  end

  def t_order_status(status)
    ORDER_STATUS_LABELS[status.to_s] || status.to_s.titleize
  end
end
