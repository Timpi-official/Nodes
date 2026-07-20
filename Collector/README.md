# 🔄 Timpi Collector — Docker

**This is the supported way to run a Collector.** It's the only Collector build that receives updates.

👉 **[Linux Docker Collector Guide](https://github.com/Timpi-official/Nodes/blob/main/Collector/guides/LinuxDocker.md)**

---

## What a Collector does

Collectors are the network's "workers": they crawl the web and collect information about websites and their
pages, which Guardians then store and the search engine serves. They stay invisible to front-end services,
which keeps them secure — and they need **no inbound port**, so there's nothing to forward on your router.

## What you need

* A machine with Docker (Ubuntu is what the guide covers)
* Your **GUID** from [timpi.com/node/v2/management](https://timpi.com/node/v2/management)

That's it. No GPU, no static IP, no open ports.

## Keeping it updated

The Collector does **not** update itself. Run **Watchtower** once and it stays current automatically — one
Watchtower covers every Timpi node on the machine. See
[§8 of the guide](https://github.com/Timpi-official/Nodes/blob/main/Collector/guides/LinuxDocker.md#autoupdate).

## Checking it works

* **In Discord:** `/collector <your-guid>` — see [Node Checkers](https://github.com/Timpi-official/Nodes/blob/main/NodeCheckers/NodeCheckers.md)
* **On the web:** [Node Monitor](https://timpi.se/node-monitor.html) on the Timpi Explorer
* **On the machine** — the check that actually matters, is it crawling:
  ```bash
  sudo docker logs timpi-collector --since 1h | grep -c "finished ok"
  ```
  Any number above 0 means work is flowing. A Collector can be "running" and still fetch nothing.

## Other install paths

* **[Native Linux (systemd)](https://github.com/Timpi-official/Nodes/blob/main/Collector/legacy/LinuxNative-retired.md)** — ⚠️ retired, no longer updated. Migrate to Docker.
* **[Windows](https://github.com/Timpi-official/Nodes/blob/main/Collector/guides/Windows.md)** — ⏳ coming soon; the current download predates the latest version and won't qualify for rewards.
* **[Flux](https://github.com/Timpi-official/Nodes/blob/main/FluxDeployment/CollectorFluxDeployment.md)** — deploy on FluxCloud/FluxEdge.

---

**Built with ❤️ by the Timpi community**
Powering a free, decentralized internet 🌍
