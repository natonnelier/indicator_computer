class AddFilesetToMarks < ActiveRecord::Migration[6.0]
  def change
    add_column :marks, :fileset, :string
  end
end
