--1.1
SELECT /*+PARALLEL (A,16)*/
 COUNT(DISTINCT A.MSISDN)
  FROM (SELECT A.MSISDN, SUM(PV)
          FROM PAGEVISIT A, USER_INFO B
         WHERE A.RECORD_DAY BETWEEN '20171001' AND '20171007'
           AND A.MSISDN = B.MSISDN
           AND B.SEX = 'ÄÐ'
         GROUP BY A.MSISDN
        HAVING SUM(PV) > 100) A;

--1.2
SELECT /*+PARALLEL (A,16)*/
DISTINCT A.MSISDN
  FROM (SELECT A.MSISDN,
               MAX(A.MARK1) || MAX(A.MARK2) || MAX(A.MARK3) || MAX(A.MARK4) ||
               MAX(A.MARK5) || MAX(A.MARK6) || MAX(A.MARK7) MARK
          FROM (SELECT DISTINCT A.MSISDN,
                                '1' MARK1,
                                '0' MARK2,
                                '0' MARK3,
                                '0' MARK4,
                                '0' MARK5,
                                '0' MARK6,
                                '0' MARK7
                  FROM PAGEVISIT A
                 WHERE A.RECORD_DAY = '20171001'
                UNION ALL
                SELECT DISTINCT A.MSISDN,
                                '0' MARK1,
                                '1' MARK2,
                                '0' MARK3,
                                '0' MARK4,
                                '0' MARK5,
                                '0' MARK6,
                                '0' MARK7
                  FROM PAGEVISIT A
                 WHERE A.RECORD_DAY = '20171002'
                UNION ALL
                SELECT DISTINCT A.MSISDN,
                                '0' MARK1,
                                '0' MARK2,
                                '1' MARK3,
                                '0' MARK4,
                                '0' MARK5,
                                '0' MARK6,
                                '0' MARK7
                  FROM PAGEVISIT A
                 WHERE A.RECORD_DAY = '20171003'
                UNION ALL
                SELECT DISTINCT A.MSISDN,
                                '0' MARK1,
                                '0' MARK2,
                                '0' MARK3,
                                '1' MARK4,
                                '0' MARK5,
                                '0' MARK6,
                                '0' MARK7
                  FROM PAGEVISIT A
                 WHERE A.RECORD_DAY = '20171004'
                UNION ALL
                SELECT DISTINCT A.MSISDN,
                                '0' MARK1,
                                '0' MARK2,
                                '0' MARK3,
                                '0' MARK4,
                                '1' MARK5,
                                '0' MARK6,
                                '0' MARK7
                  FROM PAGEVISIT A
                 WHERE A.RECORD_DAY = '20171005'
                UNION ALL
                SELECT DISTINCT A.MSISDN,
                                '0' MARK1,
                                '0' MARK2,
                                '0' MARK3,
                                '0' MARK4,
                                '0' MARK5,
                                '1' MARK6,
                                '0' MARK7
                  FROM PAGEVISIT A
                 WHERE A.RECORD_DAY = '20171006'
                UNION ALL
                SELECT DISTINCT A.MSISDN,
                                '0' MARK1,
                                '0' MARK2,
                                '0' MARK3,
                                '0' MARK4,
                                '0' MARK5,
                                '0' MARK6,
                                '1' MARK7
                  FROM PAGEVISIT A
                 WHERE A.RECORD_DAY = '20171007') A
         GROUP BY A.MSISDN) A
 WHERE INSTR(MARK, '111') > 0;

--2
SELECT /*+PARALLEL (A,16)*/
 A.DEPT_NAME, A.NAME, A.SALARY
  FROM (SELECT B.DEPT_NAME,
               A.NAME,
               A.SALARY,
               DENSE_RANK() OVER(PARTITION BY B.DEPT_NAME ORDER BY A.SALARY DESC) RN
          FROM EMPLOYEE A, DEPARTMENT B
         WHERE A.DEPARTMENTID = B.DEPARTMENTID) A
 WHERE A.RN <= 3;

--3
SELECT /*+PARALLEL (A,16)*/
 A.REQUEST_AT, ROUND(A.CANCELLED_CNT / A.TOTAL_CNT, 2) CANCELLATION_RATE
  FROM (SELECT A.REQUEST_AT,
               COUNT(*) TOTAL_CNT,
               COUNT(CASE
                       WHEN UPPER(A.STATUS) <> 'COMPLETED' THEN
                        A.ID
                       ELSE
                        NULL
                     END) CANCELLED_CNT
          FROM TRIPS A,
               (SELECT *
                  FROM USERS B
                 WHERE UPPER(B.BANNED) = 'NO'
                   AND UPPER(B.ROLE) = 'CLIENT') B,
               (SELECT *
                  FROM USERS B
                 WHERE UPPER(B.BANNED) = 'NO'
                   AND UPPER(B.ROLE) = 'DRIVER') C
         WHERE REPLACE(A.REQUEST_AT, '-', '') BETWEEN '20131001' AND '20131003'
           AND A.CLIENT_ID = B.USERS_ID
           AND A.DRIVER_ID = C.USERS_ID
         GROUP BY A.REQUEST_AT) A;
