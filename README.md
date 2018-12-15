# DayZ Server in Docker

This repository contains files used to set up a DayZ server in Docker.

![Screenshot 1](docker/docs/screenshot_1.png)

# Building the image

1.  Run `./docker/create_steam_secret_data.sh <username> <password> [<authcode>]`.
    This will try to log you in and on success it will pack all needed authentication
    information needed during the actual image build into a file named `userdata.tar`.
2.  Now run `docker build .`. This will create the image.
