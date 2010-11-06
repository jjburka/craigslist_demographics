class CraigslistArea
  
  attr_accessor :area_name
  attr_accessor :state
  attr_reader :count
  attr_accessor :results
  attr_accessor :search_date
  
  def initialize(name,search_date)
    super()
    name = name.split("-")
    @state = name[0]
    @area_name = name[1]
    @results = []
    @search_date = search_date
  end
  
  def count
    @results.count
  end
  
  def add_result(result)
    @results << result unless @results.include? result
  end
  
end