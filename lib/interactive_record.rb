require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name #this gets the table name so we can use this to dynamically access the database (to get column names)
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    array = DB[:conn].execute(sql)
    coulmn_name = []
    array.each do |column|
      coulmn_name << column["name"]
    end
    coulmn_name.compact
  end

  def self.find_by(attributes)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attributes.keys[0]} = '#{attributes.values[0]}'"
    
    DB[:conn].execute(sql)
  end

   def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    sql = "SELECT last_insert_rowid() FROM #{table_name_for_insert}"
    results = DB[:conn].execute(sql)

    self.id=(results[0][0])

  end

  def values_for_insert
    column_array = self.class.column_names
    column_array.delete_if {|value| value == "id"}
    values = []
    column_array.each do |column_title|
     values << "'#{self.send(column_title)}'"
   end
   values.join(", ")
    
  end

  def col_names_for_insert
   self.class.column_names.delete_if {|value| value == "id"}.join(", ")

  end



end