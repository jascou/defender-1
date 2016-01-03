import sys,re

c=0
for i in open("game.d","r"):

    if re.search("[{}]",i)!=None:
        if re.search("{",i)!=None:
            c+=1
        if re.search("}",i)!=None:
            c-=1
                 
        print c,i         
