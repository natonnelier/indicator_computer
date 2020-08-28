class AddOptionsToMarks < ActiveRecord::Migration[6.0]
  def change
    add_column :marks, :options, :jsonb, default: {}
  end
end
