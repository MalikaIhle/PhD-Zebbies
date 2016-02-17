## Malika Ihle 08/07/2014
## C-NC Breeding 2014 (Season 3: divorce exp)

## 2by2by2 contingency table

# Cochran-Mantel-Haenszel test


m <- data.frame(
Trt=c(
'C',
'C',
'NC',
'NC',
'C',
'C',
'NC',
'NC'),
StayNew=c(
'Stay',
'Stay',
'Stay',
'Stay',
'New',
'New',
'New',
'New'),
YN=c(
'Y',
'N',
'Y',
'N',
'Y',
'N',
'Y',
'N'),
Count=c(
3,
2,
2,
4,
4,
7,
1,
11)
)
m

## Relationship Trt and YN while controlling for StayNew
# Make a 3D contingency table, where the last variable, StayNew, is the one to control for.
md <- xtabs(Count ~ Trt + YN + StayNew, data= m)

# print it flat
ftable(md)

# just to print it differently
ftable(md, row.vars=c("StayNew","YN"), col.vars="Trt")


mantelhaen.test(md) # > no relationship (p=0.17) between Trt and YN while controlling for StayNew



## Relationship StayNew and YN while controlling for Trt
mf <- xtabs(Count ~ StayNew + YN + Trt, data= m)
mantelhaen.test(mf) # > no relationship (p=0.28) between StayNew and YN while controlling for Trt








