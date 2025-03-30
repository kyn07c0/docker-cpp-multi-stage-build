#include <iostream>
#include <soci/soci.h>
#include <soci/postgresql/soci-postgresql.h>
#include <clickhouse/client.h>

int main()
{
    try
    {
        // Создаем сессию для подключения к PostgreSQL
        soci::session sql(soci::postgresql, "dbname=test user=postgres password=xyTcV3Q7 host=192.168.88.100 port=5432");

        // Пример выполнения SQL-запроса
        int count;
        sql << "SELECT COUNT(*) FROM public.users", soci::into(count);

        std::cout << "[PostgreSQL]\t Number of rows in users table: " << count << std::endl;
    }
    catch (const std::exception& e)
    {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    try
    {
        clickhouse::Client client(clickhouse::ClientOptions().SetHost("192.168.88.100").SetUser("default").SetPassword("xyTcV3Q7"));
        std::string query = "SELECT name FROM system.databases";

        client.Select(query, [](const clickhouse::Block &block)
        {
            for (size_t i = 0; i < block.GetRowCount(); ++i)
            {
                std::cout << "[ClickHouse]\t Database name: " << block[0]->As<clickhouse::ColumnString>()->At(i) << std::endl;
            }
        });

    }
    catch (const std::exception& e)
    {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }


    return 0;
}
