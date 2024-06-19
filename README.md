# Despliegue de aplicación Flask

Esta es una aplicación web desarrollada con Flask que permite a los usuarios consultar los precios del mercado de las empresas a través de una API externa (Twelve data). Además de consultarlos, podemos anotar las acciones que hemos comprado o vendido y ver el historial de cada uno de los movimientos que hemos hecho.

La aplicación incluye un conjunto de pruebas automatizadas que se ejecutan con CircleCI cada vez que se detectan cambios en el código. Además, hemos implementado varios métodos para desplegar la aplicación: usando Helm Charts, Kubernetes, y utilizando Terraform.

**Tabla de Contenidos**

- Requisitos

- Instalación y Despliegues

- Estructura del Proyecto


## Requisitos

- Python 3.7 o superior.
- Docker.
- Cuenta de CircleCI configurada.
- Acceso a un clúster de Kubernetes.
- Terraform instalado.

## Instalación y Despliegues

Para comenzar necesitas crear el repositorio. Una vez clonado y con los requisitos instalados podremos desplegar nuestra aplicación.

Como comentamos anteriormente, existen varias formas de desplegar nuestra aplicación. Una vez decidida la herramienta que queremos utilizar, entramos a su carpeta.

>cd <CARPETA_SELECCIONADA>

Una vez dentro, y dependiendo de la opción seleccionada utilizaremos los comandos correspondientes

- K8s:

> minikube start

> helm install app-chart .


- Charts: 

> minikube start

> kubectl apply -f .

- Terraform:

> terraform init

> terraform apply


## Estructura del Proyecto

A continuación se describe la estructura del proyecto y el propósito de cada carpeta. Este desglose ayuda a entender cómo se organiza el código y facilita el desarrollo, pruebas y despliegue de la aplicación Flask.

### CircleCi

**Propósito**: Configuración para la integración continua con CircleCI.

**Archivos**:

- config.yml: Este archivo contiene la configuración de CircleCI para ejecutar las pruebas automáticamente cada vez que hay cambios en el código. Define los pasos del pipeline, incluyendo la instalación de dependencias, la ejecución de pruebas.


### App chart

**Propósito**: Archivos de configuración de Helm Chart para el despliegue de la aplicación en Kubernetes.

**Archivos**:

- Chart.yaml: Archivo de metadatos del Helm Chart que incluye el nombre del chart, la versión, y una breve descripción.

- values.yaml: Archivo que contiene los valores predeterminados de configuración del chart. Estos valores pueden ser sobrescritos durante la instalación o actualización del chart.

- templates/: Directorio que contiene las plantillas de recursos de Kubernetes (despliegues, servicio ...) que serán renderizadas usando los valores especificados en values.yaml.


### K8s

**Propósito**: Archivos de configuración para el despliegue manual en Kubernetes.

**Archivos**:

- deployment.yaml: Define el despliegue de la aplicación, especificando detalles como el número de réplicas, la imagen del contenedor, y las configuraciones de actualización.

- service.yaml: Configura el servicio de Kubernetes que expone la aplicación, permitiendo que otros servicios o usuarios accedan a ella.


### Terraform

**Propósito**: Archivos de configuración para el despliegue de la infraestructura en AWS utilizando Terraform.

**Archivos**:

- COMENTADOS DENTRO DE LA CARPETA


### Test

**Propósito**: Archivos de configuración de las pruebas automatizadas para la aplicación Flask.

**Archivos**:

- app.py: Especifica el puerto en el que se va a ver la aplicación.

- app/test/test_app.py: Archivo principal de pruebas que contiene las pruebas unitarias y de integración para la aplicación Flask. Utiliza frameworks de prueba como pytest.

- app/_init_.py: Archivo que convierte este directorio en un paquete de Python, permitiendo la importación de módulos desde este directorio en otros archivos de prueba.