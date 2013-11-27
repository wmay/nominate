class Wnominate
  def initialize()
    @legislators = {}
    @rollcalls = []
    # party is 'unknown' by default
    @parties = Hash.new('unknown')
    # variable for assigning each legislator a number, used for DW-NOMINATE
    @x = 1
  end
  attr_accessor :parties
  attr_accessor :prefix
  def add_rollcall(rollcall_hash)
    @rollcalls.push rollcall_hash
    rollcall_hash.each_key do |name|
      if not @legislators.has_key? name
        @legislators[name] = @x
        @x += 1
      end
    end
  end
  def wnominate(file_prefix = 'wnom_')
    Dir.mkdir('nominate') unless Dir.exist?('nominate')
    Dir.chdir('nominate')
    @prefix = file_prefix
    self.write_wnom(@legislators, @rollcalls, @parties)
    path = File.expand_path(File.dirname(__FILE__))
    was_good = system 'Rscript ' + path + '/nominate.R'
    if was_good != true
      puts ''
      puts 'Something went wrong.'
      puts 'If you have not installed R, please install R and try again.'
      exit
    else
      files = ['votes.csv', 'legislators.csv', 'rollcalls.csv',
               'dimensions.csv', 'eigenvalues.csv', 'beta.csv', 'weights.csv',
               'fits.csv', 'Rplots.pdf']
      files.each { |file| File.rename(file, file_prefix + file) }
    end
    Dir.chdir('..')
  end
  def write_wnom(legislators, rollcalls, parties)
    final = []
    # write output in format 'Bob Smith|party|Y|Y|N|Y|N|N|...'
    legislators.each_key do |leg|
      line = leg + '|' + parties[leg]
      rollcalls.each { |hash| line << '|' + hash[leg] }
      final.push line
    end
    File.open('votes.csv', 'w') { |f1| f1.puts final }
  end
end
