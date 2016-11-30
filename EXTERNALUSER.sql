select CR.CONCERNROLENAME from PERSON P, CONCERNROLE CR WHERE P.CONCERNROLEID = CR.CONCERNROLEID AND P.CREATEDON IS NOT NULL AND CR.CONCERNROLENAME = 'George8 Utdanp02' order by P.CREATEDON DESC; /* person */
SET SERVEROUTPUT ON;
exec dbms_output.enable(null);
DECLARE
  v_now DATE;
  latestTransactionDate DATE;
  newUserName VARCHAR2(40) := 'George10@dc.gov';
  roleName VARCHAR2(40) := 'George10 Utdanp02';
  OUT_STRING VARCHAR2(4000) := '';
  sleepTime number := 0.1; /* 0.1 * 9000 = 15 minutes */
  loopMax number := 90000; /* 9000 * 0.1 = 15 minutes */
  loopCount number := 0;
  n_selected number := 0;
 BEGIN
  SELECT SYSDATE INTO v_now FROM DUAL; 
dbms_output.put_line('v_now/SYSDATE=' || to_char(v_now,'yyyy/mm/dd:hh:mi:ss')||'/'||to_char(SYSDATE,'yyyy/mm/dd:hh:mi:ss'));
  WHILE loopCount < loopMax
  LOOP
      latestTransactionDate := SYSDATE;
      loopCount := loopCount + 1;
      BEGIN /* Check for existance of user */
/*       select unique EU.USERNAME AS User_Name, to_char(EU.CREATEDON,'yyyy/mm/dd:hh:mi:ss') AS EXTERNALUSER_CREATEDON, CR.CONCERNROLENAME AS ConcernRoleName, to_char(CR.CREATEDON,'yyyy/mm/dd:hh:mi:ss') AS CONCERNROLENAME_CREATEDON, 
                to_char(AN.CREATEDON,'yyyy/mm/dd:hh:mi:ss') AS ALTERNATENAME_CREATEDON, to_char(P.CREATEDON,'yyyy/mm/dd:hh:mi:ss') AS PERSON_CREATEDON, to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') AS INTAKEAPPLICATION_CREATEDON,
                to_char(A.SUBMITTEDDATETIME,'yyyy/mm/dd:hh:mi:ss') AS APPLICATIONCASE_SUBMITTEDDATETIME, to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') AS INTAKEAPPLICATION_CREATEDON, 
                to_char(C.CREATEDON,'yyyy/mm/dd:hh:mi:ss') AS CASEHEADER_CREATEDON */
       select unique EU.USERNAME || '|' || to_char(EU.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || CR.CONCERNROLENAME || '|' || to_char(CR.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' ||  
                to_char(AN.CREATEDON,'yyyy/mm/dd:hh:mi:ss')|| '|' ||  to_char(P.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || 
                to_char(A.SUBMITTEDDATETIME,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(C.CREATEDON,'yyyy/mm/dd:hh:mi:ss') INTO OUT_STRING 
          from EXTERNALUSER EU, APPLICATIONCASE A, CASEHEADER C, CONCERNROLE CR, ALTERNATENAME AN, PERSON P, INTAKEAPPLICATION IA
          where EU.FULLNAME = roleName AND A.APPLICATIONCASEID = C.CASEID AND CR.CONCERNROLEID = C.CONCERNROLEID AND AN.CONCERNROLEID = CR.CONCERNROLEID AND P.CONCERNROLEID = CR.CONCERNROLEID AND 
                IA.ENTEREDBYUSER = EU.USERNAME AND C.CASEID = A.APPLICATIONCASEID; /* application */
/**/
       --select unique CR.CONCERNROLENAME INTO roleName from APPLICATIONCASE A, CASEHEADER C, CONCERNROLE CR where A.APPLICATIONCASEID = C.CASEID AND CR.CONCERNROLEID = C.CONCERNROLEID AND CONCERNROLENAME = roleName; /* application */
        --select CR.CONCERNROLENAME INTO newUserName from PERSON P, CONCERNROLE CR WHERE P.CONCERNROLEID = CR.CONCERNROLEID AND P.CREATEDON IS NOT NULL AND CR.CONCERNROLENAME = roleName order by P.CREATEDON DESC; /* person */
        --select CREATEDON INTO latestTransactionDate FROM externaluser where USERNAME = newUserName;
--        dbms_output.put_line('After select: loopCount=' ||loopCount);
        dbms_lock.sleep(sleepTime);
--dbms_output.put_line('loopCount/latestTransactionDate=' || loopCount ||'/'||to_char(latestTransactionDate,'yyyy/mm/dd:hh:mi:ss'));
--dbms_output.put_line('sql%rowcount = ' || to_char(sql%rowcount));
        IF (sql%rowcount = 1) THEN BEGIN dbms_output.put_line('Found: roleName=' ||roleName); EXIT; END;
        ELSE dbms_output.put_line('Nothing Found'); END IF;
--        ELSE dbms_output.put_line('latestTransactionDate/userName=' || to_char(latestTransactionDate,'yyyy/mm/dd:hh:mi:ss')||'|'||newUserName); END IF;
        
        exception
          when NO_DATA_FOUND then
            dbms_output.put_line('No Data: loopCount/roleName=' || loopCount|| '/' ||roleName);
            CONTINUE;
            dbms_output.put_line('Caught raised exception NO_DATA_FOUND');
          when TOO_MANY_ROWS then
            n_selected := sql%rowcount;
            dbms_output.put_line('Caught raised exception TOO_MANY_ROWS: ' || n_selected);
      END; /* Check for existance of user */
    END LOOP;
dbms_output.put_line('v_now/SYSDATE=' || to_char(v_now,'yyyy/mm/dd:hh:mi:ss')||'/'||to_char(SYSDATE,'yyyy/mm/dd:hh:mi:ss'));
END;
/

       select EU.USERNAME || '|' || to_char(EU.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || CR.CONCERNROLENAME || '|' || to_char(CR.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' ||  
                to_char(AN.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' ||  to_char(P.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || 
                to_char(A.SUBMITTEDDATETIME,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(C.CREATEDON,'yyyy/mm/dd:hh:mi:ss')
          from EXTERNALUSER EU, APPLICATIONCASE A, CASEHEADER C, CONCERNROLE CR, ALTERNATENAME AN, PERSON P, INTAKEAPPLICATION IA
          where EU.USERNAME = 'George8@dc.gov' AND A.APPLICATIONCASEID = C.CASEID AND CR.CONCERNROLENAME = EU.FULLNAME AND C.CONCERNROLEID = CR.CONCERNROLEID AND AN.CONCERNROLEID = CR.CONCERNROLEID AND P.CONCERNROLEID = CR.CONCERNROLEID AND 
                IA.ENTEREDBYUSER = EU.USERNAME AND C.CASEID = A.APPLICATIONCASEID; /* application */
                
       select unique EU.USERNAME || '|' || to_char(EU.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || CR.CONCERNROLENAME || '|' || to_char(CR.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' ||  
                to_char(AN.CREATEDON,'yyyy/mm/dd:hh:mi:ss')|| '|' ||  to_char(P.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || 
                to_char(A.SUBMITTEDDATETIME,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(C.CREATEDON,'yyyy/mm/dd:hh:mi:ss') INTO OUT_STRING 
          from EXTERNALUSER EU, APPLICATIONCASE A, CASEHEADER C, CONCERNROLE CR, ALTERNATENAME AN, PERSON P, INTAKEAPPLICATION IA
          where EU.FULLNAME = 'George10 Utdanp02' AND A.APPLICATIONCASEID = C.CASEID AND CR.CONCERNROLEID = C.CONCERNROLEID AND AN.CONCERNROLEID = CR.CONCERNROLEID AND P.CONCERNROLEID = CR.CONCERNROLEID AND 
                IA.ENTEREDBYUSER = EU.USERNAME AND C.CASEID = A.APPLICATIONCASEID; /* application */

       select unique CR.CONCERNROLENAME || '|' || to_char(CR.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' ||  
                to_char(AN.CREATEDON,'yyyy/mm/dd:hh:mi:ss')|| '|' ||  to_char(P.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || 
                to_char(A.SUBMITTEDDATETIME,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(IA.CREATEDON,'yyyy/mm/dd:hh:mi:ss') || '|' || to_char(C.CREATEDON,'yyyy/mm/dd:hh:mi:ss') INTO OUT_STRING 
          from APPLICATIONCASE A, CASEHEADER C, CONCERNROLE CR, ALTERNATENAME AN, PERSON P, INTAKEAPPLICATION IA, INTAKEAPPCONCERNROLELINK AL
          where CR.CONCERNROLENAME = 'George10 Utdanp02' AND CR.CONCERNROLEID = C.CONCERNROLEID AND A.APPLICATIONCASEID = C.CASEID AND AN.CONCERNROLEID = CR.CONCERNROLEID AND P.CONCERNROLEID = CR.CONCERNROLEID AND
                IA.INTAKEAPPLICATIONID = AL.INTAKEAPPLICATIONID AND AL.CONCERNROLEID=CR.CONCERNROLEID;

                select * from DYNAMICEVIDENCEDATAATTRIBUTE where VALUE like '%George8%';
                --select * from DYNAMICEVIDENCEDATAATTRIBUTE where EVIDENCEID IN (;
                
                select NAME,VALUE,to_char(CREATEDON,'yyyy/mm/dd:hh:mi:ss') from DYNAMICEVIDENCEDATAATTRIBUTE where EVIDENCEID IN (
               '-3208120822405267456','8573295802795950080','-5189704658448285696','2703979588425351168','-37586684736438272','551258966542254080') ORDER BY CREATEDON;
               
                select * from DATASTOREENTITY where ENTITYVALUE like '%George8%';
                select to_char(LASTWRITTEN,'yyyy/mm/dd:hh:mi:ss'),ENTITYTYPE,ENTITYVALUE,OVERFLOWNEXTID from DATASTOREENTITY 
                where ENTITYID IN ('36214277','36214264','36214266','36214268','36214270','36214272','36214018','36214151','36214154','36214167','36214022','36214133','36214301')
                order by LASTWRITTEN;
