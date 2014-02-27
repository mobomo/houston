class DashboardConfig
  include ActiveModel::Validations
  validates_presence_of :client_id, :client_secret, :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}

  def initialize(attributes = {})
    @attributes = attributes || {}
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end

  def client_id
    read_attribute_for_validation(:client_id)
  end

  def client_secret
    read_attribute_for_validation(:client_secret)
  end

  def email
    read_attribute_for_validation(:email)
  end

  def save
    return false unless valid?

    AppSettings.google_client_id = client_id
    AppSettings.google_client_secret = client_secret

    User.find_or_create_by_email_and_role_and_name email, 'SuperAdmin', 'Admin User'
    true
  end
end