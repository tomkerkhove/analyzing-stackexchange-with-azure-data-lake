function CreateIfNotExists-AzureBlobContainer {
    param(
            [Parameter(Mandatory=$true)]$ContainerName,
            [Parameter(Mandatory=$true)]$StorageContext
         )
    try {
        $Container = Get-AzureStorageContainer -Name $ContainerName -Context $StorageContext -ErrorAction SilentlyContinue
    }
    catch {
        # Create containter
        New-AzureStorageContainer -Name $ContainerName -Permission off -Context $StorageContext
    }
}

function Import-StackExchangeToAzureBlobStorage
{
    param(
            [Parameter(Mandatory=$true)][string]$SubscriptionId,
            [Parameter(Mandatory=$true)][string]$StorageAccountName,
            [Parameter(Mandatory=$true)][string]$DumpLocation
         )
    
    Add-AzureAccount

    $current = Get-AzureSubscription -Current

    if($current.SubscriptionId -ne $SubscriptionId)
    {
        Select-AzureSubscription -SubscriptionId $SubscriptionId -Default
    }

    $StorageAccount = Get-AzureStorageAccount -StorageAccountName $StorageAccountName
    $PrimaryStorageKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary

    $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $PrimaryStorageKey

    foreach($Item in Get-ChildItem $DumpLocation) {
        Write-Host "Item - '$Item'" -ForegroundColor Green

        if($Item -is [System.IO.DirectoryInfo]) {

            # Remove the dots & lower text
	        if($Item.Name.Contains('stackoverflow'))
	        {
		        $ContainerName = 'stackoverflow-com'
	        }
	        else
	        {
		        $ContainerName = $Item.Name.Replace('.', '-').ToLower()
	        }
	
            # Shorten if too long
            if($ContainerName.Length -gt 63) {
                $ContainerName = $ContainerName.Substring(0,63)
            }
	        Write-Host "Container - '$ContainerName'" -ForegroundColor Gray

            # Check if the container already exists
            CreateIfNotExists-AzureBlobContainer -ContainerName $ContainerName -StorageContext $StorageContext
            
            # Compose full folder path
            $FullFolder = "$DumpLocation\$Item"
    
            foreach($File in Get-ChildItem $FullFolder) {
                Write-Host "File - '$File'" -ForegroundColor Yellow

                $FullFile = "$FullFolder\$File"

                Set-AzureStorageBlobContent -Container $ContainerName -Blob $File -File $FullFile -Context $StorageContext
            }
        }
        else {
            # Assign default metadata container
            $ContainerName = "metadata"

            # Check if the container already exists
            CreateIfNotExists-AzureBlobContainer -ContainerName $ContainerName -StorageContext $StorageContext

            # Compose full path to file
            $FullPath = "$DumpLocation\$Item"

            # Upload file
            Set-AzureStorageBlobContent -Container $ContainerName -Blob $Item -File $FullPath -Context $StorageContext
        }        
    }
}