start:
	docker-compose -f db/mssql.yml up -d

	docker-compose -f node1/kafka-controller.yml up -d
	docker-compose -f node1/kafka-broker.yml up -d
	docker-compose -f node1/kafka-source-connect.yml up -d
	docker-compose -f node1/kafka-sink-connect.yml up -d

	docker-compose -f node2/kafka-controller.yml up -d
	docker-compose -f node2/kafka-broker.yml up -d
	docker-compose -f node2/kafka-source-connect.yml up -d
	docker-compose -f node2/kafka-sink-connect.yml up -d

	docker-compose -f node3/kafka-controller.yml up -d
	docker-compose -f node3/kafka-broker.yml up -d
	docker-compose -f node3/kafka-source-connect.yml up -d
	docker-compose -f node3/kafka-sink-connect.yml up -d

	docker-compose -f ui/kafka-ui.yml up -d

stop:
	docker-compose -f db/mssql.yml down

	docker-compose -f node1/kafka-controller.yml down
	docker-compose -f node1/kafka-broker.yml down
	docker-compose -f node1/kafka-source-connect.yml down
	docker-compose -f node1/kafka-sink-connect.yml down

	docker-compose -f node2/kafka-controller.yml down
	docker-compose -f node2/kafka-broker.yml down
	docker-compose -f node2/kafka-source-connect.yml down
	docker-compose -f node2/kafka-sink-connect.yml down

	docker-compose -f node3/kafka-controller.yml down
	docker-compose -f node3/kafka-broker.yml down
	docker-compose -f node3/kafka-sink-connect.yml down
	docker-compose -f node3/kafka-source-connect.yml down

	docker-compose -f ui/kafka-ui.yml down
