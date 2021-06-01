class AddUserIdToHissekis < ActiveRecord::Migration[6.1]
  def change
    add_column :hissekis, :user_id, :integer
  end
end
