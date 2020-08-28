class CreateMarks < ActiveRecord::Migration[6.0]
  def change
    create_table :marks do |t|
      t.integer :indicator_id, index: true
      t.integer :strategy_id, index: true
      t.boolean :required, default: false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
