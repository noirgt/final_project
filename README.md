# Crawler appliction
Graduation project for OTUS of *Gennadiy Tokarev*.

## Состав проекта:
- Приложение Crawler (**application** и **ui**) - `./crawler`:
  - Dockerfile для сбора образов на базе Alpine;
  - Docker-compose file для запуска готового проекта в Docker вместе с **MongoDB**, **RabbitMQ**.
- Terraform манифесты для поднятия инфраструктуры под проект в Yandex Cloud - `./infra/terraform`:
  - Виртуальная сеть; 
  - Виртуальные инстансы для: **Gitlab CI**, **Gitlab CI Runner**, **Harbor Registry**;
  - Облачный кластер Kubernetes.
- Ansible playbooks, вызываемые через provisioner в Terraform после поднятия инстансов - `./infra/ansible`:
  - Для установки **Gitlab CI**;
  - Для установки **Gitlab CI Runner**;
  - Для установки **Harbor Registry**.
- Kubernetes манифесты и готовый Helm chart для деплоя приложения Crawler:
  - Самое приложение Crawler (**application** и **ui**) с сопутствующими сервисами - **MongoDB**, **RabbitMQ**;
  - Опционально публикация сервиса через **Nginx Ingress**;
  - Опционально установка сервисов логирования и монтиоринга в namespace с приложением - **Grafana**, **Prometheus**, **Loki**.

## Terraform:
Для установки инфраструктуры через Terraform необходимо выполнить:

1. В корне директории с манифестами создать файл для определения переменных - `terraform.tfvars`:
```
cloud_id                 = "<идентификатор_облака_yandex>"
folder_id                = "<идентификатор_директории_проекта>"
zone                     = "<наименование_облачной_зоны>" -
region                   = "<наименование_облачного_региона>"
vm_disk_image            = "<идентификатор_образа_os>"
public_key_path          = "<путь_до_публичного_ключа_пользователя>"
private_key_path         = "<путь_до_приватного_ключа_пользователя>"
service_account_key_file = "<путь_до_сервисного_файла_yc>"
network_id               = "<идентификатор_сети>"
subnet_name              = "<идентификатор_подсети>"
```
2. В корне директории с манифестами создать файл для определения переменных хранилища S3,
где будет храниться Terraform state - `config.s3.tfbackend`:
```
endpoint   = "<адрес_сервиса_s3>"
bucket     = "<наименование_bucket>"
region     = "<наименование_облачного_региона>"
access_key = "<access_ключ_для_доступа>"
secret_key = "<secret_ключ_для_доступа>"

skip_region_validation      = true
skip_credentials_validation = true
```

В файле `main.yml` в корне директории Terraform описан вызов необходимых модулей для запуска инфраструктуры,
имеется возможность конфигурирования передаваемых опций. Например, блок с конфигурацией VM через локальную переменную:
```
locals {
  vms                      = {
    "gitlab"               : {"cpu": 4, "memory": 4, "ip_static": true},
    "harbor"               : {"cpu": 2, "memory": 2, "ip_static": true},
  }
}
```
> В текущем примере показана установка: **Gitlab CI**, **Harbor Registry**.

После создания вышеуказанных файлов с переменными можно применить манифесты: `terraform apply`.

## Ansible:
Ansible playbooks вызываются через provisioner в Terraform после поднятия инстансов на основе групп:
- **gitlab** - установка Gitlab CI;
- **harbor** - установка Harbor Registry.

Принадлежность инстанса к той или иной группе определяется на основании его названия. Например:
```
locals {
  vms                      = {
    "gitlab"               : {"cpu": 4, "memory": 4, "ip_static": true},
    "harbor"               : {"cpu": 2, "memory": 2, "ip_static": true},
  }
}
```
> Для текущих VM Terraform создаст инстансы с именами: vm-gitlab, vm-runner, vm-harbor.
> Группа инстанса определяется на основании последнего слова после знака тире "-" в его названии.
> В вышеуказанном примере:
> - VM **vm-gitlab** будет относиться к группе **gitlab**;
> - VM **vm-harbor** будет относиться к группе **harbor**.

Определение групп инстансов и передача необходимых значений переменных происходит через динамический
`inventory.py`, написанный на Python. Для его работы необходимо установить CLI Yandex Cloud `yc`
на машину, где будет производиться запуск Terraform.

Для успешного выполнения playbooks в Terraform provisioner необходимо скопировать SSL ключи для доменного имени,
под которым будет работать Harbor Registry:
- Путь для приватного ключа - `infra/ansible/files/harbor_certs/privkey.pem`
- Путь для публичного ключа - `infra/ansible/files/harbor_certs/cert.pem`
> Название сертификатов можно изменить, для этого в файле `infra/ansible/group_vars/harbor` необходимо задать значения
> переменных:
```
harbor_ssl_pubkey: cert.pem
harbor_ssl_privkey: privkey.pem
```

## Kubernetes:
Для запуска проекта в кластере Kubernetes Yandex Cloud необходимо:

1. Скопировать на локальную машину файлы конфигурации Kubernetes, для управления кластером:
```bash
yc managed-kubernetes cluster get-credentials kubernetes-cluster --external
```
2. Установить **Nginx Ingress** и **Cert Manager**:
```bash
helm install ingress-nginx ingress-nginx/ingress-nginx

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml
```
3. Выполнить деплой проекта **Crawler**:
```bash
kubectl create namespace prod

cd infra/kubernetes/helm/crawler && helm install -n prod crawler .
```

## Мониторинг и логирование:
В проекте используется стек *Grafana/Prometheus/Loki*. При установке Crawler через Helm
данный стек устанавливается автоматически. WEB-доступ к Grafana осуществляется через Ingress.

Dashboard для Crawler, содержащий графики и счётчики, а также набор логов из Loki подгружается
автоматически и доступен панели `dashboards` Grafana.

## Autodeploy:
Реализован через *Gitlab CI*. Для работы необходимо установить в кластер Kubernetes CI runner.
