## DevOps \ Домашнее задание №14 - Terraform Yandex Cloud

С помощью Terraform поднять 2 инстанса в облаке. «Сборочный» инстанс собирает Java приложение. «Продовый» инстанс запускает приложение. В качестве репозитория использовать нативный сервис облачного провайдера. 



## Сервер Terraform создаёт две VM (build & prod) и управляет ими:
  - #### Подготовка инфраструктуры:
    - #### convert my terraform OAuth-token to IAM-token
    - sudo curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    - yc init
    - yc config list
    - #### prepare infrastructure
    - sudo apt update
    - sudo apt-get update
    - sudo apt-get install mc -y
    - sudo mc
    - apt install git
    - apt install unzip
    - #### install terraform
    - cd /tmp
    - git clone https://github.com/spring108/terraform.git
    - cd /tmp/terraform
    - unzip terraform_1.7.0_linux_amd64.zip
    - cp ./terraform /bin
    - terraform --version
    - #### configure terraform: setup providers-mirror from yandex
    - nano ~/.terraformrc
    - #### load project
    - cd /home/igor
    - git clone https://github.com/spring108/terraform_yandex.git
    - cd /home/igor/terraform_yandex
    - #### setup my IAM-token into config.tf
  - #### Запуск сборки проекта и вынос на ПРОД:
    - terraform init
    - terraform plan
    - terraform apply


## Сервер build:
  - #### всем управляет Terraform


## Сервер prod:
  - #### всем управляет Terraform




## Смотрим http://prod_ip:8080/hello