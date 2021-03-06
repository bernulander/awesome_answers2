class User < ApplicationRecord
  # has_secure_password does a few things for us:
  # - it automatically adds `password` and `password_confirmation` attribute
  #   accessors
  # - it automatically adds a presence validator on the password
  # - it automatically adds a confirmation validator if you add a
  #   password confirmation field
  # - when password is provided `has_secure_password` will generate a salt and
  #   will generate a digest of the password + salt and it will store it in the
  #   `password_digest` field
  # - it gives us a handy method called `authentciate` that will help us check
  #   if the password is correct
  # http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
  has_secure_password

  has_many :questions, dependent: :nullify
  has_many :liked_questions, through: :likes, source: :question
  has_many :likes, dependent: :destroy

  has_many :votes, dependent: :destroy
  has_many :voted_questions, through: :votes, source: :question

  before_validation :downcase_email
  before_create :generate_api_key

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    uniqueness: true,
                    format: VALID_EMAIL_REGEX

  def full_name
    "#{first_name} #{last_name}".strip.titleize
  end

  private

  def downcase_email
    self.email&.downcase!
  end

  def generate_api_key
    loop do
      self.api_key = SecureRandom.hex
      break unless User.exists?(api_key: api_key)
    end
  end
end
