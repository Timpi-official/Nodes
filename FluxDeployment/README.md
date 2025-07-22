# ⚡ Timpi Node Deployment Guide

**Deploy and run your Timpi Collector or Synaptron nodes using Flux infrastructure**

This guide walks you through two ways of deploying Timpi nodes:

* 🟢 **FluxCloud** – Beginner-friendly, fast deployment of **Collector Nodes** via the Flux Marketplace
* 🔵 **FluxEdge** – Customizable, advanced deployment for **Synaptron Nodes** and multiple **Collector Nodes**

---

## 📦 What’s Inside

* ✅ Step-by-step deployment walkthroughs
* 🖼️ Screenshots of every step
* 💳 Payment methods (Flux, Stripe, PayPal)
* 🧠 Synaptron GPU requirements
* 🔁 How to scale by adding Collectors

---

## 📂 Node Types Covered

| Node Type | FluxCloud | FluxEdge |
| --------- | --------- | -------- |
| Collector | ✅         | ✅        |
| Synaptron | ❌         | ✅        |

---

## 🟢 Method 1: Deploy a Timpi Collector Node via FluxCloud

### 🧩 Step 1: Launch the TimpiCollector App

1. Go to: [https://cloud.runonflux.com](https://cloud.runonflux.com)

2. Click **Sign In**, and log in via:

   * Google
   * Apple
   * Zelcore
   * Email

   ![](https://github.com/user-attachments/assets/6b93db8a-e405-4edf-a33a-0a5fca9d48d6)

3. On the sidebar: **Marketplace → Blockchain**
   
   ![](https://github.com/user-attachments/assets/8cb1a64c-f0ae-43b6-baad-8f7e0869b85e)

5. Search for `TimpiCollector` → click **View App**
   
   ![](https://github.com/user-attachments/assets/e803a831-669a-4578-9bd7-67f92cd32710)

6. Choose a plan, adjust specs if needed → click **Next**
   💡 Higher compute = higher monthly cost

   ![](https://github.com/user-attachments/assets/2f7c0145-1acb-4a67-8847-4dfb695c2bcf)

7. Optional: set geolocation filters → **Next**
   
   ![](https://github.com/user-attachments/assets/55d38c42-b299-4095-9337-6ea13e708df6)

8. Enter your **email** for alerts → **Next**
   
   ![](https://github.com/user-attachments/assets/418f8759-8b6f-41cf-8596-178cfebc1a1c)

9. Click **Launch App**
   
   ![](https://github.com/user-attachments/assets/c47ceb2e-a5f5-4a06-83d9-73ba631bf73b)

10. Select payment method:

   * 💳 Stripe
   * 🅿️ PayPal
   * 🔷 Flux (🎁 5% discount!)
     
     ![](https://github.com/user-attachments/assets/af2f2ed1-5ba9-4754-b8ad-4261c910d785)

11. Click **Next → Finish**
    🕒 Deployment takes **10–30 minutes**

---

### 🔧 Step 2: Configure Your Node

1. Go to **My Apps → Active Apps**

2. Click **App Details**
   
   ![](https://github.com/user-attachments/assets/ef9cedf8-8d85-4ffa-a98b-8c08260ea9af)

4. Click the app’s **Auto-domain URL**

5. Set:

   * **Wallet Address** *(must hold a Timpi NFT)*
   * **Number of Workers**
   * Click **Save**
     
     ![](https://github.com/user-attachments/assets/b6c97357-eade-4d0d-9659-81c54fc1ad54)
     
     ![](https://github.com/user-attachments/assets/2ae1f04b-ca99-4493-987a-99c28c36be83)

6. Click the **Collector** tab
   ✅ Your node is now indexing
 
   ![](https://github.com/user-attachments/assets/b300a71f-f639-4719-85f8-5b4dc83e3856)

---

### 🔁 Manage or Renew Subscription

1. Go to [https://cloud.runonflux.io](https://cloud.runonflux.io)

2. Go to **My Apps → Active Apps**

3. Click **App Details**
   
   ![](https://github.com/user-attachments/assets/e4e9541e-a183-4f5c-bbca-9887fc6b99ff)

5. Click **Update App**
   
   ![](https://github.com/user-attachments/assets/5af685a1-523b-4549-8850-21f78b1a7dbc)

6. Enable **Subscription Plan**, choose duration → **Finish → Renew App**
   
   ![](https://github.com/user-attachments/assets/284a02bf-c278-43e6-87cb-0562be7430fc)

7. Choose payment method
   
   ![](https://github.com/user-attachments/assets/b090df6b-ef38-4488-a6cd-d613f8fa1fd4)

---

## 🔵 Method 2: Deploy a Timpi Node via FluxEdge

### 🧠 Step 1: Deploy a Synaptron Node

1. Go to: [https://console.fluxedge.ai](https://console.fluxedge.ai)

2. Sign in or create an account
   
   ![](https://github.com/user-attachments/assets/7c17857d-ae3b-46ca-97b9-24e1a2fe9c2c)

4. Go to **Account Overview**, deposit funds via:

   * 💳 Card
   * 🅿️ PayPal
   * 🔷 Flux (🎁 5% bonus)
     
     ![](https://github.com/user-attachments/assets/8f656ec4-ae82-4dd7-bc04-177e1fbf1ddd)

5. Click **Deploy App → Explore All Templates**

6. Search for **Timpi Synaptron** → click it

7. Optionally read README → click **Builder** or **Continue**
   
   ![](https://github.com/user-attachments/assets/29310fab-8387-4d6f-9299-10dc8a20848e)

8. Under **Environment Variables**, add:

   * `NAME` (min 17 characters)
   * `GUID`: [Get one here](https://timpi.com/node/register)
     
     📘 [Setup Guide (Linux)](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/Tutorial/SynaptronLinux.md)

9. Adjust machine specs or keep default
   
   ![](https://github.com/user-attachments/assets/a2741fba-eef8-4d41-be23-760f4ad9a7d4)

10. Click **Rent Machine**, use filters (location, GPU, etc)
    
   ![](https://github.com/user-attachments/assets/1b89d44e-9ded-4a88-b091-b492eadba932)

11. Click **Rent**, then confirm
    
    ![](https://github.com/user-attachments/assets/3cb78b2a-4d5b-412b-b0ca-909679538691)

12. After deployment, your dashboard shows:

* Runtime & costs
* Logs and shell
* Event monitor
  
  ![](https://github.com/user-attachments/assets/b398fe00-34ee-400c-9c50-8712156efa09)

---

### ➕ Step 2: Add Collector Nodes on Same Machine

Take full advantage of your machine's resources by running **multiple Timpi Collector nodes** with your Synaptron.

1. In your machine list, click `⋮` → **+ New Deployment**

2. Search for `Timpi Collector` → click it

3. Click **Builder** or **Continue**

4. Adjust specs → click **Deploy App**

5. Wait for **Running** status

6. Open the app URL
   → Go to **Settings**, enter:

   * **Timpi Wallet Address** (holding NFT)
   * **Number of Workers**
   * Click **Save**
     
     ![](https://github.com/user-attachments/assets/d14a5993-382e-414b-8e90-82d6557500ef)

7. Switch to **Collector** tab
   ✅ Your new collector starts indexing
   
   ![](https://github.com/user-attachments/assets/e8cdf91d-539a-4714-9dad-e9067fc04b9a)

---

## 🧠 Why Add Collectors with Synaptron?

If you're already paying for a Synaptron GPU machine, it's **highly recommended** to deploy multiple Collectors on the same host.
More Collectors = More indexing power using the same resources. ⚙️💡

---

## 💬 Need Help?

Join the [**Timpi Discord**](https://discord.com/channels/946982023245992006/1179480018292850830) for:

* Tech support
* Updates from the team

📢 Let’s build the decentralized search engine of the future — together.
