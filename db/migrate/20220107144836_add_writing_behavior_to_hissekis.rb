class AddWritingBehaviorToHissekis < ActiveRecord::Migration[6.1]
  def change
    add_column :hissekis, :writing_behavior, :text
  end
end
