# non-activerecord backed model
class Table
  require 'pp'
  require 'ftools'
  def initialize (id=nil)
    @id = id
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
      #todo: file not deleted. necessary?
      
    rescue
      raise
    end
    
    # return the array of tables populated with data.
    # pp(tables)
    return tables
  end
    
end