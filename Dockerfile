FROM osrf/ros:kinetic-desktop-full

# Install pip
RUN apt-get update

# Need a build of Blender with COLLADA support
# Install autoconf for tmkit
RUN apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:thomas-schiex/blender && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y python-dev python-pip build-essential less wget nano vim autoconf

# Make bash execute ros setup
RUN echo 'source /opt/ros/kinetic/setup.bash' >> /root/.bashrc 

# Create ROS ws
RUN mkdir -p /root/catkin_ws/src && cd /root/catkin_ws

# Install dependencies
#RUN apt-get install -y libsdl-image1.2-dev && \
#    apt-get install -y libsdl-dev
#    apt-get install -y ros-melodic-moveit-core && \
#    apt-get install -y ros-melodic-tf2-sensor-msgs

# Install Fetch Melodic
RUN cd /root/catkin_ws/src && \
    git clone https://github.com/fetchrobotics/fetch_ros.git && \
    git clone https://github.com/fetchrobotics/fetch_gazebo.git && \
    git clone https://github.com/ros-planning/navigation.git && \
    git clone https://github.com/ros-planning/navigation_msgs.git

# Install special version of CLPython
RUN cd /root && \
    git clone https://github.com/metawilm/cl-python.git && \
    mkdir -p /root/.share/common-lisp/source && \
    ln -s /root/cl-python/clpython.asd /root/.share/common-lisp/source

# Amino dependencies
RUN apt-get install -y build-essential gfortran \
    autoconf automake libtool autoconf-archive autotools-dev \
    maxima libblas-dev liblapack-dev \
    libglew-dev libsdl2-dev \
    libfcl-dev libompl-dev \
    sbcl \
    default-jdk \
    blender flex povray ffmpeg
RUN wget https://beta.quicklisp.org/quicklisp.lisp
RUN sbcl --load quicklisp.lisp --eval '(quicklisp-quickstart:install)' --eval '(ql:add-to-init-file)' --eval '(quit)'

# Install Amino
RUN echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> /root/.bashrc
RUN mkdir -p ~/amino && \
    cd ~/amino && \
    git clone --recursive https://github.com/golems/amino.git

# Second line needed to break test.
# (If you want to install the "right" way, remove the second line. You will,
# however, need to allow Docker access to the "persistence" syscall.
RUN cd ~/amino/amino && \
    autoreconf -i && \
    ./configure && make && make install

RUN apt-get install z3

# Install tmkit
RUN ldconfig && \
    mkdir -p ~/tmkit && \
    cd ~/tmkit && \
    git clone https://github.com/kavrakilab/tmkit.git && \
    cd tmkit && \
    autoreconf -i && \
    ./configure && make && make install

RUN ldconfig

VOLUME ./files /code

