# select operating system
FROM ubuntu:16.04

# install operating system packages 
RUN apt-get update -y &&  apt-get install git curl gettext unzip wget software-properties-common python python-software-properties python-pip python3-pip dnsutils make -y 

## add more packages, if necessary
# install Java8
RUN add-apt-repository ppa:webupd8team/java -y && apt-get update && apt-get -y install openjdk-8-jdk-headless

# install boto3 library for PySpark applications to connect to S3
RUN pip install boto3==1.9


# use bpkg to handle complex bash entrypoints
RUN curl -Lo- "https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh" | bash
RUN bpkg install cha87de/bashutil -g
## add more bash dependencies, if necessary 

# add config, init and source files 
# entrypoint
ADD init /opt/docker-init
ADD conf /opt/docker-conf

# folders
RUN mkdir /opt/apache-livy
RUN mkdir /var/apache-spark-binaries/

# binaries
# apache livy
RUN wget http://mirror.23media.de/apache/incubator/livy/0.5.0-incubating/livy-0.5.0-incubating-bin.zip -O /tmp/livy.zip
RUN unzip /tmp/livy.zip -d /opt/
# Logging dir
RUN mkdir /opt/livy-0.5.0-incubating-bin/logs

# apache spark
RUN wget https://archive.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz -O /tmp/spark-2.3.1-bin-hadoop2.7.tgz
RUN  tar -xvzf /tmp/spark-2.3.1-bin-hadoop2.7.tgz -C /opt/

# set Python3 as default
RUN rm  /usr/bin/python
RUN ln -s /usr/bin/python3 /usr/bin/python


 
# expose ports
EXPOSE 8998

# start from init folder
WORKDIR /opt/docker-init
ENTRYPOINT ["./entrypoint"]