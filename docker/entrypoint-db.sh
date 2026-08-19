#!/bin/bash
# ============================================================
# SQL Server Initialization Script for Docker
# ============================================================

# Start SQL Server process in background
/opt/mssql/bin/sqlservr &

# Wait until SQL Server is up and ready to accept TCP connections
echo "Waiting for SQL Server to start..."
for i in {1..60}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SQL Server is online and ready!"
        break
    fi
    sleep 2
done

# Run full database creation and sample data import
if [ -f /docker-entrypoint-initdb.d/full_database_nutrioverflow.sql ]; then
    echo "Importing NutriOverflow database schema and seed data..."
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i /docker-entrypoint-initdb.d/full_database_nutrioverflow.sql
    echo "NutriOverflow database successfully initialized!"
fi

# Keep container active
wait
