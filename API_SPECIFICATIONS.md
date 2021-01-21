# API Specifications

 ## 1. Setup & fill database
In the root of this project you'll find a csv-file with passenger data from the Titanic. Create a database and fill it with the given data. SQL or NoSQL is your choice.


## 2. Create an API
Create an HTTP-API (e.g. REST) that allows reading & writing (maybe even updating & deleting) data from your database.
Tech stack and language are your choice. 


An OpenAPI specification is provided (see [swagger.yml](./swagger.yml)). 

If you do not want to implement an API server from scratch, you can use something like [swagger-codegen](https://swagger.io/tools/swagger-codegen/) to generate server stubs for your solution.

We would like you to implement the following five HTTP endpoints. If you want to, you can expand the capabilities of the API, but please ensure that the following endpoints will work as described below. We will use a program to verify that these endpoints are working as expected.

| HTTP Verb | Path             | Request Content-Type | Request body | Response Content-Type | Example response body |
|-----------|------------------|----------------------|--------------|-----------------------|-----------------------|
| GET       | `/people`        | `application/json`   | -            | `application/json`    | `[ { "uuid": "49dc24bd-906d-4497-bcfc-ecc8c309ecfc", survived": true, "passengerClass": 3, "name": "Mr. Owen Harris Braund", "sex": "male", "age": 22, "siblingsOrSpousesAboard": 1, "parentsOrChildrenAboard":0, "fare":7.25}, ... ]` |
| POST      | `/people`        | `application/json`   | `{ "survived": true, "passengerClass": 3, "name": "Mr. Owen Harris Braund", "sex": "male", "age": 22, "siblingsOrSpousesAboard": 1, "parentsOrChildrenAboard":0, "fare":7.25}` | `application/json`    |  `{ "uuid": "49dc24bd-906d-4497-bcfc-ecc8c309ecfc", survived": true, "passengerClass": 3, "name": "Mr. Owen Harris Braund", "sex": "male", "age": 22, "siblingsOrSpousesAboard": 1, "parentsOrChildrenAboard":0, "fare":7.25}` |
| GET       | `/people/{uuid}` | `application/json`   | -            | `application/json`    | `{ "uuid": "49dc24bd-906d-4497-bcfc-ecc8c309ecfc", survived": true, "passengerClass": 3, "name": "Mr. Owen Harris Braund", "sex": "male", "age": 22, "siblingsOrSpousesAboard": 1, "parentsOrChildrenAboard":0, "fare":7.25}` |
| DELETE    | `/people/{uuid}` | `application/json`   | -            | `application/json`    | - |
| PUT       | `/people/{uuid}` | `application/json`   | `{ "survived": true, "passengerClass": 3, "name": "Mr. Owen Harris Braund", "sex": "male", "age": 22, "siblingsOrSpousesAboard": 1, "parentsOrChildrenAboard":0, "fare":7.25}` | `application/json`    | - |

## 3. Dockerize
Automate setup of your database & API with Docker, so it can be run everywhere comfortably with one or two commands.
The following build tools are acceptable:
 * docker
 * docker-compose


