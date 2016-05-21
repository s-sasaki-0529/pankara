#----------------------------------------------------------------------
# Pager - ページャを実装するためのクラス
#----------------------------------------------------------------------
class Pager
  attr_accessor :limit , :current_page , :page_num

  # initialize - 現在ページ、ページ総数、データ総数で初期化
  #--------------------------------------------------------------------
  def initialize(limit , current_page = 1)
    @limit = limit
    @current_page = current_page
    @page_num = 1
    @data_num = 0
  end

  # getData - ページャにて区切った範囲のデータを戻す
  #--------------------------------------------------------------------
  def getData(data)
    @page_num = (data.count.to_f / @limit.to_f).ceil
    from = (@current_page - 1) * @limit
    return data[from , @limit]
  end

end
