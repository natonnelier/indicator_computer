class CreateIndicators < ActiveRecord::Migration[6.0]
  def change
    create_table :indicators do |t|
      t.string :indicator_name, index: true
      t.string :indicator_symbol, index: true
      t.string :response_keys, array: true, default: []
      t.integer :min_data_size
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
