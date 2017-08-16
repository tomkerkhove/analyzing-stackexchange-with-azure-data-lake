Param(
    [string] $subscriptionId = $(throw "Subscription id is required"),
    [string] $dataLakeStoreAccountName = $(throw "Name of the Azure Data Lake Store account required"),
    [string] $localInputFolder = $(throw "Local folder which contains the files to upload"),
    [string] $destinationDataLakeFolder = $(throw "Folder in the Azure Data Lake Store account to upload to")
)

function Authenticate-WithAzureRm ($subscriptionId){
    if($subscriptionId -eq $null){
        throw [System.Exception] "No subscription id was provided"
    }

    # Authenticating with Azure RM
    Login-AzureRmAccount

    # Specify subscription we want to use
    Set-AzureRmContext -SubscriptionId $subscriptionId
}

function Upload-LocalFilesToAzureDataLakeStore ($dataLakeStoreAccountName, $localInputFolder, $destinationDataLakeFolder) {
    if($dataLakeStoreAccountName -eq $null){
        throw [System.Exception] "No Azure Data Lake Store account name was provided"
    }
    if($localInputFolder -eq $null){
        throw [System.Exception] "No local input folder was provided"
    }
    if($destinationDataLakeFolder -eq $null){
        throw [System.Exception] "No destination folder in Azure Data Lake Store was provided"
    }

    $rootDestinationDataLakeFolder = $destinationDataLakeFolder

    # Add beginning '/', if need be
    if($rootDestinationDataLakeFolder.StartsWith("/") -eq $false){
        $rootDestinationDataLakeFolder = "/$rootDestinationDataLakeFolder"
    }

    # Remove trailing '/', if need be. This is to make the rest of the function more easy
    if($rootDestinationDataLakeFolder.EndsWith("/") -eq $true) {
        $rootDestinationDataLakeFolder = $rootDestinationDataLakeFolder.Substring(1)
    }

    # Get all items in the folder, recursively, and process them individually
    Get-ChildItem $localInputFolder -Filter * -Recurse | Foreach-Object {
        # Get absolute path to folder or file
        $absolutePath = $_.FullName
        
        # Remove root folder from absolute path
        $relativePath = $absolutePath.Replace($localInputFolder, $string.Empty)

        # Remove starting '\', if need be
        if($relativePath.StartsWith("\")){
            $relativePath = $relativePath.Substring(1)
        }

        # Change way items are slashed, Azure Data Lake Store doesn't like '/'
        $relativePath = $relativePath.Replace("\","/")

        # Compose destination path
        $destinationPath = "$rootDestinationDataLakeFolder/$relativePath"

        Write-Host "Uploading '$absolutePath' to '$destinationPath'"

        # Determine if the item is a file or folder
        if(((Get-Item $_.FullName) -is [System.IO.DirectoryInfo]) -eq $true) {
            # Determine if the folder already exists in Azure Data Lake Store
            $doesFolderExist = Test-AzureRmDataLakeStoreItem -AccountName $dataLakeStoreAccountName -Path $destinationPath -ErrorAction Stop
            if($doesFolderExist -eq $false) {
                # Create new folder in Azure Data Lake Store
                New-AzureRmDataLakeStoreItem -AccountName $dataLakeStoreAccountName -Path $destinationPath -Folder
            } else {
                Write-Host "Folder already exists"
            }
        } else {
            # Import the file to Azure Data Lake Store, overwrite when need be
            Import-AzureRmDataLakeStoreItem -AccountName $dataLakeStoreAccountName -Path $absolutePath -Destination $destinationPath -Force
        }
    }
}

# Authenticate and select subscription
Authenticate-WithAzureRm -subscriptionId $subscriptionId

# Upload local file structure to Azure Data Lake Store
Upload-LocalFilesToAzureDataLakeStore -dataLakeStoreAccountName $dataLakeStoreAccountName -localInputFolder $localInputFolder -destinationDataLakeFolder $destinationDataLakeFolder