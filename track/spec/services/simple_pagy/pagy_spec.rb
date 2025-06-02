require 'rails_helper'

RSpec.describe SimplePagy::Pagy, type: :feature do
  let(:pagy_nil_page) { SimplePagy::Pagy.new(request_page: nil) }
  let(:pagy_invalid_page) { SimplePagy::Pagy.new(request_page: "aaaa") }
  let(:pagy_1_page) { SimplePagy::Pagy.new(request_page: "1") }
  let(:pagy_2_page) { SimplePagy::Pagy.new(request_page: "2") }
  let(:pagy_2_page_with_request) { SimplePagy::Pagy.new(request_page: "2", request_query: { transaction_type_id: 1 }) }


  describe 'set_offset' do
    context 'offset value.' do
      it 'should get 0 when page is nil.' do
        pagy_nil_page.set_offset
        expect(pagy_nil_page.offset).to eq(0)
      end

      it 'should get 0 when page is invalid.' do
        pagy_invalid_page.set_offset
        expect(pagy_invalid_page.offset).to eq(0)
      end

      it 'should get 0 when page is 1.' do
        pagy_1_page.set_offset
        expect(pagy_1_page.offset).to eq(0)
      end

      it 'should get 50 when page is 2.' do
        pagy_2_page.set_offset
        expect(pagy_2_page.offset).to eq(50)
      end
    end
  end

  describe 'set_current_page' do
    context 'current_page value.' do
      it 'should get 0 when page is nil.' do
        pagy_nil_page.set_offset.set_current_page
        expect(pagy_nil_page.current_page).to eq(1)
      end

      it 'should get 0 when page is invalid.' do
        pagy_invalid_page.set_offset.set_current_page
        expect(pagy_invalid_page.current_page).to eq(1)
      end

      it 'should get 1 when page is 1.' do
        pagy_1_page.set_offset.set_current_page
        expect(pagy_1_page.current_page).to eq(1)
      end

      it 'should get 2 when page is 2.' do
        pagy_2_page.set_offset.set_current_page
        expect(pagy_2_page.current_page).to eq(2)
      end
    end
  end

  describe 'set_total' do
    context 'total value.' do
      it 'should get 0 when page is nil.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 0)
        expect(pagy_nil_page.total).to eq(0)
      end

      it 'should get 0 when page is invalid.' do
        expect { pagy_invalid_page.set_offset.set_current_page.set_total(total: nil).set_page }.to raise_error(SimplePagy::Pagy::NotFoundTotal)
      end

      it 'should get 50 when page is 1 and total is 50.' do
        pagy_1_page.set_offset.set_current_page.set_total(total: 50)
        expect(pagy_1_page.total).to eq(50)
      end
    end
  end

  describe 'set_page' do
    context 'page value.' do
      # pageパラメーターなしでデータ数が0
      it 'should get 1 when total is 0.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 0).set_page
        expect(pagy_nil_page.page).to eq(1)
      end

      # pageパラメーターなしでデータ数が1
      it 'should get 1 when total is 0.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 1).set_page
        expect(pagy_nil_page.page).to eq(1)
      end

      # pageパラメーターなしでデータ数がaaaa(ありえない)
      it 'should get 1 when total is invalid.' do
        expect { pagy_nil_page.set_offset.set_current_page.set_total(total: "aaaa").set_page }.to raise_error(SimplePagy::Pagy::InvalidTotal)
      end

      # pageパラメーターなしでデータ数がnil(ありえないはず)
      it 'should get 1 when total is invalid.' do
        expect { pagy_nil_page.set_offset.set_current_page.set_total(total: nil).set_page }.to raise_error(SimplePagy::Pagy::NotFoundTotal)
      end

      # pageパラメーター1でデータ数が0
      it 'should get 1 when page is 1.' do
        pagy_1_page.set_offset.set_current_page.set_total(total: 0).set_page
        expect(pagy_1_page.page).to eq(1)
      end

      # pageパラメーター1でデータ数が1
      it 'should get 1 when page is 1 and total is 1.' do
        pagy_1_page.set_offset.set_current_page.set_total(total: 1).set_page
        expect(pagy_1_page.page).to eq(1)
      end

      # pageパラメーター1でデータ数が50
      it 'should get 1 when page is 1 and total is 50.' do
        pagy_1_page.set_offset.set_current_page.set_total(total: 50).set_page
        expect(pagy_1_page.page).to eq(1)
      end

      # pageパラメーター1でデータ数が51
      it 'should get 1 when page is 1 and total is 51.' do
        pagy_1_page.set_offset.set_current_page.set_total(total: 51).set_page
        expect(pagy_1_page.page).to eq(2)
      end

      # pageパラメーター2でデータ数が0
      it 'should get 1 when page is 2 and total is 0.' do
        pagy_2_page.set_offset.set_current_page.set_total(total: 0).set_page
        expect(pagy_2_page.page).to eq(1)
      end

      # pageパラメーター2でデータ数が51
      it 'should get 1 when page is 2 and total is 51.' do
        pagy_2_page.set_offset.set_current_page.set_total(total: 51).set_page
        expect(pagy_2_page.page).to eq(2)
      end
    end
  end

  describe 'set_start_data_number' do
    context 'start_data_number value.' do
      # pageパラメーターなしでデータ数が0
      it 'should get 0 when page is nil total is 0.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 0).set_page.set_start_data_number
        expect(pagy_nil_page.start_data_number).to eq(0)
      end

      # pageパラメーターなしでデータ数が1
      it 'should get 1 when page is nil and total is 1.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 1).set_page.set_start_data_number
        expect(pagy_nil_page.start_data_number).to eq(1)
      end

      # pageパラメーターなしでデータ数が50
      it 'should get 50 when page is nil and total is 50.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 50).set_page.set_start_data_number
        expect(pagy_nil_page.start_data_number).to eq(1)
      end

      # pageパラメーターなしでデータ数が51
      it 'should get 50 when page is 1 and total is 50.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 51).set_page.set_start_data_number
        expect(pagy_nil_page.start_data_number).to eq(1)
      end

      # pageパラメーター2でデータ数が51
      it 'should get 50 when page is 2 and total is 51.' do
        pagy_2_page.set_offset.set_current_page.set_total(total: 51).set_page.set_start_data_number
        expect(pagy_2_page.start_data_number).to eq(51)
      end
    end
  end

  describe 'set_end_data_number' do
    context 'end_data_number value.' do
      # pageパラメーターなしでデータ数が0
      it 'should get 0 when page is nil total is 0.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 0).set_page.set_start_data_number.set_end_data_number
        expect(pagy_nil_page.end_data_number).to eq(0)
      end

      # pageパラメーターなしでデータ数が10
      it 'should get 0 when page is nil total is 10.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 10).set_page.set_start_data_number.set_end_data_number
        expect(pagy_nil_page.end_data_number).to eq(10)
      end

      # pageパラメーター2でデータ数が80
      it 'should get 0 when page is nil total is 80.' do
        pagy_2_page.set_offset.set_current_page.set_total(total: 80).set_page.set_start_data_number.set_end_data_number
        expect(pagy_2_page.end_data_number).to eq(80)
      end
    end
  end

  describe 'set_prev_query' do
    context 'prev_query value.' do
      # pageパラメーターなしでデータ数が100
      it 'should empty when page is nil total is 100.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 100).set_page.set_start_data_number.set_end_data_number.set_prev_query
        expect(pagy_nil_page.prev_query).to eq("")
      end

      # pageパラメーター2でデータ数が100
      it 'should query when page is 2 total is 100.' do
        pagy_2_page.set_offset.set_current_page.set_total(total: 100).set_page.set_start_data_number.set_end_data_number.set_prev_query
        expect(pagy_2_page.prev_query).to eq("page=1")
      end

      # pageパラメーター2でデータ数が100
      it 'should query when page is 2 total is 100.' do
        pagy_2_page_with_request.set_offset.set_current_page.set_total(total: 100).set_page.set_start_data_number.set_end_data_number.set_prev_query
        expect(pagy_2_page_with_request.prev_query).to eq("page=1&transaction_type_id=1")
      end
    end
  end

  describe 'set_next_query' do
    context 'next_query value.' do
      # pageパラメーターなしでデータ数が100
      it 'should empty when page is nil total is 100.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 100).set_page.set_start_data_number.set_end_data_number.set_prev_query.set_next_query
        expect(pagy_nil_page.next_query).to eq("page=2")
      end

      # pageパラメーター1でデータ数が100
      it 'should empty when page is nil total is 100.' do
        pagy_1_page.set_offset.set_current_page.set_total(total: 100).set_page.set_start_data_number.set_end_data_number.set_prev_query.set_next_query
        expect(pagy_1_page.next_query).to eq("page=2")
      end

      # pageパラメーター2でデータ数が100
      it 'should query when page is 2 total is 100.' do
        pagy_2_page.set_offset.set_current_page.set_total(total: 100).set_page.set_start_data_number.set_end_data_number.set_prev_query.set_next_query
        expect(pagy_2_page.next_query).to eq("page=2")
      end

      # pageパラメーター2でデータ数が100
      it 'should query when page is 2 total is 100.' do
        pagy_2_page_with_request.set_offset.set_current_page.set_total(total: 100).set_page.set_start_data_number.set_end_data_number.set_prev_query.set_next_query
        expect(pagy_2_page_with_request.next_query).to eq("page=2&transaction_type_id=1")
      end
    end
  end

  describe 'set_pages_query' do
    context 'pages_query value.' do
      # pageパラメーターなしでデータ数が100
      it 'should queryes when page is nil total is 100.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 100).set_page.set_start_data_number.set_end_data_number.set_prev_query.set_next_query.set_pages_query
        expect(pagy_nil_page.pages_query).to eq([ { page: 1, query: "page=1" }, { page: 2, query: "page=2" } ])
      end

      # pageパラメーターなしでデータ数が101
      it 'should queryes when page is nil total is 101.' do
        pagy_nil_page.set_offset.set_current_page.set_total(total: 101).set_page.set_start_data_number.set_end_data_number.set_prev_query.set_next_query.set_pages_query
        expect(pagy_nil_page.pages_query).to eq([ { page: 1, query: "page=1" }, { page: 2, query: "page=2" }, { page: 3, query: "page=3" } ])
      end

      # pageパラメーター2でデータ数が100
      it 'should queryes when page is 2 total is 101.' do
        pagy_2_page_with_request.set_offset.set_current_page.set_total(total: 101).set_page.set_start_data_number.set_end_data_number.set_prev_query.set_pages_query
        expect(pagy_2_page_with_request.pages_query).to eq([ { page: 1, query: "page=1&transaction_type_id=1" }, { page: 2, query: "page=2&transaction_type_id=1" }, { page: 3, query: "page=3&transaction_type_id=1" } ])
      end
    end
  end
end
