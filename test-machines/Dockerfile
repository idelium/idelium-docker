FROM ubuntu:latest
RUN apt-get update && apt-get install -y firefox && apt-get install -y wget
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -y libcurl3-gnutls fonts-liberation libdrm2 libgbm1 libnspr4 libnss3 xdg-utils libu2f-udev udev
RUN apt install ./google-chrome-stable_current_amd64.deb
RUN apt-get install -y python3.8 python3-pip
RUN pip install selenium 
RUN pip install Appium-Python-Client
RUN pip install requests Image
RUN pip install webdriver-manager

RUN echo "cd /var/idelium-cl;/usr/bin/python3 ideliumcl.py --ideliumServer --verbose --ideliumServerPort=1968 --ideliumws_baseurl=http://ideliumfe" > start.sh
CMD ["/usr/bin/firefox"]
