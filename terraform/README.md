# Load Balancer with autoscaling

A continuación se proporciona una guía completa para crear un balanceador de carga con autoescalado en AWS utilizando Terraform. La configuración incluye la creación de una plantilla de lanzamiento, pares de claves, un grupo de auto-scaling, roles IAM, un balanceador de carga, VPC, subredes, grupos de seguridad y salidas requeridas.

**Tabla de Contenidos**

- Requisitos Previos

- Proveedor

- Configuración

- Recursos Creados

- Variables

- Salidas


## Requisitos

- Terraform v0.12 o superior
- Una cuenta de AWS con credenciales configuradas
- Clave SSH existente o generar una nueva

## Proveedor

Especificamos el proveedor de AWS, incluyendo la región y las credenciales de acceso. En este caso tenemos las claves como sensibles por lo que nos las pedirá cada vez que queramos interactuar con el CLI de AWS. 

## Configuración

Configuramos una VPC, subredes para cada uno de las zonas de la región y rutas para la infraestructura de red.

Así mismo creamos dos grupos de seguridad, uno para el balanceador de carga y otro para las instancias EC2 que se creen. En ellos están creadas las reglas para permitir el tráfico HTTP en el puerto 80 y el acceso SSH en el puerto 22 para las instancias EC2.

## Recursos Creados

Creamos un balanceador de carga para distribuir el tráfico entrante entre las instancias del grupo de autoescalado. Además, un target group que definirá a donde se enviará el mismo a través del listener que escuchará en el puerto 80.

A continuación conectaremos el balanceador de carga al grupo de autoescalado para poder manejar de una forma dinámica las instancias que se van creando.


## Variables

Las variables permiten la configuración dinámica de los recursos.

- **app_name:** Define el nombre de la aplicación.

- **aws_region:** Especifica la región de AWS donde se desplegarán los recursos.

- **aws_access_key:** Credencial de acceso a AWS

- **aws_secret_key:** Credencial de clave secreta de acceso a AWS

- **az_prefix:** Define el prefijo de la zona de disponibilidad usada.


## Salidas

Una vez creado el balanceador de carga podremos ver a través del output el nombre de dns, con el que podremos comprobar si la aplicación se ha desplegado correctamente.



![Arquitectura AWS](./img/aws%20-architecture.png)

