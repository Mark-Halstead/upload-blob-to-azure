# Variables
$storageAccountName = Read-Host -Prompt "enter sa$(Get-Random)"
$resourceGroupName = Read-Host -Prompt "enter rg name"
$location = Read-Host -Prompt "enter region"
$containerName = Read-Host -Prompt "enter container name"
$localFilePath = Read-Host -Prompt "enter the local file path to blob"


# Check if the storage account exists and create one if not
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



# create the storage context
Write-Host "Creating the storage context for account: $storageAccountName"
$context = New-AzStorageContext -StorageAccountName $storageAccountName
Write-Host "Storage context created successfully."



# check if the container exists
$container = Get-AzStorageContainer -Name $containerName -Context $context -ErrorAction SilentlyContinue
if ($null -eq $container) {
    # If the container doesn't exist, create it
    Write-Host "Container $containerName does not exist. Creating container..."
    New-AzStorageContainer -Name $containerName -Context $context
    Write-Host "Container $containerName created successfully."
} else {
    Write-Host "Container $containerName already exists."
}



# get local file name
$fileName = [System.IO.Path]::GetFileName($localFilePath)
Write-Host "Preparing to upload file: $fileName from path: $localFilePath"

# upload file to blob storage container
Write-Host "Uploading file to blob storage container: $containerName"
Set-AzStorageBlobContent -File $localFilePath -Container $containerName -Blob $fileName -Context $context

Write-Host "File '$fileName' uploaded to container '$containerName' successfully."
Write-Host "Azure Blob upload process completed successfully."
