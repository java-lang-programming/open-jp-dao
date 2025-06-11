module SimplePagy
  class Pagy
    DEFAULT_LIMIT = 50

    # offsetがない
    class NotFoundOffset < StandardError; end
    # 全データ数がない
    class NotFoundTotal < StandardError; end
    # 現在ページ数がない
    class NotFoundCurrentPage < StandardError; end
    # 不正な全データ数
    class InvalidTotal < StandardError; end

    # リクエストページ, クエリ, オフセット値, 全データ数, ページ数, 現在のページ, ページのデータ開始件数, ページのデータ終了件数, 前のページのクエリ, 次のページのクエリ, ページのクエリ
    attr_accessor :request_page, :request_query, :offset, :total, :page, :current_page, :start_data_number, :end_data_number, :prev_query, :next_query, :pages_query

    def initialize(request_page: nil, request_query: {})
      unless request_page.present?
        @request_page = 1
      else
        begin
          @request_page = Integer(request_page)
        rescue => e
          # 強制的に1
          @request_page = 1
        end
      end
      if request_query.present?
        @request_query = request_query.except(:page)
      else
        @request_query = {}
      end
    end

    # Pagyオブジェクトを生成する
    def build(total: nil)
      set_offset.set_current_page.set_total(
        total: total
      ).set_page.set_start_data_number.set_end_data_number.set_prev_query.set_next_query.set_pages_query
    end

    def set_offset
      @offset ||= (@request_page - 1) * DEFAULT_LIMIT
      self
    end

    def set_current_page
      raise NotFoundOffset unless @offset.present?
      @current_page ||= (@offset / DEFAULT_LIMIT) + 1
      self
    end

    def set_total(total: nil)
      raise NotFoundTotal unless total.present?

      begin
        @total = Integer(total)
      rescue => e
        raise InvalidTotal
      end
      self
    end

    def set_page
      raise NotFoundTotal unless @total.present?

      @total = total

      temp_page = @total / DEFAULT_LIMIT
      if temp_page == 0
        temp_page = 1
      elsif total.modulo(DEFAULT_LIMIT) != 0
        temp_page = temp_page + 1
      end
      @page = temp_page
      self
    end

    def set_start_data_number
      @start_data_number = (@current_page * DEFAULT_LIMIT) - (DEFAULT_LIMIT - 1)
      @start_data_number = 0 if @total == 0
      self
    end

    def set_end_data_number
      @end_data_number = @current_page * DEFAULT_LIMIT
      @end_data_number = @total if @end_data_number > @total
      self
    end

    def set_prev_query
      hash = @request_query
      hash = hash.merge({ page: @current_page - 1 }) if @current_page > 1
      @prev_query = hash.to_query
      self
    end

    def set_next_query
      hash = @request_query
      if @current_page == @page
        hash = hash.merge({ page: @page })
      else
        hash = hash.merge({ page: @current_page + 1 })
      end
      @next_query = hash.to_query
      self
    end

    def set_pages_query
      pages = []
      @page.times do |pn|
        # 処理を行うページ
        page = pn + 1
        hash = { page: page }
        if @request_query.present?
          hash = hash.merge(@request_query)
        end
        pages << { page: page, query: hash.to_query }
      end
      @pages_query = pages
      self
    end
  end
end
