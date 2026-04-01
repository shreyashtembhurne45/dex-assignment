# 📌 Decentralized Exchange (DEX) - Assignment 3

## 🌐 Live UI
https://shreyashtembhurne45.github.io/dex-assignment

> Connect MetaMask on **Sepolia testnet** to interact with the live contracts.

---

## ⚙️ Testnet
Sepolia Testnet (Chain ID: 11155111)

---

## 📜 Deployed Contracts

| Contract | Address | Explorer |
|----------|---------|----------|
| TokenA | 0xf71bD5F3843bfEB4828A6134bA429Fe7b3bfdfEA | [View](https://sepolia.etherscan.io/address/0xf71bD5F3843bfEB4828A6134bA429Fe7b3bfdfEA) |
| TokenB | 0x677c8e3Faac324Ac445484529BA1DFaF22611878 | [View](https://sepolia.etherscan.io/address/0x677c8e3Faac324Ac445484529BA1DFaF22611878) |
| DEX (1) | 0x3e7935d4789a582bE2aefF20436a5469E0202382 | [View](https://sepolia.etherscan.io/address/0x3e7935d4789a582bE2aefF20436a5469E0202382) |
| DEX (2) | 0x08E60a465Bde51fC8898A2CcEAaaFB786ac83D0c | [View](https://sepolia.etherscan.io/address/0x08E60a465Bde51fC8898A2CcEAaaFB786ac83D0c) |
| Arbitrage | 0x9Df1200d845c6310d956da23190C49B45b3Ccc2F | [View](https://sepolia.etherscan.io/address/0x9Df1200d845c6310d956da23190C49B45b3Ccc2F) |

> LPToken is deployed automatically by each DEX contract internally.

---

## 🔁 Key Transactions

| Action | Transaction Hash |
|--------|-----------------|
| Add Liquidity + LP Token Minting | [0xfa7d...](https://sepolia.etherscan.io/tx/0xfa7de0bd11a9a8cf89403967809ea8f5017aa2e7a076783fff8e95c4baf5f53f) |
| Add Liquidity DEX2 | [0x932a...](https://sepolia.etherscan.io/tx/0x932ae8d257e89c06dc4100a70bacdf976220897a415ff14e743cf5a882582506) |
| Swap TokenA → TokenB | [0xb9e6...](https://sepolia.etherscan.io/tx/0xb9e616015463b615cd4877a79b357ce5a78efaab99d463789ba26b916c6c8c37) |
| Remove Liquidity + LP Token Burning | [0x52e3...](https://sepolia.etherscan.io/tx/0x52e31e2a3ea25d14b74a414485b0a45d7191fdb543503b6b3aad1d548e754582) |
| Profitable Arbitrage Execution | [0xf752...](https://sepolia.etherscan.io/tx/0xf752dd953fd30a1c9b227dcf5ed2a53aa019bfeb9ad8fe5938ca6fbcce9aad98) |
| Failed Arbitrage (Insufficient Profit) | [0xe242...](https://sepolia.etherscan.io/tx/0xe2422522eeea07a2e621692267cf2db2fea6f057c4032689e56ad0511645805f) |

---

## 🚀 How to Use the UI

1. Go to https://shreyashtembhurne45.github.io/dex-assignment
2. Make sure MetaMask is on **Sepolia testnet**
3. Click **Connect Wallet**
4. To get tokens: call `mint()` on TokenA and TokenB via Etherscan
5. Add liquidity, swap, or remove liquidity using the UI

---

## 🧠 How It Works

### AMM Formula
```
x * y = k
```
Price is determined by reserve ratio. Buying TokenA decreases its reserve, automatically raising its price.

### LP Tokens
Minted when liquidity is added, burned when removed. Only the DEX can mint/burn them.

### Swap Fee
Fixed at 0.3%. Stays in the pool — this is how LPs earn returns over time.

### Arbitrage
Compares spot prices across two DEXes. Executes only when profit exceeds minimum threshold after fees.

---

## 🔐 Security
- Ratio validation on every deposit
- Reentrancy protection (state updated before transfers)
- Only DEX can mint/burn LP tokens
- Solidity 0.8+ overflow protection

---

## 📊 Simulation
```bash
pip install matplotlib
python simulation.py
```
Plots: TVL, Reserve Ratio, LP Distribution, Swap Volume, Fees, Spot Price, Slippage

---

## 📚 References
- Uniswap Whitepaper: https://uniswap.org/whitepaper.pdf
- OpenZeppelin ERC-20: https://docs.openzeppelin.com/contracts/erc20
- Solidity Docs: https://docs.soliditylang.org
- Ethereum Developer Docs: https://ethereum.org/en/developers/
