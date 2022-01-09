--PACKAGE
--Paketler: Birçok fonksiyon, procedure, sabiler, deðiþkenler, type'lar gibi birçok þeyi birarada tutabileceðimiz veritabaný objeleridir.
--Ýþlerin çok karmaþýklaþarak yönetilemez hale gelmesini engellemek için kullanýlýr.
--Bazen oluþturduðumuz prosedürlerin içeriðini baþkalarýna göstermek istemeyebiliriz. Sacede prosedürün kullanýmýna yönelik kýsýmlarý dýþ kullanýcýlara göstermek isteyebiliriz.
--Bu yüzden package'larda Spec ve Body diye 2 kýsým vardýr. Birisine paketin sadece kullanýmý yetkisini vermek istersek sadece spec kýsmýna execute yetkisi vermemiz yeterli olur.
--Ýstersek paketin içeriðini gizleyebiliriz. WRAP fonksiyonu ile þifreleyip içeriði gizli þekilde kullanýma sunabiliriz. Bu þekilde karþý tarafýn package içeriðini görme ve deðiþtirme þansý olmaz.

--Package örneði:

/********************************************************************************/  --->>> SPEC KISMI

CREATE OR REPLACE PACKAGE PCK_HR IS -- Burasý Spec kýsmý. Bu kýsma yazdýklarýmýz dýþarýya açýktýr. Yani bu package üzerinde yetkisi olan kiþiler buradaki spec kýsmýný görür ve oradakileri bilgileri referans alarak kendi uygulamalarýnda kullanabilirler.

PROCEDURE add_job_history -- Burada Spec kýsmýnda tanýmlamasaydýk aþaðýda çaðýramayacaktýk.
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
      


FUNCTION GET_DEPT_SALARY(PRM_DEPT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE) -- Prosedür tanýmladýðýmýz gibi fonksiyon da tanýmlayabiliriz.
        RETURN EMPLOYEES.SALARY%TYPE;
      
      
END PCK_HR;





/********************************************************************************/  --->>> BODY KISMI   

CREATE OR REPLACE PACKAGE BODY PCK_HR IS -- Burasý da Body kýsmý. Eðer biz bir fonksiyonun tanýmýný Body kýsmýnda yaparsak bu internal bir fonksiyon olur. Yani sadece PCK_HR paketinin içerisinden eriþilebilir. Ne zaman ki biz bu fonksiyonun tanýmýný Spec kýsmýna koyarýz, iþte o zaman dýþarýdan eriþilebilir hale gelir.

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
    PRAGMA EXCEPTION_INIT(ZORUNLU_ALAN_HATASI, -02290); -- Oracle'ýn 1400 numaralý hatasýný ZORUNLU_ALAN_HATASI olarak tanýmladýk burada. Yani Oracle'ýn kendisinin isimlendirmediði bir hatayý biz kendimiz bu þekilde adlandýrabiliyoruz


    BEGIN
      INSERT INTO DEPARTMENTS VALUES PRM_DEPT;
      PRM_RC := 'Islem basarili';
      COMMIT;
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        PRM_RC := 'Mukerrer bolum numarasi';
    WHEN ZORUNLU_ALAN_HATASI THEN --Burada da yukarýda tanýmladýðýmýz hatayý kullanýyoruz. Oluþturduðumuz Exception sadece içinde bulunduðu Begin-End bloðunu kapsar. Mesela bir procedure içinde 1/0 ifadesi koyduk. Fakat exception when zero_divide hatasýný baþka bir Begin-End bloðu arasýnda tanýmlarsak o hatayý görmeyecektir. O yüzden hatanýn gelmesini nerede bekliyorsak hata yönetimini de ayný Begin-End bloðunda yapmamýz lazým. Daha detaylý bilgi için -- https://www.oracletutorial.com/plsql-tutorial/plsql-exception-propagation/ linkindeki örnekleri inceleyebilirsin.

        PRM_RC := 'Zorunlu alanlari doldurunuz'||SQLERRM;      
    WHEN OTHERS THEN -- Aklýmýza gelen tüm hatalarý yakaladýktan sonra diðer beklenmeyen hatalar için WHEN OTHERS kullanýrýz. WHEN OTHERS herzaman Exception'larýn en altýnda olur.
        PRM_RC := 'Beklenmeyen DB Hatasi'||SQLERRM;  
    END;


    FUNCTION GET_DEPT_SALARY(PRM_DEPT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE) -- Prosedür tanýmladýðýmýz gibi fonksiyon da tanýmlayabiliriz.
        RETURN EMPLOYEES.SALARY%TYPE IS

    L_TOTAL_SALARY EMPLOYEES.SALARY%TYPE;
    BEGIN
        SELECT SUM(SALARY) INTO L_TOTAL_SALARY -- SUM(SALARY) ifadesinden gelen deðeri bir deðiþkende tutmamýz lazým. O yüzden INTO L_TOTAL_SALARY ifadesini koyduk. Bu ifade olmasaydý hata verirdi.
        FROM EMPLOYEES
        WHERE DEPARTMENT_ID = PRM_DEPT_ID;
        RETURN(L_TOTAL_SALARY); -- Fonksiyonlar mutlaka return deðeri döndürmek zorundadýr. Return olmazsa hata verir.
    END;




END PCK_HR;



/********************************************************************************/  --->>> ÇALIÞTIRMA KISMI

BEGIN
    PCK_HR.ADD_JOB_HISTORY; -- Package içerisindekilerin kullanýmý bu þekilde. Parametrelerini verirsek çalýþacaktýr. Parametreleri de DECLARE kýsmý oluþturup orda tanýmlamamýz lazým tabiki.
END;

BEGIN
    PCK_HR.DEPARTMENT_INSERT2; -- Package içerisindekilerin kullanýmý bu þekilde. Parametrelerini verirsek çalýþacaktýr. Parametreleri de DECLARE kýsmý oluþturup orda tanýmlamamýz lazým tabiki.
END;











--ÖRNEK 2: PCK_EGITIM PAKETÝ ALTINDA BAZI OBJELERÝ TOPLAYALIM:

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
P_RC := 'ÝÞLEM BAÞARILI.';

EXCEPTION WHEN NO_DATA_FOUND THEN 
P_RC := 'GEÇERSÝZ ÜLKE ADI.';

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

P_RC:='BAÞARILI ÝÞLEM';
COMMIT;

EXCEPTION WHEN EX_LIMIT_KONTROL THEN  
ROLLBACK;
P_RC:='MAAÞ ARALIK DEÐERLERÝ DIÞINDADIR.';

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




-- 3.GÜN
/***********************************************************************************************************************************************/
--TRANSACTION YÖNETÝMÝ:
--Commit
--Rollback (to savepoint)
--Savepoint
--Autonomous Transactions

--Db'deki transaction'larda bizim irademiz dýþýnda bir kesinti olmamalýdýr. Ýþlem bütünlüðü korunmalýdýr. Yani transaction'lar atomik (bölünemez, yarýda kesilemez) olmalýdýr. 
--Eðer böyle olmazsa örneðin fatura ödenmiþtir ama kimin ödediði belli deðildir. Çünkü o bilginin iþlenmesi sýrasýnda transaction yarýda kesilmiþtir. 
--Bu tür durumlarý engellememiz gerekir. Bunu engellemek için de Commit, Rollback, Savepoint, Autonomous Transactions gibi yapýlar kullanýlýr.

--Commit ve Rollback:
--Bir transaction commit ve rollback görene kadar devam ederler. Eðer commit yapýlmazsa kullanýcý sadece bulunduðu session'da deðiþiklikleri görebilir. Diðer kullanýcýlar göremez. Eðer commit etmeden session kapatýrsa deðiþiklikler kaybolur.
--Eðer bir iþin (procedure, function vs.) bölünmeden bir bütün olarak çalýþmasý gerekiyorsa Exception'larýn altýna Rollback de koymalýyýz.

--Savepoint:
--Eðer transaction'ýmýz atomik deðilse, yani bazý kýsýmlar önemli, bazý kýsýmlar hata alsa da olur þeklindeyse, o zaman önemli noktalara savepoint koyarak ilerlememiz gerekir ki eðer transaction kesilirse savepoint'den öncesini kaybetmeyelim.
--Mesela bir bulk insert iþlemi yapýyoruz. 100 bin tane kayýt insert edeceðim. Her 10 bin kayýtta eðer bir hata yoksa savepoint koyarým ki, bir hata çýktýðýnda en baþtan baþlamayayým.
--Örneðin; 100 bin tane fatura ödeme iþleminin kaydedilmesi gerekiyor. Bu durumda faturalarý düzgün ödenenler kaydedilsin, bir sorun olanlar bir tabloya loglansýn, fakat iþlemimiz kesilmeyip devam etsin. Biz en son sorun olanlarý kontrol ederiz gibi bir senaryo tasarlanabilir.
--Mesela 10 milyon kayýt olan bir iþi tek seferde biz tamamlayamayýz. Rollback segment'ler dolar ve normal iþ akýþýnda olmayan hatalar vermeye baþlar. "Transaction_to_old" gibi bir hata vermeye baþlar eðer iþlem çok uzun sürerse. Yani rollback segment'leri dolduðu için iþlemi otomatikmen keser.
--Bu yüzden bizim belli periyotlarla (örn: her 1000 kayýtta) bu rollback'leri boþaltýp, yaptýðýmýz baþarýlý iþlemleri commit'leyip yoluna devam edecek bir yapý kurmamýz gerekir.

--Abona uygulamasý yapabilmemiz için gerekli olan tablo ve verilerimiz: Bu tablolar varmý sende kontrol et. Datalar farklýysa tablolarý delete edip bu kodlarla tekrar oluþturabilirsin.
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
  fatura_tipi        number(2) references fatura_tipi(kod), --FATURA tablosundaki FATURA_TIPI kolonuna gireceðimiz deðerin, mutlaka FATURA_TIPI tablosunun KOD kolonunda bulunan deðerlerden biri olmasý için bu þekilde bir constraint tanýmladýk.
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

--Yapacaðýmýz uygulama:
--Uygulama kesintisiz çalýþsýn. Yani bir hata olduðu zaman kesilmesin. 
--Hata alýnan aboneler için loglama yapýlsýn.
--Her 1000 kayýtta bir commit edilsin. Çok sýk (örn: her 10 kayýtta bir) commit edilmesi de iyi deðildir. Bu durumda da performans yavaþlamasý olabilir. O yüzden 1000 kayýt veya 10000 kayýtta bir commit idealdir.

CREATE OR REPLACE PROCEDURE SP_FATURA IS

CURSOR C1 IS select * from ABONE order by ID; -- Bütün aboneleri içerisine atmak için cursor'ýmýzý oluþturduk.

l_ERROR_MESAJ VARCHAR2 (200);

BEGIN

    FOR LC1 IN C1 LOOP -- Her bir abone satýrda gezinebilmek için for içinde LC1 oluþturduk.
    
    SAVEPOINT GUNVENLINOKTA; -- Burasý bizim güvenli kayýt noktamýz. Her 1000 kayýtta savepoint almak istiyoruz. Ýlk döngüden itibaren kaydetmek istediðimiz için savepoint'i döngü baþýnda oluþturduk. Hata alýrsa da  Exception içinde ROLLBACK TO ile kaydediyoruz
    
    BEGIN --Kayýt ekleme ve Hata yönetimini ayrý bir Begin-End bloðunda yaptýk daha anlaþýlýr olmasý için.
    
        UPDATE ABONE -- 9, 19, 29 vs. nolu abonelere gelince INSERT iþlemi hata alacak ve faturalarý oluþmayacak zaten. Buradaki UPDATE iilemi de aþaðýdaki ROLLBACK'den dolayý geri alýnacaðý için SON_FATURA_TARIHI güncellenmeyecek. 
           SET SON_FATURA_TARIHI = SYSDATE
           WHERE ID = LC1.ID;
         
        INSERT INTO FATURA VALUES -- FATURA tablosundaki her kolon için otomatik deðer üretip onlarý ekliyoruz her seferinde kendimiz girmemek için.
            (LC1.ID, 'F'||LPAD(LC1.ID,6,0), MOD (LC1.ID,10), MOD(LC1.ID,5)*2 ); --FATURA_TIPI kolonuna girilecek deðeri MOD (LC1.ID,10) þeklinde yaptýk. Bu da 0'dan 9'a kadar olan deðerleri alacak demek oluyor. Fakat FATURA_TIPI tablomuzda 0'dan 8'e kadar tip bulunduðu için her 10 kayýtta bir tip9 için hata verecek. fatura no ve tutar alanlarýný da id alanýna baðlý olarak ürettik.
        EXCEPTION WHEN OTHERS THEN 
          l_ERROR_MESAJ :=  SQLERRM; --ROLLBACK çalýþmadan önce INSERT ifadesinden gelecek hatayý burada l_ERROR_MESAJ adlý bir deðiþkene kaydediyoruzki ROLLBACK çalýþtýktan sonra bu hatayý ezmesin. Eðer bunu yapmazsak en son ROLLBACK ifadesi çalýþacaðý için SQLERRM içerisinde o kalacak ve INSERT'den gelen hatayý yakalayamamýþ olacaðýz.
          ROLLBACK TO GUNVENLINOKTA; -- Buradaki Savepoint'e gitme iþlemi bazý programlama dillerindeki "go to x. line" gibi birþey deðil. Yani "hata olursa þu satýra git" tarzýnda birþey söylemiyoruz burada. Sadece ROLLBACK TO GUNVENLINOKTA ifadesini gördüðünde en son Savepoint noktasýndan itibaren yapýlan deðiþiklikleri iptal et diyoruz. 
        INSERT INTO HATA_DURUMLARI VALUES (LC1.ID || ' KULLANICI ÝÇÝN FATURA ÜRETÝLEMEDÝ. - ' || l_ERROR_MESAJ); --Rollback iþleminden sonra programýmýz normal iþleyiþine devam ediyor. Alýnan hatayý ilgili tablomuza basýyoruz.
        --Bu satýrda COMMIT yazmamýza gerek yok. Çünkü IF MOD ifadesinin içindeki COMMIT ile hepsini commitleyecek zaten.
    END; 
    
    IF MOD ( C1%ROWCOUNT, 1000 ) = 0  THEN --Her 1000 kayýt eklendiðinde commit yapýlan kýsým.
      COMMIT ; --Her 1000, 2000, 3000 vs. kayýtta commit edecek sadece.
    END IF;
         
    END LOOP;

COMMIT; -- Farzedelim ki 100 bin deðil de 99800 tane kaydýmýz var toplam. Bu durumda yukarýdaki commit en son 99000. kayýtta çalýþtý. Yani henüz commit edilmemiþ 800 tane daha kaydýmýz var. Bu yüzden son 800 kaydýn da update edilmesi için commit eklendi.

END;

select * from abone;

select * from fatura;

select * from fatura_tipi;

SELECT * FROM HATA_DURUMLARI;

SELECT ABONE_ID FROM FATURA;

SELECT * FROM ABONE 
WHERE SON_FATURA_TARIHI IS NOT NULL 
AND ID NOT IN (SELECT ABONE_ID FROM FATURA); -- Bu sorgu SON_FATURA_TARIHI güncellenmiþ, fakat faturasý oluþmamýþ abone varmý diye kontrol ediyor. Yani yarým kalmýþ transaction olup olmadýðýna bakýyoruz. Sorgu sonucu boþ geliyorsa yarýn kalmýþ transaction yok demektir.

SELECT * FROM ABONE 
WHERE SON_FATURA_TARIHI IS NULL 
AND ID IN (SELECT ABONE_ID FROM FATURA); -- Bu da yukarýdaki sorgunun tam tersi. Yani faturasý oluþmuþ, fakat SON_FATURA_TARIHI güncellenmemiþ aboneleri kontrol ediyor sanýrým? Bu sorgunun da sonucunun boþ gelmesi lazým normal þartlarda.
--Ýki sorgu da boþ geliyorsa sorun yok demektir. Yani ABONE tablosunda SON_FATURA_TARIHI güncellenmiþse faturasý var. Eðer SON_FATURA_TARIHI boþ ise faturasý yok demektir. Beklediðimiz durum bu þekilde.

select * from abone ORDER BY ID; --Her 9, 19, 29 vs. ID'nin Son fatura tarihi boþ.

select * from fatura ORDER BY ABONE_ID; -- --Her 9, 19, 29 vs. ABONE_ID yok. Yani faturasý yok.

--Ýstersek Debug ederek yapmýþ olduðumuz bu procedure uygulamasýnýn iþleyiþini adým adým çalýþtýrak görebiliriz. Prod ortamda Debug ederken dikkatli olmak lazým. Çünkü prosedürü debug ederken diðer yerlerden o prosedüre eriþimi kesiyor diye hatýrlýyorum. Yani canlý sistemlerde debug yaparken gerekli önlemler alýnmadan yapýlmamasý gerekir.









------------ÝNDEX KULLANIMI ÖRNEÐÝ:-----------------

SELECT * FROM ABONE;

UPDATE ABONE SET SON_FATURA_TARIHI = SYSDATE;

UPDATE ABONE SET SON_FATURA_TARIHI = SYSDATE-1 WHERE MOD(ID,100)=0; -- Her 100 kayýttan birinde tarihi bir gün öncesine güncelliyoruz. ABONE tablosunda toplam 100 bin tane kayýt olduðu için 1000 kayýt güncellenmiþ olacak.

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI = TO_DATE('08/12/2021', 'DD/MM/YYYY'); -- Tabloda 16/11/2021 tarihin ait kayýt olmasýna raðmen sorgu sonucu boþ geldi. Çünkü bizim verdiðimiz TO_DATE('16/11/2021', 'DD/MM/YYYY') ifadesinin saat, dakika ve saniyesi default olarak 00'dýr. ABONE tablosundaki kayýtlarda ise saat, dakika ve saniye deðerleri farklýdýr. O yüzden eþleþmedi ve sorgu boþ göndü.

SELECT TO_DATE('08/12/2021', 'DD/MM/YYYY') FROM DUAL; -- Bu ifade ile bir alt satýrdaki ifade birbiriyle ayný aslýnda. Yani biz bu ifadeyi kullandýðýmýzda ayný zamanda bir alt satýrdaki ifadeyi de kastetmiþ oluyoruz.

SELECT TO_CHAR(TO_DATE('08/12/2021', 'DD/MM/YYYY'),'DD/MM/YYYY HH24:MI:SS') FROM DUAL; --Bu sorgu ile görebiliriz saat, dakika ve saniye deðerlerinin 00 olduðunu. 

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI IS NOT NULL ORDER BY SON_FATURA_TARIHI;
--08/12/2021 00:00:00
--8/12/2021 12:01:34

SELECT * FROM ABONE ORDER BY SON_FATURA_TARIHI DESC; 

SELECT * FROM ABONE WHERE TRUNC(SON_FATURA_TARIHI) = TO_DATE('08/12/2021', 'DD/MM/YYYY'); -- Tarihini 1 gün önceye güncellediðimiz 1000 kayýt geldi.

--Þu an 100 bin kaydýmýz olduðu için hýzlý bir þekilde sorgu sonucumuz geldi. Fakat milyarlarca kaydýmýz olsaydý bu kadar çabuk gelmeyecekti. Hýzlý getirebilmek için index kullanmamýz gerekirdi.

CREATE INDEX NDX_ABONE_SON_FATURA ON ABONE(SON_FATURA_TARIHI);

--Kullandýðýmýz tool'larda, sistemin bizim yazdýðýmýz sorgularý nasýl bir plan dahilinde çalýþtýrdýðýný gösterdiði özellikleri vardýr. 
--Bu özelliði kullanarak sorgularýmýzýn nasýl çalýþtýðýný görebiliriz. Bunun PL/SQL Developer tool'undaki karþýlýðý Explain Plan Window'dur. Toad, DBeaver gibi diðer tool'larda da vardýr bu özellik.

SELECT * FROM ABONE WHERE TRUNC(SON_FATURA_TARIHI) = TO_DATE('08/12/2021', 'DD/MM/YYYY');
-- Bu sorguyu takrar Toad'ýn Expain Plan'ýnda çalýþtýrsak (sorguyu seçip Ctrl+E yapabilriz) oluþturduðumuz indexi kullanmadýðýný görürüz. Çünkü bu sorgumuzdaki TRUNC ifadesi iþi bozuyor. 
--Bizim oluþturduðumuz index'de SON_FATURA_TARIHI trunc'sýz þekilde kayýtlý. Ama çalýþtýrdýðýmýz bu sorguda trunc olduðu için önce trunc ifadesi bütün datayý dolaþýp tarihlerden saat, dakika ve saniyeyi kýrptý. Sonra sorguda bu haliyle date alanlarýný karþýlaþtýrdý. Bu yüzden index olmasý bir iþe yaramadý. 
--Index'den faydalanmak istiyorsak trunc kullanmamalýyýz. Þuan bu haliyle de sorgumuz çalýþýr ama milyar kayýt olursa index kullanamayacaðý için yavaþlayacaktýr. 
--Index'ler B+ tree arama algoritmasýný kullandýðý için çok hýzlý arama yapar. Örneðin 4 blok okuyarak 1 milyar tane kayýt arayabiliyoruz eðer index kullanýrsak. Yani 1 milyar tane kaydýn indexli halde tutulduðu bir tabloda 4 tane data bloðu okuyarak bulmak istediðimiz kayýta ulaþabiliyoruz. Detaylý bilgi için B+ tree araþtýrabilirsin.
--Özetle indexler büyük miktarda kayýt arasýndan aradýðýmýz veriye hýzlý bir þekilde (INDEX RANGE SCAN) ulaþmamýzý saðlýyor. Eðer index yoksa aradýðýmýz kaydý bulmak için bütün tabloyu baþtan sona (TABLE ACCESS FULL) okumak zorundayýz. Index kullanýrsak CPU, RAM vs. gibi donanýmlarý da fazla yormamýþ oluruz.

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI = TO_DATE('08/12/2021', 'DD/MM/YYYY'); -- TRUNC'ý kaldýrdýk. Þuan oluþturduðumuz indexi (NDX_ABONE_SON_FATURA) kullanýyor (Cost bölümü 173'den 2'ye düþtü dikkat edersek) ama bu sefer de kayýt getirmiyor trunc'ý kaldýrdýðýmýz için.
--Bu sorgularýn ikisinin de sorunlarý var: Biri kayýt getiriyor ama trunc olduðu için indexi kullanamýyor. Diðeri de Indexi kullanýyor ama trunc olmadýðý için kayýt getiremiyor.

--Bu durumda uygulayabileceðimiz birkaç farklý çözüm yolu var:

--1.Yöntem olarak bir tarih aralýðý verip o þekilde sorgulama yapabiliriz. 
--Yani biz bir kolona index tanýmlamýþsak ve o indexi kullanmak istiyorsak üzerine fonksiyon (trunc vs. gibi fonksiyonlar) uygulamamalýyýz.

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI >= TO_DATE('08/12/2021', 'DD/MM/YYYY') AND SON_FATURA_TARIHI < TO_DATE('09/12/2021', 'DD/MM/YYYY'); --Sadece 8 Aralýk verisini aldýk burada. Video'da Fatih Sami Karakaþ Hoca yaptýðýnda Index kullanýyordu ama biz Toad'da yaptýðýmýzda index kullanmadý. INDEX RANGE SCAN yerine TABLE ACCESS FULL yazýyordu Toad'ýn Explain Plan ekranýnda.

SELECT * FROM ABONE WHERE ID=90000; --Mesela 90000. kaydý getirdik. Toplam data sayýmýz çok fazla olmadýðý (100 bin tane) için getirirken pek fazla zorlanmadý. 0.1 saniye sürdü kaydý getirmesi.

INSERT INTO ABONE SELECT * FROM ABONE; -- Þimdi bu sorguyu ard arda 7 defa çalýþtýrýyoruz. Her çalýþtýrmamýzda ABONE tablosundaki verilerin tamamýný üzerine tekrar ekliyor. Ýlk çalýþtýrdýðýmýzda 100 bin kayýt ekledi ve 1 saniye sürdü eklemesi. Fakat 7. çalýþtýrmamýzda 6.4 milyon kayýt eklediði için 28 saniye sürdü sorgunun çalýþma süresi. Milyarlarca kayýt ekleyecek olsaydý günlerce sürecekti belki. Bu tür durumlarda belli periyorlarla commit eklemenin önemi de ortaya çýkýyor.

SELECT count(*) FROM ABONE;

SELECT * FROM ABONE WHERE ID=90000; -- Þimdi 12.8 milyon kayýt arasýndan tekrar sorguluyoruz ayný kayýtý. Verileri çokladýðýmýz için Id'si 90000 olan birden çok kayýt var. Bu sefer çalýþma süresi 0.5 saniye (576 milisaniye) sürdü yaklaþýk. Explain Plan' sekmesine baktýðýmýzda da ID kolonuna bir index tanýmlamadýðýmýz için TABLE ACCESS FULL ile eriþmiþ ve Cost = 171 olmuþ.

CREATE INDEX NDX_ABONE_ID ON ABONE(ID); -- ABONE tablosunun ID kolonunda bir Index oluþturduk. Artýk tabloda milyonlarca kayýt olduðu için indexi oluþturmasý bile 8 saniye sürdü :)

SELECT * FROM ABONE WHERE ID=90000; -- Index'i kullanabilmek için, index'in tanýmlandýðý kolonu(ID), sorguda þart (WHERE) olarak vermemiz gerekir. Ayný sorguyu tekrar çalýþtýrdýðýmýzda bu sefer 0.07 saniye (70 milisaniye) sürdü yaklaþýk. Yani yaklaþýk 9 kat hýz farký var index kullanmadan çalýþan sorgu ile arasýnda. Explain Plan sekmesine baktýðýmýzda da INDEX RANGE SCAN ile aradýðýný ve Cost = 3 olduðunu görüyoruz. Yani sorgu maliyetinde de 50 kat dan fazla düþüþ olmuþ. Veri sayýsý arttýkça bu farklar daha da artacaktýr.






--2.Yol: Veriyi tabloya direkt olarak trunc'lý þekilde atýp, sorgulamayý o þekilde yapabilirdik. 
--Böylece üzerinde index bulunan kolona fonksiyon (trunc) uygulamamýza gerek kalmaz ve indexi kaybetmeden select yapabiliriz.
--Eðer mutlaka saat, dakika vs. bilgisi de gerekliyse o zaman tablomuzda Audit (denetim) amaçlý INSERT_TIME, UPDATE_TIME yada ISLEM_TARIHI gibi baþka kolonlar oluþturabiliriz. 
--Bu kolonlara da trunc yapmadan yazarýz tarihi. Onlar da kaydýn giriþ zamanýný ifade etmiþ olur. Böylece trunc'lý þekilde sorgulama yapacaksak SON_FATURA_TARIHI kolonu üzerinden, saat, dakika bilgisi de lazýmsa Audit kolonlar üzerinden sorgulama yapabiliriz.

UPDATE ABONE SET SON_FATURA_TARIHI = TRUNC(SYSDATE-1) WHERE MOD(ID,100)=0; --Update ifademizi tekrar çalýþtýrýp bu kez her 100 satýrda bir verileri tabloya trunc'lý olarak yazýyoruz. Toplamda 128 bin kayýt update etmiþ olduk.

SELECT * FROM ABONE WHERE SON_FATURA_TARIHI = TO_DATE('08/12/2021', 'DD/MM/YYYY'); --Daha önceden trunc'lý olarak çalýþtýrdýðýmýz sorguyu þimdi trunc'sýz olarak çalýþtýrýyoruz. Sorgu sonucunda da gördüðümüz gibi verileri SON_FATURA_TARIHI alanýný trunc'ladýðýmýz için saat, dakika ve saniye bilgisi olmadan geldi.

--Index sorgulama performansýný artýrmak içindir ama unutulmamalý ki tablo üzerindeki insert, update ve delete ifadelerini de yavaþlatacaktýr.
--Her sorgu için bir index eklemek tabloyu boðacaktýr. 
--Tüm sorgularýn ihtiyaçlarý birlikte düþünülmeli, mümkün olan en az sayýda index oluþturulmalý.
--Sorgularýn ihtiyacý en az sayýda index ile çözülmeli. Tablodaki verilerin %5'inden daha azýný select ile getireceksek index kullanmak mantýklýdýr. Ama yüzde 5'inden fazlasýný getireceksek o zaman index yerine table access full ile getirmek daha doðru olur.
--Mesela içinde 100 milyon satýr olan bir tablomuz var. Bu tablodan biz select ile 5 milyondan az data getireceksek index kullanmalýyýz. 5 milyondan fazla kayýt getireceksek index kullanmadan normal select ile getirmek daha avantajlý olacaktýr.


--Ýndex'lerle ilgili daha detaylý bilgi için M:\IZV\OZEL\Veri Ambarý ve Ýþ Zekasý\07 - Eðitim\04 - Oracle 12c PL-SQL Eðitimi\Örnekler\3.Gün\dbIndex.pptx slaytýný inceleyebilirsin. 
--Fatih Sami Karakaþ Hoca C:\Users\bisik\Videos\Captures\Oracle 12c PL-SQL Eðitimi\3.Gün\Zoom Meeting 2021-11-17 13-38-16.mp4 ve 
--C:\Users\bisik\Videos\Captures\Oracle 12c PL-SQL Eðitimi\3.Gün\Zoom Meeting 2021-11-17 13-56-20.mp4 videolarýnda anlatýyor slaytý. Hints kullanýmýný da anlatýyor bu videoda. Hints ile ilgili detaylý bilgi sahibi olmak için internetten araþtýr
-- https://docs.oracle.com/cd/B12037_01/server.101/b10752/hintsref.htm --> Burada detaylý bilgi veriliyor Hint'lerle ilgili.


GRANT SELECT ON gv$sqlarea TO HR; 

SELECT * FROM gv$sqlarea; -- DBA'larin Performans izlemesi için
