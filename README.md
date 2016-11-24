Analyzing StackExchange data with Azure Data Lake
============================================
This repository contains all the code & scripts for my 'Analyzing StackExchange data with Azure Data Lake' series.

This series will take you through the process of storing StackExchange data in Data Lake Store, aggregating all the User-data from all the websites into one file and gaining knowledge from it with Data Lake Analytics. After that we'll use PowerBI to visualize the gained knowledge.

In [the introduction](https://tomkerkhove.ghost.io/2015/11/28/analyzing-stackexchange-data-with-azure-data-lake-introduction/) I've talked about the four major blocks in the series:

1. Storing the data in Azure Data Lake Store or Azure Storage ([post](analyzing-stackexchange-data-with-azure-data-lake-storing-the-data))
2. Aggregating the data with Azure Data Lake Analytics
3. Analyzing the data with Azure Data Lake Analytics
4. Visualizing the data with Power BI

---------------------------------------

The blog post series is currently on hold but you can browse all the scripts.
*This is based on an old SDK so there might be compatibility issues*

---------------------------------------

# Getting the StackExchange Data Dump
Stack Exchange has made their data available from all their websites under [Creative Commons](http://creativecommons.org/licenses/by-sa/3.0/) license. It includes data about users, posts, comments, votes, etc for every single site.

![Stack Exchange Logo](./media/Stack-Exchange-Logo.png)

We will use this data as a demo set as this reflect real-world data. The data contains information about every website by StackExchange going from users & posts to comments and votes and beyond.

Here is an example of how the folder for `coffee-stackexchange-com` is structured: 

	+ coffee-stackexchange-com
		- Badges.xml
		- Comments.xml
		- PostHistory.xml
		- PostLinks.xml
		- Posts.xml
		- Tags.xml
		- Users.xml
		- Votes.xml

You can find all the data [here](https://archive.org/details/stackexchange).

# License
Licensed under the terms of the [MIT license](LICENSE).
