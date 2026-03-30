import numpy as np
import matplotlib.pyplot as plt

f = np.linspace(0.001, 1.0, 1000)  # trade lot fraction from 0 to 100%

expected_price = 1  # normalized
actual_price = 0.997 / (1 + f * 0.997)
slippage = (actual_price - expected_price) / expected_price * 100

plt.figure(figsize=(8, 5))
plt.plot(f, slippage, color="red")
plt.title("Slippage vs Trade Lot Fraction (Constant Product AMM)")
plt.xlabel("Trade Lot Fraction (amountIn / reserveA)")
plt.ylabel("Slippage (%)")
plt.grid(True)
plt.savefig("slippage_plot.png", dpi=150)
plt.show()