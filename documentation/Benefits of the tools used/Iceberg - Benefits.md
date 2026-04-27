Tags: [[__Data_Engineering]], [[Object storage]] 
#DataEngineering #ObjectStorage 

# Enabling SQL
Iceberg stores tables metadata like Hive and enables running SQL queries on them. It is also more efficient than Hive.
# ACID transactions
Iceberg assures ACID when performing data transformations.
# Time travel (data versioning)
It keeps track of what changes happen to data and we can go back to the previous version of a table, before we made some changes.
# Functions for working with data
Iceberg provides useful functions, such as:
- Merge (combines insert, update and delete in one operation)
- Functions helping creating Slowly Changing Dimensions
# Protects data from corruption
- Our table is a folder consisting of multiple files. 
- Without Iceberg we might save a new file in that folder with different columns or data types in columns and that will break the table. 
- Iceberg makes sure problems like that don’t happen.
# Multi-engine support
Supports Spark, Flink, Trino, Presto, Hive, Impala
# Efficiency
Efficient metadata storage, updates and deletes for very big tables