create or replace 
PROCEDURE Get_BLOBs_Only (
   i_caseref          IN     /* schemaname */ caseheader.casereference%TYPE,
   i_is_zipped        IN BOOLEAN
   )
IS
BEGIN
DECLARE
 l_compressed_blob      BLOB;
 l_uncompressed_blob    BLOB;
 l_blob_tmp             VARCHAR2(32767);
 l_buffer               RAW(32767);
 l_blob_char            VARCHAR2(32767);
 l_blob_string          VARCHAR2(32767);
 l_pos                  NUMBER := 1;
 l_blob_len             NUMBER;
 l_amount               BINARY_INTEGER := 16383; -- Half the maximum buffer size, since converting from single byte to 2- byte HEX
 PDC_Type_Base_Ptr      NUMBER;
 PDC_Type_Ptr           NUMBER;
 PDC_Type_Ptr2          NUMBER;
 number_of_participants INTEGER := 0;
 crlf                   VARCHAR2(2) := chr(13)||chr(10);
 tempString             STRING(32767);
 sCount                 INTEGER := -1;
 staticString           STRING(32767);
 StringStart            INTEGER;
 PDC_Type               STRING(60);
 membersString          STRING(40);
 bufferNumber           INTEGER;
 numberOfBLOBs          INTEGER;
 
 --1. This retrieves  BLOBs used to paint Curam screens 
 cursor c_getBLOB is

          SELECT CDD.CREOLESNAPSHOTDATA FROM CREOLECASEDETERMINATIONDATA CDD, CREOLECASEDETERMINATION CD
                WHERE CDD.CREOLECASEDETERMINATIONDATAID = CD.DETERMINATIONRESULTDATAID /* Case Assessment */ AND CDD.CREOLECASEDETERMINATIONDATAID IN 
            (
            SELECT RULEOBJECTSNAPSHOTDATAID FROM CREOLECASEDETERMINATION WHERE  CASEID IN --          SELECT RULEOBJECTSNAPSHOTDATAID FROM CREOLECASEDETERMINATION WHERE ASSESSMENTSTATUS = 'CDAS1' AND CASEID IN 
            (SELECT CASEID FROM CASEHEADER WHERE /* STATUSCODE = 'CS1' AND */ INTEGRATEDCASEID IN (SELECT CASEID FROM CASEHEADER WHERE CASEREFERENCE = i_caseref))
        UNION 
            SELECT DETERMINATIONRESULTDATAID FROM CREOLECASEDETERMINATION WHERE  CASEID IN 
            (SELECT CASEID FROM CASEHEADER WHERE /* STATUSCODE = 'CS1' AND */ INTEGRATEDCASEID IN (SELECT CASEID FROM CASEHEADER WHERE CASEREFERENCE = i_caseref))
            );
/**************** Other tables containing BLOBs (START) ************************************
-- TABLES with BLOBs
SELECT * FROM APPCASEELIGIBILITYRESULTDATA;
SELECT * FROM APPRESOURCE;
SELECT * FROM ATTACHMENT;
SELECT * FROM BATCHPROCESS;
SELECT * FROM BATCHPROCESSCHUNK;
SELECT * FROM COMPACTSIMDETERMINATION;--0
SELECT * FROM CONCERNROLEIMAGE;
SELECT * FROM CREOLECASEPCRDATA;--0
SELECT * FROM CREOLEPRODUCTSANDBOX;--0
SELECT * FROM CREOLEPRODUCTSNAPSHOT;
SELECT * FROM CREOLEPROGRECOMMENDATIONDATA;--0
SELECT * FROM CREOLERULESET;
SELECT * FROM CREOLERULESETEDITACTION;--0
SELECT * FROM CREOLERULESETSNAPSHOT;
SELECT * FROM DOCUMENTTEMPLATE;
SELECT * FROM EXTERNALEVIDENCE;--0
SELECT * FROM GSSBATCHPROCESS;--0
SELECT * FROM GSSBATCHPROCESSCHUNK;--0
SELECT * FROM IEGEXECUTIONINFO;--0
SELECT * FROM RULEOBJECTPROPAGATORCONFIG;
SELECT * FROM RULEOBJPROPCONFIGSANDBOX;--0
SELECT * FROM RULEOBJPROPCONFIGSNAPSHOT;
SELECT * FROM TAXONOMYVERSION;--0
SELECT * FROM TAXONOMYVERSIONDATA;--0
SELECT * FROM WMCASEAUDITINSTANCEDATA;--0
**************** Other tables containing BLOBs (END) ************************************/

 BEGIN
  OPEN c_getBLOB;
  numberOfBLOBs := 0;
  LOOP
    FETCH c_getBLOB INTO l_compressed_blob;
    EXIT WHEN c_getBLOB%NOTFOUND;
    l_pos := 1;
    numberOfBLOBs := numberOfBLOBs + 1;
    IF NOT i_is_zipped THEN
      l_uncompressed_blob := l_compressed_blob;
    ELSE
      l_uncompressed_blob := UTL_COMPRESS.lz_uncompress (l_compressed_blob);
    END IF;
    l_blob_len := LENGTH(l_uncompressed_blob);
    bufferNumber := 0;
    dbms_output.put_line(crlf || '*********** For IC: '||  i_caseref || '(BLOB # ' || numberOfBLOBs || ') ******************');
    WHILE l_pos <= l_blob_len
    LOOP
      DBMS_LOB.read(l_uncompressed_blob, l_amount, l_pos, l_buffer);    
      l_blob_char :=  RAWTOHEX(l_buffer);
      l_blob_tmp := l_blob_char;
      l_blob_string := NULL;
      l_amount := 16383; /* Reset to max */
      BEGIN
        while length(l_blob_tmp)>0
        LOOP
          l_blob_string:=l_blob_string||chr(to_number(substr(l_blob_tmp,0,2),'xx') using NCHAR_CS);
          l_blob_tmp:=substr(l_blob_tmp,3);
        END LOOP;
      END;      
      bufferNumber := bufferNumber + 1;
      dbms_output.put_line('BLOB/Buffer # '|| numberOfBLOBs || '/' ||bufferNumber || ':' || crlf || l_blob_string); /* Prints out all the XML in the BLOB */
      l_blob_string := '';
      l_pos := l_pos + l_amount;
    END LOOP; /* WHILE l_pos <= l_blob_len */
  END LOOP; /* cursor c_getBLOB */
  CLOSE c_getBLOB;
EXCEPTION
   WHEN NO_DATA_FOUND THEN  -- catches all 'no data found' errors
    dbms_output.put_line('No data found for IC: '||i_caseref);
   END;
END;
/

/* Test Get_BLOBs_Only */
SET SERVEROUTPUT ON;
declare  
  i            INTEGER;
  type         IC_list_t is varray(300) of varchar2(10);
IC_list      IC_list_t := IC_list_t(
'4007941'--'4008452' --(4008452: Streamlined doesn't show up unless CDAS==> '%', but other 2 PDCs are duplicated)--'4003965'--'3965804'--'3972160'--'3114746'--'3971620'--'3971873'--'3114746'--'3933096' (No such IC)--'3167527', '3844113', '3893671', '3315181', '3933096'--'3969475'--3969441 (GrandChildrenVtGranny)--3969416 (CoupleVtDaughter)	--3969505--5 year bar -- BLOCKED	3965815--3965792 (CoupleVt2Children_1ChildLivingSeperately)	--3965849 (CoupleLivingSeperately_ChildoutOfDC)--3965804 (CoupleVtParents_ChildrenAndSiblings)	--3969407 (MotherVtDaughter) --3969407-(MotherVtDaughter) --3969363 (OneAdultVtChild)--3969373 (Couple_65plusAge_OneEarning) --3965764 (MotherVtChild) -- 3969399 (MotherVtMedicare_Daughter)
--'3114746'--'3965840'--'3965774'--'3965783'--'3965860'--'3965822'--'3917708' (Corrupt?)--'3931739' (Medicaid/UQHP in future)--'3931764' (APTC)--'3114746'--'3115210'--'2005014'--'3935587'--'2154282'--'3358826'--'3352177'
-- '3134891'--'2921639' -- USE FOR REGRESSION TESTING (PARTICIPANT IS ON THE BOUNDARY OF TWO BUFFERS - BLOB 1, buffers 1 and 2)
                                    );
BEGIN
  for i in 1..IC_list.count loop
    Get_BLOBs_Only (IC_list(i) , TRUE /* BLOB is zipped */); -- 3167527, 3844113, 3893671, 3315181, '3933096',
  end loop;
END;
/
