module Admin
  class SettingsController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def show
    end

    def update
      params[:settings]&.each do |key, value|
        StudioSetting.set(key, value)
      end

      redirect_to admin_settings_path, notice: "Configuración actualizada exitosamente."
    end
  end
end
