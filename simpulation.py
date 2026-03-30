import random
import matplotlib.pyplot as plt

# ================================================================
# Section 4.2 — Testing Requirements
# Simulating 5 LPs and 8 traders over N transactions
# ================================================================

# Section 4.1.2 — Same fee as DEX.sol
FEE_NUMERATOR = 997
FEE_DENOMINATOR = 1000

# ================================================================
# AMM CLASS — applying the math in DEX.sol exactly
# ================================================================
class AMM:
    def __init__(self, initial_a, initial_b):
        # Section 4.1.3 — internal reserves
        self.reserve_a = initial_a
        self.reserve_b = initial_b
        self.lp_supply = 1000  # first deposit baseline

        # Section 4.2 Table 1 — Fee Accumulation tracking
        self.total_fees_a = 0
        self.total_fees_b = 0

    def spot_price(self):
        # Section 4.1.1 — "return value of this function is Spot Price"
        # price of A in terms of B
        if self.reserve_a == 0:
            return 0
        return self.reserve_b / self.reserve_a

    def add_liquidity(self, amount_a, amount_b):
        # Section 4.1.1 — ratio must be preserved
        if self.reserve_a > 0 and self.reserve_b > 0:
            expected_b = amount_a * self.reserve_b / self.reserve_a
            if abs(expected_b - amount_b) > 1e-9:
                # Fix the ratio automatically in simulation
                amount_b = expected_b

        lp_minted = (amount_a / self.reserve_a) * self.lp_supply
        self.reserve_a += amount_a
        self.reserve_b += amount_b
        self.lp_supply += lp_minted
        return lp_minted

    def remove_liquidity(self, lp_amount):
        # Section 4.1.1 — proportional withdrawal
        if lp_amount > self.lp_supply:
            lp_amount = self.lp_supply * 0.5
        share = lp_amount / self.lp_supply
        amount_a = share * self.reserve_a
        amount_b = share * self.reserve_b
        self.reserve_a -= amount_a
        self.reserve_b -= amount_b
        self.lp_supply -= lp_amount
        return amount_a, amount_b

    def swap_a_for_b(self, amount_a_in):
        # Section 4.1.2 — constant product formula with 0.3% fee
        amount_in_with_fee = amount_a_in * FEE_NUMERATOR
        amount_b_out = (self.reserve_b * amount_in_with_fee) / \
                       (self.reserve_a * FEE_DENOMINATOR + amount_in_with_fee)

        # Track fees (Section 4.2 Table 1 — Fee Accumulation)
        fee = amount_a_in * 0.003
        self.total_fees_a += fee

        self.reserve_a += amount_a_in
        self.reserve_b -= amount_b_out
        return amount_b_out

    def swap_b_for_a(self, amount_b_in):
        # Section 4.1.2 — same formula, A and B reversed
        amount_in_with_fee = amount_b_in * FEE_NUMERATOR
        amount_a_out = (self.reserve_a * amount_in_with_fee) / \
                       (self.reserve_b * FEE_DENOMINATOR + amount_in_with_fee)

        fee = amount_b_in * 0.003
        self.total_fees_b += fee

        self.reserve_b += amount_b_in
        self.reserve_a -= amount_a_out
        return amount_a_out


# ================================================================
# SIMULATION SETUP
# Section 4.2: "5 LPs and 8 traders, N transactions"
# ================================================================
N = 75  # Section 4.2: N ∈ [50, 100]

# Give each user some initial tokens
lp_users = [{"a": 10000, "b": 15000, "lp": 0} for _ in range(5)]
traders  = [{"a": 5000,  "b": 5000}            for _ in range(8)]

# Initialize AMM with first LP's deposit
amm = AMM(initial_a=200, initial_b=300)
lp_users[0]["a"] -= 200
lp_users[0]["b"] -= 300
lp_users[0]["lp"] += 1000

all_users = lp_users + traders

# ================================================================
# METRICS TRACKING — Section 4.2 Table 1
# ================================================================
metrics = {
    "tvl":          [],   # Total Value Locked in TokenA units
    "reserve_a":    [],   # TokenA reserve
    "reserve_b":    [],   # TokenB reserve
    "spot_price":   [],   # Current exchange rate
    "swap_vol_a":   [],   # Cumulative TokenA swap volume
    "swap_vol_b":   [],   # Cumulative TokenB swap volume
    "fees_a":       [],   # Cumulative fees in TokenA
    "fees_b":       [],   # Cumulative fees in TokenB
    "slippage":     [],   # Per-swap slippage
    "lp_holdings":  [],   # LP token distribution
}

swap_vol_a = 0
swap_vol_b = 0

# ================================================================
# MAIN SIMULATION LOOP
# Section 4.2: "performer chosen uniformly randomly from all users"
# ================================================================
for t in range(N):
    # Pick random user
    user_idx = random.randint(0, len(all_users) - 1)
    user = all_users[user_idx]
    is_lp = user_idx < 5

    # Pick random action
    # LPs can deposit/withdraw/swap, traders can only swap
    if is_lp:
        action = random.choice(["deposit", "withdraw", "swap_a", "swap_b"])
    else:
        action = random.choice(["swap_a", "swap_b"])

    slippage = None

    if action == "deposit" and is_lp:
        # Section 4.2: "amount determined uniformly randomly
        # based on maximum tokens available with the LP"
        max_a = user["a"] * random.uniform(0.01, 0.5)
        amount_a = max_a
        amount_b = amount_a * (amm.reserve_b / amm.reserve_a)

        if user["a"] >= amount_a and user["b"] >= amount_b and amount_a > 0:
            lp_minted = amm.add_liquidity(amount_a, amount_b)
            user["a"] -= amount_a
            user["b"] -= amount_b
            user["lp"] = user.get("lp", 0) + lp_minted

    elif action == "withdraw" and is_lp:
        lp_bal = user.get("lp", 0)
        if lp_bal > 0:
            lp_amount = lp_bal * random.uniform(0.1, 0.5)
            a_out, b_out = amm.remove_liquidity(lp_amount)
            user["a"] += a_out
            user["b"] += b_out
            user["lp"] -= lp_amount

    elif action == "swap_a":
        # Section 4.2: "tokens deposited chosen from uniform random
        # distribution between 0 and min(tokens held, 10% of reserves)"
        max_swap = min(user["a"], 0.1 * amm.reserve_a)
        amount_in = random.uniform(0, max_swap)

        if amount_in > 0 and amm.reserve_b > 0:
            # Section 4.2 equation (2) — Slippage calculation
            expected_price = amm.reserve_b / amm.reserve_a
            b_out = amm.swap_a_for_b(amount_in)
            actual_price = b_out / amount_in
            slippage = ((actual_price - expected_price) / expected_price) * 100

            user["a"] -= amount_in
            user["b"] = user.get("b", 0) + b_out
            swap_vol_a += amount_in

    elif action == "swap_b":
        max_swap = min(user["b"], 0.1 * amm.reserve_b)
        amount_in = random.uniform(0, max_swap)

        if amount_in > 0 and amm.reserve_a > 0:
            expected_price = amm.reserve_a / amm.reserve_b
            a_out = amm.swap_b_for_a(amount_in)
            actual_price = a_out / amount_in
            slippage = ((actual_price - expected_price) / expected_price) * 100

            user["b"] -= amount_in
            user["a"] = user.get("a", 0) + a_out
            swap_vol_b += amount_in

    # ============================================================
    # Record all metrics after each transaction
    # Section 4.2 Table 1
    # ============================================================
    # TVL = total reserves measured in TokenA units using spot price
    tvl = amm.reserve_a + amm.reserve_b / amm.spot_price() \
          if amm.spot_price() > 0 else amm.reserve_a
    metrics["tvl"].append(tvl)
    metrics["reserve_a"].append(amm.reserve_a)
    metrics["reserve_b"].append(amm.reserve_b)
    metrics["spot_price"].append(amm.spot_price())
    metrics["swap_vol_a"].append(swap_vol_a)
    metrics["swap_vol_b"].append(swap_vol_b)
    metrics["fees_a"].append(amm.total_fees_a)
    metrics["fees_b"].append(amm.total_fees_b)
    metrics["slippage"].append(slippage if slippage is not None else 0)
    metrics["lp_holdings"].append([u.get("lp", 0) for u in lp_users])


# ================================================================
# PLOTS — Section 4.2 Table 1
# One plot per metric as required
# ================================================================
time = list(range(N))

fig, axes = plt.subplots(4, 2, figsize=(14, 16))
fig.suptitle("DEX Simulation Metrics (Section 4.2)", fontsize=14)

# 1. TVL
axes[0,0].plot(time, metrics["tvl"], color="blue")
axes[0,0].set_title("Total Value Locked (TVL) in TokenA units")
axes[0,0].set_xlabel("Transaction")
axes[0,0].set_ylabel("TokenA units")

# 2. Reserve Ratio
ratio = [a/b if b > 0 else 0
         for a, b in zip(metrics["reserve_a"], metrics["reserve_b"])]
axes[0,1].plot(time, ratio, color="green")
axes[0,1].set_title("Reserve Ratio (TokenA / TokenB)")
axes[0,1].set_xlabel("Transaction")
axes[0,1].set_ylabel("Ratio")

# 3. LP Token Distribution
lp_data = metrics["lp_holdings"]
for i in range(5):
    axes[1,0].plot(time, [lp_data[t][i] for t in range(N)], label=f"LP {i+1}")
axes[1,0].set_title("LP Token Distribution")
axes[1,0].set_xlabel("Transaction")
axes[1,0].set_ylabel("LP Tokens held")
axes[1,0].legend()

# 4. Swap Volume
axes[1,1].plot(time, metrics["swap_vol_a"], label="TokenA volume", color="orange")
axes[1,1].plot(time, metrics["swap_vol_b"], label="TokenB volume", color="purple")
axes[1,1].set_title("Cumulative Swap Volume")
axes[1,1].set_xlabel("Transaction")
axes[1,1].set_ylabel("Tokens")
axes[1,1].legend()

# 5. Fee Accumulation
axes[2,0].plot(time, metrics["fees_a"], label="Fees in TokenA", color="red")
axes[2,0].plot(time, metrics["fees_b"], label="Fees in TokenB", color="darkred")
axes[2,0].set_title("Fee Accumulation")
axes[2,0].set_xlabel("Transaction")
axes[2,0].set_ylabel("Tokens")
axes[2,0].legend()

# 6. Spot Price
axes[2,1].plot(time, metrics["spot_price"], color="teal")
axes[2,1].set_title("Spot Price (TokenB per TokenA)")
axes[2,1].set_xlabel("Transaction")
axes[2,1].set_ylabel("Price")

# 7. Slippage
axes[3,0].plot(time, metrics["slippage"], color="brown")
axes[3,0].set_title("Slippage per Transaction (%)")
axes[3,0].set_xlabel("Transaction")
axes[3,0].set_ylabel("Slippage %")

# Hide unused subplot
axes[3,1].axis("off")

plt.tight_layout()
plt.savefig("dex_simulation.png", dpi=150)
plt.show()
print("Simulation complete. Plot saved as dex_simulation.png")