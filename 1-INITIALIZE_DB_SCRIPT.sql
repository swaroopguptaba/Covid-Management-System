SET SERVEROUTPUT ON;


CREATE OR REPLACE PROCEDURE CREATE_CONFIG_TABLE AS
ROW_COUNT NUMBER(10);
BEGIN 
    SELECT count(*) into ROW_COUNT FROM user_tables where table_name = 'CONFIG_TABLE';
    IF(ROW_COUNT > 0)
    THEN
        DBMS_OUTPUT.PUT_LINE('TABLE CONFIG_TABLE ALREADY EXISTS');
    ELSE
        EXECUTE IMMEDIATE 'CREATE TABLE CONFIG_TABLE
    (
       TABLE_NAME varchar2(50), 
       TABLE_DEF varchar2(3000) NOT NULL, 
       CONSTRAINT CONFIG_TABLE_PK PRIMARY KEY(TABLE_NAME)
    )
    ';    
     DBMS_OUTPUT.PUT_LINE('TABLE CONFIG_TABLE CREATED SUCCESSFULLY');
    
    EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('LOCATION','CREATE TABLE LOCATION
            (	
            LOCATION_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
            CITY VARCHAR2(50) NOT NULL, 
            STATE VARCHAR2(50) NOT NULL,
            ZIPCODE NUMBER(10),
            CONSTRAINT LOCATION_PK PRIMARY KEY(LOCATION_ID)
            )
    ')]';
    
     EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('GROUPS','CREATE TABLE GROUPS
            (	
            GROUPS_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
            GROUPS_NAME VARCHAR2(20) NOT NULL, 
            GROUPS_DESCRIPTION VARCHAR2(100) NOT NULL,
            CONSTRAINT GROUPS_PK PRIMARY KEY(GROUPS_ID)
            )
    ')]';
    
      EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('ROLES','CREATE TABLE ROLES
            (	
            ROLES_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
            ROLES_DESCRIPTION VARCHAR2(100) NOT NULL,
            CONSTRAINT ROLES_PK PRIMARY KEY(ROLES_ID)
            )
    ')]';
    
    EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('USERS','CREATE TABLE USERS
            (
              USER_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY
            , PHONE NUMBER(10)
            , PWD VARCHAR2(20) NOT NULL 
            , EMERGENCY_CONTACT VARCHAR2(10) NOT NULL 
            , LOCATION_ID NUMBER(10) NOT NULL 
            , RISK_STATUS INT 
            , LAST_NAME VARCHAR2(10) 
            , FIRST_NAME VARCHAR2(10) NOT NULL 
            , DOB DATE NOT NULL 
            , JOIN_DATE DATE DEFAULT SYSDATE
            , GROUPS_ID NUMBER(10) DEFAULT 1 
            , EMAIL VARCHAR2(50) NOT NULL 
            ,  CONSTRAINT USERS_PK PRIMARY KEY(USER_ID)
            ,  CONSTRAINT EMAIL_VALIDATION CHECK(REGEXP_LIKE(EMAIL,''^[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$''))
            ,  CONSTRAINT PHONE_VALIDATION CHECK(REGEXP_LIKE(PHONE, ''^[0-9]{10}$''))
            ,  CONSTRAINT USERS_FK_LOCATION FOREIGN KEY (LOCATION_ID) REFERENCES LOCATION(LOCATION_ID)
            ,  CONSTRAINT USERS_FK_GROUPS FOREIGN KEY (GROUPS_ID) REFERENCES GROUPS(GROUPS_ID) 
            )
       ')]';
       
    EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('TEST_CENTER','CREATE TABLE TEST_CENTER
            (
             TEST_CENTER_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
             CENTER_NAME VARCHAR2(20) NOT NULL, 
             LOCATION_ID NUMBER(10) NOT NULL, 
             CENTER_HEAD NUMBER(10) NOT NULL, 
             CONSTRAINT TEST_CENTER_PK PRIMARY KEY(TEST_CENTER_ID),
             CONSTRAINT TEST_CENTER_FK_LOCATION FOREIGN KEY (LOCATION_ID) REFERENCES LOCATION(LOCATION_ID),
             CONSTRAINT TEST_CENTER_FK_USERS FOREIGN KEY (CENTER_HEAD) REFERENCES USERS(USER_ID) 
    )
    ')]';
	EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('SLOTS','CREATE TABLE SLOTS
            (
             SLOT_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
             SLOT_NAME VARCHAR2(50) NOT NULL, 
             SLOT_TIME TIMESTAMP NOT NULL, 
             SLOTS_AVAILABLE NUMBER(10) NOT NULL, 
             CONSTRAINT SLOTS_PK PRIMARY KEY(SLOT_ID)
    )
    ')]';
    EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('TEST_TYPE','CREATE TABLE TEST_TYPE
            (
             TEST_TYPE_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
             TEST_TYPE VARCHAR2(20) NOT NULL,
             CONSTRAINT TEST_TYPE_PK PRIMARY KEY(TEST_TYPE_ID)
    )
    ')]';
       EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('TEST_AVAILABILITY','CREATE TABLE TEST_AVAILABILITY
            (
             TEST_AVAILABILITY_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
             TEST_CENTER_ID NUMBER(10) NOT NULL, 
             SLOT_ID NUMBER(10) NOT NULL, 
             TEST_TYPE_ID NUMBER(10) NOT NULL, 
             CONSTRAINT TEST_AVAILABILITY_PK PRIMARY KEY(TEST_AVAILABILITY_ID),
             CONSTRAINT TEST_AVAILABILITY_FK_TEST_CENTER FOREIGN KEY (TEST_CENTER_ID) REFERENCES TEST_CENTER(TEST_CENTER_ID),
             CONSTRAINT TEST_AVAILABILITY_SLOTS FOREIGN KEY (SLOT_ID) REFERENCES SLOTS(SLOT_ID),
             CONSTRAINT TEST_AVAILABILITY_FK_TEST_TYPE FOREIGN KEY (TEST_TYPE_ID) REFERENCES TEST_TYPE(TEST_TYPE_ID)
        )
        ')]';
    EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('STAFF_TIMESHEET','CREATE TABLE STAFF_TIMESHEET
            (
             STAFF_TIMESHEET_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
             USER_ID NUMBER(10) NOT NULL, 
             TEST_CENTER_ID NUMBER(10) NOT NULL, 
         SLOT_ID NUMBER(10) NOT NULL, 
             CONSTRAINT STAFF_TIMESHEET_PK PRIMARY KEY(STAFF_TIMESHEET_ID),
    CONSTRAINT STAFF_TIMESHEET_FK_USERS FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID),
    CONSTRAINT STAFF_TIMESHEET_FK_TEST_CENTER FOREIGN KEY (TEST_CENTER_ID) REFERENCES TEST_CENTER(TEST_CENTER_ID),
        CONSTRAINT STAFF_TIMESHEET_FK_SLOTS FOREIGN KEY (SLOT_ID) REFERENCES SLOTS(SLOT_ID)
    )
    ')]';
    EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('QUARANTINE_FACILITY','CREATE TABLE QUARANTINE_FACILITY
            (
             QUARANTINE_FACILITY_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
             QUARANTINE_FACILITY_NAME VARCHAR2(50) NOT NULL, 
             ROOMS_AVAILABILITY NUMBER(10) NOT NULL, 
             DOCTOR_ID NUMBER(10) NOT NULL,
             LOCATION_ID NUMBER(10) NOT NULL, 
             CONSTRAINT QUARANTINE_FACILITY_PK PRIMARY KEY(QUARANTINE_FACILITY_ID),
             CONSTRAINT QUARANTINE_FACILITY_FK_DOCTOR_ID FOREIGN KEY (DOCTOR_ID) REFERENCES USERS(USER_ID),
             CONSTRAINT QUARANTINE_FACILITY_FK_LOCATION_ID FOREIGN KEY (LOCATION_ID) REFERENCES LOCATION(LOCATION_ID)
    )
    ')]';
        
    EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('QUARANTINED_PATIENT_DETAILS','CREATE TABLE QUARANTINED_PATIENT_DETAILS
            (
             QUARANTINED_PATIENT_DETAILS_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY,
            QUARANTINE_FACILITY_ID NUMBER(10) NOT NULL,  
             USER_ID NUMBER(20) NOT NULL, 
             JOIN_DATE DATE NOT NULL,
             CONSTRAINT QUARANTINED_PATIENT_DETAILS_PK PRIMARY KEY(QUARANTINED_PATIENT_DETAILS_ID),
            CONSTRAINT QUARANTINED_PATIENT_DETAILS_FK_FACILITY_ID FOREIGN KEY (QUARANTINE_FACILITY_ID) REFERENCES QUARANTINE_FACILITY(QUARANTINE_FACILITY_ID),
            CONSTRAINT QUARANTINED_PATIENT_DETAILS_FK_USER_ID FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
    )
    ')]';
    EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('TEST_SCHEDULE','CREATE TABLE TEST_SCHEDULE
            (
             TEST_SCHEDULE_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY,
             USER_ID NUMBER(10) NOT NULL,  
             TEST_DATE DATE NOT NULL, 
             TEST_SLOT_ID  NUMBER(10) NOT NULL,
            CENTER_ID NUMBER(10) NOT NULL,
            TEST_TYPE_ID NUMBER(10) NOT NULL,
            SCHEDULE_STATUS VARCHAR2(20) NOT NULL,
            TEST_RESULTS VARCHAR2(20),
             CONSTRAINT TEST_SCHEDULE_PK PRIMARY KEY(TEST_SCHEDULE_ID),
            CONSTRAINT TEST_SCHEDULE_FK_USER_ID FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID),
            CONSTRAINT TEST_SCHEDULE_FK_TEST_SLOT_ID FOREIGN KEY (TEST_SLOT_ID) REFERENCES SLOTS(SLOT_ID),
            CONSTRAINT TEST_SCHEDULE_FK_TEST_TYPE_ID FOREIGN KEY (TEST_TYPE_ID) REFERENCES TEST_TYPE(TEST_TYPE_ID)
    )
    ')]';
    
     EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('GROUPS_ROLES','CREATE TABLE GROUPS_ROLES
            (
             GROUPS_ROLES_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
             GROUPS_ID NUMBER(10), 
             ROLES_ID NUMBER(10), 
             CONSTRAINT GROUPS_ROLES_PK PRIMARY KEY(GROUPS_ROLES_ID),
             CONSTRAINT GROUPS_ROLES_FK_GROUPS FOREIGN KEY (GROUPS_ID) REFERENCES GROUPS(GROUPS_ID),
             CONSTRAINT GROUPS_ROLES_FK_ROLES FOREIGN KEY (ROLES_ID) REFERENCES ROLES(ROLES_ID) 
    )
    ')]';
       
       EXECUTE IMMEDIATE q'[INSERT INTO CONFIG_TABLE VALUES ('USER_LOGIN_AUDIT','CREATE TABLE USER_LOGIN_AUDIT
            (
             AUDIT_ID NUMBER(10) GENERATED BY DEFAULT AS IDENTITY, 
             USER_ID NUMBER(10),
             LOGIN_STATUS VARCHAR2(10) NOT NULL,
             AUDIT_DATE DATE NOT NULL,
             CONSTRAINT USER_LOGIN_AUDIT_PK PRIMARY KEY(AUDIT_ID),
             CONSTRAINT USER_LOGIN_AUDIT_FK_USERS FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID) ,
             CONSTRAINT USER_LOGIN_AUDIT_LOGIN_STATUS CHECK (LOGIN_STATUS IN (''login'',''logout''))
        )
      ')]';
         
    END IF;
END CREATE_CONFIG_TABLE;

EXEC CREATE_CONFIG_TABLE;

CREATE OR REPLACE PROCEDURE CREATE_TABLES AS
  CURSOR config_table_cur
  IS
    SELECT 
        *
    FROM 
        config_table;
        
    tab_name varchar2(50);
    tab_def varchar2(3000);
    row_count number(10):= 0;
BEGIN
  FOR i IN config_table_cur
  LOOP
      tab_name:= i.table_name;
      tab_def:= i.table_def;
      
      DBMS_OUTPUT.PUT_LINE('--------------------------');

      SELECT count(*) into row_count FROM user_tables where table_name = tab_name;
       IF(row_count > 0)
        THEN
            DBMS_OUTPUT.PUT_LINE('TABLE '|| tab_name || ' ALREADY EXISTS');
        ELSE
            DBMS_OUTPUT.PUT_LINE('--------------------------');  
            EXECUTE IMMEDIATE tab_def;
            dbms_output.put_line( 'TABLE '|| tab_name || ' CREATED SUCCESSFULLY!' );
         END IF;
  END LOOP;
  dbms_output.put_line( 'ALL TABLES CREATED');
END CREATE_TABLES;
/

EXEC CREATE_TABLES;

CREATE OR REPLACE PACKAGE INSERTIONS
AS
    PROCEDURE ADD_LOCATION(L_CITY IN VARCHAR2, L_STATE IN VARCHAR2, L_ZIPCODE IN NUMBER);
    PROCEDURE ADD_TEST_CENTER(L_CENTER_NAME IN VARCHAR2, L_LOCATION_ID IN NUMBER, L_CENTER_HEAD IN NUMBER);
    PROCEDURE ADD_GROUPS(L_GROUPS_NAME IN VARCHAR2, L_GROUPS_DESCRIPTION IN VARCHAR2);
    PROCEDURE ADD_ROLES(L_ROLES_DESCRIPTION IN VARCHAR2);
    PROCEDURE ADD_GROUP_ROLES(L_GROUPS_ID IN NUMBER, L_ROLES_ID IN NUMBER);
    PROCEDURE SIGNUP (user_f_name VARCHAR, user_l_name VARCHAR, user_dob DATE, user_email VARCHAR, user_pwd VARCHAR, 
        user_phone NUMBER, user_city VARCHAR, user_state VARCHAR, user_zip VARCHAR, user_emergency_contact  VARCHAR);
    PROCEDURE ADD_TEST_AVAILABILITY(L_TEST_CENTER_ID IN NUMBER, L_SLOTS_ID IN NUMBER, L_TEST_TYPE_ID IN NUMBER);
    PROCEDURE ADD_STAFF_TIMESHEET(L_USER_ID IN NUMBER, L_CENTER_ID IN NUMBER, L_SLOT_ID IN NUMBER);
    PROCEDURE ADD_QUARANTINE_FACILITY(L_QUARANTINE_FACILITY_NAME IN VARCHAR2, L_ROOMS_AVAILABILITY IN NUMBER, L_DOCTOR_ID IN NUMBER, L_LOCATION_ID IN NUMBER);
    PROCEDURE ADD_QUARANTINED_PATIENT_DETAILS(L_QUARANTINED_FACILITY_ID IN NUMBER, L_USER_ID IN NUMBER, L_JOIN_DATE IN DATE);
    PROCEDURE ADD_SLOTS(S_NAME IN VARCHAR2, S_TIME IN TIMESTAMP, S_AVAILABLE IN NUMBER);
    PROCEDURE ADD_TEST_TYPE(T_TEST_TYPE VARCHAR2);
    PROCEDURE ADD_USER_LOGIN_AUDIT(U_USER_ID IN NUMBER, U_LOGIN_STATUS IN VARCHAR2, U_AUDIT_DATE IN DATE);
    PROCEDURE ADD_TEST_SCHEDULE(TS_USER_ID IN NUMBER,TS_DATE DATE,TS_SLOT_ID NUMBER, TS_CENTER_ID NUMBER, TS_TEST_TYPE_ID NUMBER, TS_SCHEDULE_STATUS VARCHAR2);
    
END INSERTIONS;


CREATE OR REPLACE PACKAGE BODY INSERTIONS
AS
    PROCEDURE ADD_LOCATION(L_CITY IN VARCHAR2, L_STATE IN VARCHAR2, L_ZIPCODE IN NUMBER)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' || chr(39) || L_CITY || chr(39) || ' AS CITY, '  
                        || chr(39) || L_STATE || chr(39) || ' AS STATE, '  
                        || chr(39) || L_ZIPCODE || chr(39) || ' AS ZIPCODE '
                        || ' FROM DUAL)';
        MERGE_STMT_SQL:= 'MERGE INTO LOCATION L USING ' || USING_STMT 
        || 'TEMP ON (L.CITY = TEMP.CITY ) WHEN NOT MATCHED THEN INSERT (CITY, STATE, ZIPCODE) VALUES (TEMP.CITY, TEMP.STATE, TEMP.ZIPCODE)';
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        
    END ADD_LOCATION;
    
    
    PROCEDURE ADD_TEST_CENTER(L_CENTER_NAME IN VARCHAR2, L_LOCATION_ID IN NUMBER, L_CENTER_HEAD IN NUMBER)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' || chr(39) || L_CENTER_NAME || chr(39) || ' AS CENTER_NAME, '
                        || L_LOCATION_ID || ' AS LOCATION_ID, '
                        || L_CENTER_HEAD || ' AS CENTER_HEAD '
                        || ' FROM DUAL)';
    
        MERGE_STMT_SQL:= 'MERGE INTO TEST_CENTER TC USING ' || USING_STMT || 'TEMP ON (TC.CENTER_NAME =  TEMP.CENTER_NAME 
                   AND TC.LOCATION_ID =  TEMP.LOCATION_ID AND TC.CENTER_HEAD =  TEMP.CENTER_HEAD)
                            WHEN NOT MATCHED THEN INSERT (CENTER_NAME, LOCATION_ID, CENTER_HEAD) 
                           VALUES (TEMP.CENTER_NAME, TEMP.LOCATION_ID, TEMP.CENTER_HEAD)';
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
        
    END ADD_TEST_CENTER;
    
    
    PROCEDURE ADD_GROUPS(L_GROUPS_NAME IN VARCHAR2, L_GROUPS_DESCRIPTION IN VARCHAR2)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' 
                        || chr(39) || L_GROUPS_NAME || chr(39) || ' AS GROUPS_NAME, '
                        || chr(39) || L_GROUPS_DESCRIPTION || chr(39) || ' AS GROUPS_DESCRIPTION '
                        || ' FROM DUAL)';
    
        MERGE_STMT_SQL:= 'MERGE INTO GROUPS G USING ' || USING_STMT || 'TEMP ON (G.GROUPS_NAME =  TEMP.GROUPS_NAME 
                   AND G.GROUPS_DESCRIPTION =  TEMP.GROUPS_DESCRIPTION )
                    WHEN NOT MATCHED THEN INSERT (GROUPS_NAME,GROUPS_DESCRIPTION) 
                           VALUES (TEMP.GROUPS_NAME, TEMP.GROUPS_DESCRIPTION)';
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
        
    END ADD_GROUPS;
    
    PROCEDURE ADD_ROLES(L_ROLES_DESCRIPTION IN VARCHAR2)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' 
                        || chr(39) || L_ROLES_DESCRIPTION || chr(39) || ' AS ROLES_DESCRIPTION '
                        || ' FROM DUAL)';
    
        MERGE_STMT_SQL:= 'MERGE INTO ROLES R USING ' || USING_STMT || 'TEMP ON (
                   R.ROLES_DESCRIPTION =  TEMP.ROLES_DESCRIPTION )
                    WHEN NOT MATCHED THEN INSERT (ROLES_DESCRIPTION) 
                           VALUES (TEMP.ROLES_DESCRIPTION)';
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
        
    END ADD_ROLES;

    
    PROCEDURE ADD_GROUP_ROLES(L_GROUPS_ID IN NUMBER, L_ROLES_ID IN NUMBER)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' 
                        || L_GROUPS_ID || ' AS GROUPS_ID, '
                        || L_ROLES_ID || ' AS ROLES_ID '
                        || ' FROM DUAL)';
    
        MERGE_STMT_SQL:= 'MERGE INTO GROUPS_ROLES GR USING ' || USING_STMT || 'TEMP ON (GR.GROUPS_ID =  TEMP.GROUPS_ID 
                   AND GR.ROLES_ID =  TEMP.ROLES_ID )
                   WHEN NOT MATCHED THEN INSERT (GROUPS_ID, ROLES_ID) 
                           VALUES (TEMP.GROUPS_ID, TEMP.ROLES_ID)'; 
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
        
    END ADD_GROUP_ROLES;
    
    PROCEDURE ADD_QUARANTINE_FACILITY(L_QUARANTINE_FACILITY_NAME IN VARCHAR2, L_ROOMS_AVAILABILITY IN NUMBER, L_DOCTOR_ID IN NUMBER, L_LOCATION_ID IN NUMBER)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' || chr(39) || L_QUARANTINE_FACILITY_NAME || chr(39) || ' AS QUARANTINE_FACILITY_NAME, '  
                        || chr(39) || L_ROOMS_AVAILABILITY || chr(39) || ' AS ROOMS_AVAILABILITY, '  
                        || chr(39) || L_DOCTOR_ID || chr(39) || ' AS DOCTOR_ID, '
                        || L_LOCATION_ID || ' AS LOCATION_ID '
                        || ' FROM DUAL)';
        MERGE_STMT_SQL:= 'MERGE INTO QUARANTINE_FACILITY L USING ' || USING_STMT 
        || 'TEMP ON (L.QUARANTINE_FACILITY_NAME = TEMP.QUARANTINE_FACILITY_NAME ) 
        WHEN NOT MATCHED THEN
        INSERT (QUARANTINE_FACILITY_NAME, ROOMS_AVAILABILITY, DOCTOR_ID, LOCATION_ID) 
        VALUES (TEMP.QUARANTINE_FACILITY_NAME, TEMP.ROOMS_AVAILABILITY, TEMP.DOCTOR_ID, TEMP.LOCATION_ID)';
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        
    END ADD_QUARANTINE_FACILITY;
    
    PROCEDURE ADD_QUARANTINED_PATIENT_DETAILS(L_QUARANTINED_FACILITY_ID IN NUMBER, L_USER_ID IN NUMBER, L_JOIN_DATE IN DATE)
        AS
        MERGE_STMT_SQL VARCHAR2(500);
        USING_STMT VARCHAR2(500);
        BEGIN  
            USING_STMT:= '(SELECT ' || chr(39) || L_QUARANTINED_FACILITY_ID || chr(39) || ' AS QUARANTINE_FACILITY_ID, '  
                            || chr(39) || L_USER_ID || chr(39) || ' AS USER_ID, '  
                            || chr(39) || L_JOIN_DATE || chr(39) || ' AS JOIN_DATE '
                            || ' FROM DUAL)';
            MERGE_STMT_SQL:= 'MERGE INTO QUARANTINED_PATIENT_DETAILS L USING ' || USING_STMT 
            || 'TEMP ON (L.QUARANTINE_FACILITY_ID = TEMP.QUARANTINE_FACILITY_ID ) 
            WHEN NOT MATCHED THEN INSERT (QUARANTINE_FACILITY_ID, USER_ID, JOIN_DATE) VALUES (TEMP.QUARANTINE_FACILITY_ID, TEMP.USER_ID, TEMP.JOIN_DATE)';
            EXECUTE IMMEDIATE MERGE_STMT_SQL;
            COMMIT;
            
        END ADD_QUARANTINED_PATIENT_DETAILS;
        
    PROCEDURE ADD_SLOTS(S_NAME IN VARCHAR2, S_TIME IN TIMESTAMP, S_AVAILABLE IN NUMBER)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' || chr(39) || S_NAME || chr(39) || ' AS SLOT_NAME, '
                        || chr(39) || S_TIME || chr(39) || ' AS SLOT_TIME, '
                        || S_AVAILABLE || ' AS SLOTS_AVAILABLE '
                        || ' FROM DUAL)';
        DBMS_OUTPUT.PUT_LINE(USING_STMT); 
    
        MERGE_STMT_SQL:= 'MERGE INTO SLOTS S USING ' || USING_STMT || 'TEMP ON (S.SLOT_NAME =  TEMP.SLOT_NAME 
                   AND S.SLOT_TIME =  TEMP.SLOT_TIME AND S.SLOTS_AVAILABLE =  TEMP.SLOTS_AVAILABLE)
                            WHEN NOT MATCHED THEN INSERT (SLOT_NAME, SLOT_TIME, SLOTS_AVAILABLE) 
                           VALUES (TEMP.SLOT_NAME, TEMP.SLOT_TIME, TEMP.SLOTS_AVAILABLE)';
        DBMS_OUTPUT.PUT_LINE(MERGE_STMT_SQL); 
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
    END ADD_SLOTS;
    
    PROCEDURE ADD_TEST_TYPE(T_TEST_TYPE VARCHAR2)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' || chr(39) || T_TEST_TYPE || chr(39) || ' AS TEST_TYPE '
                        || ' FROM DUAL)';
        DBMS_OUTPUT.PUT_LINE(USING_STMT); 
    
        MERGE_STMT_SQL:= 'MERGE INTO TEST_TYPE T USING ' || USING_STMT || 'TEMP ON (T.TEST_TYPE =  TEMP.TEST_TYPE)
                            WHEN NOT MATCHED THEN INSERT (TEST_TYPE) 
                           VALUES (TEMP.TEST_TYPE)';
        DBMS_OUTPUT.PUT_LINE(MERGE_STMT_SQL); 
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
    END ADD_TEST_TYPE;
    
    
    PROCEDURE ADD_USER_LOGIN_AUDIT(U_USER_ID IN NUMBER, U_LOGIN_STATUS IN VARCHAR2, U_AUDIT_DATE IN DATE)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' || U_USER_ID || ' AS USER_ID, '
                        || chr(39) || U_LOGIN_STATUS || chr(39) || ' AS LOGIN_STATUS, ' || chr(39) 
                        || U_AUDIT_DATE || chr(39) || ' AS AUDIT_DATE '
                        || ' FROM DUAL)';
        DBMS_OUTPUT.PUT_LINE(USING_STMT); 
    
        MERGE_STMT_SQL:= 'MERGE INTO USER_LOGIN_AUDIT U USING ' || USING_STMT || 'TEMP ON (U.USER_ID =  TEMP.USER_ID 
                   AND U.LOGIN_STATUS =  TEMP.LOGIN_STATUS AND U.AUDIT_DATE =  TEMP.AUDIT_DATE)
                            WHEN NOT MATCHED THEN INSERT (USER_ID, LOGIN_STATUS, AUDIT_DATE) 
                           VALUES (TEMP.USER_ID, TEMP.LOGIN_STATUS, TEMP.AUDIT_DATE)';
        DBMS_OUTPUT.PUT_LINE(USING_STMT); 
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
    END ADD_USER_LOGIN_AUDIT;
    
    
    PROCEDURE ADD_TEST_SCHEDULE(TS_USER_ID IN NUMBER,TS_DATE DATE,TS_SLOT_ID NUMBER, TS_CENTER_ID NUMBER, TS_TEST_TYPE_ID NUMBER, TS_SCHEDULE_STATUS VARCHAR2)
    AS
    MERGE_STMT_SQL VARCHAR2(1000);
    USING_STMT VARCHAR2(1000);
    BEGIN  
        USING_STMT:= '(SELECT ' || TS_USER_ID || ' AS USER_ID, '||chr(39) ||TS_DATE ||chr(39)|| ' AS TEST_DATE,'
                        || TS_SLOT_ID ||' AS TEST_SLOT_ID, ' 
                        || TS_CENTER_ID || ' AS CENTER_ID,' || TS_TEST_TYPE_ID || ' AS TEST_TYPE_ID,'
                        || chr(39) || TS_SCHEDULE_STATUS || chr(39) || ' AS SCHEDULE_STATUS ' || 'FROM DUAL)';
        DBMS_OUTPUT.PUT_LINE(USING_STMT); 
    
        MERGE_STMT_SQL:= 'MERGE INTO TEST_SCHEDULE TS USING ' || USING_STMT || 'TEMP ON (TS.USER_ID =  TEMP.USER_ID 
                   AND TS.TEST_DATE =  TEMP.TEST_DATE AND TS.TEST_SLOT_ID =  TEMP.TEST_SLOT_ID AND TS.CENTER_ID = TEMP.CENTER_ID 
                   AND TS.TEST_TYPE_ID = TEMP.TEST_TYPE_ID AND TS.SCHEDULE_STATUS =TEMP.SCHEDULE_STATUS)
                            WHEN NOT MATCHED THEN INSERT (USER_ID, TEST_DATE,TEST_SLOT_ID, CENTER_ID,TEST_TYPE_ID, SCHEDULE_STATUS) 
                           VALUES (TEMP.USER_ID, TEMP.TEST_DATE, TEMP.TEST_SLOT_ID, TEMP.CENTER_ID, TEMP.TEST_TYPE_ID, TEMP.SCHEDULE_STATUS )';
        DBMS_OUTPUT.PUT_LINE(USING_STMT); 
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
    END ADD_TEST_SCHEDULE;

    PROCEDURE SIGNUP (user_f_name VARCHAR, user_l_name VARCHAR, user_dob DATE, user_email VARCHAR, user_pwd VARCHAR, 
        user_phone NUMBER, user_city VARCHAR, user_state VARCHAR, user_zip VARCHAR, user_emergency_contact  VARCHAR)
    AS
        user_id NUMBER;
        ncount  NUMBER := 0;
        loc_id  NUMBER(10):= 0;
        test_results_view_sql VARCHAR(1000 char);
    
    BEGIN
        SELECT
            COUNT(*)
        INTO ncount
        FROM
            users
        WHERE
            email = user_email;
    
    IF ( ncount > 0 ) THEN
        dbms_output.put_line('User already exists.. If you are the user, then connect with your credentials and execute ALL_ACTIONS to see all availale actions.');
    ELSE
    
        begin 
        SELECT
            location_id
        INTO loc_id
        FROM
            location
        WHERE
            city = UPPER(user_city)
            AND state = UPPER(user_state)
            AND zipcode= user_zip;
        EXCEPTION
            WHEN no_data_found THEN
            dbms_output.put_line('LOCATION NOT FOUND');
        END ;
            INSERT INTO admin.USERS ( PHONE , PWD ,EMERGENCY_CONTACT, LOCATION_ID, LAST_NAME, FIRST_NAME , DOB , JOIN_DATE, EMAIL) VALUES 
            (user_phone, user_pwd, user_emergency_contact,loc_id, user_l_name, user_f_name, user_dob, sysdate, user_email );
        
    END IF;
    COMMIT ;
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('ENCOUNTERED ERROR - ' || SQLERRM);
    END SIGNUP;
    
    PROCEDURE ADD_TEST_AVAILABILITY(L_TEST_CENTER_ID IN NUMBER, L_SLOTS_ID IN NUMBER, L_TEST_TYPE_ID IN NUMBER)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' 
                        || L_TEST_CENTER_ID || ' AS TEST_CENTER_ID, '
                        || L_SLOTS_ID || ' AS SLOT_ID, '
                        || L_TEST_TYPE_ID || ' AS TEST_TYPE_ID '
                        || ' FROM DUAL)';
        DBMS_OUTPUT.PUT_LINE(USING_STMT);
        MERGE_STMT_SQL:= 'MERGE INTO TEST_AVAILABILITY TA USING ' || USING_STMT || 'TEMP ON (TA.TEST_CENTER_ID =  TEMP.TEST_CENTER_ID 
                   AND TA.SLOT_ID =  TEMP.SLOT_ID AND TA.TEST_TYPE_ID =  TEMP.TEST_TYPE_ID)
                   WHEN NOT MATCHED THEN INSERT (TEST_CENTER_ID, SLOT_ID, TEST_TYPE_ID) 
                           VALUES (TEMP.TEST_CENTER_ID, TEMP.SLOT_ID, TEMP.TEST_TYPE_ID)'; 
        DBMS_OUTPUT.PUT_LINE(MERGE_STMT_SQL);
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
            
     END ADD_TEST_AVAILABILITY;
     
    PROCEDURE ADD_STAFF_TIMESHEET(L_USER_ID IN NUMBER, L_CENTER_ID IN NUMBER, L_SLOT_ID IN NUMBER)
    AS
    MERGE_STMT_SQL VARCHAR2(500);
    USING_STMT VARCHAR2(500);
    BEGIN  
        USING_STMT:= '(SELECT ' 
                        || L_USER_ID || ' AS USER_ID, '
                        || L_CENTER_ID || ' AS TEST_CENTER_ID, '
                        || L_SLOT_ID || ' AS SLOT_ID '
                        || ' FROM DUAL)';
    
        MERGE_STMT_SQL:= 'MERGE INTO STAFF_TIMESHEET ST USING ' || USING_STMT || 'TEMP ON (ST.USER_ID =  TEMP.USER_ID 
                   AND ST.TEST_CENTER_ID =  TEMP.TEST_CENTER_ID AND ST.SLOT_ID =  TEMP.SLOT_ID)
                   WHEN NOT MATCHED THEN INSERT (USER_ID, TEST_CENTER_ID, SLOT_ID) 
                           VALUES (TEMP.USER_ID, TEMP.TEST_CENTER_ID, TEMP.SLOT_ID)'; 
        EXECUTE IMMEDIATE MERGE_STMT_SQL;
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
            
     END ADD_STAFF_TIMESHEET;
END INSERTIONS;


------------POPULATE LOCATION TABLE -------------
EXEC INSERTIONS.ADD_LOCATION('BOSTON','MA',02215);
EXEC INSERTIONS.ADD_LOCATION('NEW YORK','NY',10001);
EXEC INSERTIONS.ADD_LOCATION('CAMBRIDGE','MA',02114);
EXEC INSERTIONS.ADD_LOCATION('LOWELL','MA',01850);
EXEC INSERTIONS.ADD_LOCATION('SAN JOSE','CA',95119);
EXEC INSERTIONS.ADD_LOCATION('SAN FRANCISCO','CA',94105);
EXEC INSERTIONS.ADD_LOCATION('LOS ANGELES','CA',90001);

------------POPULATE GROUP TABLE -------------
EXEC insertions.add_groups('USERS','Can access USERS AND test availability table');
EXEC insertions.add_groups('STAFF','Can access staff timesheet');
EXEC insertions.add_groups('CENTER_HEAD','Can access test schedule,test center and staff timesheet');
EXEC insertions.add_groups('DOCTOR','Can access quarantine facitlity and quarentined patient details');
EXEC insertions.add_groups('ADMIN','Manages all tables');


------------POPULATE ROLES TABLE -------------
EXEC insertions.add_roles('Select test availibility');
EXEC insertions.add_roles('Select staff timesheet');
EXEC insertions.add_roles('Select staff timesheet, test schedule,test center');
EXEC insertions.add_roles('Select quarantine facitlity, quarentined patient details');
EXEC insertions.add_roles('Select all tables');

------------POPULATE USERS TABLE -------------

EXEC INSERTIONS.SIGNUP('SWAROOP' , 'GUPTA', TO_DATE('12-NOV-1994', 'DD-MON-YY'), 'BA.SWAROOP@GMAIL.COM', 'Mypwd@123456789',6178589411, 'SAN JOSE', 'CA', 95119, 'PALANI');
EXEC INSERTIONS.SIGNUP('SHREYAS' , 'RAMESH', TO_DATE('17-NOV-1996', 'DD-MON-YY'), 'SHREYAS@GMAIL.COM', 'Mypwd@123456789',6174601757, 'BOSTON', 'MA', 02215, 'PALANI');
EXEC INSERTIONS.SIGNUP('APOORVA' , 'K', TO_DATE('1-JAN-1997', 'DD-MON-YY'), 'APOORVA@GMAIL.COM', 'Mypwd@123456789',6171234560, 'NEW YORK', 'NY', 10001, 'PALANI');

------------POPULATE TEST CENTER TABLE -------------
EXEC INSERTIONS.ADD_TEST_CENTER('SAINT MARY',1,1);
EXEC INSERTIONS.ADD_TEST_CENTER('AFC URGENT CARE',2,2);
EXEC INSERTIONS.ADD_TEST_CENTER('CAREWELL URGENT CARE',3,3);
EXEC INSERTIONS.ADD_TEST_CENTER('RITE AID',4,1);
EXEC INSERTIONS.ADD_TEST_CENTER('TILTON VA CLINIC',5,2);
EXEC INSERTIONS.ADD_TEST_CENTER('CVS',6,3);

-------POPULATE SLOTS---------------
EXECUTE INSERTIONS.ADD_SLOTS('MORNING', TO_TIMESTAMP('28-APR-21 09', 'DD-MON-YY HH24'),10);
EXECUTE INSERTIONS.ADD_SLOTS('MORNING', TO_TIMESTAMP('28-APR-21 10', 'DD-MON-YY HH24'),10);
EXECUTE INSERTIONS.ADD_SLOTS('MORNING', TO_TIMESTAMP('28-APR-21 11', 'DD-MON-YY HH24'),10);
EXECUTE INSERTIONS.ADD_SLOTS('AFTERNOON', TO_TIMESTAMP('28-APR-21 12', 'DD-MON-YY HH24'),10);
EXECUTE INSERTIONS.ADD_SLOTS('AFTERNOON', TO_TIMESTAMP('28-APR-21 14', 'DD-MON-YY HH24'),10);
EXECUTE INSERTIONS.ADD_SLOTS('AFTERNOON', TO_TIMESTAMP('28-APR-21 15', 'DD-MON-YY HH24'),10);
EXECUTE INSERTIONS.ADD_SLOTS('EVENING', TO_TIMESTAMP('28-APR-21 16', 'DD-MON-YY HH24'),10);
EXECUTE INSERTIONS.ADD_SLOTS('EVENING', TO_TIMESTAMP('28-APR-21 17', 'DD-MON-YY HH24'),10);
EXECUTE INSERTIONS.ADD_SLOTS('EVENING', TO_TIMESTAMP('28-APR-21 18', 'DD-MON-YY HH24'),10);


------------POPULATE TEST TYPE TABLE -------------
EXEC INSERTIONS.ADD_TEST_TYPE ('COVID - PCR');
EXEC INSERTIONS.ADD_TEST_TYPE ('COVID - RT PCR');
EXEC INSERTIONS.ADD_TEST_TYPE ('COVID - ANTIGEN');

------------POPULATE TEST_AVAILABILITY TABLE -------------
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(1, 1, 1);
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(1, 2, 1);
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(1, 3, 1);
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(1, 4, 1);
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(1, 5, 1);
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(1, 6, 1);
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(2, 7, 1);
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(2, 8, 1);
EXEC INSERTIONS.ADD_TEST_AVAILABILITY(2, 9, 1);

------------POPULATE STAFF TIMESHEET TABLE -------------
EXEC INSERTIONS.ADD_STAFF_TIMESHEET(1, 1, 1);
EXEC INSERTIONS.ADD_STAFF_TIMESHEET(1, 1, 2);
EXEC INSERTIONS.ADD_STAFF_TIMESHEET(2, 2, 1);
EXEC INSERTIONS.ADD_STAFF_TIMESHEET(2, 2, 1);

------------POPULATE QUARANTINE FACILITY--------------------
EXEC INSERTIONS.ADD_QUARANTINE_FACILITY('Boston Quarantine Station',20,1,1);
EXEC INSERTIONS.ADD_QUARANTINE_FACILITY('CHA Cambridge Hospital',20,2,2);
EXEC INSERTIONS.ADD_QUARANTINE_FACILITY('Baltimore Isolation Center',20,3,3);

------POPULATE QUARANTINED PATIENT DETAILS----------------------

EXEC INSERTIONS.ADD_QUARANTINED_PATIENT_DETAILS(1,1,sysdate+2);
EXEC INSERTIONS.ADD_QUARANTINED_PATIENT_DETAILS(1,2,sysdate+3);
EXEC INSERTIONS.ADD_QUARANTINED_PATIENT_DETAILS(2,3,sysdate+4);

------------POPULATE GROUP ROLES TABLE -------------
EXEC insertions.add_group_roles(1,1);
EXEC insertions.add_group_roles(2,2);
EXEC insertions.add_group_roles(3,3);
EXEC insertions.add_group_roles(4,4);
EXEC insertions.add_group_roles(5,5);

---------POPULATE TEST SCHEDULE-------------
EXEC INSERTIONS.ADD_TEST_SCHEDULE(1,sysdate,1,1,1,'scheduled');
EXEC INSERTIONS.ADD_TEST_SCHEDULE(2,sysdate,2,1,1,'scheduled');
EXEC INSERTIONS.ADD_TEST_SCHEDULE(3,sysdate,3,2,2,'scheduled');
EXEC INSERTIONS.ADD_TEST_SCHEDULE(1,sysdate,4,2,1,'scheduled');
EXEC INSERTIONS.ADD_TEST_SCHEDULE(2,sysdate,5,3,2,'scheduled');
EXEC INSERTIONS.ADD_TEST_SCHEDULE(3,sysdate,6,4,1,'scheduled');
   
--------POPULATE USER_LOGIN_AUDIT------------------
EXEC INSERTIONS.ADD_USER_LOGIN_AUDIT(1,'login',sysdate);
EXEC INSERTIONS.ADD_USER_LOGIN_AUDIT(2,'login',sysdate);
EXEC INSERTIONS.ADD_USER_LOGIN_AUDIT(3,'login',sysdate);
EXEC INSERTIONS.ADD_USER_LOGIN_AUDIT(1,'logout',sysdate);
EXEC INSERTIONS.ADD_USER_LOGIN_AUDIT(2,'logout',sysdate);
EXEC INSERTIONS.ADD_USER_LOGIN_AUDIT(3,'logout',sysdate);
    
---------------------------------------------------------VIEWS-------------------------------------------------
 CREATE OR REPLACE VIEW VIEW_QUARANTINE_FACILITY_DETAILS  AS
    SELECT
        QUARANTINE_FACILITY_NAME,
        ROOMS_AVAILABILITY,
        city,
        state,
        zipcode
    FROM
             quarantine_facility qf
        INNER JOIN location l ON qf.location_id = l.location_id;

CREATE OR REPLACE VIEW VIEW_TEST_AVAILABILITY  AS
    SELECT
    tc.center_name,
    slot_name,
    slot_time,
    slots_available,
    tt.test_type
FROM
    test_center tc
    INNER JOIN test_availability  ta ON tc.test_center_id = ta.test_center_id
    INNER JOIN slots             s ON ta.slot_id = s.slot_id
    INNER JOIN test_type         tt ON ta.test_type_id = tt.test_type_id
WHERE
        s.slots_available > 0
    AND s.slot_time > sysdate
GROUP BY
    tc.center_name, 
    slot_time,
    slot_name,
    slots_available,
    tt.test_type
ORDER BY
    tc.center_name ASC;


 CREATE OR REPLACE FORCE EDITIONABLE VIEW TEST_CENTER_HEAD_VIEW 
  AS
    SELECT
        tc.center_name,
        pu.first_name || pu.last_name AS "Name",
        pu.user_id
    FROM
             test_center tc
        JOIN users          u ON tc.center_head = u.user_id
        JOIN users          pu ON tc.center_head != pu.user_id
        JOIN test_schedule  ts ON pu.user_id = ts.user_id
                                 AND ts.center_id = tc.center_id
        JOIN test_type      tp ON tp.test_type_id = ts.test_type_id
        JOIN slots          s ON ts.test_slot_id = s.slot_id
    WHERE
        tc.center_head = 1;


 CREATE OR REPLACE VIEW QUARANTINE_FACILITY_HEAD_VIEW
 AS 
            select 
            qf.QUARANTINE_FACILITY_NAME, pu.first_name || pu.last_name AS "Name", pu.user_id, (sysdate - pu.join_date) AS "NO OF DAYS IN QUARANTINE"
            from quarantine_facility qf
            join quarantined_patient_details qp on qf.QUARANTINE_FACILITY_ID = qp.QUARANTINE_FACILITY_ID
            join users u on qf.doctor_id = u.user_id
            join users pu on qp.user_id = pu.user_id
            where  qf.doctor_id = 2;
            
