using System.Globalization;

namespace CsvToSqlImporter.Transform
{
  public class DataTransformer
  {
    private readonly Dictionary<string, string> _columnTypes;

    public DataTransformer( Dictionary<string, string> columnTypes )
    {
      _columnTypes = columnTypes;
    }

    public List<object []> Transform( List<string []> rows )
    {
      var transformed = new List<object[]>();

      foreach (var row in rows)
      {
        var newRow = new object[row.Length];
        int i = 0;
        foreach (var kvp in _columnTypes)
        {
          string value = row[i];
          newRow [i] = ConvertValue( value, kvp.Value );
          i++;
        }
        transformed.Add( newRow );
      }

      return transformed;
    }

    private object ConvertValue( string value, string sqlType )
    {
      if (string.IsNullOrWhiteSpace( value ))
        return DBNull.Value;

      try
      {
        if (sqlType.StartsWith( "INT" ))
          return int.Parse( value );
        if (sqlType.StartsWith( "FLOAT" ))
          return float.Parse( value );
        if (sqlType.StartsWith( "DATE" ))
          return DateTime.Parse( value, CultureInfo.InvariantCulture );
        if (sqlType.StartsWith( "BIT" ))
          return value.ToLower() == "true" || value == "1";
        return value; // Default to string
      }
      catch
      {
        return DBNull.Value;
      }
    }
  }
}