module Admin
  class PromotionCodesController < BaseController
    def index
      @promotion_codes = policy_scope(PromotionCode).ordered
    end

    def new
      @promotion_code = PromotionCode.new(discount_type: "percent_off", applies_to: "all", active: true)
      authorize @promotion_code
    end

    def create
      @promotion_code = PromotionCode.new(promotion_code_params)
      authorize @promotion_code

      PromotionCode.transaction do
        @promotion_code.save!
        sync_to_stripe!(@promotion_code)
      end

      redirect_to admin_promotion_codes_path, notice: "Código de promoción creado."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    rescue Stripe::StripeError => e
      @promotion_code.destroy if @promotion_code.persisted?
      flash.now[:alert] = "Error de Stripe: #{e.message}"
      render :new, status: :unprocessable_entity
    end

    def toggle
      @promotion_code = PromotionCode.find(params[:id])
      authorize @promotion_code, :update?

      new_active = !@promotion_code.active?
      @promotion_code.update!(active: new_active)

      if @promotion_code.stripe_promotion_code_id.present?
        Stripe::PromotionCode.update(@promotion_code.stripe_promotion_code_id, active: new_active)
      end

      status = new_active ? "activado" : "desactivado"
      redirect_to admin_promotion_codes_path, notice: "Código #{status}."
    rescue Stripe::StripeError => e
      redirect_to admin_promotion_codes_path, alert: "Error de Stripe: #{e.message}"
    end

    private

    def promotion_code_params
      params.require(:promotion_code).permit(:code, :discount_type, :discount_value, :applies_to, :max_redemptions, :expires_at, :active)
    end

    def sync_to_stripe!(promo)
      currency = StudioSetting.currency

      coupon_params = { duration: "forever", metadata: { applies_to: promo.applies_to } }
      if promo.percent_off?
        coupon_params[:percent_off] = promo.discount_value.to_f
      else
        coupon_params[:amount_off] = (promo.discount_value * 100).to_i
        coupon_params[:currency] = currency
      end

      coupon = Stripe::Coupon.create(coupon_params)

      pc_params = { coupon: coupon.id, code: promo.code, active: promo.active?, metadata: { applies_to: promo.applies_to } }
      pc_params[:max_redemptions] = promo.max_redemptions if promo.max_redemptions.present?
      pc_params[:expires_at] = promo.expires_at.to_i if promo.expires_at.present?

      stripe_pc = Stripe::PromotionCode.create(pc_params)

      promo.update_columns(stripe_coupon_id: coupon.id, stripe_promotion_code_id: stripe_pc.id)
    end
  end
end
