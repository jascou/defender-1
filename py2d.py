import sys, re, os

def doit(inname):
    
    outname=inname.split(".")[0]+".d"

    inf=open("src/"+inname,"r")
    outf=open(outname,"w")

    for l in inf:

        if re.search("if.*:",l)!= None:
            l0=re.sub(":","",l)
            ll=l0.split()
            out=ll[0]+"("+"".join(ll[1:])+"){"
        else:
            if re.search("[#:;{}]",l)==None \
            and len(l.split()) > 0 \
            and re.search("if",l)==None \
            and re.search("else",l)==None \
            and re.search(", *$",l)==None:
                out=l[:-1]+";"
            else:
                out=l[:-1]

        print >>outf,out

        

    inf.close()
    outf.close()

for f in [ x for x in os.listdir("src") if re.search(".d",x ) != None ]:
    doit(f)
    
