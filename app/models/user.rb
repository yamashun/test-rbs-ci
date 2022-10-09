class User < ApplicationRecord
  has_many :todos

  class << self
    def hoge(title)
      joins(:todos).merge(Todo.where(title: title))
    end
  end
end
