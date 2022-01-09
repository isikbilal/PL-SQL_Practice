--Neden Trigger Kullan�r�z:

--Sanal alanlar i�in de�er �retmek
--Yap�lan i�lemin loglanmas�
--Veri do�rulamas� (data authentication) yapmak
--�zet veri olu�turmak

--Trigger'lara kritik veri konmamaml�d�r. ��nk� trigger olmadan da bizim sistemimiz �al���r. Hata vermez. Mesela birisi bizim trigger'�m�z� drop veya disable ederse sistem "burada bir trigger vard� nereye gitti o trigger" diye uyar� vermez. Sistem �al��maya devam eder. Biz farkedene kadar da i� i�ten ge�mi� olabilir. Dolay�s�yla telafi edilemeyecek kritiklikteki bir veriyi trigger'a g�venerek tutmamam�z gerekir.
--Fakat sonradan telafi edilebilecek bir veriyi trigger'a koyabiliriz. Mesela bir �cret bilgisi girildi�inde hemen onu %20 ile �arp�p zaml� halini ba�ka bir s�tuna yazan bir trigger'�m�z olsun. Bu trigger disable olmu� ve bizde bunu 2 ay sonra farketmi� olal�m ve 1 milyon �arp�lmam�� kay�t birikmi� olsun. Hemen bir update sorgusu ile �cretlerin %20 zaml� halini hesaplay�p kolona ekleyebilirim. ��nk� burada ham data (�cret) benim elimededir. O y�zden trigger �al��masa da kendim yapabilirim. B�yle kritik olmayan durumlarda i�imizi kolayla�t�rs�n ve h�zland�rs�n diye trigger kullan�labilir.
--Ama memory �zerinde anl�k tutulan temp bir�eyse mesela, onu trigger'a koyarsak trigger �al��mad���nda o veriyi kaybederiz. O y�zden bu t�r �eyler trigger'a konmaz. Normal kod blo�umuz i�erisinde bu kritik bilgileri tutmal�y�z.


--Trigger �rne�i:
--EMPLOYEES tablosuna yeni bir kay�t girildi�i zaman bu kayd�n isim-soyisim (FIRST_NAME ve LAST_NAME kolonlar�) k�sm�n� otomatik olarak b�y�k harfe �eviren bir trigger uygulamas�.

--E�itim s�ras�nda olu�turdu�umuz �rnek:
/*CREATE OR REPLACE TRIGGER BISIK.TRG_EMP_NAME_CONTROL
    before insert or update
    ON BISIK.EMPLOYEES
    for each row
begin
    :NEW.FIRST_NAME :=UPPER(:NEW.FIRST_NAME);
    :NEW.LAST_NAME :=UPPER(:NEW.LAST_NAME);
end TRG_EMP_NAME_CONTROL;
*/


CREATE OR REPLACE TRIGGER TRG_EMP_NAME_CONTROL
    BEFORE INSERT OR UPDATE
    ON EMPLOYEES
    FOR EACH ROW 

BEGIN
    :NEW.FIRST_NAME := UPPER(:NEW.FIRST_NAME); -- De�i�tirece�imiz kay�tlar�n trigger �al��madan �nceki ve sonraki hallerini :NEW ve :OLD diyerek belirtmek zorunday�z.
    :NEW.LAST_NAME := UPPER(:NEW.LAST_NAME); -- Burada UPPER(:NEW.LAST_NAME) yerine UPPER(:OLD.LAST_NAME) deseydik hatal� �al���rd�. Mesela "Bila I��" yazan yere "Bilal I��k" yazsak bile bize "BILA I�I" d�nd�r�d�. O y�zden eski halinin (:OLD) de�il de yeni halinin (:NEW) b�y�k harfli olmas� i�in :NEW kulland�k. :OLD ifadesini eski kayd� kaybetmemek istedi�imiz durumlarda (log tutma vs. gibi) kullan�r�z.
END TRG_EMP_NAME_CONTROL;


SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID=100 FOR UPDATE; -- FOR UPDATE ifadesi istenilen bir sat�r� kilitlemek i�in kullan�l�yor san�r�m.

SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID=100;

UPDATE EMPLOYEES SET COMMISSION_PCT = 0.20 WHERE EMPLOYEE_ID=100; -- Sadece isim ve soyisimde de�il, herhangi bir s�tunda da (COMMISSION_PCT gibi) de�i�iklik yapsak isim ve soyismi b�y�k harfe �evirir.

UPDATE EMPLOYEES SET LAST_NAME = 'Kings' WHERE EMPLOYEE_ID=100; -- Verdi�imiz soyisimde k���k harf olmas�na ra�men hepsini b�y�k harfe �evirdi.

SELECT * FROM EMPLOYEES ORDER BY EMPLOYEE_ID;


--Ba�ka bir deneme:

SELECT * FROM EMPLOYEES ORDER BY MANAGER_ID;

UPDATE EMPLOYEES SET PHONE_NUMBER = PHONE_NUMBER||'-1' WHERE MANAGER_ID=100; --Dikkat edersek burada MANAGER_ID'si 100 olan kay�tlar� g�ncelledik ve olu�turdu�umuz TRG_EMP_NAME_CONTROL adl� trigger'dan dolay� hepsinin ad� ve soyas� b�y�k harfe d�n��t�. ��nk� bizim bu trigger'� olu�turuken CREATE OR REPLACE TRIGGER b�l�m�nde FOR EACH ROW dedi�imizden dolay� her bir sat�r i�in �al��t� ve WHERE �art�m�za uyan b�t�n kay�tlar�n isim soyismini b�y�k harfe d�n��t�rd�. Yani bir tane UPDATE ifadesi ile 14 (manager_id'si 100 olan kay�t say�s�) tane kayd� g�ncelleyebildik FOR EACH ROW ifadesi sayesinde.




/******************************************************************************************************************************************************************************/



--Herhangi birisi bir tabloda update, insert (DML sorgusu) yapm�� bunun kayd�n� tutup bir tabloda loglayan ifade bazl� (statement level) bir trigger uygulamas�.
CREATE OR REPLACE TRIGGER TRG_EMP_LOG
    BEFORE INSERT OR UPDATE OR DELETE
    ON EMPLOYEES -- Dikkat edersek FOR EACH ROW koymad�k bu sefer. ��nk� bu trigger'�m�z kay�t bazl� de�il. �fade bazl� bir tigger.

BEGIN
    INSERT INTO HATA_DURUMLARI VALUES ('TARIH: '||TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    
END TRG_EMP_LOG;

UPDATE EMPLOYEES SET PHONE_NUMBER = REPLACE(PHONE_NUMBER,'-1') WHERE MANAGER_ID=100; -- REPLACE komutu i�ine verdi�imiz ifadeyi String veritipinden ��kar�r. 14 kay�t g�ncellendi.

SELECT * FROM HATA_DURUMLARI; -- Biz yukar�da 14 kayd� g�ncelledik ama HATA_DURUMLARI tablomuza bir tane kay�t eklendi. ��nk� TRG_EMP_LOG trigger'�m�z ifade bazl� bir trigger. O y�zden bir defa �al��t�.

SELECT * FROM USER_SOURCE; --USER_SOURCE tablosu db'ye ba�l� oldu�umuz kullan�c�daki t�m uygulama kodlar�n� (function, trigger, procedure vs.) g�sterir.

SELECT * FROM USER_SOURCE
WHERE NAME='GET_DEPT_SALARY'
ORDER BY LINE; -- Burada sat�r say�s�na (LINE) g�re s�ralarsak bize arad���m�z uygulama kodunun (function, trigger, procedure vs.) i�eri�ini s�ral� bir �ekilde g�sterir.

--Bir tane tablo olu�turup bu tabloya USER_SOURCE tablosundan istedi�imiz uygulamalar�n kodlar�n� ekleyerek yedek kod tablosu olu�turabiliriz. B�ylece kodlar�m�z�n de�i�mesi durumunda eski haline ula�abiliriz.
CREATE TABLE KOD_YEDEK( --Tablomuzu olu�turduk
    TARIH DATE,
    NAME VARCHAR2(128),
    TYPE VARCHAR2(12),
    LINE NUMBER,
    TEXT VARCHAR2(4000),
    ORIGIN_CON_ID NUMBER);

INSERT INTO KOD_YEDEK -- Bu �ekilde SELECT sonucundan gelen ifadeyi bir tabloya INSERT edebiliyoruz.
SELECT SYSDATE, S.* FROM USER_SOURCE S; -- Bu �ekilde db'de en son al�nan back up'dan sonra pl sql kodlar�m�zda bir de�i�iklik olduysa onlar� da ayr� bir tabloya yedekleyebiliriz.

SELECT * FROM KOD_YEDEK;



/******************************************************************************************************************************************************************************/



--Bir tablodaki (Mesela DEPARTMENTS tablosu) de�i�iklikleri tarih�esini tutaca��m�z bir trigger uygulamas�. Yani ":OLD" kullanarak tablonun eski halini ba�ka bir tabloda (DEPARTMENTS_HIST) yedekleyen bir trigger:

CREATE TABLE DEPARTMENTS_HIST AS 
SELECT * FROM DEPARTMENTS -- Tablo ve kolonlar zaten varsa bu kodlar hata verecektir.

ALTER TABLE DEPARTMENTS_HIST ADD ISLEM_TARIHI DATE

ALTER TABLE DEPARTMENTS_HIST ADD ISLEM VARCHAR2(30)

DROP TABLE DEPARTMENTS_HIST; -- Tabloda fazla s�tun varsa tabloyu veya s�tunu silmeliyiz. Yoksa sorun ��kart�yor trigger �al���rken.

DELETE FROM DEPARTMENTS_HIST;

SELECT * FROM DEPARTMENTS;

SELECT * FROM DEPARTMENTS_HIST;

UPDATE DEPARTMENTS 
SET  DEPARTMENT_NAME = DEPARTMENT_NAME||'XX' --Departman ad�n�n sonuna xx ekeldik
WHERE DEPARTMENT_ID=10;

UPDATE DEPARTMENTS 
SET  DEPARTMENT_NAME = REPLACE(DEPARTMENT_NAME,'XX') --De�i�ikli�i eski haline �evirdik
WHERE DEPARTMENT_ID=10;

INSERT INTO DEPARTMENTS VALUES --Insert �rne�i
('99', 'TEST', '200', '1700');

DELETE FROM DEPARTMENTS WHERE DEPARTMENT_ID=99; --DEPARTMENT_ID alan� NUMBER oldu�u i�in t�rnak i�inde yazmasak da olur

--INSERT ��LEM�NDE OLD DEPER� OLMAZ.
--DELETE ��LEM�NDE NEW DE�ER� OLMAZ.
CREATE OR REPLACE TRIGGER  TRG_DEPARTMENT_HIST
  BEFORE  UPDATE OR DELETE
  ON DEPARTMENTS
  FOR EACH ROW

BEGIN
  INSERT INTO DEPARTMENTS_HIST VALUES 
   (:OLD.DEPARTMENT_ID, :OLD.DEPARTMENT_NAME, :OLD.MANAGER_ID, :OLD.LOCATION_ID, SYSDATE);
   --Trigger'larda commit veya rollback olmaz.
END;


/******************************************************************************************************************************************************************************/


-- T�M DURUMLARI LOGLAYAN TRIGGER (ISLEM a��klamas�yla birlikte logluyor)
CREATE OR REPLACE TRIGGER  TRG_DEPARTMENT_ALL_HIST
  BEFORE INSERT OR UPDATE OR DELETE
  ON DEPARTMENTS
  FOR EACH ROW
  
DECLARE 
    L_ISLEM VARCHAR2(30);

BEGIN
    IF INSERTING THEN L_ISLEM:='INSERT'; -- Update i�lemi yap�lm��sa ISLEM kolonuna UPDATE yaz.
    ELSIF UPDATING THEN L_ISLEM:='UPDATE'; -- Insert i�lemi yap�lm��sa ISLEM kolonuna INSERT yaz.
    ELSE L_ISLEM:='DELETE'; --�kisi de de�ilse DELETE yaz
    END IF;
    
    IF INSERTING OR UPDATING THEN -- Insert veya Update olma durumu
        INSERT INTO DEPARTMENTS_HIST VALUES
        (:NEW.DEPARTMENT_ID, :NEW.DEPARTMENT_NAME, :NEW.MANAGER_ID, :NEW.LOCATION_ID, SYSDATE, L_ISLEM);
    ELSIF DELETING THEN
        INSERT INTO DEPARTMENTS_HIST VALUES
        (:OLD.DEPARTMENT_ID, :OLD.DEPARTMENT_NAME, :OLD.MANAGER_ID, :OLD.LOCATION_ID, SYSDATE, L_ISLEM);
    END IF;    
END;


SELECT * FROM DEPARTMENTS_HIST;


--------------------------------------------------------------------------------------------------------------------
/******************************************************************************************************************************************************************************/





EDIT EMPLOYEES  WHERE EMPLOYEE_ID=189

-- KULLANICININ SAHIP OLDU�U TRIGGERLAR
select * from USER_TRIGGERS

-- KULLANICININ G�RMEYE YETK�L� OLDU�U TRIGGERLAR
select * from ALL_TRIGGERS

-- DBA YETK�L� OLD. T�M  TRIGGERLAR
select * from DBA_TRIGGERS


-- G�NCELLENEN/G�R�LEN MAA� DE�ERLER� M�N MAX DE�ERLER� ARASINDA DE��LSE HATA VEREN TRIGGER
CREATE OR REPLACE TRIGGER  TRG_SALARY_CONTROL
  BEFORE INSERT OR UPDATE 
  ON EMPLOYEES
  FOR EACH ROW
  
DECLARE 
L_MIN_SALARY  EMPLOYEES.SALARY%TYPE;
L_MAX_SALARY  EMPLOYEES.SALARY%TYPE; 
  
BEGIN 

SELECT MIN_SALARY, MAX_SALARY  INTO L_MIN_SALARY, L_MAX_SALARY 
FROM JOBS 
WHERE JOB_ID = :NEW.JOB_ID;

IF :NEW.SALARY > L_MAX_SALARY    OR   :NEW.SALARY < L_MIN_SALARY THEN 
    RAISE_APPLICATION_ERROR (-20001,'MAA� ARALIK DE�ERLER� DI�INDADIR.');
END IF;


END;



/******************************************************************************************************************************************************************************/

------- EXCEPTION �E��TLER�----------
--Her except�on'� yakalama �ans�m�z yok. Sadece yayg�n olan hatalar veya olu�abilece�ini tahmin etti�imiz hatalar� yakalay�p �nlem al�r�z genelde.


--S�f�ra b�l�nememe (divisor is equal to zero) hatas� yakalama �rne�i:

DECLARE
    L_VAL NUMBER;
    L_RC VARCHAR2(100);

BEGIN
    L_VAL := 1/0;
    EXCEPTION WHEN OTHERS THEN --OTHERS dersek b�t�n hatalar� kapsar. Sadece s�f�ra b�l�nememe hatas�n� almak istersek ZERO_DIVIDE yazmam�z gerekirdi.
    DBMS_OUTPUT.PUT_LINE(SQLCODE||' '||SQLERRM); -- Gelen hatan�n kodunu ve a��klamas�n� yazd�r�yoruz.
    L_RC := '0''A BOLUNEMEME HATASI';
    DBMS_OUTPUT.PUT_LINE(L_RC);-- Yada bu �ekilde kullan�c�n�n anlayabilece�i bir a��klama da yazd�rabiliriz..
END;


--Oracle'da baz� yayg�n hatalar hata kodu yerine ayr�ca isimlendirilmi�tir:
--zero_divide(ora-1476)
--no_data_found(ora-1403)
--too_many_rows(ora-1422)
--dup_val_on_index(ora-1) -- M�kerrer kay�t kontrol� hatas�
--value_error(ora-6502) vs. gibi




/******************************************************************************************************************************************************************************/


--Exception ile hata yakalama uygulamas�:
CREATE OR REPLACE PROCEDURE DEPARTMENT_INSERT2(
  PRM_DEPT DEPARTMENTS%ROWTYPE,
  PRM_RC OUT VARCHAR2
  ) IS

ZORUNLU_ALAN_HATASI EXCEPTION;
PRAGMA EXCEPTION_INIT(ZORUNLU_ALAN_HATASI, -02290); -- Oracle'�n 02290 numaral� hatas�n� ZORUNLU_ALAN_HATASI olarak tan�mlad�k burada. Hoca yaparken 1400 nolu hatay� tan�mlam��t�k. Toad da 02290 olarak verdi hatay�. Yani Oracle'�n kendisinin isimlendirmedi�i bir hatay� biz kendimiz bu �ekilde adland�rabiliyoruz


BEGIN
  INSERT INTO DEPARTMENTS VALUES PRM_DEPT;
  PRM_RC := 'Islem basarili';
  COMMIT;
EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    PRM_RC := 'Mukerrer bolum numarasi';
WHEN ZORUNLU_ALAN_HATASI THEN --Burada da yukar�da tan�mlad���m�z hatay� kullan�yoruz.
    PRM_RC := 'Zorunlu alanlari doldurunuz '||SQLERRM;      
WHEN OTHERS THEN -- Akl�m�za gelen t�m hatalar� yakalad�ktan sonra di�er beklenmeyen hatalar i�in WHEN OTHERS kullan�r�z.
    PRM_RC := 'Beklenmeyen DB Hatasi '||SQLERRM;  
END;



/******************************************************************************************************************************************************************************/


--Hata yakalama procedure'�m�z� tan�mlad�k. �imdi a�a��daki kod blo�unu �al��t�rarak kay�t eklemeye �al��al�m ve ��kan hatalar� inceleyelim.
DECLARE
L_DEPT DEPARTMENTS%ROWTYPE;
L_RC VARCHAR2(500);

BEGIN
    L_DEPT.DEPARTMENT_ID := 300;
    L_DEPT.DEPARTMENT_NAME := 'TR';
    L_DEPT.MANAGER_ID := 100;
    L_DEPT.LOCATION_ID := 1700;
    
    DEPARTMENT_INSERT2(L_DEPT, L_RC);
    DBMS_OUTPUT.PUT_LINE(L_RC); 
END;

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;



/******************************************************************************************************************************************************************************/

--Depatman y�neticisi bulunmayan birimlere y�neticisi, Administrator departman�n�n y�neticisi olan ki�inin ismini (Jennifer Whalen) default olarak veren uygulama:
--E�er girilen de�erin b�l�m� (depatment_id) yoksa NULL d�nd�rs�n. B�l�m� varsa ama y�neticisi yoksa o zaman y�neticisi, Administrator departman�n�n y�neticisi olan ki�inin ismini (Jennifer Whalen) yazd�r. Insert yok, sadece ekrana yazd�racak. Yani select i�lemi yap�lacak


-- Daha �nceden yapt���m�z ID'si verilen Departman'�n Y�neticisini (Manager) veren fonksiyonu kopyalad�k buraya. Bu fonksiyon bize Id'si verilen departman�n y�neticisini veriyor halihaz�rda.

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;

SELECT * FROM EMPLOYEES  E, DEPARTMENTS D;

CREATE OR REPLACE FUNCTION FUNC_DEPT_MANAGER_NAME(PRM_ID EMPLOYEES.DEPARTMENT_ID%TYPE)
RETURN VARCHAR2 IS -- Burada bir local de�i�ken olu�turmad���m�z i�in return k�sm�nda sadece datatype'�n� verip b�rakt�k. 

L_ISIM EMPLOYEES.FIRST_NAME%TYPE;  --E�er L_ISIM de�i�kenine EMPLOYEES.FIRST_NAME'in karakter say�s�ndan uzun olan bir �sim Soyisim atan�rsa INTO L_ISIM k�sm�nda string'i into ile L_ISIM de�i�kenine atarken "ORA-06502: PL/SQL: numeric or value error: character string buffer too small" hatas� verecektir.
L_NAME EMPLOYEES.FIRST_NAME%TYPE;
L_BOLUM DEPARTMENTS.DEPARTMENT_ID%TYPE;

BEGIN
    SELECT FIRST_NAME || ' ' || LAST_NAME INTO L_ISIM -- Mesela burada LAST_NAME'den sonra EMAIL'i de yazd�rmak i�in yan�na || ' ' || EMAIL ifadesini de ekleseydik isim+soyisim+email toplam� 20 karakteri a�aca�� i�in ORA-06502 hatas� verecekti.
    FROM EMPLOYEES  E, DEPARTMENTS D -- �ki farkl� tablo ile ilgili where ko�ulu vereceksek bu �ekilde harf vererek isimlendirebilriz..
    WHERE D.MANAGER_ID = E.EMPLOYEE_ID 
    AND D.DEPARTMENT_ID = PRM_ID;
    
    RETURN(L_ISIM);
    
    BEGIN -- Fonksiyona parametre olarak verdi�imiz Departman (department_id) yoksa NULL d�nen hata kontrol k�sm�
        SELECT DEPARTMENT_ID INTO L_BOLUM
        FROM DEPARTMENTS D 
        WHERE D.DEPARTMENT_ID = PRM_ID;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Boyle bir departman yok.'); 
        RETURN(NULL);    
    END; -- �ki ayr� NO_DATA_FOUND hatas�n� da ayr� ayr� BEGIN-END blo�u aras�na almam�z gerekiyor. B�yle yapmasayd�k, tek bir BEGIN-END blo�u olsayd� her zaman en alttaki NO_DATA_FOUND hatas�na d��ecekti. Yani olmayan bir department_id(-10) verseydik yine Jennifer Whalen yazacakt�. Bu da mant�ks�z olurdu

    BEGIN -- Parametre olarak ID'si verdi�imiz Departman varsa, fakat Y�neticisi yoksa, o zaman y�neticisi, Administrator departman�n�n y�neticisi olan ki�inin ismini (Jennifer Whalen)veriyoruz.
        SELECT FIRST_NAME || ' ' || LAST_NAME INTO L_NAME
        FROM EMPLOYEES  E, DEPARTMENTS D 
        WHERE D.MANAGER_ID = E.EMPLOYEE_ID 
        AND D.DEPARTMENT_ID = 10;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Girdiginiz departmanin yoneticisi olmadigi icin 10 nolu departman�n yoneticisi oldugu kisinin ismi getirilecektir'); 
        RETURN(L_NAME);
    END;    
END;

SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = -130;

SELECT FUNC_DEPT_MANAGER_NAME(-10) FROM DUAL;

SELECT DEPARTMENT_NAME, FUNC_DEPT_MANAGER_NAME(DEPARTMENT_ID) FROM DEPARTMENTS; --T�m Id'lerle birlikte �al��t�rmak i�in.


/******************************************************************************************************************************************************************************/
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Yeni lokasyon tan�mlayan birtane prosed�r uygulamas�:
--Locations tablosuna insert yapan bir procedure yazal�m. Location_id'yi d��ar�dan de�il sequence'den alal�m. Ayr�ca country_id'yi de�il de country_name'i g�nderece�iz parametre olarak. Bunun i�in de country_name'den country_id'yi bulan bir sorgu yazmam�z gerekiyor ayr�ca.
--LOCATIONS_SEQ adl� bir sequence var. Sequence'ler s�ral� olarak numara �retirler. Mesela bir tabloya insert yaparken s�ral� numaralar �retmemizi sa�lar. Location_id'yi bu sequence'den alaca��z.
--Giri� Parametreleri: PRM_STREET_ADDRESS, PRM_POSTAL_CODE, PRM_CITY, PRM_STATE_PROVINCE, PRM_COUNTRY_NAME
--out parametreler: insert edilen lokasyon kayd�n�n id bilgisini kullan�c�ya g�stermek i�in PRM_LOCATION_ID ve kullanc�ya hata durmunda mesaj g�stermek i�in PRM_RC
--Hata kodlar�n� da EXCEPTION WHEN bloklar� i�erisinde tan�mlayal�m

SELECT * FROM LOCATIONS;

SELECT * FROM COUNTRIES;

CREATE OR REPLACE PROCEDURE SP_LOCATION_INSERT (
                                            
                                            PRM_STREET_ADDRESS LOCATIONS.STREET_ADDRESS%TYPE,
                                            PRM_POSTAL_CODE LOCATIONS.POSTAL_CODE%TYPE,
                                            PRM_CITY LOCATIONS.CITY%TYPE,
                                            PRM_STATE_PROVINCE LOCATIONS.STATE_PROVINCE%TYPE,
                                            PRM_COUNTRY_NAME COUNTRIES.COUNTRY_NAME%TYPE, -- Country_name'in data tipini COUNTRIES tablosundan al�yor. Di�erlerini LOCATIONS tablosundan.
                                            
                                            PRM_LOCATION_ID OUT LOCATIONS.LOCATION_ID%TYPE, -- Burada sadece parametre ve datatype'lar�n� tan�ml�yoruz. Sequence olarak Begin-End i�erisinde tan�mlayaca��z.
                                            PRM_RC OUT VARCHAR2 --Procedure'lerde out parametrelerinin dataype'�na s�n�rland�rma koyamay�z. Yani VARCHAR2(50) �eklinde yapamazd�k. Sadece VARCHAR2 �eklinde yazmal�y�z.
                                            ) IS
L_COUNTRY_ID COUNTRIES.COUNTRY_ID%TYPE;
L_LOCATION_ID NUMBER; -- Parametre olarak almayaca��m�z de�erleri de LOCATIONS tablosuna insert edebilmek i�in burada local de�i�ken olarak tan�mlad�k.                                  
                                            
BEGIN

    BEGIN -- Burada COUNTRIES tablosunu BEGIN-END blo�u aras�na alarak bir nevi koruma alt�na ald�k. Olu�acak datay� ba�ka bir sorguyla kar��t�rmadan ba��ms�z olarak ele alm�� olduk. Mesela PRM_COUNTRY_NAME gibi ba�ka tablodan (COUNTRIES) alaca��m�z ba�ka bir data olsayd� (CITIES tablosundan alaca��m�z CITY_NAME gibi) onu da BEGIN-END aras�na almam�z daha do�ru olurdu kar��mamas� i�in. Yani EXCEPTION (HATA) y�netimlerini di�er kod bloklar�ndan ba��ms�z olarak yapmam�z daha do�ru.
        SELECT COUNTRY_ID INTO L_COUNTRY_ID 
        FROM COUNTRIES 
        WHERE COUNTRY_NAME = PRM_COUNTRY_NAME; --LOCATIONS tablosuna insert edece�imizi yeni lokasyonun COUNTRY_ID'sini elde edebilmek i�in COUNTRIES tablosundan bizim parametre olarak verdi�imiz PRM_COUNTRY_NAME ile e�le�en �lkenin COUNTRY_ID'sini ald�k. Bu sorgunun sonucunu da INTO ifadesiyle L_COUNTRY_ID de�i�kenimize att�k kullanabilmek i�in. E�er atmasayd�k direkt kullanamazd�k COUNTRY_ID kolonu �zerinden.

        EXCEPTION WHEN NO_DATA_FOUND THEN -- Hata y�netimini bu k�s�mda yap�yoruz.
            PRM_RC := 'Gecersiz ulke adi '; -- Burada sadece P_RC'nin de�erini de�i�tirmemiz yeterli. Fonksiyonlardaki gibi return etmemize gerek yok. Prosed�r oldu�u i�in kendisi return edecektir zaten. E�er d�nd�rmemiz gerekn bir�ey varsa onu CREATE k�sm�nda OUT parametre olarak veriyoruz.
    END;
    
    BEGIN
        NULL; -- NULL koymazsak BEGIN-END blo�u �al��maz i�erisi bo�ken.
        --DI�ER SE�IM SQLLERI -- Mesela ba�ka tablodan alaca��m�z ba�ka bir data olsayd� ( E�er CITIES tablosu olsayd� oradan alaca��m�z CITY_NAME gibi) onu da BEGIN-END aras�na almam�z daha do�ru olurdu kar��mamas� i�in. 
        --EXCEPTION -- Yani EXCEPTION (HATA) y�netimlerini di�er kod bloklar�ndan ba��ms�z olarak yapmam�z daha do�ru.
        -- Burada ya region_name (b�lge ismi) i�in bir sorgu koyup �yle dene bakal�m. Yani �nce LOCATIONS tablosunda REGION_ID diye bir kolon olu�tural�m. Sonra prosed�re parametre olarak REGION_NAME verelim. Sonra REGIONS tablosundan verdi�imiz REGION_NAME'in kar��l��� olan REGION_ID'yi al�p onu da LOCATIONS tablosuna kay�t insert ederken, olu�turdu�umuz REGION_ID kolonuna ekleyelim.
        
    END;

    L_LOCATION_ID := LOCATIONS_SEQ.NEXTVAL; -- Insert yaparken her seferinde kendimiz id vermek zorunda kalmayal�m diye LOCATIONS_SEQ.NEXTVAL ile her kay�tta otomatik s�ral� numaralar �retmesini sa�lad�k. Php'de id eklerkenki auto increment �zelli�i gibi. Db'de olu�turulmu� di�er sequence'lar� g�rmek istersek Schema Browser'dan Sequences b�l�m�ne bakabiliriz. Buradan Script sekmesine gelerek Sequence'in �zelliklerini (hangi say�dan ba�lay�p hangi de�ere kadar gidecek? ka�ar ka�ar artacak? vs. )g�rebiliriz. Kendimiz bir sequence olu�turmak istersek internette "Oracle Sequence" diye arat�rsak nas�l yap�lca�� ��kacakt�r.
    
    INSERT INTO LOCATIONS
    VALUES (L_LOCATION_ID, PRM_STREET_ADDRESS, PRM_POSTAL_CODE, PRM_CITY, PRM_STATE_PROVINCE, L_COUNTRY_ID);
    
    PRM_LOCATION_ID := L_LOCATION_ID; -- DBMS_OUTPUT'da ��kt� olarak verilebilmesi i�in burada OUT parametrelerimize de�er at�yoruz. Sonra prosed�r�m�z� �al��t�r�ken parametre olarak verece�iz.
    PRM_RC := 'Islem basarili ';
    
    COMMIT; -- EXCEPTION WHEN OTHERS'�n Commit'den sonra yaz�lmas� gerekiyor san�r�m.
    
    EXCEPTION WHEN OTHERS THEN
		PRM_RC := 'Beklenmeyen DB Hatasi'; 
END;


DECLARE --Declare i�erisinde bir de�i�kene, parametreye vs. de�er atamas� yapam�yoruz. Sadece tan�mlama yapabiliyoruz.
    PRM_LOCATION_ID LOCATIONS.LOCATION_ID%TYPE; --Burada tekrar out parametrelerini "OUT" keyword'� ��kar�lm�� �ekilde yeniden DECLARE alt�nda de�i�ken olarak data tipleriyle birlikte tan�mlamam�z gerekiyor a�a��da proced�r� �al��t�r�rken IN parametresi olarak verebilmemiz i�in
    PRM_RC VARCHAR2(50); --Yukar�da proced�r�n parametresi olarak tan�mlarken 50'yi verememi�tik ama burada DECLARE alt�nda de�i�ken olarak tan�mlarken verebiliyoruz.

BEGIN
    SP_LOCATION_INSERT('ISTANBUL', '00034', 'ISTANBUL', 'MASLAK', 'Australia', PRM_LOCATION_ID, PRM_RC); --Create b�l�m�nde tan�mlad���m�z parametrelerin s�ras�na g�re parametre vererek procedure'�m�z� �al��t�r�yoruz. �lke ismi olarak COUNTRIES tablosunda bulunan �lkelerden birinin ismini vermemiz gerekiyor COUNTRY_ID'si bo� �ekilde eklememesi i�in.
    DBMS_OUTPUT.PUT_LINE('SONUC: '||PRM_LOCATION_ID||' '||PRM_RC);
END;

SELECT * FROM COUNTRIES;

SELECT * FROM LOCATIONS ORDER BY LOCATION_ID DESC; --Buradan yeni kayd� tablomuza ekleyip eklemedi�ini kontrol edebiliriz.


/******************************************************************************************************************************************************************************/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Bir �al��an�n maa��n� artt�ran bir fonksiyon yazal�m:
-- �nceki �rneklerimizden birinde maa�� belirli bir aral���n d���ndaysa hata veren bir trigger (TRG_SALARY_CONTROL) yapm��t�k. Burdan �rnek alabiliriz
--�imdi de direkt parametre olarak verdi�imiz miktar kadar maa�a zam yapan bir fonksiyon yazaca��z. Yani fonksiyonumuzun iki parametresi olacak: prm_employee_id ve prm_zam
/*****************************************************************************************************/
CREATE OR REPLACE PROCEDURE SP_SALARY_ADD (P_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE,
                                            P_ZAM NUMBER,
                                            P_RC OUT VARCHAR2) IS 

V_SALARY  EMPLOYEES.SALARY%TYPE;
L_MAX_SALARY EMPLOYEES.SALARY%TYPE;
L_MIN_SALARY EMPLOYEES.SALARY%TYPE;

L_JOB_ID JOBS.JOB_ID%TYPE;

EX_LIMIT_KONTROL EXCEPTION; --A�a��da f�rlatmak �zere bir exception tan�mlad�k

BEGIN

    UPDATE EMPLOYEES
    SET SALARY = SALARY + P_ZAM
    WHERE EMPLOYEE_ID = P_EMPLOYEE_ID
    RETURNING JOB_ID, SALARY INTO L_JOB_ID, V_SALARY; --RETURNING ifadesi yukar�da veriyi update ettikten sonra g�ncellenen veriyi almam�z� sa�lar. Yani UPDATE ve SELECT birarada gibi oldu sorgumuz. RETURNING demeseydik update ettikten sonra birde select ile g�ncellenen o veriyi almak zorunda kalacakt�k.

    SELECT MIN_SALARY, MAX_SALARY  INTO L_MIN_SALARY, L_MAX_SALARY 
    FROM JOBS 
    WHERE JOB_ID = L_JOB_ID; --JOBS tablosundaki JOB_ID ile EMPLOYEES tablosundaki JOB_ID (L_JOB_ID)'si e�le�en kay�tlar�n min ve max salary'lerini al�p local de�i�kenlere att�k.
    
    IF V_SALARY > L_MAX_SALARY  OR  V_SALARY < L_MIN_SALARY THEN 
       RAISE EX_LIMIT_KONTROL; --Yukar�da tan�mlad���m�z exception'� burada maa� aral�k d���ndaysa raise ediyoruz.
    END IF;

    P_RC:='BA�ARILI ��LEM'; 
    COMMIT; 
	EXCEPTION WHEN EX_LIMIT_KONTROL THEN  
    ROLLBACK; -- E�er maa� de�eri aral�k d���ndaysa rollback ile yap�lan de�i�iklikleri geri almam�z laz�m. ��nk� yukar�da update �al���yor �ncelikle. Rollback demeyip de daha sonra a�a��larda biyerlerde commit yaparsak aral���n d���nda bile olsa maa�� de�i�tirir.
    P_RC:='MAA� ARALIK DE�ERLER� DI�INDADIR.';
    
END;

SELECT * FROM JOBS;
    
SELECT * FROM EMPLOYEES;


DECLARE
    P_RC VARCHAR2(50);

BEGIN
    SP_SALARY_ADD(198, 2000, P_RC);
    DBMS_OUTPUT.PUT_LINE(P_RC); 
END;

/******************************************************************************************************************************************************************************/





