class Table
  # require 'pp'
  # require 'ftools'
  extend FileReader
  
  PATH_TO_FILE = "../../../run/monitoring/"
  ORIGINAL_FILE_NAME = "table_stats.txt"
  COPY_FILE_NAME = "copy_of_#{@orig_file_name}"
  
  cells_read = {:type => :B, :stats => [:cells_read, :cells_written]}
  bloom_filter_accesses = {:type => :B, :stats => [:bloom_filter_accesses, :bloom_filter_maybes]}
  bloom_filter_memory = {:type => :B, :stats => [:bloom_filter_memory, :block_index_memory, :shadow_cache_memory]}
  #data structure to determine graph types, and what graphs to display.
  STATS_KEY = {
    :memory_used => {:type => :A, :stats => [:memory_used, :memory_allocated]},
    
    :cells_read => cells_read,
    :cells_written => cells_read,
    :bloom_filter_accesses => bloom_filter_accesses,
    :bloom_filter_maybes => bloom_filter_accesses,
    
    :bloom_filter_memory => bloom_filter_memory,
    :block_index_memory => bloom_filter_memory,
    :shadow_cache_memory => bloom_filter_memory,

    #todo: stats is redundant for type C graphs...
    :scans => {:type => :C, :stats => [:scans]},
    :bloom_filter_false_positives => {:type => :C, :stats => [:bloom_filter_false_positives]},
    :disk_used => {:type => :C, :stats => [:disk_used]}
    
  }

  def self.get_data_types
    STATS_KEY.keys.sort {|a,b| a.to_s <=> b.to_s}.map {|d| d.to_s}
  end
  
  def self.get_chart_type stat
    stat = stat.to_sym
    STATS_KEY[stat]
  end
  
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

