class IndexDate < ActiveRecord::Base
  attr_accessible :index, :date, :close

  before_save  :capitalize_index

  # ------------- Associations  --------------------


  # ------------- Validations  --------------------
  validates :index, presence: true
  validates :date, :presence => true, :uniqueness => {:scope => :index}
  validates :close, presence: true


  # ------------- Class Methods --------------------
  class << self
  end


  # ------------- Instance Methods -----------------



  def capitalize_index
    self.index.capitalize
  end

end

