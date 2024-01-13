# Create and run concurrent profiles with Docker and Multilogin browser profiles

Please use the command below to build the image:

docker build -t multilogin-container .

After building, you can run it by using the template below:

docker run -d --name multilogin-app -p 8080:8080 -e EMAIL=foo@bar.com -e PASSWORD=mysecretpassword -e TIMES=10 -e FOLDERID=a123b45c678d910 multilogin-container

If you don't run it with the env variables, it will not work.

Important:

Password must be encrypted with MD5
TIMES variable passes how many profiles you want to create. If you want to create 500 profiles, you can
All profiles will be created in intervals of 10 seconds
All profiles will be created in the specified folder with the name "Created by Docker"
Docker engine must be running in the background
