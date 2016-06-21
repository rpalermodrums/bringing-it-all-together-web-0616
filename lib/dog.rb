class Dog
  attr_accessor :id, :name, :breed

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def initialize(hash, id = nil)
    @id = id
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
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
      self
    end
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(i)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, i).first
    self.new_from_db(row)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, hash[:name], hash[:breed]).first
    # binding.pry
    if !dog.nil?
      self.new_from_db(dog)
    else
      Dog.create(hash)
    end
  end

  def self.new_from_db(row)
    dog = Dog.new({name: row[1], breed: row[2]}, row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL

    dog = DB[:conn].execute(sql, name).first
    self.new_from_db(dog)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
