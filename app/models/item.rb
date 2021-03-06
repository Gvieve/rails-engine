class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  validates_presence_of [:name, :description, :unit_price, :merchant_id], on: :create

  def self.find_one_by_name_fragment(search_term)
    where("name ILIKE ?", "%#{search_term}%")
    .order(:name)
    .limit(1)
    .first
  end

  def self.find_one_by_unit_price(min_price, max_price)
    min_price = 0 unless min_price
    max_price = 1_000_000_000_000 unless max_price
    where('unit_price >= ?', min_price)
    .where('unit_price <= ?', max_price )
    .order(:name)
    .limit(1)
    .first
  end

  def self.top_revenue(quantity)
    select('items.*')
    .select('sum(invoice_items.quantity * invoice_items.unit_price) as revenue')
    .joins(:transactions)
    .where("invoices.status = 'shipped'")
    .where("transactions.result = 'success'")
    .group(:id)
    .order('revenue desc')
    .limit(quantity)
  end
end
