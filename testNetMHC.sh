# run this script to test if all the stuff is configured correctly.

# testing netMHCpan
./netMHCpan/netMHCpan-2.8/netMHCpan -p ./netMHCpan/netMHCpan-2.8/test/test.pep > ./netMHCpan/netMHCpan-2.8/test/test.pep.myout
./netMHCpan/netMHCpan-2.8/netMHCpan ./netMHCpan/netMHCpan-2.8/test/test.fsa > test.fsa.myout
./netMHCpan/netMHCpan-2.8/netMHCpan -hlaseq ./netMHCpan/netMHCpan-2.8/test/B0702.fsa ./netMHCpan/netMHCpan-2.8/test/test.fsa > ./netMHCpan/netMHCpan-2.8/test/test.fsa_userMHC.myout

# testing netMHC
./netMHC/netMHC-3.4/netMHC -a HLA-A02:01 ./netMHC/netMHC-3.4/test/test.fsa > ./netMHC/netMHC-3.4/test/test.fsa.myout
./netMHC/netMHC-3.4/netMHC -a HLA-A02:01 -p ./netMHC/netMHC-3.4/test/test.pep > ./netMHC/netMHC-3.4/test/test.pep.myout


# testing pickpocket

./pickpocket/pickpocket-1.1/PickPocket -p ./pickpocket/pickpocket-1.1/test/test.pep > ./pickpocket/pickpocket-1.1/test/test.pep.myout
./pickpocket/pickpocket-1.1/PickPocket ./pickpocket/pickpocket-1.1/test/test.fsa > ./pickpocket/pickpocket-1.1/test/test.fsa.myout
./pickpocket/pickpocket-1.1/PickPocket -hlaseq ./pickpocket/pickpocket-1.1/test/B0702.fsa -p ./pickpocket/pickpocket-1.1/test/test.pep > ./pickpocket/pickpocket-1.1/test/test.pep_userMHC.myout



# testing cons installation
./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -a HLA-A02:01 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep.myout
./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -a HLA-B78:07 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep.myout
./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -a HLA-B78:07 -f ./netMHCcons/netMHCcons-1.1/test/test2.pep > ./netMHCcons/netMHCcons-1.1/test/test2.pep.myout

./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -a HLA-B14 -f ./netMHCcons/netMHCcons-1.1/test/test2.pep > ./netMHCcons/netMHCcons-1.1/test/test2.pep.myout

more ./netMHCcons/netMHCcons-1.1/test/test2.pep
more ./netMHCcons/netMHCcons-1.1/test/test.pep.myout




# test different lengths

./netMHC/netMHC-3.4/netMHC -a HLA-A02:01 -p ./netMHCcons/netMHCcons-1.1/test/test2.pep
./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -a HLA-B78:07 -f ./netMHCcons/netMHCcons-1.1/test/test2.pep > ./netMHCcons/netMHCcons-1.1/test/test2.pep.myout

wc /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8.pep

./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -a HLA-B78:07 -f /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8.pep > /home/witold/prog/systemhccake/systemhccake/test8.pep.txt

./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHC -inptype 1 -a HLA-A02:01 -f /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8.pep > /home/witold/prog/systemhccake/systemhccake/test8.mhc.txt
./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHCpan -inptype 1 -a HLA-A02:01 -f /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8.pep > /home/witold/prog/systemhccake/systemhccake/test8.pan.txt
./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHCcons -inptype 1 -a HLA-A02:01 -f /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8.pep > /home/witold/prog/systemhccake/systemhccake/test8.cons.txt

./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHCcons -inptype 1 -a HLA-B78:07 -f  /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8.pep > /home/witold/prog/systemhccake/systemhccake/test8.cons.B78.txt

./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHC -inptype 1 -a HLA-B78:07 -f /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8_15.pep


./netMHC/netMHC-3.4/netMHC -a HLA-A02:01 -p /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8_15.pep > /home/witold/prog/systemhccake/systemhccake/test8_15.pep.txt
./netMHC/netMHC-3.4/netMHC -a HLA-A02:01 -p /home/witold/prog/SysteMHC_Binaries/netMHCcons/netMHCcons-1.1/test/test8_15.pep


./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -a HLA-A02:01 -f ./netMHCcons/netMHCcons-1.1/test/peptides.pep > ./netMHCcons/netMHCcons-1.1/test/peptides.csv.myout
./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -a HLA-A02:01 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep.myout
./netMHCcons/netMHCcons-1.1/netMHCcons -inptype 1 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep.myout



####


./netMHCcons/netMHCcons-1.1/netMHCcons -f ./netMHCcons/netMHCcons-1.1/test/test.fsa > ./netMHCcons/netMHCcons-1.1/test/test.fsa.myout
./netMHCcons/netMHCcons-1.1/netMHCcons -hlaseq ./netMHCcons/netMHCcons-1.1/test/B0702.fsa -inptype 1 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep_userMHC.myout

./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHC -inptype 1 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep.myout.NetMHC
./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHC -f ./netMHCcons/netMHCcons-1.1/test/test.fsa > ./netMHCcons/netMHCcons-1.1/test/test.fsa.myout.NetMHC
./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHC -hlaseq ./netMHCcons/netMHCcons-1.1/test/B0702.fsa -inptype 1 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep_userMHC.myout.NetMHC

./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHCpan -inptype 1 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep.myout.NetMHCpan
./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHCpan -f ./netMHCcons/netMHCcons-1.1/test/test.fsa > ./netMHCcons/netMHCcons-1.1/test/test.fsa.myout.NetMHCpan
./netMHCcons/netMHCcons-1.1/netMHCcons -method NetMHCpan -hlaseq ./netMHCcons/netMHCcons-1.1/test/B0702.fsa -inptype 1 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep_userMHC.myout.NetMHCpan

./netMHCcons/netMHCcons-1.1/netMHCcons -method PickPocket -inptype 1 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep.myout.PickPocket
./netMHCcons/netMHCcons-1.1/netMHCcons -method PickPocket -f ./netMHCcons/netMHCcons-1.1/test/test.fsa > ./netMHCcons/netMHCcons-1.1/test/test.fsa.myout.PickPocket
./netMHCcons/netMHCcons-1.1/netMHCcons -method PickPocket -hlaseq ./netMHCcons/netMHCcons-1.1/test/B0702.fsa -inptype 1 -f ./netMHCcons/netMHCcons-1.1/test/test.pep > ./netMHCcons/netMHCcons-1.1/test/test.pep_userMHC.myout.PickPocket


# finally remove all myout files
find . -name "*.myout*" -exec rm -rf {} \;





