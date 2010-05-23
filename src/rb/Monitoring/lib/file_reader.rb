module FileReader
  #get table view
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
  def get_stat(uid)
    list = self.get_stats
    list.each do |table| 
      return table if table.id == uid
    end
    return nil
  end
  
  #method args: get_stats(filename, object name 'Table' or 'RangeServer'[, wait_time])
  def get_stats(object_type=nil, filename=nil, wait_time=2)
    list = []
    path_to_file = "../../../run/monitoring/"
    orig_file_name = filename || "table_stats.txt"
    copy_file_name = "copy_of_#{orig_file_name}"
     
    #copy table stats "#{app_root}/run/monitoring/table_stats.txt" 
    # repeats the copy for some given time.
    time_spent = 0
    start_time = Time.now
    elapsed_time = Time.now
    begin
        elapsed_time = Time.now
        File.copy("#{path_to_file}#{orig_file_name}", "#{path_to_file}#{copy_file_name}")
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
      file = File.open("#{path_to_file}#{copy_file_name}", "r")
      current_table = (object_type == "Table") ? Table.new : RangeServer.new
      file.each do |line|
        #start parsing...
        if line =~ /^(#{object_type}) = (.+)/
          current_table = (object_type == "Table") ? Table.new($2) : RangeServer.new($2)
          list.push current_table
        elsif line =~ /^\t(.+)=(.+)/
          key = :"#{$1}"
          values = $2.split(",").map! { |v| v.to_i } #data can be floats
          # values = $2.split(",") #data can be floats
          if key == :Timestamps
            current_table.timestamps = values
          else
            current_table.data[key] = values
          end
        end
      end
      #todo: file doesn't appear to be reloaded if modifed externally
      file.close
      File.delete("#{path_to_file}#{copy_file_name}")
    rescue
      raise
    end    
    # return the array of list populated with data.
    return list
  end
  
  
  #todo: this doesn't handle tables with less than 3 indeces of values...
  def sort(list, sort_type, data_type, interval_index)
    sorted = list.sort { |x, y|       
      if sort_type == "name"
        x.id <=> y.id
      elsif sort_type == "data"
        y.data[:"#{data_type}"][interval_index] <=> x.data[:"#{data_type}"][interval_index]
        #todo: ommit table if no value for given index? or flag it somehow? 0
      end
    } 
    sorted
  end

  #todo: doesn't handle if interval_index is there. (it pushes nil)
  def get_all_data(list, data_type, interval_index)
    data = []
    list.each do |table|
      #todo: if data doesn't exist for the selected index, push a nil value or -1? No. All values will be present
      data.push table.data[:"#{data_type}"][interval_index]
    end
    data
  end
  
  def get_all_names(list)
    names = list.map {|t| t.id }
  end
  
end
