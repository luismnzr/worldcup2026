class ProductsController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @products = Product.active.order(:name)
  end

  def show
    @product = find_product!
  end

  private

  def find_product!
    Product.active.find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    Product.active.find(params[:id])
  end
end
