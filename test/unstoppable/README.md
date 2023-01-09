# Intro

There's a lending pool with a million DVT tokens in balance, offering flash loans for free.

If only there was a way to attack and stop the pool from offering flash loans ...

You start with 100 DVT tokens in balance.

# Glossary

- **Lending**: Lenders (depositors) provide funds to borrowers in return for interest. Borrowers (loan takers) are willing to pay interest on the amount they borrowed in exchange for having the money available immediately.

- **Money market**: Market where you can borrow a currency placing another currency as collateral. The collateral may be required in order to pay back if the borrower fails to return his debt. Otherwise, the collateral is returned once the loan is payed back.

- **Defi lending**: Allows users to become lenders or borrowers in a completely decentralized and permisionless way while maintaining full custody over their tokens. Based on SC. Accesible from anyone without KYC.

  1. Users who want to become lenders, supply their assets to a particular money market. They start receiving interests on their assets according to APY.
  2. Supplied assets are sent to SC and become availabe for other users to borrow.
  3. In exchange for the assets lended, the SC issues other tokens that represents supply tokens plus interest. They can be reedemed for the underlying tokens plus interest that grows every block.

- **Overcollateralized loan**: A user who wants to borrow funds, have to supply tokens in the form of collateral that is worth more of the actual loan that they want to take. Reasons to take this loans:

  1. Users dont want to sell their tokens but their need other funds.
  2. Using borrowed funds to increase their leverage in certain position.

- **Borrowing limt**: Depends on many factors

  1. How much funds are available to be borrowed in a particular market. (not a problem in active markets unless someone is trying to borrow a really big amount of tokens)
  2. What is the collateral factor of the supply tokens. Collateral factor determines how much can be borroewd based on the quality of the colateral. (e.g. factor 75% -> Up to 75% of the supplied collateral can be used to borrow other tokens)
  3. MUST: Value of borrowed funds < value of Collateral \* collateral factor.
  4. If Value of borrowed funds > value of Collateral \* collateral factor, the user will have his collateral liquidated in order to repay the borrowed amount.

- **Lending pool**: Pool that has liquidity of certain asset. Tokens deposited by lenders goes here, and borrowed funds are taken from here.

- **Flash loans**: Users can borrow funds with no collateral for a very short period of time. A flash loan have to be borrowed and repayed within the same blockchain transaction (same block).

- **Flash loan provider**: Aave, dydx. Entity with SC that allow users to borrow coins from designated pools under the condition that they are repayed within the same blockchain transaction. Once the amount is borrowed from the lending pool, the user can make any arbitrary actions with them assuming that at the end, the initial flashloan is repayed. For this reason, there is no risk of borrowers not repaying the borrowed funds. Every platform sets a fee that is split between depositors (the ones who provide borrowed assets) and integrators (who facilitate use of flashloan apis). Use cases:

  1. Arbitrage: Maximize the profit of arbitrage with flash loans.
  2. Collateral swap: Swap your colateral to other coin.
  3. Self liquidation: Repay loan before getting liquidated using a flash loan.

# Attack explanation

Challenge #1 - Unstoppable

# Attack function
