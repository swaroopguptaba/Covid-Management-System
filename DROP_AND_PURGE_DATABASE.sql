SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE DROP_TABLES AS
  CURSOR config_table_cur
  IS
    SELECT 
        *
    FROM 
        config_table;
        
    tab_name varchar2(50);
    drop_sql varchar2(100);
    row_count number(10):= 0;
BEGIN
  FOR i IN config_table_cur
  LOOP
      tab_name:= i.table_name;  
      DBMS_OUTPUT.PUT_LINE('--------------------------');

      SELECT count(*) into row_count FROM user_tables where table_name = tab_name;
       IF(row_count > 0)
        THEN
            drop_sql:= 'DROP TABLE ' || tab_name || ' CASCADE CONSTRAINTS PURGE'; 
            EXECUTE IMMEDIATE drop_sql;
            DBMS_OUTPUT.PUT_LINE('TABLE '|| tab_name || ' DROPPED');
         END IF;
  END LOOP;
  EXECUTE IMMEDIATE 'DROP TABLE CONFIG_TABLE';
  dbms_output.put_line( 'ALL TABLES DROPPED AND PURGED');
END DROP_TABLES;
/


EXEC DROP_TABLES;

CREATE OR REPLACE PROCEDURE DROP_USER_DEFINED_OBJECTS
AS


