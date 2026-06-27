module Admin
  class UsersController < BaseController
    def index
      @users = policy_scope(User)

      if params[:q].present?
        query = "%#{params[:q].strip}%"
        @users = @users.where("first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q", q: query)
      end

      @users = @users.where(role: params[:role]) if params[:role].present?

      if params[:status] == "active"
        @users = @users.where(active: true)
      elsif params[:status] == "inactive"
        @users = @users.where(active: false)
      end

      @users = case params[:sort]
      when "name_asc"
        @users.order(:first_name, :last_name)
      when "name_desc"
        @users.order(first_name: :desc, last_name: :desc)
      else
        @users.order(created_at: :desc)
      end

      @pagy, @users = pagy(@users)
    end

    def search
      authorize User, :index?
      query = params[:q].to_s.strip
      users = policy_scope(User)
        .where("first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q", q: "%#{query}%")
      users = users.where(role: params[:role]) if params[:role].present?
      users = users.limit(10)

      render json: users.map { |user|
        {
          id: user.id,
          name: user.full_name,
          email: user.email,
          initials: "#{user.first_name[0]}#{user.last_name[0]}",
          role: user.role.titleize,
          role_class: case user.role
                      when "admin" then "bg-purple-50 text-purple-700"
                      else "bg-gray-100 text-gray-700"
                      end,
          url: admin_user_path(user)
        }
      }
    end

    def show
      @user = User.find(params[:id])
      authorize @user
      if @user.student?
        @subscription_plans = SubscriptionPlan.active.order(:price)
      end
      @payments = @user.payments.recent.limit(15)
    end

    def new
      @user = User.new
      authorize @user
    end

    def create
      @user = User.new(user_create_params)
      authorize @user

      respond_to do |format|
        if @user.save
          format.html { redirect_to admin_user_path(@user), notice: "#{@user.full_name} creado exitosamente." }
          format.json do
            render json: {
              id: @user.id,
              full_name: @user.full_name,
              email: @user.email
            }, status: :created
          end
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def grant_subscription
      @user = User.find(params[:id])
      authorize @user, :update?

      plan = SubscriptionPlan.find(params[:subscription_plan_id])
      period_end = params[:period_end].present? ? Date.parse(params[:period_end]).end_of_day : nil

      if period_end.nil?
        redirect_to admin_user_path(@user), alert: "Debes especificar la fecha de fin del periodo."
        return
      end

      ActiveRecord::Base.transaction do
        @user.user_subscription&.destroy!

        UserSubscription.create!(
          user: @user,
          subscription_plan: plan,
          status: "active",
          current_period_start: Time.current,
          current_period_end: period_end
        )

        currency = StudioSetting.get("currency") || "mxn"
        Payment.create!(
          user: @user,
          amount: plan.price,
          currency: currency,
          status: "succeeded",
          payment_method: params[:payment_method] || "cash",
          description: "#{plan.name} — otorgada por admin",
          payable: @user.reload.user_subscription
        )
      end

      redirect_to admin_user_path(@user), notice: "Suscripción #{plan.name} otorgada a #{@user.full_name}."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_user_path(@user), alert: "Error al otorgar suscripción: #{e.message}"
    rescue ArgumentError
      redirect_to admin_user_path(@user), alert: "Fecha inválida."
    end

    def edit
      @user = User.find(params[:id])
      authorize @user
    end

    def update
      @user = User.find(params[:id])
      authorize @user
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "Usuario actualizado exitosamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      authorize @user
      full_name = @user.full_name
      if @user.destroy
        redirect_to admin_users_path, notice: "#{full_name} eliminado exitosamente."
      else
        redirect_to admin_user_path(@user), alert: "No se pudo eliminar el usuario: #{@user.errors.full_messages.to_sentence.presence || 'tiene registros asociados que no se pueden borrar.'}"
      end
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :role, :active, :phone, :photo, :stripe_customer_id, :notes, :featured)
    end

    def user_create_params
      params.require(:user).permit(:first_name, :last_name, :email, :role, :active, :phone, :password, :password_confirmation, :photo)
    end
  end
end
