class Object
  def save_to_file(filename)
    File.open(filename, 'w+') { |f| f << Marshal.dump(self) }
  end

  def self.load_from_file(filename)
    Marshal.load(File.read(filename))
  end
end
