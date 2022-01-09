--TYPE kullan�m�
DECLARE -- Declare ile de�i�kenler tan�mlan�r.
    L_MESSAGE CONSTANT VARCHAR2(10) := 'MERHABA'; --De�erinin sabit olarak kalmas�n� istedi�imiz bir de�i�ken olu�tururken CONSTANT kelimesi kullan�l�r. Sabitlerin de�i�kenlerden fark� bununla birlikte ilk de�er atamas�n�n hemen yap�lmas�d�r.
    L_LAST_NAME VARCHAR2(20);-- Local bir de�i�ken tan�mlarken isminden anlayabilmek i�in ba��na L koyabiliriz standart olarak. PL/SQL de de�i�kenlerin kapsam� global ve local olmak �zere 2 �e�ittir.Local de�i�kenler i�teki(inner) bloklarda kullan�l�r ve d��taki bloklarda kullan�lmaz.Global de�i�kenler ise her tarafta kullan�labilir. Yani asl�nda bizim bu sat�rda olu�turduklar�m�z ba��nda L harfi olmas�na ra�men global de�i�ken. ��nk� en d��ta tan�mlad�k. ��teki Begin-End'lerden birinde tna�mlasayd�k local de�i�ken olurdu.
    L_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE; --Bir de�i�kenimizin tipinin sabit olarak verilmesi ileride sorun olu�turabilir. Mesela L_LAST_NAME VARCHAR2(20) dersek soyisim alan� 20 karakteri ge�ince uygulamam�z patlar. Bunu engellemek i�in de�i�ken tipinii do�rudan db deki ili�kili oldu�u kolondan als�n diyebiliyoruz.
    
BEGIN
    L_NAME := 'ALI'; --L_NAME de�i�kenini yukar�da CONSTANT olarak tan�mlamad���m�z i�in bu i� block da de�erini atayabildik. Sabit(constant) olarak tan�mlasayd�k en ba�ta de�erini atamam�z gerekcekti.
    --L_MESSAGE := 'HELLO'; -- Burada L_MESSAGE de�erine atama yapmak istersek hata veriyor. ��nk� yukar�da constant olarak tan�mlad�k.
    DBMS_OUTPUT.PUT_LINE(L_MESSAGE || ' ' || L_LAST_NAME); -- Bu fonksiyon tek bir parametre al�r. Doaly�s�yla vermek istedi�imiz t�m parametreleri birle�tirerek buraya tek bir parametre olarak vermemiz laz�m. Concat (||) ile bir�etirebiliriz string ifadeleri.
    --NULL; -- Begin - End aras� bo� kalamaz. E�er hi�bir�ey yapt�rmak istemiyorsak Begin-End aras�na null; koyabiliriz.
END;


/******************************************************************************************************************************************************************************/


--ROWTYPE ve INTO kullan�m�
DECLARE
    L_EMPLOYEE EMPLOYEES%ROWTYPE; -- Employees tablosundaki tek bir sat�r� temsil eden L_EMPLOYEE adl� bir de�i�ken olu�turduk. Yani tek bir kolon veya h�cre de�il, b�t�n bir sat�r i�erisindeki bilgileri atabilece�imiz bir de�i�ken.
    L_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE :=100;

BEGIN
    SELECT * INTO L_EMPLOYEE -- Sorgu sonucunda gelen veriyi INTO ifadesi ile do�rudan ba�ka bir de�i�kene atabiliyoruz. Yani INTO ifadesi ile EMPLOYEES tablosundan gelen sonucun sat�rlar�n� direkt L_EMPLOYEE de�i�kenine atabiliyoruz.
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = L_EMPLOYEE_ID; -- PL SQL i�erisinde (DECLARE) yapt���m�z tan�mlamalar� SQL (WHERE) i�erisinde kullanabiliyoruz. Yani declare ifadesi Pl sql diline aittir ve burada tan�mlad���m�z L_EMPLOYEE_ID de�i�kenini, Begin-End blo�u i�erisindeki ANSI SQL diline ait olan where ifadesi ile birlikte kullanabildik.
    DBMS_OUTPUT.PUT_LINE(L_EMPLOYEE.FIRST_NAME || ' ' || L_EMPLOYEE.LAST_NAME);
END; --Burada PL SQL'in SQL ile entegre �al��ma �zelli�i sayesinde 4 sat�rda yapt���m�z i�lemleri SQL ile entegre �al��mayan di�er db dillerinde belkide 15 sat�rda yapabilirdik, �oklamam�z gerekebilirdi sorgular�.

SELECT * FROM EMPLOYEES;



/******************************************************************************************************************************************************************************/


--ROWTYPE kullanrak db ye kay�t ekleme uygulamas�.

SELECT * FROM JOBS WHERE JOB_ID = 'TR_ACCOUNT';

DECLARE
    L_JOB JOBS%ROWTYPE;

BEGIN
    L_JOB.JOB_ID := 'TR_ACCOUNT';
    L_JOB.JOB_TITLE := 'T�rkiye Muhasebe';
    L_JOB.MIN_SALARY := '3000';
    L_JOB.MAX_SALARY := '6000';
    
    INSERT INTO JOBS VALUES L_JOB; -- JOBS tablosuna INSERT INTO ile direk yukar�da de�erlerini tan�mlad���m�z L_JOB sat�r�m�z� verebiliyoruz
    --INSERT INTO JOBS VALUES (L_JOB.JOB_ID, L_JOB.JOB_TITLE, L_JOB.MIN_SALARY, L_JOB.MAX_SALARY); -- E�er L_JOB ifadesini direkt sat�r olarak veremeseydik insert i�lemini bu �ekilde yapmak zorunda kalacakt�k.
    COMMIT;

END;


/******************************************************************************************************************************************************************************/


--Cursor uygulamas�. (implicit & explicit) gizli ve a��k cursorlar:
-- SELECT, INSERT, UPDATE, DELETE gibi DML ifadelerinin �al��mas� s�ras�nda db nin arkplanda olu�turdu�u cursor'a implicit(gizli) cursor deriz.
--Bu cursor do�rudan kullan�c� olarak bizim y�netti�imiz bir cursor de�il. Db bunu kendi i�erisinde y�netiyor.
--Bu cursor ile ilgili baz� bilgileri �e�itli ifadeler kullanarak alabiliyoruz:
--DBMS_OUTPUT.PUT_LINE(
    --sql%rowcount -- Son �al��an sql ifadesi ka� tane kayda dokundu? Ka� kay�t �zerinde i�lem yapt� onu verir.
    --sql%found -- Son �al��an sql ifadesi bir kay�t buldu mu?
    --sql%notfound - Bu ifade, sql%found'un  tersidir. INSERT, UPDATE veya DELETE ifadeleri hi�bir sat�r� etkilemediyse veya SELECT INTO ifadesi sat�r d�nd�rmediyse TRUE sonucunu verir. Aksi takdirde, FAlSE verir.
    --sql%isopen); -- Bu de�er implicit cursor'larda her zaman False de�erini verir. ��nk� sadece sorgu �al��t��� s�rada a��kt�r. Sorgu bitince kapan�r. Dolay�s�yla biz hep kapal� halini g�r�r�z.
    --commit; -- Bu ifadeleri db ye bir�ey kay�t ett�imizde yada select att���m�zda kay�t geldi mi gelmedimi? geldiyse ka� tane geldi vs. gibi bilgilere ihtiyac�m�z oldu�unda kullan�r�z.
    

SELECT * FROM JOBS WHERE JOB_ID = 'TR_ACCOUNT';

DECLARE
LJOB JOBS%ROWTYPE; --Bir sat�rdaki t�m kolonlar� temsil eden tek bir kay�tl�k bir local de�i�ken (LJOB) tan�mlad�k

BEGIN
    LJOB.JOB_ID := 'TR_ACCNT2';
    LJOB.JOB_TITLE := 'T�rkiye Muhasebe';
    LJOB.MIN_SALARY := 3000;
    LJOB.MAX_SALARY := 6000;

    INSERT INTO JOBS VALUES LJOB; -- Yukar�da LJOB'�n alanlar�n� (kolonlar�n�) tan�mlad�ktan sonra insert ederken VALUES k�sm�na direk sat�r� temsil eden de�i�keni (LJOB) verebiliyoruz
    dbms_output.put_line('Girilen kay�t say�s�'||sql%rowcount); 
    commit;
END; -- �al��mad� PK sonundan dolay�


/******************************************************************************************************************************************************************************/


--�mplicit (gizli) cursor �rne�i
SELECT * FROM EMPLOYEES ORDER BY DEPARTMENT_ID;

declare
  lDepartmentId employees.department_id%type := -50;
begin

  update employees 
  set commission_pct = 0.2
  where department_id = lDepartmentId;

  if sql%notfound then
    dbms_output.put_line('Herhangi bir g�ncelleme yap�lmam��t�r');
  else
    dbms_output.put_line('Guncellenen kay�t say�s� : '||sql%rowcount);
  end if;  
    
  commit;
end;

/******************************************************************************************************************************************************************************/

--Explicit (a��k) cursorlar:

--Bir ANSI SQL ifadesini PL SQL diline ait bir ifade kullanmadan da �al��t�rabiliriz.
--Fakat yapaca��m�z i�lem �ok b�y�kse ve biz bunu par�a par�a yapmak istiyorsak o zaman ANSI SQL ifadeleri bu par�alamay� yapamayabilir.
--Mesela �ok b�y�k miktarda veri varsa ve biz milyon sat�rl�k bir insert veya update i�lemi yapacaksak; 
--Bunu tek seferde yapmam�z hem sisteme �ok b�y�k y�k bindirir, hem de bu i�lemin ba�ar�l� bitme ihtimali �ok d���kt�r. Y�ksek ihtimalle biryerlerde hata verecektir.
--Ayr�ca bir bu update ve ya insert ifadesinin �al��t�r�rken db de b�t�n update etti�imiz ifadelerin eski halleri (izleri) Oracle'�n log tablolar�na yaz�l�yor.
--Doaly�s�yla �ok b�y�k miktarda commit edilmemi� veriyi bekletirsek bu log tablolar� ve tablespace'leri �i�er ve bir s�re sonra hata almaya ba�lar�z.
--O y�zden biz peyderper, yani par�al� bir �ekilde i�lemelrimizi y�r�tmek zorunday�z. 
--Bununla birlikte SQL ile bir i�lem yap�p da saatler sonra sonucunu g�rmek yerine, a�ama a�ama geli�meyi de g�rmek isteriz. ��lem t�kand� m�? kesildi mi? devam ediyor mu? bunu bilemeyiz.
--E�er i�lemler aras�na belli periyotlarla commit'lerimizi mesajlar�m�z� koyarsak yap�lan i�lemlerin devam etti�ini anlayabiliriz.
--Bu y�zden baz� durumlarda kay�tlar �zerinde dola��rken toplu bir �ekilde (bulk) i�lemler (update, insert vs.) yapmak yerine, kay�t kay�t dola��p o �ekilde i�lemler yapmam�z gerekebilir.
--A�a��da bu tip durumlar i�in yap�lm�� �e�itli explicit cursor uygulama �rnekleri mevcuttur:


-- Her �al��an�n maa� durumunu ald��� maa�a g�re; 6000 tl'nin �zeri, 6000 tl'ye e�it ve 6000 tl'nin alt� olarak yazd�ral�m:
SELECT * FROM EMPLOYEES;

DECLARE
    
    CURSOR C1 IS SELECT * FROM EMPLOYEES; -- EMPLOYEES talosundaki� t�m kayitlari i��eren bi�r CURSOR olu�turduk. Bu cursor ile employees tablomuzdaki kay�tlar� tek tek dola�mak istiyoruz.
    L_STATUS VARCHAR2(100);
    
BEGIN
    FOR L_C1 IN C1 LOOP -- Burada C1 dedi�imiz �ey cursor, yani employees tablosuna ait t�m kay�tlar. L_C1 ise her bir d�ng� de o an i�in elimde olan kay�t. Yani Python'daki "for i in list:" ifadesi gibi
        IF L_C1.SALARY < 6000 THEN
            L_STATUS := '6000''DEN K���K'; -- String bir ifade i�erisinde t�rnak i�areti kullanmak istedi�imizde iki tane t�rnak koyar�z.
            
        ELSIF L_C1.SALARY = 6000 THEN
            L_STATUS := '6000'' E E��T';
            
        ELSE
            L_STATUS := '6000''DEN B�Y�K';
        END IF;
        
    DBMS_OUTPUT.PUT_LINE(RPAD(L_C1.FIRST_NAME || ' ' || L_C1.LAST_NAME,25) || L_STATUS); -- RPAD ve LPAD ile String ifadelerin sa��na veya soluna bo�luklar ekleyerek output da daha d�zg�n g�r�nmesini sa�layabiliriz. 25 de�eri de ka� tane bo�luk olaca��n� s�yl�yor. 
    
    END LOOP;
    
END; -- Bu �rnekte EMPLOYEES tablosundaki say�s� az olan veriler �zerinde i�lem yapt�k. Bunu pl sql'e ait CURSOR �zelli�ini kullanmadan ANSI SQL deki CASE WHEN ile de yapabilirdik.
--Ama �ok b�y�k boyutlu verilerde cursor kullanamdan yapamay�z. �rne�in T�rk Telekom'un 20 milyon abonesi var. Her abone i�in her ay fatura hesaplanmas� gerekiyor. Bu i�lemi pl sql deki cursor yard�m�yla yapabiliriz ancak.
    
SELECT ' '||LPAD('ISTANBUL', 20, '*')|| ' ' FROM DUAL; -- Sadece bo�luk de�il ba�ka ifadelerle de doldurabiliriz. TRIM, LTRIM, RTRIM ifadeleri de tam tersine bo�luk veya ba�ka bir karakteri sa�dan yada soldan silmek i�in kullan�l�r.   

/******************************************************************************************************************************************************************************/


--EMPLOYEES tablosundaki �al��anlar�n, departman baz�nda maa� toplamlar�n�, DEPT_SUMMARY tablosuna, ayn� �ekilde departman baz�nda ekleyen uygulama.

CREATE TABLE DEPT_SUMMARY -- TAbloyu olu�turuyoruz
(
    DEPARTMENT_ID NUMBER(4),
    TOTAL_SALARY NUMBER(8,2)
);

DELETE FROM DEPT_SUMMARY; -- ��inde kay�t varsa bo�alt�yoruz.


INSERT INTO DEPT_SUMMARY
SELECT DEPARTMENT_ID, SUM(SALARY) 
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID; 

ALTER TABLE DEPT_SUMMARY DROP COLUMN PERSONEL_COUNT; --fazladan olu�an kolonu silmek i�in

ALTER TABLE DEPT_SUMMARY ADD PERSONEL_COUNT NUMBER(4); --tekrar ekledik ayn� kolonu

SELECT * FROM DEPT_SUMMARY;

SELECT * FROM EMPLOYEES;

DECLARE
    CURSOR C1 IS SELECT * FROM EMPLOYEES;
    
BEGIN
    FOR L_C1 IN C1 LOOP
        --1.YOL: �nce kayd� g�ncellemeye �al��, e�er yoksa kayd� olu�tur.
        --2.YOl: �nce kayd� olu�turmaya �al��, e�er varsa kayd� g�ncelle.
        --Burada do�ru olan yol 1. yoldur. ��nk� kay�t olu�turma i�lemi sadece tablo bo� oldu�unda bir kere yap�lacak, sonras�nda hep insert yap�lacak. O y�zden bo�u bo�una her seferinde kay�t olu�turmay� denememek i�in, �nce g�ncelleyip yoksa kay�t olu�turan 1. yolu tercih etmek daha az maliyetli olacakt�r.

        UPDATE DEPT_SUMMARY
        SET TOTAL_SALARY= TOTAL_SALARY + L_C1.SALARY, 
        PERSONEL_COUNT = PERSONEL_COUNT + 1 -- Toplam personel say�s�n� yazd�r�rken EMPLOYEES tablosunda SALARY bilgisi gibi elimizde personel say�s�n� tutan bir kolon olmad��� i�in, PERSONEL_COUNT'u bir kolon de�eri ile toplamak yerine her d�ng�de elimizde 1 personel oldu�u i�in perosneli 1 artt�rd�k.
        WHERE DEPARTMENT_ID = L_C1.DEPARTMENT_ID;
        
        IF SQL%ROWCOUNT = 0 THEN
        
            INSERT INTO DEPT_SUMMARY VALUES (L_C1.DEPARTMENT_ID, L_C1.SALARY, 1);--�lk ki�i PERSONEL_COUNT = 1
        
        END IF;
        
    END LOOP;

END;

SELECT * FROM DEPT_SUMMARY ORDER BY DEPARTMENT_ID;

SELECT DEPARTMENT_ID, SUM(SALARY), count(*) FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID ORDER BY DEPARTMENT_ID; -- SUM fonksyonu tek ba��na kullan�lm�yor, group by ile kullan�lmal�d�r.



/******************************************************************************************************************************************************************************/



--�al��anlar�n isim, soyisim ve toplam �al��ma s�resini hesaplayan ve ekrana yazan uygulama
SELECT * FROM JOB_HISTORY;

SELECT * FROM EMPLOYEES; 

DECLARE
    CURSOR C1 IS SELECT * FROM EMPLOYEES;
    L_CALISMA_SURESI NUMBER; -- Parantez i�inde de�er vermeyince s�n�rs�z m� oluyor Number alan� ---> ???
    
    

BEGIN
    FOR L_C1 IN C1 LOOP
    
        SELECT SUM(END_DATE - START_DATE) INTO L_CALISMA_SURESI -- INTO ile SELECT sonucunu olu�turdu�umuz bir de�i�kene (L_CALISMA_SURESI) atabiliriz. SUM kullanmam�z�n sebebi de bir personel(EMPLOYEE_ID) birden fazla title ile birden fazla pozisyondan �al��m�� olabilir. Mesela EMPLOYEE_ID'si 101 olan ki�i bir s�re AC_ACCOUNT olarak, bir s�re de AC_MGR olarak �al��m��. Yani ki�i bazl� toplam s�reyi alabilmek i�in SUM kulland�k. �fadeyi SELECT ....INTO L_CALISMA_SURESI �eklinde kulland���m�z i�in L_CALISMA_SURESI de�i�kenine tek bir kay�t atabiliriz. Bu ifade birden fazla kayd� desteklemez.  
        FROM JOB_HISTORY
        WHERE EMPLOYEE_ID = L_C1.EMPLOYEE_ID; 
        DBMS_OUTPUT.PUT_LINE(L_C1.FIRST_NAME || ' ' || L_C1.LAST_NAME || ' '||L_CALISMA_SURESI); 
    END LOOP;
END;



/******************************************************************************************************************************************************************************/



-- Herhangi bir �al��an� olmayan Job'lar� listeleyen uygulama.

-- A�a��daki sorgu ile EMPLOYEES tablosunda olup da JOBS tablosunda olmayan JOB_ID'leri bulduk.
SELECT JOB_ID FROM JOBS MINUS -- MINUS ile iki SELECT sonucu aras�ndaki fark� alabiliyoruz.
SELECT DISTINCT JOB_ID FROM EMPLOYEES; -- �al��anlar�n �nvanlar�. DISTINCT ile tekrar eden �nvanlar� ��kard�k.


DECLARE
    CURSOR C1 IS SELECT * FROM JOBS;
    L_CALISAN_SAYISI NUMBER; -- Parantez i�inde de�er vermeyince s�n�rs�z m� oluyor Number alan� ---> ???  

BEGIN
    FOR L_C1 IN C1 LOOP
    
        SELECT COUNT(*) INTO L_CALISAN_SAYISI -- INTO ile SELECT sonucunu olu�turdu�umuz bir de�i�kene (L_CALISMA_SURESI) atabiliriz. SUM kullanmam�z�n sebebi de bir personel(EMPLOYEE_ID) birden fazla title ile birden fazla pozisyondan �al��m�� olabilir. Mesela EMPLOYEE_ID'si 101 olan ki�i bir s�re AC_ACCOUNT olarak, bir s�re de AC_MGR olarak �al��m��. Yani ki�i bazl� toplam s�reyi alabilmek i�in SUM kulland�k. �fadeyi SELECT ....INTO L_CALISMA_SURESI �eklinde kulland���m�z i�in L_CALISMA_SURESI de�i�kenine tek bir kay�t atabiliriz. Bu ifade birden fazla kayd� desteklemez.  
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


--1.G�n klas�r�ndeki ornek10.bmp resmindeki gibi bir �rnek rapor ��kt�s�n� olu�turacak uygulama.
--Her departman�n ismi ve alt�nda da bu departmanda �al��anlar�n ad, soyad, i�e giri� tarihi ve telefon numaras� bilgileri olacak.

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
            IF L_C1.DEPARTMENT_ID = L_C2.DEPARTMENT_ID THEN -- 1.yol: C1 ile C2'nin departman id'leri ayn�ysa yazd�r diye �art koyabiliriz.
                DBMS_OUTPUT.PUT_LINE(L_C2.FIRST_NAME||' '||L_C2.LAST_NAME||' '||L_C2.HIRE_DATE||' '||L_C2.PHONE_NUMBER);
            END IF;
        END LOOP;

    END LOOP;
END;

SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID IN (120,130,140,150,160,170); -- ��inde hi�kimsenin �al��mad��� departmanlar da var.


/******************************************************************************************************************************************************************************/

-- 2.yol: For d�ng�s�n�n i�erisine if koymak yerine, Cursor'a parametre vererek yapabiliriz.

DECLARE
    CURSOR C1 IS SELECT * FROM DEPARTMENTS; --Alt sat�rda C2 cursor'umuza WHERE �art� koyduk. Art�k bu cursor bizim �art�m�za g�re a��l�p �al��acak.
    CURSOR C2(PRM_DEPARTMENT_ID EMPLOYEES.DEPARTMENT_ID%TYPE) IS SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = PRM_DEPARTMENT_ID;
    
    L_DEPARTMENT_NAME VARCHAR2(20);

BEGIN
    FOR L_C1 IN C1 LOOP
    
        DBMS_OUTPUT.PUT_LINE('Department Name '||' '||L_C1.DEPARTMENT_NAME);
        DBMS_OUTPUT.PUT_LINE('--------------------------------');
        DBMS_OUTPUT.PUT_LINE('Name                Hire Date         Phone Number');
        
        FOR L_C2 IN C2(L_C1.DEPARTMENT_ID) LOOP -- Burada for d�ng�s� i�erisine if �art� koymak yerine, C2 parametresine o an d�� d�ng�deki C1'in i�inde hangi DEPARTMENT_ID de�eri varsa onu veriyoruz ki e�le�ebilsin. Mesela d�� d�ng�n�n ilk turunda L_C1'in i�indeki DEPARTMENT_ID de�eri 10'dur. Biz de i� d�g�de 10 de�erini vermeliyiz ki 10 nolu departmandaki �al��anlar� alabilelim ilk turda.
            DBMS_OUTPUT.PUT_LINE(L_C2.FIRST_NAME||' '||L_C2.LAST_NAME||' '||L_C2.HIRE_DATE||' '||L_C2.PHONE_NUMBER);  
        END LOOP;

    END LOOP;
END;



/******************************************************************************************************************************************************************************/


--Zam yapan Procedure �rne�i: Hata verdi baz� yerlerde tam �al��mad� sebebini bulamad�m.
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


--DEPT_SUMMARY tablosunu dolduran bir procedure �rne�i;

SELECT * FROM DEPT_SUMMARY;

CREATE OR REPLACE PROCEDURE SP_OZET_HAZIRLA IS --DECLARE ifadesini kullanm�yoruz procedure'lerde. CREATE dedikten sonra alt�na de�i�kenleri tan�mlamaya ba�l�yoruz direkt.
    CURSOR C1 IS SELECT * FROM EMPLOYEES;
    
BEGIN
    FOR L_C1 IN C1 LOOP
        --1.YOL: �nce kayd� g�ncellemeye �al��, e�er yoksa kayd� olu�tur.
        --2.YOl: �nce kayd� olu�turmaya �al��, e�er varsa kayd� g�ncelle.
        --Burada do�ru olan yol 1. yoldur. ��nk� kay�t olu�turma i�lemi sadece tablo bo� oldu�unda bir kere yap�lacak, sonras�nda hep insert yap�lacak. O y�zden bo�u bo�una her seferinde kay�t olu�turmay� denememek i�in, �nce g�ncelleyip yoksa kay�t olu�turan 1. yolu tercih etmek daha az maliyetli olacakt�r.

        UPDATE DEPT_SUMMARY
        SET TOTAL_SALARY= TOTAL_SALARY + L_C1.SALARY,
        PERSONEL_COUNT = PERSONEL_COUNT + 1 -- Toplam personel say�s�n� yazd�r�rken EMPLOYEES tablosunda SALARY bilgisi gibi elimizde personel say�s�n� tutan bir kolon olmad��� i�in, PERSONEL_COUNT'u bir kolon de�eri ile toplamak yerine her d�ng�de elimizde 1 personel oldu�u i�in perosneli 1 artt�rd�k.
        WHERE DEPARTMENT_ID = L_C1.DEPARTMENT_ID;
        
        IF SQL%ROWCOUNT = 0 THEN
        
            INSERT INTO DEPT_SUMMARY VALUES (L_C1.DEPARTMENT_ID, L_C1.SALARY, 1);--�lk ki�i PERSONEL_COUNT = 1
        
        END IF;
        
    END LOOP;

END;

/******************************************************************************************************************************************************************************/
--Fonksiyonlar:
-- Verilen bir ID'ye ait b�l�mde �al��anlar�n �cretlerinin toplam�n� bulan fonksiyon �rne�i.

select * from employees where employee_id=100;

SELECT GET_DEPT_SALARY(20) FROM DUAL; -- Fonksiyonlar� SQL sorgular� i�erisinde �a��rabiliyoruz. Ama Procedure'leri �a��ramay�z.

SELECT D.* FROM DEPARTMENTS D;

SELECT D.*, GET_DEPT_SALARY(D.DEPARTMENT_ID) FROM DEPARTMENTS D; --�stersek fonksiyona parametre olarak departman_id'yi verip t�m departmanlar i�in sonu� alabiliriz. 
SELECT GET_DEPT_SALARY(10) FROM DUAL; -- Fonksiyonlar kompleks sorgular� sadecele�tirmek i�in �ok i�e yararlar. Mesela biz burada GET_DEPT_SALARY(10) fonksiyonunu kullanmasayd�k sorgumuz uzayacakt�. �rne�in 10 tane tabloyu join etmemiz gereken bir sorgu olsayd� ve fonksiyon kullanamsayd�k o sorgu �ok karma��kla�arak i�inden ��k�lmaz bir hale gelebilirdi. Hoca ders kay�t videosunda g�zel bir �rnek veriyordu bu duruma.

CREATE OR REPLACE FUNCTION GET_DEPT_SALARY(PRM_DEPT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE)
    RETURN EMPLOYEES.SALARY%TYPE IS

L_TOTAL_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
    SELECT SUM(SALARY) INTO L_TOTAL_SALARY -- SUM(SALARY) ifadesinden gelen de�eri bir de�i�kende tutmam�z laz�m. O y�zden INTO L_TOTAL_SALARY ifadesini koyduk. Bu ifade olmasayd� hata verirdi.
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = PRM_DEPT_ID;
    RETURN(L_TOTAL_SALARY); -- Fonksiyonlar mutlaka return de�eri d�nd�rmek zorundad�r. Return olmazsa hata verir.
END;


/******************************************************************************************************************************************************************************/


-- ID'si verilen Departman'�n Y�neticisini (Manager) veren fonksiyon �rne�i:

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;

SELECT * FROM EMPLOYEES  E, DEPARTMENTS D;

CREATE OR REPLACE FUNCTION FUNC_DEPT_MANAGER_NAME(PRM_ID EMPLOYEES.DEPARTMENT_ID%TYPE)
RETURN VARCHAR2 IS -- Burada bir local de�i�ken olu�turmad���m�z i�in return k�sm�nda sadece datatype'�n� verip b�rakt�k. 

L_ISIM EMPLOYEES.FIRST_NAME%TYPE; -- L_ISIM de�i�kenimizi FIRST_NAME s�tununun karakter say�s� kadar (VARCHAR2 20 Byte) string alabilecek �ekilde tan�mlad�k. E�er L_ISIM de�i�kenine 20 karaktersen uzun olan bir �sim Soyisim atan�rsa INTO L_ISIM k�sm�nda string'i into ile L_ISIM de�i�kenine atarken "ORA-06502: PL/SQL: numeric or value error: character string buffer too small" hatas� verecektir.

BEGIN
    SELECT FIRST_NAME || ' ' || LAST_NAME INTO L_ISIM -- Mesela burada LAST_NAME'den sonra EMAIL'i de yazd�rmak i�in yan�na || ' ' || EMAIL ifadesini de ekleseydik isim+soyisim+email toplam� 20 karakteri a�aca�� i�in ORA-06502 hatas� verecekti.
    FROM EMPLOYEES  E, DEPARTMENTS D -- �ki farkl� tablo ile ilgili where ko�ulu vereceksek b�yle yap�yoruz.
    WHERE D.MANAGER_ID = E.EMPLOYEE_ID 
    AND D.DEPARTMENT_ID = PRM_ID;
    
    RETURN(L_ISIM);
    
EXCEPTION WHEN NO_DATA_FOUND THEN -- Hata y�netimi i�in Exception kulland�k.
    RETURN (NULL); -- E�er fonksiyona parametre olarak verilen id'ye ait bir kay�t bulamazsa "no data found" hatas� vermek yerine i�lem kesilmeden null d�nd�r�p devam etsin diye bu k�sm� ekledik

END;


SELECT FUNC_DEPT_MANAGER_NAME(10) FROM DUAL;

SELECT DEPARTMENT_NAME, FUNC_DEPT_MANAGER_NAME(DEPARTMENT_ID) FROM DEPARTMENTS;

/******************************************************************************************************************************************************************************/


--Fonksiyonlar Toad veya SQL Developer, DBeaver gibi ba�ka bir IDE �zerinden de a�a��daki gibi �a��r�labilir.

DECLARE
    MANAGERNAME VARCHAR2(40);
BEGIN
    MANAGERNAME := FUNC_DEPT_MANAGER_NAME(-10); -- Fonksiyonun i�ine -10 de�erini verip �al��t�rmak istersem, b�yle bir id bulunmad��� i�in "no data found" hatas� verir. ��nk� benim FUNC_DEPT_MANAGER_NAME fonksiyonumu tan�mlad���m yerde biz SELECT ifadesi ile data getirmeye �al���yoruz. Getirecek bir data olmay�nca da hata veriyor. E�er fonksiyonumuzda SUM, AVG, COUNT gibi matematiksel ifadeler olsayd� o zaman bo� gelse bile hata vermezdi. ��nk� o durumda data listelemiyoruz, matematiksel bir i�lem yap�yoruz.
END;


/******************************************************************************************************************************************************************************/


--�d'si verilen Departman'�n Adres bilgisini veren, bu adresi de d�zg�n bir �ekilde formatlayarak d��ar� String olarak d�nen bir fonksiyon uygulamas�.

SELECT * FROM DEPARTMENTS;

SELECT * FROM COUNTRIES;

SELECT * FROM LOCATIONS;


CREATE OR REPLACE FUNCTION FUNC_DEPT_ADRESS(PRM_ID  DEPARTMENTS.DEPARTMENT_ID%TYPE)
RETURN VARCHAR2 IS

L_ADRES VARCHAR2(200);-- Burada L_ADRES de�i�keninin tipini bir �nceki �rnekte oldu�u gibi LOCATIONS tablosundaki STREET_ADDRESS kolonundan almak i�in "L_ADRES LOCATIONS.STREET_ADDRESS%TYPE;" �eklinde tan�mlasayd�k STREET_ADDRESS kolonunun karakter s�n�r� VARCHAR2 (40 Byte) oldu�u i�in bizim INTO L_ADRES ifadesiyle L_ADRES i�erisine atm�� oldu�umuz uzunca adres ifadesi STREET_ADDRESS kolonunun boyutunu ge�ece�inden "ORA-06502: PL/SQL: numeric or value error: character string buffer too small" hatas� verecekti. O y�zden bu hatayla kar��la�mamak i�in L_ADRES VARCHAR2(200) olarak tan�mlad�k.

BEGIN
    SELECT L.STREET_ADDRESS || ' ' || L.POSTAL_CODE || ' ' || L.CITY || ' ' || C.COUNTRY_NAME INTO L_ADRES
    FROM DEPARTMENTS D, LOCATIONS L, COUNTRIES C
    WHERE D.LOCATION_ID = L.LOCATION_ID
    AND C.COUNTRY_ID = L.COUNTRY_ID
    AND D.DEPARTMENT_ID = PRM_ID;
    
    RETURN (L_ADRES);
    
    EXCEPTION WHEN OTHERS THEN RETURN (NULL); --Bu sat�r sayesinde DEPARTMENT_ID'si olmayan bir de�er (0, -20, -50 vs.) nerdi�imizde hata vermek yerine NULL (bo�) de�er d�necek.
END;

SELECT FUNC_DEPT_ADRESS(50) FROM DUAL;

DECLARE
    DEPTADRES VARCHAR2(200);
BEGIN
    DEPTADRES := FUNC_DEPT_ADRESS(10);
    
END;



/******************************************************************************************************************************************************************************/


-- Bir �lkedeki �al��anlar�n ortalama �cretini veren fonksiyon uygulamas�.

SELECT * FROM LOCATIONS;

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;

CREATE OR REPLACE FUNCTION FUNC_COUNTRY_SALARY(PRM_COUNTRY LOCATIONS.COUNTRY_ID%TYPE) 
    RETURN NUMBER--EMPLOYEES.SALARY%TYPE --Fonksiyonlarda daima return degeri olam�d�r. Procedure'lerde ise return olmaz. Onun yerine OUT parametresiyle deger dondurebiliriz.
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
    EMPLOYEES_AVG_SALARY := FUNC_COUNTRY_SALARY('DE'); --Sadece DE, US, UK, CA olan COUNTRY_ID'lerde data var. O y�zden fonksiyona parametre olarak bu 4 de�erden birini verirsek sonu� d�necektir. Aksi halde null d�ner. A�a��daki sorgularda da bu durum g�r�lmektedir. �al��t�r�larak denenebilir.
    DBMS_OUTPUT.PUT_LINE(EMPLOYEES_AVG_SALARY);
END;

/******************************************************************************************************************************************************************************/

--Sadece DE, US, UK, CA olan COUNTRY_ID'lerin ortalama maa�lar�:
SELECT L.COUNTRY_ID, AVG(E.SALARY) --INTO L_AVG_SALARY
FROM EMPLOYEES E, DEPARTMENTS D, LOCATIONS L
WHERE L.LOCATION_ID = D.LOCATION_ID
AND D.DEPARTMENT_ID = E.DEPARTMENT_ID
--AND PRM_COUNTRY = L.COUNTRY_ID
GROUP BY L.COUNTRY_ID;


--Sadece DE, US, UK, CA olan COUNTRY_ID'lerin t�m personellerin maa�lar�:
SELECT L.COUNTRY_ID, E.FIRST_NAME, E.LAST_NAME, E.SALARY --INTO L_AVG_SALARY
FROM EMPLOYEES E, DEPARTMENTS D, LOCATIONS L
WHERE L.LOCATION_ID = D.LOCATION_ID
AND D.DEPARTMENT_ID = E.DEPARTMENT_ID;
    
SELECT * FROM LOCATIONS;

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;



/******************************************************************************************************************************************************************************/

--FUNC_DEPT_ADRES ve FUNC_DEPT_MANAGER_NAME fonksiyonlar�n� tek bir procedure alt�nda birle�tiren uygulama.
--Yani bir procedure yazaca��z. Bu procedure yine bir tane DEPT_ID alacak. Bu id'ye g�re bizim iki ayr� fonksiyonla yapt���m�z adres ve manager_name bilgilerini tek bir hamlede bize verecek olan bir procedure yazaca��z.

CREATE OR REPLACE PROCEDURE SP_GET_DEPT_ADRESS_AND_MANAGER(PRM_DEPT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE,
                                                            PRM_ADRES OUT VARCHAR2, -- Procedure'lerde datatype'lara limit veremiyoruz. Yani VARCHAR2(40) diye bir�ey yazamay�z. Sadece VARCHAR2 �eklinde yazmam�z gerekiyor.  
                                                            PRM_MANAGER_NAME OUT EMPLOYEES.FIRST_NAME%TYPE) -- Procedure'lere verdi�imiz parametreler varsay�lan olarak IN (girdi) �eklinde tan�mlan�r. Yani parametre isminden sonra hi�bir�ey yazmadan datatype'�n� verirsek IN olarak kabul eder. E�er biz procedure'�m�z�n bir ��kt� vermesini istiyorsak o zaman OUT olarak belirtmeliyiz. 
                                                            IS
    
BEGIN

PRM_ADRES  := FUNC_DEPT_ADRES(PRM_DEPT_ID);

PRM_MANAGER_NAME := FUNC_DEPT_MANAGER_NAME (PRM_DEPT_ID);

END;                                                         
                                                            

DECLARE 
PRM_ADRES   VARCHAR2(400); --Procedure parametre verirken limit koyam�yorduk ama buradaki gibi de�i�ken tan�mlarken limit verebiliriz.
PRM_MANAGER_NAME VARCHAR2(400);
BEGIN

SP_GET_DEPT_INFO (10, PRM_ADRES, PRM_MANAGER_NAME);
DBMS_OUTPUT.PUT_LINE ('ADRES: '||PRM_ADRES ||'   MUDUR: '|| PRM_MANAGER_NAME );
END;

-- File i�lemleri i�in (dosyaya yazma, dosyadan okuma vs.) Oracle'�n UTL_FILE adl� bir Packace'� varm��. Onu kullanarak dosya i�lemlerini yapaca��z.
--UTL_FILE package'� server �zerinde �al���yormu�. Yani database'in bulundu�u makine �zerinde yazan ve okuyan bir package'm��. Veri aktar�mlar�, toplu (bulk) data y�klemek i�in vs. kullan�l�yormu�.



























