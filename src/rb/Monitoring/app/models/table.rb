# non-activerecord backed model
class Table
  require 'pp'
  require 'ftools'
  def initialize (id=nil)
    @table_id = id
    @data = {}
  end
  
  attr_accessor :table_id, 
                :timestamps, 
                :data #data is a hash containing current stats collected.                
                  # :scans, 
                  # :cells_read, 
                  # :bytes_read, 
                  # :cells_written, 
                  # :bytes_written,
                  # :bloom_filter_accesses,
                  # :bloom_filter_maybes,
                  # :bloom_filter_false_positives,
                  # :bloom_filter_memory,
                  # :block_index_memory,
                  # :shadow_cache_memory,
                  # :memory_used,
                  # :memory_allocated,
                  # :disk_used

  #return table data
  def self.get_stats
    #todo: need path variable, verify time to wait for file to appear. 2 seconds is many lifetimes.
    tables = []
    path_to_file = "../../../run/monitoring/"
    orig_file_name = "table_stats.txt"
    copy_file_name = "copy_of_table_stats.txt"
    seconds_to_wait = 2
    
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
      if time_spent <= seconds_to_wait
        retry
      else
        raise
      end
    end

    begin
      #parse copied file here
      file = File.open("#{path_to_file}#{copy_file_name}", "r")
      current_table = Table.new
      file.each do |line|
        #start parsing...
        if line =~ /^(Table) = (.+)/
          current_table = Table.new($2)
          tables.push current_table
        elsif line =~ /^\t(.+)=(.+)/
          key = :"#{$1}"
          values = $2.split(",").map! { |v| v.to_i } #all data should be integers
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
    
    # return the array of tables populated with data.
    # pp(tables)
    return tables
  end
  
  #todo: this doesn't handle tables with less than 3 indeces of values...
  def self.sort(tables, sort_by, interval_index)
    sorted = tables.sort { |x, y|       
      if sort_by == "name"
        x.table_id <=> y.table_id
      elsif sort_by == "reverse_date"
        y.timestamps <=> x.timestamps
      else
        if x.timestamps.length > interval_index.to_i and y.timestamps.length > interval_index.to_i
          x.data[:"#{sort_by}"][interval_index] <=> y.data[:"#{sort_by}"][interval_index]  
        else
          #todo: ommit table if no value for given index? or flag it somehow?
          0
        end
      end
   } 
   sorted
  end

  #todo: doesn't handle if interval_index is there. (it pushes nil)
  def self.get_all_data(tables, data_type, interval_index)
    data = []
    tables.each do |table|
      if data_type == "name" || data_type == "reverse_date"
        data.push table.data[:bytes_read][interval_index]
      else
        data.push table.data[:"#{data_type}"][interval_index]
      end
    end
    data
  end
  
  def self.get_all_names(tables)
    names = tables.map {|t| t.table_id }
  end
  
  def get_data_names
    return [] unless self.data != {}
    names = self.data.keys.map {|k| k.to_s }
  end

end