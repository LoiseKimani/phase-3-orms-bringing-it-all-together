class Dog
    attr_accessor :id, :name, :breed
    
    def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
    end
    
    def self.create_table
      DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end
    
    def self.drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end
    
    def save
      if self.id
        self.update
      else
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end
    
    def self.create(name:, breed:)
      dog = self.new(name: name, breed: breed)
      dog.save
    end
    
    def self.new_from_db(row)
      self.new(id: row[0], name: row[1], breed: row[2])
    end
    
    def self.all
      DB[:conn].execute("SELECT * FROM dogs").map do |row|
        self.new_from_db(row)
      end
    end
    
    def self.find_by_name(name)
      DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map do |row|
        self.new_from_db(row)
      end.first
    end
    
    def self.find(id)
      DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).map do |row|
        self.new_from_db(row)
      end.first
    end
    
    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      
      if !dog.empty?
        dog_data = dog[0]
        self.new_from_db(dog_data)
      else
        self.create(name: name, breed: breed)
      end
    end
    
    def update
      DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
end
  
