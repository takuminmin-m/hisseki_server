class CreateHissekis < ActiveRecord::Migration[6.1]
  def change
    create_table :hissekis do |t|
      t.string :image

      t.timestamps
    end
  end
end
