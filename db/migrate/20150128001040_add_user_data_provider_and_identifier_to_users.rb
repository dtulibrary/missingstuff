class AddUserDataProviderAndIdentifierToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_data, :text
    add_column :users, :provider, :text
    add_column :users, :identifier, :text
  end
end
