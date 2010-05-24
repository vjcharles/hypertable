class Table
  # require 'pp'
  # require 'ftools'
  extend FileReader
  
  PATH_TO_FILE = "../../../run/monitoring/"
  ORIGINAL_FILE_NAME = "table_stats.txt"
  COPY_FILE_NAME = "copy_of_#{@orig_file_name}"
  
  def initialize (id=nil)
    @id = id
    @data = {}
  end
  
  attr_accessor :id, 
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

  def get_data_names
    return [] unless self.data != {}
    names = self.data.keys.map {|k| k.to_s }
  end
  
  #todo: temp until we have a real table name
  alias name id
  
end

