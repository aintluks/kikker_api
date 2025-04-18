class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE ratings
      ADD CONSTRAINT check_rating_value_range
      CHECK (value BETWEEN 1 AND 5)
    SQL
  end
end
