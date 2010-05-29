#All google chart generation methods live here
module GoogleChart
  
  # chart related functions
  def generate_chart(chart_key, sorted_list, selected_sort, timestamp_index, selected_stat)
    time_interval = FileReader::TIME_INTERVALS
    stats_array = Table.get_all_stats(sorted_list, selected_stat, timestamp_index)    
    
    smallest = find_smallest(stats_array)
    largest = find_largest(stats_array)
    
    #todo: dynamically generate chart size
    bar_width = 'a,0,10'
    chart_height = 170
    chart_width = 400
    
    # handcrafted googlechart url
    chart = "http://chart.apis.google.com/chart?" + 
      "cht=bhs&" + 
      "chts=FF0000,15&" +
      "chs=#{chart_width}x#{chart_height}&" + # size
      "chd=t:#{stats_array.join(',')}&" + #data 
      "chds=#{smallest},#{largest}&" + # scale #TODO: this breaks with 1 data point
      "chxr=0,#{smallest},#{largest}&" + # values to be listed (high and low) 
      "chxt=x,y&" + # "chxl=1:|#{FileReader.get_all_names(sorted_list).reverse.map{|n| n.titleize}.join('|')}&" + #notice the order is reversed, put stat label here
      "chxl=1:|#{sorted_list.map {|t| t.id }.reverse.map{|n| n.titleize}.join('|')}&" + #notice the order is reversed, put stat label here
      "chco=FF0000&" +
      "chbh=#{bar_width}&" #bar width.x 23px is default
    if selected_sort == "name"  
      chart = chart + "chtt=#{selected_stat.titleize}, sorted by #{selected_sort.titleize}|every " + ((time_interval[timestamp_index] > 1 ? "#{time_interval[timestamp_index]} minutes" : 'second')) #title
    else
      chart = chart + "chtt=Sorted by #{selected_stat.titleize}|every " + (time_interval[timestamp_index] > 1 ? "#{time_interval[timestamp_index]} minutes" : 'minute') #title
    end
    chart
  end

  #todo: 2nd version of chart url creation.
  def generate_chart2(chart_key, sorted_list, selected_sort, timestamp_index, selected_stat)
    chart = "http://chart.apis.google.com/chart?"
    case chart_key[:type]
    when :A
      puts "A"
    when :B
      puts "B"
    when :C
      puts "C"
      chart = generate_chart(chart_key, sorted_list, selected_sort, timestamp_index, selected_stat)
    end 
    chart
  end
  
  
  def json_map(chart)
    chart_map = URI.encode(chart + "&chof=json")
    chart_map = `curl "#{chart_map}"`
    chart_map = JSON.parse(chart_map)
    return chart_map
  end
  
  def generate_html_map(json_map, sorted_list)
    map = "<map name=#{map_name}>\n"
    json_map["chartshape"].each do |area|
      #axes and bars: title and href
      title = ""
      href = ""
      item = ""
      
      if area["name"] =~ /axis1_(.+)/
        index = $1
        item = sorted_list.reverse[index.to_i]
        title = item.id  #this may be an actual name later
        href = item.is_a?(RangeServer) ? range_server_path(title) : table_path(title) #title is also id right now. todo: better way to determine the path?
      elsif area["name"] =~ /bar0_(.+)/
        index = $1
        item = sorted_list[index.to_i]
        title = item.id 
        href = item.is_a?(RangeServer) ? range_server_path(title) : table_path(title)  #todo: better way to determine path?
      end      
      map += "\t<area name='#{area["name"]}' shape='#{area["type"]}' coords='#{area["coords"].join(",")}' href=\"#{href}\" title='#{title}'>\n"
    end
    map += "</map>\n"
  end
  
  # used in view template and controller
  def map_name
    return "generic_map_name" unless @selected_sort && @selected_stat && @timestamp_index
    return "#{@selected_sort}_#{@selected_stat}_#{@timestamp_index}"
  end
  
  
end