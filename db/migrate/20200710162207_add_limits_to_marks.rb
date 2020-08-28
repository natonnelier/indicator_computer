class AddLimitsToMarks < ActiveRecord::Migration[6.0]
  def change
    add_column :marks, :limits, :string, array: true, default: []
  end
end
