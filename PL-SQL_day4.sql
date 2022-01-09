----------------------------
--GRUP HALÝNDE GÜNCELLEME  :  LISTAGG
----------------------------
SELECT DEPARTMENT_ID, LISTAGG(EMPLOYEE_ID,',') WITHIN GROUP (ORDER BY LAST_NAME) EMPLOYEE_LIST
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID;
----------------------------

CREATE OR REPLACE PROCEDURE SP_UCRET_ARTISI ( PRM_STR VARCHAR2 ) IS
BEGIN 
                                               
    UPDATE EMPLOYEES 
       SET SALARY = SALARY + 200
     WHERE EMPLOYEE_ID IN ( select EMPLOYEE_ID from EMPLOYEES WHERE EMPLOYEE_ID IN (select regexp_substr(PRM_STR,'[^,]+', 1, level) 
                                               from dual 
                                               connect BY regexp_substr(PRM_STR, '[^,]+', 1, level) 
                                               is not null) ) ;

COMMIT;
  
END;


DECLARE 
L_PRM VARCHAR2 (300) := '116,119,118,115,114,117';

BEGIN 
  SP_UCRET_ARTISI (L_PRM);  
END;

select * from EMPLOYEES  WHERE EMPLOYEE_ID IN (116,119,118,115,114,117)

-------------------------------
--GRUP HALÝNDE GÜNCELLEME RUN:
-------------------------------
DECLARE 
    CURSOR C1 IS
    SELECT DEPARTMENT_ID, LISTAGG(EMPLOYEE_ID,',') WITHIN GROUP (ORDER BY LAST_NAME) EMPLOYEE_LIST
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID;

BEGIN 
     FOR LC1 IN C1 LOOP 
      SP_UCRET_ARTISI (LC1.EMPLOYEE_LIST);  
     END LOOP;
END;

----------------------------
-- STRING LÝSTE DÖNÜÞÜMÜ
----------------------------
select regexp_substr('116,119,118,115,114,117','[^,]+', 1, level) 
   from dual 
   connect BY regexp_substr('116,119,118,115,114,117', '[^,]+', 1, level) 
   is not null;
  
--DÝNAMÝK SQL KULLLANIMI (execute ýmmedýate)

--------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_CREATE_TABLE IS
BEGIN
   --PLSQL ÝÇÝNDE DDL ÇALIÞTIRAMAYIZ, DML ÇALIÞTIRABÝLÝRÝZ.
   EXECUTE IMMEDIATE 'CREATE TABLE B ( B NUMBER )';
END;

BEGIN SP_CREATE_TABLE; END;

CREATE TABLE NKARABIYIK.A ( B NUMBER )

select * from B

--------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_TRUNCATE_TABLE (P_TABLE_NAME VARCHAR2) IS
BEGIN
EXECUTE IMMEDIATE ' truncate table '||P_TABLE_NAME ;
END;


BEGIN 
SP_TRUNCATE_TABLE ('a');
END;

select * from a

insert into a values (1)

commit;

--------------------------------------------------------
--BIND DEÐIÞKEN KULLANIMI. BIND DML LERDE KULLANILABÝLÝR. DDL DE KULLANILMAZ.
----------------------------
CREATE OR REPLACE PROCEDURE SP_INSERT_TABLE2 (P_DEGER VARCHAR2) IS
BEGIN
EXECUTE IMMEDIATE ' INSERT INTO A VALUES (:PARAMETRE) ' USING IN P_DEGER ;
END;

BEGIN SP_INSERT_TABLE2(50); END;

----------------------------
--BIND ÖRNEK
----------------------------
DECLARE  
   P_RC   VARCHAR2(100);  
BEGIN  
   EXECUTE IMMEDIATE  
      'begin SP_SALARY_ADD (:P_EMPLOYEE_ID, :P_ZAM, :P_RC ); end;'  
      USING IN 1,  
            IN 50,  
            OUT P_RC;  
  
   DBMS_OUTPUT.put_line (P_RC);  
   ROLLBACK;  
END;

PROCEDURE NKARABIYIK.SP_SALARY_ADD (P_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE,
                                    P_ZAM       NUMBER,
                                    P_RC   OUT  VARCHAR2)  
                                            
select * from EMPLOYEES WHERE EMPLOYEE_ID =100;

CREATE OR REPLACE PROCEDURE NKARABIYIK.SP_SALARY_ADD (P_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE,
                                            P_ZAM NUMBER,
                                            P_RC OUT VARCHAR2) IS 

V_SALARY  EMPLOYEES.SALARY%TYPE;
L_MAX_SALARY EMPLOYEES.SALARY%TYPE;
L_MIN_SALARY EMPLOYEES.SALARY%TYPE;

L_JOB_ID JOBS.JOB_ID%TYPE;

EX_LIMIT_KONTROL EXCEPTION;

BEGIN

    UPDATE EMPLOYEES
       SET SALARY = SALARY + P_ZAM
     WHERE EMPLOYEE_ID = P_EMPLOYEE_ID
    RETURNING JOB_ID, SALARY INTO L_JOB_ID, V_SALARY;

    SELECT MIN_SALARY, MAX_SALARY  INTO L_MIN_SALARY, L_MAX_SALARY 
    FROM JOBS 
    WHERE JOB_ID = L_JOB_ID;


    IF V_SALARY > L_MAX_SALARY    OR  V_SALARY < L_MIN_SALARY THEN 
       RAISE EX_LIMIT_KONTROL;
    END IF;

P_RC:='BAÞARILI ÝÞLEM';
COMMIT;
EXCEPTION WHEN NO_DATA_FOUND THEN  P_RC:='KAYIT BULUNAMADI';
          WHEN EX_LIMIT_KONTROL THEN  
ROLLBACK;
P_RC:='MAAÞ ARALIK DEÐERLERÝ DIÞINDADIR.';

END;
/
---------------------------------------------------------------------------
-- UTL FILE KONUSU
---------------------------------------------------------------------------

select * from all_directories
--USER_DIR2
--/home/oramkk/userdir2


-- dosyadan okuma
DECLARE 
      V1 VARCHAR2(300); 
      F1 UTL_FILE.FILE_TYPE; 
--      CURSOR C1 IS SELECT * FROM EMPLOYEES;
    BEGIN 
       F1 := UTL_FILE.FOPEN('USER_DIR2','abc.txt','r'); 
       LOOP
       BEGIN
         UTL_FILE.GET_LINE(F1,V1); 
         DBMS_OUTPUT.PUT_LINE(V1);
       EXCEPTION WHEN NO_DATA_FOUND THEN
         EXIT;
       END;
       END LOOP;
       
      UTL_FILE.FCLOSE(F1); 

    END;



-- dosya oluþturma / yazma 
DECLARE 
      V1 VARCHAR2(300); 
      F1 UTL_FILE.FILE_TYPE; 
      CURSOR C1 IS SELECT lpad (EMPLOYEE_ID, 10,0) ||' '|| rpad (FIRST_NAME,15)||' '|| rpad (LAST_NAME,15)||' '|| rpad (EMAIL,30)||' '|| rpad (PHONE_NUMBER,15)||' '|| to_char(HIRE_DATE,'dd/mm/yyyy')||' '|| rpad (JOB_ID,10) ||' '|| 
                lpad (SALARY,10,0)||' '|| lpad (COMMISSION_PCT,10,0)||' '||lpad ( MANAGER_ID,10)||' '|| lpad (DEPARTMENT_ID,5) SATIR
                FROM EMPLOYEES;

    BEGIN 
       F1 := UTL_FILE.FOPEN('USER_DIR2','abc2.txt','w'); --write mod
     
     for lc1 in c1  LOOP
       BEGIN
       
         UTL_FILE.PUT_LINE(F1,LC1.SATIR); 

       END;
       END LOOP;
       
      UTL_FILE.FCLOSE(F1); 

    END;

-----------------------------------------------------------------------------
--ÖRNEK

abone_id (10 basamak)
abone_no (10 basamak)
abone_adi  (geri kalan)

truncate table  abone;
truncate table HATA_DURUMLARI;
TRUNCATE TABLE ISLENEN_DOSYA;


ALTER TABLE ABONE MODIFY ID NOT NULL;
ALTER TABLE ABONE ADD CONSTRAINT PK_ABONE PRIMARY KEY(ID);

select * from abone;
select * from HATA_DURUMLARI;
select * from ISLENEN_DOSYA;

DELETE FROM abone WHERE ID <> 846;

CREATE TABLE ISLENEN_DOSYA (DOSYA_ADI VARCHAR2(30), ISLENEN_KAYIT_SAYISI NUMBER (5) );


EXEC SP_DOSYA_OKUMA;

CREATE OR REPLACE PROCEDURE SP_DOSYA_OKUMA IS
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
                INSERT INTO HATA_DURUMLARI VALUES (V1 || '  ' || L_ERR);
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
    
    
    
    
    
--------------------------------------------------------    
--    FORALL ÖRNEÐI
---------------------------
DECLARE
TYPE NumList IS VARRAY(20) OF NUMBER; 
depts NumList := NumList(10, 30, 70); -- department numbers
BEGIN
  FORALL i IN depts.FIRST..depts.LAST
  DELETE FROM employees_temp
  WHERE department_id = depts(i);
END;
----------------------------

create table employees_temp as 
select * from employees

select * from employees_temp WHERE DEPARTMENT_ID IN (10,30,70)

EXEC SP_EMLPYEE_TEMP_DELETE('10,30,70');

CREATE OR REPLACE PROCEDURE SP_EMLPYEE_TEMP_DELETE(P_STR VARCHAR2) IS 
 
 TYPE NUMLIST IS VARRAY (10) OF NUMBER;
L_EMP  NUMLIST := NUMLIST ();

  CURSOR C1 IS
  -- STRING LÝSTE DÖNÜÞÜMÜ
  SELECT REGEXP_SUBSTR(P_STR,'[^,]+', 1, LEVEL) SONUC
   FROM DUAL 
   CONNECT BY REGEXP_SUBSTR(P_STR, '[^,]+', 1, LEVEL) 
   IS NOT NULL;

 BEGIN
   
 FOR LC1 IN C1 LOOP
DBMS_OUTPUT.PUT_LINE (C1%ROWCOUNT ||' ' || LC1.SONUC );
   L_EMP.EXTEND ;
   L_EMP(C1%ROWCOUNT) :=  LC1.SONUC;
END LOOP;

  FORALL i IN L_EMP.FIRST..L_EMP.LAST
  DELETE FROM employees_temp
  WHERE department_id = L_EMP(i); 
 
  COMMIT;
END;
---------------------------------------------------------------------------
--TABLE OF ÖRENÐÝ
-------------------------
declare
type numList is table of number index by pls_integer;
lempList numList;
begin
  select employee_id bulk collect into lempList from employees;

  for i in 1..lempList.count loop
    dbms_output.put_line(lempList(i));
  end loop;
end;
-------------------------

EXEC SP_EMLPYEE_TEMP_DELETE2('189,190,191');
select * from employees_temp WHERE EMPLOYEE_ID IN (189,190,191)

CREATE OR REPLACE PROCEDURE SP_EMLPYEE_TEMP_DELETE2 (P_STR VARCHAR2) IS 
 TYPE    NUMLIST IS TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
L_EMP   NUMLIST ;
BEGIN
   
   -- STRING LÝSTE DÖNÜÞÜMÜ
  SELECT REGEXP_SUBSTR(P_STR,'[^,]+', 1, LEVEL)  bulk collect into  L_EMP
   FROM DUAL 
   CONNECT BY REGEXP_SUBSTR(P_STR, '[^,]+', 1, LEVEL) 
   IS NOT NULL;
  
  DBMS_OUTPUT.PUT_LINE (L_EMP.FIRST ||' '||L_EMP.LAST)  ;
  FORALL i IN L_EMP.FIRST..L_EMP.LAST
  DELETE FROM employees_temp
  WHERE EMPLOYEE_ID = L_EMP(i); 
 
  DBMS_OUTPUT.PUT_LINE ('SON');
  COMMIT;
END;

--------------------------------------------------
-----------PERFORMANS ÖRNEKLERÝ:
--------------------------------------------------

--ABONE TABLOSUNA 100.00 KAYIT INSERT EDECEÐÝZ
-- 1. ARRAY ÝLE, TEKER TEKER
-- 2. ARRAY ÝLE, FOR ALL ÝLE TOPLUCA

--------------1-------------------
CREATE OR REPLACE PROCEDURE SP_ABONE_BULK_1  IS
TYPE IDTAB       IS TABLE OF ABONE.ID%TYPE        INDEX BY PLS_INTEGER;
TYPE ABONENOTAB  IS TABLE OF ABONE.ABONE_NO%TYPE  INDEX BY PLS_INTEGER;
TYPE ABONEADITAB IS TABLE OF ABONE.ABONE_ADI%TYPE INDEX BY PLS_INTEGER;

 TYPE ABONE_TAB IS RECORD (ID ABONE.ID%TYPE, ABONE_NO ABONE.ABONE_NO%TYPE, ABONE_ADI ABONE.ABONE_ADI%TYPE);-- RECORD TANIMI. ROWTYPE GÝBÝ.
TYPE ABONE_LIST IS TABLE OF ABONE_TAB INDEX BY PLS_INTEGER; --ABONE_TAB'LARINDAN OLUÞAN BIR ARRAY.

 idlist idtab;
abonenolist abonenotab;
aboneadilist aboneaditab;

 L_ABONE_LIST ABONE_LIST; --DEÐÝÞKEN TANIMLADIK

 L_START TIMESTAMP;
L_END   TIMESTAMP;

BEGIN


FOR I IN 1..100000 LOOP
  L_ABONE_LIST(I).ID := I;
  L_ABONE_LIST(I).ABONE_NO := '1-'||LPAD(I,6,0);
  L_ABONE_LIST(I).ABONE_ADI := 'ABONE_ADI-'||LPAD(I,6,0);  
END LOOP;

L_START := SYSTIMESTAMP;

FOR I IN 1..100000 LOOP

    INSERT INTO ABONE (ID, ABONE_NO, ABONE_ADI) VALUES ( L_ABONE_LIST(I).ID,L_ABONE_LIST(I).ABONE_NO, L_ABONE_LIST(I).ABONE_ADI );
     
END LOOP;
COMMIT;

L_END   := SYSTIMESTAMP;
DBMS_OUTPUT.PUT_LINE ('START:' || L_START || ' END :'  || L_END );
DBMS_OUTPUT.PUT_LINE (L_END-L_START);
END;

EXEC SP_ABONE_BULK_1

TRUNCATE TABLE ABONE

--------------------2----------------------
CREATE OR REPLACE PROCEDURE SP_ABONE_BULK_2  IS
TYPE IDTAB       IS TABLE OF ABONE.ID%TYPE        INDEX BY PLS_INTEGER;--TIP
TYPE ABONENOTAB  IS TABLE OF ABONE.ABONE_NO%TYPE  INDEX BY PLS_INTEGER;--TIP
TYPE ABONEADITAB IS TABLE OF ABONE.ABONE_ADI%TYPE INDEX BY PLS_INTEGER;--TIP
idlist idtab; --ARRAY
abonenolist abonenotab;--ARRAY
aboneadilist aboneaditab;--ARRAY

-- TYPE ABONE_TAB_2 IS ABONE%ROWTYPE; -- ALTERNATÝF

 TYPE ABONE_TAB  IS RECORD (ID        ABONE.ID%TYPE, 
                            ABONE_NO  ABONE.ABONE_NO%TYPE, 
                            ABONE_ADI ABONE.ABONE_ADI%TYPE); --RECORD TANIMI. ROWTYPE GÝBÝ.
TYPE ABONE_LIST IS TABLE OF ABONE_TAB INDEX BY PLS_INTEGER; --ABONE_TAB'LARINDAN OLUÞAN BIR ARRAY.
L_ABONE_LIST ABONE_LIST;                                    --DEÐÝÞKEN TANIMLADIK

 L_START TIMESTAMP;
L_END   TIMESTAMP;

BEGIN


FOR I IN 1..100000 LOOP
  L_ABONE_LIST(I).ID := I;
  L_ABONE_LIST(I).ABONE_NO := '1-'||LPAD(I,6,0);
  L_ABONE_LIST(I).ABONE_ADI := 'ABONE_ADI-'||LPAD(I,6,0);  
END LOOP;

L_START := SYSTIMESTAMP;

FORALL I IN 1..100000 
    INSERT INTO ABONE (ID, ABONE_NO, ABONE_ADI) VALUES ( L_ABONE_LIST(I).ID,L_ABONE_LIST(I).ABONE_NO, L_ABONE_LIST(I).ABONE_ADI );
COMMIT;

L_END   := SYSTIMESTAMP;
DBMS_OUTPUT.PUT_LINE ('START:' || L_START || ' END :'  || L_END );
DBMS_OUTPUT.PUT_LINE (L_END-L_START);
END;

EXEC SP_ABONE_BULK_2

TRUNCATE TABLE ABONE

-----------------------------------------
--INVALID OBJELERI VALIDE ETME
------------------------------------
select * from USER_OBJECTS WHERE STATUS <>'VALID'

ALTER PROCEDURE SP_FATURA COMPILE

ALTER PROCEDURE SP_GET_DEPT_INFO COMPILE 


EXEC DBMS_UTILITY.COMPILE_SCHEMA('NKARABIYIK');

------------------------------------
--JOB QUEUE PROCESS PARAMETRESÝ VAR

select * from V$PARAMETER -- TABLOSUNDAN PARAMTRE BÝLGÝSÝ GÖRÜNTÜLENEBÝLÝR.


--JOB TANIMLAMA
DECLARE
    l_job NUMBER ;
BEGIN    DBMS_JOB.SUBMIT(l_job,'begin null; end;',sysdate,'sysdate+1/1440');  
END;


------------------------------------
--GLOBAL TEMP TABLE
------------------------

create global temporary table abone_temp_session
( id number, 
abone_no varchar2(10), 
abone_adi varchar2(40))
ON COMMIT PRESERVE ROWS;


--------------1-------------------
CREATE OR REPLACE PROCEDURE SP_ABONE_BULK_11  IS
TYPE IDTAB       IS TABLE OF ABONE.ID%TYPE        INDEX BY PLS_INTEGER;
TYPE ABONENOTAB  IS TABLE OF ABONE.ABONE_NO%TYPE  INDEX BY PLS_INTEGER;
TYPE ABONEADITAB IS TABLE OF ABONE.ABONE_ADI%TYPE INDEX BY PLS_INTEGER;

 TYPE ABONE_TAB IS RECORD (ID ABONE.ID%TYPE, ABONE_NO ABONE.ABONE_NO%TYPE, ABONE_ADI ABONE.ABONE_ADI%TYPE);-- RECORD TANIMI. ROWTYPE GÝBÝ.
TYPE ABONE_LIST IS TABLE OF ABONE_TAB INDEX BY PLS_INTEGER; --ABONE_TAB'LARINDAN OLUÞAN BIR ARRAY.

 idlist idtab;
abonenolist abonenotab;
aboneadilist aboneaditab;

 L_ABONE_LIST ABONE_LIST; --DEÐÝÞKEN TANIMLADIK

 L_START TIMESTAMP;
L_END   TIMESTAMP;

BEGIN


FOR I IN 1..100000 LOOP
  L_ABONE_LIST(I).ID := I;
  L_ABONE_LIST(I).ABONE_NO := '1-'||LPAD(I,6,0);
  L_ABONE_LIST(I).ABONE_ADI := 'ABONE_ADI-'||LPAD(I,6,0);  
END LOOP;

L_START := SYSTIMESTAMP;

FOR I IN 1..100000 LOOP

    INSERT INTO ABONE_TEMP_SESSION (ID, ABONE_NO, ABONE_ADI) VALUES ( L_ABONE_LIST(I).ID,L_ABONE_LIST(I).ABONE_NO, L_ABONE_LIST(I).ABONE_ADI );
     
END LOOP;
COMMIT;

L_END   := SYSTIMESTAMP;
DBMS_OUTPUT.PUT_LINE ('START:' || L_START || ' END :'  || L_END );
DBMS_OUTPUT.PUT_LINE (L_END-L_START);
END;

EXEC SP_ABONE_BULK_11

--------------------2----------------------
CREATE OR REPLACE PROCEDURE SP_ABONE_BULK_22  IS
TYPE IDTAB       IS TABLE OF ABONE.ID%TYPE        INDEX BY PLS_INTEGER;--TIP
TYPE ABONENOTAB  IS TABLE OF ABONE.ABONE_NO%TYPE  INDEX BY PLS_INTEGER;--TIP
TYPE ABONEADITAB IS TABLE OF ABONE.ABONE_ADI%TYPE INDEX BY PLS_INTEGER;--TIP
idlist idtab; --ARRAY
abonenolist abonenotab;--ARRAY
aboneadilist aboneaditab;--ARRAY

-- TYPE ABONE_TAB_2 IS ABONE%ROWTYPE; -- ALTERNATÝF

 TYPE ABONE_TAB  IS RECORD (ID        ABONE.ID%TYPE, 
                            ABONE_NO  ABONE.ABONE_NO%TYPE, 
                            ABONE_ADI ABONE.ABONE_ADI%TYPE); --RECORD TANIMI. ROWTYPE GÝBÝ.
TYPE ABONE_LIST IS TABLE OF ABONE_TAB INDEX BY PLS_INTEGER; --ABONE_TAB'LARINDAN OLUÞAN BIR ARRAY.
L_ABONE_LIST ABONE_LIST;                                    --DEÐÝÞKEN TANIMLADIK

 L_START TIMESTAMP;
L_END   TIMESTAMP;

BEGIN


FOR I IN 1..100000 LOOP
  L_ABONE_LIST(I).ID := I;
  L_ABONE_LIST(I).ABONE_NO := '1-'||LPAD(I,6,0);
  L_ABONE_LIST(I).ABONE_ADI := 'ABONE_ADI-'||LPAD(I,6,0);  
END LOOP;

L_START := SYSTIMESTAMP;

FORALL I IN 1..100000 
    INSERT INTO ABONE_TEMP_SESSION (ID, ABONE_NO, ABONE_ADI) VALUES ( L_ABONE_LIST(I).ID,L_ABONE_LIST(I).ABONE_NO, L_ABONE_LIST(I).ABONE_ADI );
COMMIT;

L_END   := SYSTIMESTAMP;
DBMS_OUTPUT.PUT_LINE ('START:' || L_START || ' END :'  || L_END );
DBMS_OUTPUT.PUT_LINE (L_END-L_START);
END;

EXEC SP_ABONE_BULK_22



------------------------------------------
-- DB DE NULL VERÝLERÝN KULLANIMI

select * from EMPLOYEES  WHERE COMMISSION_PCT = NULL -- DEÐER GELMEZ ÇÜNKÜ NULL != NULL

select * from EMPLOYEES  WHERE COMMISSION_PCT IS NULL

-- JOINLERDE NULL'LARA DÝKKAT ETMEK GEREK. NULL ALANLAR JOINDE GELMEZ.
-- NULLARI JOINLEMEK : NVL() ÝLE NULLADAN KURTARIP JOINLEMEK GEREK.

select * from EMPLOYEES E, DEPARTMENTS D
WHERE NVL(E.DEPARTMENT_ID,0) = NVL(D.DEPARTMENT_ID,0) 

--NOT: NVL2(x,y,z) fonksiyonu x'in degeri NULL ise z'yi,NULL degilse y'yi verir.
