------OTONOM OLMAYAN TRANSACTIONS -----
TRUNCATE TABLE HATA_DURUMLARI

CREATE OR REPLACE PROCEDURE SP_IC_PROSEDUR  IS
BEGIN 
 INSERT INTO HATA_DURUMLARI VALUES ('İÇ PROSEDÜR HATASI.'|| SYSTIMESTAMP);
ROLLBACK;
END;


CREATE OR REPLACE PROCEDURE SP_DIS_PROSEDUR  IS
BEGIN 
 INSERT INTO HATA_DURUMLARI VALUES ('DIŞ PROSEDÜR HATASI.'|| SYSTIMESTAMP);
SP_IC_PROSEDUR;
COMMIT;
END;


EXEC SP_DIS_PROSEDUR;

select * from HATA_DURUMLARI


------ OTONOM TRANSACTIONS -----
-- OTONOM PROSEDÜR ÇAĞIRAN YERDEN BAĞIMSIZ YÜRÜTÜR İŞLEMLERİNİ.
CREATE OR REPLACE PROCEDURE SP_IC_PROSEDUR_AUTONOMOUS  IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN 
 INSERT INTO HATA_DURUMLARI VALUES ('İÇ PROSEDÜR HATASI.'|| SYSTIMESTAMP);
COMMIT;
END;


CREATE OR REPLACE PROCEDURE SP_DIS_PROSEDUR_AUTONOMOUS  IS
BEGIN 
 INSERT INTO HATA_DURUMLARI VALUES ('DIŞ PROSEDÜR HATASI.'|| SYSTIMESTAMP);
SP_IC_PROSEDUR_AUTONOMOUS;
ROLLBACK;
END;

EXEC SP_DIS_PROSEDUR_AUTONOMOUS

----------------------------------


CREATE OR REPLACE PROCEDURE SP_HATA_KAYDET (P_TEXT VARCHAR2)  IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN 
 INSERT INTO HATA_DURUMLARI VALUES ('SP_HATA_KAYDET PROSEDÜR HATASI.  ' ||P_TEXT|| '  '|| SYSTIMESTAMP);
COMMIT;
END;


CREATE OR REPLACE PROCEDURE SP_DOSYA_OKUMA_AUTONOMOUS IS
-- DOSYADAN OKUMA

      V1 VARCHAR2(600); 
      F1 UTL_FILE.FILE_TYPE; 
      
L_ID        ABONE.ID%TYPE;
L_ABONE_NO  ABONE.ABONE_NO%TYPE;
L_ABONE_ADI ABONE.ABONE_ADI%TYPE;

L_CNT NUMBER := 0;

L_ERR VARCHAR2 (200);

    BEGIN 
       
       F1 := UTL_FILE.FOPEN('USER_DIR2','utlFileDosya.txt','r'); 
       INSERT INTO ISLENEN_DOSYA VALUES ('utlFileDosya.txt' , 0);
       
       
       LOOP
       BEGIN
       SAVEPOINT GUVENLI_NOKTA;
       
         L_ID := NULL;
         L_ABONE_NO := NULL;
         L_ABONE_ADI := NULL;
         
         L_CNT := L_CNT +1 ;
         
         UTL_FILE.GET_LINE(F1,V1); 
         DBMS_OUTPUT.PUT_LINE ('. '||V1||'. ');
       UPDATE ISLENEN_dOSYA 
          SET ISLENEN_KAYIT_SAYISI = ISLENEN_KAYIT_SAYISI+1
        WHERE DOSYA_aDI = 'utlFileDosya.txt' ;
         
        BEGIN 
           L_ID        := SUBSTR(V1,1 ,10);
           EXCEPTION WHEN VALUE_ERROR
           THEN L_ERR :=  SQLERRM;
                ROLLBACK TO GUVENLI_NOKTA;
                SP_HATA_KAYDET(V1 || '  ' || L_ERR); -- OTONOM TRANSACTION ILE HATA YÖNETİMİ.
--                INSERT INTO HATA_DURUMLARI VALUES (V1 || '  ' || L_ERR);
                CONTINUE;
        END;
         L_ABONE_NO  := SUBSTR(V1,11,10);
         L_ABONE_ADI := SUBSTR(V1,21);
         
         BEGIN 
         INSERT INTO ABONE ( ID, ABONE_NO, ABONE_ADI ) VALUES ( L_ID, L_ABONE_NO, L_ABONE_ADI );
         EXCEPTION WHEN DUP_VAL_ON_INDEX 
          THEN L_ERR :=  SQLERRM; 
               ROLLBACK TO GUVENLI_NOKTA;
               INSERT INTO HATA_DURUMLARI VALUES (V1 || '  ' || L_ERR);
               CONTINUE;
         END;
         
         
         IF MOD (L_CNT,1000) = 0  THEN COMMIT; END IF ;


       EXCEPTION WHEN NO_DATA_FOUND THEN
         EXIT;
       
       END;
       END LOOP;
       
      UTL_FILE.FCLOSE(F1); 
      COMMIT;
      
    END;
    
    TRUNCATE TABLE ABONE 
    
EXEC SP_DOSYA_OKUMA_AUTONOMOUS;
    
    select * from ABONE 
    
    select * from HATA_DURUMLARI
    
------------------------------------------------------
--ROWID : her bir satırın disk üzerindeki id'si. En hızlı erişim yöntemidir.
------------------------------------------------------


------------------------------------
--GLOBAL DEĞİŞKENLER
------------------------------------
--SPEC
CREATE OR REPLACE PACKAGE  PCK_GLOBAL AS

P_SAAT   NUMBER (2);
P_DAKIKA NUMBER (2);

PROCEDURE SP_PARAMETRE_GUNCELLE;

END;


--BODY
CREATE OR REPLACE PACKAGE BODY  PCK_GLOBAL IS
PROCEDURE SP_PARAMETRE_GUNCELLE IS 
BEGIN  
  P_SAAT   := to_CHAR (SYSDATE, 'HH24');
  P_DAKIKA := TO_CHAR (SYSDATE, 'MI');
END ;

BEGIN
  SP_PARAMETRE_GUNCELLE;
END;


DECLARE
  L_SAAT NUMBER (2);
  L_DAKIKA NUMBER (2);
BEGIN
  L_SAAT   := PCK_GLOBAL.P_SAAT;
  L_DAKIKA := PCK_GLOBAL.P_DAKIKA;
  DBMS_OUTPUT.PUT_LINE ( L_SAAT || ' : ' || L_DAKIKA);
END;

EXEC PCK_GLOBAL.SP_PARAMETRE_GUNCELLE;

--------------------------
--IN OUT PARAMETRE
--------------------------

CREATE OR REPLACE PROCEDURE SP_IN_OUT_PARAMETER (P_IN_OUT IN OUT VARCHAR2) IS

BEGIN
  DBMS_OUTPUT.PUT_LINE ('1-GELEN DEĞER : '||P_IN_OUT );
  P_IN_OUT:= 'PROSEDÜR İÇİNDE GÜNCELLENDİ. ';
  DBMS_OUTPUT.PUT_LINE ('2-GELEN DEĞER : '||P_IN_OUT);
END;

DECLARE 
  L_IN_OUT VARCHAR2 (50);
BEGIN
  L_IN_OUT := 'İLK DEĞER';
  SP_IN_OUT_PARAMETER (L_IN_OUT );
   DBMS_OUTPUT.PUT_LINE ('3-DÖNEN DEĞER : '||L_IN_OUT);
END;

------------------------
--ÖRNEK - IN  OUT.  (İÇ İÇE KULLANIM)
------------------------

CREATE OR REPLACE PROCEDURE SP_IN_OUT_IC ( PRM_RC IN OUT NUMBER )  IS
BEGIN 
 INSERT INTO HATA_DURUMLARI VALUES ('SP_IN_OUT_IC PROSEDÜR HATASI.'|| SYSTIMESTAMP);
PRM_RC := '2';
END;

CREATE OR REPLACE PROCEDURE SP_IN_OUT_DIS ( PRM_RC OUT NUMBER )  IS
BEGIN 
 INSERT INTO HATA_DURUMLARI VALUES ('SP_IN_OUT_DIS PROSEDÜR HATASI.'|| SYSTIMESTAMP);
IF SQL%ROWCOUNT = 0
  THEN PRM_RC := '1'; 
  RETURN ; --ÇIKIŞ
END IF;

 SP_IN_OUT_IC(PRM_RC);

 COMMIT;
END;

DECLARE 
 PRM_RC NUMBER(10);
BEGIN
SP_IN_OUT_DIS (PRM_RC);
DBMS_OUTPUT.PUT_LINE (PRM_RC);
END;


-------------------------------------------

SELECT * FROM DBA_EXTENTS

SELECT * FROM DBA_SEGMENTS
-------------------------------------------

-------------------------------------------
-- EXTERNAL TABLES
-------------------------------------------


CREATE TABLE abone_load
  (id      CHAR(10),
   abone_no       CHAR(10),
   abone_adi      char(40))
ORGANIZATION EXTERNAL
  (TYPE ORACLE_LOADER
   DEFAULT DIRECTORY user_dir2
   ACCESS PARAMETERS
     (RECORDS DELIMITED BY NEWLINE
      FIELDS (id      CHAR(10),
                   abone_no       CHAR(10),
                   abone_adi      char(40)
             )
     )
   LOCATION ('info.dat')
  );



-- Create table
create table EXT_ABONE_LOAD
(
  id        varCHAR2(10),
  abone_no  varCHAR2(10),
  abone_adi varCHAR2(40)
)
organization external
(
  type ORACLE_LOADER
  default directory USER_DIR2
  access parameters 
  (
    RECORDS DELIMITED BY NEWLINE
          FIELDS (id      CHAR(10),
                  abone_no       CHAR(10),
                 abone_adi      char(40)
                 )
  )
  location (USER_DIR2:'utlFileDosya.txt')
)

select * from EXT_ABONE_LOAD


update EXT_ABONE_LOAD set abone_no = 1111 -- ext table üzerinde veri güncellenemez. yalnızca okuma amaçlıdır.
where id= '0000000846'


------------------------------
--VİEW
------------------------------



------------------------------
--DATA INTEGRITY: objeler arası tutarlılık/bütünlük.
------------------------------
--foreign keys, tablolar arasındaki ilişkiler, constraints vb. ile yönetilir.



------------------------------
--PERFORMANS İYİLEŞTİRME
------------------------------

--DATA TYPE CONVERTION'A SEBEBİYET VERMEMEK ÖNEMLİ.
DECLARE 

  CURSOR C1 IS 
  select * from EMPLOYEES;

--  L_UCRET NUMBER (6) := 0;          --PERFORMANSSIZ
  L_UCRET EMPLOYEES.SALARY%TYPE := 0; --DAHA PERFORMANSLI

BEGIN

  FOR LC1 IN C1 LOOP 
   L_UCRET := L_UCRET + LC1.SALARY;
--   IF LC1.DEPARTMENT_ID = '50'    --PERFORMANSSIZ (NUMBER = STRING)
     IF LC1.DEPARTMENT_ID = 50      --PERFORMANSLI 
     THEN DBMS_OUTPUT.PUT_LINE ('YÖNETİM BÖLÜMÜDÜR.'); 
     END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE ( 'TOPLAM UCRET : '|| L_UCRET);
  
END;



select FUNC_DEPT_ADRES('50') FROM DUAL  -- PERFORMASSIZ

select FUNC_DEPT_ADRES(50) FROM DUAL  -- PERFORMASLI



select * from  DEPT_SUMMARY

select * from COUNTRIES

select * from LOCATIONS

select * from EMPLOYEES

select * from DEPARTMENTS

--FUNCTION_COUNTRY_SALARY;

select * from DEPARTMENTS D, LOCATIONS L, EMPLOYEES E
WHERE D.LOCATION_ID = L.LOCATION_ID
and e.department_id= d.department_id;


DECLARE 

  CURSOR C1 IS 
    select fırst_name, last_name, l.country_id, d.department_id  from DEPARTMENTS D, LOCATIONS L, EMPLOYEES E
    WHERE D.LOCATION_ID = L.LOCATION_ID
    and e.department_id= d.department_id;

  L_UCRET EMPLOYEES.SALARY%TYPE := 0; 

BEGIN

  FOR LC1 IN C1 LOOP 

     IF (LC1.DEPARTMENT_ID = 50      --KOLAY HESAPALANANI ÜSTE YAZMAK DAHA PERFORMANSLIDIR. 
         or 
         FUNCTION_COUNTRY_SALARY(lc1.country_id) > 50000 -- KRITERLERI KOLAYDAN ZORA DOĞRU SIRALAMAK TERCIH EDILMELIDIR.
         )
     THEN DBMS_OUTPUT.PUT_LINE ('UYGUN ÇALIŞAN.'); 
     END IF;
  END LOOP;
  
END;

------------------------------------------------
--TABLO/KOLON ISMININ PARAMETRIK OLMASI ÖRNEĞI  -- START
------------------------------------------------
--tüm tablolara 1 kolon eklemek

select 'ALTER TABLE ' || TABLE_NAME || ' ADD YENI_ALAN NUMBER (4);' from user_tables

ALTER TABLE ABONE ADD YENI_ALAN NUMBER(4)

ALTER TABLE REGIONS ADD YENI_ALAN NUMBER (4);

select * from REGIONS 


ALTER TABLE REGIONS ADD YENI_ALAN NUMBER (4);
ALTER TABLE COUNTRIES ADD YENI_ALAN NUMBER (4);
ALTER TABLE JOBS ADD YENI_ALAN NUMBER (4);
ALTER TABLE DEPARTMENTS ADD YENI_ALAN NUMBER (4);
ALTER TABLE EMPLOYEES ADD YENI_ALAN NUMBER (4);
ALTER TABLE LOCATIONS ADD YENI_ALAN NUMBER (4);
ALTER TABLE JOB_HISTORY ADD YENI_ALAN NUMBER (4);
ALTER TABLE DEPT_SUMMARY ADD YENI_ALAN NUMBER (4);
ALTER TABLE HATA_DURUMLARI ADD YENI_ALAN NUMBER (4);
ALTER TABLE DEPARTMENTS_HIST ADD YENI_ALAN NUMBER (4);
ALTER TABLE FATURA_TIPI ADD YENI_ALAN NUMBER (4);
ALTER TABLE ABONE ADD YENI_ALAN NUMBER (4);
ALTER TABLE FATURA ADD YENI_ALAN NUMBER (4);
ALTER TABLE A ADD YENI_ALAN NUMBER (4);
ALTER TABLE B ADD YENI_ALAN NUMBER (4);
ALTER TABLE ISLENEN_DOSYA ADD YENI_ALAN NUMBER (4);
ALTER TABLE EMPLOYEES_TEMP ADD YENI_ALAN NUMBER (4);
ALTER TABLE ABONE_TEMP_SESSION ADD YENI_ALAN NUMBER (4);
ALTER TABLE ABONE_LOAD ADD YENI_ALAN NUMBER (4);
ALTER TABLE EXT_ABONE_LOAD ADD YENI_ALAN NUMBER (4);

CREATE OR REPLACE PROCEDURE SP_KOLON_EKLEME (PRM_YENI_ALAN VARCHAR2)  IS

CURSOR C1 IS
select TABLE_NAME, 'ALTER TABLE ' || TABLE_NAME ||' ADD ' || PRM_YENI_ALAN  SONUC from user_tables;
L_ERR VARCHAR2 (200);
BEGIN

  FOR LC1 IN C1 LOOP
    BEGIN
        EXECUTE IMMEDIATE LC1.SONUC;
        DBMS_OUTPUT.PUT_LINE (LC1.TABLE_NAME || '  OLUŞTURULDU.');
        EXCEPTION WHEN OTHERS THEN
        L_ERR := SQLERRM;
        DBMS_OUTPUT.PUT_LINE (LC1.TABLE_NAME ||'  HATA ALDI. HATA:  ' || L_ERR);
    END;
  END LOOP ;

END;


EXEC SP_KOLON_EKLEME('YENI_ALAN3 NUMBER(4)');







CREATE OR REPLACE PROCEDURE SP_KOLON_EKLEME (P_COLUMN_NAME VARCHAR2, P_TYPE VARCHAR2)  IS

CURSOR C1 IS
SELECT TABLE_NAME, 'ALTER TABLE  '||TABLE_NAME ||'  MODIFY  ' || COLUMN_NAME || '  ' || P_TYPE  SONUC
FROM  USER_TAB_COLUMNS
WHERE COLUMN_NAME = P_COLUMN_NAME ;

L_ERR VARCHAR2 (200);

BEGIN

  FOR LC1 IN C1 LOOP
    BEGIN
        DBMS_OUTPUT.PUT_LINE (LC1.SONUC);
        EXECUTE IMMEDIATE LC1.SONUC;
        DBMS_OUTPUT.PUT_LINE (LC1.TABLE_NAME || '  OLUŞTURULDU.');
        EXCEPTION WHEN OTHERS THEN
        L_ERR := SQLERRM;
        DBMS_OUTPUT.PUT_LINE (LC1.TABLE_NAME ||'  HATA ALDI. HATA:  ' || L_ERR);
    END;
  END LOOP ;

END;


EXEC SP_KOLON_EKLEME ('YENI_ALAN','NUMBER(6)')

select * from REGIONS

SELECT TABLE_NAME, 'ALTER TABLE  '||TABLE_NAME ||'  MODIFY COLUMN ' || COLUMN_NAME    SONUC
FROM  USER_TAB_COLUMNS
--WHERE COLUMN_NAME = P_COLUMN_NAME ;

ALTER TABLE  REGIONS MODIFY YENI_ALAN NUMBER(5)

--select * from ALL_DB_LINKS
--
--SELECT DB_LINK FROM V$DBLINK;
--
--ALTER SESSION CLOSE DATABASE LINK _DBLİNK_

------------------------------------------------
--TABLO/KOLON ISMININ PARAMETRIK OLMASI ÖRNEĞI  -- END
------------------------------------------------


------------------------------------------------
--PERFORMANS KONUSU - ÖRNEK
------------------------------------------------

create or replace function get_department_name(prm_dept_id departments.department_id%type)
return varchar2 is
  lFunctionResult varchar2(50);
begin
  select department_name into lFunctionResult 
  from departments
  where department_id = prm_dept_id;
  
  return(lFunctionResult);
end get_department_name;


SELECT D.*, GET_DEPARTMENT_NAME(DEPARTMENT_ID) FROM DEPARTMENTS D

-- 1 - AZ PERFORMANSLI
  SELECT GET_DEPARTMENT_NAME(DEPARTMENT_ID) DEPARTMAN, COUNT(*)  CALISAN_SAYISI
    FROM EMPLOYEES
GROUP BY GET_DEPARTMENT_NAME(DEPARTMENT_ID)

-- 2 - DAHA PERFORMANSLI. ÖNCE GRUPLANIP SONRA FONKSİYON ÇAĞIRILMALI. DAHA AZ KAYITA GİDİLMELİ.
SELECT GET_DEPARTMENT_NAME(DEPARTMENT_ID), SAYI 
FROM (
        select DEPARTMENT_ID,  count(*)  SAYI
        from EMPLOYEES
        group by  DEPARTMENT_ID
     )

-- 3 - DAHA PERFORMANSLI. 12 DEFA ÇAĞIRILMIŞ OLDU.
  SELECT GET_DEPARTMENT_NAME(DEPARTMENT_ID) DEPARTMAN, COUNT(*)  CALISAN_SAYISI
    FROM EMPLOYEES
GROUP BY DEPARTMENT_ID

-- 4 - PERFORMANSLI. 12 DEFA ÇAĞIRILMIŞ OLDU.
  SELECT  (SELECT DEPARTMENT_NAME  FROM DEPARTMENTS D     WHERE E.DEPARTMENT_ID= D.DEPARTMENT_ID) DEPARTMAN, 
          COUNT(*)  CALISAN_SAYISI
    FROM EMPLOYEES E
    GROUP BY  DEPARTMENT_ID
    
    
-- BULK COLLECT KULLANMAK PERFORMASLIDIR. 
-- DB'YE ERİŞİMİ TOPLULAŞTIRIR. 
-- SQL ENGİNE VE DB ENGİNE ARASIDAKİ İLETİŞİMİ MİNİMUMDA TUTMAK GEREK.
