class UpdateLimitsInMarks < ActiveRecord::Migration[6.0]
  def change
    remove_column :marks, :limits
    add_column :marks, :limits, :jsonb, default: []
  end
end
