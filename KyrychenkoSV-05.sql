--Завдання 1
--Виберіть всі записи з таблиці "Wine" і додайте новий стовпець "PriceCategory". В цьому стовпці визначте категорію ціни вина за такими правилами:
--Якщо ціна вина менше або рівна 30, то категорія "Доступне вино".
--Якщо ціна вина більше 30 і менше або рівна 50, то категорія "Середня ціна".
--Якщо ціна вина більше 50, то категорія "Дороге вино".
SELECT *, case when Price <= 30 then 'Доступне вино' when Price > 30 and Price <= 50 then 'Середня ціна'  when Price > 50 then 'Дороге вино' else null end as PriceCategory FROM Wine;
--Виберіть всі записи з таблиці "Sales" і додайте новий стовпець "DiscountApplied". В цьому стовпці визначте, чи була надана знижка на продаж за такими правилами:
--Якщо кількість проданих пляшок вина більше або рівна 10, то знижка була надана (встановіть значення "Так").
--Якщо кількість проданих пляшок вина менше 10, то знижки не було (встановіть значення "Ні").
SELECT *, case when QuantitySold >= 10 then 'Так' else 'Ні' end as DiscountApplied FROM Sales;
--Знайдіть усіх клієнтів (ім'я та прізвище) з бази даних, які здійснили покупки (мають відповідні записи в таблиці "Sales"). 
--Використайте внутрішній підзапит для отримання списку унікальних клієнтів, які вже купували вино.
SELECT c.FirstName+' '+c.LastName from Customers c where EXISTS (select 1 from Sales s where c.CustomerID = s.CustomerID);
--Знайдіть назви всіх видів вина (стовпець "Type" з таблиці "Wine"), які були продані клієнтам з ім'ям "Гаррі". 
--Використайте внутрішній підзапит для вибору відповідних записів з таблиці "Sales" та потім з'єднайте їх з таблицею "Wine", щоб отримати назви видів вина.
SELECT w.Type from Wine w where EXISTS (select 1 from Sales s where s.CustomerID in (SELECT CustomerID from Customers where FirstName='Гаррі') and s.WineID = w.ID)
--Знайдіть всі записи з таблиці "Purchases", де кількість придбаних пляшок вина перевищує середню кількість придбаних пляшок вина для всіх покупок. 
--Використайте внутрішній підзапит для обчислення середньої кількості придбаних пляшок вина, 
--а потім використовуйте це значення в умові для вибору відповідних записів з таблиці "Purchases".
SELECT * FROM Purchases tp WHERE tp.QuantityPurchased > (select avg(QuantityPurchased) from Purchases);
--Виберіть клієнтів, які зробили понад 5 покупок.
select t.Client from (SELECT c.FirstName+' '+c.LastName as Client, row_number() OVER(PARTITION BY c.CustomerID ORDER BY s.SaleID) as QuantitySales
                      FROM Customers c RIGHT JOIN Sales s ON c.CustomerID = s.CustomerID) t where t.QuantitySales > 5;
--Виберіть всі вина, ціна яких менше середньої ціни для всіх вин.
select * from Wine where Price < (select avg(Price) from Wine);

--Завдання 2
--Порахувати, скільки разів кожна книга була замовлена і вивести інформацію про кожну книгу разом із іменем її автора. 
--Результат сортувати за фаміліями авторів та назвами книг.
select a.name_author, b.title, count( bb.buy_id),/*або*/sum(bb.amount)
  from buy_book bb join book b on bb.book_id = b.book_id join author a on a.author_id = b.author_id 
 group by a.name_author, b.title 
 order by a.name_author, b.title

--Вивести список міст, в яких живуть клієнти, що робили замовлення в інтернет-магазині, та підрахувати кількість замовлень в кожному місті. 
--Результат сортувати за спаданням кількості замовлень, а потім за алфавітом назв міст.
select ct.name_city, count(b.buy_id) 
  from buy b join client c on c.client_id = b.client_id join city ct on ct.city_id = c.city_id 
 group by ct.name_city
 order by 2 desc, 1

--Вивести номери всіх оплачених замовлень та дати їх оплати.
select b.buy_id, bs.date_step_end from buy b join buy_step bs on b.buy_id = bs.buy_id and bs.date_step_end is not null join step s on bs.step_id = s.step_id and s.name_step = 'Оплата';

--Вивести інформацію про кожне замовлення: його номер, хто зробив замовлення (фамілія клієнта) та його вартість (сума кількостей замовлених книг та їх цін). 
--Результат сортувати за номером замовлення.
select b.buy_id, c.name_client, sum(bb.amount * bk.price)
 from buy b join client c on b.client_id = c.client_id join buy_book bb on b.buy_id = bb.buy_id join book bk on bb.book_id = bk.book_id
group by  b.buy_id, c.name_client
 order by 1

--Вивести номери замовлень та етапи, на яких вони знаходяться в даний момент, за умови, що замовлення ще не доставлені. 
--Результат сортувати за зростанням номерів замовлень.
select b.buy_id, s.name_step from buy b join buy_step bs on b.buy_id = bs.buy_id and bs.date_step_end is null and bs.date_step_beg is not null join step s on bs.step_id = s.step_id;

--Для кожного міста в таблиці "city" зазначено кількість днів, за які можливо доставити замовлення в це місто (розглядається лише етап "Транспортування"). 
--Для замовлень, які пройшли етап транспортування, вивести кількість днів, за які замовлення було реально доставлено до міста, 
--а також, якщо замовлення було доставлено з запізненням, вказати кількість днів затримки; в іншому випадку вивести 0. 
--Включити номер замовлення (buy_id) та обчислені стовпці "Кількість_днів" та "Затримка". Результат сортувати за номером замовлення.
select tb.buy_id, tb.cd as "Кількість_днів", iif(tb.dd<tb.cd,tb.cd - tb.dd,0) as "Затримка" from (
select b.buy_id, DATEDIFF(day, bs.date_step_beg,bs.date_step_end) as cd,
       (select max(days_delivery) from client c join city ct on c.city_id = ct.city_id where c.client_id = b.client_id) as dd  
  from buy b join buy_step bs on b.buy_id = bs.buy_id and bs.date_step_end is not null join step s on s.step_id = bs.step_id and s.name_step = 'Транспортування') tb

--Вибрати всіх клієнтів, які робили замовлення книг Тараса Шевченка та вивести їх інформацію в алфавітному порядку. Використовуйте фамілію автора, а не його ідентифікатор.
select (select cl.name_client from client cl where cl.client_id = b.client_id) 
  from buy b join buy_book bb on b.buy_id = bb.buy_id join book bk on bb.book_id = bk.book_id join author a on bk.author_id = a.author_id and a.name_author = 'Тарас Шевченко'
  order by 1;

--Вивести жанр (або жанри), в яких було замовлено найбільше кількість книг, та зазначити цю кількість. Останній стовпець назвати "Кількість".
select g.name_genre, sum(bb.amount) as "Кількість" from buy_book bb join book bk on bb.book_id = bk.book_id join genre g on bk.genre_id = g.genre_id
 group by g.name_genre;

--Порівняти щомісячний дохід від продажу книг за поточний та попередній роки. 
--Для цього вивести рік, місяць та суму доходу, спершу за зростанням місяців, а потім за зростанням років. Назви стовпців: "Рік", "Місяць", "Сума".
select year(bs.date_step_end), month(bs.date_step_end),  sum(bk.price*bbk.amount) 
  from buy b 
  join buy_step bs on b.buy_id = bs.buy_id 
  join step s on s.step_id = bs.step_id and bs.date_step_end is not null and s.name_step = 'Оплата'--and (year(bs.date_step_end) = year(GETDATE()) or year(bs.date_step_end) = year(GETDATE())-1)
  join buy_book bbk on b.buy_id = bbk.book_id
  join book bk on bbk.book_id = bk.book_id
  group by year(bs.date_step_end), month(bs.date_step_end) 
  order by 2, 1;

--Для кожної окремої книги вивести інформацію про кількість проданих копій та їх вартість за 2020 і 2019 роки. 
--Обчислювані стовпці назвати "Кількість" і "Сума". Інформацію сортувати за спаданням вартості.
select bbk.book_id, year(bs.date_step_end), sum(bbk.amount) as "Кількість", sum(bbk.amount*bk.price) as "Сума"
  from buy b 
  join buy_step bs on b.buy_id = bs.buy_id 
  join step s on s.step_id = bs.step_id and bs.date_step_end is not null and s.name_step = 'Оплата'--and (year(bs.date_step_end) = year(GETDATE()) or year(bs.date_step_end) = year(GETDATE())-1)
  join buy_book bbk on b.buy_id = bbk.book_id
  join book bk on bbk.book_id = bk.book_id
  group by bbk.book_id, year(bs.date_step_end)
  order by 4