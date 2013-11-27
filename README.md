nominate
========

The 'nominate' gem, to run W- and DW-NOMINATE from Ruby

W-NOMINATE uses rollcall votes to map legislators along a political spectrum. In American state and federal elections, it typically finds the traditional left-right spectrum. DW-NOMINATE uses legislators who have served in multiple legislative sessions to compare sessions and track changes through time.


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

The following code will read the rollcall data into WSession objects, and add the sessions to a DWChamber object.
<code>chamber.dwnominate</code> starts the nominate process, first calling <code>wnominate</code> on each WSession, then using the results to write the input files for the DW-NOMINATE program, and then running DW-NOMINATE. All results,
including output graphs from the R wnominate package, will be written to a folder called 'nominate'.

An alternative is to call <code>wnominate(prefix)</code> on WSession objects, which will run only the W-NOMINATE program, adding the specified prefix to each output file.



<pre>
require 'nominate'

chamber = Dwnominate.new

# votes other than Yes or No are counted as missing ('M')
vote_key = Hash.new('M')
vote_key['Yes'] = 'Y'
vote_key['No'] = 'N'

['1999', '2001', '2003', '2005', '2007'].each do |year|
  year = (year.to_i + 1).to_s
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
    issue = data[2]
    vote = vote_key[data[3].chomp]
    if issue != old_issue
      session.add_rollcall(rollcall) unless i == 0
      rollcall = Hash.new('M')
      old_issue = issue
    end
    rollcall[name] = vote
    parties[name] = data[1] if not parties.has_key?(name)
    # get the last rollcall when you reach the end of the file
    session.add_rollcall(rollcall) if i == lines.length - 1
  end
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
