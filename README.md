# 🧠 Timpi Nodes – All Node Types & Installers

![Last Commit](https://img.shields.io/github/last-commit/Timpi-official/Nodes)

Welcome to the official repository for **Timpi Node installations**.  
Here you'll find everything you need to run Timpi’s decentralized infrastructure – from lightweight collectors to powerful AI-powered Synaptrons.

We provide:
- ✅ Easy-to-follow installation scripts  
- 🛠️ Regular updates for all node types  
- 📁 Organized directories by node function

---

## 📝 [Node Registration Guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)

Before you can run a Timpi node you must **register your Node Access NFT** and receive your unique `GUID`.  
This applies to **Collector**, **Guardian**, **Geocore** and **Synaptron** Node Access NFTs.

> ℹ️ **Exception:** *Collector Hero* and *Collector Champion* NFTs don't need registration.

👉 See the [Registration Guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md) for full instructions and screenshots.

---

## 🔍 [Node Checker Guide](https://github.com/Timpi-official/Nodes/blob/main/NodeCheckers/NodeCheckers.md)

Want to know whether your node is online **and earning**? Type a Discord slash command, paste your GUID, and
the bot answers in seconds — no login, no SSH. Only you see the reply.

| Command | Node | You provide |
|---|---|---|
| `/geocore` | GeoCore | GUID + port |
| `/guardian` | Guardian | GUID + port |
| `/collector` | Collector | GUID |
| `/synaptronchecker` | Synaptron | GUID |

👉 See the [Node Checker Guide](https://github.com/Timpi-official/Nodes/blob/main/NodeCheckers/NodeCheckers.md) for what each reply means, and what to do when it isn't green.

---

## 🗂 Node Types

Each link goes straight to that node's install guide.

1. 🔄 **[Collector](https://github.com/Timpi-official/Nodes/blob/main/Collector/guides/LinuxDocker.md)**  
   Collectors are decentralized "workers" that crawl the web, collecting information about websites and their
   pages. They stay invisible to front-end services, which keeps them secure.
   *Docker is the supported install, and [Windows](https://github.com/Timpi-official/Nodes/blob/main/Collector/guides/Windows.md)
   has a native v2 build. The [native Linux build](https://github.com/Timpi-official/Nodes/blob/main/Collector/legacy/LinuxNative-retired.md)
   is retired — migrate to Docker.*

2. 🛡️ **[Guardian](https://github.com/Timpi-official/Nodes/blob/main/Guardian/guides/LinuxDocker.md)**  
   Guardians are distributed storage nodes that archive the web, safeguarding what Collectors gather. They need
   no static IP, and rewards are based on uptime.

3. 🧬 **[Synaptron](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/README.md)**  
   Timpi's AI node. It reasons over the data the network gathers — running local AI models to generate and
   refine answers. Needs an NVIDIA GPU.
   *Runs as a native node runner — see the
   [Linux](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/guides/Linux.md) and
   [Windows](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/guides/Windows.md) guides.*

4. 🌍 **[Geo-Core](https://github.com/Timpi-official/Nodes/blob/main/Geocore/README.md)**  
   Geo-Cores sit worldwide, enabling fast, location-aware routing for accurate and efficient data queries. They
   are the backbone for global indexing and query distribution.

5. ☁️ **[Flux Deployment](https://github.com/Timpi-official/Nodes/blob/main/FluxDeployment/README.md)**  
   Use **FluxCloud** and **FluxEdge** to deploy Collector or Synaptron nodes in a few clicks.

---

## 🌐 Timpi Explorer — [timpi.se](https://timpi.se)

A web dashboard for the Timpi network and the Neutaro chain. Nothing to install — just open it.

**For node operators:** 👉 **[Node Monitor](https://timpi.se/node-monitor.html)** is the web version of the
Discord [Node Checkers](https://github.com/Timpi-official/Nodes/blob/main/NodeCheckers/NodeCheckers.md).
Paste your GUID and it shows the same checks — reachability, ports, DNS, hardware, version and whether you're
earning — laid out on one page instead of in a chat reply.

The rest of the explorer:

| Page | What it shows |
|---|---|
| [Dashboard](https://timpi.se/index.html) | Network overview at a glance |
| [Validators](https://timpi.se/validator.html) | Validator list, details and [uptime](https://timpi.se/validator-uptime.html) |
| [Governance](https://timpi.se/governance.html) | Proposals and voting |
| [Params](https://timpi.se/param.html) | Live chain parameters |
| [Transactions](https://timpi.se/transaction.html) | Search and inspect transactions |
| [Wallet Explorer](https://timpi.se/wallet.html) | Look up any address |
| [Portfolio](https://timpi.se/portfolio.html) | Your holdings across the network |
| [Send](https://timpi.se/send.html) · [Stake](https://timpi.se/stake.html) | Transfer and stake $NTMPI |
| [Marketplace](https://timpi.se/marketplace.html) | Node NFT marketplace |

---

## 📊 [Node Reward Structures](https://github.com/Timpi-official/Nodes/blob/main/Rewards/RewardStructures.md)

Guaranteed minimum reward pools per node type, by period.

👉 See the [Reward Structures](https://github.com/Timpi-official/Nodes/blob/main/Rewards/RewardStructures.md) page for the full tables.

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

## 🤝 Contributing

Have a fix or idea for improvement? Pull requests are welcome!  
For larger changes, please [open an issue](https://discord.com/channels/946982023245992006/1179427377844068493) to discuss it with us first.
