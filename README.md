# 🚀 Shareify – Community Resource Sharing Platform (Enterprise Azure Architecture)

Welcome to the **Shareify** infrastructure repository! This project contains the complete Enterprise-grade Terraform codebase used to provision a highly available, secure, and auto-scaling microservices environment on Microsoft Azure.

---

## 1. Project Overview

### What is Shareify?
Shareify is a community resource sharing platform designed to allow users to share, rent, and borrow items locally. Built with a modern service-oriented architecture (SOA), it utilizes a frontend web application backed by multiple specialized APIs.

### The Purpose of Terraform in this Project
In this project, **Terraform** acts as our Infrastructure-as-Code (IaC) tool. Instead of manually clicking through the Azure portal, this repository allows you to define, provision, and update the entire infrastructure predictably and idempotently via code. This guarantees identical staging and production environments, disaster recovery, and change management.

### Why Azure?
Microsoft Azure was chosen for its robust enterprise integrations, comprehensive networking capabilities (VNet, NAT Gateway, Application Gateway), and managed database offerings (PostgreSQL Flexible Server), which seamlessly support virtual machine scale sets and microservices.

### Microservices Architecture
The application is split into 6 core Python FastAPI microservices and 1 API Gateway, all running on a dedicated Backend Virtual Machine, plus a React-based frontend running on a Virtual Machine Scale Set (VMSS).
*   **FastAPI & Python**: Used for all microservices for high performance and rapid development.
*   **Virtual Machine Scale Set (VMSS)**: Automatically scales the frontend application based on traffic.
*   **Azure PostgreSQL Flexible Server**: A fully managed, highly available relational database for storing all application state.
*   **Azure Application Gateway & WAF**: Provides Layer-7 load balancing, SSL termination, path-based routing, and enterprise-grade Web Application Firewall security.
*   **NAT Gateway**: Secures outbound traffic from private subnets.
*   **Azure Bastion**: Secures SSH access without exposing ports to the public internet.

---

## 2. Architecture Overview

This architecture is designed around the principles of defense-in-depth, high availability, and scalability.

### Core Components
*   **Resource Group**: A logical container (`shareify-rg`) holding all related resources for this deployment.
*   **Virtual Network (VNet)**: A `10.0.0.0/16` isolated network boundary containing multiple dedicated subnets.
*   **Subnets**:
    *   `AppGatewaySubnet` (`10.0.0.0/24`): Dedicated exclusively to the Application Gateway.
    *   `FrontendSubnet` (`10.0.2.0/24`): Houses the Frontend VMSS.
    *   `BackendSubnet` (`10.0.3.0/24`): Houses the Backend VM running the microservices APIs.
    *   `DbSubnet` (`10.0.4.0/24`): Delegated exclusively for the Azure PostgreSQL Flexible Server.
    *   `AzureBastionSubnet` (`10.0.1.0/24`): Dedicated strictly to Azure Bastion.
*   **Application Gateway with WAF**: The main entry point. It filters malicious traffic using the OWASP 3.2 ruleset (Detection mode) and routes traffic based on URL paths (`/` goes to the frontend, `/api/*` goes to the backend).
*   **Frontend VMSS**: An auto-scaling group of `Standard_Dc1ds_v3` VMs serving the React frontend via Nginx.
*   **Backend VM**: A single robust `Standard_Dc1ds_v3` VM (designed to be scalable later) hosting 6 FastAPI microservices managed via systemd.
*   **PostgreSQL Flexible Server**: A private, VNet-integrated database server containing 6 isolated databases (one for each microservice).
*   **NAT Gateway**: Attached to the Frontend and Backend subnets, ensuring all outbound internet traffic from the VMs shares a single, predictable public IP without exposing the VMs to inbound internet traffic.
*   **Azure Bastion**: A fully managed PaaS service that provides secure and seamless RDP/SSH connectivity to VMs directly from the Azure portal over TLS.
*   **Network Security Groups (NSGs)**: Applied to subnets to strictly enforce the principle of least privilege, blocking all inbound traffic except what is explicitly required.

### Traffic Flow (Internal & External)
1.  **Ingress**: A user navigates to the public IP of the Application Gateway.
2.  **Routing**: 
    *   If the user requests the base path `/`, the Application Gateway routes the request to the **Frontend VMSS pool**.
    *   If the user requests `/api/*`, the Gateway routes the request to the **Backend VM pool** (specifically hitting the API Gateway service running on port 8000).
3.  **Backend Processing**: The Python API Gateway receives the request and proxies it to the corresponding internal microservice (e.g., `user-service` on port 8001) using local loopback (`127.0.0.1`).
4.  **Database Access**: The microservice securely communicates with its dedicated database hosted on the private PostgreSQL server over the VNet.

---

## 3. Architecture Diagram

Below is the visual representation of the Shareify infrastructure.

> **[High-Level Architecture Diagram Placeholder]**
> *(Insert an image showing the VNet, Subnets, App Gateway, VMSS, Backend VM, and PostgreSQL flow here)*

> **[Network Flow Diagram Placeholder]**
> *(Insert an image showing the precise ingress routing through NSGs, NAT Gateway outbound flow, and Bastion secure SSH flow here)*

---

## 4. Project Structure

The codebase is organized using a highly modular Terraform architecture to promote reusability and maintainability.

```text
Shareify-Terraform/
├── main.tf                 # Root module orchestrating all child modules
├── variables.tf            # Global input variables
├── outputs.tf              # Global outputs (e.g., Public IPs, DB FQDN)
├── providers.tf            # Azure provider configuration
├── terraform.tfvars        # Values for the variables (Environment specific)
└── modules/
    ├── application-gateway/ # Layer 7 Load Balancer & WAF
    ├── autoscaling/         # Azure Monitor Autoscale settings for VMSS
    ├── backend-vm/          # Backend API Virtual Machine & bootstrap script
    ├── bastion/             # Azure Bastion Host
    ├── nat-gateway/         # NAT Gateway for outbound connectivity
    ├── networking/          # VNet, Subnets, and NSGs
    ├── postgresql/          # Private PostgreSQL Flexible Server & Databases
    ├── resource-group/      # Foundational Resource Group
    └── vmss/                # Virtual Machine Scale Set & bootstrap script
```

**Why Modular?** 
A modular structure prevents monolithic code files, allows different teams to manage specific infrastructure pieces (e.g., a DBA team managing `postgresql`), and makes it easy to duplicate environments (e.g., deploying staging vs. production).

---

## 5. Terraform Modules Explanation

### `resource-group`
*   **Purpose**: Creates the base Azure Resource Group.
*   **Resources**: `azurerm_resource_group`.
*   **Dependencies**: None.

### `networking`
*   **Purpose**: Builds the network backbone.
*   **Resources**: `azurerm_virtual_network`, `azurerm_subnet` (x5), `azurerm_network_security_group`, `azurerm_subnet_network_security_group_association`.
*   **Outputs**: Subnet IDs, VNet ID, NSG IDs.

### `application-gateway`
*   **Purpose**: Ingress controller, WAF, and path-based router.
*   **Resources**: `azurerm_application_gateway`, `azurerm_public_ip`, `azurerm_web_application_firewall_policy`.
*   **Dependencies**: `networking`.

### `vmss`
*   **Purpose**: Deploys the auto-scaling frontend instances.
*   **Resources**: `azurerm_linux_virtual_machine_scale_set`.
*   **Inputs**: `cloud-init` script via custom data for automatic Nginx deployment.
*   **Dependencies**: `networking`, `nat-gateway`.

### `backend-vm`
*   **Purpose**: Hosts the backend APIs.
*   **Resources**: `azurerm_linux_virtual_machine`, `azurerm_network_interface`.
*   **Inputs**: `cloud-init` script that clones the GitHub repo, templates systemd services, and starts Uvicorn.
*   **Dependencies**: `networking`, `postgresql`.

### `postgresql`
*   **Purpose**: Deploys the managed database tier.
*   **Resources**: `azurerm_postgresql_flexible_server`, `azurerm_postgresql_flexible_server_database` (x6), `azurerm_private_dns_zone`.
*   **Dependencies**: `networking`.

### `bastion`
*   **Purpose**: Secure administrative access.
*   **Resources**: `azurerm_bastion_host`, `azurerm_public_ip`.
*   **Dependencies**: `networking` (specifically `AzureBastionSubnet`).

### `nat-gateway`
*   **Purpose**: Allows private VMs to pull packages and code from the internet securely.
*   **Resources**: `azurerm_nat_gateway`, `azurerm_public_ip`, `azurerm_subnet_nat_gateway_association`.

### `autoscaling`
*   **Purpose**: Adds elasticity to the VMSS.
*   **Resources**: `azurerm_monitor_autoscale_setting`.
*   **Dependencies**: `vmss`.

---

## 6. Prerequisites

To deploy this architecture, you must have the following installed on your local machine:

1.  **Azure Subscription**: An active subscription with Contributor rights.
2.  **Azure CLI**: To authenticate to Azure.
3.  **Terraform**: Version `1.5.0` or higher.
4.  **Git**: To clone this repository.
5.  **SSH Client**: To access the VMs (if not using the Azure Portal Bastion UI).

### Installation Commands

**Windows (PowerShell with Chocolatey):**
```powershell
choco install azure-cli terraform git -y
```

**Linux (Ubuntu/Debian):**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt-get install git -y
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform -y
```

**macOS (Homebrew):**
```bash
brew install azure-cli terraform git
```

---

## 7. Azure Authentication

Before running Terraform, you must log in to Azure and set your subscription.

1.  **Log in to Azure**:
    ```bash
    az login
    ```
    *(This will open a browser window for you to authenticate)*
2.  **List your subscriptions**:
    ```bash
    az account list --output table
    ```
3.  **Set the active subscription** (Replace `<SUBSCRIPTION_ID>`):
    ```bash
    az account set --subscription <SUBSCRIPTION_ID>
    ```
4.  **Verify your identity**:
    ```bash
    az ad signed-in-user show
    ```

---

## 8. Terraform Deployment Steps

Follow these exact steps to provision the infrastructure from scratch.

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/muvvaalaakash/Shareify.git
    cd Shareify/Shareify-Terraform
    ```

2.  **Initialize Terraform**:
    This downloads the required Azure provider plugins and initializes the modules.
    ```bash
    terraform init
    ```

3.  **Validate the Configuration**:
    Ensures your syntax is correct.
    ```bash
    terraform validate
    ```

4.  **Plan the Deployment**:
    Preview exactly what Azure resources will be created.
    ```bash
    terraform plan -out=tfplan
    ```

5.  **Apply the Infrastructure**:
    Execute the plan and provision the resources. (This process takes ~10-15 minutes, mostly for the PostgreSQL server and Application Gateway).
    ```bash
    terraform apply tfplan
    ```

6.  **Confirm the Outputs**:
    Once finished, Terraform will print the important endpoints:
    ```text
    Outputs:
    app_gateway_public_ip = "4.213.119.219"
    backend_vm_private_ip = "10.0.3.4"
    bastion_public_ip = "4.213.126.90"
    postgresql_fqdn = "shareify-postgres.postgres.database.azure.com"
    ```

---

## 9. `terraform.tfvars` Explanation

The `terraform.tfvars` file contains the specific values passed into our variables.

*   `location = "eastus"`: The Azure region where resources are deployed.
*   `project_name = "shareify"`: Prefix used for all resource naming conventions.
*   `vnet_cidr = ["10.0.0.0/16"]`: The massive IP block for our internal network.
*   `app_gateway_subnet_cidr = ["10.0.0.0/24"]`: Reserved specifically for Application Gateway.
*   `bastion_subnet_cidr = ["10.0.1.0/24"]`: Mandatory subnet name/size for Azure Bastion.
*   `frontend_subnet_cidr = ["10.0.2.0/24"]`: Subnet for the VMSS nodes.
*   `backend_subnet_cidr = ["10.0.3.0/24"]`: Subnet for the backend API VMs.
*   `db_subnet_cidr = ["10.0.4.0/24"]`: Dedicated delegated subnet for PostgreSQL Flexible Server.
*   `admin_username = "Akash"`: Administrator username for VMs and the Database.
*   `admin_password = "Akash@21042004"`: Administrator password. *(Note: In production, rely on Azure Key Vault or SSH keys instead of plain text passwords).*
*   `vm_size = "Standard_Dc1ds_v3"`: The SKU size for the virtual machines. Chosen for a balance of cost and computing power.
*   `postgres_sku_name = "B_Standard_B1ms"`: The SKU for PostgreSQL. B-series is burstable, making it cost-effective.
*   `postgres_version = "15"`: Utilizing modern Postgres 15 features.

---

## 10. Application Deployment

The Shareify application is deployed **automatically** at boot time via `cloud-init` custom data scripts attached to the Terraform configurations.

### Backend Startup (`backend-bootstrap.sh`)
1.  Installs Python 3, pip, git, and Postgres dev tools.
2.  Clones the GitHub repository into `/opt/Shareify`.
3.  Creates a Python virtual environment and installs `uvicorn`, `fastapi`, `psycopg2-binary`, etc.
4.  Dynamically generates `systemd` unit files (`shareify-user.service`, `shareify-item.service`, etc.) injecting the live PostgreSQL connection strings generated by Terraform.
5.  Patches the API Gateway code using `sed` to route requests to local loopback IPs (`127.0.0.1:8001`, etc.) instead of Kubernetes DNS names.
6.  Starts all 6 microservices and the API gateway on their respective ports (`8000-8006`).

### Frontend Startup (`frontend-bootstrap.sh`)
1.  Installs Node.js, npm, git, and Nginx.
2.  Clones the repository.
3.  Builds the React frontend using `npm run build`.
4.  Copies the static assets to `/var/www/html`.
5.  Restarts Nginx to serve the site on port 80.

---

## 11. Internal Service Flow

Understanding how requests travel internally is critical for debugging.

**Example: User Registration Flow**
1.  **User Browser**: Sends `POST https://<AppGateway-IP>/api/register` with JSON body.
2.  **Application Gateway**: Matches the `/api/*` path rule. Forwards the request to `Backend VM` on port `8000`.
3.  **API Gateway (Port 8000)**: Receives `/api/register`. Looks up its `SERVICE_MAP`. Identifies that `users` maps to `http://127.0.0.1:8001`. Forwards the request.
4.  **User Service (Port 8001)**: Receives the registration request. Hashes the password using `bcrypt`.
5.  **PostgreSQL Server**: The User Service connects to `users_db` using the injected `DATABASE_URL` environment variable. Executes the `INSERT` query.
6.  **Response**: The success response cascades back up the chain to the user.

---

## 12. Networking and Security

*   **Public IP Exposure**: Only the Application Gateway, NAT Gateway, and Bastion have Public IPs. **VMs and Databases have NO Public IPs.**
*   **WAF (Web Application Firewall)**: The Application Gateway WAF inspects payloads for SQL Injection, Cross-Site Scripting (XSS), and anomaly detection.
*   **NSGs (Network Security Groups)**: Applied strictly at the subnet level. For instance, the Backend Subnet only allows inbound traffic on port 8000 originating from the Application Gateway Subnet.
*   **Database Isolation**: The PostgreSQL server lives in a delegated private subnet. It can only be accessed by resources within the VNet. It is entirely invisible to the outside internet.
*   **NAT Gateway**: Because backend VMs lack Public IPs, they use the NAT Gateway to securely download Ubuntu updates and Python packages.

---

## 13. Autoscaling

The Frontend tier utilizes a **Virtual Machine Scale Set (VMSS)** with Azure Monitor autoscale rules configured via Terraform.

*   **Minimum Instances**: 1
*   **Maximum Instances**: 3
*   **Scale Out Rule**: If average CPU utilization exceeds **70%** over 5 minutes, Azure spins up 1 additional VM instance.
*   **Scale In Rule**: If average CPU utilization drops below **30%** over 5 minutes, Azure terminates 1 VM instance.

*Benefits*: This ensures the application remains responsive during high traffic spikes while saving compute costs during low traffic periods.

---

## 14. Monitoring and Logging

*   **Health Probes**: The Application Gateway continuously monitors the backend VM. We have deployed a custom probe that ensures even if the API gateway returns a `404` for the root path (`/`), the node is marked as "Healthy" to prevent `502 Bad Gateway` drops.
*   **Systemd Logs**: Application logs on the backend VM are managed by `journald`. You can view them using:
    ```bash
    journalctl -u shareify-api-gateway -f
    ```
*   **Azure Monitor**: CPU, Memory, and Network metrics for all VMs and databases are automatically collected by Azure Monitor for alerting and dashboards.

---

## 15. Validation and Testing

Once Terraform finishes, validate the deployment:

1.  **Test the Application Gateway & WAF**:
    ```bash
    curl -I http://<APP_GATEWAY_IP>/
    ```
    *(You should receive a `200 OK` from the Nginx frontend).*

2.  **Test the API Registration Flow**:
    ```bash
    curl -X POST http://<APP_GATEWAY_IP>/api/register \
      -H "Content-Type: application/json" \
      -d '{"name": "Test User", "email": "test@test.com", "password": "password"}'
    ```
    *(You should receive a success JSON response).*

3.  **Verify Backend Services**:
    Log into the backend VM using Azure Bastion and check the service status:
    ```bash
    systemctl status shareify-user
    ```

---

## 16. Troubleshooting Guide

### ❌ Issue: Application Gateway returns `502 Bad Gateway`
*   **Root Cause**: The health probe is failing, causing the App Gateway to mark the backend pool as unhealthy.
*   **Symptoms**: Browser shows 502. App Gateway backend health shows "Unhealthy".
*   **Fix**: Verify that the custom health probe in `application-gateway/main.tf` accepts `404` or `200-399` as healthy statuses. Restart the API gateway systemd service on the backend VM.

### ❌ Issue: API returns `503 Service Unavailable: [Errno -3] Temporary failure in name resolution`
*   **Root Cause**: The API Gateway is trying to route traffic to Kubernetes hostnames (e.g., `shareify-user-service`) which do not exist in the VM's `/etc/hosts` file.
*   **Symptoms**: Registration or Login endpoints return 503 errors.
*   **Fix**: The `backend-bootstrap.sh` script contains `sed` commands to replace these strings with `127.0.0.1`. If it fails, manually run:
    ```bash
    sed -i 's/"http:\/\/shareify-user-service:8000"/"http:\/\/127.0.0.1:8001"/g' /opt/Shareify/api-gateway/main.py
    systemctl restart shareify-api-gateway
    ```

### ❌ Issue: Database Connection Errors
*   **Root Cause**: Special characters (like `%`) in the database password break the systemd unit file loading.
*   **Symptoms**: `journalctl -u shareify-user` shows "Invalid slot" or connection timeouts.
*   **Fix**: Passwords with `%` must be escaped as `%%` when written into a `.service` file. This is handled by a Python url-encoding step inside `backend-bootstrap.sh`. Ensure you do not use `$$` for bash variables inside Terraform heredoc strings if escaping is needed.

---

## 17. Cleanup Steps

To avoid incurring ongoing Azure costs, completely destroy the infrastructure when you are finished testing.

1.  **Destroy the Infrastructure**:
    ```bash
    terraform destroy -auto-approve
    ```
2.  **Remove State (Optional)**:
    Delete the local `.terraform` folder and `terraform.tfstate` files if you are done completely.

---

## 18. Future Improvements

To elevate this project to a true production state, the following roadmap is recommended:

*   **Azure Kubernetes Service (AKS) Migration**: Containerize the microservices using Docker and migrate from bare VMs to AKS for superior orchestration and zero-downtime deployments.
*   **SSL/TLS Certificates**: Integrate Azure Key Vault and Let's Encrypt to bind HTTPS certificates to the Application Gateway.
*   **CI/CD Pipeline**: Implement GitHub Actions to automatically run `terraform plan` and `terraform apply` on pushes to the `main` branch.
*   **Redis Caching**: Deploy Azure Cache for Redis to speed up database query read times for the `inventory-service`.

---

## 19. Best Practices Utilized

*   **Infrastructure as Code (IaC)**: Eliminates human error and allows code review of infrastructure changes.
*   **Principle of Least Privilege**: Used NSGs to tightly restrict traffic. Databases have no public IP.
*   **Modular Architecture**: Enables reuse of code and cleaner state management.
*   **Immutable Infrastructure**: Server configuration is baked into `cloud-init` scripts at provisioning time rather than manually SSHing and configuring servers post-deployment.

---

## 20. Conclusion

The Shareify platform infrastructure represents a robust, highly available, and secure deployment utilizing the best of Microsoft Azure's cloud offerings. By pairing advanced networking architectures (Application Gateway, Bastion, NAT) with dynamic auto-scaling sets and managed databases, this project provides an incredible foundation for any enterprise-grade microservice application. 

Happy Sharing! 🎉
