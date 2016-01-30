using Microsoft.Analytics.Interfaces;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Xml;

namespace StackExchange.Analytics.Extractors
{

    [SqlUserDefinedExtractor(AtomicFileProcessing = true)]
    public class XmlExtractor : IExtractor
    {
        public XmlExtractor() { }

        public override IEnumerable<IRow> Extract(IUnstructuredReader input, IUpdatableRow output)
        {
            using (XmlReader reader = XmlReader.Create(input.BaseStream))
            {
                while (reader.Read())
                {
                    if (reader.NodeType == XmlNodeType.Element && reader.LocalName == "row")
                    {
                        foreach (IColumn column in output.Schema)
                        {
                            string rawValue = reader.GetAttribute(column.Name);

                            if (rawValue == null)
                            {
                                output.Set(column.Name, column.DefaultValue);
                            }
                            else
                            {
                                if (column.Type == typeof(string))
                                {
                                    string simplifiedValue = Simplify(rawValue);

                                    int byteCount = Encoding.UTF8.GetByteCount(simplifiedValue);

                                    if (byteCount > Constants.Limits.StringSizeInBytes) // 128kB
                                    {
                                        simplifiedValue = ShortenWithinBoundries(simplifiedValue);
                                    }

                                    output.Set(column.Name, simplifiedValue);
                                }
                                else
                                {
                                    var typeConverter = TypeDescriptor.GetConverter(column.Type);
                                    var castedValue = typeConverter.ConvertFromString(rawValue);

                                    output.Set(column.Name, castedValue);
                                }
                            }
                        }

                        yield return output.AsReadOnly();
                    }
                }
            }
        }

        private string Simplify(string input)
        {
            string output = input;

            output = output.Replace("\r", "");
            output = output.Replace("\n", "");
            output = output.Replace(",", ";");

            return output;
        }

        private string ShortenWithinBoundries(string input)
        {
            return new string(input.TakeWhile((c, i) =>
                                            Encoding.UTF8.GetByteCount(input.Substring(0, i + 1)) <= Constants.Limits.StringSizeInBytes)
                                   .ToArray());
        }
    }
}
