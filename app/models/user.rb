require 'dtu_rails_common/user_roles'

class User < ActiveRecord::Base
# Connects this user object to Hydra behaviors. 
  include Hydra::User# Connects this user object to Sufia behaviors. 
  include Sufia::User
  include DtuRailsCommon::UserRoles

  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4
# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
# devise :database_authenticatable, :registerable,
#        :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  serialize :user_data, JSON

  def to_s
    email
  end

  def self.create_or_update provider, user_data
    user = find_by_provider_and_identifier( provider, user_data['id'].to_s ) ||
           create( :provider => provider, :identifier => user_data['id'].to_s )

    user.user_data = user_data
    user.email = user_data['email'].to_s
    if user_data['applications_and_roles'] and user_data['applications_and_roles']['missingStuff']
      user.group_list = user_data['applications_and_roles']['missingStuff'].join(';?;')
    end
    user.save
    user
  end
end
