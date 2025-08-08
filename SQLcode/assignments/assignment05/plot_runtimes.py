import os

try:
    import matplotlib.pyplot as plt
    import pandas as pd
except ImportError:
    import subprocess
    subprocess.check_call(["pip3", "install", "matplotlib", "pandas"])
    import matplotlib.pyplot as plt
    import pandas as pd

# ===================================

output_dir = "outputfiles/exercise01"
data_file = f"{output_dir}/timing_results.tsv"
plot_file = f"{output_dir}/thread_performance_plots.png"

df = pd.read_csv(data_file, sep="\t")
fig, axs = plt.subplots(3, 1, figsize=(6, 8), sharex=True)

max_threads = max(df["Threads"])
x_ticks = range(0, max_threads + 10, 10)

# Sweet spot (T=8-12)
highlight_color = 'lightgreen'
highlight_alpha = 0.2

for ax in axs:
    ax.axvspan(8, 12, facecolor=highlight_color, alpha=highlight_alpha, label='Optimal Range (T=8-12)')
    ax.axvline(8, color='green', linestyle='--', linewidth=0.7)
    ax.axvline(12, color='green', linestyle='--', linewidth=0.7)
    ax.grid(True, linestyle=':', alpha=0.7)
    ax.set_xticks(x_ticks)

# Runtime 
axs[0].plot(df["Threads"], df["Runtime"], 'blue', marker='o', linewidth=2, label='Runtime')
axs[0].set_ylabel("Runtime (s)", fontweight='bold')
axs[0].set_title("Runtime Scaling", fontweight='bold')
axs[0].legend()

# Speedup 
axs[1].plot(df["Threads"], df["Speedup"], 'orange', marker='s', linewidth=2, label='Speedup')
axs[1].set_ylabel("Speedup", fontweight='bold')
axs[1].set_title("Parallel Speedup", fontweight='bold')
axs[1].legend()

# Efficiency 
axs[2].plot(df["Threads"], df["Efficiency"], 'purple', marker='^', linewidth=2, label='Efficiency')
axs[2].set_xlabel("Thread Count", fontweight='bold')
axs[2].set_ylabel("Efficiency", fontweight='bold')
axs[2].set_title("Parallel Efficiency", fontweight='bold')
axs[2].legend()

plt.suptitle("Thread Scaling Performance Analysis (M2 MacBook Pro)", y=1.02, fontweight='bold')
plt.tight_layout()
plt.savefig(plot_file)
plt.show()

#### ################################################################# ####