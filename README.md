## 1. Setup local project
  - Add your code in `src/main/` if needed
  - Test your code with `src/tests/` if needed
  - Modify notebooks for your needs

## 2. Create a Storage Account in Azure for Terraform State
Terraform requires a remote backend to store its state file. Follow these steps:

### **Option 1: Using Azure Portal (Web UI)**
1. **Log in to [Azure Portal](https://portal.azure.com/)**
2. Navigate to **Resource Groups** and click **Create**.
3. Enter a **Resource Group Name**, select a **Region**, and click **Review + Create**.
4. Once the Resource Group is created, go to **Storage Accounts** and click **Create**.
5. Fill in the required details:
   - **Storage Account Name**
   - **Resource Group** (Select the one you just created)
   - **Region** (Choose your preferred region)
   - **Performance**: Standard
   - **Redundancy**: Locally Redundant Storage (LRS)
6. Click **Review + Create** and then **Create**.
7. Once created, go to the **Storage Account** → **Containers** → Click **+ Container**.
8. Name it `tfstate` (as example) and set **Access Level** to Private.

### **Option 2: Using Azure CLI**
1. **Log in to Azure:**
   ```bash
   az login
   ```
   This will open a browser for authentication.

2. **Select Your Azure Subscription (if multiple exist):**
   ```bash
   az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
   ```

3. **Create a Resource Group:**
   ```bash
   az group create --name <RESOURCE_GROUP_NAME> --location <AZURE_REGION>
   ```

4. **Create a Storage Account:**
   ```bash
   az storage account create --name <STORAGE_ACCOUNT_NAME> --resource-group <RESOURCE_GROUP_NAME> --location <AZURE_REGION> --sku Standard_LRS
   ```

5. **Create a Storage Container:**
   ```bash
   az storage container create --name <CONTAINER_NAME> --account-name <STORAGE_ACCOUNT_NAME>
   ```

## 3. Get Your Azure Subscription ID

### **Option 1: Using Azure Portal (Web UI)**
1. **Go to [Azure Portal](https://portal.azure.com/)**
2. Click on **Subscriptions** in the left-hand menu.
3. You will see a list of your subscriptions.
4. Choose the subscription you want to use and copy the **Subscription ID**.

### **Option 2: Using Azure CLI**
Retrieve it using Azure CLI:
```bash
az account show --query id --output tsv
```

## 4. Update Terraform Configuration
Modify `main.tf` and replace placeholders with your actual values.

- **Edit the backend block in `main.tf`:**
  ```hcl
  terraform {
    backend "azurerm" {
      resource_group_name  = "<RESOURCE_GROUP_NAME>"
      storage_account_name = "<STORAGE_ACCOUNT_NAME>"
      container_name       = "<CONTAINER_NAME>"
      key                  = "terraform.tfstate"
    }
  }
  provider "azurerm" {
    features {}
    subscription_id = "<SUBSCRIPTION_ID>"
  }
  ```

## 5. Deploy Infrastructure with Terraform
Run the following Terraform commands:

```bash
terraform init
terraform plan -out terraform.plan
terraform apply terraform.plan
```

## 6. Verify Resource Deployment in Azure
After Terraform completes, verify that resources were created:

1. **Go to the [Azure Portal](https://portal.azure.com/)**
2. Navigate to **Resource Groups** → **Find `<RESOURCE_GROUP_NAME>`**
3. Check that the resources (Storage Account, Databricks, etc.) are created.

Alternatively, check via CLI:
```bash
az resource list --output table
az resource list --resource-group <RESOURCE_GROUP_NAME> --output table
```

## 7. Launch notebooks on Databricks cluster

## 8. Destroy Infrastructure (Optional)
To remove all deployed resources, run:
```bash
terraform destroy
```
