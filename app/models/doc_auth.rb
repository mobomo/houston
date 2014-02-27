class DocAuth < ActiveRecord::Base
  attr_accessible :username, :password, :key, :current

  validates :username, :presence => true
  validates :password, :presence => true
  validates :key, :presence => true


  def self.current_doc
    self.where(:current => true).first
  end

  def set_as_current
    DocAuth.all.each do |d|
      if d == self
        self.update_attributes(:current => true)
      else
        d.update_attributes(:current => false)
      end
    end
  end

  def value_of(key)
    self.try(key) || DocAuth.first.try(key)
  end
end
