module "supplychain-glue" {
  source = "../../../../../terraform-aws-modules-glue/modules"
 
 
  create_glue_catalog_database = true
  catalog_database_name        = var.catalog_database_name
  catalog_database_description = "Supplychain Database Tracker"
  location_uri                 = var.location_uri
  database_parameters = {
    "classification"         = "csv",
    "typeOfData"             = "file",
    "compressionType"        = "none",
    "averageRecordSize"      = "1024",
    "customSerde"            = "OpenCSVSerDe",
    "areColumnsQuoted"       = "true",
    "columnsOrdered"         = "true",
    "delimiter"              = ",",
    "skip.header.line.count" = "1"
  }
 
 
  create_glue_catalog_table = true
  database_name             = var.catalog_database_name
  catalog_table_name        = var.catalog_table_name
  catalog_id                = var.catalog_id
  owner                     = "supplychain"
  table_parameters = {
    "skip.header.line.count" = 1,
    "classification"         = "csv", # Specify the quote character (default is double quote)
    "averageRecordSize"      = 1024,
    "customSerde"            = "OpenCSVSerDe",
    "areColumnsQuoted"       = "true",
    "columnsOrdered"         = "true",
    "delimiter"              = ",",
    "typeOfData"             = "file",
    "compressionType"        = "none",
  }
 
  table_type = "EXTERNAL_TABLE"
 
  storage_descriptor = {
    location      = var.location_uri
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
 
    ser_de_info = {
      name                  = "OpenCSVSerde",
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      parameters = {
        "separatorChar" = ",",
        "quoteChar"     = "\"",
        "escapeChar"    = "\\"
      }
    }
 
    columns = [
      {
        name = "ReleasePipelineID",
        type = "string"
      },
      {
        name = "ReleasePipelineName",
        type = "string"
      },
      {
        name = "ReleaseDate",
        type = "string"
      },
      {
        name = "Summary",
        type = "string"
      },
      {
        name = "AppicationName",
        type = "string"
      },
      {
        name = "ChangeTicket",
        type = "string"
      },
      {
        name = "DBName",
        type = "string"
      },
      {
        name = "SchemaUser",
        type = "string"
      },
      {
        name = "EventType",
        type = "string"
      },
      {
        name = "SQLStatement",
        type = "string"
      },
      {
        name = "RowsAffected",
        type = "string"
      },
      {
        name = "ExecutionTimestamp",
        type = "string"
      }
    ]
  } 
 }