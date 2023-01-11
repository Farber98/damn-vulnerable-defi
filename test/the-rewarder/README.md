# Intro

There's a pool offering rewards in tokens every 5 days for those who deposit their DVT tokens into it.

Alice, Bob, Charlie and David have already deposited some DVT tokens, and have won their rewards!

You don't have any DVT tokens. But in the upcoming round, you must claim most rewards for yourself.

Oh, by the way, rumours say a new pool has just landed on mainnet. Isn't it offering DVT tokens in flash loans?

# Attack explanation

Our objective is to take the ETH from the lending pool. If we dig the contract, we can find the next functions:

```

```

In order to beat the level, we need to ...

# Attack function

We can create the following attacker contract to make the attack:

```

```
