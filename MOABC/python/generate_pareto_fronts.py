#!/usr/bin/env python3
"""Generate Pareto front plots for ZDT1 using MOEAD-ABC.

Standalone script — runs the algorithm with all 4 aggregation types,
generates PNG plots and CSV data files in the results/ directory.

Usage:
    python3 generate_pareto_fronts.py
"""

import os
import sys
import numpy as np
from itertools import combinations
from math import comb
from scipy.spatial.distance import cdist

# Use non-interactive backend so we can save without a display
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


# ======================================================================
# Utility functions (self-contained)
# ======================================================================

def uniform_point(n, m):
    """Generate approximately n uniform weight vectors with m objectives."""
    h1 = 1
    while comb(h1 + m, m - 1) <= n:
        h1 += 1
    indices = np.array(list(combinations(range(1, h1 + m), m - 1)))
    w = indices - np.arange(m - 1) - 1
    w = np.column_stack([w, np.full(len(w), h1)]) - \
        np.column_stack([np.zeros(len(w)), w])
    w = w / h1
    if h1 < m:
        h2 = 0
        while comb(h1 + m - 1, m - 1) + comb(h2 + m, m - 1) <= n:
            h2 += 1
        if h2 > 0:
            i2 = np.array(list(combinations(range(1, h2 + m), m - 1)))
            w2 = i2 - np.arange(m - 1) - 1
            w2 = np.column_stack([w2, np.full(len(w2), h2)]) - \
                 np.column_stack([np.zeros(len(w2)), w2])
            w2 = w2 / h2
            w = np.vstack([w, w2 / 2 + 1 / (2 * m)])
    w = np.maximum(w, 1e-6)
    return w, w.shape[0]


def roulette_wheel(p):
    """Roulette wheel selection (0-based index)."""
    return int(np.searchsorted(np.cumsum(p), np.random.rand()))


def zdt1_obj(x):
    """Evaluate ZDT1 objectives. x shape: (n, D) or (D,)."""
    x = np.atleast_2d(x)
    f1 = x[:, 0]
    g = 1.0 + 9.0 * np.sum(x[:, 1:], axis=1)
    f2 = g * (1.0 - np.sqrt(f1 / g))
    return np.column_stack([f1, f2])


def igd(pop_obj, pf):
    """Inverted Generational Distance."""
    return float(np.mean(np.min(cdist(pf, pop_obj), axis=1)))


# ======================================================================
# MOEAD-ABC
# ======================================================================

def run_moeadabc(agg_type, N=100, D=30, max_eval=10000, T=20, seed=42):
    """Run MOEAD-ABC on ZDT1 and return the final objective matrix."""
    np.random.seed(seed)
    M = 2

    # Weight vectors & neighbourhood
    W, N = uniform_point(N, M)
    B = np.argsort(cdist(W, W), axis=1)[:, :T]

    # Initialise
    pop_dec = np.random.rand(N, D)
    pop_obj = zdt1_obj(pop_dec)
    Z = np.min(pop_obj, axis=0).copy()

    evals = N
    while evals < max_eval:
        for i in range(N):
            P = B[i]
            nb_obj = pop_obj[P]

            # Fitness-proportionate selection
            Zmax = np.max(pop_obj, axis=0)
            denom = Zmax - Z; denom[denom == 0] = 1e-10
            te = np.max(np.abs(nb_obj - Z) / denom / W[i], axis=1)
            mc = np.mean(te)

            if mc == 0:
                m = np.random.randint(T)
            else:
                F = np.exp(-te / mc)
                m = roulette_wheel(F / F.sum())

            # Choose k ≠ m
            order = np.random.permutation(T)
            while order[0] == m:
                order = np.random.permutation(T)
            k = B[i, order[0]]

            # Offspring
            phi = np.random.uniform(-1, 1, D)
            off = pop_dec[B[i, m]] + phi * (pop_dec[B[i, m]] - pop_dec[k])

            # Polynomial mutation
            mu_pm = 20
            for ii in range(D):
                if np.random.rand() < 1.0 / D:
                    r = np.random.rand()
                    if r < 0.5:
                        delta = (2 * r) ** (1 / (1 + mu_pm)) - 1
                    else:
                        delta = 1 - (2 * (1 - r)) ** (1 / (mu_pm + 1))
                    off[ii] += delta

            off = np.clip(off, 0, 1)
            off_obj = zdt1_obj(off).ravel()
            evals += 1

            Z = np.minimum(Z, off_obj)

            # Update neighbours
            nb_obj = pop_obj[P]
            if agg_type == 1:  # PBI
                nW = np.sqrt(np.sum(W[P] ** 2, axis=1))
                dO = nb_obj - Z; dN = off_obj - Z
                nP = np.sqrt(np.sum(dO ** 2, axis=1))
                nO = np.sqrt(np.sum(dN ** 2))
                cP = np.sum(dO * W[P], axis=1) / (nW * np.maximum(nP, 1e-30))
                cO = np.sum(np.tile(dN, (T, 1)) * W[P], axis=1) / (nW * max(nO, 1e-30))
                g_old = nP * cP + 5 * nP * np.sqrt(np.maximum(1 - cP**2, 0))
                g_new = nO * cO + 5 * nO * np.sqrt(np.maximum(1 - cO**2, 0))
            elif agg_type == 2:  # Tchebycheff
                g_old = np.max(np.abs(nb_obj - Z) * W[P], axis=1)
                g_new = np.max(np.tile(np.abs(off_obj - Z), (T, 1)) * W[P], axis=1)
            elif agg_type == 3:  # Normalised Tchebycheff
                Zm = np.max(np.vstack([pop_obj, off_obj]), axis=0)
                dn = Zm - Z; dn[dn == 0] = 1e-10
                g_old = np.max(np.abs(nb_obj - Z) / dn / W[P], axis=1)
                g_new = np.max(np.tile(np.abs(off_obj - Z) / dn, (T, 1)) / W[P], axis=1)
            elif agg_type == 4:  # Modified Tchebycheff
                g_old = np.max(np.abs(nb_obj - Z) / W[P], axis=1)
                g_new = np.max(np.tile(np.abs(off_obj - Z), (T, 1)) / W[P], axis=1)

            improved = np.where(g_old >= g_new)[0]
            for idx in improved:
                pop_dec[P[idx]] = off.copy()
                pop_obj[P[idx]] = off_obj.copy()

            if evals >= max_eval:
                break

    return pop_obj


# ======================================================================
# Main
# ======================================================================

def main():
    results_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "results")
    os.makedirs(results_dir, exist_ok=True)

    # True PF
    f1_true = np.linspace(0, 1, 1000)
    f2_true = 1 - np.sqrt(f1_true)
    pf = np.column_stack([f1_true, f2_true])

    agg_names = ["PBI", "Tchebycheff", "Normalised_Tchebycheff", "Modified_Tchebycheff"]
    all_results = {}

    # --- True PF plot ---
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.plot(f1_true, f2_true, "b-", linewidth=2)
    ax.set_xlabel(r"$f_1$", fontsize=14)
    ax.set_ylabel(r"$f_2$", fontsize=14)
    ax.set_title("True Pareto Front — ZDT1", fontsize=16)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(results_dir, "ZDT1_true_pareto_front.png"), dpi=150)
    plt.close(fig)
    print("Saved: ZDT1_true_pareto_front.png")

    # --- Run each aggregation type ---
    for agg_type in range(1, 5):
        name = agg_names[agg_type - 1]
        print(f"Running MOEAD-ABC with {name.replace('_', ' ')} (type={agg_type})...")

        pop_obj = run_moeadabc(agg_type, N=100, D=30, max_eval=10000, seed=42)
        all_results[agg_type] = pop_obj

        igd_val = igd(pop_obj, pf)
        print(f"  IGD = {igd_val:.6f}")

        # Individual plot
        fig, ax = plt.subplots(figsize=(8, 6))
        ax.plot(f1_true, f2_true, "b-", linewidth=1.5, label="True PF")
        ax.scatter(pop_obj[:, 0], pop_obj[:, 1], s=30, c="red",
                   edgecolors="darkred", linewidths=0.5, label="MOEAD-ABC", zorder=5)
        ax.set_xlabel(r"$f_1$", fontsize=14)
        ax.set_ylabel(r"$f_2$", fontsize=14)
        ax.set_title(f"MOEAD-ABC on ZDT1 — {name.replace('_', ' ')}  (IGD={igd_val:.4e})",
                     fontsize=15)
        ax.legend(fontsize=12, loc="upper right")
        ax.grid(True, alpha=0.3)
        fig.tight_layout()
        fname = f"ZDT1_MOEADABC_{name}.png"
        fig.savefig(os.path.join(results_dir, fname), dpi=150)
        plt.close(fig)
        print(f"  Saved: {fname}")

        # CSV
        csv_name = f"ZDT1_MOEADABC_{name}_objectives.csv"
        np.savetxt(os.path.join(results_dir, csv_name), pop_obj, delimiter=",",
                   header="f1,f2", comments="")
        print(f"  Saved: {csv_name}")

    # --- Combined comparison plot ---
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.plot(f1_true, f2_true, "k-", linewidth=2, label="True PF")
    colors = ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728"]
    for agg_type in range(1, 5):
        data = all_results[agg_type]
        name = agg_names[agg_type - 1].replace("_", " ")
        ax.scatter(data[:, 0], data[:, 1], s=25, c=colors[agg_type - 1],
                   edgecolors="none", label=name, alpha=0.8, zorder=5)
    ax.set_xlabel(r"$f_1$", fontsize=14)
    ax.set_ylabel(r"$f_2$", fontsize=14)
    ax.set_title("MOEAD-ABC on ZDT1 — All Aggregation Types Compared", fontsize=16)
    ax.legend(fontsize=11, loc="upper right")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(results_dir, "ZDT1_MOEADABC_comparison.png"), dpi=150)
    plt.close(fig)
    print("Saved: ZDT1_MOEADABC_comparison.png")

    print(f"\n=== All done! Results in: {results_dir} ===")


if __name__ == "__main__":
    main()
