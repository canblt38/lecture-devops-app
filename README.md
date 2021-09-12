Lecture: DevOps - Application
=============================


> :warning: __Invoking `make` in a path containing white spaces will break execution and may lead to
> unforeseen side effects like DATA LOSS !__


This repository contains the [application](./app/README.md) that is supposed be used as *deployable workload* in the
[project assignment](https://github.com/lucendio/lecture-devops-material/blob/master/assignments/project-work.md)
implementation.
Normally, the only changes that are required to be made here in order 

In order to adapt the application and integrate it into your automation and deployment processes, it's usually not
required to change any existing code. Instead, you probably just want to add some *pipeline* code or even a container
file (e.g. `Dockerfile`).


### Deployment und Status der Abnahme

Um die Anwendung auf AWS zu deployen müssen die Credentianls in die Main.tf hinzugefügt werden. Anschließend erfolgt der Befehlt "terraform apply" um die App
initinal aufzusetzen. Dabei wird automatisiert die Mongo DB und die EC2 Instanzen aufgesetzt und die Anwendung ist auf den DNS namen des Load Balancers über HTTPS durch
das hinzufügen des SSL Zertifikates erreichbar. Um den DNS einzurichten muss nun ein manueller Schritt vorgenommen werden. Dabei wird der CNAME von dem Load Balancer auf der Seite Name.com als CNAME hinterlegt. Anschließend ist die TO-DO-APP unter der jeweils gewünschten Domain erreichbar. Um die TO-DO-APP auf eine neue Version upzugraden ist es zunächest nötig alle AWS Credentails innerhalb von GITHUB als Secrets zu hiterlegen. Zudem muss die IP der MongoDB Instanz und die Hostnamen der jeweiligen EC2, auf denen die TO-DO-APP läuft manuell hinterlegt werden. Dieser Schritt ist nur ein einziges mal nach der Initialen Aufsetzung der APP nötig. Die Zwei einigen Punkte die bei der Abnahme nicht vollständig erfüllt wurden, ist erstens das aufsetzen einer PROD und DEV Umgebung und zweitens die Verwendung von Prometeus und Grafana. Bei erstens wird lediglich jede Änderrung die innerhalb des Masters vorgenommen direkt auf PROD geschoben und somit Online gestellt. Eine DEV umgebung Fehlt. Bei der Verwenung von Prometheus ist lediglich die Schnittstelle der Metrics auf seitens der EC2 instancen verfügbar. Die Anbindung über eine neue EC2 instance, die die Verwaltung mittels Grafana tätigt und die Daten der EC2 Instancen der APP auswertet fehlt. Für die Tests der TO-DO-APP wurde eine Pull-Request erstellt.


### Getting started 

For more information regarding the app, please take a look into its [README](./app/README.md).

The `Makefile` in this directory can be seen as the main entry point for this repository. It's meant to locally run the
application and mess around with the source code in order to better understand how it works and to be able to tear it
apart if necessary.
Additionally, it documents various invocations that may help you adapting this application as *workload* for the exercise. 

**_Please note, that the `Makefile` is only meant to showcase steps that are usually needed to be taken in order to
automate the deployment lifecycle of such an application and code base.
It is NOT recommended to invoke `make` targets from the CI/CD, but rather to utilize platform-specific interfaces 
(e.g. `.gitlab-ci.yml`, `Jenkinsfile`, etc.), which may then invoke commands shown in the `make` target or in the `scripts`
 section of one of the `package.json` files._**


### Prerequisites

The following software must be installed and available in your `${PATH}`:

* `node` ([NodeJS](https://nodejs.org/en/download)): latest v14
* `npm` ([npm](https://www.npmjs.com/get-npm)): latest v6
* `mongod` ([MongoDB](https://docs.mongodb.com/manual/installation/)): latest v4.2

*NOTE: the application in this repository has not been tested with versions newer than that*

Choose for yourself how you want to install these dependencies. Perhaps you can use the package manager
available on your operating system, or maybe you prefer using container images. 


### Commands

The following commands are available from the root directory:


#### `make install`

* installs all dependencies via `npm` for *server* and *client*


#### `make build`

1. copies server source into some empty location
2. copies dependency manifest (`package*`) into the same location right next to the server source
3. installs server dependencies
4. builds client code (requires client dependencies to be installed already) and puts it next to the server source into   


#### `make test`

*NOTE: requires a MongoDB service already ro be running (see `MONGODB_URL` in target on where it's assumed to be running)*

* runs client & server tests in [CI mode](https://jestjs.io/docs/en/cli.html#--ci) (exits regardless of the test outcome; closed tty)


#### `make dev-test-client`

*NOTE: only demonstrates a use case during local development and are not meant to run in any other context (e.g. automation)*

* runs client tests in a local development mode


#### `make dev-start-db`

*NOTE: only demonstrates a use case during local development and are not meant to run in any other context (e.g. automation)*

* starts a local MongoDB service


#### `make dev-start-app`

*NOTE (1): only demonstrates a use case during local development and are not meant to run in any other context (e.g. automation)*
*NOTE (2): it might be desired to first start a database service (e.g. `make dev-start-db`)*

* builds client
* starts server in development mode with development configuration


#### `make run`

*NOTE (1): showcases plain executable invocation with a shared parent process. Press `Ctrl+C` to send termination signal.*
*NOTE (2): in reality those two services would always be invoked independently and __never__ share a parent process!*

* starts a MongoDB service as a child process with an explicit inline-configuration
* starts the application service with variables being set in a way so that they are only *visible* to that invocation
  (as an alternative to the configuration file `app/server/dev.env` that is used to set environment variables)
* blocks terminal and keeps it as output device until termination signal is being send.


#### `make clean`

* removes all `node_modules` dependencies that have been installed locally via `npm`
* removes other temporarily created folder in `.local` 
