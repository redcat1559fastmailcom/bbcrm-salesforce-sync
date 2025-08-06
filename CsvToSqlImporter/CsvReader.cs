using Microsoft.VisualBasic.FileIO;

namespace CsvToSqlImporter.IO
{
  public class CsvReader
  {
    private readonly string _filePath;

    public CsvReader( string filePath )
    {
      _filePath = filePath;
    }

    public List<string> GetHeaders()
    {
      using var parser = new TextFieldParser(_filePath);
      parser.SetDelimiters( "," );
      var fields = parser.ReadFields();
      return fields != null ? new List<string>( fields ) : new List<string>();
    }

    public List<string []> GetDataRows()
    {
      var rows = new List<string[]>();
      using var parser = new TextFieldParser(_filePath);
      parser.SetDelimiters( "," );
      parser.ReadLine(); // Skip header
      while (!parser.EndOfData)
      {
        var fields = parser.ReadFields();
        if (fields != null)
        {
          rows.Add( fields );
        }
      }
      return rows;
    }
  }
}