# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include GoogleChart
  
  def sort_data_hash(data)
    data.sort {|a,b| a.to_s <=> b.to_s }
  end
  
  def pretty_titleize(title)
    t = title.titleize
    if t =~ /K Bps/
      return title.titleize.gsub!(/K Bps/,"KBps") 
    elsif t =~ /Cpu/
      return title.titleize.gsub!(/Cpu/,"CPU") 
    else
      return title.titleize
    end
  end
  
end
