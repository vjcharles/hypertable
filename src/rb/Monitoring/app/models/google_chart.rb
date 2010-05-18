#All google chart generation methods now live here (not the perm home for this module)
module GoogleChart
  
  # chart related functions
  
  #todo: clean this up. manually generated google chart (probably deleting google chart plugin soon...not needed)
  def generate_chart(data_array, selected_sort, selected_index, selected_data, time_interval, sorted_tables)
    smallest = find_smallest(data_array)
    largest = find_largest(data_array)
    
    # handcrafted googlechart url
    chart = "http://chart.apis.google.com/chart?" + 
      "cht=bhs&" + 
      "chts=FF0000,15&" +
      "chs=500x170&" + # size
      "chd=t:#{data_array.join(',')}&" + #data 
      "chds=#{smallest},#{largest}&" + # scale
      "chxr=0,#{smallest},#{largest}&" + # values to be listed (high and low)
      "chxt=x,y&" + 
      "chxl=1:|#{Table.get_all_names(sorted_tables).reverse.map{|n| "name " + n.titleize}.join('|')}&" + #notice the order is reversed, put stat label here
      "chco=FF0000&" +
      "chbh=12&" #bar width.x 23px is default
    if selected_sort == "name"  
      chart = chart + "chtt=#{selected_data.titleize}, sorted by #{selected_sort.titleize}|every " + ((time_interval[selected_index] > 1 ? "#{time_interval[selected_index]} minutes" : 'second')) #title
    else
      chart = chart + "chtt=Sorted by #{selected_data.titleize}|every " + (time_interval[selected_index] > 1 ? "#{time_interval[selected_index]} minutes" : 'minute') #title
    end
    chart
  end
  
  
  def json_map(chart)
    chart_map = URI.encode(chart + "&chof=json")
    chart_map = `curl "#{chart_map}"`
    chart_map = JSON.parse(chart_map)
    return chart_map
  end
  
  def generate_html_map(json_map, sorted_tables)
    map = "<map name=#{map_name}>\n"
    json_map["chartshape"].each do |area|
      #axes and bars: title and href
      title = ""
      href = ""
      if area["name"] =~ /axis1_(.+)/
        index = $1
        title = sorted_tables.reverse[index.to_i].table_id  #this may be an actual name later
        href = tables_path(title) #title is also id right now. may change...
      elsif area["name"] =~ /bar0_(.+)/
        index = $1
        title = sorted_tables[index.to_i].table_id 
        href = table_path(title)
      end      
      map += "\t<area name='#{area["name"]}' shape='#{area["type"]}' coords='#{area["coords"].join(",")}' href=\"#{href}\" title='#{title}'>\n"
    end
    map += "</map>\n"
  end
  
  # used in view template and controller
  def map_name
    return "generic_map_name" unless @selected_sort && @selected_data && @selected_index
    return "#{@selected_sort}_#{@selected_data}_#{@selected_index}"
  end
  
  
end