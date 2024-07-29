# Kafka Connect를 활용한 CDC 구축 템플릿

이 레포지토리가 구축하고자하는 환경은 각기 다른 온프레미스 서버 인스턴스에 카프카를 KRaft모드로 띄우고 CDC를 구축하는 것이다.

따라서 각 노드에는 `Controller`, `Broker`, `Connect` 총 3개의 프로세스가 동작하는 환경을 구축한다.

## 실행 방법

1. 프로젝트 루트 폴더에서 `make start` (모든 컨테이너 다 띄우기)명령어를 실행시킨다. 만약 컨테이너를 다 내리고 싶다면 `make stop`을 실행시키면 된다.
2. 컨테이너가 다 떴으면 아래 참고 사항의 내용을 수행한다.
3. 참고 사항의 내용을 수행했으면 HTTP 요청으로 `http://localhost:8083/connectors` 혹은 `http://localhost:8084/connectors` 혹은 `http://localhost:8085/connectors` 으로 DB에 관한 커넥트를 등록한다. 이 때 메서드는 POST 요청으로 보내야하며, Requset Body는 아래와 같다.

```json
{
    "name": "mssql-cdc-member-source-connector",
    "config": {
        "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
        "tasks.max": "1",
        "database.encrypt": false,
        "database.hostname": "host.docker.internal",
        "database.port": "1433",
        "database.user": "SA",
        "database.password": "admin123$%",
        "database.names": "SOURCE",
        "schema.include.list": "SOURCE",
        "table.include.list" : "dbo.MEMBER_BASE",
        "database.history.kafka.bootstrap.servers":"broker1:19091,broker2:29092,broker3:39093",
        "db.timezone": "Asia/Seoul",
        "topic.prefix": "cdc",
        "schema.history.internal.kafka.bootstrap.servers":"broker1:19091,broker2:29092,broker3:39093",
        "schema.history.internal.kafka.topic":"schema-history-cdc"
    }
}
```

4. 이제 DB의 데이터를 삭제하고 생성하고 변경하는 등 쓰기요청을 수행한 후에 `http:://localhost:8080` 카프카 UI로 들어가서 CDC내용에 관한 토픽 메세지를 확인한다.



## 주의 사항

1. 각 폴더 내에 위치한 docker-compose파일의 필드 내용에 `주소`, `포트`를 알아서 기입한다.

2. 카프카 옵션 같은 경우는 브로커 노드 번호 등 정확하게 손봐야할게 많으니 주의해야한다.


## 참고 사항

컨트롤러, 브로커, 커넥트 컨테이너가 다 떴으면 DB에 접속해서 쿼리 콘솔에 아래와 같은 쿼리(명령어)들을 입력한다.

### 1. MSSQL 접속 및 데이터베이스, 스키마, 테이블 생성

1. `SOURCE` 데이터베이스를 생성
2. `SOURCE` 데이터베이스 내에 `dbo` 스키마를 사용
3. `SOURCE` 데이터베이스 내에 `dbo` 스키마 내에 `MEMBER_BASE` 테이블 생성
```sql
-- SOURCE 라는 데이터베이스를 사용
USE SOURCE;

-- SOURCE 데이터베이스에 대해 CDC를 활성화
EXEC sys.sp_cdc_enable_db;

-- SOURCE 데이터베이스의 변경 추적 옵션을 설정
-- 변경 추적은 데이터베이스의 테이블에서 변경된 행을 식별하는 데 사용
-- 변경 추적 데이터는 3일 동안 보존되고, 자동으로 정리
ALTER DATABASE SOURCE SET CHANGE_TRACKING = ON(CHANGE_RETENTION = 3 DAYS, AUTO_CLEANUP = ON)

-- dbo 스키마의 MEMBER_BASE 테이블에 대해 CDC를 활성화
EXEC sys.sp_cdc_enable_table
      @source_schema = 'dbo',
      @source_name = 'MEMBER_BASE',
      @role_name = 'sa';

insert into dbo.MEMBER_BASE(id, name) values (1, 'testNickname1');
insert into dbo.MEMBER_BASE(id, name) values (2, 'testNickname2');
insert into dbo.MEMBER_BASE(id, name) values (3, 'testNickname3');
insert into dbo.MEMBER_BASE(id, name) values (4, 'testNickname4');
insert into dbo.MEMBER_BASE(id, name) values (5, 'testNickname5');
insert into dbo.MEMBER_BASE(id, name) values (6, 'testNickname6');
insert into dbo.MEMBER_BASE(id, name) values (7, 'testNickname7');
insert into dbo.MEMBER_BASE(id, name) values (8, 'testNickname8');
insert into dbo.MEMBER_BASE(id, name) values (9, 'testNickname9');
insert into dbo.MEMBER_BASE(id, name) values (10, 'testNickname10');
```
