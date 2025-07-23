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

  <img width="2540" height="1296" alt="Screenshot 2025-07-23 164538" src="https://github.com/user-attachments/assets/644c1375-fc81-4f2a-a294-dbf26c87ca44" />


3. On the sidebar: **Marketplace → Blockchain**
   
   <img width="2543" height="1207" alt="Screenshot 2025-07-23 164216" src="https://github.com/user-attachments/assets/3e00504b-8eb4-4ea7-b12f-aeee0cd67458" />


5. Search for `TimpiCollector` → click **View App**
   
 <img width="2228" height="685" alt="Screenshot 2025-07-23 163422" src="https://github.com/user-attachments/assets/a8bee71b-4e31-4c06-aade-3a564deae5d8" />


6. Choose a plan, adjust specs if needed → click **Next**
   💡 Higher compute = higher monthly cost

  <img width="2211" height="982" alt="Screenshot 2025-07-23 163439" src="https://github.com/user-attachments/assets/d429c01a-a9e6-4125-9074-a2f55d2a50b5" />


7. Optional: set geolocation filters → **Next**
   
   <img width="1163" height="580" alt="Screenshot 2025-07-23 163508" src="https://github.com/user-attachments/assets/41d4d7b2-0dcf-4b36-8d94-6559d32c8946" />


8. Enter your **email** for alerts → **Next**
   
   <img width="1151" height="576" alt="Screenshot 2025-07-23 163644" src="https://github.com/user-attachments/assets/90bc0f81-6198-403b-b436-e131cf33132d" />


9. Click **Launch App**
   
  <img width="1175" height="628" alt="Screenshot 2025-07-23 163740" src="https://github.com/user-attachments/assets/bba1e804-f5af-4f66-b0a1-64ba17f46291" />


10. Select payment method:

   * 💳 Stripe
   * 🅿️ PayPal
   * 🔷 Flux (🎁 5% discount!)
     
     <img width="1155" height="578" alt="Screenshot 2025-07-23 163755" src="https://github.com/user-attachments/assets/90f14d73-8d82-4e7f-bb09-bc853f3a4b9d" />


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
   
   <img width="2545" height="1303" alt="Screenshot 2025-07-23 164757" src="https://github.com/user-attachments/assets/106cc660-0b5c-47dc-86bd-0e1b58d4c41b" />


4. Go to **Account Overview**, deposit funds via:

   * 💳 Card
   * 🅿️ PayPal
   * 🔷 Flux (🎁 5% bonus)
     
     <img width="2545" height="1134" alt="Screenshot 2025-07-23 165034" src="https://github.com/user-attachments/assets/3e76fd06-4802-4e6e-b2f5-238ca8d46383" />


5. Click **Deploy App → Explore All Templates**

6. Search for **Timpi Synaptron** → click it

7. Optionally read README → click **Builder** or **Continue**
   
   <img width="2544" height="940" alt="Screenshot 2025-07-23 165410" src="https://github.com/user-attachments/assets/da4c48aa-56bb-46da-b56e-3c44b8812489" />


8. Under **Environment Variables**, add:

   * `NAME` (min 17 characters)
   * `GUID`: [Get one here](https://timpi.com/node/register)
     
     📘 [Setup Guide (Linux)](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/Tutorial/SynaptronLinux.md)

9. Adjust machine specs or keep default
   
 <img width="2536" height="914" alt="Screenshot 2025-07-23 165322" src="https://github.com/user-attachments/assets/84625d5b-8252-4373-8303-ff89b3485fde" />


10. Click **Rent Machine**, use filters (location, GPU, etc)
    
  <img width="2559" height="1159" alt="Screenshot 2025-07-23 165631" src="https://github.com/user-attachments/assets/7e421592-5752-4d17-b618-88b8bee42d72" />


11. Click **Rent**, then confirm
    
<img width="1240" height="1077" alt="Screenshot 2025-07-23 170155" src="https://github.com/user-attachments/assets/8400e665-c22b-4dfa-839a-1657f4f56f5c" />


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
