require "active_model"

class Customer < Struct.new(:name, :id)
  extend ActiveModel::Naming
  include ActiveModel::Conversion
end

class BadCustomer < Customer
end

class GoodCustomer < Customer
end