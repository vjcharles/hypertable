#All google chart generation methods live here
module GoogleChart
  DEFAULT_COLORS = "00DD00"
  CRITICAL_COLOR = "FF0000"
  MODERATE_COLOR = "FFB90F"

  #todo: 2nd version of chart url creation.
  def generate_chart(chart_key, sorted_stats, selected_sort, timestamp_index, selected_stat)
    chart = ChartURL.new

    time_interval = FileReader::TIME_INTERVALS
    bar_width_or_scale = 12
    space_between_bars = 2
    space_between_groups = 10
    bar_width = "#{bar_width_or_scale},#{space_between_bars},#{space_between_groups}"

    # generates chart height.
    chart_height = 100 + (
                          bar_width_or_scale * chart_key[:stats].length + 
                          space_between_bars * (chart_key[:stats].length - 1)
                        ) * sorted_stats.length
    chart_width = 400
    
    options = { 
      :chts =>"FF0000,15",
      :chxt => "x,y",
      :chco => DEFAULT_COLORS,
      :chbh => "#{bar_width}", #bar width.x 23px is default
      :chs => "#{chart_width}x#{chart_height}"  # size
    }

    if selected_sort == "name"  
      options[:chtt] = "#{selected_stat.titleize}, sorted by #{selected_sort.titleize}|every " + ((time_interval[timestamp_index] > 1 ? "#{time_interval[timestamp_index]} minutes" : 'second')) #title
    else
      options[:chtt] = "Sorted by #{selected_stat.titleize}|every " + (time_interval[timestamp_index] > 1 ? "#{time_interval[timestamp_index]} minutes" : 'minute') #title
    end


    case chart_key[:type]
    when :A
      # puts "A"
      # chd = chart data
      x_stats = Table.get_all_stats(sorted_stats, chart_key[:stats][0], timestamp_index)
      y_stats = Table.get_all_stats(sorted_stats, chart_key[:stats][1], timestamp_index)
      smallest = find_smallest([x_stats, y_stats])
      largest = find_largest([x_stats, y_stats])

      stats = ChartValue.new([x_stats, y_stats])

      options[:chd] = "t:#{stats}"

      options[:chds] = "#{smallest},#{largest}" # scale #TODO: this breaks with 1 data point
      options[:chxr] = "0,#{smallest},#{largest}" # values to be listed (high and low)

      chart_height += space_between_groups * (sorted_stats.length - 1)        
      options[:chs] = "#{chart_width}x#{chart_height}"  # size

      options[:chxl] = "1:|#{sorted_stats.map {|t| t.id }.reverse.map{|n| n.titleize}.join('|')}" #notice the order is reversed, put stat label here

      percents = Array.new(x_stats.length)
      percents_strings = Array.new(x_stats.length)
      x_stats.each_with_index { |x, i| 
        percents[i] = round_to(x / (y_stats[i] * 1.0), 4) * 100
        percents_strings[i] = percents[i].to_s + "%"
      }
      percents
      percents_strings.reverse!
      options[:chxt] = "x,y,r"
      options[:chxl] += "|2:|#{percents_strings.join '|'}"

      bar_colors = []
      percents.each do |percent|
        if percent >= 95
          bar_colors.push CRITICAL_COLOR
        elsif percent >= 80
          bar_colors.push MODERATE_COLOR
        else
          bar_colors.push DEFAULT_COLORS
        end
      end
      options[:chco] = bar_colors.join '|'

      chart = ChartURL.new("http://chart.apis.google.com/chart", "bhg", options)
    when :B
      # puts "B"

    when :C
      # puts "C"      
      stats_array = Table.get_all_stats(sorted_stats, selected_stat, timestamp_index)    

      smallest = find_smallest(stats_array)
      largest = find_largest(stats_array)
      
      options[:chd] = "t:#{stats_array.join(',')}"
      options[:chds] = "#{smallest},#{largest}" # scale #TODO: this breaks with 1 data point
      options[:chxr] = "0,#{smallest},#{largest}" # values to be listed (high and low)
      options[:chxl] = "1:|#{sorted_stats.map {|t| t.id }.reverse.map{|n| n.titleize}.join('|')}" #notice the order is reversed, put stat label here

      chart = ChartURL.new("http://chart.apis.google.com/chart", "bhs", options)

    end 
    # puts chart
    chart.to_s
  end
  
  
  def json_map(chart)
    chart_map = URI.encode(chart + "&chof=json")
    chart_map = `curl "#{chart_map}"`
    chart_map = JSON.parse(chart_map)
    return chart_map
  end
  
  def generate_html_map(json_map, sorted_stats)
    map = "<map name=#{map_name}>\n"
    json_map["chartshape"].each do |area|
      #axes and bars: title and href
      title = ""
      href = ""
      item = ""
      
      if area["name"] =~ /axis1_(.+)/
        index = $1
        item = sorted_stats.reverse[index.to_i]
        title = item.id  #this may be an actual name later
        href = item.is_a?(RangeServer) ? range_server_path(title) : table_path(title) #title is also id right now. todo: better way to determine the path?
      elsif area["name"] =~ /bar0_(.+)/
        index = $1
        item = sorted_stats[index.to_i]
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

#options is only 1 level deep of concatination 
# when giving values to various chart parameters the data needs to be formatted properly for that param ("|", or  "," delimited )
class ChartURL
  def initialize (base_url=nil, chart_type=nil, options={})
    @base_url = base_url
    @chart_type = chart_type
    @options = options
  end
  
  attr_accessor :base_url, :chart_type, :options

  def to_s
    @base_url +  "?" + "cht=" + @chart_type + "&" + options_to_s
  end
  
  private
  def options_to_s
    opt = @options.to_a
    opt = opt.map do |o|
      if o[1].is_a?(Array)
        o = o[0].to_s + "=" + o[1].join(",")
      else #works for Strings, Symbols and ChartValues
        o = o[0].to_s + "=" + o[1].to_s
      end
    end
    opt.join "&"
  end
end

#A chart value is a nested array which with proper chart delimiter for gcharts
class ChartValue
  def initialize(values)
    # shuffled = Array.new(values[0].length)
    # shuffled.map! {|a| a = Array.new(values.length)}
    # shuffled.each_with_index do |element, outer_index|
    #   element.each_with_index do |inner_element, inner_index|
    #      shuffled[outer_index][inner_index] = values[inner_index][outer_index]
    #    end
    # end
    # @values = shuffled
    @values = values
  end
      
  def to_s
    @values.map{|a| a = a.join ","}.join "|"
  end
end

##random utilities
def round_to(val, x)
  (val * 10**x).round.to_f / 10**x
end