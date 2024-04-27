# Требования к системе

*   Docker & Docker Compose (https://docs.docker.com/engine/install/ubuntu/)
    *   docker >= 19.X.X 
    *   docker-compose ~1.29.2
 
> Please make sure:
*   you can run commands with root privileges on your computer
*   your port 8080 is not in use
*   the subnet 172.18.0.0/24 is not in use in your computer

# Подготовка инфраструктуры

1. Клонируем данный репозиторий к себе на локальную машину
```
git clone https://github.com/glincow/kafka-spark-streaming-docker.git
cd kafka-spark-streaming-docker
```

2. Запускаем контейнеры
```
docker-compose up -d 
```
Если все нормально, должны запуститься следующие контейнеры (контейнеров будет больше, но  нам нужно эти):

| service name             | 
|--------------------------|
| zookeeper                | 
| kafka                    | 
| spark                    | 
| spark worker 1           | 
| spark worker 2           | 
| spark-streaming-scala    | 
| python-producer          | 

Проверьте, какие контейнеры запустились. В выводе этой командывы можете найти container id, которые пригодятся в следующих шагах:
```
docker ps
```

Если каких-то контейнеров нет, запустите команду и посмотрите, какие контейнеры оказались в статусе Exited
```
docker ps -a
```

Стартаните их отдельно с помощью команды
```
docker сontainer start <container_id>
```

## Настройка Kafka

1. Создайте отдельное окно или вкладку терминала и зайдите внутрь контейнера kafka
```
docker exec -it kafka /bin/bash
```
2. Создайте топик test и 
```
kafka-topics.sh --create --topic netology --bootstrap-server 172.18.0.9:9092
``` 

## Настройка Producer на Python
1. В первом окне терминала скопируйте файл с кодом Producer внутрь контейнера python-producer
```
docker cp netology/producer.py <python-producer-container-id>:/producer.py
```
2. Внутри контейнера python-producer уже установлена библиотека kafka-python, поэтому достаточно войти в контейнер и запустит producer.py изнутри контейнера:
```
docker exec -it <python-producer-container-id> /bin/bash

python producer.py 
```
3. В окне терминала, где вы зашли в контейнер Kafka, проверьте, что сообщения отправляются в топик:
```
kafka-console-consumer.sh --topic netology --from-beginning --bootstrap-server 172.18.0.9:9092
```

## Запуск Streaming джобы
1. Создайте еще одно окно терминала и скопируйте файл с Streaming кодом внутрь контейнера spark
```
docker cp netology/structured-streaming.py <spark-container-id>:/structured-streaming.py
```
2. Запустите spark-submit из контейнера spark: 
```
docker exec -it spark spark-submit --packages "org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0" --master "spark://172.18.0.10:7077" /structured-streaming.py
```
Обратите внимание, что в обновленном файле со streaming кодом уже настроен уровень логгирования ERROR, поэтому в выводе вы должны видеть результаты streaming обработки. 


# Задание 
В рамках домашнего задания Вам необходимо повторить действия в разделе **Подготовка инфраструктуры**.

- В качестве генератора сообщений можете использовать код в netology/producer.py 
- Ваша задача - запустить код на Structure Streaming в netology/structured-streaming.py на основе сгенерированных данных и отобразить в консоле результат join (Static + Stream).
- В качестве артефакта - прикрепите скрин консоли, в которой виден timestamp сообщения и успешный результат join.
- Дополнительное задание: найти в коде приложения пример работы функции агрегата, адаптировать его под входной поток и прислать скрин консоли (в нем должны быть показаны количества событий каждого из пользователя).**
