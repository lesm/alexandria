class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.string :title
      t.text :subtitle
      t.string :isbn_10
      t.string :isbn_13
      t.text :description
      t.date :released_on
      t.references :publisher, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true

      t.timestamps
    end
    add_index :books, :title
    add_index :books, :isbn_10
    add_index :books, :isbn_13
  end
end
