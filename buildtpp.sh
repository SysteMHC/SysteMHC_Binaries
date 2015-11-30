# sudo apt-get install python-dev
# sudo apt-get install python-bzutils
TPP_INSTALL="/home/witold/prog/SysteMHC_Binaries/tpp/"

sudo apt-get -y install libnss-ldap libpam-ldap openssl ca-certificates
sudo apt-get uninstall libnss-ldap libpam-ldap openssl ca-certificates

#########
## TPP setup starts here

# Install components required for building the TPP
sudo apt-get install -y wget
sudo apt-get install -y build-essential
sudo apt-get install -y gnuplot # do I need this?
sudo apt-get install -y xsltproc
sudo apt-get install -y libgd2-dev
sudo apt-get install -y libbz2-dev
sudo apt-get install zlib1g-dev
sudo apt-get install -y libxml-libxml-perl # do i need this?
sudo apt-get install -y time

# Download the latest stable TPP
#
# NOTE change link in next line for different TPP versions
#
wget -O TPPsrc.tgz http://sourceforge.net/projects/sashimi/files/Trans-Proteomic%20Pipeline%20%28TPP%29/TPP%20v4.8%20%28philae%29%20rev%200/TPP_4.8.0-src.tgz/download
tar -zxf TPPsrc.tgz

# Configure and build the TPP
#
# NOTE change folder in next line for different TPP versions
#
cd TPP-4.8.0/trans_proteomic_pipeline/src/

# Setup custom configuration for build
echo "TPP_ROOT=$TPP_INSTALL" > Makefile.config.incl
echo "TPP_WEB=/tpp/" >> Makefile.config.incl
echo "XSLT_PROC=/usr/bin/xsltproc" >> Makefile.config.incl

# Build all 
# do not try to build with -j4 - breaks compilation
make all

# Install the TPP 
make install

# Since I only need some of the tools I do remove all the rest
rm -Rf $TPP_INSTALL/cgi-bin
rm -Rf $TPP_INSTALL/etc
rm -Rf $TPP_INSTALL/lib
rm -Rf $TPP_INSTALL/html
rm -f $TPP_INSTALL/bin/*.pl
