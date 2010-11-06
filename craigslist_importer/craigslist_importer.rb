require 'rubygems'
require 'mechanize'
require 'yaml'
require "erb"
require 'date'
require 'craigslist_area'

@search = YAML::load_file('config.yml')

class CraigslistImporter

  def initialize()
    super
    @results = Hash.new
    @agent = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
    }
    @search_date = Date.now();
  end
  
  def city_name(city_url)
    "#{city_url[/\/{1,1}[A-Za-z]*\./].chop.sub("/","")}"
  end
  
  def posting_date(job)
    date = job[/[A-Za-z]{3}\s*[0-9]{1,2}/]
    (!date.nil? ?  "#{date}" : "#{Time.now.month} #{Time.now.day}") + " #{Time.now.year}"
  end
  
  def search_city(state,city_url,section,query)
     current = "#{state}-#{city_name(city_url)}"
     @results[current] = CraigslistArea.new(current,@search_date) if @results[current].nil?
     begin
       @agent.get("#{city_url}search/#{section}?query=#{query}") do |page|
         page.search("p.row").each do |job|
           if job.to_html.include? city_url
             @results[current].add_result(job.to_html)
           end
         end
       end
     rescue
       @results[current];
       puts "Error: #{current}"
     end
   end
  def find_cities(state)
    @agent.get("http://geo.craigslist.org/iso/us/#{state}").search("#list/a")
  end
  
  def find_item_in_city(state,city_url,section)
    @options["query"].each do |query|
      search_city(state,city_url,section,query)
    end
  end
  
  def import(search)
    @options = search
    @options["states"].each do |state|
      find_cities(state).each do |city|
        @options["search"].each do |key , value|
          find_item_in_city(state,city["href"],value)
        end
      end
    end
    return @results;
  end
end