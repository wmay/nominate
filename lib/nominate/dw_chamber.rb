class DWChamber
  def initialize
    @sessions = []
  end

  def add_session(session)
    @sessions.push session
  end

  def sessions
    @sessions
  end

  def dwnominate
    path = File.expand_path(File.dirname(__FILE__))
    self.dw_check(path)
    Dir.mkdir('nominate') unless Dir.exist?('nominate')
    Dir.chdir('nominate')
    self.check_ws(@sessions)
    self.write_dw(@sessions)
    system path + '/dw-nominate'
    Dir.chdir('..')
  end

  def dw_check(path)
    # compile DW-NOMINATE if needed
    entries = Dir.entries(path)
    if not entries.include?('dw-nominate')
      puts 'You have not compiled DW-NOMINATE on this computer.'
      puts 'DW-NOMINATE must be compiled to run.'
      puts 'Would you like to compile DW-NOMINATE? (y/n)'
      puts '(Requires sudo privileges.)'
      answer = gets.chomp.downcase
      if answer == 'y'
        Dir.chdir(path) do
          system 'sudo gfortran ' + path + '/DW-NOMINATE.FOR -w -o ' +
                    path + '/dw-nominate'
          entries = Dir.entries(path)
          if not entries.include?('dw-nominate')
            puts 'Compiling failed.'
            exit
          else
            puts ''
            puts 'Code compiled successfully.'
          end
        end
      else
        exit
      end
    end
  end

  def check_ws(sessions)
    sessions.each_with_index do |session, i|
      if session.prefix == nil
        session.prefix = 'session_' + (i+1).to_s + '_'
        self.check_for_session(session)
      else
        self.check_for_session(session)
      end
    end
  end

  def check_for_session(session)
    if not Dir.entries(Dir.pwd).include?(session.prefix + 'legislators.csv')
      Dir.chdir('..')
      session.wnominate(session.prefix)
      Dir.chdir('nominate')
    end
  end

  def write_dw(sessions)
    # write_vote_matrix()
    # write_transposed_vote_matrix()
    
    # 1) Rollcall data file

    # setting variables
    leg_session = 1
    legs = {}
    legNum = 1
    stateNum = "  1"
    district = " 0"
    stName = " VERMONT"
    parties = {}
    party = 1
    votes = { "Y" => "1", "N" => "6", 'M' => '9' }
    final = []

    # processing
    sessions.each do |session|
      lines = IO.readlines(session.prefix + 'votes.csv')
      lines.each_with_index do |line, i|
        data = line.gsub("||", "| |").gsub("||", "| |").gsub("|\n", "| ").chomp.split("|")
        legName = data[0]
        legParty = data[1]
        # making legislator IDs
        if legs[legName] == nil
          legs[legName] = " "*(6-legNum.to_s.length) + legNum.to_s
          legNum += 1
        end
        # making party IDs
        if parties[legParty] == nil
          parties[legParty] = " "*(5-party.to_s.length) + party.to_s
          party += 1
        end
        # converting votes to a numeric string
        voteNums = ' '
        data[2..-1].each do |vote|
          begin
            voteNums += votes[vote]
          rescue
            puts "Unrecognized vote: " + vote + ", from " + legName + ", " +
              session + " " + legParty
          end
        end
        shortName = legName.gsub(/[^A-Za-z -]/, '')[0..9] + " "*(10-legName.gsub(/[^A-Za-z -]/, '')[0..9].length)
        if shortName.delete(' ') == ''
          puts 'Blank legislator name-'
          puts "Line #{(i+1).to_s}, '#{session.prefix}votes.csv'"
          puts 'Legislators must have non-blank names to be included.'
          puts ''
          next
        end
        final.push sprintf("%4d", leg_session) + legs[legName] + stateNum +
          district + stName + parties[legParty] + " " + shortName + voteNums
      end
      leg_session += 1
    end
    File.open("H1993-2013_1ST.VT3", 'w') { |f1| f1.puts final }


    # 2) Transposed rollcall data file

    sessionNums = []
    lines = IO.readlines("H1993-2013_1ST.VT3")

    lines.each do |line|
      if not sessionNums.include? line[0..3]
        sessionNums.push line[0..3]
      end
    end

    final = []

    sessionDatas = []
    sessionNums.each do |session|
      sessionData = []
      lines.each do |line|
        if line[0..3] == session
          sessionData.push line[40..-1].chomp
        end
      end
      sessionDatas.push sessionData
    end

    y = 0
    sessionDatas.each do |sessionData|
      x = 0
      sessionData[0].each_char do |bill|
        votes = ' '
        sessionData.each do |legVotes|
          begin
            votes += legVotes[x]
          rescue
            puts "Session #{(y+1).to_s} , vote # #{(x+1).to_s}"
            exit
          end
        end
        final.push sessionNums[y] + " "*(5-(x+1).to_s.length) + (x+1).to_s + votes
        x += 1
      end
      y += 1
    end


    File.open("HT1993-2013_1ST.VT3", 'w') do |f1|
      final.each do |line|
        f1.puts line
      end
    end


    # 3) Legislator data file

    final = []
    final2 = []

    legSession = 1
    xpositives = []
    ypositives = []
    sessions.each_with_index do |session, i|
      flipx = false
      flipy = false

      # Leg file

      sessionNum = " "*(4-legSession.to_s.length) + legSession.to_s
      lines = IO.readlines(session.prefix + "legislators.csv")
      lines.delete_at(0)

      # deciding whether to flip numbers
      xs = []
      ys = []
      if i != 0
        lines.each do |line|
          data = line.split("|")
          name = data[0]
          xs.push data[8] if xpositives.include? name
          ys.push data[9] if ypositives.include? name
        end
        flipx = true if average(xs, i) < 0
        flipy = true if average(ys, i) < 0
      end

      # writing the legislator file lines
      lines.each_with_index do |line, i|
        data = line.split("|")
        name = data[0]
        shortName = name.gsub(/[^A-Za-z -]/, '')[0..9] +
          " "*(10-name.gsub(/[^A-Za-z -]/, '')[0..9].length)

        if shortName.delete(' ') == ''
          puts 'Vote is missing a name-'
          puts "Line #{(i+1).to_s}, '#{session.prefix}legislators.csv'"
          puts 'This vote will not be included.'
          puts ''
          next
        end

        # flipping numbers to orient each session in the same direction
        xnum = data[8]
        xnum = (-(xnum.to_f)).to_s if flipx
        ynum = data[9]
        ynum = (-(ynum.to_f)).to_s if flipy

        if data[2] == 'NA' or data[3] == 'NA' or
            data[4] == 'NA' or data[5] == 'NA'
          numVotes = '    0'
          numErrors = '    0'
        else
          voteTotal = data[2].to_i + data[3].to_i + data[4].to_i + data[5].to_i
          numVotes = " "*(5-voteTotal.to_s.length) + voteTotal.to_s
          errorTotal = data[3].to_i + data[4].to_i
          numErrors = " "*(5-errorTotal.to_s.length) + errorTotal.to_s
        end
        begin
          final.push sessionNum + legs[data[0]] + stateNum + district + stName +
            parties[data[1]] + " " + shortName + " " + dw_format(xnum) +
            dw_format(ynum) +
            "  0.000  0.000  0.000  0.000     0.00000     0.00000" +
            numVotes*2 + numErrors*2 + dw_format(data[6])*2
        rescue
          puts "Error:"
          puts sessionNum
          puts data[0]
          puts legs[data[0]]
          puts parties[data[1]]
          puts format(data[8])
          puts format(data[9])
          puts numVotes*2
          puts numErrors*2
          puts format(data[6])*2
        end
      end

      xpositives = []
      ypositives = []
      lines.each do |line|
        data = line.split('|')
        # keep track of legislator scores, to decide whether to flip numbers
        # for the next session
        xpositives.push data[0] if data[8].to_f > 0
        ypositives.push data[0] if data[9].to_f > 0
      end

      # Bill file

      sessionNum = " "*(4-legSession.to_s.length) + legSession.to_s
      lines2 = IO.readlines(session.prefix + "rollcalls.csv")
      lines2.delete_at(0)
      lines2.each do |line|
        data = line.split("|")
        billNum = " "*(5-data[0].length) + data[0]
        billx = data[8]
        billx = (-(billx.to_f)).to_s if flipx
        billy = data[10].chomp
        billy = (-(billy.to_f)).to_s if flipy
        
        final2.push sessionNum[1..3] + billNum + dw_format(data[7]) +
          dw_format(data[9]) + dw_format(billx) + dw_format(billy)
      end

      legSession += 1
    end

    File.open('dw_legislator_input.dat', 'w') do |f1|
      final.each do |line|
        f1.puts line
      end
    end

    File.open("dw_rollcall_input.dat", 'w') do |f1|
      final2.each do |line|
        f1.puts line
      end
    end


    # 5) Session data file

    final = []
    legSession = 1
    sessions.each do |session|
      sessionNum = " "*(3-legSession.to_s.length) + legSession.to_s
      lines = IO.readlines(session.prefix + "rollcalls.csv")
      rollcalls = " "*(5-(lines.length-1).to_s.length) + (lines.length-1).to_s
      lines = IO.readlines(session.prefix + "legislators.csv")
      legislators = " "*(4-(lines.length-1).to_s.length) + (lines.length-1).to_s
      final.push sessionNum + rollcalls + legislators
      legSession += 1
    end

    File.open("NHOUSE_2013.NUM", 'w') do |f1|
      final.each do |line|
        f1.puts line
      end
    end


    # 6) DW-NOMSTART.DAT file

    File.open('DW-NOMSTART.DAT', 'w') do |f1|
      f1.puts 'dw_rollcall_input.dat'
      f1.puts 'dw_rollcall_output.dat'
      f1.puts 'dw_legislator_input.dat'
      f1.puts 'dw_legislator_output.dat'
      f1.puts 'NHOUSE_2013.NUM'
      f1.puts 'H1993-2013_1ST.VT3'
      f1.puts 'HT1993-2013_1ST.VT3'
      f1.puts 'NOMINAL DYNAMIC-WEIGHTED MULTIDIMENSIONAL UNFOLDING '
      num_of_sessions = sessions.length.to_s
      number_text = ' '*(5 - num_of_sessions.length) + num_of_sessions
      f1.puts '    2    1    1' + number_text + '    2    5'
      f1.puts '  5.9539  0.3463'
    end


    puts ''
    puts "File formatting done."
    puts ''
    puts ''

  end

end




def dw_format(num)
  if num[0] == '-'
    return " " + num.to_f.round(3).to_s + "0"*(6-num.to_f.round(3).to_s.length)
  elsif num == 'NA'
    return dw_format('0')
  else
    return "  " + num.to_f.round(3).to_s + "0"*(5-num.to_f.round(3).to_s.length)
  end
end

def average(numbers, si)
  if numbers.length == 0
    puts 'No legislator names matched those of the previous session.'
    puts 'You will not be able to run DW-NOMINATE on these two sessions.'
    puts 'Put names from both sessions in the same format to correct the issue.'
    puts "Sessions #{si.to_s} and #{(si+1).to_s}."
    exit
  end
  sum = 0
  numbers.each { |n| sum = sum + n.to_f }
  sum / numbers.length
end
