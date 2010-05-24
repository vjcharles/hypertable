module FileReader
  TIME_INTERVALS = [1, 5, 10]
  #get stat view
  def get_system_totals
    list = self.get_stats
    data = {}  
    list.each do |t|
      t.data.each do |key, value|
        data[key] = Array.new(value.length) unless data[key]
        value.each_with_index do |v, i|
          data[key][i] = data[key][i].to_i + v unless (v == nil || v == -1)
        end
      end
    end
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
          values = $2.split(",").map! { |v| v.to_i } #data can be floats
          # values = $2.split(",") #data can be floats
          if key == :Timestamps
            current_stat.timestamps = values
          else
            current_stat.data[key] = values
          end
        end
      end
      #todo: file doesn't appear to be reloaded if modifed externally
      file.close
      File.delete("#{self::PATH_TO_FILE}#{self::COPY_FILE_NAME}")
    rescue
      raise
    end    
    # return the array of list populated with data.
    return list
  end
  
  
  #todo: this doesn't handle stats with less than 3 indeces of values...
  def sort(list, sort_type, data_type, interval_index)
    sorted = list.sort { |x, y|       
      if sort_type == "name"
        x.id <=> y.id
      elsif sort_type == "data"
        y.data[:"#{data_type}"][interval_index] <=> x.data[:"#{data_type}"][interval_index]
        #todo: ommit stat if no value for given index? or flag it somehow? 0
      end
    } 
    sorted
  end

  #todo: doesn't handle if interval_index is there. (it pushes nil)
  def get_all_data(list, data_type, interval_index)
    data = []
    list.each do |item|
      #todo: if data doesn't exist for the selected index, push a nil value or -1? No. All values will be present
      data.push item.data[:"#{data_type}"][interval_index]
    end
    data
  end
  
  def get_all_names(list)
    names = list.map {|t| t.id }
  end
  
end
