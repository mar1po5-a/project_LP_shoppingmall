
-- 객체 제거 ====================================
-- 순서 FK -> PK

-- 장바구니 테이블 삭제 (존재할 경우)
DROP TABLE Basket CASCADE CONSTRAINTS PURGE;

-- 장바구니 옵션 테이블 삭제 (존재할 경우)
DROP TABLE BasketOpt CASCADE CONSTRAINTS PURGE;

-- 주문 테이블 삭제 (존재할 경우)
DROP TABLE Orders CASCADE CONSTRAINTS PURGE;

-- 배송지 테이블 삭제 (존재할 경우)
DROP TABLE DeliveryAddress CASCADE CONSTRAINTS PURGE;

-- 상품관리 제거

DROP TABLE item CASCADE CONSTRAINTS PURGE;
DROP TABLE Category CASCADE CONSTRAINTS PURGE;
DROP SEQUENCE item_seq;

-- 질문답변 제거(답변)
DROP TABLE answers CASCADE CONSTRAINTS;
DROP SEQUENCE ans_seq;

-- 질문답변 제거(질문)
DROP TABLE question CASCADE CONSTRAINTS;
DROP SEQUENCE ques_seq;

-- 회원관리 제거
DROP TABLE authCode CASCADE CONSTRAINTS;
DROP TABLE member CASCADE CONSTRAINTS;
DROP TABLE grade CASCADE CONSTRAINTS;

DROP SEQUENCE member_seq;

-- 공지사항 제거 - FK 없음.(순서 상관없음.)
DROP TABLE notice CASCADE CONSTRAINTS;
DROP SEQUENCE notice_seq;

 -- 객체 생성 =============================================================
 -- 생성 순서 : PK -> FK
 
 -- *** 제약 조건 - 데이터를 입력할 지 여부에 해당이 되는 조건 - insert에서 동작
 --  pk : primary key(주키) - 중복 배제, null이면 안된다.
 --  nn : not null(필수 데이터) - 데이터가 꼭 필요한 경우

CREATE TABLE grade(
  gradeNo number(1) PRIMARY KEY,
  gradeName varchar2(20) NOT NULL
);

CREATE SEQUENCE member_seq;

-- 회원관리
CREATE TABLE member (
    memberNo NUMBER PRIMARY KEY, -- 회원 번호
    memberId VARCHAR2(50) NOT NULL UNIQUE,  -- ID (중복 방지)
    email VARCHAR2(100) NOT NULL UNIQUE,  -- 이메일 (중복 방지)
    memberPw VARCHAR2(100) NOT NULL,  -- 비밀번호
    memberName VARCHAR2(50) NOT NULL,  -- 이름
    gender VARCHAR2(10) DEFAULT '남자' CHECK (gender IN ('남자', '여자')) NOT NULL,  -- 성별 (남자/여자, 기본값: 남자)
    birth DATE NOT NULL,  -- 생년월일
    tel VARCHAR2(20) NOT NULL,  -- 전화번호
    memberAddress VARCHAR2(255) NOT NULL,  -- 주소
    joinDate DATE DEFAULT sysdate NOT NULL,  -- 가입일 (시스템 지정)
    gradeNo NUMBER(1) DEFAULT 1 CHECK (gradeNo IN (1, 9)) NOT NULL,  -- 등급 번호 (1: 일반 회원, 9: 관리자)
    status VARCHAR2(16) DEFAULT '정상' CHECK (status IN ('정상', '이용 정지', '탈퇴', '휴면')) NOT NULL,  -- 상태 (기본값: 정상)
    naverId varchar2(200)
);

-- 인증 코드 저장소
CREATE TABLE authCode (
    authCodeNo NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- 자동 증가 기본 키
    email VARCHAR2(255) NOT NULL,   -- 이메일
    authCode VARCHAR2(6) NOT NULL,    -- 인증 코드 (6자리)
    expireTime DATE NOT NULL         -- 만료 시간
);

-- 상품 관리 ===========================================================

CREATE SEQUENCE item_seq;

-- 상품관리
CREATE TABLE Category (
    categoryID   NUMBER       PRIMARY KEY,  
    categoryName VARCHAR2(300) NOT NULL     
);

CREATE TABLE Item (
    itemNo       NUMBER        PRIMARY KEY,  -- 상품 번호 (기본 키)
    itemName     VARCHAR2(300) NOT NULL,     -- 상품명
    itemContent  VARCHAR2(2000) NOT NULL,    -- 상품설명
    itemImage    VARCHAR2(500) NOT NULL,     -- 이미지
    price        NUMBER        NOT NULL,     -- 가격
    purchase     NUMBER DEFAULT 0,           -- 구매 횟수 (기본값 0)
    categoryID   NUMBER NOT NULL,     -- 카테고리
    CONSTRAINT fk_item_category FOREIGN KEY (categoryID) REFERENCES Category(categoryID)
);


-- 장바구니 ============================================================ 

-- 장바구니 테이블 생성
CREATE TABLE Basket (
    basketNo NUMBER PRIMARY KEY,  -- 장바구니 번호 (기본 키)
    memberId VARCHAR2(30) NOT NULL,    -- 사용자 아이디 (회원 테이블 참조)
    itemNo NUMBER NOT NULL,     -- 상품 코드 (상품 테이블 참조)
    amount NUMBER NOT NULL,      -- 수량 (기본값 1)
    writeDate DATE DEFAULT SYSDATE, -- 등록 날짜
    CONSTRAINT fk_basket_member FOREIGN KEY (memberId) REFERENCES Member(memberId) ON DELETE CASCADE,
    CONSTRAINT fk_basket_item FOREIGN KEY (itemNo) REFERENCES item(itemNo) ON DELETE CASCADE
);

-- 장바구니 옵션 테이블 생성
CREATE TABLE BasketOpt (
    basketOptNo NUMBER PRIMARY KEY,  -- 장바구니 옵션 번호 (기본 키)
    itemNo NUMBER NOT NULL,          -- 상품 번호 (Item 테이블 참조)
    amount NUMBER NOT NULL,          -- 수량
    basketNo NUMBER NOT NULL,        -- 장바구니 번호 (장바구니 테이블 참조)
    CONSTRAINT fk_basketopt_item FOREIGN KEY (itemNo) REFERENCES Item(itemNo) ON DELETE SET NULL,  -- 외래 키 참조 수정
    CONSTRAINT fk_basketopt_basket FOREIGN KEY (basketNo) REFERENCES Basket(basketNo) ON DELETE CASCADE  -- 장바구니 테이블 외래 키
);

-- 배송지 테이블 생성
CREATE TABLE DeliveryAddress (
    dlvyAddrNo NUMBER PRIMARY KEY,   -- 배송지 번호 (기본 키)
    dlvyName VARCHAR2(30) NOT NULL,  -- 배송지 이름
    memberId VARCHAR2(30) NOT NULL,        -- 사용자 아이디 (회원 테이블 참조)
    recipient VARCHAR2(30) NOT NULL, -- 받는 사람
    tel VARCHAR2(20) NOT NULL,       -- 연락처
    addr VARCHAR2(300) NOT NULL,     -- 주소
    addrDetail VARCHAR2(300) NOT NULL, -- 상세 주소
    postNo NUMBER NOT NULL,          -- 우편 번호
    basic NUMBER(1) DEFAULT 0 CHECK (basic IN (0, 1)), -- 기본 배송지 여부 (1이면 기본, 0이면 아님)
    CONSTRAINT fk_deliveryaddr_member FOREIGN KEY (memberId) REFERENCES Member(memberId) ON DELETE CASCADE
);

-- 주문 테이블 생성
CREATE TABLE Orders (
    orderNo NUMBER PRIMARY KEY,      -- 주문 번호 (기본 키)
    memberid VARCHAR2(30) NOT NULL,        -- 주문자 아이디 (회원 테이블 참조)
    orderDate DATE DEFAULT SYSDATE,  -- 결제일
    dlvyName VARCHAR2(30) NOT NULL,  -- 배송지 이름
    recipient VARCHAR2(30) NOT NULL, -- 받는 사람
    tel VARCHAR2(20) NOT NULL,       -- 연락처
    addr VARCHAR2(300) NOT NULL,     -- 주소
    addrDetail VARCHAR2(300) NOT NULL, -- 상세 주소
    postNo NUMBER NOT NULL,          -- 우편 번호
    dlvyMemo VARCHAR2(300),          -- 배송 메모
    itemNo NUMBER NOT NULL,         -- 상품 코드 (상품 테이블 참조)
    orderPrice NUMBER NOT NULL,      -- 주문 금액
    PointShopGoodsNo NUMBER,         -- 사용 쿠폰 (포인트 샵 상품 참조)
    dlvyCharge NUMBER NOT NULL,      -- 배송비
    payWay VARCHAR2(30) NOT NULL,    -- 결제 수단 (예: 토스페이먼츠, 브랜드 페이)
    payDetail VARCHAR2(100),         -- 결제 상세 정보
    paymentKey VARCHAR2(30),         -- 페이먼츠 키 (토스 결제 위젯 제공)
    orderState VARCHAR2(30) NOT NULL CHECK (orderState IN ('결제 완료', '배송 준비', '배송중', '배송완료', '구매확정', '취소요청', '반품요청', '요청 처리')),  -- 주문 상태
    confirmDate DATE,                -- 구매 확인일
    reviewExist NUMBER(1) DEFAULT 0, -- 리뷰 작성 여부 (1이면 리뷰 있음, 0이면 없음)
    cancleReason VARCHAR2(300),      -- 취소 사유
    amount NUMBER NOT NULL,          -- 수량
    CONSTRAINT fk_orders_member FOREIGN KEY (memberId) REFERENCES Member(memberId) ON DELETE CASCADE,
    CONSTRAINT fk_orders_item FOREIGN KEY (itemNo) REFERENCES item(itemNo)
);




-- 공지사항 ============================================================ 

CREATE SEQUENCE notice_seq
START WITH 1
INCREMENT BY 1;

CREATE TABLE notice(
    noticeNo NUMBER PRIMARY KEY, -- 번호 (PK)
    title varchar2(300) not null, -- 제목
    content varchar(2000) not null, -- 내용
    startdate date DEFAULT sysdate, -- 공지 시작일
    writedate date DEFAULT sysdate,     -- 공지 작성일
    updatedate date,    -- 공지수정일
    enddate date DEFAULT TO_DATE('9999-12-30', 'YYYY-MM-DD'),  -- 공지종료일
    importnotice VARCHAR2(10) DEFAULT '비중요' CHECK(importnotice IN('중요','비중요')) NOT NULL,   -- 중요공지
    imageFile varchar2(500),   --이미지
    memberId VARCHAR2(50)  -- ID 
    );


-- 질문답변 (질문) ============================================================ 

CREATE SEQUENCE ques_seq
START WITH 8
INCREMENT BY 1;

CREATE TABLE question(
    questionNo NUMBER(20) PRIMARY KEY, -- 질문번호 (PK)
    title VARCHAR2(300) NOT NULL, -- 제목
    content VARCHAR2(2000) NOT NULL, -- 내용
    memberPw VARCHAR2(100),     -- 작성자PW
    memberId VARCHAR2(50),   -- ID (중복 방지)
    writedate DATE DEFAULT sysdate,  -- 질문작성일
    updatedate DATE,   -- 질문수정일
    imageFile varchar2(400),   --이미지,
    queCategory VARCHAR2(10) DEFAULT '주문' CHECK (queCategory IN ('주문', '반품', '상품', '기타')) NOT NULL  -- 질문 카테고리
);


-- 질문답변 (답변) ============================================================ 

CREATE SEQUENCE ans_seq
START WITH 8
INCREMENT BY 1;

CREATE TABLE answers(
    answersNo number(20) PRIMARY KEY, -- 답변번호 (PK)
    questionNo number(20),
    title varchar2(300), -- 답변내용
    content varchar2(2000) not null, -- 답변내용
    writeDate date DEFAULT sysdate,     -- 답변 작성일
    updateDate date,    -- 답변 수정일
    status VARCHAR2(10) DEFAULT '미작성' CHECK(status IN('미작성','입력')) NOT NULL,   -- 질문상태
    answerNumber number(20),
    FOREIGN KEY (questionNo) REFERENCES question(questionNo) ON DELETE CASCADE -- 외래 키 제약조건 및 삭제 시 연쇄 삭제
  
);



-- ==========================================================================


-- 주문 샘플 데이터
-- INSERT INTO Orders (orderNo, memberId, orderDate, dlvyName, recipient, tel, addr, addrDetail, postNo, dlvyMemo, itemNo, orderPrice, PointShopGoodsNo, dlvyCharge, payWay, payDetail, paymentKey, orderState, confirmDate, reviewExist, cancleReason, amount) VALUES (1, 'user01', SYSDATE, '집', '홍길동', '010-1234-5678', '서울시 강남구', '101동 202호', 12345, '부재 시 경비실', 101, 50000, NULL, 3000, '카드결제', NULL, NULL, '결제 완료', NULL, 0, NULL, 1);

-- 주문 데이터 확인
-- SELECT * FROM Orders;


 -- 샘플 데이터 =============================================================

-- >> 회원등급 관련
INSERT INTO grade VALUES (1, '일반회원');
INSERT INTO grade VALUES (9, '관리자');


-- 샘플 데이터


-- >> 회원관리 관련
 
INSERT INTO member(memberNo, memberId, email, memberPw, memberName, gender, birth, tel, memberAddress, joinDate, gradeNo, status)
VALUES(member_seq.NEXTVAL, 'first', 'first@aaaa.com', 'test123', '누렁이', '남자', '2025-01-01', '010-1234-5678', '경기도 의정부시', '2025-03-04', '1', '정상');

INSERT INTO member(memberNo, memberId, email, memberPw, memberName, gender, birth, tel, memberAddress, joinDate, gradeNo, status)
VALUES(member_seq.NEXTVAL, 'second', 'second@aaaa.com', 'test123', '구렁이', '여자', '2024-12-01', '010-1111-2222', '서울특별시 서초구', '2025-02-04', '9', '정상');

-- >> 상품관리 관련
-- 카테고리
INSERT INTO Category (categoryID, categoryName) VALUES (1, 'Rock');
INSERT INTO Category (categoryID, categoryName) VALUES (2, 'Pop');
-- 상품
INSERT INTO Item (itemNo, itemName, itemContent, itemImage, Price, purchase, categoryID)
VALUES (item_seq.nextval, 'Rock Album 1', 'This is an amazing rock album with great tracks.', '/upload/item/rock_album_1.jpg', 20000, 50, 1);

INSERT INTO Item (itemNo, itemName, itemContent, itemImage, Price,  purchase, categoryID)
VALUES (item_SEQ.nextval, 'Pop Album 1', 'A fantastic pop album with catchy melodies.', '/upload/item/pop_album_1.jpg', 18000, 120, 2);


-- >> 장바구니 샘플 데이터 관련
INSERT INTO Basket (basketNo, memberid, itemno, amount, writeDate) VALUES (1, 'first', 1, 2, SYSDATE);


-- >> 장바구니 옵션 샘플 데이터 관련
INSERT INTO BasketOpt (basketOptNo, itemNo, amount, basketNo)
VALUES (1, 1, 2, 1);


-- >> 배송지 샘플 데이터 관련
INSERT INTO DeliveryAddress (dlvyAddrNo, dlvyName, memberid, recipient, tel, addr, addrDetail, postNo, basic) 
VALUES (1, '집', 'first', '홍길동', '010-1234-5678', '서울시 강남구', '101동 202호', 12345, 1);

-- 주문 샘플 데이터 관련
INSERT INTO Orders (orderNo, memberid, orderDate, dlvyName, recipient, tel, addr, addrDetail, postNo, dlvyMemo, itemNo, orderPrice, PointShopGoodsNo,
       dlvyCharge, payWay, payDetail, paymentKey, orderState, confirmDate, reviewExist, cancleReason, amount) 
VALUES (1, 'first', SYSDATE, '집', '홍길동', '010-1234-5678', '서울시 강남구', '101동 202호', 12345, '부재 시 경비실', 1, 50000, NULL,
       3000, '카드결제', NULL, NULL, '결제 완료', NULL, 0, NULL, 1);


-- >> 공지사항 관련

INSERT INTO notice (noticeNo, title, content, startdate, writedate, updatedate, enddate, importnotice, imageFile, memberId)
VALUES (notice_seq.nextval, '시스템 점검 안내', '시스템 점검이 2025년 3월 15일 00:00부터 06:00까지 진행됩니다.', TO_DATE('2025-03-14', 'YYYY-MM-DD'), SYSDATE, SYSDATE, TO_DATE('2025-03-15', 'YYYY-MM-DD'), '중요', NULL, 'second');

INSERT INTO notice (noticeNo, title, content, startdate, writedate, updatedate, enddate, importnotice, imageFile, memberId)
VALUES (notice_seq.nextval, '새로운 기능 업데이트', '새로운 기능이 추가되었습니다. 업데이트 후 사용해 보세요.', TO_DATE('2025-03-10', 'YYYY-MM-DD'), SYSDATE, SYSDATE, TO_DATE('2025-03-20', 'YYYY-MM-DD'), '비중요', NULL, 'second');

INSERT INTO notice (noticeNo, title, content, startdate, writedate, updatedate, enddate, importnotice, imageFile, memberId)
VALUES (notice_seq.nextval, '정기 점검 안내', '정기 점검이 예정되어 있습니다. 점검 일정에 유의해 주세요.', TO_DATE('2025-03-18', 'YYYY-MM-DD'), SYSDATE, SYSDATE, TO_DATE('2025-03-19', 'YYYY-MM-DD'), '중요', NULL, 'second');

INSERT INTO notice (noticeNo, title, content, startdate, writedate, updatedate, enddate, importnotice, imageFile, memberId)
VALUES (notice_seq.nextval, '공지사항 변경', '공지사항을 업데이트했습니다. 확인해 주세요.', TO_DATE('2025-03-12', 'YYYY-MM-DD'), SYSDATE, SYSDATE, TO_DATE('2025-03-30', 'YYYY-MM-DD'), '비중요', NULL, 'second');

INSERT INTO notice (noticeNo, title, content, startdate, writedate, updatedate, enddate, importnotice, imageFile, memberId)
VALUES (notice_seq.nextval, '중요 보안 공지', '보안 패치가 적용되었습니다. 모든 사용자는 패치를 적용해야 합니다.', TO_DATE('2025-03-15', 'YYYY-MM-DD'), SYSDATE, SYSDATE, TO_DATE('2025-03-25', 'YYYY-MM-DD'), '중요', NULL, 'second');



-- >> 질문답변 관련 ( 질문 )
-- question 테이블 샘플 데이터 삽입
INSERT INTO question (questionNo, title, content, memberPw, memberId, writedate, updatedate, imageFile, queCategory) 
VALUES 
(1, '배송이 지연되고 있어요', '주문한 상품이 아직 배송되지 않았습니다. 언제 배송될까요?', '1111', 'second', SYSDATE, SYSDATE, NULL, '주문');

INSERT INTO question (questionNo, title, content, memberPw, memberId, writedate, updatedate, imageFile, queCategory) 
VALUES 
(2, '반품 절차가 궁금합니다', '상품이 마음에 들지 않아 반품하고 싶습니다. 어떻게 해야 하나요?', '1111', 'second', SYSDATE, SYSDATE, NULL, '반품');

INSERT INTO question (questionNo, title, content, memberPw, memberId, writedate, updatedate, imageFile, queCategory) 
VALUES 
(3, '상품이 불량이에요', '받은 상품에 하자가 있어서 교환하고 싶습니다. 어떻게 해야 하나요?', '1111', 'second', SYSDATE, SYSDATE, NULL, '상품');

INSERT INTO question (questionNo, title, content, memberPw, memberId, writedate, updatedate, imageFile, queCategory) 
VALUES 
(4, '배송지 변경 요청', '배송 주소를 변경하고 싶은데 어떻게 해야 하나요?', 'test123', 'first', SYSDATE, SYSDATE, NULL, '주문');

INSERT INTO question (questionNo, title, content, memberPw, memberId, writedate, updatedate, imageFile, queCategory) 
VALUES 
(5, '결제 오류 발생', '결제 진행 중 오류가 발생했어요. 어떻게 해결하나요?', 'test123', 'first', SYSDATE, SYSDATE, NULL, '주문');

INSERT INTO question (questionNo, title, content, memberPw, memberId, writedate, updatedate, imageFile, queCategory) 
VALUES 
(6, '기타 문의', '상품에 대한 기타 문의 사항입니다.', 'test123', 'first', SYSDATE, SYSDATE, NULL, '기타');

INSERT INTO question (questionNo, title, content, memberPw, memberId, writedate, updatedate, imageFile, queCategory) 
VALUES 
(7, '회원가입 후 로그인 안돼요', '회원가입 후 로그인할 수 없습니다. 비밀번호를 잊었나요?', '1111', 'second', SYSDATE, SYSDATE, NULL, '기타');

-- >> 질문답변 관련 ( 답변 )
INSERT INTO answers (answersNo, questionNo, title, content, writeDate, updateDate, status, answerNumber) 
VALUES 
(1, 1, '타이틀1', '배송이 지연되어 죄송합니다. 확인 후 빠르게 처리하겠습니다.', SYSDATE, SYSDATE, '입력', 1);

INSERT INTO answers (answersNo, questionNo, title, content, writeDate, updateDate, status, answerNumber) 
VALUES 
(2, 2,'타이틀2', '반품 절차는 고객센터로 문의해주시면 안내드리겠습니다.', SYSDATE, SYSDATE, '입력', 1);

INSERT INTO answers (answersNo, questionNo, title, content, writeDate, updateDate, status, answerNumber) 
VALUES 
(3, 3,'타이틀3', '상품 교환은 배송비를 고객님께서 부담하셔야 합니다. 교환 요청 부탁드립니다.', SYSDATE, SYSDATE, '입력', 1);

INSERT INTO answers (answersNo, questionNo, title, content, writeDate, updateDate, status, answerNumber) 
VALUES 
(4, 4,'타이틀4', '배송지 변경은 고객센터에 요청하시면 처리 가능합니다.', SYSDATE, SYSDATE, '입력', 1);

INSERT INTO answers (answersNo, questionNo, title, content, writeDate, updateDate, status, answerNumber) 
VALUES 
(5, 5,'타이틀5', '결제 오류 관련 문제는 결제 대행사와 확인 후 처리하겠습니다.', SYSDATE, SYSDATE, '입력', 1);

INSERT INTO answers (answersNo, questionNo, title, content, writeDate, updateDate, status, answerNumber) 
VALUES 
(6, 6,'타이틀6', '기타 문의는 담당 부서에 전달하겠습니다.', SYSDATE, SYSDATE, '입력', 1);

INSERT INTO answers (answersNo, questionNo, title, content, writeDate, updateDate, status, answerNumber) 
VALUES 
(7, 7,'타이틀7', '비밀번호 찾기 기능을 이용해 주세요. 고객센터로 문의 주셔도 도움을 드리겠습니다.', SYSDATE, SYSDATE, '입력', 1);




commit;
