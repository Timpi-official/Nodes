# 🔎 Timpi Node Checkers

Check any Timpi node straight from Discord — **no login, no SSH, nothing to install**. Type a slash command,
paste your GUID, and the bot answers in seconds. Only you see the reply.

> 🌐 **Prefer a web page?** [**Node Monitor**](https://timpi.se/node-monitor.html) on the Timpi Explorer runs
> the same checks and shows them on one page instead of in a chat reply. Same data, same verdicts — pick
> whichever you like.

The checkers answer the question that actually matters: **is my node earning, and if not, what do I fix?**

---

## 📑 Table of Contents

* [The commands](#commands)
* [What you need](#need)
* [GeoCore](#geocore)
* [Guardian](#guardian)
* [Collector](#collector)
* [Synaptron](#synaptron)
* [What the verdicts mean](#verdicts)
* [Common results explained](#common)

---

<a id="commands"></a>

## The commands

| Command | Node | You provide |
|---|---|---|
| `/geocore` | GeoCore | GUID + inbound port (default `4013`) |
| `/guardian` | Guardian | GUID + Guardian port (default `4005`) |
| `/collector` | Collector | GUID |
| `/synaptronchecker` | Synaptron | GUID |

Type the command in Discord and a small form opens. Fill it in, press submit.

---

<a id="need"></a>

## What you need

**Your GUID** — find it in your dashboard at
[timpi.com/node/v2/management](https://timpi.com/node/v2/management), or read it off the machine:

```bash
sudo docker inspect <container-name> --format '{{range .Config.Env}}{{println .}}{{end}}' | grep GUID
```

**Your port** (GeoCore and Guardian only) — the inbound port your node advertises. If you used the install
script and pressed Enter at the port question, it's the default: `4013` for GeoCore, `4005` for Guardian.

> 💡 The checker compares what you type against the port **registered with Timpi**. If they differ it tells
> you — and that mismatch is itself a useful finding, because coordinators only ever use the registered one.

---

<a id="geocore"></a>

## 🛰️ GeoCore — `/geocore`

Fill in your **GUID** and **port**. You get back:

* **A verdict up top** — 🟢 EARNING, 🟡 ONLINE BUT NOT EARNING, 🔴 NOT EARNING …
* **📋 Bottom line** — plain language: what's happening, and the single next thing to do.
* **🛰️ Status (from TAP)** — heartbeat, region, NFT, address, join date, pages served, **version**, and
  answered/missed calls.
* **🖥️ Hardware** — CPU, RAM and disk, read live from the node.
* **Inbound port** — whether Timpi's coordinators can actually reach you.
* **DNS** — whether the required Timpi resolvers are configured.
* **GeoCores on this IP** — if you run several on one machine, it flags **port collisions**.

> ⚠️ **Two GeoCores on the same IP must not share a port.** Only one container can hold a port, so the others
> answer nothing and earn nothing — while TAP can still show them "alive". Give each its own `COMPORT` (plus
> a matching `-p` and router forward). The checker catches this; an install guide can't.

---

<a id="guardian"></a>

## 🛡️ Guardian — `/guardian`

Fill in your **GUID** and **Guardian port** (not the Solr port). You get back:

* **A verdict** — 🟢 EARNING, 🟡 NOT EARNING — PORT BLOCKED, 🟡 NOT YET SEEN ALIVE, 🔴 NOT FOUND.
* **📋 Bottom line** — what to do, if anything.
* **🛰️ Cluster view** — how many coordinators see it alive, region, NFT, **version**, Solr collections.
* **Ports** — both the Guardian port and the Solr port are tested.
* **DNS**, system load and uptime.

**Two things worth knowing about Guardians:**

* **Rewards come from uptime, not from search traffic.** A Guardian earns by answering the coordinator's
  pings on its **Guardian port**. Serving Solr queries is not what pays.
* **Not holding a Solr shard is normal** — most Guardians never get one, because shards are assigned manually
  by the Timpi team. It does **not** affect your rewards, and the checker says so rather than alarming you.
  For the same reason, a blocked **Solr** port is reported as information, not as a problem with your
  rewards — but a blocked **Guardian** port is, because that's the one the coordinator pings.

---

<a id="collector"></a>

## 📦 Collector — `/collector`

Fill in your **GUID** — no port, since Collectors don't accept inbound connections. You get back:

* **Status** — 🟢 ACTIVE / 🟡 STALE / 🔴 OFFLINE, from the real heartbeat.
* **Last Active** and its age, **Version**, NFT, wallet, region, DNS.
* **Connections** and **Workers**.

> 💡 **ACTIVE means the heartbeat is fresh — not that it's crawling.** To confirm work is flowing, ask the
> node itself:
> ```bash
> sudo docker logs timpi-collector --since 1h | grep -c "finished ok"
> ```
> Any number above 0 means it's crawling. A Collector can be up, reachable and still fetch nothing.

---

<a id="synaptron"></a>

## 🧠 Synaptron — `/synaptronchecker`

Fill in your **GUID**. Reports online state from the last-seen timestamp, plus tier, wallet, GPU tier, ping
counts, and how you rank against others in your tier.

---

<a id="verdicts"></a>

## What the verdicts mean

| Verdict | Meaning |
|---|---|
| 🟢 **EARNING** | Online, set up correctly, answering calls. Nothing to do. |
| 🟡 **ONLINE BUT NOT EARNING** | Running and talking to Timpi, but answering **no calls** — almost always a closed port. |
| 🟡 **NOT EARNING — PORT BLOCKED** | *(Guardian)* The coordinator can't reach your Guardian port, so you aren't counted as online. |
| 🟡 **NOT YET SEEN ALIVE** | *(Guardian)* Registered, but no coordinator lists it alive yet. Normal for a few minutes after starting. |
| 🟡 **SHARED PORT — CHECK SETUP** | *(GeoCore)* Several GeoCores on this IP use the same port. At most one of them earns. |
| 🟡 **CHECK CONNECTIVITY** | Answering calls, but the heartbeat is aging. Still earning — keep an eye on it. |
| 🔴 **NOT EARNING** | Not seen by any coordinator, or offline. Check the GUID first, then the container. |
| 🔴 **NOT FOUND** | The GUID isn't in the registry. Usually a typo — copy it from your dashboard. |
| ⚠️ **WRONG NODE TYPE** | This GUID is a different node type — use the matching checker. |
| ❔ **COULDN'T VERIFY** | Timpi's cluster couldn't be reached. Temporary — try again in a minute. |

---

<a id="common"></a>

## Common results explained

**"Port is OPEN, but TAP shows no calls being answered"**
Your port answers, but Timpi hasn't sent work yet. Usually a node that started recently — recheck later.

**"Port mismatch"**
The port you typed isn't the one registered with Timpi. Coordinators only ever use the **registered** port,
so if that one is closed you earn nothing even though the port you opened works fine. Fix the node's port
setting, or open the registered port.

**"Missing required Timpi DNS"**
Your container isn't using Timpi's resolvers. Recreate it with:
`--dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1`

**Hardware "couldn't be read"**
That section is read from your node directly, which needs your inbound port open. The **Status** section
still comes from Timpi's cluster and is authoritative — so this on its own does not mean your node is broken.

**Your version looks old**
See the auto-update section of your node's guide —
[GeoCore](https://github.com/Timpi-official/Nodes/blob/main/Geocore/README.md#s7-autoupdate) ·
[Guardian](https://github.com/Timpi-official/Nodes/blob/main/Guardian/Tutorial/GuardianDockerLinux.md#75-enable-auto-updates) ·
[Collector](https://github.com/Timpi-official/Nodes/blob/main/DockerCollector/Tutorial/LinuxDockerCollectorLatest.md#autoupdate).
One Watchtower keeps every Timpi node on the machine current.

---

**Built with ❤️ by the Timpi community**
Powering a free, decentralized internet 🌍

---
