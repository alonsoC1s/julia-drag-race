# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.11.1
#   kernelspec:
#     display_name: 'Python 3.8.8 64-bit (''augusta'': conda)'
#     name: python388jvsc74a57bd0eb4ac2b025dd20083c769b1f97ba4d0ea548d44d81379c34c67558da8c520a19
# ---

# %%
import seaborn as sns
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt

sns.set(style="darkgrid")

# matplotlib.use("module://matplotlib-backend-kitty")

lpdefaults = {"x": "dim", "y": "time", "hue": "method"}


# %%
# julia = pd.read_csv("julia.csv")
julia_d = pd.read_csv("julia_dumb.csv")
matlab = pd.read_csv("matlab.csv")

# %%
sns.lineplot(**lpdefaults, data=julia)

# %%
sns.lineplot(**lpdefaults, data=julia_d)

# %%
julias = pd.concat([julia, julia_d])
fig, ax = plt.subplots()
# ax.set_ylim((0, .25))
sns.lineplot(**lpdefaults, data=julias, ax=ax)

# %%
sns.lineplot(**lpdefaults, data=matlab)

# %%
both = pd.concat([julia_d, matlab])

# %%
fig, ax = plt.subplots()
ax.set_ylim((0, 0.10))
sns.lineplot(**lpdefaults, style="lang", data=both, ax=ax)

# %%
only_simple = both[both.method.str.startswith("pivotSimple")]
sns.lineplot(**lpdefaults, style="lang", data=only_simple)

plt.savefig("simple_pivot.png")
