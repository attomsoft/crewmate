class OauthToken < ActiveRecord::Base
  belongs_to :client_application
  belongs_to :user
  validates_uniqueness_of :token
  validates_presence_of :client_application, :token
  before_validation :generate_keys, :on => :create
  serialize :scope
  
  def scope=(value)
    if value.is_a? String
      self[:scope] = value.split(',').map(&:to_sym)
    else
      self[:scope] = value
    end
  end

  def invalidated?
    invalidated_at != nil
  end

  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end

  def authorized?
    authorized_at != nil && !invalidated?
  end

  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end

  protected

  def generate_keys
    self.token = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end
end
