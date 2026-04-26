Tags: [[__Data_Engineering]]
#DataEngineering 

# Introduction
Instead of writing all the data into one big table/file, we split it into logical chunks (partitions) based on a column.
### Example (by date)
Instead of:
```
/data/sales/  
  data.parquet
```

We write:
```
/data/sales/  
  date=2026-04-10/  
  date=2026-04-11/  
  date=2026-04-12/
```

Each folder = a partition
# Why this matters (3 core reasons)
## 1. Idempotency
Using partitioning, we can create an idempotent ([[Data Engineering - Idempotency|link]]) pipeline which appends new data to a table by overwriting a specific partition instead of just appending new records.

For example, when we add data for a specific date, we replace (if exists) a partition with data for that date.
## 2. Performance
Engines like Apache Spark don’t scan everything but only a relevant partitions. 
### Selecting data
If we select data:
```sql
SELECT * FROM sales WHERE date = '2026-04-10'
```

then we only read one partition instead of all:
```
date=2026-04-10/
```

This is called **partition pruning**
### Updating data
When we want to update a table, then instead of overwriting an entire table we overwrite only an updated partitions.
### Parallel processing
Different partitions can be processed in parallel on different servers what is faster when working with big datasets.

It is used when performing any operations, like aggregations.
## 3. Backfills & Incremental processing
We can process data slice by slice:
- Incremental processing → perform calculations only on one partition, e.g. `2026-04-11`
- Backfill ([[Data Engineering - Backfills|link]]) → process only a part of all the past partitions, e.g. March `2026-03-*`
# How it works in practice (Spark example)
In Spark we run:
```
df.write \  
  .mode("overwrite") \  
  .partitionBy("date") \  
  .parquet("/data/sales")
```
and this creates:
```
/data/sales/date=2026-04-10/  
/data/sales/date=2026-04-11/
```
# Common Problems (and how to think about them)
## 1. Wrong partition key (too big cardinality)
If we use a key with a too big cardinality, like `user_id`, we will get too many tiny partitions what gives bad performance.

It is better to use fields like:
- `date` (most common)
- `region`
- `event_type` (sometimes)

Rule:
> Partition by columns used in filters AND with reasonable cardinality
## 2. Small Files Problem
Too many small files per partition:
```
date=2026-04-10/  
  part-0001.parquet  
  part-0002.parquet  
  ...  
  part-9999.parquet
```

Why it’s bad:
- Metadata overhead
- Slow reads

Fix:
- Repartition before write:
```
df.repartition(10, "date")
```
## 3. Skewed partitions
Skewed partitions refers to a situation when some partitions are very small while others are very big, for example:
- One date has 1B rows
- Others have 1K rows

That causes uneven processing.

Fix:
- Add secondary partitioning
- Or use clustering (e.g. Z-order in Delta)
# Partitioning vs Table Formats
Modern systems like:
- Delta Lake ([[_Delta_lake|link]])
- Apache Iceberg ([[_Iceberg|link]])

add:
- Metadata tracking
- ACID transactions
- Smarter partition handling

Without them:
- We manually manage files

With them:
- We think in tables, not files
# Best Practices
- Partition by time (almost always)
- Keep partition size ~100MB–1GB
- Avoid high-cardinality partitions
- Always design for reprocessing
- Combine with:
    - Upserts
    - Deduplication
    - Data versioning