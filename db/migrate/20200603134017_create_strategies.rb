class CreateStrategies < ActiveRecord::Migration[6.0]
  def change
    create_table :strategies do |t|
      t.string :name, index: true
      t.integer :user_id, index: true
      t.integer :min_buy_required, default: 1
      t.integer :min_sell_required, default: 1
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
