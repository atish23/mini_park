class Parking < ActiveRecord::Base
  has_many :transactions
end
