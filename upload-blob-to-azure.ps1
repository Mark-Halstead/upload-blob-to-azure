# Variables - replace with Read-Host for user input
$storageAccountName = Read-Host -Prompt "Enter a name for the Storage Account (e.g., sa$(Get-Random))"
$resourceGroupName = Read-Host -Prompt "Enter the resource group name"
$location = Read-Host -Prompt "Enter the Azure region (e.g., UKSouth)"
$containerName = Read-Host -Prompt "Enter the container name"
$localFilePath = Read-Host -Prompt "Enter the local file path (e.g., ./test.txt)"

# Notify that the process is starting
Write-Host "Starting the Azure Blob upload process..."

# Authenticate with Azure
Connect-AzAccount

# Check if the storage account exists
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue

if ($null -eq $storageAccount) {
    # If the storage account doesn't exist, create it
    Write-Host "Storage account $storageAccountName does not exist. Creating a new storage account..."

    # Create a new storage account
    New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName "Standard_LRS" -Kind "StorageV2"

    Write-Host "Storage account $storageAccountName created successfully."
} else {
    Write-Host "Storage account $storageAccountName already exists."
}

# Create the storage context (no key needed in Azure Cloud Shell)
Write-Host "Creating the storage context for account: $storageAccountName"
$context = New-AzStorageContext -StorageAccountName $storageAccountName

# Confirm storage context creation
Write-Host "Storage context created successfully."

# Check if the container exists
$container = Get-AzStorageContainer -Name $containerName -Context $context -ErrorAction SilentlyContinue

if ($null -eq $container) {
    # If the container doesn't exist, create it
    Write-Host "Container $containerName does not exist. Creating container..."
    New-AzStorageContainer -Name $containerName -Context $context
    Write-Host "Container $containerName created successfully."
} else {
    Write-Host "Container $containerName already exists."
}

# Get the file name from the local path
$fileName = [System.IO.Path]::GetFileName($localFilePath)
Write-Host "Preparing to upload file: $fileName from path: $localFilePath"

# Upload the file to the blob storage container
Write-Host "Uploading file to blob storage container: $containerName"
Set-AzStorageBlobContent -File $localFilePath -Container $containerName -Blob $fileName -Context $context

# Confirm upload completion
Write-Host "File '$fileName' uploaded to container '$containerName' successfully."

# Final completion message
Write-Host "Azure Blob upload process completed successfully."
