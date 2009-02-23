spec = Gem::Specification.new do |s|
  s.name = 'decisiontree'
  s.version = '0.3.0'
  s.date = '2009-02-21'
  s.summary = 'ID3-based implementation of the M.L. Decision Tree algorithm'
  s.description = s.summary
  s.email = 'ilya@igvita.com'
  s.homepage = "http://github.com/igrigorik/decisiontree"
  s.has_rdoc = true
  s.authors = ["Ilya Grigorik"]
 
  # ruby -rpp -e' pp `git ls-files`.split("\n") '
  s.files = ["README.rdoc",
    "examples/continuous-id3.rb",
    "examples/data/continuous-test.txt",
    "examples/data/continuous-training.txt",
    "examples/data/discrete-test.txt",
    "examples/data/discrete-training.txt",
    "examples/discrete-id3.rb",
    "examples/simple.rb",
    "lib/decisiontree.rb",
		"lib/id3_tree.rb",
    "test/test_decisiontree.rb"]

end
