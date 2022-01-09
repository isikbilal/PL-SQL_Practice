--TYPE kullanýmý
DECLARE -- Declare ile deðiþkenler tanýmlanýr.
    L_MESSAGE CONSTANT VARCHAR2(10) := 'MERHABA'; --Deðerinin sabit olarak kalmasýný istediðimiz bir deðiþken oluþtururken CONSTANT kelimesi kullanýlýr. Sabitlerin deðiþkenlerden farký bununla birlikte ilk deðer atamasýnýn hemen yapýlmasýdýr.
    L_LAST_NAME VARCHAR2(20);-- Local bir deðiþken tanýmlarken isminden anlayabilmek için baþýna L koyabiliriz standart olarak. PL/SQL de deðiþkenlerin kapsamý global ve local olmak üzere 2 çeþittir.Local deðiþkenler içteki(inner) bloklarda kullanýlýr ve dýþtaki bloklarda kullanýlmaz.Global deðiþkenler ise her tarafta kullanýlabilir. Yani aslýnda bizim bu satýrda oluþturduklarýmýz baþýnda L harfi olmasýna raðmen global deðiþken. Çünkü en dýþta tanýmladýk. Ýçteki Begin-End'lerden birinde tnaýmlasaydýk local deðiþken olurdu.
    L_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE; --Bir deðiþkenimizin tipinin sabit olarak verilmesi ileride sorun oluþturabilir. Mesela L_LAST_NAME VARCHAR2(20) dersek soyisim alaný 20 karakteri geçince uygulamamýz patlar. Bunu engellemek için deðiþken tipinii doðrudan db deki iliþkili olduðu kolondan alsýn diyebiliyoruz.
    
BEGIN
    L_NAME := 'ALI'; --L_NAME deðiþkenini yukarýda CONSTANT olarak tanýmlamadýðýmýz için bu iç block da deðerini atayabildik. Sabit(constant) olarak tanýmlasaydýk en baþta deðerini atamamýz gerekcekti.
    --L_MESSAGE := 'HELLO'; -- Burada L_MESSAGE deðerine atama yapmak istersek hata veriyor. Çünkü yukarýda constant olarak tanýmladýk.
    DBMS_OUTPUT.PUT_LINE(L_MESSAGE || ' ' || L_LAST_NAME); -- Bu fonksiyon tek bir parametre alýr. Doalyýsýyla vermek istediðimiz tüm parametreleri birleþtirerek buraya tek bir parametre olarak vermemiz lazým. Concat (||) ile birþetirebiliriz string ifadeleri.
    --NULL; -- Begin - End arasý boþ kalamaz. Eðer hiçbirþey yaptýrmak istemiyorsak Begin-End arasýna null; koyabiliriz.
END;


/******************************************************************************************************************************************************************************/


--ROWTYPE ve INTO kullanýmý
DECLARE
    L_EMPLOYEE EMPLOYEES%ROWTYPE; -- Employees tablosundaki tek bir satýrý temsil eden L_EMPLOYEE adlý bir deðiþken oluþturduk. Yani tek bir kolon veya hücre deðil, bütün bir satýr içerisindeki bilgileri atabileceðimiz bir deðiþken.
    L_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE :=100;

BEGIN
    SELECT * INTO L_EMPLOYEE -- Sorgu sonucunda gelen veriyi INTO ifadesi ile doðrudan baþka bir deðiþkene atabiliyoruz. Yani INTO ifadesi ile EMPLOYEES tablosundan gelen sonucun satýrlarýný direkt L_EMPLOYEE deðiþkenine atabiliyoruz.
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = L_EMPLOYEE_ID; -- PL SQL içerisinde (DECLARE) yaptýðýmýz tanýmlamalarý SQL (WHERE) içerisinde kullanabiliyoruz. Yani declare ifadesi Pl sql diline aittir ve burada tanýmladýðýmýz L_EMPLOYEE_ID deðiþkenini, Begin-End bloðu içerisindeki ANSI SQL diline ait olan where ifadesi ile birlikte kullanabildik.
    DBMS_OUTPUT.PUT_LINE(L_EMPLOYEE.FIRST_NAME || ' ' || L_EMPLOYEE.LAST_NAME);
END; --Burada PL SQL'in SQL ile entegre çalýþma özelliði sayesinde 4 satýrda yaptýðýmýz iþlemleri SQL ile entegre çalýþmayan diðer db dillerinde belkide 15 satýrda yapabilirdik, çoklamamýz gerekebilirdi sorgularý.

SELECT * FROM EMPLOYEES;



/******************************************************************************************************************************************************************************/


--ROWTYPE kullanrak db ye kayýt ekleme uygulamasý.

SELECT * FROM JOBS WHERE JOB_ID = 'TR_ACCOUNT';

DECLARE
    L_JOB JOBS%ROWTYPE;

BEGIN
    L_JOB.JOB_ID := 'TR_ACCOUNT';
    L_JOB.JOB_TITLE := 'Türkiye Muhasebe';
    L_JOB.MIN_SALARY := '3000';
    L_JOB.MAX_SALARY := '6000';
    
    INSERT INTO JOBS VALUES L_JOB; -- JOBS tablosuna INSERT INTO ile direk yukarýda deðerlerini tanýmladýðýmýz L_JOB satýrýmýzý verebiliyoruz
    --INSERT INTO JOBS VALUES (L_JOB.JOB_ID, L_JOB.JOB_TITLE, L_JOB.MIN_SALARY, L_JOB.MAX_SALARY); -- Eðer L_JOB ifadesini direkt satýr olarak veremeseydik insert iþlemini bu þekilde yapmak zorunda kalacaktýk.
    COMMIT;

END;


/******************************************************************************************************************************************************************************/


--Cursor uygulamasý. (implicit & explicit) gizli ve açýk cursorlar:
-- SELECT, INSERT, UPDATE, DELETE gibi DML ifadelerinin çalýþmasý sýrasýnda db nin arkplanda oluþturduðu cursor'a implicit(gizli) cursor deriz.
--Bu cursor doðrudan kullanýcý olarak bizim yönettiðimiz bir cursor deðil. Db bunu kendi içerisinde yönetiyor.
--Bu cursor ile ilgili bazý bilgileri çeþitli ifadeler kullanarak alabiliyoruz:
--DBMS_OUTPUT.PUT_LINE(
    --sql%rowcount -- Son çalýþan sql ifadesi kaç tane kayda dokundu? Kaç kayýt üzerinde iþlem yaptý onu verir.
    --sql%found -- Son çalýþan sql ifadesi bir kayýt buldu mu?
    --sql%notfound - Bu ifade, sql%found'un  tersidir. INSERT, UPDATE veya DELETE ifadeleri hiçbir satýrý etkilemediyse veya SELECT INTO ifadesi satýr döndürmediyse TRUE sonucunu verir. Aksi takdirde, FAlSE verir.
    --sql%isopen); -- Bu deðer implicit cursor'larda her zaman False deðerini verir. Çünkü sadece sorgu çalýþtýðý sýrada açýktýr. Sorgu bitince kapanýr. Dolayýsýyla biz hep kapalý halini görürüz.
    --commit; -- Bu ifadeleri db ye birþey kayýt ettðimizde yada select attýðýmýzda kayýt geldi mi gelmedimi? geldiyse kaç tane geldi vs. gibi bilgilere ihtiyacýmýz olduðunda kullanýrýz.
    

SELECT * FROM JOBS WHERE JOB_ID = 'TR_ACCOUNT';

DECLARE
LJOB JOBS%ROWTYPE; --Bir satýrdaki tüm kolonlarý temsil eden tek bir kayýtlýk bir local deðiþken (LJOB) tanýmladýk

BEGIN
    LJOB.JOB_ID := 'TR_ACCNT2';
    LJOB.JOB_TITLE := 'Türkiye Muhasebe';
    LJOB.MIN_SALARY := 3000;
    LJOB.MAX_SALARY := 6000;

    INSERT INTO JOBS VALUES LJOB; -- Yukarýda LJOB'ýn alanlarýný (kolonlarýný) tanýmladýktan sonra insert ederken VALUES kýsmýna direk satýrý temsil eden deðiþkeni (LJOB) verebiliyoruz
    dbms_output.put_line('Girilen kayýt sayýsý'||sql%rowcount); 
    commit;
END; -- Çalýþmadý PK sonundan dolayý


/******************************************************************************************************************************************************************************/


--Ýmplicit (gizli) cursor örneði
SELECT * FROM EMPLOYEES ORDER BY DEPARTMENT_ID;

declare
  lDepartmentId employees.department_id%type := -50;
begin

  update employees 
  set commission_pct = 0.2
  where department_id = lDepartmentId;

  if sql%notfound then
    dbms_output.put_line('Herhangi bir güncelleme yapýlmamýþtýr');
  else
    dbms_output.put_line('Guncellenen kayýt sayýsý : '||sql%rowcount);
  end if;  
    
  commit;
end;

/******************************************************************************************************************************************************************************/

--Explicit (açýk) cursorlar:

--Bir ANSI SQL ifadesini PL SQL diline ait bir ifade kullanmadan da çalýþtýrabiliriz.
--Fakat yapacaðýmýz iþlem çok büyükse ve biz bunu parça parça yapmak istiyorsak o zaman ANSI SQL ifadeleri bu parçalamayý yapamayabilir.
--Mesela çok büyük miktarda veri varsa ve biz milyon satýrlýk bir insert veya update iþlemi yapacaksak; 
--Bunu tek seferde yapmamýz hem sisteme çok büyük yük bindirir, hem de bu iþlemin baþarýlý bitme ihtimali çok düþüktür. Yüksek ihtimalle biryerlerde hata verecektir.
--Ayrýca bir bu update ve ya insert ifadesinin çalýþtýrýrken db de bütün update ettiðimiz ifadelerin eski halleri (izleri) Oracle'ýn log tablolarýna yazýlýyor.
--Doalyýsýyla çok büyük miktarda commit edilmemiþ veriyi bekletirsek bu log tablolarý ve tablespace'leri þiþer ve bir süre sonra hata almaya baþlarýz.
--O yüzden biz peyderper, yani parçalý bir þekilde iþlemelrimizi yürütmek zorundayýz. 
--Bununla birlikte SQL ile bir iþlem yapýp da saatler sonra sonucunu görmek yerine, aþama aþama geliþmeyi de görmek isteriz. Ýþlem týkandý mý? kesildi mi? devam ediyor mu? bunu bilemeyiz.
--Eðer iþlemler arasýna belli periyotlarla commit'lerimizi mesajlarýmýzý koyarsak yapýlan iþlemlerin devam ettiðini anlayabiliriz.
--Bu yüzden bazý durumlarda kayýtlar üzerinde dolaþýrken toplu bir þekilde (bulk) iþlemler (update, insert vs.) yapmak yerine, kayýt kayýt dolaþýp o þekilde iþlemler yapmamýz gerekebilir.
--Aþaðýda bu tip durumlar için yapýlmýþ çeþitli explicit cursor uygulama örnekleri mevcuttur:


-- Her çalýþanýn maaþ durumunu aldýðý maaþa göre; 6000 tl'nin üzeri, 6000 tl'ye eþit ve 6000 tl'nin altý olarak yazdýralým:
SELECT * FROM EMPLOYEES;

DECLARE
    
    CURSOR C1 IS SELECT * FROM EMPLOYEES; -- EMPLOYEES talosundaki· tüm kayitlari i·çeren bi·r CURSOR oluþturduk. Bu cursor ile employees tablomuzdaki kayýtlarý tek tek dolaþmak istiyoruz.
    L_STATUS VARCHAR2(100);
    
BEGIN
    FOR L_C1 IN C1 LOOP -- Burada C1 dediðimiz þey cursor, yani employees tablosuna ait tüm kayýtlar. L_C1 ise her bir döngü de o an için elimde olan kayýt. Yani Python'daki "for i in list:" ifadesi gibi
        IF L_C1.SALARY < 6000 THEN
            L_STATUS := '6000''DEN KÜÇÜK'; -- String bir ifade içerisinde týrnak iþareti kullanmak istediðimizde iki tane týrnak koyarýz.
            
        ELSIF L_C1.SALARY = 6000 THEN
            L_STATUS := '6000'' E EÞÝT';
            
        ELSE
            L_STATUS := '6000''DEN BÜYÜK';
        END IF;
        
    DBMS_OUTPUT.PUT_LINE(RPAD(L_C1.FIRST_NAME || ' ' || L_C1.LAST_NAME,25) || L_STATUS); -- RPAD ve LPAD ile String ifadelerin saðýna veya soluna boþluklar ekleyerek output da daha düzgün görünmesini saðlayabiliriz. 25 deðeri de kaç tane boþluk olacaðýný söylüyor. 
    
    END LOOP;
    
END; -- Bu örnekte EMPLOYEES tablosundaki sayýsý az olan veriler üzerinde iþlem yaptýk. Bunu pl sql'e ait CURSOR özelliðini kullanmadan ANSI SQL deki CASE WHEN ile de yapabilirdik.
--Ama çok büyük boyutlu verilerde cursor kullanamdan yapamayýz. Örneðin Türk Telekom'un 20 milyon abonesi var. Her abone için her ay fatura hesaplanmasý gerekiyor. Bu iþlemi pl sql deki cursor yardýmýyla yapabiliriz ancak.
    
SELECT ' '||LPAD('ISTANBUL', 20, '*')|| ' ' FROM DUAL; -- Sadece boþluk deðil baþka ifadelerle de doldurabiliriz. TRIM, LTRIM, RTRIM ifadeleri de tam tersine boþluk veya baþka bir karakteri saðdan yada soldan silmek için kullanýlýr.   

/******************************************************************************************************************************************************************************/


--EMPLOYEES tablosundaki çalýþanlarýn, departman bazýnda maaþ toplamlarýný, DEPT_SUMMARY tablosuna, ayný þekilde departman bazýnda ekleyen uygulama.

CREATE TABLE DEPT_SUMMARY -- TAbloyu oluþturuyoruz
(
    DEPARTMENT_ID NUMBER(4),
    TOTAL_SALARY NUMBER(8,2)
);

DELETE FROM DEPT_SUMMARY; -- Ýçinde kayýt varsa boþaltýyoruz.


INSERT INTO DEPT_SUMMARY
SELECT DEPARTMENT_ID, SUM(SALARY) 
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID; 

ALTER TABLE DEPT_SUMMARY DROP COLUMN PERSONEL_COUNT; --fazladan oluþan kolonu silmek için

ALTER TABLE DEPT_SUMMARY ADD PERSONEL_COUNT NUMBER(4); --tekrar ekledik ayný kolonu

SELECT * FROM DEPT_SUMMARY;

SELECT * FROM EMPLOYEES;

DECLARE
    CURSOR C1 IS SELECT * FROM EMPLOYEES;
    
BEGIN
    FOR L_C1 IN C1 LOOP
        --1.YOL: Önce kaydý güncellemeye çalýþ, eðer yoksa kaydý oluþtur.
        --2.YOl: Önce kaydý oluþturmaya çalýþ, eðer varsa kaydý güncelle.
        --Burada doðru olan yol 1. yoldur. Çünkü kayýt oluþturma iþlemi sadece tablo boþ olduðunda bir kere yapýlacak, sonrasýnda hep insert yapýlacak. O yüzden boþu boþuna her seferinde kayýt oluþturmayý denememek için, önce güncelleyip yoksa kayýt oluþturan 1. yolu tercih etmek daha az maliyetli olacaktýr.

        UPDATE DEPT_SUMMARY
        SET TOTAL_SALARY= TOTAL_SALARY + L_C1.SALARY, 
        PERSONEL_COUNT = PERSONEL_COUNT + 1 -- Toplam personel sayýsýný yazdýrýrken EMPLOYEES tablosunda SALARY bilgisi gibi elimizde personel sayýsýný tutan bir kolon olmadýðý için, PERSONEL_COUNT'u bir kolon deðeri ile toplamak yerine her döngüde elimizde 1 personel olduðu için perosneli 1 arttýrdýk.
        WHERE DEPARTMENT_ID = L_C1.DEPARTMENT_ID;
        
        IF SQL%ROWCOUNT = 0 THEN
        
            INSERT INTO DEPT_SUMMARY VALUES (L_C1.DEPARTMENT_ID, L_C1.SALARY, 1);--Ýlk kiþi PERSONEL_COUNT = 1
        
        END IF;
        
    END LOOP;

END;

SELECT * FROM DEPT_SUMMARY ORDER BY DEPARTMENT_ID;

SELECT DEPARTMENT_ID, SUM(SALARY), count(*) FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID ORDER BY DEPARTMENT_ID; -- SUM fonksyonu tek baþýna kullanýlmýyor, group by ile kullanýlmalýdýr.



/******************************************************************************************************************************************************************************/



--Çalýþanlarýn isim, soyisim ve toplam çalýþma süresini hesaplayan ve ekrana yazan uygulama
SELECT * FROM JOB_HISTORY;

SELECT * FROM EMPLOYEES; 

DECLARE
    CURSOR C1 IS SELECT * FROM EMPLOYEES;
    L_CALISMA_SURESI NUMBER; -- Parantez içinde deðer vermeyince sýnýrsýz mý oluyor Number alaný ---> ???
    
    

BEGIN
    FOR L_C1 IN C1 LOOP
    
        SELECT SUM(END_DATE - START_DATE) INTO L_CALISMA_SURESI -- INTO ile SELECT sonucunu oluþturduðumuz bir deðiþkene (L_CALISMA_SURESI) atabiliriz. SUM kullanmamýzýn sebebi de bir personel(EMPLOYEE_ID) birden fazla title ile birden fazla pozisyondan çalýþmýþ olabilir. Mesela EMPLOYEE_ID'si 101 olan kiþi bir süre AC_ACCOUNT olarak, bir süre de AC_MGR olarak çalýþmýþ. Yani kiþi bazlý toplam süreyi alabilmek için SUM kullandýk. Ýfadeyi SELECT ....INTO L_CALISMA_SURESI þeklinde kullandýðýmýz için L_CALISMA_SURESI deðiþkenine tek bir kayýt atabiliriz. Bu ifade birden fazla kaydý desteklemez.  
        FROM JOB_HISTORY
        WHERE EMPLOYEE_ID = L_C1.EMPLOYEE_ID; 
        DBMS_OUTPUT.PUT_LINE(L_C1.FIRST_NAME || ' ' || L_C1.LAST_NAME || ' '||L_CALISMA_SURESI); 
    END LOOP;
END;



/******************************************************************************************************************************************************************************/



-- Herhangi bir çalýþaný olmayan Job'larý listeleyen uygulama.

-- Aþaðýdaki sorgu ile EMPLOYEES tablosunda olup da JOBS tablosunda olmayan JOB_ID'leri bulduk.
SELECT JOB_ID FROM JOBS MINUS -- MINUS ile iki SELECT sonucu arasýndaki farký alabiliyoruz.
SELECT DISTINCT JOB_ID FROM EMPLOYEES; -- Çalýþanlarýn ünvanlarý. DISTINCT ile tekrar eden ünvanlarý çýkardýk.


DECLARE
    CURSOR C1 IS SELECT * FROM JOBS;
    L_CALISAN_SAYISI NUMBER; -- Parantez içinde deðer vermeyince sýnýrsýz mý oluyor Number alaný ---> ???  

BEGIN
    FOR L_C1 IN C1 LOOP
    
        SELECT COUNT(*) INTO L_CALISAN_SAYISI -- INTO ile SELECT sonucunu oluþturduðumuz bir deðiþkene (L_CALISMA_SURESI) atabiliriz. SUM kullanmamýzýn sebebi de bir personel(EMPLOYEE_ID) birden fazla title ile birden fazla pozisyondan çalýþmýþ olabilir. Mesela EMPLOYEE_ID'si 101 olan kiþi bir süre AC_ACCOUNT olarak, bir süre de AC_MGR olarak çalýþmýþ. Yani kiþi bazlý toplam süreyi alabilmek için SUM kullandýk. Ýfadeyi SELECT ....INTO L_CALISMA_SURESI þeklinde kullandýðýmýz için L_CALISMA_SURESI deðiþkenine tek bir kayýt atabiliriz. Bu ifade birden fazla kaydý desteklemez.  
        FROM EMPLOYEES
        WHERE JOB_ID = L_C1.JOB_ID; 
         
    
        IF L_CALISAN_SAYISI = 0 THEN 
            DBMS_OUTPUT.PUT_LINE(L_C1.JOB_ID || ' ' || L_C1.JOB_TITLE);
        END IF;
    END LOOP;
END;

SELECT * FROM JOBS;

SELECT * FROM EMPLOYEES;


/******************************************************************************************************************************************************************************/


--1.Gün klasöründeki ornek10.bmp resmindeki gibi bir örnek rapor çýktýsýný oluþturacak uygulama.
--Her departmanýn ismi ve altýnda da bu departmanda çalýþanlarýn ad, soyad, iþe giriþ tarihi ve telefon numarasý bilgileri olacak.

SELECT * FROM DEPARTMENTS;

DECLARE
    CURSOR C1 IS SELECT * FROM DEPARTMENTS;
    CURSOR C2 IS SELECT * FROM EMPLOYEES;
    
    L_DEPARTMENT_NAME VARCHAR2(20);

BEGIN
    FOR L_C1 IN C1 LOOP
    
        DBMS_OUTPUT.PUT_LINE('Department Name '||' '||L_C1.DEPARTMENT_NAME);
        DBMS_OUTPUT.PUT_LINE('--------------------------------');
        DBMS_OUTPUT.PUT_LINE('Name                                 Hire Date         Phone Number');
        
        FOR L_C2 IN C2 LOOP
            IF L_C1.DEPARTMENT_ID = L_C2.DEPARTMENT_ID THEN -- 1.yol: C1 ile C2'nin departman id'leri aynýysa yazdýr diye þart koyabiliriz.
                DBMS_OUTPUT.PUT_LINE(L_C2.FIRST_NAME||' '||L_C2.LAST_NAME||' '||L_C2.HIRE_DATE||' '||L_C2.PHONE_NUMBER);
            END IF;
        END LOOP;

    END LOOP;
END;

SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID IN (120,130,140,150,160,170); -- Ýçinde hiçkimsenin çalýþmadýðý departmanlar da var.


/******************************************************************************************************************************************************************************/

-- 2.yol: For döngüsünün içerisine if koymak yerine, Cursor'a parametre vererek yapabiliriz.

DECLARE
    CURSOR C1 IS SELECT * FROM DEPARTMENTS; --Alt satýrda C2 cursor'umuza WHERE þartý koyduk. Artýk bu cursor bizim þartýmýza göre açýlýp çalýþacak.
    CURSOR C2(PRM_DEPARTMENT_ID EMPLOYEES.DEPARTMENT_ID%TYPE) IS SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = PRM_DEPARTMENT_ID;
    
    L_DEPARTMENT_NAME VARCHAR2(20);

BEGIN
    FOR L_C1 IN C1 LOOP
    
        DBMS_OUTPUT.PUT_LINE('Department Name '||' '||L_C1.DEPARTMENT_NAME);
        DBMS_OUTPUT.PUT_LINE('--------------------------------');
        DBMS_OUTPUT.PUT_LINE('Name                Hire Date         Phone Number');
        
        FOR L_C2 IN C2(L_C1.DEPARTMENT_ID) LOOP -- Burada for döngüsü içerisine if þartý koymak yerine, C2 parametresine o an dýþ döngüdeki C1'in içinde hangi DEPARTMENT_ID deðeri varsa onu veriyoruz ki eþleþebilsin. Mesela dýþ döngünün ilk turunda L_C1'in içindeki DEPARTMENT_ID deðeri 10'dur. Biz de iç dögüde 10 deðerini vermeliyiz ki 10 nolu departmandaki çalýþanlarý alabilelim ilk turda.
            DBMS_OUTPUT.PUT_LINE(L_C2.FIRST_NAME||' '||L_C2.LAST_NAME||' '||L_C2.HIRE_DATE||' '||L_C2.PHONE_NUMBER);  
        END LOOP;

    END LOOP;
END;



/******************************************************************************************************************************************************************************/


--Zam yapan Procedure örneði: Hata verdi bazý yerlerde tam çalýþmadý sebebini bulamadým.
create or replace procedure salary_add (
    prm_employee_id IN employees.employee_id%type, 
    prm_rate IN number,
    prm_response_code OUT varchar2
) is
begin
  
  update employees
  set salary = salary + salary * prm_rate / 100
  where employee_id = prm_employee_id;
  
  if sql%rowcount = 1 then
    prm_response_code := PCK_SABITLER.C_RC_SUCCESS;
  elsif sql%rowcount = 0 then
    prm_response_code := PCK_SABITLER.C_RC_KAYIT_BULUNAMADI;
  elsif sql%rowcount > 1 then
    prm_response_code := PCK_SABITLER.C_RC_BIRDEN_FAZLA_KAYIT;
  end if;
  
  if prm_response_code = PCK_SABITLER.C_RC_SUCCESS then
    commit;
  else
    rollback;
    insert into hata_durumlari values ('salary_add:'||prm_response_code||' EmployeeID:'||prm_employee_id);
    commit;
  end if;
end;


SELECT * FROM hata_durumlari;

DECLARE
    L_RC VARCHAR(2);
BEGIN
    SALARY_ADD(-100,10,L_RC);
END;

EXECUTE SALARY_ADD(100,10);

CREATE TABLE HATA_DURUMLARI (ACIKLAMA VARCHAR2(100));


/******************************************************************************************************************************************************************************/


--DEPT_SUMMARY tablosunu dolduran bir procedure örneði;

SELECT * FROM DEPT_SUMMARY;

CREATE OR REPLACE PROCEDURE SP_OZET_HAZIRLA IS --DECLARE ifadesini kullanmýyoruz procedure'lerde. CREATE dedikten sonra altýna deðiþkenleri tanýmlamaya baþlýyoruz direkt.
    CURSOR C1 IS SELECT * FROM EMPLOYEES;
    
BEGIN
    FOR L_C1 IN C1 LOOP
        --1.YOL: Önce kaydý güncellemeye çalýþ, eðer yoksa kaydý oluþtur.
        --2.YOl: Önce kaydý oluþturmaya çalýþ, eðer varsa kaydý güncelle.
        --Burada doðru olan yol 1. yoldur. Çünkü kayýt oluþturma iþlemi sadece tablo boþ olduðunda bir kere yapýlacak, sonrasýnda hep insert yapýlacak. O yüzden boþu boþuna her seferinde kayýt oluþturmayý denememek için, önce güncelleyip yoksa kayýt oluþturan 1. yolu tercih etmek daha az maliyetli olacaktýr.

        UPDATE DEPT_SUMMARY
        SET TOTAL_SALARY= TOTAL_SALARY + L_C1.SALARY,
        PERSONEL_COUNT = PERSONEL_COUNT + 1 -- Toplam personel sayýsýný yazdýrýrken EMPLOYEES tablosunda SALARY bilgisi gibi elimizde personel sayýsýný tutan bir kolon olmadýðý için, PERSONEL_COUNT'u bir kolon deðeri ile toplamak yerine her döngüde elimizde 1 personel olduðu için perosneli 1 arttýrdýk.
        WHERE DEPARTMENT_ID = L_C1.DEPARTMENT_ID;
        
        IF SQL%ROWCOUNT = 0 THEN
        
            INSERT INTO DEPT_SUMMARY VALUES (L_C1.DEPARTMENT_ID, L_C1.SALARY, 1);--Ýlk kiþi PERSONEL_COUNT = 1
        
        END IF;
        
    END LOOP;

END;

/******************************************************************************************************************************************************************************/
--Fonksiyonlar:
-- Verilen bir ID'ye ait bölümde çalýþanlarýn ücretlerinin toplamýný bulan fonksiyon örneði.

select * from employees where employee_id=100;

SELECT GET_DEPT_SALARY(20) FROM DUAL; -- Fonksiyonlarý SQL sorgularý içerisinde çaðýrabiliyoruz. Ama Procedure'leri çaðýramayýz.

SELECT D.* FROM DEPARTMENTS D;

SELECT D.*, GET_DEPT_SALARY(D.DEPARTMENT_ID) FROM DEPARTMENTS D; --Ýstersek fonksiyona parametre olarak departman_id'yi verip tüm departmanlar için sonuç alabiliriz. 
SELECT GET_DEPT_SALARY(10) FROM DUAL; -- Fonksiyonlar kompleks sorgularý sadeceleþtirmek için çok iþe yararlar. Mesela biz burada GET_DEPT_SALARY(10) fonksiyonunu kullanmasaydýk sorgumuz uzayacaktý. Örneðin 10 tane tabloyu join etmemiz gereken bir sorgu olsaydý ve fonksiyon kullanamsaydýk o sorgu çok karmaþýklaþarak içinden çýkýlmaz bir hale gelebilirdi. Hoca ders kayýt videosunda güzel bir örnek veriyordu bu duruma.

CREATE OR REPLACE FUNCTION GET_DEPT_SALARY(PRM_DEPT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE)
    RETURN EMPLOYEES.SALARY%TYPE IS

L_TOTAL_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
    SELECT SUM(SALARY) INTO L_TOTAL_SALARY -- SUM(SALARY) ifadesinden gelen deðeri bir deðiþkende tutmamýz lazým. O yüzden INTO L_TOTAL_SALARY ifadesini koyduk. Bu ifade olmasaydý hata verirdi.
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = PRM_DEPT_ID;
    RETURN(L_TOTAL_SALARY); -- Fonksiyonlar mutlaka return deðeri döndürmek zorundadýr. Return olmazsa hata verir.
END;


/******************************************************************************************************************************************************************************/


-- ID'si verilen Departman'ýn Yöneticisini (Manager) veren fonksiyon örneði:

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;

SELECT * FROM EMPLOYEES  E, DEPARTMENTS D;

CREATE OR REPLACE FUNCTION FUNC_DEPT_MANAGER_NAME(PRM_ID EMPLOYEES.DEPARTMENT_ID%TYPE)
RETURN VARCHAR2 IS -- Burada bir local deðiþken oluþturmadýðýmýz için return kýsmýnda sadece datatype'ýný verip býraktýk. 

L_ISIM EMPLOYEES.FIRST_NAME%TYPE; -- L_ISIM deðiþkenimizi FIRST_NAME sütununun karakter sayýsý kadar (VARCHAR2 20 Byte) string alabilecek þekilde tanýmladýk. Eðer L_ISIM deðiþkenine 20 karaktersen uzun olan bir Ýsim Soyisim atanýrsa INTO L_ISIM kýsmýnda string'i into ile L_ISIM deðiþkenine atarken "ORA-06502: PL/SQL: numeric or value error: character string buffer too small" hatasý verecektir.

BEGIN
    SELECT FIRST_NAME || ' ' || LAST_NAME INTO L_ISIM -- Mesela burada LAST_NAME'den sonra EMAIL'i de yazdýrmak için yanýna || ' ' || EMAIL ifadesini de ekleseydik isim+soyisim+email toplamý 20 karakteri aþacaðý için ORA-06502 hatasý verecekti.
    FROM EMPLOYEES  E, DEPARTMENTS D -- Ýki farklý tablo ile ilgili where koþulu vereceksek böyle yapýyoruz.
    WHERE D.MANAGER_ID = E.EMPLOYEE_ID 
    AND D.DEPARTMENT_ID = PRM_ID;
    
    RETURN(L_ISIM);
    
EXCEPTION WHEN NO_DATA_FOUND THEN -- Hata yönetimi için Exception kullandýk.
    RETURN (NULL); -- Eðer fonksiyona parametre olarak verilen id'ye ait bir kayýt bulamazsa "no data found" hatasý vermek yerine iþlem kesilmeden null döndürüp devam etsin diye bu kýsmý ekledik

END;


SELECT FUNC_DEPT_MANAGER_NAME(10) FROM DUAL;

SELECT DEPARTMENT_NAME, FUNC_DEPT_MANAGER_NAME(DEPARTMENT_ID) FROM DEPARTMENTS;

/******************************************************************************************************************************************************************************/


--Fonksiyonlar Toad veya SQL Developer, DBeaver gibi baþka bir IDE üzerinden de aþaðýdaki gibi çaðýrýlabilir.

DECLARE
    MANAGERNAME VARCHAR2(40);
BEGIN
    MANAGERNAME := FUNC_DEPT_MANAGER_NAME(-10); -- Fonksiyonun içine -10 deðerini verip çalýþtýrmak istersem, böyle bir id bulunmadýðý için "no data found" hatasý verir. Çünkü benim FUNC_DEPT_MANAGER_NAME fonksiyonumu tanýmladýðým yerde biz SELECT ifadesi ile data getirmeye çalýþýyoruz. Getirecek bir data olmayýnca da hata veriyor. Eðer fonksiyonumuzda SUM, AVG, COUNT gibi matematiksel ifadeler olsaydý o zaman boþ gelse bile hata vermezdi. Çünkü o durumda data listelemiyoruz, matematiksel bir iþlem yapýyoruz.
END;


/******************************************************************************************************************************************************************************/


--Ýd'si verilen Departman'ýn Adres bilgisini veren, bu adresi de düzgün bir þekilde formatlayarak dýþarý String olarak dönen bir fonksiyon uygulamasý.

SELECT * FROM DEPARTMENTS;

SELECT * FROM COUNTRIES;

SELECT * FROM LOCATIONS;


CREATE OR REPLACE FUNCTION FUNC_DEPT_ADRESS(PRM_ID  DEPARTMENTS.DEPARTMENT_ID%TYPE)
RETURN VARCHAR2 IS

L_ADRES VARCHAR2(200);-- Burada L_ADRES deðiþkeninin tipini bir önceki örnekte olduðu gibi LOCATIONS tablosundaki STREET_ADDRESS kolonundan almak için "L_ADRES LOCATIONS.STREET_ADDRESS%TYPE;" þeklinde tanýmlasaydýk STREET_ADDRESS kolonunun karakter sýnýrý VARCHAR2 (40 Byte) olduðu için bizim INTO L_ADRES ifadesiyle L_ADRES içerisine atmýþ olduðumuz uzunca adres ifadesi STREET_ADDRESS kolonunun boyutunu geçeceðinden "ORA-06502: PL/SQL: numeric or value error: character string buffer too small" hatasý verecekti. O yüzden bu hatayla karþýlaþmamak için L_ADRES VARCHAR2(200) olarak tanýmladýk.

BEGIN
    SELECT L.STREET_ADDRESS || ' ' || L.POSTAL_CODE || ' ' || L.CITY || ' ' || C.COUNTRY_NAME INTO L_ADRES
    FROM DEPARTMENTS D, LOCATIONS L, COUNTRIES C
    WHERE D.LOCATION_ID = L.LOCATION_ID
    AND C.COUNTRY_ID = L.COUNTRY_ID
    AND D.DEPARTMENT_ID = PRM_ID;
    
    RETURN (L_ADRES);
    
    EXCEPTION WHEN OTHERS THEN RETURN (NULL); --Bu satýr sayesinde DEPARTMENT_ID'si olmayan bir deðer (0, -20, -50 vs.) nerdiðimizde hata vermek yerine NULL (boþ) deðer dönecek.
END;

SELECT FUNC_DEPT_ADRESS(50) FROM DUAL;

DECLARE
    DEPTADRES VARCHAR2(200);
BEGIN
    DEPTADRES := FUNC_DEPT_ADRESS(10);
    
END;



/******************************************************************************************************************************************************************************/


-- Bir ülkedeki çalýþanlarýn ortalama ücretini veren fonksiyon uygulamasý.

SELECT * FROM LOCATIONS;

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;

CREATE OR REPLACE FUNCTION FUNC_COUNTRY_SALARY(PRM_COUNTRY LOCATIONS.COUNTRY_ID%TYPE) 
    RETURN NUMBER--EMPLOYEES.SALARY%TYPE --Fonksiyonlarda daima return degeri olamýdýr. Procedure'lerde ise return olmaz. Onun yerine OUT parametresiyle deger dondurebiliriz.
    IS

L_AVG_SALARY EMPLOYEES.SALARY%TYPE;

BEGIN
    SELECT AVG(E.SALARY) INTO L_AVG_SALARY
    FROM EMPLOYEES E, DEPARTMENTS D, LOCATIONS L
    WHERE L.LOCATION_ID = D.LOCATION_ID
    AND D.DEPARTMENT_ID = E.DEPARTMENT_ID
    AND PRM_COUNTRY = L.COUNTRY_ID;
    
    RETURN(L_AVG_SALARY);
    
    EXCEPTION WHEN OTHERS THEN RETURN (NULL);
    
END;


SELECT FUNC_COUNTRY_SALARY('DE') FROM DUAL; 


DECLARE
    EMPLOYEES_AVG_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
    EMPLOYEES_AVG_SALARY := FUNC_COUNTRY_SALARY('DE'); --Sadece DE, US, UK, CA olan COUNTRY_ID'lerde data var. O yüzden fonksiyona parametre olarak bu 4 deðerden birini verirsek sonuç dönecektir. Aksi halde null döner. Aþaðýdaki sorgularda da bu durum görülmektedir. Çalýþtýrýlarak denenebilir.
    DBMS_OUTPUT.PUT_LINE(EMPLOYEES_AVG_SALARY);
END;

/******************************************************************************************************************************************************************************/

--Sadece DE, US, UK, CA olan COUNTRY_ID'lerin ortalama maaþlarý:
SELECT L.COUNTRY_ID, AVG(E.SALARY) --INTO L_AVG_SALARY
FROM EMPLOYEES E, DEPARTMENTS D, LOCATIONS L
WHERE L.LOCATION_ID = D.LOCATION_ID
AND D.DEPARTMENT_ID = E.DEPARTMENT_ID
--AND PRM_COUNTRY = L.COUNTRY_ID
GROUP BY L.COUNTRY_ID;


--Sadece DE, US, UK, CA olan COUNTRY_ID'lerin tüm personellerin maaþlarý:
SELECT L.COUNTRY_ID, E.FIRST_NAME, E.LAST_NAME, E.SALARY --INTO L_AVG_SALARY
FROM EMPLOYEES E, DEPARTMENTS D, LOCATIONS L
WHERE L.LOCATION_ID = D.LOCATION_ID
AND D.DEPARTMENT_ID = E.DEPARTMENT_ID;
    
SELECT * FROM LOCATIONS;

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;



/******************************************************************************************************************************************************************************/

--FUNC_DEPT_ADRES ve FUNC_DEPT_MANAGER_NAME fonksiyonlarýný tek bir procedure altýnda birleþtiren uygulama.
--Yani bir procedure yazacaðýz. Bu procedure yine bir tane DEPT_ID alacak. Bu id'ye göre bizim iki ayrý fonksiyonla yaptýðýmýz adres ve manager_name bilgilerini tek bir hamlede bize verecek olan bir procedure yazacaðýz.

CREATE OR REPLACE PROCEDURE SP_GET_DEPT_ADRESS_AND_MANAGER(PRM_DEPT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE,
                                                            PRM_ADRES OUT VARCHAR2, -- Procedure'lerde datatype'lara limit veremiyoruz. Yani VARCHAR2(40) diye birþey yazamayýz. Sadece VARCHAR2 þeklinde yazmamýz gerekiyor.  
                                                            PRM_MANAGER_NAME OUT EMPLOYEES.FIRST_NAME%TYPE) -- Procedure'lere verdiðimiz parametreler varsayýlan olarak IN (girdi) þeklinde tanýmlanýr. Yani parametre isminden sonra hiçbirþey yazmadan datatype'ýný verirsek IN olarak kabul eder. Eðer biz procedure'ümüzün bir çýktý vermesini istiyorsak o zaman OUT olarak belirtmeliyiz. 
                                                            IS
    
BEGIN

PRM_ADRES  := FUNC_DEPT_ADRES(PRM_DEPT_ID);

PRM_MANAGER_NAME := FUNC_DEPT_MANAGER_NAME (PRM_DEPT_ID);

END;                                                         
                                                            

DECLARE 
PRM_ADRES   VARCHAR2(400); --Procedure parametre verirken limit koyamýyorduk ama buradaki gibi deðiþken tanýmlarken limit verebiliriz.
PRM_MANAGER_NAME VARCHAR2(400);
BEGIN

SP_GET_DEPT_INFO (10, PRM_ADRES, PRM_MANAGER_NAME);
DBMS_OUTPUT.PUT_LINE ('ADRES: '||PRM_ADRES ||'   MUDUR: '|| PRM_MANAGER_NAME );
END;

-- File iþlemleri için (dosyaya yazma, dosyadan okuma vs.) Oracle'ýn UTL_FILE adlý bir Packace'ý varmýþ. Onu kullanarak dosya iþlemlerini yapacaðýz.
--UTL_FILE package'ý server üzerinde çalýþýyormuþ. Yani database'in bulunduðu makine üzerinde yazan ve okuyan bir package'mýþ. Veri aktarýmlarý, toplu (bulk) data yüklemek için vs. kullanýlýyormuþ.



























