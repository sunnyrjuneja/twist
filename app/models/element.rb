class Element
  include Mongoid::Document
  extend Processor
  field :tag, :type => String
  field :identifier, :type => String
  field :title, :type => String
  field :content, :type => String
  
  embedded_in :chapter
end