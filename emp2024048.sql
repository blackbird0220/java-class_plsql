drop table emp;

-- 사원(emp) 테이블 생성
create table emp (eno number primary key, ename varchar(20) not null, pno number not null, pos varchar(100), pcode varchar(7) not null, addr varchar(100), salary number, bonus number, regdate timestamp not null, gender number not null);
-- int와 number: number는 자릿수 제한 가능
alter table emp add (superior int, tel varchar(13));
select * from emp; 


alter table emp modify salary invisible;
alter table emp modify bonus invisible;
alter table emp modify regdate invisible;
alter table emp modify gender invisible;
alter table emp modify superior invisible;

alter table emp modify salary visible;
alter table emp modify bonus visible;
alter table emp modify regdate visible;
alter table emp modify gender visible;
alter table emp modify superior visible;


insert into emp values (2001, '수민', 10, '부장', '125-365', '서울 용산구', '02-985-1254', 3500000, 1000000, '1990-12-01', 1, null);
insert into emp values (2002, '시은', 10, '대리', '354-865', '서울 강남구', '02-865-1245', 4000000, null, '2000-01-25', 1, 2004);
insert into emp values (2003, '아이사', 20, '사원', '587-456', '부산 해운대구', '051-256-9874', 2500000, 1000000, '2002-05-24', 2, 2002);
insert into emp values (2004, '세은', 30, '과장', '987-452', '서울 강남구', '02-333-6589', 5000000,  null, '1997-03-22', 2, 2001);
insert into emp values (2005, '윤', 10, '대리', '123-322', '서울 성동구', '02-888-9564', 3000000, 1000000, '1999-07-15', 2, 2004);
insert into emp values (2006, '재이', 20, '사원', '154-762', '서울 송파구', '02-3369-9874', 2000000,  null, '2003-05-22', 2, 2005);
insert into emp values (2007, '최유진', 30, '대리', '367-985', '서울 영등포구', '02-451-2563', 3000000, 1000000, '2006-01-25', 2, 2004);
insert into emp values (2008, '샤오팅', 40, '사원', '552-126', '서울 중구', '02-447-3256', 2400000,  null, '2001-02-02', 2, 2007);
insert into emp values (2009, '마시로', 10, '사원', '315-276', '서울 종로구', '02-123-1278', 2500000, 1000000, '2009-04-17', 2, 2002);
insert into emp values (2010, '김채현', 20, '사원', '485-172', '서울 성북구', '02-478-1235', 2450000, 1000000, '2009-12-15', 2, 2004);

-- 절차적 언어(Procedural Language)의 SQL => PL/SQL
-- SQL 구문을 하나의 명령 블록으로 구성하여 필요 시 호출하여 사용하며, IF LOOP FOR 등을 활용하여 더 효과적으로 SQL을 활용할 수 있다. 
-- 프로시저 Procedural 함수Function 트리거Trigger
-- PL 실행결과 출력문 활성화

SET SERVEROUTPUT ON;

DECLARE
    TYPE firsttype IS RECORD(a emp.ename%TYPE, b emp.pos%TYPE, c emp.salary%TYPE);
cus1 firsttype;
BEGIN
    SELECT ename, pos, salary INTO cus1 FROM emp where eno=2001;
    DBMS_OUTPUT.PUT_LINE('******************************************');
    DBMS_OUTPUT.PUT_LINE(cus1.a || CHR(9) || cus1.b || CHR(9) || cus1.c);
    DBMS_OUTPUT.PUT_LINE('현재 계정 : ' || USER);
    DBMS_OUTPUT.PUT_LINE('현재 질의 시간: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:MM:SS'));
END;

-- CHR(10)

-- 익명의 프로시저를 활용하여 사원테이블로부터 사원번호 2002인 사원의 사원번호, 사원명, 직급, 주소, 입사일을 출력하시오.
-- 단 입사일은 

DECLARE
    sawon emp%ROWTYPE;
BEGIN
    SELECT * INTO sawon FROM emp where eno=2002;
    DBMS_OUTPUT.PUT_LINE('*********************************');
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || sawon.eno);
    DBMS_OUTPUT.PUT_LINE('사원명 : ' || sawon.ename);
    DBMS_OUTPUT.PUT_LINE('직급 : ' || sawon.pos);
    DBMS_OUTPUT.PUT_LINE('주소 : ' || sawon.addr);
    DBMS_OUTPUT.PUT_LINE('입사일 : ' || sawon.regdate);
END;

-- 익명의 반복 프로시저 실습
-- 사원(emp) 테이블로부터 사원명(ename), 직급(pos) 컬럼의 모든 사원을 출력하시오.
DECLARE
    TYPE ename_type IS TABLE OF emp.ename%TYPE INDEX BY BINARY_INTEGER;
    TYPE pos_type IS TABLE OF emp.pos%TYPE INDEX BY BINARY_INTEGER;
    ename_col ename_type;
    pos_col pos_type;
    i BINARY_INTEGER :=0;
BEGIN
    FOR k IN(SELECT ename, pos FROM emp) LOOP
        i := i +1;
        ename_col(i) := k.ename;
        pos_col(i) := k.pos;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('**************************');
    DBMS_OUTPUT.PUT_LINE('사원명              직급');
    DBMS_OUTPUT.PUT_LINE('**************************');
    FOR j IN 1..i LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(ename_col(j), 12)|| RPAD(pos_col(j),10));
    END LOOP;
END;

-- 사원번호와 급여를 매개변수로 입력받아 해당 사원의 급여를 갱신하는 프로시저(update_pay)를 작성하여라
CREATE OR REPLACE PROCEDURE update_pay(u_eno IN NUMBER, u_salary IN NUMBER)
IS
BEGIN
    UPDATE emp SET salary=u_salary WHERE eno=u_eno;
    COMMIT;
END update_pay;

EXEC update_pay(2001, 5000000);
EXEC update_pay(2006, 2800000);

select * from emp;

-- 사원번호(eno)와 직급(pos), 주소(addr)를 입력 받아 갱신하는 프로시저(update_emp)를 작성하고, 
-- 임의의 데이터로 2건 이상 실행되도록 하시오.

CREATE OR REPLACE PROCEDURE update_emp (u_eno IN NUMBER, u_pos IN emp.pos%TYPE, u_addr IN emp.addr%TYPE)
IS
BEGIN
    UPDATE emp SET pos=u_pos, addr=u_addr WHERE eno= u_eno;
    COMMIT;
END update_emp;

EXEC update_emp(2004, '부장', '서울 강동구');
EXEC update_emp(2002, '과장', '서울 강남구');
EXEC update_emp(2003, '대리', '부산 해운대구');
    
select * from emp;      
    
    
-- 함수(Functions)   
-- 사원번호(eno)를 매개변수로 입력받아 특정 직원의 세금(3.3%)을 계산하여 출력하는 함수(tax_fnc)를 작성하고 실행하시오.
-- 임의로 3건의 실행문을 실행하고, 그 경과를 출력하시오.
CREATE OR REPLACE FUNCTION tax(v_eno IN emp.eno%TYPE)
RETURN NUMBER
IS
    v_tax NUMBER;
BEGIN
    SELECT (salary+NVL(bonus,0))*0.033 INTO v_tax FROM emp WHERE eno = v_eno;
    RETURN v_tax;
END tax;
/


-- 실행 방법1
DECLARE
    v_tax NUMBER;
BEGIN
    v_tax := tax(2003);
    DBMS_OUTPUT.PUT_LINE('세금:' || v_tax);
END;
/
--MySQL플러스에서는 / 사용해줘야 함

-- 실행방법2
select tax(2003) as "세금" from dual;

-- 실행방법3
select distinct tax(2003) as "세금" from emp;
select tax(2003) as "세금" from emp where eno= 2003;

-- 직급(pos)을 매개변수로 입력 받아 해당 직급별 급여 총액, 평균 급여, 인원수를 출력하는 
-- 프로시저(tot_emp)를 작성하시오
CREATE OR REPLACE PROCEDURE tot_emp(v_pos IN VARCHAR2)
IS
    a NUMBER :=0;
    b NUMBER(12,2):=0;
    C NUMBER :=0;
BEGIN
    SELECT SUM(salary+NVL(bonus, 0)), AVG(salary+NVL(bonus, 0)), COUNT(*) INTO a,b,c FROM emp WHERE pos=v_pos;
    DBMS_OUTPUT.PUT_LINE(v_pos ||'의 급여집계' );
    DBMS_OUTPUT.PUT_LINE('급여 총액 : ' || a || '원' );
    DBMS_OUTPUT.PUT_LINE('평균 급여 : ' || b || '원' );
    DBMS_OUTPUT.PUT_LINE('인원수 : ' || c || '명' );
END tot_emp;
/    
-- 사원을 추가하는 프로시저(ins_emp)를 작성하시오.
-- (단, 추가하는 데이터는 임의로 할 것.)
CREATE OR REPLACE PROCEDURE ins_emp(ins_eno in emp.eno%TYPE, ins_ename in emp.ename%TYPE, ins_pos in emp.pno%TYPE, ins_salary in emp.salary%TYPE)
IS
BEGIN
    INSERT INTO emp (eno, ename, pos, salary) VALUES(ins_eno, ins_ename, ins_pos, ins_salary);  
    
    
-- CREATE OR REPLACE PROCEDURE ins_emp(ins_eno in emp.eno%TYPE, ins_ename in emp.ename%TYPE, ins_pno in emp.pno%TYPE, 
-- ins_pos in emp.pno%TYPE, ins_pcode in emp.pcode%TYPE,  ins_addr in emp.addr%TYPE)
-- IS
-- BEGIN  이라고도 표현할 수 있음
addr varchar(100), salary number, bonus number, regdate timestamp not null, gender number not null
-- 사원번호(eno)를 매개변수로 입력받아 해당 직원에 대한 퇴사 처리를 하는 프로시저를 작성하시오.
-- 작성된 del_emp 프로시저에서 단, 매개값으로 사원번호가 2001인 사원을 진행할 것



-- 원의 반지름을 입력받아 원주율(3.1415) 를 반영하여 넓이를 구하는 함수(circle_fnc)를 작성하시오.
CREATE OR REPLACE FUNCTION circle_fnc(radius IN NUMBER)
RETURN NUMBER
IS
    area NUMBER;
BEGIN
    area := radius * radius * 3.1415;
    RETURN area;
END;
/

SELECT circle_fnc(25) as "면적" from dual;

-- 너비w 높이h, 깊이d 를 매개변수로 입력받아 직육면체의 부피를 구하는 함수box_vol를 작성하고, 실행하시오.
CREATE OR REPLACE FUNCTION vol_fnc(w IN NUMBER, h IN NUMBER, d IN NUMBER)
RETURN NUMBER
IS
  vol NUMBER;
BEGIN
    vol := w * h * d;
    RETURN vol;
END;
/
SELECT vol_fnc as "부피" from dual;
-- 반환값이 ... dual

-- 사원(emp) 테이블로부터 근무기간 (y년 x개월)을 계산하는 함수(workdays_fnc)를 작성하시오.
-- (단, 입사일을 입력받아 MONTH_BETWEEN 함수를 사용하여 년수와 개월수를 구할 수 있도록 할 것.)
-- (실행 싱에는 사원명(ename)과 근무기간(y년X개월이 출력되도록 할 것)
-- MONTHS_BETWEEN(나중날짜, 먼저날짜) : 흐른 개월 수 계산 (EX) 98 개월)
-- FLOOR(숫자) : 소숫점 이하 버림
-- 년수 구하기: FLOOR(MONTHS_BETWEEN(SYSDATE, 입사일)/12) (EX. 98/12=>8....2)
-- 잔여개월수 구하기: FLOOR
CREATE OR REPLACE FUNCTION workdays_fnc(a_day in varchar b_day in varchar)
RETURN NUMBER
IS 
    workday NUMBER;
BEGIN
    ru
-- ----------------------------

CREATE OR REPLACE FUNCTION workdays_fnc(vdate IN DATE)
RETURN VARCHAR2
IS 
    workday VARCHAR2(40);
BEGIN
    workdate := FLOOR(MONTHS_BETWEEN(SYSDATE, vdate/12) || '년' || FLOOR(MOD(MONTHS_BETWEEN(SYSDATE, vdate), 12)) || '개월';
RETURN workdate;
END;
/


-- 사원(emp) 테이블에서 성별코드(gender)를 이용하여 성별을 구하는 함수(gender_fnc)를 작성하고, 실행하시오.
-- (단, 성별코드 gender 가 1이거나 3 이면, '남'이고, 아니면, '여'이다.)
-- (실행결과는 사원명, 성별 컬럼이 출력될 수 있도록 하시오.)


CREATE OR REPLACE FUNCTION gender_fnc(gender IN NUMBER)
RETURN VARCHAR2
IS
    gen_code VARCHAR(4);
BEGIN
    IF gender IN (1, 3) THEN 
        gen_code := '남' ;
    ELSE gen_code= '여'
    END IF; 
    RETURN gen_code;
END;
/
-- IS gcode VARCHAR(4)
-- gcode :=SUBSTR(jumin, 8,1) 성별코드가 주민번호에서 8번째 글자 1글자인 경우
-- IF gcode IN ('1','3') THEN
SELECT ename AS "사원명", gender_fnc(gender) as "성별" FROM EMP;

-- ------------------------------------------------------------------------------
-- CREATE OR REPLACE FUNCTION gender_fnc(gen_code IN NUMBER)
-- RETURN NUMBER
-- IS
    -- gen_code NUMBER;
-- BEGIN
   -- if gen_code= '남' WHERE gender='1' or gender = '3';
    -- else gen_code= '여' WHERE gender='1' or gender = '3';..................
    -- DBMS OUTPUT.PUT_LIN




-- 사원(emp) 테이블에서 급여(salary)를 이용하여 급여등급을 구하는 함수(grade_emp)를 작성하고, 실행하시오.
--(단, 급여가 4,500,000 이상이면 'A', 3,500,000원 이상이면 'B', 3,000,000 이상이면 'C', 나머지는 'D'로
-- (실행결과는 사원코드, 사원명, 급여등급, 급여 순으로 출력될 수 있도록 하시오.) IF THEN-ESLIF THEN-ELSE)

CREATE OR REPLACE FUNCTION grade_emp(salary IN NUMBER)
RETURN VARCHAR2
IS
    grade VARCHAR2
BEGIN
    IF salary >= 4,500,000 THEN
    grade = 'A'
    ELSIF 
-----------------------------------------------------------------------------------------------
-- loop_test 테이블생성
-- 번호(no)숫자
-- 이름(name) 가변문자열 20글자, 기본값 '김기태'
CREATE TABLE loop_test (no NUMBER, name VARCHAR2(20) DERAULT '김기태');




-- 1) LOOP문을 활용하여 번호를 증가식으로 자동 채우면서 20개의 레코드를 추가될 수 있도록 반복할 것.
--    번호는 1~20
DECLARE
    vcnt NUMBER(2) :=1;
BEGIN
    LOOP
        INSERT INTO loop_test(NO) VALUES(vcnt);
        vcnt := vcnt +1;
        EXIT WHEN vcnt >20;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE((vcnt-1) || '건의 데이터 입력 완료');
END;


-- 2) FOR IN LOOP 문을 활용하여 번호를 증가시키고 자동 채우면서 10개의 레코드를 추가될 수 있도록 반복할 것.
--    번호는 21~30, 프로시저 이름: loop2
CREATE OR REPLACE PROCEDURE loop2
IS
BEGIN
    FOR i IN 21..30 LOOP
        INSERT INTO loop_test(NO) VALUES (i);
        COMMIT;
    END LOOP;
END;
/
EXEC loop3;

select *from


-- 3) 예외처리 프로시저
CREATE OR REPLACE PROCEDURE exc_test
IS 
    sw emp%ROWTYPE;

BEGIN
    SELECT * INTO SW FROM emp;
    DBMS_OUTPUT.PUT_LINE('데이터 검색 성공');
    COMMIT;
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('데이터가 너무 많습니다');
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;





















