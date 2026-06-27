class StudioSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  DEFAULTS = {
    "studio_name" => "Studio",
    "studio_email" => "",
    "studio_phone" => "",
    "studio_address" => "",
    "studio_schedule" => "Lun - Vie\n9:00 AM - 7:00 PM",
    "studio_timezone" => "America/Mexico_City",
    "currency" => "mxn",
    "football_data_api_token" => ""
  }.freeze

  def self.get(key)
    find_by(key: key)&.value || DEFAULTS[key.to_s]
  end

  ALLOWED_KEYS = DEFAULTS.keys.freeze

  def self.set(key, value)
    unless ALLOWED_KEYS.include?(key.to_s)
      Rails.logger.warn "Rejected unknown studio setting key: #{key}"
      return
    end

    setting = find_or_initialize_by(key: key)
    setting.update!(value: value.to_s)
  end

  def self.studio_timezone
    get("studio_timezone") || "America/Mexico_City"
  end

  def self.currency
    get("currency") || "mxn"
  end
end
