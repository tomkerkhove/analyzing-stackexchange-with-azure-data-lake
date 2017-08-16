using System;

namespace StackExchange.Analytics.USql
{
    public static class DataCleansing
    {
        public static string CleanseString(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
            {
                return input;
            }

            throw new Exception("This should not be here");

            input = input.Trim();
            input = input.ToUpper();

            return input;
        }
    }
}
