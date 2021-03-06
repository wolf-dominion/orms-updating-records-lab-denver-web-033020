require_relative "../config/environment.rb"
require 'pp'
class Student
  attr_accessor :name, :grade, :id
  # wrong- attr_reader :id

  def initialize(id=nil, name, grade) # I originally had id as the last argument
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table # I originally put grade as an int
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY, 
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  # def self.create(name:, grade:)
  #   new_student = self.new(name, grade)
  #   new_student.save
  #   new_student
  # end

  #Why do we not use symbols for this one? Why isn't student returned? Both questions stem
  #from looking at examples in the lessons/readings
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    # sql = <<-SQL
    #   SELECT * FROM students 
    #   WHERE id = ?
    #   UPDATE name or grade
    # SQL
    # DB[:conn].execute(sql, name, grade)

      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
