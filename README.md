## Тестове завдання

> Назви таблиць/полів/функцій у завданні не сприймати «буквально», окрім явно вказаних назв та типів.

1. Створити партиціоновану таблицю `Т1` з полями: `дата`, `айді`, `сума`, `стан`, `гуід операції`, `повідомлення` (JSONB),
   де `повідомлення` включає номер рахунку, айді клієнта та тип операції (онлайн/офлайн).
2. Згенерувати дані для заповнення таблиці `Т1` за допомогою збереженої процедури чи функції
   (загалом не менше 100 тис. рядків за період три або чотири місяці).
3. Забезпечити унікальність даних по полю `гуід операції`.
4. Створити регламентне завдання, яке викликає функцію/процедуру додавання запису в таблицю `Т1` кожні `5` секунд зі `стан` = `0`.
5. Створити регламентне завдання, яке кожні `3` секунди оновлює поле `стан` таблиці `Т1` з `0` на `1` для парних та непарних `айді`
   (якщо кількість секунд парна — оновлюються парні айді; інакше — непарні).
6. Створити механізм зберігання поточної загальної суми поля `сума` по `айді клієнта` та `типу` операції у матеріалізованому представленні
   з оновленням при кожному переході `стан` таблиці `Т1` з `0` на `1`.
7. Налаштувати реплікацію створеної таблиці `Т1` на інший інстанс.

---

## Test Task (English)

> Do not treat table/field/function names literally, except where names and types are explicitly specified.

1. Create a partitioned table `T1` with fields: `date`, `id`, `amount`, `status`, `operation_guid`, `message` (JSONB),
   where `message` includes account number, customer id, and operation type (online/offline).
2. Generate data to populate table `T1` using a stored procedure or function
   (at least 100k rows in total over a period of three or four months).
3. Ensure uniqueness of data by the `operation_guid` field.
4. Create a scheduled job that calls the function/procedure to insert a record into table `T1` every `5` seconds with `status` = `0`.
5. Create a scheduled job that every `3` seconds updates the `status` field in table `T1` from `0` to `1` for even and odd `id`s
   (if the current seconds value is even — update even ids; otherwise — odd ids).
6. Create a mechanism to store the current total of the `amount` field by `customer id` and operation `type` in a materialized view,
   refreshing it on every change of `status` in table `T1` from `0` to `1`.
7. Configure replication of the created table `T1` to another instance.