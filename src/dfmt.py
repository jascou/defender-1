import sys,os

list=[ i for i in os.listdir(".") if i[-1]=="d" ]

for f in list:

    os.system("dfmt --inplace "+f )
