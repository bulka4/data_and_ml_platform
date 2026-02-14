FROM apache/hive:standalone-metastore-4.2.0

# Set environment variable for JDBC driver version
ENV PG_DRIVER_VERSION=42.6.0

# Download PostgreSQL JDBC driver. It is needed for Hive to connect to the PostgreSQL metadata db.
# Put it into the /opt/hive/lib folder because Hive loads automatically all the JARs from that folder.
RUN curl -L https://jdbc.postgresql.org/download/postgresql-${PG_DRIVER_VERSION}.jar \
    -o /opt/hive/lib/postgresql-${PG_DRIVER_VERSION}.jar

# Entrypoint for debugging
# ENTRYPOINT ["sh"]