SET SERVEROUTPUT ON;
DECLARE
ROW_COUNT NUMBER;
BEGIN
    SELECT count(*) into ROW_COUNT FROM user_tables where table_name = 'CONFIG_TABLE';
    IF(ROW_COUNT > 0)
    THEN
        DBMS_OUTPUT.PUT_LINE('TABLE CONFIG_TABLE ALREADY EXISTS');
    ELSE
        EXECUTE IMMEDIATE 'CREATE TABLE CONFIG_TABLE
    (
       TABLE_NAME varchar2(50), 
       TABLE_DEF varchar2(1000) NOT NULL, 
       CONSTRAINT CONFIG_TABLE_PK PRIMARY KEY(TABLE_NAME)
    )
    ';    
     DBMS_OUTPUT.PUT_LINE('TABLE USERS CREATED SUCCESSFULLY');
     
     
     INSERT INTO CONFIG_TABLE VALUES ('USERS','CREATE TABLE USERS
            (
              USER_ID NUMBER(10)
            , PHONE NUMBER(10)
            , PWD VARCHAR2(10) NOT NULL 
            , EMERGENCY_CONTACT VARCHAR2(10) NOT NULL 
            , LOCATION_ID NUMBER(10) NOT NULL 
            , RISK_STATUS INT 
            , LAST_NAME VARCHAR2(10) 
            , FIRST_NAME VARCHAR2(10) NOT NULL 
            , DOB DATE NOT NULL 
            , JOIN_DATE DATE DEFAULT SYSDATE
            , GROUPS_ID NUMBER(10) DEFAULT 1 
            , EMAIL VARCHAR2(10) NOT NULL 
            ,  CONSTRAINT USERS_PK PRIMARY KEY(USER_ID)
            ,  CONSTRAINT EMAIL_VALIDATION CHECK(REGEXP_LIKE(EMAIL,''^[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$''))
            ,  CONSTRAINT PHONE_VALIDATION CHECK(REGEXP_LIKE(PHONE, ''^[0-9]{10}$''))
            ,  CONSTRAINT USERS_FK_LOCATION FOREIGN KEY (LOCATION_ID) REFERENCES LOCATION(LOCATION_ID)
            ,  CONSTRAINT USERS_FK_GROUPS FOREIGN KEY (GROUPS_ID) REFERENCES GROUPS(GROUPS_ID) 
            )
     ');
        
        
    INSERT INTO CONFIG_TABLE VALUES ('GROUPS','CREATE TABLE GROUPS
            (	
            GROUPS_ID NUMBER(10), 
            GROUPS_NAME VARCHAR2(20) NOT NULL, 
            GROUPS_DESCRIPTION VARCHAR2(20) NOT NULL,
             CONSTRAINT GROUPS_PK PRIMARY KEY(GROUPS_ID)
    )');
        
        
    INSERT INTO CONFIG_TABLE VALUES ('ROLES','CREATE TABLE ROLES
            (	
            ROLES_ID NUMBER(10), 
            ROLES_DESCRIPTION VARCHAR2(20) NOT NULL,
             CONSTRAINT ROLES_PK PRIMARY KEY(ROLES_ID)
    )');
        
    INSERT INTO CONFIG_TABLE VALUES ('GROUPS_ROLES','CREATE TABLE GROUPS_ROLES
            (
             GROUPS_ROLES_ID NUMBER(10), 
             GROUPS_ID NUMBER(10), 
             ROLES_ID NUMBER(10), 
             CONSTRAINT GROUPS_ROLES_PK PRIMARY KEY(GROUPS_ROLES_ID),
             CONSTRAINT GROUPS_ROLES_FK_GROUPS FOREIGN KEY (GROUPS_ID) REFERENCES GROUPS(GROUPS_ID) 
             CONSTRAINT GROUPS_ROLES_FK_ROLES FOREIGN KEY (ROLES_ID) REFERENCES ROLES(ROLES_ID) 
    )');
        
        
    INSERT INTO CONFIG_TABLE VALUES ('USER_LOGIN_AUDIT','CREATE TABLE USER_LOGIN_AUDIT
            (
             AUDIT_ID NUMBER(100), 
             USER_ID NUMBER(10),
             LOGIN_STATUS VARCHAR2(10) NOT NULL,
             AUDIT_DATE DATE NOT NULL,
             CONSTRAINT USER_LOGIN_AUDIT_PK PRIMARY KEY(AUDIT_ID),
             CONSTRAINT USER_LOGIN_AUDIT_FK_USERS FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID) ,
             CONSTRAINT USER_LOGIN_AUDIT_LOGIN_STATUS CHECK (LOGIN_STATUS IN ("login","logout")),
             CONSTRAINT USER_LOGIN_AUDIT_DATE CHECK (AUDIT_DATE <= SYSDATE),
    )');


    END IF;
END;
/

DECLARE
  CURSOR config_table_cur
  IS
    SELECT 
        *
    FROM 
        config_table;
        
    tab_name varchar2(50);
    tab_def varchar2(1000);
    row_count number(10):= 0;
BEGIN
  FOR i IN config_table_cur
  LOOP
      tab_name:= i.table_name;
      tab_def:= i.table_def;
      
      SELECT count(*) into row_count FROM user_tables where table_name = tab_name;
       IF(row_count > 0)
        THEN
            DBMS_OUTPUT.PUT_LINE('TABLE'||tab_name || 'ALREADY EXISTS');
        ELSE
            EXECUTE IMMEDIATE tab_def;
            dbms_output.put_line( 'TABLE '||tab_name || 'CREATED SUCCESSFULLY!' );
         END IF;
  END LOOP;
END;
/