require 'sqlite3'
class Dog
  attr_accessor :name, :breed, :id

def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
end

def self.create_table
    DB[:conn].execute('CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)')
end

def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
end

def save
    if @id
      update
else
      DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?, ?)', name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
end
    self
end

def update
    DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?', name, breed, id)
end

def self.create(name:, breed:)
    Dog.new(name: name, breed: breed).save
end

def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
end

def self.all
    DB[:conn].execute('SELECT * FROM dogs').map { |row| new_from_db(row) }
end

def self.find_by_name(name)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? LIMIT 1', name).first
    new_from_db(row) if row
end

def self.find(id)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE id = ? LIMIT 1', id).first
    new_from_db(row) if row
  end
end

