class User < ActiveRecord::Base
  
  has_many :comments
  
  attr_accessor :password
  before_save :encrypt_password
  before_save :create_uniq_username
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
  def create_uniq_username
    if name.present?
	    self.username = name.gsub(/\s+/, "").downcase + Time.now.strftime("%L").to_s
    end
  end

  def authenticate(email, password)
    user = User.find_by(email: email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

end