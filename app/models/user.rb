class User < ApplicationRecord
  include AdminNotifiable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { student: 0, admin: 2 }

  has_one :user_subscription, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :event_registrations, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :predictions, dependent: :destroy

  has_one_attached :photo

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, length: { maximum: 20 }, allow_blank: true

  before_validation :normalize_phone
  before_validation :normalize_stripe_customer_id

  after_create_commit :send_welcome_email, if: :student?
  after_create_commit :notify_admin_new_user

  scope :active, -> { where(active: true) }
  scope :students, -> { where(role: :student) }
  scope :admins, -> { where(role: :admin) }

  def full_name
    "#{first_name} #{last_name}"
  end

  # Nombre visible en leaderboard/quiniela. Cae al primer nombre si no se eligió.
  def display_name_or_default
    display_name.presence || first_name.presence || email.split("@").first
  end

  def entry_for(tournament)
    entries.find_by(tournament: tournament)
  end

  def paid_entry?(tournament)
    entry_for(tournament)&.paid?
  end

  def active_subscription
    user_subscription&.active? ? user_subscription : nil
  end

  def has_active_subscription?
    user_subscription&.status == "active"
  end

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end

  def notify_admin_new_user
    create_admin_notification(
      title: "Nuevo usuario registrado",
      body: "#{full_name} se registró como #{role}",
      category: "new_user",
      action_url: "/admin/users"
    )
  end

  def normalize_phone
    return if phone.blank?
    self.phone = phone.gsub(/[^\d+]/, "")
  end

  def normalize_stripe_customer_id
    self.stripe_customer_id = nil if stripe_customer_id.blank?
  end
end
