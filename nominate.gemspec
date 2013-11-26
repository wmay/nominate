Gem::Specification.new do |s|
  s.name        = 'nominate'
  s.version     = '0.0.0'
  s.date        = '2013-11-26'
  s.summary     = "Run W- and DW-NOMINATE from Ruby"
  s.description = <<EOF
    An interface to the W- and DW-NOMINATE political scaling programs, written
    by Keith Poole, Howard Rosenthal, and others. Map legislators along the
    political spectrum using their rollcall votes."
EOF
  s.author      = 'Will May'
  s.email       = 'williamcmay@live.com'
  s.files       = ['lib/nominate.rb', 'lib/nominate/fixer.rb',
                   'lib/nominate/DW-NOMINATE.FOR', 'lib/nominate/nominate.R']
  s.homepage    = ''
  s.license     = 'MIT'
  s.requirements << 'the R statistical programming language'
  s.requirements << 'GFortran'
  s.requirements << 'Linux'
end
