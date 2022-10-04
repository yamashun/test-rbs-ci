class User < ApplicationRecord
  has_many :todos

  class << self
    def hoge
      joins(:todos).merge(Todo.where(title: 'hoge'))
    end
  end
end
