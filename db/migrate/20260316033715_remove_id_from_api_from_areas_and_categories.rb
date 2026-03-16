class RemoveIdFromApiFromAreasAndCategories < ActiveRecord::Migration[7.1]
  def change
    remove_column :areas, :id_from_api, :string
    remove_column :categories, :id_from_api, :string
  end
end