import sys, os

out=open("list.out", "w" )

print os.getcwd()

for i in os.listdir(os.getcwd()):

    print i
    

    print >> out,i

out.close()
