class RenamePositionsTableToTrades < ActiveRecord::Migration
  def self.up
    rename_table :positions, :trades
  end

 def self.down
    rename_table :trades, :positions
 end
end
