class ConvertNotesToText < ActiveRecord::Migration
  def change
    change_column :trades, :note, :text
  end
end
