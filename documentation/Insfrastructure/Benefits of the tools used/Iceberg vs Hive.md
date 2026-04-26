Tags: [[_Iceberg]] [[__Data_Engineering]], [[Object storage]] [[_Hive]]
#Iceberg #DataEngineering #ObjectStorage #Hive 

# Introduction
Hive and Iceberg can be used together. Hive handles metadata about:
- table name
- table type
- table data location (where it is saved)

Iceberg handles metadata about:
- snapshots
- schema
- partitions
- version history

Iceberg can also handle metadata which Hive manages, so we can use either Iceberg alone or together with Hive.

Using Hive in addition to Iceberg has only benefits such as:
- There is more tools compatible with it and configuring them to use Hive is usually easier
- Hive stores metadata in a relational database (like MySQL, PostgreSQL) so it is easier to mange it (Iceberg stores that data in object storage)

Iceberg brings additional features to Hive such as ACID transactions or time travel.