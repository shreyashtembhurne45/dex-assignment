# 📌 Decentralized Exchange (DEX) - Assignment 3

This project is my implementation of a basic Automated Market Maker (AMM) based Decentralized Exchange using Solidity.

The goal of this assignment was to understand how DEXs like Uniswap work internally, especially concepts like liquidity pools, LP tokens, and arbitrage.

Since I am still new to Solidity and blockchain (learning for a few weeks), I have focused more on correctness and understanding rather than advanced optimizations.

---

## ⚙️ Testnet Used

Remix VM (Osaka) — Local simulation environment

---

## 📜 Deployed Contracts

| Contract | Address |
|----------|---------|
| TokenA | 0xDf9D0C45d97f134151a386E0AA23b09CA903c13f |
| TokenB | 0xc4753C8802178e524cdB766D7E47cFc566e34443 |
| DEX (1) | 0x9dAf7c849c20Be671315E77CB689811bD5EDefe6 |
| DEX (2) | 0xa42b1378D1A84b153eB3e3838aE62870A67a40EA |
| DEX (3) | 0x4D9f44094F448D949fc3EECa230A01d362529424 |
| Arbitrage | 0xFd33eca8D6411f405637877c9C7002D321182937 |

> Note: LPToken is deployed automatically by each DEX contract internally via `new LPToken()` in the DEX constructor.

---

## 🔁 Key Transactions

| Action | Transaction Hash |
|--------|-----------------|
| Add Liquidity + LP Token Minting | 0x38c3b71c8f79c219f60496e3f4bf5e648d9b16f504e762e712d4d98975ec1e42 |
| Remove Liquidity + LP Token Burning | 0x13ab86b9fcc0044dad490f7c9e42f5e397f3bbd9e26ed18bca17b633199c990c |
| Swap TokenA → TokenB | 0xd8f5094a4e3136f8e82a85e2f85b40c644d5b0bec999b93c982c2e6eedd86fff |
| Profitable Arbitrage Execution | 0x88f321ae0508da8b55be34b9e48e3b7397968078fc321ab255b0f7ca07d23ba9 |
| Failed Arbitrage (Insufficient Profit) | 0x73d099f1f408c364bbc842a56b90853ca3a0d6f4b58a50548ca9c5e41b27467b |

---

## 🧠 Design Overview

### AMM Model
The DEX follows the constant product formula:
```
x * y = k
```

Where:
- x = reserve of TokenA
- y = reserve of TokenB
- k = constant maintained during swaps

### 💧 Liquidity Pool
Users deposit TokenA and TokenB while maintaining the current reserve ratio. The first liquidity provider sets the initial ratio and receives LP tokens.

### 🪙 LP Tokens
LP tokens are ERC20 tokens minted when liquidity is added and burned when liquidity is removed. They represent the provider's proportional share of the pool. Only the DEX contract can mint or burn LP tokens.

### 🔁 Swapping
Users can swap TokenA for TokenB and vice versa. The output amount is determined by the constant product formula with a fixed 0.3% fee applied on every swap.

### ⚖️ Arbitrage
The Arbitrage contract compares spot prices across two DEX contracts. If a profitable opportunity exists (profit exceeds minimum threshold), it executes swaps on both DEXes to capture the difference.

### 📊 Metrics Tracked
- Reserves of TokenA and TokenB
- Spot price (TokenB per TokenA)
- LP token supply and distribution

---

## 🔐 Security Considerations
- Liquidity ratio validation enforced on every deposit
- `require` checks on all inputs
- Only the DEX contract can mint and burn LP tokens (via `onlyOwner` on LPToken)
- State updated before external token transfers (reentrancy protection)
- Solidity 0.8+ used to prevent overflow/underflow

---

## 📊 Simulation (Section 4.2)

Run the simulation:
```bash
pip install matplotlib
python simulation.py
```

Generates plots for all 7 metrics from Table 1:
- Total Value Locked (TVL)
- Reserve Ratio
- LP Token Distribution
- Swap Volume
- Fee Accumulation
- Spot Price
- Slippage

Simulation plots are included in the repository:
- `dex_simulation.png` — all 7 metrics
- `slippage_plot.png` — slippage vs trade lot fraction (Theory Q7)

---

## 🚀 How to Interact (Via Remix)

### Step 1: Compile all contracts
Open each file in Remix and hit Ctrl+S:
1. `Token.sol`
2. `LPToken.sol`
3. `DEX.sol`
4. `Arbitrage.sol`

### Step 2: Deploy in order
1. Deploy `Token` as TokenA (`name=TokenA, symbol=TKA, initialSupply=1000000`)
2. Deploy `Token` as TokenB (`name=TokenB, symbol=TKB, initialSupply=1000000`)
3. Deploy `DEX` with TokenA and TokenB addresses
4. Deploy `Arbitrage` with TokenA, TokenB addresses and min threshold

### Step 3: Approve tokens
On both TokenA and TokenB, call:
```
approve(DEX_address, 999999999999999999999999)
```

### Step 4: Add liquidity
```
addLiquidity(amountA, amountB)
```
Ratio must match existing pool reserves. First provider sets the ratio.

### Step 5: Swap tokens
```
swapAForB(amountAIn)   // TokenA → TokenB
swapBForA(amountBIn)   // TokenB → TokenA
```

### Step 6: Remove liquidity
```
removeLiquidity(lpAmount)
```

### Step 7: Check pool state
```
getReserves()     // returns (reserveA, reserveB)
spotPrice()       // returns TokenB per TokenA scaled by 1e18
```

### Step 8: Run arbitrage
```
approveTokens(dex1, dex2)           // pre-approve DEXes
deposit(amount)                      // fund the contract
executeArbitrage(dex1, dex2, amount) // execute if profitable
```

---

## 📹 Demo Video
# 📌 Decentralized Exchange (DEX) - Assignment 3

This project is my implementation of a basic Automated Market Maker (AMM) based Decentralized Exchange using Solidity.

The goal of this assignment was to understand how DEXs like Uniswap work internally, especially concepts like liquidity pools, LP tokens, and arbitrage.

Since I am still new to Solidity and blockchain (learning for a few weeks), I have focused more on correctness and understanding rather than advanced optimizations.

---

## ⚙️ Testnet Used

Remix VM (Osaka) — Local simulation environment

---

## 📜 Deployed Contracts

| Contract | Address |
|----------|---------|
| TokenA | 0xDf9D0C45d97f134151a386E0AA23b09CA903c13f |
| TokenB | 0xc4753C8802178e524cdB766D7E47cFc566e34443 |
| DEX (1) | 0x9dAf7c849c20Be671315E77CB689811bD5EDefe6 |
| DEX (2) | 0xa42b1378D1A84b153eB3e3838aE62870A67a40EA |
| DEX (3) | 0x4D9f44094F448D949fc3EECa230A01d362529424 |
| Arbitrage | 0xFd33eca8D6411f405637877c9C7002D321182937 |

> Note: LPToken is deployed automatically by each DEX contract internally via `new LPToken()` in the DEX constructor.

---

## 🔁 Key Transactions

| Action | Transaction Hash |
|--------|-----------------|
| Add Liquidity + LP Token Minting | 0x38c3b71c8f79c219f60496e3f4bf5e648d9b16f504e762e712d4d98975ec1e42 |
| Remove Liquidity + LP Token Burning | 0x13ab86b9fcc0044dad490f7c9e42f5e397f3bbd9e26ed18bca17b633199c990c |
| Swap TokenA → TokenB | 0xd8f5094a4e3136f8e82a85e2f85b40c644d5b0bec999b93c982c2e6eedd86fff |
| Profitable Arbitrage Execution | 0x88f321ae0508da8b55be34b9e48e3b7397968078fc321ab255b0f7ca07d23ba9 |
| Failed Arbitrage (Insufficient Profit) | 0x73d099f1f408c364bbc842a56b90853ca3a0d6f4b58a50548ca9c5e41b27467b |

---

## 🧠 Design Overview

### AMM Model
The DEX follows the constant product formula:
```
x * y = k
```

Where:
- x = reserve of TokenA
- y = reserve of TokenB
- k = constant maintained during swaps

### 💧 Liquidity Pool
Users deposit TokenA and TokenB while maintaining the current reserve ratio. The first liquidity provider sets the initial ratio and receives LP tokens.

### 🪙 LP Tokens
LP tokens are ERC20 tokens minted when liquidity is added and burned when liquidity is removed. They represent the provider's proportional share of the pool. Only the DEX contract can mint or burn LP tokens.

### 🔁 Swapping
Users can swap TokenA for TokenB and vice versa. The output amount is determined by the constant product formula with a fixed 0.3% fee applied on every swap.

### ⚖️ Arbitrage
The Arbitrage contract compares spot prices across two DEX contracts. If a profitable opportunity exists (profit exceeds minimum threshold), it executes swaps on both DEXes to capture the difference.

### 📊 Metrics Tracked
- Reserves of TokenA and TokenB
- Spot price (TokenB per TokenA)
- LP token supply and distribution

---

## 🔐 Security Considerations
- Liquidity ratio validation enforced on every deposit
- `require` checks on all inputs
- Only the DEX contract can mint and burn LP tokens (via `onlyOwner` on LPToken)
- State updated before external token transfers (reentrancy protection)
- Solidity 0.8+ used to prevent overflow/underflow

---

## 📊 Simulation (Section 4.2)

Run the simulation:
```bash
pip install matplotlib
python simulation.py
```

Generates plots for all 7 metrics from Table 1:
- Total Value Locked (TVL)
- Reserve Ratio
- LP Token Distribution
- Swap Volume
- Fee Accumulation
- Spot Price
- Slippage

Simulation plots are included in the repository:
- `dex_simulation.png` — all 7 metrics
- `slippage_plot.png` — slippage vs trade lot fraction (Theory Q7)

---

## 🚀 How to Interact (Via Remix)

### Step 1: Compile all contracts
Open each file in Remix and hit Ctrl+S:
1. `Token.sol`
2. `LPToken.sol`
3. `DEX.sol`
4. `Arbitrage.sol`

### Step 2: Deploy in order
1. Deploy `Token` as TokenA (`name=TokenA, symbol=TKA, initialSupply=1000000`)
2. Deploy `Token` as TokenB (`name=TokenB, symbol=TKB, initialSupply=1000000`)
3. Deploy `DEX` with TokenA and TokenB addresses
4. Deploy `Arbitrage` with TokenA, TokenB addresses and min threshold

### Step 3: Approve tokens
On both TokenA and TokenB, call:
```
approve(DEX_address, 999999999999999999999999)
```

### Step 4: Add liquidity
```
addLiquidity(amountA, amountB)
```
Ratio must match existing pool reserves. First provider sets the ratio.

### Step 5: Swap tokens
```
swapAForB(amountAIn)   // TokenA → TokenB
swapBForA(amountBIn)   // TokenB → TokenA
```

### Step 6: Remove liquidity
```
removeLiquidity(lpAmount)
```

### Step 7: Check pool state
```
getReserves()     // returns (reserveA, reserveB)
spotPrice()       // returns TokenB per TokenA scaled by 1e18
```

### Step 8: Run arbitrage
```
approveTokens(dex1, dex2)           // pre-approve DEXes
deposit(amount)                      // fund the contract
executeArbitrage(dex1, dex2, amount) // execute if profitable
```

---

## 📹 Demo Video
(https://youtu.be/oZX2-qALpXw)

---

## 🌐 Live UI
https://shreyashtembhurne45.github.io/dex-assignment

---

## 📚 References
- Uniswap Whitepaper: https://uniswap.org/whitepaper.pdf
- OpenZeppelin ERC-20: https://docs.openzeppelin.com/contracts/erc20
- Solidity Documentation: https://docs.soliditylang.org
- Ethereum Developer Docs: https://ethereum.org/en/developers/

---

## 🙌 Final Notes
This is a simplified implementation of a DEX. No UI is included due to time constraints. Interaction is done via Remix. The focus was on understanding AMM logic, liquidity pool mechanics, and arbitrage in DeFi systems.

---

## 📚 References
- Uniswap Whitepaper: https://uniswap.org/whitepaper.pdf
- OpenZeppelin ERC-20: https://docs.openzeppelin.com/contracts/erc20
- Solidity Documentation: https://docs.soliditylang.org
- Ethereum Developer Docs: https://ethereum.org/en/developers/

---

## 🙌 Final Notes
This is a simplified implementation of a DEX. No UI is included due to time constraints. Interaction is done via Remix. The focus was on understanding AMM logic, liquidity pool mechanics, and arbitrage in DeFi systems.
