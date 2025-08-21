class TaxReturnsController < ApplicationViewController
  include Nav
  before_action :index, only: [ :index ]

  def index
    headers
    address = @session.address
    @navs = ledgers_navs(selected: TAX_RESULT)

    calculation = TaxReturns::Calculation.new(address: address, year: Time.current.year)
    @tax_return = calculation.execute
  end
end
