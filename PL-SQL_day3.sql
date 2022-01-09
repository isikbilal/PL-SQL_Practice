--PACKAGE
--Paketler: Bir�ok fonksiyon, procedure, sabiler, de�i�kenler, type'lar gibi bir�ok �eyi birarada tutabilece�imiz veritaban� objeleridir.
--��lerin �ok karma��kla�arak y�netilemez hale gelmesini engellemek i�in kullan�l�r.
--Bazen olu�turdu�umuz prosed�rlerin i�eri�ini ba�kalar�na g�stermek istemeyebiliriz. Sacede prosed�r�n kullan�m�na y�nelik k�s�mlar� d�� kullan�c�lara g�stermek isteyebiliriz.
--Bu y�zden package'larda Spec ve Body diye 2 k�s�m vard�r. Birisine paketin sadece kullan�m� yetkisini vermek istersek sadece spec k�sm�na execute yetkisi vermemiz yeterli olur.
--�stersek paketin i�eri�ini gizleyebiliriz. WRAP fonksiyonu ile �ifreleyip i�eri�i gizli �ekilde kullan�ma sunabiliriz. Bu �ekilde kar�� taraf�n package i�eri�ini g�rme ve de�i�tirme �ans� olmaz.

--Package �rne�i:

/********************************************************************************/  --->>> SPEC KISMI

CREATE OR REPLACE PACKAGE PCK_HR IS -- Buras� Spec k�sm�. Bu k�sma yazd�klar�m�z d��ar�ya a��kt�r. Yani bu package �zerinde yetkisi olan ki�iler buradaki spec k�sm�n� g�r�r ve oradakileri bilgileri referans alarak kendi uygulamalar�nda kullanabilirler.

PROCEDURE add_job_history -- Burada Spec k�sm�nda tan�mlamasayd�k a�a��da �a��ramayacakt�k.
  (  p_emp_id          job_history.employee_id%type
   , p_start_date      job_history.start_date%type
   , p_end_date        job_history.end_date%type
   , p_job_id          job_history.job_id%type
   , p_department_id   job_history.department_id%type
   );


PROCEDURE DEPARTMENT_INSERT2(
      PRM_DEPT DEPARTMENTS%ROWTYPE,
      PRM_RC OUT VARCHAR2
      );
      


FUNCTION GET_DEPT_SALARY(PRM_DEPT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE) -- Prosed�r tan�mlad���m�z gibi fonksiyon da tan�mlayabiliriz.
        RETURN EMPLOYEES.SALARY%TYPE;
      
      
END PCK_HR;





/********************************************************************************/  --->>> BODY KISMI   

CREATE OR REPLACE PACKAGE BODY PCK_HR IS -- Buras� da Body k�sm�. E�er biz bir fonksiyonun tan�m�n� Body k�sm�nda yaparsak bu internal bir fonksiyon olur. Yani sadece PCK_HR paketinin i�erisinden eri�ilebilir. Ne zaman ki biz bu fonksiyonun tan�m�n� Spec k�sm�na koyar�z, i�te o zaman d��ar�dan eri�ilebilir hale gelir.

    PROCEDURE add_job_history
      (  p_emp_id          job_history.employee_id%type
       , p_start_date      job_history.start_date%type
       , p_end_date        job_history.end_date%type
       , p_job_id          job_history.job_id%type
       , p_department_id   job_history.department_id%type
       )
    IS
    BEGIN
      INSERT INTO job_history (employee_id, start_date, end_date,
                               job_id, department_id)
        VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);

    END add_job_history;
    
 
    PROCEDURE DEPARTMENT_INSERT2(
      PRM_DEPT DEPARTMENTS%ROWTYPE,
      PRM_RC OUT VARCHAR2
      ) IS

    ZORUNLU_ALAN_HATASI EXCEPTION;
    PRAGMA EXCEPTION_INIT(ZORUNLU_ALAN_HATASI, -02290); -- Oracle'�n 1400 numaral� hatas�n� ZORUNLU_ALAN_HATASI olarak tan�mlad�k burada. Yani Oracle'�n kendisinin isimlendirmedi�i bir hatay� biz kendimiz bu �ekilde adland�rabiliyoruz


    BEGIN
      INSERT INTO DEPARTMENTS VALUES PRM_DEPT;
      PRM_RC := 'Islem basarili';
      COMMIT;
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        PRM_RC := 'Mukerrer bolum numarasi';
    WHEN ZORUNLU_ALAN_HATASI THEN --Burada da yukar�da tan�mlad���m�z hatay� kullan�yoruz. Olu�turdu�umuz Exception sadece i�inde bulundu�u Begin-End blo�unu kapsar. Mesela bir procedure i�inde 1/0 ifadesi koyduk. Fakat exception when zero_divide hatas�n� ba�ka bir Begin-End blo�u aras�nda tan�mlarsak o hatay� g�rmeyecektir. O y�zden hatan�n gelmesini nerede bekliyorsak hata y�netimini de ayn� Begin-End blo�unda yapmam�z laz�m. Daha detayl� bilgi i�in -- https://www.oracletutorial.com/plsql-tutorial/plsql-exception-propagation/ linkindeki �rnekleri inceleyebilirsin.

        PRM_RC := 'Zorunlu alanlari doldurunuz'||SQLERRM;      
    WHEN OTHERS THEN -- Akl�m�za gelen t�m hatalar� yakalad�ktan sonra di�er beklenmeyen hatalar i�in WHEN OTHERS kullan�r�z. WHEN OTHERS herzaman Exception'lar�n en alt�nda olur.
        PRM_RC := 'Beklenmeyen DB Hatasi'||SQLERRM;  
    END;


    FUNCTION GET_DEPT_SALARY(PRM_DEPT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE) -- Prosed�r tan�mlad���m�z gibi fonksiyon da tan�mlayabiliriz.
        RETURN EMPLOYEES.SALARY%TYPE IS

    L_TOTAL_SALARY EMPLOYEES.SALARY%TYPE;
    BEGIN
        SELECT SUM(SALARY) INTO L_TOTAL_SALARY -- SUM(SALARY) ifadesinden gelen de�eri bir de�i�kende tutmam�z laz�m. O y�zden INTO L_TOTAL_SALARY ifadesini koyduk. Bu ifade olmasayd� hata verirdi.
        FROM EMPLOYEES
        WHERE DEPARTMENT_ID = PRM_DEPT_ID;
        RETURN(L_TOTAL_SALARY); -- Fonksiyonlar mutlaka return de�eri d�nd�rmek zorundad�r. Return olmazsa hata verir.
    END;




END PCK_HR;



/********************************************************************************/  --->>> �ALI�TIRMA KISMI

BEGIN
    PCK_HR.ADD_JOB_HISTORY; -- Package i�erisindekilerin kullan�m� bu �ekilde. Parametrelerini verirsek �al��acakt�r. Parametreleri de DECLARE k�sm� olu�turup orda tan�mlamam�z laz�m tabiki.
END;

BEGIN
    PCK_HR.DEPARTMENT_INSERT2; -- Package i�erisindekilerin kullan�m� bu �ekilde. Parametrelerini verirsek �al��acakt�r. Parametreleri de DECLARE k�sm� olu�turup orda tan�mlamam�z laz�m tabiki.
END;











--�RNEK 2: PCK_EGITIM PAKET� ALTINDA BAZI OBJELER� TOPLAYALIM:

CREATE OR REPLACE PACKAGE PCK_EGITIM is
/********************************************************************************/  --->>>SPEC KISMI
  PROCEDURE SP_LOCATIONS_INSERT (
                                                P_STREET_ADDRESS LOCATIONS.STREET_ADDRESS%TYPE, 
                                                p_POSTAL_CODE LOCATIONS.POSTAL_CODE%TYPE, 
                                                P_CITY LOCATIONS.CITY%TYPE, 
                                                P_STATE_PROVINCE LOCATIONS.STATE_PROVINCE%TYPE, 
                                                P_COUNTRY_NAME COUNTRIES.COUNTRY_NAME%TYPE,
                                                P_LOCATION_ID OUT LOCATIONS.LOCATION_ID%TYPE,
                                                P_RC OUT VARCHAR2
                                                );
                                                
                                                
 PROCEDURE SP_SALARY_ADD (P_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE,
                                            P_ZAM NUMBER,
                                            P_RC OUT VARCHAR2); 

END;

/********************************************************************************/  --->>>BODY KISMI
CREATE OR REPLACE PACKAGE BODY PCK_EGITIM is

 PROCEDURE SP_LOCATIONS_INSERT (
                                                P_STREET_ADDRESS LOCATIONS.STREET_ADDRESS%TYPE, 
                                                p_POSTAL_CODE LOCATIONS.POSTAL_CODE%TYPE, 
                                                P_CITY LOCATIONS.CITY%TYPE, 
                                                P_STATE_PROVINCE LOCATIONS.STATE_PROVINCE%TYPE, 
                                                P_COUNTRY_NAME COUNTRIES.COUNTRY_NAME%TYPE,
                                                P_LOCATION_ID OUT LOCATIONS.LOCATION_ID%TYPE,
                                                P_RC OUT VARCHAR2
                                                ) IS 
                                                
V_COUNTRY_ID COUNTRIES.COUNTRY_ID%TYPE;
V_LOCATION_ID NUMBER;
BEGIN


SELECT COUNTRY_ID INTO V_COUNTRY_ID 
  FROM COUNTRIES  
 WHERE COUNTRY_NAME = P_COUNTRY_NAME;

V_LOCATION_ID := LOCATIONS_SEQ.NEXTVAL;


INSERT INTO LOCATIONS VALUES
(V_LOCATION_ID, P_STREET_ADDRESS, P_POSTAL_CODE, P_CITY, P_STATE_PROVINCE, V_COUNTRY_ID);

P_LOCATION_ID := V_LOCATION_ID;
P_RC := '��LEM BA�ARILI.';

EXCEPTION WHEN NO_DATA_FOUND THEN 
P_RC := 'GE�ERS�Z �LKE ADI.';

COMMIT;

END SP_LOCATIONS_INSERT;


/*****************************************************************************************************/
 PROCEDURE SP_SALARY_ADD (P_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE,
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

P_RC:='BA�ARILI ��LEM';
COMMIT;

EXCEPTION WHEN EX_LIMIT_KONTROL THEN  
ROLLBACK;
P_RC:='MAA� ARALIK DE�ERLER� DI�INDADIR.';

END SP_SALARY_ADD;
/*****************************************************************************************************/
/*****************************************************************************************************/
/*****************************************************************************************************/

END ;


--PACKAGE RUN ETME KISMI
DECLARE
    P_RC VARCHAR2 (50);
BEGIN
    PCK_EGITIM.SP_SALARY_ADD (190,100,P_RC);
    DBMS_OUTPUT.PUT_LINE (P_RC);
END; 

SELECT * FROM EMPLOYEES;




-- 3.G�N
/***********************************************************************************************************************************************/
--TRANSACTION Y�NET�M�:
--Commit
--Rollback (to savepoint)
--Savepoint
--Autonomous Transactions

--Db'deki transaction'larda bizim irademiz d���nda bir kesinti olmamal�d�r. ��lem b�t�nl��� korunmal�d�r. Yani transaction'lar atomik (b�l�nemez, yar�da kesilemez) olmal�d�r. 
--E�er b�yle olmazsa �rne�in fatura �denmi�tir ama kimin �dedi�i belli de�ildir. ��nk� o bilginin i�lenmesi s�ras�nda transaction yar�da kesilmi�tir. 
--Bu t�r durumlar� engellememiz gerekir. Bunu engellemek i�in de Commit, Rollback, Savepoint, Autonomous Transactions gibi yap�lar kullan�l�r.

--Commit ve Rollback:
--Bir transaction commit ve rollback g�rene kadar devam ederler. E�er commit yap�lmazsa kullan�c� sadece bulundu�u session'da de�i�iklikleri g�rebilir. Di�er kullan�c�lar g�remez. E�er commit etmeden session kapat�rsa de�i�iklikler kaybolur.
--E�er bir i�in (procedure, function vs.) b�l�nmeden bir b�t�n olarak �al��mas� gerekiyorsa Exception'lar�n alt�na Rollback de koymal�y�z.

--Savepoint:
--E�er transaction'�m�z atomik de�ilse, yani baz� k�s�mlar �nemli, baz� k�s�mlar hata alsa da olur �eklindeyse, o zaman �nemli noktalara savepoint koyarak ilerlememiz gerekir ki e�er transaction kesilirse savepoint'den �ncesini kaybetmeyelim.
--Mesela bir bulk insert i�lemi yap�yoruz. 100 bin tane kay�t insert edece�im. Her 10 bin kay�tta e�er bir hata yoksa savepoint koyar�m ki, bir hata ��kt���nda en ba�tan ba�lamayay�m.
--�rne�in; 100 bin tane fatura �deme i�leminin kaydedilmesi gerekiyor. Bu durumda faturalar� d�zg�n �denenler kaydedilsin, bir sorun olanlar bir tabloya loglans�n, fakat i�lemimiz kesilmeyip devam etsin. Biz en son sorun olanlar� kontrol ederiz gibi bir senaryo tasarlanabilir.
--Mesela 10 milyon kay�t olan bir i�i tek seferde biz tamamlayamay�z. Rollback segment'ler dolar ve normal i� ak���nda olmayan hatalar vermeye ba�lar. "Transaction_to_old" gibi bir hata vermeye ba�lar e�er i�lem �ok uzun s�rerse. Yani rollback segment'leri doldu�u i�in i�lemi otomatikmen keser.
--Bu y�zden bizim belli periyotlarla (�rn: her 1000 kay�tta) bu rollback'leri bo�alt�p, yapt���m�z ba�ar�l� i�lemleri commit'leyip yoluna devam edecek bir yap� kurmam�z gerekir.

--Abona uygulamas� yapabilmemiz i�in gerekli olan tablo ve verilerimiz: Bu tablolar varm� sende kontrol et. Datalar farkl�ysa tablolar� delete edip bu kodlarla tekrar olu�turabilirsin.
create table abone
(
  id                 NUMBER,
  abone_no           VARCHAR2(10),
  abone_adi          varchar2(40),
  son_fatura_tarihi  date
  );


create table fatura_tipi(kod number primary key, aciklama varchar2(30));
insert into fatura_tipi values (0,'Tip 0');
insert into fatura_tipi values (1,'Tip 1');
insert into fatura_tipi values (2,'Tip 2');
insert into fatura_tipi values (3,'Tip 3');
insert into fatura_tipi values (4,'Tip 4');
insert into fatura_tipi values (5,'Tip 5');
insert into fatura_tipi values (6,'Tip 6');
insert into fatura_tipi values (7,'Tip 7');
insert into fatura_tipi values (8,'Tip 8');

create table fatura
(
  abone_id           number,
  fatura_no          varchar2(10),
  fatura_tipi        number(2) references fatura_tipi(kod), --FATURA tablosundaki FATURA_TIPI kolonuna girece�imiz de�erin, mutlaka FATURA_TIPI tablosunun KOD kolonunda bulunan de�erlerden biri olmas� i�in bu �ekilde bir constraint tan�mlad�k.
  tutar              number(10,2)
);

commit;
  
begin
  for i in 1..100000 loop
    insert into abone values (i, 'A'||lpad(i,6,0),'abone-'||i, null);
  end loop;
end ;

select * from abone;

select * from fatura;

select * from fatura_tipi;

--Yapaca��m�z uygulama:
--Uygulama kesintisiz �al��s�n. Yani bir hata oldu�u zaman kesilmesin. 
--Hata al�nan aboneler i�in loglama yap�ls�n.
--Her 1000 kay�tta bir commit edilsin. �ok s�k (�rn: her 10 kay�tta bir) commit edilmesi de iyi de�ildir. Bu durumda da performans yava�lamas� olabilir. O y�zden 1000 kay�t veya 10000 kay�tta bir commit idealdir.

CREATE OR REPLACE PROCEDURE SP_FATURA IS

CURSOR C1 IS select * from ABONE order by ID; -- B�t�n aboneleri i�erisine atmak i�in cursor'�m�z� olu�turduk.

l_ERROR_MESAJ VARCHAR2 (200);

BEGIN

    FOR LC1 IN C1 LOOP -- Her bir abone sat�rda gezinebilmek i�in for i�inde LC1 olu�turduk.
    
    SAVEPOINT GUNVENLINOKTA; -- Buras� bizim g�venli kay�t noktam�z. Her 1000 kay�tta savepoint almak istiyoruz. �lk d�ng�den itibaren kaydetmek istedi�imiz i�in savepoint'i d�ng� ba��nda olu�turduk. Hata al�rsa da  Exception i�inde ROLLBACK TO ile kaydediyoruz
    
    BEGIN --Kay�t ekleme ve Hata y�netimini ayr� bir Begin-End blo�unda yapt�k daha anla��l�r olmas� i�in.
    
        UPDATE ABONE -- 9, 19, 29 vs. nolu abonelere gelince INSERT i�lemi hata alacak ve faturalar� olu�mayacak zaten. Buradaki UPDATE iilemi de a�a��daki ROLLBACK'den dolay� geri al�naca�� i�in SON_FATURA_TARIHI g�ncellenmeyecek. 
           SET SON_FATURA_TARIHI = SYSDATE
           WHERE ID = LC1.ID;
         
        INSERT INTO FATURA VALUES -- FATURA tablosundaki her kolon i�in otomatik de�er �retip onlar� ekliyoruz her seferinde kendimiz girmemek i�in.
            (LC1.ID, 'F'||LPAD(LC1.ID,6,0), MOD (LC1.ID,10), MOD(LC1.ID,5)*2 ); --FATURA_TIPI kolonuna girilecek de�eri MOD (LC1.ID,10) �eklinde yapt�k. Bu da 0'dan 9'a kadar olan de�erleri alacak demek oluyor. Fakat FATURA_TIPI tablomuzda 0'dan 8'e kadar tip bulundu�u i�in her 10 kay�tta bir tip9 i�in hata verecek. fatura no ve tutar alanlar�n� da id alan�na ba�l� olarak �rettik.
        EXCEPTION WHEN OTHERS THEN 
          l_ERROR_MESAJ :=  SQLERRM; --ROLLBACK �al��madan �nce INSERT ifadesinden gelecek hatay� burada l_ERROR_MESAJ adl� bir de�i�kene kaydediyoruzki ROLLBACK �al��t�ktan sonra bu hatay� ezmesin. E�er bunu yapmazsak en son ROLLBACK ifadesi �al��aca�� i�in SQLERRM i�erisinde o kalacak ve INSERT'den gelen hatay� yakalayamam�� olaca��z.
          ROLLBACK TO GUNVENLINOKTA; -- Buradaki Savepoint'e gitme i�lemi baz� programlama dillerindeki "go to x. line" gibi bir�ey de�il. Yani "hata olursa �u sat�ra git" tarz�nda bir�ey s�ylemiyoruz burada. Sadece ROLLBACK TO GUNVENLINOKTA ifadesini g�rd���nde en son Savepoint noktas�ndan itibaren yap�lan de�i�iklikleri iptal et diyoruz. 
        INSERT INTO HATA_DURUMLARI VALUES (LC1.ID || ' KULLANICI ���N FATURA �RET�LEMED�. - ' || l_ERROR_MESAJ); --Rollback i�leminden sonra program�m�z normal i�leyi�ine devam ediyor. Al�nan hatay� ilgili tablomuza bas�yoruz.
        --Bu sat�rda COMMIT yazmam�za gerek yok. ��nk� IF MOD ifadesinin i�indeki COMMIT ile hepsini commitleyecek zaten.
    END; 
    
    IF MOD ( C1%ROWCOUNT, 1000 ) = 0  THEN --Her 1000 kay�t eklendi�inde commit yap�lan k�s�m.
      COMMIT ; --Her 1000, 2000, 3000 vs. kay�tta commit edecek sadece.
    END IF;
         
    END LOOP;

COMMIT; -- Farzedelim ki 100 bin de�il de 99800 tane kayd�m�z var toplam. Bu durumda yukar�daki commit en son 99000. kay�tta �al��t�. Yani hen�z commit edilmemi� 800 tane daha kayd�m�z var. Bu y�zden son 800 kayd�n da update edilmesi i�in commit eklendi.

END;

select * from abone;

select * from fatura;

select * from fatura_tipi;

SELECT * FROM HATA_DURUMLARI;

SELECT ABONE_ID FROM FATURA;

SELECT * FROM ABONE 
WHERE SON_FATURA_TARIHI IS NOT NULL 
AND ID NOT IN (SELECT ABONE_ID FROM FATURA); -- Bu sorgu SON_FATURA_TARIHI g�ncellenmi�, fakat faturas� olu�mam�� abone varm� diye kontrol ediyor. Yani yar�m kalm�� transaction olup olmad���na bak�yoruz. Sorgu sonucu bo� geliyorsa yar�n kalm�� transaction yok demektir.

SELECT * FROM ABONE 
WHERE SON_FATURA_TARIHI IS NULL 
AND ID IN (SELECT ABONE_ID FROM FATURA); -- Bu da yukar�daki sorgunun tam tersi. Yani faturas� olu�mu�, fakat SON_FATURA_TARIHI g�ncellenmemi� aboneleri kontrol ediyor san�r�m? Bu sorgunun da sonucunun bo� gelmesi laz�m normal �artlarda.
--�ki sorgu da bo� geliyorsa sorun yok demektir. Yani ABONE tablosunda SON_FATURA_TARIHI g�ncellenmi�se faturas� var. E�er SON_FATURA_TARIHI bo� ise faturas� yok demektir. Bekledi�imiz durum bu �ekilde.

select * from abone ORDER BY ID; --Her 9, 19, 29 vs. ID'nin Son fatura tarihi bo�.

select * from fatura ORDER BY ABONE_ID; -- --Her 9, 19, 29 vs. ABONE_ID yok. Yani faturas� yok.

--�stersek Debug ederek yapm�� oldu�umuz bu procedure uygulamas�n�n i�leyi�ini ad�m ad�m �al��t�rak g�rebiliriz. Prod ortamda Debug ederken dikkatli olmak laz�m. ��nk� prosed�r� debug ederken di�er yerlerden o prosed�re eri�imi kesiyor diye hat�rl�yorum. Yani canl� sistemlerde debug yaparken gerekli �nlemler al�nmadan yap�lmamas� gerekir.









------------�NDEX KULLANIMI �RNE��:-----------------

SELECT * FROM ABONE;

UPDATE ABONE SET SON_FATURA_TARIHI = SYSDATE;

UPDATE ABONE SET SON_FATURA_TARIHI = SYSDATE-1 WHERE MOD(ID,100)=0; -- Her 100 kay�ttan birinde tarihi bir g�n �ncesine g�ncelliyoruz. ABONE tablosunda toplam 100 bin tane kay�t oldu�u i�in 1000 kay�t g�ncellenmi� olacak.

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI = TO_DATE('08/12/2021', 'DD/MM/YYYY'); -- Tabloda 16/11/2021 tarihin ait kay�t olmas�na ra�men sorgu sonucu bo� geldi. ��nk� bizim verdi�imiz TO_DATE('16/11/2021', 'DD/MM/YYYY') ifadesinin saat, dakika ve saniyesi default olarak 00'd�r. ABONE tablosundaki kay�tlarda ise saat, dakika ve saniye de�erleri farkl�d�r. O y�zden e�le�medi ve sorgu bo� g�nd�.

SELECT TO_DATE('08/12/2021', 'DD/MM/YYYY') FROM DUAL; -- Bu ifade ile bir alt sat�rdaki ifade birbiriyle ayn� asl�nda. Yani biz bu ifadeyi kulland���m�zda ayn� zamanda bir alt sat�rdaki ifadeyi de kastetmi� oluyoruz.

SELECT TO_CHAR(TO_DATE('08/12/2021', 'DD/MM/YYYY'),'DD/MM/YYYY HH24:MI:SS') FROM DUAL; --Bu sorgu ile g�rebiliriz saat, dakika ve saniye de�erlerinin 00 oldu�unu. 

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI IS NOT NULL ORDER BY SON_FATURA_TARIHI;
--08/12/2021 00:00:00
--8/12/2021 12:01:34

SELECT * FROM ABONE ORDER BY SON_FATURA_TARIHI DESC; 

SELECT * FROM ABONE WHERE TRUNC(SON_FATURA_TARIHI) = TO_DATE('08/12/2021', 'DD/MM/YYYY'); -- Tarihini 1 g�n �nceye g�ncelledi�imiz 1000 kay�t geldi.

--�u an 100 bin kayd�m�z oldu�u i�in h�zl� bir �ekilde sorgu sonucumuz geldi. Fakat milyarlarca kayd�m�z olsayd� bu kadar �abuk gelmeyecekti. H�zl� getirebilmek i�in index kullanmam�z gerekirdi.

CREATE INDEX NDX_ABONE_SON_FATURA ON ABONE(SON_FATURA_TARIHI);

--Kulland���m�z tool'larda, sistemin bizim yazd���m�z sorgular� nas�l bir plan dahilinde �al��t�rd���n� g�sterdi�i �zellikleri vard�r. 
--Bu �zelli�i kullanarak sorgular�m�z�n nas�l �al��t���n� g�rebiliriz. Bunun PL/SQL Developer tool'undaki kar��l��� Explain Plan Window'dur. Toad, DBeaver gibi di�er tool'larda da vard�r bu �zellik.

SELECT * FROM ABONE WHERE TRUNC(SON_FATURA_TARIHI) = TO_DATE('08/12/2021', 'DD/MM/YYYY');
-- Bu sorguyu takrar Toad'�n Expain Plan'�nda �al��t�rsak (sorguyu se�ip Ctrl+E yapabilriz) olu�turdu�umuz indexi kullanmad���n� g�r�r�z. ��nk� bu sorgumuzdaki TRUNC ifadesi i�i bozuyor. 
--Bizim olu�turdu�umuz index'de SON_FATURA_TARIHI trunc's�z �ekilde kay�tl�. Ama �al��t�rd���m�z bu sorguda trunc oldu�u i�in �nce trunc ifadesi b�t�n datay� dola��p tarihlerden saat, dakika ve saniyeyi k�rpt�. Sonra sorguda bu haliyle date alanlar�n� kar��la�t�rd�. Bu y�zden index olmas� bir i�e yaramad�. 
--Index'den faydalanmak istiyorsak trunc kullanmamal�y�z. �uan bu haliyle de sorgumuz �al���r ama milyar kay�t olursa index kullanamayaca�� i�in yava�layacakt�r. 
--Index'ler B+ tree arama algoritmas�n� kulland��� i�in �ok h�zl� arama yapar. �rne�in 4 blok okuyarak 1 milyar tane kay�t arayabiliyoruz e�er index kullan�rsak. Yani 1 milyar tane kayd�n indexli halde tutuldu�u bir tabloda 4 tane data blo�u okuyarak bulmak istedi�imiz kay�ta ula�abiliyoruz. Detayl� bilgi i�in B+ tree ara�t�rabilirsin.
--�zetle indexler b�y�k miktarda kay�t aras�ndan arad���m�z veriye h�zl� bir �ekilde (INDEX RANGE SCAN) ula�mam�z� sa�l�yor. E�er index yoksa arad���m�z kayd� bulmak i�in b�t�n tabloyu ba�tan sona (TABLE ACCESS FULL) okumak zorunday�z. Index kullan�rsak CPU, RAM vs. gibi donan�mlar� da fazla yormam�� oluruz.

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI = TO_DATE('08/12/2021', 'DD/MM/YYYY'); -- TRUNC'� kald�rd�k. �uan olu�turdu�umuz indexi (NDX_ABONE_SON_FATURA) kullan�yor (Cost b�l�m� 173'den 2'ye d��t� dikkat edersek) ama bu sefer de kay�t getirmiyor trunc'� kald�rd���m�z i�in.
--Bu sorgular�n ikisinin de sorunlar� var: Biri kay�t getiriyor ama trunc oldu�u i�in indexi kullanam�yor. Di�eri de Indexi kullan�yor ama trunc olmad��� i�in kay�t getiremiyor.

--Bu durumda uygulayabilece�imiz birka� farkl� ��z�m yolu var:

--1.Y�ntem olarak bir tarih aral��� verip o �ekilde sorgulama yapabiliriz. 
--Yani biz bir kolona index tan�mlam��sak ve o indexi kullanmak istiyorsak �zerine fonksiyon (trunc vs. gibi fonksiyonlar) uygulamamal�y�z.

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI >= TO_DATE('08/12/2021', 'DD/MM/YYYY') AND SON_FATURA_TARIHI < TO_DATE('09/12/2021', 'DD/MM/YYYY'); --Sadece 8 Aral�k verisini ald�k burada. Video'da Fatih Sami Karaka� Hoca yapt���nda Index kullan�yordu ama biz Toad'da yapt���m�zda index kullanmad�. INDEX RANGE SCAN yerine TABLE ACCESS FULL yaz�yordu Toad'�n Explain Plan ekran�nda.

SELECT * FROM ABONE WHERE ID=90000; --Mesela 90000. kayd� getirdik. Toplam data say�m�z �ok fazla olmad��� (100 bin tane) i�in getirirken pek fazla zorlanmad�. 0.1 saniye s�rd� kayd� getirmesi.

INSERT INTO ABONE SELECT * FROM ABONE; -- �imdi bu sorguyu ard arda 7 defa �al��t�r�yoruz. Her �al��t�rmam�zda ABONE tablosundaki verilerin tamam�n� �zerine tekrar ekliyor. �lk �al��t�rd���m�zda 100 bin kay�t ekledi ve 1 saniye s�rd� eklemesi. Fakat 7. �al��t�rmam�zda 6.4 milyon kay�t ekledi�i i�in 28 saniye s�rd� sorgunun �al��ma s�resi. Milyarlarca kay�t ekleyecek olsayd� g�nlerce s�recekti belki. Bu t�r durumlarda belli periyorlarla commit eklemenin �nemi de ortaya ��k�yor.

SELECT count(*) FROM ABONE;

SELECT * FROM ABONE WHERE ID=90000; -- �imdi 12.8 milyon kay�t aras�ndan tekrar sorguluyoruz ayn� kay�t�. Verileri �oklad���m�z i�in Id'si 90000 olan birden �ok kay�t var. Bu sefer �al��ma s�resi 0.5 saniye (576 milisaniye) s�rd� yakla��k. Explain Plan' sekmesine bakt���m�zda da ID kolonuna bir index tan�mlamad���m�z i�in TABLE ACCESS FULL ile eri�mi� ve Cost = 171 olmu�.

CREATE INDEX NDX_ABONE_ID ON ABONE(ID); -- ABONE tablosunun ID kolonunda bir Index olu�turduk. Art�k tabloda milyonlarca kay�t oldu�u i�in indexi olu�turmas� bile 8 saniye s�rd� :)

SELECT * FROM ABONE WHERE ID=90000; -- Index'i kullanabilmek i�in, index'in tan�mland��� kolonu(ID), sorguda �art (WHERE) olarak vermemiz gerekir. Ayn� sorguyu tekrar �al��t�rd���m�zda bu sefer 0.07 saniye (70 milisaniye) s�rd� yakla��k. Yani yakla��k 9 kat h�z fark� var index kullanmadan �al��an sorgu ile aras�nda. Explain Plan sekmesine bakt���m�zda da INDEX RANGE SCAN ile arad���n� ve Cost = 3 oldu�unu g�r�yoruz. Yani sorgu maliyetinde de 50 kat dan fazla d���� olmu�. Veri say�s� artt�k�a bu farklar daha da artacakt�r.






--2.Yol: Veriyi tabloya direkt olarak trunc'l� �ekilde at�p, sorgulamay� o �ekilde yapabilirdik. 
--B�ylece �zerinde index bulunan kolona fonksiyon (trunc) uygulamam�za gerek kalmaz ve indexi kaybetmeden select yapabiliriz.
--E�er mutlaka saat, dakika vs. bilgisi de gerekliyse o zaman tablomuzda Audit (denetim) ama�l� INSERT_TIME, UPDATE_TIME yada ISLEM_TARIHI gibi ba�ka kolonlar olu�turabiliriz. 
--Bu kolonlara da trunc yapmadan yazar�z tarihi. Onlar da kayd�n giri� zaman�n� ifade etmi� olur. B�ylece trunc'l� �ekilde sorgulama yapacaksak SON_FATURA_TARIHI kolonu �zerinden, saat, dakika bilgisi de laz�msa Audit kolonlar �zerinden sorgulama yapabiliriz.

UPDATE ABONE SET SON_FATURA_TARIHI = TRUNC(SYSDATE-1) WHERE MOD(ID,100)=0; --Update ifademizi tekrar �al��t�r�p bu kez her 100 sat�rda bir verileri tabloya trunc'l� olarak yaz�yoruz. Toplamda 128 bin kay�t update etmi� olduk.

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI = TO_DATE('08/12/2021', 'DD/MM/YYYY'); --Daha �nceden trunc'l� olarak �al��t�rd���m�z sorguyu �imdi trunc's�z olarak �al��t�r�yoruz. Sorgu sonucunda da g�rd���m�z gibi verileri SON_FATURA_TARIHI alan�n� trunc'lad���m�z i�in saat, dakika ve saniye bilgisi olmadan geldi.

--Index sorgulama performans�n� art�rmak i�indir ama unutulmamal� ki tablo �zerindeki insert, update ve delete ifadelerini de yava�latacakt�r.
--Her sorgu i�in bir index eklemek tabloyu bo�acakt�r. 
--T�m sorgular�n ihtiya�lar� birlikte d���n�lmeli, m�mk�n olan en az say�da index olu�turulmal�.
--Sorgular�n ihtiyac� en az say�da index ile ��z�lmeli. Tablodaki verilerin %5'inden daha az�n� select ile getireceksek index kullanmak mant�kl�d�r. Ama y�zde 5'inden fazlas�n� getireceksek o zaman index yerine table access full ile getirmek daha do�ru olur.
--Mesela i�inde 100 milyon sat�r olan bir tablomuz var. Bu tablodan biz select ile 5 milyondan az data getireceksek index kullanmal�y�z. 5 milyondan fazla kay�t getireceksek index kullanmadan normal select ile getirmek daha avantajl� olacakt�r.


--�ndex'lerle ilgili daha detayl� bilgi i�in M:\IZV\OZEL\Veri Ambar� ve �� Zekas�\07 - E�itim\04 - Oracle 12c PL-SQL E�itimi\�rnekler\3.G�n\dbIndex.pptx slayt�n� inceleyebilirsin. 
--Fatih Sami Karaka� Hoca C:\Users\bisik\Videos\Captures\Oracle 12c PL-SQL E�itimi\3.G�n\Zoom Meeting 2021-11-17 13-38-16.mp4 ve 
--C:\Users\bisik\Videos\Captures\Oracle 12c PL-SQL E�itimi\3.G�n\Zoom Meeting 2021-11-17 13-56-20.mp4 videolar�nda anlat�yor slayt�. Hints kullan�m�n� da anlat�yor bu videoda. Hints ile ilgili detayl� bilgi sahibi olmak i�in internetten ara�t�r
-- https://docs.oracle.com/cd/B12037_01/server.101/b10752/hintsref.htm --> Burada detayl� bilgi veriliyor Hint'lerle ilgili.


GRANT SELECT ON gv$sqlarea TO HR; 

SELECT * FROM gv$sqlarea; -- DBA'larin Performans izlemesi i�in
