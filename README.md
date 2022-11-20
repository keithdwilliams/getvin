# getvin
Docker application to return a VIN number for a vehicle "make" as input. This application will also create a file output.log with complete runtime output."

## Usage

1. Clone this repository locally.
git clone git@github.com:keithdwilliams/getvin.git

2. cd dir into repository
cd getvin

3. Build docker image
```
docker build --tag getvin:latest
```
4. Run docker application using the make of a car as the only input
```
docker run -v $(pwd):/home getvin toyota
```
