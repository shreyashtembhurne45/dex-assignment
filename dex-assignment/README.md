# 📌 Decentralized Exchange (DEX) - Assignment 3

This project is my implementation of a basic Automated Market Maker (AMM) based Decentralized Exchange using Solidity.

The goal of this assignment was to understand how DEXs like Uniswap work internally, especially concepts like liquidity pools, LP tokens, and arbitrage.

Since I am still new to Solidity and blockchain (learning for a few weeks), I have focused more on correctness and understanding rather than advanced optimizations.

## ⚙️ Testnet Used

Sepolia Testnet

## 📜 Deployed Contracts

| Contract | Address | Link |
|---------|--------|------|
| TokenA | <add address> | <etherscan link> |
| TokenB | <add address> | <etherscan link> |
| LPToken | <add address> | <etherscan link> |
| DEX (1) | <add address> | <etherscan link> |
| DEX (2) | <add address> | <etherscan link> |
| Arbitrage | <add address> | <etherscan link> |

## 🔁 Key Transactions

| Action | Transaction Hash |
|-------|-----------------|
| Add Liquidity | <tx hash> |
| Remove Liquidity | <tx hash> |
| Swap TokenA → TokenB | <tx hash> |
| Swap TokenB → TokenA | <tx hash> |
| Arbitrage (Profitable) | <tx hash> |
| Arbitrage (Failed) | <tx hash> |

## 🧠 Design Overview

### AMM Model

The DEX follows the constant product formula:

x * y = k

Where:
x = reserve of TokenA  
y = reserve of TokenB  

### 💧 Liquidity Pool

Users can deposit TokenA and TokenB while maintaining the ratio. The first liquidity provider sets the initial ratio.

### 🪙 LP Tokens

LP tokens are minted when liquidity is added and burned when liquidity is removed. They represent the share of the pool.

### 🔁 Swapping

Users can swap TokenA and TokenB. The price is determined dynamically based on pool reserves. A fixed fee of 0.3% is applied on swaps.

### 📊 Metrics Available

The contract provides:
- Reserves of TokenA and TokenB
- Spot price
- LP token supply

## 🔐 Basic Security Considerations

- Liquidity ratio validation is enforced
- Require checks are used for invalid inputs
- Only the DEX contract can mint and burn LP tokens
- Solidity version 0.8+ is used to avoid overflow issues

## 🚀 How to Interact (Without UI)

Since no UI is implemented, interaction can be done using Etherscan (Write Contract) or Remix.

### Step 1: Mint Tokens

Call `mint()` on both TokenA and TokenB contracts to obtain tokens.

### Step 2: Approve Tokens

Before interacting with the DEX, approve tokens using:

approve(DEX_address, amount)

This must be done for both TokenA and TokenB.

### Step 3: Add Liquidity

Call:

addLiquidity(amountA, amountB)

Note:
- The ratio must match existing pool reserves
- The first provider sets the ratio

LP tokens will be minted to your address.

### Step 4: Remove Liquidity

Call:

removeLiquidity(lpAmount)

You will receive TokenA and TokenB proportional to your share.

### Step 5: Swap Tokens

For TokenA to TokenB:

swapAforB(amountA)

For TokenB to TokenA:

swapBforA(amountB)

### Step 6: Check Pool State

Call:

getReserves()  
getSpotPrice()

### Step 7: Arbitrage Contract

Call:

executeArbitrage()

This function checks for price differences between two DEX contracts and executes the trade only if it is profitable.

## 📹 Demo Video

<add video link>

## 📚 Notes

This is a simplified implementation of a DEX. No UI is included due to time constraints. Interaction is done via Etherscan or Remix. The focus of this project was to understand AMM logic and smart contract interaction.

## 🙌 Final Thoughts

This assignment helped me understand how AMMs work, how liquidity pools maintain pricing, and how arbitrage works in DeFi systems. There is still scope for improvements like better security and gas optimization.