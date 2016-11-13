# bucklin-range
Voting scripts based on the Bucklin-Range method (in turn based on PTASes of
the k-median and uncapacitated facility location problem).

## References
- [First EM list post describing Bucklin-Range](http://lists.electorama.com/pipermail/election-methods-electorama.com/2015-January/131069.html) 
- [Second EM list post simplifying Bucklin-Range](http://lists.electorama.com/pipermail/election-methods-electorama.com/2016-November/000976.html)

## Description

The scripts may be somewhat ugly as they're meant as proof of concepts and
some of the tiebreak logic isn't entirely sound yet.

- `bucklin.py` implements the weighted candidate version of Bucklin-Range 
in both Bucklin ("Double Bucklin") and Range-based forms. This is essentially
party list with a limited number of parties, but where the parliament has
infinite seats and each candidate's weight is the proportion of the seats that
candidate would get if it were a party.

- `dbuck_partylist.py` implements a discrete version of Double Bucklin that
reduces to Webster's method if the voters only submit Plurality-style ballots.
To reduce vote-wasting, the method only gives additional seats to a party when
there are enough voters to give one additional seat, and then it redistributes
the surplus to the voters who contributed to giving the party an additional
seat (as in STV).

- `dbuck_droop.py` is a simple Double Bucklin variant which elects 
individual candidates (no weights). It is basically Bucklin or MJ with the 
Droop quota (rather than a majority) as the threshold.
