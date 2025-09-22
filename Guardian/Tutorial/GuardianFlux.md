# ⚡ Timpi Node Deployment Guide
**Deploy and run your Timpi Collector or Synaptron nodes using Flux infrastructure**

This guide walks you through two ways of deploying Timpi nodes:

🟢 **FluxCloud** – Beginner-friendly, fast deployment of Collector Nodes via the Flux Marketplace

🔵 **FluxEdge** – Customizable, advanced deployment for Synaptron Nodes and additional Collector Nodes


# 📑 Table of Contents

  * [🟢 Method 1: Deploy a Timpi Collector Node via FluxCloud](#-method-1-deploy-a-timpi-collector-node-via-fluxcloud)

    * [Step 1: Install the TimpiCollector App](#install-the-timpicollector-app)
    * [Step 2: Configure Your Node](#step-2-configure-your-node)
    * [Updating Your App Subscription](#updating-your-app-subscription)
  * [🔵 Method 2: Deploy a Timpi Node via FluxEdge](#step-1-deploy-a-timpi-synaptron-node)

    * [Step 1: Deploy a Timpi Synaptron Node](#step-1-deploy-a-timpi-synaptron-node)
    * [Step 2: Add Timpi Collector Nodes (Same Machine)](#step-2-add-timpi-collector-nodes-same-machine)

---


# 🟢 Method 1: deploy a timpi collector node via fluxcloud

### Install the timpicollector App

Visit https://cloud.runonflux.com/
3. Click Sign In and sign in or up using
    
Google Account
 
Apple
 
Zelcore
 
E-mail Address

<img width="609" height="264" alt="Screenshot 2025-07-22 180001" src="https://github.com/user-attachments/assets/6b93db8a-e405-4edf-a33a-0a5fca9d48d6" />

 
  3. Once signed in Go to Marketplace → Blockchain using the left handed menu.
 
<img width="600" height="283" alt="Screenshot 2025-07-22 180226" src="https://github.com/user-attachments/assets/8cb1a64c-f0ae-43b6-baad-8f7e0869b85e" />

 4. Search for the TimpiCollector App and click View App to review the README section (optional) or directly on Install Now.

<img width="592" height="257" alt="Screenshot 2025-07-22 180323" src="https://github.com/user-attachments/assets/e803a831-669a-4578-9bd7-67f92cd32710" />

 5 Select your subscription plan, and adjust resources if desired. Any increase from the recommended Compute resources will affect pricing. Once everything here is specified click Next.

<img width="604" height="243" alt="Screenshot 2025-07-22 180719" src="https://github.com/user-attachments/assets/2f7c0145-1acb-4a67-8847-4dfb695c2bcf" />

 6. On the next screen you can adjust Geolocation Allowed/Forbidden (recommended: leave default). Click Next.

<img width="606" height="240" alt="Screenshot 2025-07-22 180847" src="https://github.com/user-attachments/assets/55d38c42-b299-4095-9337-6ea13e708df6" />


 7. Now you can provide an email for expiration reminders. After you provided your email address, click on Next.

<img width="602" height="278" alt="Screenshot 2025-07-22 180933" src="https://github.com/user-attachments/assets/418f8759-8b6f-41cf-8596-178cfebc1a1c" />

 8. Click on the Launch App button.

<img width="602" height="192" alt="Screenshot 2025-07-22 181010" src="https://github.com/user-attachments/assets/c47ceb2e-a5f5-4a06-83d9-73ba631bf73b" />

 9. Choose the payment method you want to use to pay for this app. We support Stripe (Card), PayPal, and Flux. Paying in Flux gives a 5% discount.

<img width="602" height="280" alt="Screenshot 2025-07-22 181059" src="https://github.com/user-attachments/assets/af2f2ed1-5ba9-4754-b8ad-4261c910d785" />

 10. Once paid, click on Next, and then Finish. Your Timpi Collector node will now deploy — typically within 10–30 minutes.

## Step 2: Configure Your Node
1. Go to **My Apps → Active Apps**
2. Click App Details for your TimpiCollector

<img width="590" height="345" alt="Screenshot 2025-07-22 181236" src="https://github.com/user-attachments/assets/ef9cedf8-8d85-4ffa-a98b-8c08260ea9af" />

3. Click any **Auto-domain** URL
4. In the new opened tab, click the **Settings icon**. Then enter your **Timpi Wallet address** (must hold a
Timpi NFT), and set the Number **of Workers** from to , and save it by clicking the **Save** button.

<img width="604" height="352" alt="Screenshot 2025-07-22 181409" src="https://github.com/user-attachments/assets/b6c97357-eade-4d0d-9659-81c54fc1ad54" />

<img width="604" height="351" alt="Screenshot 2025-07-22 181431" src="https://github.com/user-attachments/assets/2ae1f04b-ca99-4493-987a-99c28c36be83" />

5.  Go back to the **Collector tab** in the header. Your node should now begin **indexing pages.**

<img width="604" height="352" alt="Screenshot 2025-07-22 181518" src="https://github.com/user-attachments/assets/b300a71f-f639-4719-85f8-5b4dc83e3856" />

## Updating Your App Subscription
1. Log in to https://cloud.runonflux.io/
2. Navigate to **My Apps → Active Apps.**
3. Click **App Details** on your TimpiCollector application.

   <img width="587" height="341" alt="Screenshot 2025-07-22 181701" src="https://github.com/user-attachments/assets/e4e9541e-a183-4f5c-bbca-9887fc6b99ff" />

4. Click on the **Update App** button.

   <img width="598" height="351" alt="Screenshot 2025-07-22 181804" src="https://github.com/user-attachments/assets/5af685a1-523b-4549-8850-21f78b1a7dbc" />

5. Toggle on **Subscription Plan**, and choose your desired **duration**, then click on the **Finish** navigation tab
at the top
6. Click on the **Renew App** button.

<img width="599" height="347" alt="Screenshot 2025-07-22 181936" src="https://github.com/user-attachments/assets/284a02bf-c278-43e6-87cb-0562be7430fc" />

7. Choose the payment method you want to use to pay for this app. We support Stripe (Card), PayPal,
and Flux. Paying in Flux gives a 5% discount.

<img width="605" height="359" alt="Screenshot 2025-07-22 182008" src="https://github.com/user-attachments/assets/b090df6b-ef38-4488-a6cd-d613f8fa1fd4" />

## 2 deploying a timpi node via fluxedge

### Step 1 deploy a timpi synaptron node
1. Visit https://console.fluxedge.ai/
2. Sign in or sign up.

<img width="605" height="360" alt="Screenshot 2025-07-22 182144" src="https://github.com/user-attachments/assets/7c17857d-ae3b-46ca-97b9-24e1a2fe9c2c" />

3. Navigate to the Account Overview using the left handed menu to deposit funds. We support PayPal,
Credit Cards, or Flux. If you deposit via Flux you will receive a 5% bonus.

<img width="604" height="348" alt="Screenshot 2025-07-22 182220" src="https://github.com/user-attachments/assets/8f656ec4-ae82-4dd7-bc04-177e1fbf1ddd" />

4. Once your account is funded, click **Deploy App**, and on **Explore All Templates** at the Quick launch
section.
5. Search for **Timpi Synaptron**, and click on it on the application
6. Read the README if you want to learn more about how the application works. Continue the deployment
process by clicking on the **Builder** tab or **Continue** button to configure your application specifications.

<img width="596" height="350" alt="Screenshot 2025-07-22 182419" src="https://github.com/user-attachments/assets/29310fab-8387-4d6f-9299-10dc8a20848e" />

7. At Environment Variables enter both a NAME (min. 17 characters), and your GUID https://timpi.com/node/register
- Learn more on how to setup your GUID at https://github.com/Timpi-official/Nodes/blob/main/Synaptron/Tutorial/SynaptronLinux.md
8. Adjust the resources as needed (or keep recommended)

  <img width="607" height="350" alt="Screenshot 2025-07-22 182632" src="https://github.com/user-attachments/assets/a2741fba-eef8-4d41-be23-760f4ad9a7d4" />

  9. Click the Rent Machine button to choose the machine you want to deploy your Timpi Synaptron node
on. You can use filters like GPU model, location, or price range, or even Advanced Filter (RAM, storage,
etc.) to choose a machine. You can also click a Machine ID to view details & reviews

<img width="602" height="262" alt="Screenshot 2025-07-22 182724" src="https://github.com/user-attachments/assets/1b89d44e-9ded-4a88-b091-b492eadba932" />

10. Select the machine you want to rent and then click the Rent button, and confirm the deployment in the
popup.

<img width="606" height="431" alt="Screenshot 2025-07-22 182813" src="https://github.com/user-attachments/assets/3cb78b2a-4d5b-412b-b0ca-909679538691" />

10. You will get forwarded to your Synaptron Node deployment overview, where you will have access to all
the necessary information of your application, like:
- URL, runtime, cost
- Access logs and shell
- Monitor events

<img width="604" height="220" alt="Screenshot 2025-07-22 182925" src="https://github.com/user-attachments/assets/b398fe00-34ee-400c-9c50-8712156efa09" />

## Step 2: Add Timpi Collector Nodes (Same Machine)
As you are already paying for the whole machine that your synaptron node is running one, it makes sense
to use the unused resources of that machine to deploy further Timpi Collector Nodes on top of it. You can
redo the below process and deploy multiple Collector Nodes alongside your Synaptron Node on the same
machine,

1. On the machine overview, click the three dots on the machine row, where you have your Synaptron
Node already running, then click + New Deployment,

2. Click on Explore All Templates at the Quick launch section, and search for Timpi Collector, and click on
it.

3. , Read the README if you want to learn more about how the application works. Continue the deployment
process by clicking on the Builder tab or Continue button to configure your application specifications,

4. Adjust resources, or keep them at recommended values, and click on the Deploy App button.

5. You will get forwarded to the Deployment Overview of your application. Wait until your application has
the status running, and click the app URL link.

6. In the newly opened tab, click the Settings icon. Then enter your Timpi Wallet address (must hold a
Timpi NFT), and set the Number of Workers from to , and save it by clicking the Save button.

<img width="606" height="356" alt="Screenshot 2025-07-22 183144" src="https://github.com/user-attachments/assets/d14a5993-382e-414b-8e90-82d6557500ef" />

7. Go back to the Collector tab in the header. Your node should now begin indexing pages.

<img width="607" height="352" alt="Screenshot 2025-07-22 183221" src="https://github.com/user-attachments/assets/e8cdf91d-539a-4714-9dad-e9067fc04b9a" />
