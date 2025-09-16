# 🌐 Timpi Node Deployment Guide

This guide covers two separate methods for deploying Timpi Nodes:

---

* 🟢 [FluxCloud](#-part-1-deploying-a-timpi-collector-or-geocore-node-via-fluxcloud) – Simplified and affordable deployment of **Collector** and **Geocore** Nodes via the Flux Marketplace.

  * [Step 1: Install the TimpiCollector App](#-step-1-install-the-timpicollector-app)
  * [App Configuration](#app-configuration)
  * [Sign & Register](#-sign--register)
  * [Step 2: Configure Your Collector Node](#step-2-configure-your-collector-node)
  * [Updates on Flux (Watchtower & Redeploy)](#-updates-on-flux-watchtower--redeploy)
  * [Updating Your App Subscription](#-updating-your-app-subscription)

* 🔵 [FluxEdge](#-part-2-deploying-timpi-node-via-fluxedge) – Advanced and customizable infrastructure for deploying **Synaptron** and **Collector** Nodes.

  * [Step 1: Deploy a Synaptron Node](#-step-1-deploy-a-synaptron-node)
  * [Step 2: Add Collector Nodes (Same Machine)](#-step-2-add-collector-nodes-same-machine)

* 🙋 [Community & Support](#-community--support)

---

## 🚀 Part 1: Deploying a Timpi Collector or Geocore Node via FluxCloud

### 🧩 Step 1: Install the TimpiCollector App

1. **Visit** [home.runonflux.com](http://home.runonflux.com)

2. **Sign in or create an account** with:

   * Apple ID
   * Google
   * Email
   * Zelcore / SSP / MetaMask / other Web3 wallets
     ![](https://github.com/user-attachments/assets/27a010ce-74a9-473b-9080-5125ed2991d5)

3. Go to **Applications → Marketplace**
   → Search for **TimpiCollector** or **TimpiGeoCore** and click the desired app.
   ![](https://github.com/user-attachments/assets/025047db-a6ac-4d7b-9830-2baeae5b2480)

---

### App Configuration

#### 🟢 **TimpiCollector**

1. Enter your email (optional)
2. Select subscription period
3. Agree to the Terms of Service
4. Click **Start Launching Marketplace Application**
   ![](https://github.com/user-attachments/assets/f8a48e8b-905e-4b1a-a964-8b188eaedcfd)

#### 🔵 **TimpiGeoCore**

1. Enter your email (optional)
2. Select subscription period
3. Enter your registered **GUID**
4. Agree to the Terms
5. Click **Start Launching Marketplace Application**
<img width="1435" height="805" alt="Skärmavbild 2025-08-13 kl  13 32 51" src="https://github.com/user-attachments/assets/996585d1-2fd0-4be4-bf83-8f3a3432cf11" />

---

### ✅ Sign & Register

5. Click **Next** on the registration confirmation screen
   ![](https://github.com/user-attachments/assets/7deace26-5339-499d-aaa3-8ffa9083d26b)

6. **Sign the message** depending on login method:

   * Web3 Wallet: Click wallet icon
   * Email Login: Click Flux SSO/Email
     → Once auto-filled, click **Next**
     ![](https://github.com/user-attachments/assets/70011e19-9687-46ca-b064-fb11c7c60f85)

7. Confirm **Total Price + VAT** → click **Register**
   → Green ✅ **DONE!** confirms successful broadcast
   ![](https://github.com/user-attachments/assets/6778f235-b45c-4ec4-8551-3c09ff2dbe23)

8. Choose payment method:

   * 💳 Stripe
   * 🅿️ PayPal
   * 🔷 Flux (5% discount)
     ![](https://github.com/user-attachments/assets/1e9c0ec0-8a80-44ee-9bb1-fb6efe0e4ebd)

9. Click **Done**, then **Yes**
   🕒 Deployment time: **10–30 minutes**

---

### Step 2: Configure Your Collector Node

1. Go to **Applications → Management → My Active Apps**
   → Click **Manage**, then confirm
   ![](https://github.com/user-attachments/assets/f5271e09-8ea4-4f85-bd77-06b96349477e)

2. **FluxCloud runs 3 instances**
   → You can run **up to 3 Collector Nodes** per deployment.

3. Open the **Running Instances** tab
   → Click the **App** button next to any IP
   ![](https://github.com/user-attachments/assets/65e8943a-31b0-4832-b808-2548eeee975b)

4. In the node interface:

   * Click ⚙️ **Settings**
   * Enter your **Timpi Wallet Address** (must hold NFT)
   * Set **Number of Workers** (1–5)
   * Click **Save**
     ![](https://github.com/user-attachments/assets/91e3f515-7e75-47ba-a2d1-c72e510469ac)

5. Go to the **Collector** tab
   ✅ Your node starts indexing
   ![](https://github.com/user-attachments/assets/44ca58a4-71af-4579-8e1d-b6d455ab7ef5)

📝 **Note:** FluxCloud may rotate server IPs. If redeployed, repeat steps 3–5 on the new IP.

---

### 🔄 Updates on Flux (Watchtower & Redeploy)

When you run your Collector or Geocore node on **Flux Cloud**, you do **not** need to manually update the container.

Flux includes a built-in tool called **Watchtower**, which:

* Monitors your running containers
* Detects when a new image is available
* Automatically restarts your container with the updated version

📌 This means your node will always stay up to date without you doing anything.

⚠️ Because Flux runs across thousands of decentralized servers worldwide, the update rollout can take **up to 10 hours** before all instances refresh.

If you want to update faster, you can trigger a redeploy:

1. Log in to [home.runonflux.io](https://home.runonflux.io) with your ZelID
2. Go to **Apps → Global Apps → My Apps**
3. Select your app → **Manage → Manage App**
4. In the left menu, click **Global Control**
5. Under **Redeploy**, choose:

   * **Soft Redeploy** → redeploy with data preserved
   * **Hard Redeploy** → redeploy from scratch (container data wiped)

More info:
👉 [Flux Cloud Watchtower Docs](https://help.runonflux.io/docs/the-flux-cloud-watchtower/)

---

### 🔁 Updating Your App Subscription

Log in to [home.runonflux.com](https://home.runonflux.com)

Go to **Applications → Management → My Active Apps** → Click **Manage**

... *(and your existing steps follow here)*

---

### 🔁 Updating Your App Subscription

1. Log in to [home.runonflux.com](https://home.runonflux.com)

2. Go to **Applications → Management → My Active Apps**
   → Click **Manage**

3. Open the **Update/Renew** tab:

   * Toggle on **Extend Subscription**
   * Keep **Update Specifications** toggled **off**
   * Select duration
   * Accept ToS
   * Click **Compute Update Message**
     ![](https://github.com/user-attachments/assets/dd1c6010-6b0a-4bf5-9b75-4dc539665386)

4. **Sign the message** using your login method
   → Then click **Update Application**
   ![](https://github.com/user-attachments/assets/74fba599-0207-4d7d-a52b-1fc2f9444351)

5. Choose payment method and complete
   ![](https://github.com/user-attachments/assets/97613910-a2ba-47a4-8777-3fa7bb5fff21)

---

## 💻 Part 2: Deploying Timpi Node via FluxEdge

### 🧠 Step 1: Deploy a Synaptron Node

1. Go to [https://console.fluxedge.ai](https://console.fluxedge.ai)
   → Sign in or sign up
   ![](https://github.com/user-attachments/assets/c48a6647-940d-4b32-b284-bccc24733bdd)

2. Deposit funds under **Account Overview**

   * 💳 Stripe / Card
   * 🅿️ PayPal
   * 🔷 Flux (5% bonus)
     ![](https://github.com/user-attachments/assets/9e4c56b8-8dbe-4380-8339-0be696dc5bf2)

3. Click **Deploy App → Explore All Templates**

4. Search for **Timpi Synaptron** and click the app

5. (Optional) Read README → click **Builder** or **Continue**
   ![](https://github.com/user-attachments/assets/418249c4-25fa-422f-87ba-2fa63c7a61ea)

6. Add required **Environment Variables**:

   * `NAME` (min. 17 characters)
   * `GUID` → [Get it here](https://timpi.com/node/register)
     📘 [How to set up GUID (Linux)](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/Tutorial/SynaptronLinux.md)

7. Adjust resources (or use defaults)
   ![](https://github.com/user-attachments/assets/6011c5b7-ba7b-4421-8a45-c31219680c26)

8. Click **Rent Machine**
   → Use filters like GPU, RAM, location, etc.
   ![](https://github.com/user-attachments/assets/07be5908-f10b-40a8-b7a0-b5227a3fb11e)

9. Select a machine → click **Rent** and confirm
   ![](https://github.com/user-attachments/assets/e7541468-b19a-4731-9d96-1a64f8e03ca8)

10. After deployment, your Synaptron Dashboard provides:

* App URL, cost, runtime
* Logs, shell, monitoring
  ![](https://github.com/user-attachments/assets/59896e32-5d17-47ce-b345-bcff562cbe97)

---

### ➕ Step 2: Add Collector Nodes (Same Machine)

To maximize value, add **Collector Nodes** to your Synaptron machine:

1. On your machine row, click `⋮` → **+ New Deployment**

2. Click **Explore All Templates** → search `Timpi Collector`

3. (Optional) Read README → click **Builder** or **Continue**

4. Adjust resources → click **Deploy App**

5. Wait for status **Running** → click **App URL**

6. In the app:

   * Go to ⚙️ **Settings**
   * Enter **Timpi Wallet Address** (must hold NFT)
   * Set **Workers** (1–5)
   * Click **Save**
     ![](https://github.com/user-attachments/assets/7ee5798e-7b8e-4915-b45d-2cb9d529dfcf)

7. Go to the **Collector** tab
   ✅ Indexing starts
   ![](https://github.com/user-attachments/assets/b86e19fd-7d37-417c-a581-ce3c16b82d4c)

---


## 🙋 Community & Support

* 💬 Ask questions in the [**Timpi Discord Channel**](https://discord.com/channels/946982023245992006)
* 🛠️ Get help in [**#Create a support Ticket**](https://discord.com/channels/946982023245992006/1179427377844068493)
* 📚 Generic Flux help: [**RunOnFlux Help Center**](https://help.runonflux.io/)
* 🧾 Submit a ticket via [**Flux Support Portal**](https://support.runonflux.io/support/home)

---

**Built with 🧠 by the Timpi community**
*Empowering a faster, fairer, and decentralized internet 🌍*
