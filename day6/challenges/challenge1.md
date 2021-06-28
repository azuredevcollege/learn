# Challenge 1: Docker 101

⏲️ *Est. time to complete: 30 min.* ⏲️

## Here is what you will learn 🎯

In this challenge, we are learn how to use Docker CLI. After that we will run our first Docker Container. By the end of this challenge, we will have learned the basics of Docker containers, how to create, run, stop, delete, inspect and list them.

In this challenge you will:

- Learn to use the Docker CLI
- Create and run Docker containers
- List Docker containers and other objects
- Learn about Docker object names and IDs
- Inspect container details

## Table Of Contents

1. [Status of Docker](#status-of-docker)
2. [Information about Docker Installation](#information-about-docker-installation)
3. [The Docker CLI](#the-docker-cli)
4. [Our First Container](#our-first-container)
5. [Detach Containers](#detach-containers)
6. [Running another Application inside the Container](#running-another-application-inside-the-container)
7. [Connecting to a Docker Container](#connecting-to-a-docker-container)
8. [Inspecting Container Details](#inspecting-container-details)
9. [Wrap-Up](#wrap-up)

## Status of Docker

First let's check the current status of the Docker. Open your terminal and type:

```shell
docker version
```

The output will be something like:

```shell
Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b7f0
 Built:             Wed Mar 11 01:25:46 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       afacb8b
  Built:            Wed Mar 11 01:29:16 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
  ```

  If you have got a similar output, this means that your Docker installation is successful and your Docker CLI can communicate with the Docker Daemon without any problems.
  
  This output also shows us the Docker CLI - Docker Daemon versions and their details.
  
:::tip
📝 You might get the following response: ``` Error response from daemon: open \\.\pipe\docker_engine_linux: The system cannot find the file specified. ```. This means that the Docker CLI could not connect to the Docker Daemon. In that case the Docker Daemon might not have started properly. Just try to start the daemon process again and retry.
:::

## Information about Docker Installation

It's time to get more information about our Docker installation.

Type:

```shell
docker info
```

The output will be something like:

```shell
Client:
 Debug Mode: false

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 19.03.8
 Storage Driver: overlay2
  Backing Filesystem: <unknown>
  Supports d_type: true
  Native Overlay Diff: true
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 […]
 ```

 This command displays system wide information of Docker Daemon. The information displayed includes the kernel version, number of containers and images.

 At the moment, we don't have any running, paused or stopped containers on our system. Also we don't have any container images pulled yet. This will change in a few minutes. But before running our first Docker container, let's learn how to use Docker CLI.

## The Docker CLI

Let's see how to become a _Docker CLI_ master.

Type:

```shell
docker
```

The output will be something like:

```shell
Management Commands:
  app*        Docker Application (Docker Inc., v0.8.0)
  builder     Manage builds
  buildx*     Build with BuildKit (Docker Inc., v0.3.1-tp-docker)
  […]

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  build       Build an image from a Dockerfile
  commit      Create a new image from a container's changes
  […]
```

The Docker CLI makes it easy to figure out how to use it. Just type ```docker``` and after that type the command that you want to execute and the options that you want to use.

Some examples:

- Run ```docker run hello-world```. This will create a container by hello-world Docker image.
- Run```docker run --name azuredevcol hello-world```. This will create another container using the same image but this time container will have the name "azuredevcol".

Although this looks straightforward, it got complicated day after day. Docker had roughly 40 top-level solo commands like run, inspect, build, attach etc.

While these commands worked very well for a while, they had a few issues and Docker decided to solve these issues. Docker started to group these commands logically with Docker CLI version 1.13 and called these new groups _management commands_. Each group represents a single Docker object or ability. For example, all the commands related to container objects are grouped together under the "container" management command.

Going back to the previous example, the Docker command to run a container was ```docker run hello-world```. Now it's ```docker container run hello-world```. Docker CLI is backward-compatible so it still supports the old pattern but the management command approach is the future.

Let us recap the Docker CLI syntax. Type ```docker``` and after that type the management command of the object that you want to use, like ```image```, ```container```, ```volume``` and after that the command that you want to execute, like ```run```, ```stop```, ```pull```, ```inspect``` and the additional options that you want to use.

Here are some examples:

```shell
docker container run --name container1 busybox ping -c 5 www.bing.com

docker image pull mysql:5.7

docker volume create my_first_volume

docker network inspect bridge
```

How do we know which commands we can use and which options we have? By asking the Docker CLI for help.

Let's say that we want to create our first Docker container but we don't know which command and options that we can use. We can ask this to Docker CLI using the ```--help``` option.

Type:

```shell
docker container --help
```

The output will be something like:

```shell
Usage:  docker container COMMAND

Manage containers

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  […]
  rm          Remove one or more containers
  run         Run a command in a new container
  start       Start one or more stopped containers
  […]

Run 'docker container COMMAND --help' for more information on a command.
```

The ```--help``` option listed all the sub-commands under the container management command. Now we know which commands do we have and what are they used for.

We can even go further and ask for help for the sub-commands. For example.

Type:

```shell
docker container run --help
```

The output will be something like:

```shell
Usage:  docker container run [OPTIONS] IMAGE [COMMAND] [ARG...]

Run a command in a new container

Options:
      --add-host list                  Add a custom host-to-IP mapping
                                       (host:ip)
  -a, --attach list                    Attach to STDIN, STDOUT or STDERR
      --blkio-weight uint16            Block IO (relative weight),
                                       between 10 and 1000, or 0 to
                                       disable (default 0)
      --blkio-weight-device list       Block IO weight (relative device
                                       weight) (default [])
[…]
```

Congrats! We have learned how to use the Docker CLI and how to get help when we get stuck. We're now ready to play with Docker.

## Our First Container

It's time to run our first container. We'll create our container from Docker image tagged hello-world. Let's first check if this image is available on our system or not.

Type:

```shell
docker image ls
```

The output will be something like:

```shell
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```

The list is empty. We don't have any Docker image stored locally. Let's pull this image to the system.

Type:

```shell
docker image pull hello-world
```

The output will be something like:

```shell
Using default tag: latest
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:49a1c8800c94df04e9658809b006fd8a686cab8028d33cfba2cc049724254202
Status: Downloaded newer image for hello-world:latest
docker.io/library/hello-world:latest
```

Docker started to do its magic. We requested from Docker that "hey please find the image called ```hello-world``` and pull it into this system from wherever it is located." Docker did that. Docker pulled the image from Docker's default _Image Registry_ which is called _Docker Hub_.

If you don't specify in which image registry your image is stored, Docker assumes that it's stored at Docker Hub ```docker.io/library/hello-world```. We also wanted to pull an image called "hello-world" but as can be seen from the output, Docker pulled the image called **hello-world:latest**". What does the appendix **:latest** stand for?

An image name is made up of slash-separated name components and tags, optionally prefixed by a registry hostname. Registry hostnames represent in which registry an image is stored. Slash-separated name components represent the repository of the image in that image registry. The last part, which is called tag, represents the version of the image.

You can use it's meta-data to distinguish versions of your Docker images. **:latest** is the default tag used by Docker. If it's not tagged otherwise, images are tagged as **:latest** by default. And if you don't specify the tag while working with Docker images, Docker always assumes that you're pointing the image tagged as **:latest**.

Let's type ```docker image ls``` one more time:

```shell
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              bf756fb1ae65        6 months ago        13.3kB
```

The ```hello-world:latest``` image has been pulled into our system. Now we're ready to create and run our first Docker container.

Now type:

```shell
docker container run hello-world
```

The output will be something like:

```shell
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

Congratulations! You have created your first Docker container. But what has actually happened behind the scene?

You typed the command ```docker container run hello-world``` and instructed the Docker Daemon that you want to create a new container by the image called hello-world and run a command inside that container.

- The Docker CLI took your command and connected to Docker Daemon over its REST API and passed that command. to the Daemon
- The Docker Daemon checked if the image called ```hello-world:latest``` is stored locally or not. If it can not find the image locally, it will start to pull that from its registry. But we already pulled that image a few minutes ago, so it didn't pull it again.
- Docker created a new container from that image and assigned a random id to the container. It assigned a random name too, because we didn't specify any name using ```--name``` option on our command. After that, the container has been created. But it's only created, it has not been started yet. (a couple of other things also have happened like r/w layer, networks etc. but we'll come to these details later)
- Actually the ```docker container run``` command tells Docker that we want to run a command inside a new container. If it isn't specified which command to run, Docker runs the default command instructed on the image.

  In our case, we didn't specify any command to run inside the container. Therefore Docker started the container that it created and ran the default command instructed on the image. In our case this command is ```/hello```. "hello" is a very simple console application. When you run that, it echos ```"Hello from Docker! This message shows ..."``` message on the console and exits.
- Unless otherwise stated, Docker attaches to the container's shell and shows the output of that shell "stdout, stderr" on your console. That is the reason why we could see the output generated by the "/hello" application on our terminal.
  :::tip
  📝**Golden Rule:** Each Docker image has a default application-command to run, when a container is created from that image. This is instructed in the Docker image. But you can overwrite this instruction and point another application-command to run when the container is created. When Docker starts a container, it starts this command-application and also monitors the process which is triggered by this command-application. This application is always the PID1. Docker monitors the PID1. If PID1 continues to run, the container continues to run. If PID1 is killed or stopped, the container exits.
  :::
- In our case, it was the application called '/hello'. When we typed ```docker container run hello-world```, Docker created a new container from "hello-world" image and started it. The default application which has been instructed to run when a container has been created from hello-world image is "/hello".
  
  Therefore, "/hello" application has started. It has done what it is programmed for and when finished, it is closed. "/hello" isn't a daemon or long running service etc, so when it has done its job, it is closed. When Docker detected that the PID1 is not running any more, Docker closed the container too.  

Let's turn back to terminal and type:

```shell
docker container ls
```

The output will be something like:

```shell
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
````

```docker container ls``` or short ```docker ps``` command lists all the running containers on our system. At the moment, we do not have any running container so the list is empty. But if we add ```-a``` option to the command, we can list all both running and stopped containers. Let's do that and type:

```shell
docker ps -a
```

The output will be something like:

```shell
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
93a266670eb8        hello-world         "/hello"            56 minutes ago      Exited (0) 56 minutes ago                       amazing_wu
```

Finally we see the container that we created a few seconds ago on the list. ID and Name sections are different on your system. When Docker containers are created, the system automatically assigns a _universally unique identifier_ (UUID) number to each container. That is the case for other Docker objects like images, container, volume etc., too.

Each Docker object has a universally unique identifier. These are 64 character SHA-256 IDs. Docker commands truncate them to 12 characters and that's the reason why we saw just first 12 characters of the ID.

In addition to that, Docker assigns names to the containers. If we don't specify the name with ```--name``` option, Docker generates a random name using an open source list of adjectives and known figures in science and IT world.

We can use those IDs and names interchangeable when we call the container and we'll see couple of examples in a few minutes. Other sections on that list are:

- _Image_ is the image that was used to create this container.
- _Command_  is the command that was executed inside the container when we started it.
- _Created_ is the timestamp of the creation time.
- _Status_ is the current status of the container and in our case it is "Exited" which means that, container is stopped.
- _Ports_ section shows us the exposed ports from that container but it's empty at the moment because we didn't expose any port.

A container has been created and the "hello" application was started in the container. It has completed its duties and closed, therefore the container is closed too.

Let's continue to play with this container and start that container again. We will use the container id as a reference in this.

```shell
docker container start 93a # the first few characters of the container id would be enough
```

The output will be something like:

```shell
93a
```

We didn't get any output this time. Instead of that, Docker returned the container id that we typed. That is normal. When we typed the ```docker container run``` command and created the container a few minutes ago, our console has been attached to the container's shell and we saw the output.

With ```docker container start``` this doesn't happen. ```docker container start``` starts the stopped container and reruns the default command. In our case, it started the "hello" console application again. "hello" console application recreated the message and send it to the "stdout" stream of the console's shell. We didn't attach to that shell so we didn't see the output. But an output is there.

We can see any output that has been generated by the container with ```docker logs``` command. Let's do that but this time let's use the container's name instead of the id.

```shell
docker logs amazing_wu #name of the container
```

The output will be something like:

```shell
Hello from Docker!
This message shows that your installation appears to be working correctly.
[…]
Hello from Docker!
This message shows that your installation appears to be working correctly.
[…]
```

We saw two messages. By default, ```docker logs``` shows the command’s output as it would appear if you run the command interactively in a terminal.

UNIX and Linux commands typically open three I/O streams when they run, called STDIN, STDOUT, and STDERR.

- _STDIN_ is the command’s input stream, which may include input from the keyboard or input from another command.
- _STDOUT_ is usually a command’s normal output.
- _STDERR_ is typically used to output error messages.

By default, ```docker logs``` shows the STDOUT and STDERR streams of the container since it was created.

Our container wasn't killed. When we first ran the container, it was stopped automatically after its PID1 was stopped. We started the container one more time with ```docker container start``` command again.

The process was restarted, generated the same message and stopped again. The container was stopped too, but it wasn't killed. So we can still see all the STDOUT and STDERR messages since the creation of the container. But now it's time to kill "or delete" the container.

Type:

```shell
docker container rm 93a # or container name
```

The output will be something like:

```shell
93a
```

If you type ```docker ps -a``` now, the output should be empty.

***

## Detach Containers

We are going to create another container from the same hello-world:latest image. But this time we'll create it _detached_.

Docker containers start in the foreground mode by default. Like the one that we created a few minutes ago. In the foreground mode, Docker starts the default process in the container and attaches your console to the process’s STDIN, STDOUT and STDERR streams. When this happens, you can not access your own console anymore. You just see the output generated by the container on your screen.

To avoid this, we can start a container in the background mode which is also called detached and the option that gives you this ability is ```-d```. Running a container in the foreground or background modes don't change its behavior., it is just about if we want to attach to the container's streams or not.

Let's create a new container in the background "detached" and this time let's define a name too.

Type:

```shell
docker container run -d --name azuredevcoll hello-world
```

The output will be something like:

```shell
12fe24372acd0fed5f2063d35faaae13f2cb2e5f7d60f94ff86bec55ba272b1a
```

This time, instead of getting a message generated by hello app, Docker returned back the container id. A new container has been created using hello-world:latest image, the container has been started, the default application inside the container started, it did its thing, the app stopped and the container stopped, too.

If you type ```docker logs azuredevcoll``` , you see the logs generated by the application running inside the container.

Now let's create another container but we'll use another image ```httpd``` this time which is the official Apache HTTP Server Docker image.

Type:

```shell
docker container run -d --name webserver httpd
```

The output will be something like:

```shell
Unable to find image 'httpd:latest' locally
latest: Pulling from library/httpd
6ec8c9369e08: Pull complete
819d6e0b29e7: Pull complete
6a237d0d4aa4: Pull complete
cd9a987eec32: Pull complete
fdec8f3f8485: Pull complete
Digest: sha256:2a9ae199b5efc3e818cdb41c790638fc043ffe1aba6bc61ada28ab6356d044c6
Status: Downloaded newer image for httpd:latest
83d3a7cb8bd571d9f35688d80a4c676b3fe88f297d2170c5ea78d1c87dcd31aa
```

We requested from Docker to create a new container from the image called ```httpd:latest```, start it detached and gave it the name, "webserver". Docker took our command, checked the local image store and couldn't find the image called httpd. So it started to pull the image from Docker Hub.

As you can see from the output, it completed this pulling process in 5 steps. Docker pulled 5 different layers. We'll come to the topic of ```layers``` later but for now just notice that, this operation was handled as multiple steps.

At the end, Docker combined these layers, saved them to the local store and returned the id of the image. After that Docker created the container, started it and returned the container id. It also gave us our console back because we started the container in the background "detached" mode.

Type:

```shell
docker ps
```

The output will be something like:

```shell
CONTAINER ID        IMAGE               COMMAND              CREATED             STATUS              PORTS               NAMES
83d3a7cb8bd5        httpd               "httpd-foreground"   12 seconds ago      Up 12 seconds       80/tcp              webserver
```

As you can see from the output, the status of the container is "Up" and the main process running inside the container is "httpd-foreground".

httpd-foreground is Apache's web server daemon. It's not like the one shot hello-app console application. It's a service i.e. a daemon. When you start it, it continues to run until it crashes or is explicitly stopped or killed.

It's running at the moment so our container is running too. Remember the Golden Rule. If the first process inside the container runs, container continues to run too. If it stops, container stops too. Let's try to delete this container.

Type:

```shell
docker container rm webserver
```

The output will be something like:

```shell
Error response from daemon: You cannot remove a running container 83d3a7cb8bd571d9f35688d80a4c676b3fe88f297d2170c5ea78d1c87dcd31aa. Stop the container before attempting removal or force remove
```

As message says, you can't delete a running container. Either you have to stop the container first or you can force the deletion with ```-f``` option. Type ```docker container rm -f webserver``` to delete this container.

## Running another Application inside the Container

As mentioned before, each Docker image has a default application-command instructed in the image to run, when a container is created from that image. You can overwrite this command and point another command to run, when a container is created". Let's try that one. Again, we'll create a container from httpd image but this time we'll create it and run another application instead of the default "httpd-foreground".  

Type:

```shell
docker container run httpd date
```

The output will be something like:

```shell
Tue May 28 20:46:22 UTC 2020
```

We requested from Docker to create a new container from the ```httpd``` image and run the ```date``` command instead of the default "httpd-foreground".

Type:

```shell
docker ps -a
```

The output will be something like:

```shell
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
42227d141918        httpd               "date"              4 seconds ago       Exited (0) 2 seconds ago                       sad_yonath
```

As you can see, Docker did that, created a new container and ran the date application in it. You can also execute/run other commands/applications inside running containers.

The ```docker container exec``` command does that. Let's  give it a try.

First, we create a running container.

Type:

```shell
docker container run -d --name exec_test httpd
```

The output will be something like:

```shell
d0f1c26b80706f47ba4d676e285c771d7ed5c077c961be36dc73091893a784a9
```

Check and confirm that the container is running.

Type:

```shell
docker ps
```

The output will be something like:

```shell
CONTAINER ID        IMAGE               COMMAND              CREATED              STATUS              PORTS               NAMES
d0f1c26b8070        httpd               "httpd-foreground"   About a minute ago   Up About a minute   80/tcp              exec_test
```

Now we have a running container. We can execute new commands inside that container.

Type:

```shell
docker container exec exec_test date
```

The output will be something like:

```shell
Tue May 28 21:16:03 UTC 2020
```

You can run any application-command if this application exists inside the container. Let's delete the container before the next challenge.

Type:

```shell
docker container rm -f exec_test
```

The output will be something like:

```shell
exec_test
```

## Connecting to a Docker Container

In this challenge, we connect to a running container. Connecting to a running Docker container is helpful when you want to see what is happening inside the container. First, let's create a running container.

Type:

```shell
docker container run -d --name azuredevcoll httpd
```

The output will be something like:

```shell
3e9574a7ed458ff1d2343404a1c24f3361f18f1dabf52a75da0d0b4030723c82
```

Check and confirm that the container is running.

Type:

```shell
docker ps
```

The output will be something like:

```shell
CONTAINER ID        IMAGE               COMMAND              CREATED             STATUS              PORTS               NAMES
3e9574a7ed45        httpd               "httpd-foreground"   7 seconds ago       Up 7 seconds        80/tcp              azuredevcol
```

Now, we have a running container named ```azuredevcoll```. We want to connect to this container's shell.

We must distinguish: We do not want to _attach_ to this container's running process' STDOUT and STDERR streams. We want to _run a shell inside the container_ and _attach_ to that shell.

To be able to do that, we use ```docker container exec``` command. This time we need 2 more options, which are ```--interactive``` and ```--tty```. "Interactive" means that you want to keep the input channel open on the container and "tty" means that you're creating pseudo terminal. We can combine them via ```-it```.

Long story short ```-it``` tells Docker to allocate pseudo-TTY connected to the container’s stdin and create an interactive shell in the container.

Type:

```shell
docker exec -it azuredevcoll sh
```

The output will be something like:

```shell
#
```

Our shell prompt changed to ```#``` and this means that we're connected to the container. We executed the ```sh``` command inside the running container with ```-it``` options. This allowed us to connect a running "sh" instance inside the container.

Let's type couple of commands to proof that we're in the container.

```shell
# echo $0
sh
# ls
bin  build  cgi-bin  conf  error  htdocs  icons  include  logs  modules
# date
Tue May 28 21:44:53 UTC 2020
# hostname
3e9574a7ed45
# exit
$
```

You can delete this container by typing ```docker container rm -f azuredevcoll```.

:::warning
⚠️ The ```docker container prune``` command deletes all stopped containers as bulk. Use it with caution.
:::

## Inspecting Container Details

The commands ```docker ps``` or ```docker container ls``` show us the list of running containers on the system. If you add ```-a``` option, you can list both _running_ and _stopped_ containers.

The output of these commands show us only limited details about containers. If you want to get all the information related to a specific container, you should use ```docker container inspect``` command. Let's try this. First let's create a container.

Type:

```shell
docker container run -d --name inspect_test httpd
```

The output will be something like:

```shell
d4463417f9946f9d2cabfdca5ac81f45b7d2a2f4dc8299b9d36922b8d4b23111
```

With the "inspect" command we can see all the details of this or any container.

Type:

```shell
docker container inspect inspect_test
```

The output will be something like:

```shell
[
    {
        "Id": "d4463417f9946f9d2cabfdca5ac81f45b7d2a2f4dc8299b9d36922b8d4b23111",
        "Created": "2020-07-31T08:38:26.3847773Z",
        "Path": "httpd-foreground",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 1085,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2020-07-31T08:38:27.3829639Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        […]
        […]
        […]
        "Image": "sha256:9d2a0c6e5b5714303c7b72793311d155b1652d270a785c25b88197069ba78734",

                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }
    }
]
```

You can delete this container by typing ```docker container rm -f inspect_test```.

:::warning
⚠️ ```docker container prune``` command deletes all stopped containers as bulk. Use it with caution.
:::

## Wrap-Up

🎉 **_Congratulations_** 🎉

You have completed the Docker 101 challenge and learned very basics of Docker containers.

:::details
🔍 Reference: <https://docs.docker.com>
:::

[◀ Previous challenge](./challenge0.md) | [🔼 Day 6](../README.md) | [Next challenge ▶](./challenge2.md)
