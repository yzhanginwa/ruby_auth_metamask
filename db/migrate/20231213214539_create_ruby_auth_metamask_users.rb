class CreateRubyAuthMetamaskUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :ruby_auth_metamask_users do |t|
      t.string :address

      t.timestamps
    end
  end
end
