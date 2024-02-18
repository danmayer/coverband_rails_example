class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title
      t.text :content
      t.string :author

      t.timestamps
    end
  end
end
