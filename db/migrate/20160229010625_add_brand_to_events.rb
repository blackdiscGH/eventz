class AddBrandToEvents < ActiveRecord::Migration
  def change
    add_column :events, :brand, :string
  end
end
