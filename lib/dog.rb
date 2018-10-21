class Dog
    attr_accessor :name, :breed, :id
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
      SQL
      DB[:conn].execute(sql)  
    end

    def self.drop_table
        sql =  <<-SQL 
      DROP TABLE IF EXISTS dogs 
      SQL
      DB[:conn].execute(sql) 
    end

    def save
        if self.id
        self.update
        else
        sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def self.create(hash)
      dog = Dog.new(hash)
      dog.save
      dog
    end

    def self.find_by_id(id)
      sql = <<-SQL
       SELECT * FROM dogs WHERE id = ?
      SQL
      result = DB[:conn].execute(sql, id)[0]
      Dog.new({id: result[0], name: result[1], breed: result[2]})    
    end

    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
      dog = self.create(name: name, breed: breed)
      end
      dog
    end

    def self.new_from_db(array)
      self.new(id: array[0], name: array[1], breed: array[2])
    end

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? 
      SQL
 
      array = DB[:conn].execute(sql, name)
      self.new_from_db(array[0])
    end

    def update
      sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? 
      WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end