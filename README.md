nominate
========

The 'nominate' gem, to run W- and DW-NOMINATE from Ruby

I recommend using the [`dwnominate` package for R](https://github.com/wmay/dwnominate) instead of this gem. It should be more convenient in most cases.

W-NOMINATE uses rollcall votes to map legislators along a political spectrum. In American state and federal elections, it typically finds the traditional left-right spectrum. DW-NOMINATE uses legislators who have served in multiple legislative sessions to compare sessions and track changes through time.

Installation: <code>sudo gem install nominate</code>


Requirements
------------

* Linux
* R  
In Ubuntu: <code>sudo apt-get install r-base r-base-dev</code>
* GFortran (only for DW-NOMINATE)  
In Ubuntu: <code>sudo apt-get install gfortran</code>


Example
-------

Let's say you have a file of voting data in the format

> name1|party1|rollcall1 info|vote1  
> name2|party2|rollcall1 info|vote2  
> ...  
> name1|party1|rollcall2 info|vote1  
> name2|party2|rollcall2 info|vote2  
> ...

which is similar to what you can download from the
<a href="http://www.gencourt.state.nh.us/downloads/">New Hampshire state legislature</a>.
And these are collected in file '1999NHrollcalls.csv' and so forth.

The following code will read the rollcall data into Wnominate objects, and add the sessions to a Dwnominate object.
<code>chamber.dwnominate</code> starts the nominate process, first calling <code>wnominate</code> on each Wnominate object, then using the results to write the input files for the DW-NOMINATE program, and then running DW-NOMINATE. All results, including output graphs from the R wnominate package, will be written to a folder called 'nominate'.

An alternative is to call <code>wnominate(prefix)</code> on Wnominate objects, which will run only the W-NOMINATE program, adding the specified prefix to each output file.



<pre>
require 'nominate'

chamber = Dwnominate.new

# votes other than Yes or No are counted as missing ('M')
vote_key = Hash.new('M')
vote_key['Yes'] = 'Y'
vote_key['No'] = 'N'
# Wnominate object only accepts 'Y', 'N', and 'M' votes

['1999', '2001', '2003', '2005', '2007'].each do |year|
  file = year + 'NHrollcalls.csv'
  lines = IO.readlines(file)
  session = Wnominate.new
  # default party is 'unknown'
  parties = Hash.new('unknown')
  old_issue = 0
  # default vote is 'M' for 'missing'
  rollcall = Hash.new('M')
  lines.each_with_index do |line, i|
    data = line.split('|')
    name = data[0]
    party = data[1]
    issue = data[2]
    vote = vote_key[data[3].chomp]
    # every time we get to a new rollcall, add the hash with the old rollcall's votes to the
    # Wnominate object, and start a new rollcall hash.
    if issue != old_issue
      session.add_rollcall(rollcall) unless i == 0
      rollcall = Hash.new('M')
      old_issue = issue
    end
    rollcall[name] = vote
    parties[name] = party if not parties.has_key?(name)
    # get the last rollcall when you reach the end of the file
    session.add_rollcall(rollcall) if i == lines.length - 1
  end
  # add a hash of legislator names and parties if you want party info to be included
  session.parties = parties
  chamber.add_session(session)
end

chamber.dwnominate(prefix = 'dw_')
</pre>


More Resources
--------------

* <a href="http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=4&cad=rja&ved=0CEoQFjAD&url=http%3A%2F%2Fwww.jstatsoft.org%2Fv42%2Fi14%2Fpaper&ei=EEaVUt2uJMnMsQStm4KwDA&usg=AFQjCNHZsPQw1NuuNqjmdgrTocQpcNgW2g&sig2=wyMhSL38AaMsDxYpwKm4yA&bvm=bv.57155469,d.cWc">Scaling Roll Call Votes with W-NOMINATE in R</a>
* <a href="http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0CCwQFjAA&url=http%3A%2F%2Fcran.r-project.org%2Fweb%2Fpackages%2Fwnominate%2Fwnominate.pdf&ei=EEaVUt2uJMnMsQStm4KwDA&usg=AFQjCNHmCcBCSbfZkZ8WQRlKsnVxOGSM9g&sig2=zRs0PR_OwBttMm4MBA6NDQ&bvm=bv.57155469,d.cWc&cad=rja">R wnominate package documentation</a>
* <a href="http://voteview.com/dwnominate.asp">DW-NOMINATE at voteview.com</a> (with an explanation of the output format)
* *Spatial Models of Parliamentary Voting*, by Keith Poole, an in-depth explanation of the programs
* *Ideology and Congress*, by Keith Poole and Howard Rosenthal
