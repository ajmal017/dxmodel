class CreateIndexDatesTable < ActiveRecord::Migration
  def change
    create_table :index_dates do |t|
      t.string :index
      t.date :date
      t.float :close, :default => 0.0

      t.timestamps
    end
  end
end
