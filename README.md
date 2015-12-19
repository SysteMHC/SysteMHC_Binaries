# SysteMHC_Binaries

Binaries needed to run the systemMHC project. At the moment only binaries for gnu Linux tested on ubuntu 14.04 are available.
That is because some of the components of the workflow (gibscluster and netMHC) are only avaialable for linux.

Binaries are taken from the following sites:
- [netMHC](http://www.cbs.dtu.dk/services/NetMHC/)
- [gibscluster](http://www.cbs.dtu.dk/services/GibbsCluster/)

Myrimatch executable and comet executables are taken from [searchGUI](https://github.com/compomics/searchgui)

Tpp is build using the build script 
https://github.com/SysteMHC/SysteMHC_Binaries/blob/master/buildtpp.sh

For licences of the binaries published here please check the Licence.txt file (will be added soon).

Furthermore you will need to install:

## Install R on ubuntu
For details see:
https://cran.r-project.org/bin/linux/ubuntu/README

to run RnetMHC

Ubuntu 14.04 is Trusty Tahr
sudo deb https://cran.rstudio.com/bin/linux/ubuntu trusty/


## Infromation for installing netHMC on ubuntu linux 14.04

sudo apt-get install gawk
sudo apt-get install tcsh

edit the __nethcm__ tcsh script
 - On the first line of the script replace the string: /usr/local/python/bin/python
 - set NMHOME variable to to the full path to the 'netMHC-3.0'
 - set TMPDIR to a writeable directory

then download [net.tar.gz](http://www.cbs.dtu.dk/services/NetMHC-3.4/net.tar.gz)
and extract to the 
netMHC-3.4/etc 
directory...


 
