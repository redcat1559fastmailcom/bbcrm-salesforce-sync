using CsvToSqlImporter.IO;
using CsvToSqlImporter.Database;
using CsvToSqlImporter.Transform;

namespace CsvToSqlImporter
{
  internal class Program
  {
    static void Main( string [] args )
    {
      Console.Write( "Enter path to CSV file: " );
      string? filePath = Console.ReadLine();
      if (string.IsNullOrWhiteSpace( filePath ))
      {
        Console.WriteLine( "File path cannot be empty." );
        return;
      }

      CsvReader reader = new CsvReader(filePath);
      var headers = reader.GetHeaders();

      Console.WriteLine( "\nSelect SQL data types for each column:" );
      var columnDefinitions = new Dictionary<string, string>();
      foreach (var header in headers)
      {
        Console.Write( $"Data type for '{header}' (e.g., INT, VARCHAR(100), DATE): " );
        string? dataType = Console.ReadLine();
        if (string.IsNullOrWhiteSpace( dataType ))
        {
          Console.WriteLine( "Data type cannot be empty." );
          return;
        }
        columnDefinitions [header] = dataType.ToUpper();
      }

      Console.Write( "Enter SQL Server connection string: " );
      string? connectionString = Console.ReadLine();
      if (string.IsNullOrWhiteSpace( connectionString ))
      {
        Console.WriteLine( "Connection string cannot be empty." );
        return;
      }

      Console.Write( "Enter table name to create: " );
      string? tableName = Console.ReadLine();
      if (string.IsNullOrWhiteSpace( tableName ))
      {
        Console.WriteLine( "Table name cannot be empty." );
        return;
      }

      SqlHandler sql = new SqlHandler(connectionString);
      sql.CreateTable( tableName, columnDefinitions );

      var rows = reader.GetDataRows();
      DataTransformer transformer = new DataTransformer(columnDefinitions);
      var transformedRows = transformer.Transform(rows);

      sql.InsertData( tableName, columnDefinitions, transformedRows );

      Console.WriteLine( "CSV data imported successfully." );
    }
  }
}