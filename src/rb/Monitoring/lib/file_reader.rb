module FileReader
  TIME_INTERVALS = [1, 5, 10]
  UNIT = {
      :kbps => "KBps", 
      :rwps => "Reads and Writes per second", 
      :bytes => "Bytes", 
      :kb => "KB", 
      :loadave => "measure of waiting proc in proc queue",
      :abs => "absolute numbers",
      :ab => "absolute number",
      :percent => "%",
      :mhz => "Mhz"
    }
    
    CHART_A_OPTIONS = {:padding => 95, :legend_height => 8, :bar_width_or_scale => 10, :space_between_bars => 2, :space_between_groups => 4}
    CHART_B_OPTIONS = {:padding => 95, :legend_height => 8, :bar_width_or_scale => 10, :space_between_bars => 2, :space_between_groups => 4}
    CHART_C_OPTIONS = {:padding => 95, :legend_height => 8, :bar_width_or_scale => 10, :space_between_bars => 2, :space_between_groups => 4}
    
  #get stat view
  def get_system_totals
    list = self.get_stats
    data = {}  
    list.each do |t|
      t.data.each do |key, value|
        data[key] = Array.new(value.length) unless data[key]
        value.each_with_index do |v, i|
          data[key][i] = data[key][i].to_f + v unless (v == nil || v == -1)
        end
      end
    end
    # data = data.sort { |a, b| a.to_s <=> b.to_s }
    [list.first.timestamps, data]
  end

  # find just one. this could be optimized
  def get_stat uid
    list = self.get_stats
    list.each do |item| 
      return item if item.id == uid
    end
    return nil
  end
  
  def get_stats(wait_time=2)
    list = []

    # repeats the copy for some given time.
    time_spent = 0
    start_time = Time.now
    elapsed_time = Time.now
    begin
        elapsed_time = Time.now
        File.copy("#{self::PATH_TO_FILE}#{self::ORIGINAL_FILE_NAME}", "#{self::PATH_TO_FILE}#{self::COPY_FILE_NAME}")
    rescue => err
      time_spent = elapsed_time - start_time
      if time_spent <= wait_time
        retry
      else
        raise
      end
    end

    begin
      #parse copied file here
      file = File.open("#{self::PATH_TO_FILE}#{self::COPY_FILE_NAME}", "r")
      current_stat = self.new
      file.each do |line|
        #start parsing...
        if line =~ /^(#{self.name.to_s}) = (.+)/
          current_stat = self.new($2)
          list.push current_stat
        elsif line =~ /^\t(.+)=(.+)/
          key = :"#{$1}"
          values = $2.split(",").map! do |v|
            if v =~ /\./
              v.to_f  #data can be floats
            else
              v.to_i
            end
          end
          
          # values = $2.split(",") #data can be floats
          if key == :Timestamps
            current_stat.timestamps = values
          else
            current_stat.data[key] = values
          end
        end
      end
      file.close
      File.delete("#{self::PATH_TO_FILE}#{self::COPY_FILE_NAME}")
    rescue
      raise
    end    
    # return the array of list populated with data.
    return list
  end

  def sort(chart_key, list, sort_type, selected_stat, interval_index)
    data_type = selected_stat.to_sym
    puts data_type
    sorted = list.sort { |x, y|       
      if sort_type == "name"
        x.id <=> y.id
      elsif sort_type == "data"        
        case chart_key[:type]

        when :A
          a = y.data[chart_key[:stats][0]][interval_index]
          b = y.data[chart_key[:stats][1]][interval_index]
          
          c = x.data[chart_key[:stats][0]][interval_index]
          d = x.data[chart_key[:stats][1]][interval_index]
          #todo: handle divide by zero? doesn't blow up with 

          # special case for :disk_available
          if data_type == :disk_used
            (b - a)/(b * 1.0) <=> (d - c)/(d * 1.0)
          else
            a/(b * 1.0) <=> c/(d * 1.0)
          end

        when :B
          y.data[data_type][interval_index] <=> x.data[data_type][interval_index]
        when :C
          data_type = chart_key[:stats][0]
          y.data[data_type][interval_index] <=> x.data[data_type][interval_index]
        end
      end
    } 
    # pp sorted.map{|s| s.data[data_type]}, chart_key[:type], chart_key, sort_type, data_type, interval_index
    sorted
  end

  #todo: doesn't handle if interval_index is there. (it pushes nil)
  def get_all_stats(list, data_type, interval_index)
    data = []
    list.each do |item|
      #todo: if data doesn't exist for the selected index, push a nil value or -1? No. All values will be present
      data.push item.data[:"#{data_type}"][interval_index]
    end
    data
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
