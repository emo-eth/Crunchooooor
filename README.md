# Crunchooooor

Crunchooooor is a (WIP) smart contract that (todo: tokenizes? and) rewards Create2Crunchooooors by paying out bounties to whoever crunches the most efficient address for a smart contract deployed via CREATE2.

Anyone can create a bounty for an efficient CREATE2 address, and anyone can pitch in to increase that bounty. Bounties have a time limit, and once it has ended, the reward is paid out to the highest scoring submitter or, if none, returned to the bounty creator (note: including any extra pitched in by other users).

(TODO: and maybe a token is minted of the smart contract address)

The scoring formula is as follows:

```
S = L^2 + T
```


Where
- S is the total score
- L is the number of leading zero bytes in the address
- T is the total number of zero bytes in the address

Submitters must first submit a commitment hash and wait at least one minute. The hash is validated upon submission of the salt used to derive the address. This prevents front-running of efficient salt submission to steal bounties.

To prevent gaming of the time window, a commitment expires after 5 minutes.
