# 🧬 **Timpi Synaptron — Intel GPU**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

**Intel GPUs are not supported. There is nothing to install yet.**

This page exists so the answer is written down rather than guessed at. Synaptron runs on
[NVIDIA](NVIDIA.md) cards on Windows, Linux and Docker, and on [AMD](AMD.md) cards on Linux.
Intel Arc, Intel Data Center GPU (Flex / Max) and Intel integrated graphics are **none of those**.

---

## What happens today if you try

| | |
|---|---|
| **Windows** | Not supported. There is no Intel path on any operating system, and if one is ever added it would be Linux first, the way AMD was. |
| **Linux** | The installer looks for an NVIDIA or an AMD GPU, finds neither, and stops in the NVIDIA preflight. It is not a bug report — the machine has no GPU the node can use. |
| **Docker** | Not supported. The images require the NVIDIA Container Toolkit. |
| **Rewards** | An Intel card cannot register, so it cannot earn. Running the node on the CPU is not a supported node either. |

Nothing in the node reads an Intel device: there is no Intel branch in the GPU detection, no Intel
entry in the tier rules, no Intel pattern in the model catalog, and no Intel PyTorch wheel set. The
Controller has no admission rule for one.

---

## What supporting Intel would take

Listed so it is clear this is real work and not a switch waiting to be flipped. Roughly what the AMD
work needed, in the same order:

1. **A PyTorch wheel set for Intel GPUs** (the XPU/oneAPI stack), pinned the way
   `constraints/torch-cu124.txt` and `constraints/torch-rocm.txt` are pinned today, and proven to run
   the node's own workloads — including the 4-bit quantized path, which is what decides whether a
   small card is useful.
2. **Vendor detection and a preflight** — the Intel counterpart of `check-rocm-linux.sh`: the driver,
   the device nodes, the user's group membership, and a real "torch can see this card" probe, each
   failure naming its cure.
3. **Admission and tier rules**, keyed on whatever Intel's stable device identifier is — the
   counterpart of a CUDA compute capability or an AMD gfx target — plus the VRAM tiering and a reward
   multiplier the Timpi team has approved.
4. **Catalog patterns**, so an Intel node is offered the models that actually run on it and withheld
   the ones that do not.
5. **Measurement on real hardware.** AMD support shipped after a card was installed, admitted, paid
   and made to complete dispatched jobs end to end. Intel would need the same before it is announced.

---

## If you have an Intel card

Watch the release notes on [github.com/Timpi-official/Nodes](https://github.com/Timpi-official/Nodes).
There is no date, and no work in progress to report. Asking in Discord whether Intel is supported will
get you this same answer, so do not buy a card for Synaptron on the strength of a maybe — buy
[NVIDIA](NVIDIA.md), or [AMD](AMD.md) if you are on Linux and comfortable with ROCm.

---

*Placeholder page. Intel appears in Timpi's internal GPU tier chart as a note only — nothing is built,
and nothing is scheduled.*
