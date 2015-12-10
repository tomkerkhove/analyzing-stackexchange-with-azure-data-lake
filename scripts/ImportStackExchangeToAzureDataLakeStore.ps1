function Import-StackExchangeToAzureDataLakeStore
{
    param(
            [Parameter(Mandatory=$true)][string]$SubscriptionId,
            [Parameter(Mandatory=$true)][string]$DataLakeStoreAccountName,
            [Parameter(Mandatory=$true)][string]$DataLakeStoreRootLocation,
            [Parameter(Mandatory=$true)][string]$DumpLocation
         )
    
    # Log in to your Azure account
    Login-AzureRmAccount

    # Select a subscription 
    Set-AzureRmContext -SubscriptionId $SubscriptionId

    # Register for Azure Data Lake Store
    Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.DataLakeStore" 
    
    # Prefix location with "/" when required
    if($DataLakeStoreRootLocation.StartsWith("/") -eq $false) {
        $DataLakeStoreRootLocation = "/$DataLakeStoreRootLocation"
    }

    # Check if the root exists
    $FolderExists = Test-AzureRmDataLakeStoreItem -AccountName $DataLakeStoreAccountName -Path $DataLakeStoreRootLocation
    if($FolderExists -eq $false){
        New-AzureRmDataLakeStoreItem -AccountName $DataLakeStoreAccountName -Folder $DataLakeStoreRootLocation 
    }

    foreach($Item in Get-ChildItem $DumpLocation) {
        Write-Host "Item - '$Item'" -ForegroundColor Green
    
        # Compose full folder path
        $FullPath = "$DumpLocation\$Item"
        
        # Determine if it's a file or folder
        if($Item -is [System.IO.DirectoryInfo]) {
            # Align folder name with Azure Blob requirements
	        if($Item.Name.Contains('stackoverflow'))
	        {
		        $DashedFolder = 'stackoverflow-com'
	        }
	        else
	        {
		        $DashedFolder = $Item.Name.Replace('.', '-').ToLower()
	        }
            $DestinationFolder = "$DataLakeStoreRootLocation/$DashedFolder"
            Write-Host "Destination - '$DestinationFolder'" -ForegroundColor Gray

            # Check if the folder exists
            $FolderExists = Test-AzureRmDataLakeStoreItem -AccountName $DataLakeStoreAccountName -Path $DestinationFolder
            if($FolderExists -eq $false){
                New-AzureRmDataLakeStoreItem -AccountName $DataLakeStoreAccountName -Folder $DestinationFolder
            }
    
            # Look all the files in the folder
            foreach($File in Get-ChildItem $FullPath) {
                Write-Host "File - '$File'" -ForegroundColor Yellow

                # Compose full path of original & destination file
                $FullFile = "$FullPath\$File"
                $FullDestination = "$DestinationFolder/$File"

                Import-AzureRmDataLakeStoreItem -AccountName $DataLakeStoreAccountName -Path $FullFile -Destination $FullDestination -Force
            }
        }else{
                $FullDestination = "$DataLakeStoreRootLocation/$Item"
                Import-AzureRmDataLakeStoreItem -AccountName $DataLakeStoreAccountName -Path $FullPath -Destination $FullDestination -Force
        }
    }
}