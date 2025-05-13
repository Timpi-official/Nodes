*Only Support · For Native Ubuntu +22.04.4 LTS*

---
# Linux Synaptron
### :small_blue_diamond: How to Use the Automated Synaptron Installation Script tested on Ubuntu 22.04 LTS.

## Minimum requirements
• 4 Core CPU​
• 12GB RAM​
• CUDA Compatible NVidia GPU (Min 6.1 (4 GB min) based on the Nvidia Compute Capability Index (https://developer.nvidia.com/cuda-gpus))​
• 250 GB free storage SSD / NVMe​
• Good unlimited internet connection​
• Usage of multiple GPUs not supported

## :warning: Important: Install Your Graphics Drivers First!
Ensure you have installed the latest NVIDIA graphics drivers for your GPU.

**:man_mage: Need to Install NVIDIA Drivers on Linux? Here's How!**  

## :one: **Follow NVIDIA’s official guide:**  
:point_right: [NVIDIA Driver Installation Guide](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/#ubuntu)  

## :two: **Find the right drivers for your system:**  
Check this page and pick your **Ubuntu version** and **architecture** (most people need `x86_64`).  
Example for Ubuntu 22.04:  
:point_right: [Ubuntu 22.04 x86_64 repository](https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/)  

## :three:    Verify NVIDIA Driver Installation

### :small_blue_diamond: Check if the GPU drivers is installed before proceeding the guide below:
```shell
nvidia-smi
```
## :four: Now Proceed Script or Manual Setup
### :pushpin: Automatic script Run the following commands in your terminal: 

```shell
curl -sSL -o Synaptron_setup.sh https://raw.githubusercontent.com/Timpi-official/Nodes/main/Synaptron/Synaptron_setup
chmod +x Synaptron_setup.sh
./Synaptron_setup.sh
```

## :five:    Update, Synaptron
### :small_blue_diamond: To update to the latest version when a new release is available, use the following command:
```shell
while true; do read -p "Enter a unique node name (min. 17 characters): " node_name; if [ ${#node_name} -ge 17 ]; then break; else echo "Error: Node name must be at least 17 characters. Please try again."; fi; done; read -p "Enter your GUID: " guid; sudo docker run --pull=always --restart always -d -e NAME="$node_name" -e GUID="$guid" --gpus all timpiltd/timpi-synaptron:latest
```
(Now it will take about 30 minutes until Synaptron have downloaded all necessary data before running)

NOTE :notepad_spiral: 
Update to latest synaptron repeat step :five:

# Manual Installation

## :one:  Verify NVIDIA Driver Installation

### :small_blue_diamond: Check if the GPU drivers is installed before proceeding the guide below:
```shell
nvidia-smi
```

## :two: Install Docker and NVIDIA Docker

### :small_blue_diamond: Update and Install Required Packages
```shell
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release wget
```
### :small_blue_diamond: Add Docker Repository and Install Docker
```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
```shell
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```shell
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```
### :small_blue_diamond: Enable and Start Docker
```shell
sudo systemctl enable docker
sudo systemctl start docker
```

### :small_blue_diamond: Let’s take a look to see that your docker is installed before proceeding:
```shell
sudo systemctl status docker
```

### :small_blue_diamond: Install NVIDIA Docker
```shell
sudo curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```
```shell
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

## :three: Download and Deploy Synaptron

### :small_blue_diamond: Set Up Node Information and Run the Synaptron Container
```shell
while true; do read -p "Enter a unique node name (min. 17 characters): " node_name; if [ ${#node_name} -ge 17 ]; then break; else echo "Error: Node name must be at least 17 characters. Please try again."; fi; done; read -p "Enter your GUID: " guid; sudo docker run --pull=always --restart always -d -e NAME="$node_name" -e GUID="$guid" --gpus all timpiltd/timpi-synaptron:latest
```
(Now it will take about 30 minutes until Synaptron have downloaded all necessary data before running)

## NOTE
When we make announcements about a new Synaptron update make sure you first stop the current container and remove it and then redo **only** step :three:.

### :small_blue_diamond: To monitor your setup, use the following commands:
1. Check running containers:
```shell
sudo docker ps
```
2. To start a Synaptron container after an exit:
```shell
sudo docker start -ia <Your Container ID>
```
3. Check GPU status:
```shell
nvidia-smi
```
4. To watch the logs in real-time (like tail -f for files):
```shell
sudo docker logs -f <Your Container ID>
```
5. To stop container):
```shell
sudo docker stop <Your Container ID>
```
6. To remove current container:
```shell
sudo docker rm <Your Container ID>
```

You should see a running container.

### :tv: Check Out Our Linux Video Guide:
[Click Here](https://www.youtube.com/watch?v=nhfq0PAm_BE&t=6s)
