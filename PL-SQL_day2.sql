--Neden Trigger Kullanýrýz:

--Sanal alanlar için deðer üretmek
--Yapýlan iþlemin loglanmasý
--Veri doðrulamasý (data authentication) yapmak
--Özet veri oluþturmak

--Trigger'lara kritik veri konmamamlýdýr. Çünkü trigger olmadan da bizim sistemimiz çalýþýr. Hata vermez. Mesela birisi bizim trigger'ýmýzý drop veya disable ederse sistem "burada bir trigger vardý nereye gitti o trigger" diye uyarý vermez. Sistem çalýþmaya devam eder. Biz farkedene kadar da iþ iþten geçmiþ olabilir. Dolayýsýyla telafi edilemeyecek kritiklikteki bir veriyi trigger'a güvenerek tutmamamýz gerekir.
--Fakat sonradan telafi edilebilecek bir veriyi trigger'a koyabiliriz. Mesela bir ücret bilgisi girildiðinde hemen onu %20 ile çarpýp zamlý halini baþka bir sütuna yazan bir trigger'ýmýz olsun. Bu trigger disable olmuþ ve bizde bunu 2 ay sonra farketmiþ olalým ve 1 milyon çarpýlmamýþ kayýt birikmiþ olsun. Hemen bir update sorgusu ile ücretlerin %20 zamlý halini hesaplayýp kolona ekleyebilirim. Çünkü burada ham data (ücret) benim elimededir. O yüzden trigger çalýþmasa da kendim yapabilirim. Böyle kritik olmayan durumlarda iþimizi kolaylaþtýrsýn ve hýzlandýrsýn diye trigger kullanýlabilir.
--Ama memory üzerinde anlýk tutulan temp birþeyse mesela, onu trigger'a koyarsak trigger çalýþmadýðýnda o veriyi kaybederiz. O yüzden bu tür þeyler trigger'a konmaz. Normal kod bloðumuz içerisinde bu kritik bilgileri tutmalýyýz.


--Trigger örneði:
--EMPLOYEES tablosuna yeni bir kayýt girildiði zaman bu kaydýn isim-soyisim (FIRST_NAME ve LAST_NAME kolonlarý) kýsmýný otomatik olarak büyük harfe çeviren bir trigger uygulamasý.

--Eðitim sýrasýnda oluþturduðumuz örnek:
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
    :NEW.FIRST_NAME := UPPER(:NEW.FIRST_NAME); -- Deðiþtireceðimiz kayýtlarýn trigger çalýþmadan önceki ve sonraki hallerini :NEW ve :OLD diyerek belirtmek zorundayýz.
    :NEW.LAST_NAME := UPPER(:NEW.LAST_NAME); -- Burada UPPER(:NEW.LAST_NAME) yerine UPPER(:OLD.LAST_NAME) deseydik hatalý çalýþýrdý. Mesela "Bila Iþý" yazan yere "Bilal Iþýk" yazsak bile bize "BILA IÞI" döndürüdü. O yüzden eski halinin (:OLD) deðil de yeni halinin (:NEW) büyük harfli olmasý için :NEW kullandýk. :OLD ifadesini eski kaydý kaybetmemek istediðimiz durumlarda (log tutma vs. gibi) kullanýrýz.
END TRG_EMP_NAME_CONTROL;


SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID=100 FOR UPDATE; -- FOR UPDATE ifadesi istenilen bir satýrý kilitlemek için kullanýlýyor sanýrým.

SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID=100;

UPDATE EMPLOYEES SET COMMISSION_PCT = 0.20 WHERE EMPLOYEE_ID=100; -- Sadece isim ve soyisimde deðil, herhangi bir sütunda da (COMMISSION_PCT gibi) deðiþiklik yapsak isim ve soyismi büyük harfe çevirir.

UPDATE EMPLOYEES SET LAST_NAME = 'Kings' WHERE EMPLOYEE_ID=100; -- Verdiðimiz soyisimde küçük harf olmasýna raðmen hepsini büyük harfe çevirdi.

SELECT * FROM EMPLOYEES ORDER BY EMPLOYEE_ID;


--Baþka bir deneme:

SELECT * FROM EMPLOYEES ORDER BY MANAGER_ID;

UPDATE EMPLOYEES SET PHONE_NUMBER = PHONE_NUMBER||'-1' WHERE MANAGER_ID=100; --Dikkat edersek burada MANAGER_ID'si 100 olan kayýtlarý güncelledik ve oluþturduðumuz TRG_EMP_NAME_CONTROL adlý trigger'dan dolayý hepsinin adý ve soyasý büyük harfe dönüþtü. Çünkü bizim bu trigger'ý oluþturuken CREATE OR REPLACE TRIGGER bölümünde FOR EACH ROW dediðimizden dolayý her bir satýr için çalýþtý ve WHERE þartýmýza uyan bütün kayýtlarýn isim soyismini büyük harfe dönüþtürdü. Yani bir tane UPDATE ifadesi ile 14 (manager_id'si 100 olan kayýt sayýsý) tane kaydý güncelleyebildik FOR EACH ROW ifadesi sayesinde.




/******************************************************************************************************************************************************************************/



--Herhangi birisi bir tabloda update, insert (DML sorgusu) yapmýþ bunun kaydýný tutup bir tabloda loglayan ifade bazlý (statement level) bir trigger uygulamasý.
CREATE OR REPLACE TRIGGER TRG_EMP_LOG
    BEFORE INSERT OR UPDATE OR DELETE
    ON EMPLOYEES -- Dikkat edersek FOR EACH ROW koymadýk bu sefer. Çünkü bu trigger'ýmýz kayýt bazlý deðil. Ýfade bazlý bir tigger.

BEGIN
    INSERT INTO HATA_DURUMLARI VALUES ('TARIH: '||TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    
END TRG_EMP_LOG;

UPDATE EMPLOYEES SET PHONE_NUMBER = REPLACE(PHONE_NUMBER,'-1') WHERE MANAGER_ID=100; -- REPLACE komutu içine verdiðimiz ifadeyi String veritipinden çýkarýr. 14 kayýt güncellendi.

SELECT * FROM HATA_DURUMLARI; -- Biz yukarýda 14 kaydý güncelledik ama HATA_DURUMLARI tablomuza bir tane kayýt eklendi. Çünkü TRG_EMP_LOG trigger'ýmýz ifade bazlý bir trigger. O yüzden bir defa çalýþtý.

SELECT * FROM USER_SOURCE; --USER_SOURCE tablosu db'ye baðlý olduðumuz kullanýcýdaki tüm uygulama kodlarýný (function, trigger, procedure vs.) gösterir.

SELECT * FROM USER_SOURCE
WHERE NAME='GET_DEPT_SALARY'
ORDER BY LINE; -- Burada satýr sayýsýna (LINE) göre sýralarsak bize aradýðýmýz uygulama kodunun (function, trigger, procedure vs.) içeriðini sýralý bir þekilde gösterir.

--Bir tane tablo oluþturup bu tabloya USER_SOURCE tablosundan istediðimiz uygulamalarýn kodlarýný ekleyerek yedek kod tablosu oluþturabiliriz. Böylece kodlarýmýzýn deðiþmesi durumunda eski haline ulaþabiliriz.
CREATE TABLE KOD_YEDEK( --Tablomuzu oluþturduk
    TARIH DATE,
    NAME VARCHAR2(128),
    TYPE VARCHAR2(12),
    LINE NUMBER,
    TEXT VARCHAR2(4000),
    ORIGIN_CON_ID NUMBER);

INSERT INTO KOD_YEDEK -- Bu þekilde SELECT sonucundan gelen ifadeyi bir tabloya INSERT edebiliyoruz.
SELECT SYSDATE, S.* FROM USER_SOURCE S; -- Bu þekilde db'de en son alýnan back up'dan sonra pl sql kodlarýmýzda bir deðiþiklik olduysa onlarý da ayrý bir tabloya yedekleyebiliriz.

SELECT * FROM KOD_YEDEK;



/******************************************************************************************************************************************************************************/



--Bir tablodaki (Mesela DEPARTMENTS tablosu) deðiþiklikleri tarihçesini tutacaðýmýz bir trigger uygulamasý. Yani ":OLD" kullanarak tablonun eski halini baþka bir tabloda (DEPARTMENTS_HIST) yedekleyen bir trigger:

CREATE TABLE DEPARTMENTS_HIST AS 
SELECT * FROM DEPARTMENTS -- Tablo ve kolonlar zaten varsa bu kodlar hata verecektir.

ALTER TABLE DEPARTMENTS_HIST ADD ISLEM_TARIHI DATE

ALTER TABLE DEPARTMENTS_HIST ADD ISLEM VARCHAR2(30)

DROP TABLE DEPARTMENTS_HIST; -- Tabloda fazla sütun varsa tabloyu veya sütunu silmeliyiz. Yoksa sorun çýkartýyor trigger çalýþýrken.

DELETE FROM DEPARTMENTS_HIST;

SELECT * FROM DEPARTMENTS;

SELECT * FROM DEPARTMENTS_HIST;

UPDATE DEPARTMENTS 
SET  DEPARTMENT_NAME = DEPARTMENT_NAME||'XX' --Departman adýnýn sonuna xx ekeldik
WHERE DEPARTMENT_ID=10;

UPDATE DEPARTMENTS 
SET  DEPARTMENT_NAME = REPLACE(DEPARTMENT_NAME,'XX') --Deðiþikliði eski haline çevirdik
WHERE DEPARTMENT_ID=10;

INSERT INTO DEPARTMENTS VALUES --Insert örneði
('99', 'TEST', '200', '1700');

DELETE FROM DEPARTMENTS WHERE DEPARTMENT_ID=99; --DEPARTMENT_ID alaný NUMBER olduðu için týrnak içinde yazmasak da olur

--INSERT ÝÞLEMÝNDE OLD DEPERÝ OLMAZ.
--DELETE ÝÞLEMÝNDE NEW DEÐERÝ OLMAZ.
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


-- TÜM DURUMLARI LOGLAYAN TRIGGER (ISLEM açýklamasýyla birlikte logluyor)
CREATE OR REPLACE TRIGGER  TRG_DEPARTMENT_ALL_HIST
  BEFORE INSERT OR UPDATE OR DELETE
  ON DEPARTMENTS
  FOR EACH ROW
  
DECLARE 
    L_ISLEM VARCHAR2(30);

BEGIN
    IF INSERTING THEN L_ISLEM:='INSERT'; -- Update iþlemi yapýlmýþsa ISLEM kolonuna UPDATE yaz.
    ELSIF UPDATING THEN L_ISLEM:='UPDATE'; -- Insert iþlemi yapýlmýþsa ISLEM kolonuna INSERT yaz.
    ELSE L_ISLEM:='DELETE'; --Ýkisi de deðilse DELETE yaz
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

-- KULLANICININ SAHIP OLDUÐU TRIGGERLAR
select * from USER_TRIGGERS

-- KULLANICININ GÖRMEYE YETKÝLÝ OLDUÐU TRIGGERLAR
select * from ALL_TRIGGERS

-- DBA YETKÝLÝ OLD. TÜM  TRIGGERLAR
select * from DBA_TRIGGERS


-- GÜNCELLENEN/GÝRÝLEN MAAÞ DEÐERLERÝ MÝN MAX DEÐERLERÝ ARASINDA DEÐÝLSE HATA VEREN TRIGGER
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
    RAISE_APPLICATION_ERROR (-20001,'MAAÞ ARALIK DEÐERLERÝ DIÞINDADIR.');
END IF;


END;



/******************************************************************************************************************************************************************************/

------- EXCEPTION ÇEÞÝTLERÝ----------
--Her exceptýon'ý yakalama þansýmýz yok. Sadece yaygýn olan hatalar veya oluþabileceðini tahmin ettiðimiz hatalarý yakalayýp önlem alýrýz genelde.


--Sýfýra bölünememe (divisor is equal to zero) hatasý yakalama örneði:

DECLARE
    L_VAL NUMBER;
    L_RC VARCHAR2(100);

BEGIN
    L_VAL := 1/0;
    EXCEPTION WHEN OTHERS THEN --OTHERS dersek bütün hatalarý kapsar. Sadece sýfýra bölünememe hatasýný almak istersek ZERO_DIVIDE yazmamýz gerekirdi.
    DBMS_OUTPUT.PUT_LINE(SQLCODE||' '||SQLERRM); -- Gelen hatanýn kodunu ve açýklamasýný yazdýrýyoruz.
    L_RC := '0''A BOLUNEMEME HATASI';
    DBMS_OUTPUT.PUT_LINE(L_RC);-- Yada bu þekilde kullanýcýnýn anlayabileceði bir açýklama da yazdýrabiliriz..
END;


--Oracle'da bazý yaygýn hatalar hata kodu yerine ayrýca isimlendirilmiþtir:
--zero_divide(ora-1476)
--no_data_found(ora-1403)
--too_many_rows(ora-1422)
--dup_val_on_index(ora-1) -- Mükerrer kayýt kontrolü hatasý
--value_error(ora-6502) vs. gibi




/******************************************************************************************************************************************************************************/


--Exception ile hata yakalama uygulamasý:
CREATE OR REPLACE PROCEDURE DEPARTMENT_INSERT2(
  PRM_DEPT DEPARTMENTS%ROWTYPE,
  PRM_RC OUT VARCHAR2
  ) IS

ZORUNLU_ALAN_HATASI EXCEPTION;
PRAGMA EXCEPTION_INIT(ZORUNLU_ALAN_HATASI, -02290); -- Oracle'ýn 02290 numaralý hatasýný ZORUNLU_ALAN_HATASI olarak tanýmladýk burada. Hoca yaparken 1400 nolu hatayý tanýmlamýþtýk. Toad da 02290 olarak verdi hatayý. Yani Oracle'ýn kendisinin isimlendirmediði bir hatayý biz kendimiz bu þekilde adlandýrabiliyoruz


BEGIN
  INSERT INTO DEPARTMENTS VALUES PRM_DEPT;
  PRM_RC := 'Islem basarili';
  COMMIT;
EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    PRM_RC := 'Mukerrer bolum numarasi';
WHEN ZORUNLU_ALAN_HATASI THEN --Burada da yukarýda tanýmladýðýmýz hatayý kullanýyoruz.
    PRM_RC := 'Zorunlu alanlari doldurunuz '||SQLERRM;      
WHEN OTHERS THEN -- Aklýmýza gelen tüm hatalarý yakaladýktan sonra diðer beklenmeyen hatalar için WHEN OTHERS kullanýrýz.
    PRM_RC := 'Beklenmeyen DB Hatasi '||SQLERRM;  
END;



/******************************************************************************************************************************************************************************/


--Hata yakalama procedure'ümüzü tanýmladýk. Þimdi aþaðýdaki kod bloðunu çalýþtýrarak kayýt eklemeye çalýþalým ve çýkan hatalarý inceleyelim.
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

--Depatman yöneticisi bulunmayan birimlere yöneticisi, Administrator departmanýnýn yöneticisi olan kiþinin ismini (Jennifer Whalen) default olarak veren uygulama:
--Eðer girilen deðerin bölümü (depatment_id) yoksa NULL döndürsün. Bölümü varsa ama yöneticisi yoksa o zaman yöneticisi, Administrator departmanýnýn yöneticisi olan kiþinin ismini (Jennifer Whalen) yazdýr. Insert yok, sadece ekrana yazdýracak. Yani select iþlemi yapýlacak


-- Daha önceden yaptýðýmýz ID'si verilen Departman'ýn Yöneticisini (Manager) veren fonksiyonu kopyaladýk buraya. Bu fonksiyon bize Id'si verilen departmanýn yöneticisini veriyor halihazýrda.

SELECT * FROM DEPARTMENTS;

SELECT * FROM EMPLOYEES;

SELECT * FROM EMPLOYEES  E, DEPARTMENTS D;

CREATE OR REPLACE FUNCTION FUNC_DEPT_MANAGER_NAME(PRM_ID EMPLOYEES.DEPARTMENT_ID%TYPE)
RETURN VARCHAR2 IS -- Burada bir local deðiþken oluþturmadýðýmýz için return kýsmýnda sadece datatype'ýný verip býraktýk. 

L_ISIM EMPLOYEES.FIRST_NAME%TYPE;  --Eðer L_ISIM deðiþkenine EMPLOYEES.FIRST_NAME'in karakter sayýsýndan uzun olan bir Ýsim Soyisim atanýrsa INTO L_ISIM kýsmýnda string'i into ile L_ISIM deðiþkenine atarken "ORA-06502: PL/SQL: numeric or value error: character string buffer too small" hatasý verecektir.
L_NAME EMPLOYEES.FIRST_NAME%TYPE;
L_BOLUM DEPARTMENTS.DEPARTMENT_ID%TYPE;

BEGIN
    SELECT FIRST_NAME || ' ' || LAST_NAME INTO L_ISIM -- Mesela burada LAST_NAME'den sonra EMAIL'i de yazdýrmak için yanýna || ' ' || EMAIL ifadesini de ekleseydik isim+soyisim+email toplamý 20 karakteri aþacaðý için ORA-06502 hatasý verecekti.
    FROM EMPLOYEES  E, DEPARTMENTS D -- Ýki farklý tablo ile ilgili where koþulu vereceksek bu þekilde harf vererek isimlendirebilriz..
    WHERE D.MANAGER_ID = E.EMPLOYEE_ID 
    AND D.DEPARTMENT_ID = PRM_ID;
    
    RETURN(L_ISIM);
    
    BEGIN -- Fonksiyona parametre olarak verdiðimiz Departman (department_id) yoksa NULL dönen hata kontrol kýsmý
        SELECT DEPARTMENT_ID INTO L_BOLUM
        FROM DEPARTMENTS D 
        WHERE D.DEPARTMENT_ID = PRM_ID;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Boyle bir departman yok.'); 
        RETURN(NULL);    
    END; -- Ýki ayrý NO_DATA_FOUND hatasýný da ayrý ayrý BEGIN-END bloðu arasýna almamýz gerekiyor. Böyle yapmasaydýk, tek bir BEGIN-END bloðu olsaydý her zaman en alttaki NO_DATA_FOUND hatasýna düþecekti. Yani olmayan bir department_id(-10) verseydik yine Jennifer Whalen yazacaktý. Bu da mantýksýz olurdu

    BEGIN -- Parametre olarak ID'si verdiðimiz Departman varsa, fakat Yöneticisi yoksa, o zaman yöneticisi, Administrator departmanýnýn yöneticisi olan kiþinin ismini (Jennifer Whalen)veriyoruz.
        SELECT FIRST_NAME || ' ' || LAST_NAME INTO L_NAME
        FROM EMPLOYEES  E, DEPARTMENTS D 
        WHERE D.MANAGER_ID = E.EMPLOYEE_ID 
        AND D.DEPARTMENT_ID = 10;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Girdiginiz departmanin yoneticisi olmadigi icin 10 nolu departmanýn yoneticisi oldugu kisinin ismi getirilecektir'); 
        RETURN(L_NAME);
    END;    
END;

SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = -130;

SELECT FUNC_DEPT_MANAGER_NAME(-10) FROM DUAL;

SELECT DEPARTMENT_NAME, FUNC_DEPT_MANAGER_NAME(DEPARTMENT_ID) FROM DEPARTMENTS; --Tüm Id'lerle birlikte çalýþtýrmak için.


/******************************************************************************************************************************************************************************/
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Yeni lokasyon tanýmlayan birtane prosedür uygulamasý:
--Locations tablosuna insert yapan bir procedure yazalým. Location_id'yi dýþarýdan deðil sequence'den alalým. Ayrýca country_id'yi deðil de country_name'i göndereceðiz parametre olarak. Bunun için de country_name'den country_id'yi bulan bir sorgu yazmamýz gerekiyor ayrýca.
--LOCATIONS_SEQ adlý bir sequence var. Sequence'ler sýralý olarak numara üretirler. Mesela bir tabloya insert yaparken sýralý numaralar üretmemizi saðlar. Location_id'yi bu sequence'den alacaðýz.
--Giriþ Parametreleri: PRM_STREET_ADDRESS, PRM_POSTAL_CODE, PRM_CITY, PRM_STATE_PROVINCE, PRM_COUNTRY_NAME
--out parametreler: insert edilen lokasyon kaydýnýn id bilgisini kullanýcýya göstermek için PRM_LOCATION_ID ve kullancýya hata durmunda mesaj göstermek için PRM_RC
--Hata kodlarýný da EXCEPTION WHEN bloklarý içerisinde tanýmlayalým

SELECT * FROM LOCATIONS;

SELECT * FROM COUNTRIES;

CREATE OR REPLACE PROCEDURE SP_LOCATION_INSERT (
                                            
                                            PRM_STREET_ADDRESS LOCATIONS.STREET_ADDRESS%TYPE,
                                            PRM_POSTAL_CODE LOCATIONS.POSTAL_CODE%TYPE,
                                            PRM_CITY LOCATIONS.CITY%TYPE,
                                            PRM_STATE_PROVINCE LOCATIONS.STATE_PROVINCE%TYPE,
                                            PRM_COUNTRY_NAME COUNTRIES.COUNTRY_NAME%TYPE, -- Country_name'in data tipini COUNTRIES tablosundan alýyor. Diðerlerini LOCATIONS tablosundan.
                                            
                                            PRM_LOCATION_ID OUT LOCATIONS.LOCATION_ID%TYPE, -- Burada sadece parametre ve datatype'larýný tanýmlýyoruz. Sequence olarak Begin-End içerisinde tanýmlayacaðýz.
                                            PRM_RC OUT VARCHAR2 --Procedure'lerde out parametrelerinin dataype'ýna sýnýrlandýrma koyamayýz. Yani VARCHAR2(50) þeklinde yapamazdýk. Sadece VARCHAR2 þeklinde yazmalýyýz.
                                            ) IS
L_COUNTRY_ID COUNTRIES.COUNTRY_ID%TYPE;
L_LOCATION_ID NUMBER; -- Parametre olarak almayacaðýmýz deðerleri de LOCATIONS tablosuna insert edebilmek için burada local deðiþken olarak tanýmladýk.                                  
                                            
BEGIN

    BEGIN -- Burada COUNTRIES tablosunu BEGIN-END bloðu arasýna alarak bir nevi koruma altýna aldýk. Oluþacak datayý baþka bir sorguyla karýþtýrmadan baðýmsýz olarak ele almýþ olduk. Mesela PRM_COUNTRY_NAME gibi baþka tablodan (COUNTRIES) alacaðýmýz baþka bir data olsaydý (CITIES tablosundan alacaðýmýz CITY_NAME gibi) onu da BEGIN-END arasýna almamýz daha doðru olurdu karýþmamasý için. Yani EXCEPTION (HATA) yönetimlerini diðer kod bloklarýndan baðýmsýz olarak yapmamýz daha doðru.
        SELECT COUNTRY_ID INTO L_COUNTRY_ID 
        FROM COUNTRIES 
        WHERE COUNTRY_NAME = PRM_COUNTRY_NAME; --LOCATIONS tablosuna insert edeceðimizi yeni lokasyonun COUNTRY_ID'sini elde edebilmek için COUNTRIES tablosundan bizim parametre olarak verdiðimiz PRM_COUNTRY_NAME ile eþleþen ülkenin COUNTRY_ID'sini aldýk. Bu sorgunun sonucunu da INTO ifadesiyle L_COUNTRY_ID deðiþkenimize attýk kullanabilmek için. Eðer atmasaydýk direkt kullanamazdýk COUNTRY_ID kolonu üzerinden.

        EXCEPTION WHEN NO_DATA_FOUND THEN -- Hata yönetimini bu kýsýmda yapýyoruz.
            PRM_RC := 'Gecersiz ulke adi '; -- Burada sadece P_RC'nin deðerini deðiþtirmemiz yeterli. Fonksiyonlardaki gibi return etmemize gerek yok. Prosedür olduðu için kendisi return edecektir zaten. Eðer döndürmemiz gerekn birþey varsa onu CREATE kýsmýnda OUT parametre olarak veriyoruz.
    END;
    
    BEGIN
        NULL; -- NULL koymazsak BEGIN-END bloðu çalýþmaz içerisi boþken.
        --DIÐER SEÇIM SQLLERI -- Mesela baþka tablodan alacaðýmýz baþka bir data olsaydý ( Eðer CITIES tablosu olsaydý oradan alacaðýmýz CITY_NAME gibi) onu da BEGIN-END arasýna almamýz daha doðru olurdu karýþmamasý için. 
        --EXCEPTION -- Yani EXCEPTION (HATA) yönetimlerini diðer kod bloklarýndan baðýmsýz olarak yapmamýz daha doðru.
        -- Burada ya region_name (bölge ismi) için bir sorgu koyup öyle dene bakalým. Yani önce LOCATIONS tablosunda REGION_ID diye bir kolon oluþturalým. Sonra prosedüre parametre olarak REGION_NAME verelim. Sonra REGIONS tablosundan verdiðimiz REGION_NAME'in karþýlýðý olan REGION_ID'yi alýp onu da LOCATIONS tablosuna kayýt insert ederken, oluþturduðumuz REGION_ID kolonuna ekleyelim.
        
    END;

    L_LOCATION_ID := LOCATIONS_SEQ.NEXTVAL; -- Insert yaparken her seferinde kendimiz id vermek zorunda kalmayalým diye LOCATIONS_SEQ.NEXTVAL ile her kayýtta otomatik sýralý numaralar üretmesini saðladýk. Php'de id eklerkenki auto increment özelliði gibi. Db'de oluþturulmuþ diðer sequence'larý görmek istersek Schema Browser'dan Sequences bölümüne bakabiliriz. Buradan Script sekmesine gelerek Sequence'in özelliklerini (hangi sayýdan baþlayýp hangi deðere kadar gidecek? kaçar kaçar artacak? vs. )görebiliriz. Kendimiz bir sequence oluþturmak istersek internette "Oracle Sequence" diye aratýrsak nasýl yapýlcaðý çýkacaktýr.
    
    INSERT INTO LOCATIONS
    VALUES (L_LOCATION_ID, PRM_STREET_ADDRESS, PRM_POSTAL_CODE, PRM_CITY, PRM_STATE_PROVINCE, L_COUNTRY_ID);
    
    PRM_LOCATION_ID := L_LOCATION_ID; -- DBMS_OUTPUT'da çýktý olarak verilebilmesi için burada OUT parametrelerimize deðer atýyoruz. Sonra prosedürümüzü çalýþtýrýken parametre olarak vereceðiz.
    PRM_RC := 'Islem basarili ';
    
    COMMIT; -- EXCEPTION WHEN OTHERS'ýn Commit'den sonra yazýlmasý gerekiyor sanýrým.
    
    EXCEPTION WHEN OTHERS THEN
		PRM_RC := 'Beklenmeyen DB Hatasi'; 
END;


DECLARE --Declare içerisinde bir deðiþkene, parametreye vs. deðer atamasý yapamýyoruz. Sadece tanýmlama yapabiliyoruz.
    PRM_LOCATION_ID LOCATIONS.LOCATION_ID%TYPE; --Burada tekrar out parametrelerini "OUT" keyword'ü çýkarýlmýþ þekilde yeniden DECLARE altýnda deðiþken olarak data tipleriyle birlikte tanýmlamamýz gerekiyor aþaðýda procedürü çalýþtýrýrken IN parametresi olarak verebilmemiz için
    PRM_RC VARCHAR2(50); --Yukarýda procedürün parametresi olarak tanýmlarken 50'yi verememiþtik ama burada DECLARE altýnda deðiþken olarak tanýmlarken verebiliyoruz.

BEGIN
    SP_LOCATION_INSERT('ISTANBUL', '00034', 'ISTANBUL', 'MASLAK', 'Australia', PRM_LOCATION_ID, PRM_RC); --Create bölümünde tanýmladýðýmýz parametrelerin sýrasýna göre parametre vererek procedure'ümüzü çalýþtýrýyoruz. Ülke ismi olarak COUNTRIES tablosunda bulunan ülkelerden birinin ismini vermemiz gerekiyor COUNTRY_ID'si boþ þekilde eklememesi için.
    DBMS_OUTPUT.PUT_LINE('SONUC: '||PRM_LOCATION_ID||' '||PRM_RC);
END;

SELECT * FROM COUNTRIES;

SELECT * FROM LOCATIONS ORDER BY LOCATION_ID DESC; --Buradan yeni kaydý tablomuza ekleyip eklemediðini kontrol edebiliriz.


/******************************************************************************************************************************************************************************/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Bir çalýþanýn maaþýný arttýran bir fonksiyon yazalým:
-- Önceki örneklerimizden birinde maaþý belirli bir aralýðýn dýþýndaysa hata veren bir trigger (TRG_SALARY_CONTROL) yapmýþtýk. Burdan örnek alabiliriz
--Þimdi de direkt parametre olarak verdiðimiz miktar kadar maaþa zam yapan bir fonksiyon yazacaðýz. Yani fonksiyonumuzun iki parametresi olacak: prm_employee_id ve prm_zam
/*****************************************************************************************************/
CREATE OR REPLACE PROCEDURE SP_SALARY_ADD (P_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE,
                                            P_ZAM NUMBER,
                                            P_RC OUT VARCHAR2) IS 

V_SALARY  EMPLOYEES.SALARY%TYPE;
L_MAX_SALARY EMPLOYEES.SALARY%TYPE;
L_MIN_SALARY EMPLOYEES.SALARY%TYPE;

L_JOB_ID JOBS.JOB_ID%TYPE;

EX_LIMIT_KONTROL EXCEPTION; --Aþaðýda fýrlatmak üzere bir exception tanýmladýk

BEGIN

    UPDATE EMPLOYEES
    SET SALARY = SALARY + P_ZAM
    WHERE EMPLOYEE_ID = P_EMPLOYEE_ID
    RETURNING JOB_ID, SALARY INTO L_JOB_ID, V_SALARY; --RETURNING ifadesi yukarýda veriyi update ettikten sonra güncellenen veriyi almamýzý saðlar. Yani UPDATE ve SELECT birarada gibi oldu sorgumuz. RETURNING demeseydik update ettikten sonra birde select ile güncellenen o veriyi almak zorunda kalacaktýk.

    SELECT MIN_SALARY, MAX_SALARY  INTO L_MIN_SALARY, L_MAX_SALARY 
    FROM JOBS 
    WHERE JOB_ID = L_JOB_ID; --JOBS tablosundaki JOB_ID ile EMPLOYEES tablosundaki JOB_ID (L_JOB_ID)'si eþleþen kayýtlarýn min ve max salary'lerini alýp local deðiþkenlere attýk.
    
    IF V_SALARY > L_MAX_SALARY  OR  V_SALARY < L_MIN_SALARY THEN 
       RAISE EX_LIMIT_KONTROL; --Yukarýda tanýmladýðýmýz exception'ý burada maaþ aralýk dýþýndaysa raise ediyoruz.
    END IF;

    P_RC:='BAÞARILI ÝÞLEM'; 
    COMMIT; 
	EXCEPTION WHEN EX_LIMIT_KONTROL THEN  
    ROLLBACK; -- Eðer maaþ deðeri aralýk dýþýndaysa rollback ile yapýlan deðiþiklikleri geri almamýz lazým. Çünkü yukarýda update çalýþýyor öncelikle. Rollback demeyip de daha sonra aþaðýlarda biyerlerde commit yaparsak aralýðýn dýþýnda bile olsa maaþý deðiþtirir.
    P_RC:='MAAÞ ARALIK DEÐERLERÝ DIÞINDADIR.';
    
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





