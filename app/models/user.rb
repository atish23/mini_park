class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token
  has_many :transactions
  before_save   :downcase_email
  before_create :create_activation_digest, :user_stripe_id
 require 'dragonfly'
  validates :name, presence: true
  NUMBER_REGEX =/\A[789]\d{9}\z/
  validates :mobile, presence:true, length:{is: 10}, format: {with: NUMBER_REGEX}

  #CAR_NUMBER_REGEX = Regexp.new('/\A[A-Z]{2}\s[0-9]{2}\s[A-Z]{2}\s[0-9]{4}\z/')

  validates :car_number, presence:true#, format: {with: CAR_NUMBER_REGEX}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
#  has_attached_file :qrcode, styles: { medium: "300x300>" }, default_url: "/images/:style/missing.png"
  dragonfly_accessor :qrcode
  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def user_stripe_id
    customer = Stripe::Customer.create(email: email)
    self.stripe_id = customer.id
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
      self.remember_token = User.new_token
      update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
     digest = send("#{attribute}_digest")
     return false if digest.nil?
     BCrypt::Password.new(digest).is_password?(token)
   end

    # Forgets a user.
    def forget
      update_attribute(:remember_digest, nil)
    end

    # Activates an account.
    # Activates an account.
    def activate
      update_attribute(:activated,    true)
      update_attribute(:activated_at, Time.zone.now)
    end

    # Sends activation email.
    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end

    # Sets the password reset attributes.
    def create_reset_digest
      self.reset_token = User.new_token
      update_attribute(:reset_digest,  User.digest(reset_token))
      update_attribute(:reset_sent_at, Time.zone.now)
    end

    # Sends password reset email.
    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end

    def password_reset_expired?
      reset_sent_at < 2.hours.ago
    end

    private

      # Converts email to all lower-case.
      def downcase_email
        self.email = email.downcase
      end

      # Creates and assigns the activation token and digest.
      def create_activation_digest
        self.activation_token  = User.new_token
        self.activation_digest = User.digest(activation_token)
      end



end
