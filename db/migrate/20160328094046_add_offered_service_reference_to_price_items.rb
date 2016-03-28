class AddOfferedServiceReferenceToPriceItems < ActiveRecord::Migration
  def change
    add_reference :price_items, :offered_service, index: true, foreign_key: true
  end
end
