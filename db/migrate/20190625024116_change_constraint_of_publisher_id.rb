class ChangeConstraintOfPublisherId < ActiveRecord::Migration[6.0]
  def change
    change_column_null :books, :publisher_id, true 
  end
end
