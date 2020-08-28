class AddOperationToMarks < ActiveRecord::Migration[6.0]
  def change
    add_column :marks, :operation, :integer, default: 0
  end
end
