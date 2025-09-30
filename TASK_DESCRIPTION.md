# PrivatBank Test Task

> **Note:** Table/field/function names in the task should not be taken literally, except where names and types are explicitly specified.

## 🇺🇦 Тестове завдання

### 📋 Вимоги до реалізації

#### 1. 📊 Створення партиціонованої таблиці
Створити партиціоновану таблицю `Т1` з полями:
- `дата` - дата операції
- `айді` - унікальний ідентифікатор
- `сума` - сума операції
- `стан` - статус операції
- `гуід операції` - унікальний GUID операції
- `повідомлення` (JSONB) - JSON об'єкт, що включає:
  - номер рахунку
  - айді клієнта
  - тип операції (онлайн/офлайн)

#### 2. 📈 Генерація тестових даних
Згенерувати дані для заповнення таблиці `Т1` за допомогою збереженої процедури чи функції:
- **Мінімум 100,000 рядків** загалом
- **Період**: три або чотири місяці
- **Розподіл**: рівномірний по датах

#### 3. 🔒 Забезпечення унікальності
Забезпечити унікальність даних по полю `гуід операції`:
- Унікальний GUID для кожної операції
- Обмеження на рівні бази даних

#### 4. ⏰ Регламентне завдання - Додавання записів
Створити регламентне завдання, яке:
- **Частота**: кожні 5 секунд
- **Дія**: викликає функцію/процедуру додавання запису в таблицю `Т1`
- **Статус**: `стан` = `0` (новий запис)

#### 5. 🔄 Регламентне завдання - Оновлення статусу
Створити регламентне завдання, яке:
- **Частота**: кожні 3 секунди
- **Дія**: оновлює поле `стан` таблиці `Т1` з `0` на `1`
- **Логіка**: 
  - Якщо кількість секунд **парна** → оновлюються **парні** айді
  - Якщо кількість секунд **непарна** → оновлюються **непарні** айді

#### 6. 📊 Матеріалізоване представлення
Створити механізм зберігання:
- **Дані**: поточна загальна сума поля `сума`
- **Групування**: по `айді клієнта` та `типу` операції
- **Оновлення**: при кожному переході `стан` таблиці `Т1` з `0` на `1`

#### 7. 🔄 Реплікація
Налаштувати реплікацію створеної таблиці `Т1` на інший інстанс:
- Синхронізація даних між інстансами
- Забезпечення надійності та відмовостійкості

---

## 🇬🇧 Test Task (English)

### 📋 Implementation Requirements

#### 1. 📊 Create Partitioned Table
Create a partitioned table `T1` with fields:
- `date` - operation date
- `id` - unique identifier
- `amount` - operation amount
- `status` - operation status
- `operation_guid` - unique operation GUID
- `message` (JSONB) - JSON object including:
  - account number
  - customer id
  - operation type (online/offline)

#### 2. 📈 Generate Test Data
Generate data to populate table `T1` using a stored procedure or function:
- **Minimum 100,000 rows** in total
- **Period**: three or four months
- **Distribution**: uniform across dates

#### 3. 🔒 Ensure Uniqueness
Ensure uniqueness of data by the `operation_guid` field:
- Unique GUID for each operation
- Database-level constraint

#### 4. ⏰ Scheduled Job - Insert Records
Create a scheduled job that:
- **Frequency**: every 5 seconds
- **Action**: calls function/procedure to insert record into table `T1`
- **Status**: `status` = `0` (new record)

#### 5. 🔄 Scheduled Job - Update Status
Create a scheduled job that:
- **Frequency**: every 3 seconds
- **Action**: updates `status` field in table `T1` from `0` to `1`
- **Logic**:
  - If current seconds value is **even** → update **even** ids
  - If current seconds value is **odd** → update **odd** ids

#### 6. 📊 Materialized View
Create a mechanism to store:
- **Data**: current total of `amount` field
- **Grouping**: by `customer id` and operation `type`
- **Refresh**: on every change of `status` in table `T1` from `0` to `1`

#### 7. 🔄 Replication
Configure replication of the created table `T1` to another instance:
- Data synchronization between instances
- Ensuring reliability and fault tolerance

---

## ✅ Implementation Status

All requirements have been successfully implemented and tested:

- ✅ **Partitioned table T1** - Monthly partitions by date
- ✅ **100k+ test data** - Generated over 3-4 months
- ✅ **Unique operation_guid** - UUID constraint
- ✅ **Scheduled insert job** - Every 5 seconds, status=0
- ✅ **Scheduled update job** - Every 3 seconds, even/odd pattern
- ✅ **Materialized view** - Customer totals with automatic refresh
- ✅ **Logical replication** - Table T1 replicated to standby instance