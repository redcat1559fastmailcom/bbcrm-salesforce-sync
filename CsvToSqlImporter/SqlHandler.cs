using Microsoft.Data.SqlClient;

namespace CsvToSqlImporter.Database
{
  public class SqlHandler
  {
    private readonly string _connectionString;

    public SqlHandler( string connectionString )
    {
      _connectionString = connectionString;
    }

    public void CreateTable( string tableName, Dictionary<string, string> columns )
    {
      var columnDefs = string.Join(", ", columns.Select(kvp => $"[{kvp.Key}] {kvp.Value}"));
      string query = $"CREATE TABLE [{tableName}] ({columnDefs})";

      using var conn = new SqlConnection(_connectionString);
      conn.Open();
      using var cmd = new SqlCommand(query, conn);
      cmd.ExecuteNonQuery();
    }

    public void InsertData( string tableName, Dictionary<string, string> columns, List<object []> rows )
    {
      using var conn = new SqlConnection(_connectionString);
      conn.Open();

      foreach (var row in rows)
      {
        var columnNames = string.Join(", ", columns.Keys.Select(k => $"[{k}]"));
        var paramNames = string.Join(", ", columns.Keys.Select((k, i) => $"@p{i}"));
        string query = $"INSERT INTO [{tableName}] ({columnNames}) VALUES ({paramNames})";

        using var cmd = new SqlCommand(query, conn);
        for (int i = 0 ; i < row.Length ; i++)
        {
          cmd.Parameters.AddWithValue( $"@p{i}", row [i] ?? DBNull.Value );
        }
        cmd.ExecuteNonQuery();
      }
    }
  }
}