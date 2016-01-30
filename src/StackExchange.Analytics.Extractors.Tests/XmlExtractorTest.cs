using Microsoft.Analytics.Interfaces;
using Microsoft.Analytics.UnitTest;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Xunit;

namespace StackExchange.Analytics.Extractors.Tests
{
    public class XmlExtractorTest
    {
        [Fact]
        public void Extract_ValidCommentsInputFromCoffee_Succeeds()
        {
            IUpdatableRow output = GetCommentRow().AsUpdatable();
            IEnumerable<IRow> result;

            using (FileStream fileReader = new FileStream("Input/Coffee/Comments.xml", FileMode.Open, FileAccess.Read))
            {
                USqlStreamReader streamReader = new USqlStreamReader(fileReader);
                XmlExtractor extractor = new XmlExtractor();

                result = extractor.Extract(streamReader, output);
                Assert.Equal(1279, result.Count());
            }
        }

        [Fact]
        public void Extract_ValidCommentsInputFromBoardgames_Succeeds()
        {
            IUpdatableRow output = GetCommentRow().AsUpdatable();
            IEnumerable<IRow> result;

            using (FileStream fileReader = new FileStream("Input/Board-Games/Comments.xml", FileMode.Open, FileAccess.Read))
            {
                USqlStreamReader streamReader = new USqlStreamReader(fileReader);
                XmlExtractor extractor = new XmlExtractor();

                result = extractor.Extract(streamReader, output);
                Assert.Equal(23343, result.Count());
            }
        }

        [Fact]
        public void Extract_ValidUsersInputFromCoffee_Succeeds()
        {
            IUpdatableRow output = GetUserRow().AsUpdatable();
            IEnumerable<IRow> result;

            using (FileStream fileReader = new FileStream("Input/Coffee/Users.xml", FileMode.Open, FileAccess.Read))
            {
                USqlStreamReader streamReader = new USqlStreamReader(fileReader);
                XmlExtractor extractor = new XmlExtractor();

                result = extractor.Extract(streamReader, output);
                Assert.Equal(1162, result.Count());
            }
        }

        [Fact]
        public void Extract_ValidUsersInputFromBoardgames_Succeeds()
        {
            IUpdatableRow output = GetUserRow().AsUpdatable();
            IEnumerable<IRow> result;

            using (FileStream fileReader = new FileStream("Input/Board-Games/Users.xml", FileMode.Open, FileAccess.Read))
            {
                USqlStreamReader streamReader = new USqlStreamReader(fileReader);
                XmlExtractor extractor = new XmlExtractor();

                result = extractor.Extract(streamReader, output);
                Assert.Equal(9352, result.Count());
            }
        }

        public IRow GetUserRow()
        {
            USqlColumn<int> id = new USqlColumn<int>("Id");
            USqlColumn<int> reputation = new USqlColumn<int>("Reputation");
            USqlColumn<DateTime> creationDate = new USqlColumn<DateTime>("CreationDate");
            USqlColumn<string> displayName = new USqlColumn<string>("DisplayName");
            USqlColumn<DateTime> lastAccessDate = new USqlColumn<DateTime>("LastAccessDate");
            USqlColumn<string> location = new USqlColumn<string>("Location");
            USqlColumn<string> aboutMe = new USqlColumn<string>("AboutMe");
            USqlColumn<int> upVotes = new USqlColumn<int>("UpVotes");
            USqlColumn<int> downVotes = new USqlColumn<int>("DownVotes");
            USqlColumn<int> age = new USqlColumn<int>("Age");
            USqlColumn<int> accountId = new USqlColumn<int>("AccountId");
            USqlColumn<string> profileImageUrl = new USqlColumn<string>("ProfileImageUrl");
            USqlColumn<string> websiteUrl = new USqlColumn<string>("WebsiteUrl");

            List<IColumn> columns = new List<IColumn> { id, reputation, creationDate, displayName, lastAccessDate, location, aboutMe, upVotes, downVotes, age, accountId, profileImageUrl, websiteUrl };
            USqlSchema schema = new USqlSchema(columns);
            return new USqlRow(schema, null);
        }

        public IRow GetCommentRow()
        {
            USqlColumn<int> id = new USqlColumn<int>("Id");
            USqlColumn<int> postId = new USqlColumn<int>("PostId");
            USqlColumn<int> score = new USqlColumn<int>("Score");
            USqlColumn<string> text = new USqlColumn<string>("Text");
            USqlColumn<DateTime> creationDate = new USqlColumn<DateTime>("CreationDate");
            USqlColumn<int> userId = new USqlColumn<int>("UserId");

            List<IColumn> columns = new List<IColumn> { id, postId, score, text, creationDate, userId };
            USqlSchema schema = new USqlSchema(columns);
            return new USqlRow(schema, null);
        }
    }
}
