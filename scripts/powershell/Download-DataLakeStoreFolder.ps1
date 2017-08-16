Param(
    [string] $subscriptionId = $(throw "Subscription id is required"),
    [string] $dataLakeStoreAccountName = $(throw "Name of the Azure Data Lake Store account required"),
    [string] $dataLakeFolder = $(throw "Folder in the Azure Data Lake Store account to download"),
    [string] $localOutputFolder = $(throw "Local folder to which everything will be downloaded")
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

function Download-DataLakeFolder ($dataLakeStoreAccountName, $dataLakeFolder, $destinationFolder){
    if($dataLakeStoreAccountName -eq $null){
        throw [System.Exception] "No data lake store account name was provided"
    }
    if($dataLakeFolder -eq $null){
        throw [System.Exception] "No data lake folder was provided"
    }
    if($destinationFolder -eq $null){
        throw [System.Exception] "No local destination folder was provided"
    }

    # Get all items in the specified Azure Data Lake Store root folder and process them individually
    Get-AzureRmDataLakeStoreChildItem -Account $dataLakeStoreAccountName -Path $dataLakeFolder | ForEach-Object {
        $path = $_.Path

        # Export the contents of the Azure Data Lake Store item
        Export-AzureRmDataLakeStoreItem -AccountName $dataLakeStoreAccountName -Path $path -Destination "$destinationFolder/$path"
    }
}

# Authenticate and select subscription
Authenticate-WithAzureRm -subscriptionId $subscriptionId

# Download everything from the specified Azure Data Lake Store folder to a local folder
Download-DataLakeFolder -dataLakeStoreAccountName $dataLakeStoreAccountName -dataLakeFolder $dataLakeFolder -destinationFolder $localOutputFolder
