#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#	 Malika IHLE
#	 Breeding 2012 - 2013 Combined !
#	 Stats on breeding in aviaries
#	 Start : 10/01/2014
#	 last modif : 16/02/2016 MS sperm-phenotype
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 

 
{# IMPORTANT REMARKS

## Assigned parents : 
# for IF egg: social parents
# for broken eggs: social parents if gone before start of incubation (since 0302/2014)
# for eggs with genetic parents: genetic parents (even for EPY and dumped eggs since the 13/01/2014)
# for eggs without social parents(with Fate 1 or NA): genetic parents or nothing


## JoiningDate : 
# date of peergroup joining for chosen pairs
# date put in cage for non chosen pairs
# date put in aviary for new pairs

## PairingDate : 
# date of first egg in cage or 1/5 if didn't lay
# date first egg in aviary for new pairs 				( !! not date first time seen together !! )

## Subseting of the data :
# pair 107 18bb (2012) and pair 217 9cc (2013) were present less than 20% of the season and therefore not considered
# pair 185 3wo (2012) was formed on the 15/08/2012 and therefore not considered
# pair 87 3oo (2012) was considered to have divorced (female was secondary female then divorced)
# pair 61 16bb (2012) not considered to have divorced (female was secondary female all over)
# polygynous males (2012) 11037 (3oo) and 11190 (16bb) had their assigned female as secondary female: Pbdur are calculated for those females

## other remarks
# 6 eggs written twice in season 2013, normally with the appropriate data (clutch 914-852 and 824-842)
# change EggFate 2 to 1 when 'not for Uli' (broken, on the floor, burried before 13 days of incubation, no social parents)
# table Egg previously with 'StartIncubation Is Not Null'; from the 12/01/2014 include non-incubated eggs with or without social parents


## !!working directory!! : to change from _CURRENT BACK UP to Experiment or Desktop when home computer


## MS C-NC was written in R version 3.0.2, 
## MS sperm with R version 3.1.3 installed on the 19/03/2015,  
# model with little data do not run properly anymore, or do not run at all
# e.g. sperm Johannes DelatEp-WP, Slength give super small SD and increadibly high p values...
}

rm(list = ls(all = TRUE))
TimeStart <- Sys.time()


#######################################################################################################################
#######################################################################################################################
###############################################							###############################################
###############################################	   DATA MANIPULATION  	###############################################
###############################################							###############################################
#######################################################################################################################
#######################################################################################################################


	###############################
	## !! working directories !! ##
	###############################
	
require(RODBC)

#### server
# setwd("Z:\\Malika\\_CURRENT BACK UP\\Stats Breeding 2013\\")
# conDB= odbcConnectAccess("Z:\\Malika\\_CURRENT BACK UP\\ZebraFinchDBBielefeld.mdb")				
# conXL2012 = odbcConnectExcel2007("Z:\\Malika\\_CURRENT BACK UP\\Stats Breeding 2013\\BigBrother_Bielefeld_Malika2012.xlsx")
# conXL2013 = odbcConnectExcel2007("Z:\\Malika\\_CURRENT BACK UP\\Stats Breeding 2013\\BigBrother_Bielefeld_Malika2013.xlsx")
# conXLdiscrim2012 <- odbcConnectExcel2007("Z:\\Malika\\_CURRENT BACK UP\\Stats Breeding 2013\\DiscrimScoreBeforeBreeding2012CNC.xlsx")
# conXLdiscrim2013 <- odbcConnectExcel2007("Z:\\Malika\\_CURRENT BACK UP\\Stats Breeding 2013\\DiscrimScoreAfterBreeding2013CNC.xlsx")

#### laptop or office computer
conDB= odbcConnectAccess("C:\\Users\\mihle\\Documents\\_Malika_MPIO\\_CURRENT BACK UP\\ZebraFinchDBBielefeld.mdb")
conXL2012 = odbcConnectExcel2007("C:\\Users\\mihle\\Documents\\_Malika_MPIO\\_CURRENT BACK UP\\Stats Breeding 2013\\BigBrother_Bielefeld_Malika2012.xlsx")
conXL2013 = odbcConnectExcel2007("C:\\Users\\mihle\\Documents\\_Malika_MPIO\\_CURRENT BACK UP\\Stats Breeding 2013\\BigBrother_Bielefeld_Malika2013.xlsx")
conXLdiscrim2012 <- odbcConnectExcel2007("C:\\Users\\mihle\\Documents\\_Malika_MPIO\\_CURRENT BACK UP\\Stats Breeding 2013\\DiscrimScoreBeforeBreeding2012CNC.xlsx")
conXLdiscrim2013 <- odbcConnectExcel2007("C:\\Users\\mihle\\Documents\\_Malika_MPIO\\_CURRENT BACK UP\\Stats Breeding 2013\\DiscrimScoreAfterBreeding2013CNC.xlsx")
setwd("C:\\Users\\mihle\\Documents\\_Malika_MPIO\\_CURRENT BACK UP\\Stats Breeding 2013")




	######################################################################################
	## Creation of tables Breeding + Video data: upload data from DB + add informations ##
	######################################################################################

sqlTables(conDB)	

{#### table of existing breeding pairs (not necessarily laying): pairs1213

{pairs12 <- sqlQuery(conDB, "
SELECT BreedingAviary_Birds.Season, breedingpairs.Aviary, breedingpairs.M_ID AS MID, breedingpairs.F_ID AS FID, [BreedingAviary_Birds]![Ind_ID] & [BreedingAviary_Birds]![Season] AS MIDYear, [BreedingAviary_Birds_1]![Ind_ID] & [BreedingAviary_Birds_1]![Season] AS FIDYear, [Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID] AS MIDFID, breedingpairs.Pair_ID AS PairID, BreedingAviary_Birds.Treatment AS MTrt, BreedingAviary_Birds_1.Treatment AS FTrt, breedingpairs.ColourM_nestcards AS Mcol, breedingpairs.ColourF_nestcards AS Fcol, Breed_Pairs.VeryFirstPairingDate AS JoiningDate, Breed_Pairs.PairingStartDate AS PairingDate, Breed_Pairs.PairingEndDate, DateDiff('d',[Breed_Pairs]![VeryFirstPairingDate],#7/6/2012#) AS Pbdurlong, DateDiff('d',[Breed_Pairs]![PairingStartDate],#7/6/2012#) AS Pbdurshort, BreedingAviary_Birds.Polystatus AS MPolySt, BreedingAviary_Birds_1.Polystatus AS FPolySt, BreedingAviary_Birds_1.Divorced
FROM BreedingAviary_Birds AS BreedingAviary_Birds_1 INNER JOIN (BreedingAviary_Birds INNER JOIN ((SELECT Breed_Clutches.Aviary, Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.Pair_ID, Breed_Clutches.ColourM_nestcards, Breed_Clutches.ColourF_nestcards
FROM Breed_Clutches
GROUP BY Breed_Clutches.Aviary, Breed_Clutches.Experiment, Breed_Clutches.[K/W], Breed_Clutches.CageAviary, Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.Pair_ID, Breed_Clutches.ColourM_nestcards, Breed_Clutches.ColourF_nestcards
HAVING (((Breed_Clutches.Experiment)='force-pairing for choice' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice') AND ((Breed_Clutches.[K/W]) Is Not Null) AND ((Breed_Clutches.CageAviary)='A') AND ((Breed_Clutches.M_ID) Is Not Null))
ORDER BY Breed_Clutches.Pair_ID)  AS breedingpairs INNER JOIN Breed_Pairs ON breedingpairs.Pair_ID = Breed_Pairs.Pair_ID) ON BreedingAviary_Birds.Ind_ID = Breed_Pairs.M_ID) ON BreedingAviary_Birds_1.Ind_ID = Breed_Pairs.F_ID
GROUP BY BreedingAviary_Birds.Season, breedingpairs.Aviary, breedingpairs.M_ID, breedingpairs.F_ID, [BreedingAviary_Birds]![Ind_ID] & [BreedingAviary_Birds]![Season], [BreedingAviary_Birds_1]![Ind_ID] & [BreedingAviary_Birds_1]![Season], [Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID], breedingpairs.Pair_ID, BreedingAviary_Birds.Treatment, BreedingAviary_Birds_1.Treatment, breedingpairs.ColourM_nestcards, breedingpairs.ColourF_nestcards, Breed_Pairs.VeryFirstPairingDate, Breed_Pairs.PairingStartDate, Breed_Pairs.PairingEndDate, DateDiff('d',[Breed_Pairs]![VeryFirstPairingDate],#7/6/2012#), DateDiff('d',[Breed_Pairs]![PairingStartDate],#7/6/2012#), BreedingAviary_Birds.Polystatus, BreedingAviary_Birds_1.Polystatus, BreedingAviary_Birds_1.Divorced, BreedingAviary_Birds.Season, BreedingAviary_Birds_1.Season
HAVING (((BreedingAviary_Birds.Season)=2012) AND ((BreedingAviary_Birds_1.Season)=2012));

UNION

SELECT BreedingAviary_Birds.Season, BreedingAviary_Birds.Aviary, Breed_Pairs.M_ID AS MID, Breed_Pairs.F_ID AS FID, [BreedingAviary_Birds]![Ind_ID] & [BreedingAviary_Birds]![Season] AS MIDYear, [BreedingAviary_Birds_1]![Ind_ID] & [BreedingAviary_Birds_1]![Season] AS FIDYear, [Breed_Pairs]![M_ID] & [Breed_Pairs]![F_ID] AS MIDFID, Breed_Pairs.Pair_ID, BreedingAviary_Birds.Treatment AS MTrt, BreedingAviary_Birds_1.Treatment AS FTrt, Breed_Pairs.ColourM AS Mcol, Breed_Pairs.ColourF AS Fcol, Breed_Pairs.VeryFirstPairingDate AS JoiningDate, Breed_Pairs.PairingStartDate AS PairingDate, Breed_Pairs.PairingEndDate, DateDiff('d',[Breed_Pairs]![VeryFirstPairingDate],#5/25/2012#) AS Pbdurlong, DateDiff('d',[Breed_Pairs]![PairingStartDate],#5/25/2012#) AS Pbdurshort, BreedingAviary_Birds.Polystatus AS MPolySt, BreedingAviary_Birds_1.Polystatus AS FPolySt, BreedingAviary_Birds_1.Divorced
FROM BreedingAviary_Birds AS BreedingAviary_Birds_1 INNER JOIN (Breed_Pairs INNER JOIN BreedingAviary_Birds ON Breed_Pairs.M_ID = BreedingAviary_Birds.Ind_ID) ON BreedingAviary_Birds_1.Ind_ID = Breed_Pairs.F_ID
WHERE (((BreedingAviary_Birds.Season)=2012) AND ((Breed_Pairs.Pair_ID)=107));
")	
}		

nrow(pairs12)			# 59: includes 2 males polygynous > 11037 vaguely (3oo pair 87: the assigned female was kind of secondary female then she found another partner at the end of the season (3oo divorcedYN= yes): 3wo pair 185), 11190 simultaneously (the assigned female is the secondary female, male and secondary female not considered to have divorced, couple with primery female yes); UNION one pair removed from the first day (107 18bb female died)

{pairs13 <- sqlQuery(conDB, "
SELECT BreedingAviary_Birds.Season, breedingpairs.Aviary, breedingpairs.M_ID AS MID, breedingpairs.F_ID AS FID, [BreedingAviary_Birds]![Ind_ID] & [BreedingAviary_Birds]![Season] AS MIDYear, [BreedingAviary_Birds_1]![Ind_ID] & [BreedingAviary_Birds_1]![Season] AS FIDYear, [Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID] AS MIDFID, breedingpairs.Pair_ID AS PairID, BreedingAviary_Birds.Treatment AS MTrt, BreedingAviary_Birds_1.Treatment AS FTrt, breedingpairs.ColourM_nestcards AS Mcol, breedingpairs.ColourF_nestcards AS Fcol, Breed_Pairs.VeryFirstPairingDate AS JoiningDate, Breed_Pairs.PairingStartDate AS PairingDate, Breed_Pairs.PairingEndDate, IIf([Breed_Pairs.PairingEndDate]<#7/6/2013#,DateDiff('d',Breed_Pairs!VeryFirstPairingDate,[Breed_Pairs.PairingEndDate]),DateDiff('d',Breed_Pairs!VeryFirstPairingDate,#7/6/2013#)) AS Pbdurlong, IIf([Breed_Pairs.PairingEndDate]<#7/6/2013#,DateDiff('d',Breed_Pairs!PairingStartDate,[Breed_Pairs.PairingEndDate]),DateDiff('d',Breed_Pairs!PairingStartDate,#7/6/2013#)) AS Pbdurshort, BreedingAviary_Birds.Polystatus AS MPolySt, BreedingAviary_Birds_1.Polystatus AS FPolySt, BreedingAviary_Birds.Divorced
FROM BreedingAviary_Birds AS BreedingAviary_Birds_1 INNER JOIN (BreedingAviary_Birds INNER JOIN (Breed_Pairs INNER JOIN (SELECT Breed_Clutches.Aviary, Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.Pair_ID, Breed_Clutches.ColourM_nestcards, Breed_Clutches.ColourF_nestcards FROM Breed_Clutches GROUP BY Breed_Clutches.Aviary, Breed_Clutches.Experiment, Breed_Clutches.[K/W], Breed_Clutches.CageAviary, Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.Pair_ID, Breed_Clutches.ColourM_nestcards, Breed_Clutches.ColourF_nestcards HAVING (((Breed_Clutches.Experiment)='force-pairing for choice s2' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice s2') AND ((Breed_Clutches.[K/W]) Is Not Null) AND ((Breed_Clutches.CageAviary)='A') AND ((Breed_Clutches.M_ID) Is Not Null)) ORDER BY Breed_Clutches.Pair_ID)  AS breedingpairs ON Breed_Pairs.Pair_ID=breedingpairs.Pair_ID) ON BreedingAviary_Birds.Ind_ID=breedingpairs.M_ID) ON BreedingAviary_Birds_1.Ind_ID=breedingpairs.F_ID
GROUP BY BreedingAviary_Birds.Season, breedingpairs.Aviary, breedingpairs.M_ID, breedingpairs.F_ID, [BreedingAviary_Birds]![Ind_ID] & [BreedingAviary_Birds]![Season], [BreedingAviary_Birds_1]![Ind_ID] & [BreedingAviary_Birds_1]![Season], [Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID], breedingpairs.Pair_ID, BreedingAviary_Birds.Treatment, BreedingAviary_Birds_1.Treatment, breedingpairs.ColourM_nestcards, breedingpairs.ColourF_nestcards, Breed_Pairs.VeryFirstPairingDate, Breed_Pairs.PairingStartDate, Breed_Pairs.PairingEndDate, (IIf([Breed_Pairs.PairingEndDate]<#7/6/2013#,DateDiff('d',Breed_Pairs!VeryFirstPairingDate,[Breed_Pairs.PairingEndDate]),DateDiff('d',Breed_Pairs!VeryFirstPairingDate,#7/6/2013#))), (IIf([Breed_Pairs.PairingEndDate]<#7/6/2013#,DateDiff('d',Breed_Pairs!PairingStartDate,[Breed_Pairs.PairingEndDate]),DateDiff('d',Breed_Pairs!PairingStartDate,#7/6/2013#))), BreedingAviary_Birds.Polystatus, BreedingAviary_Birds_1.Polystatus, BreedingAviary_Birds.Divorced, BreedingAviary_Birds.Season, BreedingAviary_Birds_1.Season
HAVING (((BreedingAviary_Birds.Season)=2013) AND ((breedingpairs.Pair_ID)<>187 And (breedingpairs.Pair_ID)<>214) AND ((BreedingAviary_Birds_1.Season)=2013));
")
}

nrow(pairs13)			# 42 (pair 187 (6nn) was removed because the female laid her first clutch as single before getting with male y ; pair 214 (6yy) divorced immediately), the pair 9cc 217 was remove 06/06/2013

head(pairs12)
head(pairs13)

pairs1213 <- rbind(pairs12[pairs12$Pbdurshort > 0,], pairs13)	# this remove 3wo that pair up 15/08/2012 
pairs1213$MIDFIDyr <- paste(pairs1213$MIDFID, pairs1213$Season, sep = "")

{# change the treatment 'stay' into C-NC
pairsStay <- pairs1213[pairs1213$MIDFID%in%unique(pairs1213$MIDFID[pairs1213$MTrt == "stay"]) & pairs1213$MTrt != "stay",]
# 14 stay, all of them were chosen among those that had kept the Trt in 2012

for (i in 1:nrow(pairs1213)){if (pairs1213$FTrt[i] == "stay") 
{pairs1213$MTrt[i] <- pairsStay$MTrt[pairs1213$PairID[i] == pairsStay$PairID]
pairs1213$FTrt[i] <- pairsStay$FTrt[pairs1213$PairID[i] == pairsStay$PairID]}}
  # pairs1213[pairs1213$PairID%in%pairsStay$PairID,]
}

{BrokenUpAssignedpairs12 <- sqlQuery(conDB, "
SELECT Breed_Clutches.Aviary, Breed_Pairs.Remarks, Breed_Pairs.Pair_ID AS PairID, Breed_Pairs.M_ID AS MID, Breed_Pairs.F_ID AS FID, [Breed_Pairs]![M_ID] & [Breed_Pairs]![F_ID] AS MIDFID, Breed_Pairs.VeryFirstPairingDate AS JoiningDate, Breed_Pairs.PairingStartDate AS PairingDate, Breed_Pairs.PairingEndDate, DateDiff('d',[Breed_Pairs]![VeryFirstPairingDate],[Breed_Pairs]![PairingEndDate]) AS Pbdurlong, DateDiff('d',[Breed_Pairs]![PairingStartDate],[Breed_Pairs]![PairingEndDate]) AS Pbdurshort, Breed_Pairs.ColourM AS Mcol, Breed_Pairs.ColourF AS Fcol, BreedingAviary_Birds.Polystatus AS MPolySt, BreedingAviary_Birds_1.Polystatus AS FPolySt
FROM BreedingAviary_Birds AS BreedingAviary_Birds_1 INNER JOIN (BreedingAviary_Birds INNER JOIN (Breed_Pairs INNER JOIN Breed_Clutches ON Breed_Pairs.FIDMIDp = Breed_Clutches.FIDMIDp) ON BreedingAviary_Birds.Ind_ID = Breed_Pairs.M_ID) ON BreedingAviary_Birds_1.Ind_ID = Breed_Pairs.F_ID
WHERE (((Breed_Pairs.Remarks)='divorced') AND ((Breed_Clutches.ClutchNo)=1) AND ((Breed_Clutches.CageAviary)='A') AND ((Breed_Pairs.Occasion)='force-pairing for choice') AND ((BreedingAviary_Birds.Experiment)='force-pairing for choice') AND ((BreedingAviary_Birds_1.Experiment)='force-pairing for choice'))
ORDER BY Breed_Clutches.Aviary;
")
}

BrokenUpAssignedpairs12
}

head(pairs1213)

{#### table Eggs (without EggFate NA but can be without social parents)

{alles12 <- sqlQuery(conDB, 
"SELECT BreedingAviary_Birds2012_5.Season, alleggs2012.ClutchID, alleggs2012.Aviary, alleggs2012.PairTrt, alleggs2012.ClutchNo, alleggs2012.Pair_ID AS PairID, alleggs2012.M_ID AS MID, alleggs2012.MTrt, alleggs2012.F_ID AS FID, alleggs2012.FTrt, [M_ID] & [F_ID] AS MIDFIDSoc, alleggs2012.ClutchStart, alleggs2012.ClutchEnd, alleggs2012.StartIncubation, alleggs2012.ClutchSize, alleggs2012.EggID, alleggs2012.EggNoClutch, alleggs2012.LayingDate, alleggs2012.EggVolume, alleggs2012.EggFate, alleggs2012.Ind_ID, alleggs2012.SexMol, alleggs2012.M_Gen AS MGen, alleggs2012.MGenTrt, alleggs2012.F_Gen AS FGen, alleggs2012.FGenTrt, [M_Gen] & [F_Gen] AS MIDFIDGen, alleggs2012.DumpedEgg, alleggs2012.EPY, alleggs2012.Mass, BreedingAviary_Birds2012_4.Treatment AS MassTrt, alleggs2012.Fass, BreedingAviary_Birds2012_5.Treatment AS FassTrt, [Mass] & [Fass] AS MIDFIDass, alleggs2012.HatchDate, alleggs2012.HatchOrder, alleggs2012.Mass8dChick, alleggs2012.FledgeDate, alleggs2012.DateChickDied, alleggs2012.EmbryoDiedAge, alleggs2012.HatchOrderSurv, alleggs2012.DateOut, alleggs2012.Remarks
FROM (SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_5 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_4 RIGHT JOIN 

(SELECT Breed_Clutches.ClutchID, Breed_Clutches.Aviary, Breed_Clutches.Treatments AS PairTrt, Breed_Clutches.ClutchNo, Breed_Clutches.Pair_ID, Breed_Clutches.M_ID, BreedingAviary_Birds2012.Treatment AS MTrt, Breed_Clutches.F_ID, BreedingAviary_Birds2012_1.Treatment AS FTrt, Breed_Clutches.ClutchStart, Breed_Clutches.ClutchEnd, Breed_Clutches.StartIncubation, Breed_Clutches.ClutchSize, Breed_EggsLaid.EggID, Breed_EggsLaid.EggNoClutch, Breed_EggsLaid.LayingDate, Breed_EggsLaid.EggVolume, Breed_EggsLaid.EggFate, Breed_EggsLaid.Ind_ID, Breed_EggsLaid.SexMol, Breed_EggsLaid.M_Gen, BreedingAviary_Birds2012_2.Treatment AS MGenTrt, Breed_EggsLaid.F_Gen, BreedingAviary_Birds2012_3.Treatment AS FGenTrt, Breed_EggsLaid.DumpedEgg, Breed_EggsLaid.EPY, IIf([Breed_Clutches]![StartIncubation]-[Breed_EggsLaid]![DateFate1]>=0,0,(IIf([Breed_EggsLaid]![M_Gen] Is Not Null,[Breed_EggsLaid]![M_Gen],[Breed_Clutches]![M_ID]))) AS Mass, IIf([Breed_Clutches]![StartIncubation]-[Breed_EggsLaid]![DateFate1]>=0,0,(IIf([Breed_EggsLaid]![F_Gen] Is Not Null,[Breed_EggsLaid]![F_Gen],[Breed_Clutches]![F_ID]))) AS Fass, Breed_EggsIncubated.HatchDate, Breed_EggsIncubated.HatchOrder, Breed_EggsIncubated.Mass8dChick, Breed_EggsIncubated.FledgeDate, Breed_EggsIncubated.DateChickDied, Breed_EggsIncubated.EmbryoDiedAge, Breed_EggsIncubated.HatchOrderSurv, Breed_EggsIncubated.DateOut, Breed_EggsLaid.Remarks
FROM ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_3 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_2 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_1 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012 RIGHT JOIN (Breed_Clutches LEFT JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID) ON BreedingAviary_Birds2012.Ind_ID = Breed_Clutches.M_ID) ON BreedingAviary_Birds2012_1.Ind_ID = Breed_Clutches.F_ID) ON BreedingAviary_Birds2012_2.Ind_ID = Breed_EggsLaid.M_Gen) ON BreedingAviary_Birds2012_3.Ind_ID = Breed_EggsLaid.F_Gen) LEFT JOIN Breed_EggsIncubated ON Breed_EggsLaid.EggID = Breed_EggsIncubated.EggID
WHERE (((Breed_Clutches.Experiment)='force-pairing for choice' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice') AND ((Breed_Clutches.CageAviary)='A'))
ORDER BY Breed_EggsLaid.EggFate, Breed_EggsLaid.DumpedEgg DESC , Breed_EggsLaid.EPY DESC)  AS alleggs2012 

ON BreedingAviary_Birds2012_4.Ind_ID = alleggs2012.Mass) ON BreedingAviary_Birds2012_5.Ind_ID = alleggs2012.Fass;

")
}

nrow(alles12)	# 781 lines

alles12$Season <- 2012	# Season for eggs with no social parents or genetic parents

Eggs12 <- alles12[complete.cases(alles12[,"EggFate"]),]	# take only eggs were egg fate was known (3 'I broke it', eggs not incubated by social parents and not genotyped)

nrow(Eggs12)	# 761 eggs considered with fate <> NA


{alles13 <- sqlQuery(conDB, 
"SELECT BreedingAviary_Birds2013_5.Season, alleggs2013.ClutchID, alleggs2013.Aviary, alleggs2013.PairTrt, alleggs2013.ClutchNo, alleggs2013.Pair_ID AS PairID, alleggs2013.M_ID AS MID, alleggs2013.MTrt, alleggs2013.F_ID AS FID, alleggs2013.FTrt, [M_ID] & [F_ID] AS MIDFIDSoc, alleggs2013.ClutchStart, alleggs2013.ClutchEnd, alleggs2013.StartIncubation, alleggs2013.ClutchSize, alleggs2013.EggID, alleggs2013.EggNoClutch, alleggs2013.LayingDate, alleggs2013.EggVolume, alleggs2013.EggFate, alleggs2013.Ind_ID, alleggs2013.SexMol, alleggs2013.M_Gen AS MGen, alleggs2013.MGenTrt, alleggs2013.F_Gen AS FGen, alleggs2013.FGenTrt, [M_Gen] & [F_Gen] AS MIDFIDGen, alleggs2013.DumpedEgg, alleggs2013.EPY, alleggs2013.Mass, BreedingAviary_Birds2013_4.Treatment AS MassTrt, alleggs2013.Fass, BreedingAviary_Birds2013_5.Treatment AS FassTrt, [Mass] & [Fass] AS MIDFIDass, alleggs2013.HatchDate, alleggs2013.HatchOrder, alleggs2013.Mass8dChick, alleggs2013.FledgeDate, alleggs2013.DateChickDied, alleggs2013.EmbryoDiedAge, alleggs2013.HatchOrderSurv, alleggs2013.DateOut, alleggs2013.Remarks
FROM (SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_5 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_4 RIGHT JOIN 

(SELECT Breed_Clutches.ClutchID, Breed_Clutches.Aviary, Breed_Clutches.Treatments AS PairTrt, Breed_Clutches.ClutchNo, Breed_Clutches.Pair_ID, Breed_Clutches.M_ID, BreedingAviary_Birds2013.Treatment AS MTrt, Breed_Clutches.F_ID, BreedingAviary_Birds2013_1.Treatment AS FTrt, Breed_Clutches.ClutchStart, Breed_Clutches.ClutchEnd, Breed_Clutches.StartIncubation, Breed_Clutches.ClutchSize, Breed_EggsLaid.EggID, Breed_EggsLaid.EggNoClutch, Breed_EggsLaid.LayingDate, Breed_EggsLaid.EggVolume, Breed_EggsLaid.EggFate, Breed_EggsLaid.Ind_ID, Breed_EggsLaid.SexMol, Breed_EggsLaid.M_Gen, BreedingAviary_Birds2013_2.Treatment AS MGenTrt, Breed_EggsLaid.F_Gen, BreedingAviary_Birds2013_3.Treatment AS FGenTrt, Breed_EggsLaid.DumpedEgg, Breed_EggsLaid.EPY, IIf([Breed_Clutches]![StartIncubation]-[Breed_EggsLaid]![DateFate1]>=0,0,(IIf([Breed_EggsLaid]![M_Gen] Is Not Null,[Breed_EggsLaid]![M_Gen],[Breed_Clutches]![M_ID]))) AS Mass, IIf([Breed_Clutches]![StartIncubation]-[Breed_EggsLaid]![DateFate1]>=0,0,(IIf([Breed_EggsLaid]![F_Gen] Is Not Null,[Breed_EggsLaid]![F_Gen],[Breed_Clutches]![F_ID]))) AS Fass, Breed_EggsIncubated.HatchDate, Breed_EggsIncubated.HatchOrder, Breed_EggsIncubated.Mass8dChick, Breed_EggsIncubated.FledgeDate, Breed_EggsIncubated.DateChickDied, Breed_EggsIncubated.EmbryoDiedAge, Breed_EggsIncubated.HatchOrderSurv, Breed_EggsIncubated.DateOut, Breed_EggsLaid.Remarks
FROM ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_3 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_2 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_1 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013 RIGHT JOIN (Breed_Clutches LEFT JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID) ON BreedingAviary_Birds2013.Ind_ID = Breed_Clutches.M_ID) ON BreedingAviary_Birds2013_1.Ind_ID = Breed_Clutches.F_ID) ON BreedingAviary_Birds2013_2.Ind_ID = Breed_EggsLaid.M_Gen) ON BreedingAviary_Birds2013_3.Ind_ID = Breed_EggsLaid.F_Gen) LEFT JOIN Breed_EggsIncubated ON Breed_EggsLaid.EggID = Breed_EggsIncubated.EggID
WHERE (((Breed_Clutches.Experiment)='force-pairing for choice s2' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice s2') AND ((Breed_Clutches.CageAviary)='A'))
ORDER BY Breed_EggsLaid.EggFate, Breed_EggsLaid.DumpedEgg DESC , Breed_EggsLaid.EPY DESC)  AS alleggs2013 

ON BreedingAviary_Birds2013_4.Ind_ID = alleggs2013.Mass) ON BreedingAviary_Birds2013_5.Ind_ID = alleggs2013.Fass;
")
}

nrow(alles13)	# 715 total lines

alles13$Season <- 2013	# season for eggs without social parents

EggsnotNA13 <- alles13[complete.cases(alles13[,"EggFate"]),]	# take only eggs were egg fate was known (3 'I broke it', eggs not incubated by social parents and not genotyped)

Eggs13 <- subset (EggsnotNA13, EggsnotNA13$EggFate != -1)	# 24 eggs Fate -1 (laid after 21/08/2013)

nrow(Eggs13)	# 673 eggs considered	


head(Eggs12)
head(Eggs13)
Eggs <- rbind(Eggs12, Eggs13)
nrow(Eggs)		# 1434 eggs considered for 2012 + 2013


{# Assigned <- NA for eggs gone or burried before start of incubation and for eggs where nEggsAss per 2 days is > 3
Eggs$Fass[Eggs$Fass == 0] <- NA
Eggs$Mass[Eggs$Mass == 0] <- NA
Eggs$MIDFIDass[Eggs$MIDFIDass == 0] <- NA

Eggs$Fass[Eggs$EggID == 3891 | Eggs$EggID == 3893 | Eggs$EggID == 3309 | Eggs$EggID == 3310] <- NA
Eggs$Mass[Eggs$EggID == 3891 | Eggs$EggID == 3893 | Eggs$EggID == 3309 | Eggs$EggID == 3310] <- NA
Eggs$MIDFIDass[Eggs$EggID == 3891 | Eggs$EggID == 3893 | Eggs$EggID == 3309 | Eggs$EggID == 3310] <- NA
}

{# add MGen-, FGen- and Fass- Year

for (i in 1:nrow(Eggs)) 
{
if (!(is.na(Eggs$MGen[i]))) 
{Eggs$MGenYear[i] <- paste(Eggs$MGen[i],Eggs$Season[i], sep="")
 Eggs$FGenYear[i] <- paste(Eggs$FGen[i],Eggs$Season[i], sep="")}
else {Eggs$MGenYear[i] <- NA
	Eggs$FGenYear[i] <-NA}
if (!(is.na(Eggs$Fass[i]))) 	
{Eggs$FassYear[i] <- paste(Eggs$Fass[i],Eggs$Season[i], sep="")
Eggs$MassYear[i] <- paste(Eggs$Mass[i],Eggs$Season[i], sep="")}
else{Eggs$FassYear[i] <- NA
Eggs$MassYear[i] <- NA}
if (!(is.na(Eggs$FID[i]))) 
{Eggs$FIDYear[i] <- paste(Eggs$FID[i],Eggs$Season[i], sep="")
Eggs$MIDYear[i] <- paste(Eggs$MID[i],Eggs$Season[i], sep="")}
else{Eggs$FIDYear[i] <- NA
Eggs$MIDYear[i] <- NA}

}}

{# add ClutchAss (difference of 4 days between laying dates)

Eggs <- Eggs[order(Eggs$Fass, Eggs$LayingDate),]

Eggs$ClutchAss <- NA
Eggs$ClutchAss[1] <- 1 

for (i in 2:nrow(Eggs))
{ if (!(is.na(Eggs$Fass[i])))
	{ if((Eggs$LayingDate[i]-Eggs$LayingDate[i-1] < 5) & Eggs$Fass[i] == Eggs$Fass[i-1])
		{Eggs$ClutchAss[i] <- Eggs$ClutchAss[i-1]}
	else {Eggs$ClutchAss[i] <- Eggs$ClutchAss[i-1]+1}
}
 if (is.na(Eggs$Fass[i]))
	{Eggs$ClutchAss[i] <- NA }
}
}

{# add EggNoClutchAss

Eggs <- Eggs[order(Eggs$Fass, Eggs$LayingDate),]

Eggs$EggNoClutchAss[1] <- 1 

for (i in 2:nrow(Eggs))
{ if (!(is.na(Eggs$ClutchAss[i])))
	{ if(Eggs$ClutchAss[i] == Eggs$ClutchAss[i-1])
		{Eggs$EggNoClutchAss[i] <- Eggs$EggNoClutchAss[i-1] +1}
	else {Eggs$EggNoClutchAss[i] <- 1}
}
 if (is.na(Eggs$ClutchAss[i]))
	{Eggs$EggNoClutchAss[i] <- NA }
}
}

{# add egg fate x Yes or No, for each egg fate					

for (i in 1:nrow(Eggs)) 
{
if (Eggs$EggFate[i] >= 5) {Eggs$Fate56[i] <- 1}
else {Eggs$Fate56[i] <- 0}

if (Eggs$EggFate[i] == 3 | Eggs$EggFate[i] == 4) {Eggs$Fate34[i] <- 1}
else {Eggs$Fate34[i] <- 0}


if (Eggs$EggFate[i] == 3) {Eggs$Fate3[i] <- 1}
else {Eggs$Fate3[i] <- 0}
if (Eggs$EggFate[i] == 4) {Eggs$Fate4[i] <- 1}
else {Eggs$Fate4[i] <- 0}


if (Eggs$EggFate[i] == 2) {Eggs$Fate2[i] <- 1}
else {Eggs$Fate2[i] <- 0}

if (Eggs$EggFate[i] == 1) {Eggs$Fate1[i] <- 1}
else {Eggs$Fate1[i] <- 0}

if (Eggs$EggFate[i] == 0) {Eggs$Fate0[i] <- 1}
else {Eggs$Fate0[i] <- 0}

if (Eggs$EggFate[i] > 1) {Eggs$Fate23456[i] <- 1}
else {Eggs$Fate23456[i] <- 0}

if (Eggs$EggFate[i] > 2) {Eggs$Fate3456[i] <- 1}
else {Eggs$Fate3456[i] <- 0}

if (Eggs$EggFate[i] > 3) {Eggs$Fate456[i] <- 1}
else {Eggs$Fate456[i] <- 0}
}
}

{# add AgeChickDied, Fate 8d YN, FLYN
Eggs$AgeChickDied <- as.numeric(difftime( Eggs$DateChickDied, Eggs$HatchDate, units= 'days'))
for (i in 1: nrow(Eggs))
{
if (is.na(Eggs$HatchDate[i])) {Eggs$Fated8YN[i] <- NA }
if (!(is.na(Eggs$AgeChickDied[i])) & Eggs$AgeChickDied[i] > 8) {Eggs$Fated8YN[i] <- 1} 
if (!(is.na(Eggs$HatchDate[i]) & (is.na(Eggs$AgeChickDied[i])))) {Eggs$Fated8YN[i] <- 1} 
if (!(is.na(Eggs$AgeChickDied[i])) & Eggs$AgeChickDied[i] <= 8) {Eggs$Fated8YN[i] <- 0} 
}
head(Eggs[!(is.na(Eggs$AgeChickDied)),c('HatchDate','AgeChickDied','Fated8YN')],50)

for (i in 1: nrow(Eggs))
{
if (is.na(Eggs$HatchDate[i])) {Eggs$FLYN[i] <- NA }
if (!(is.na(Eggs$HatchDate[i]))& !(is.na(Eggs$FledgeDate[i]))) {Eggs$FLYN[i] <- 1} 
if (!(is.na(Eggs$HatchDate[i])) & is.na(Eggs$FledgeDate[i])) {Eggs$FLYN[i] <- 0} 
}

Eggs$AgeChickFL <- as.numeric(difftime( Eggs$FledgeDate, Eggs$HatchDate, units= 'days'))
Eggs$AgeChickDiedasFL <- Eggs$AgeChickDied-Eggs$AgeChickFL

}

{# change the treatment 'stay' into C-NC
pairsStay
head(Eggs[complete.cases(Eggs$FTrt)& Eggs$FTrt == 'stay',])

for (i in 1:nrow(Eggs))
{
if (!(is.na(Eggs$FTrt[i])) & Eggs$FTrt[i] == "stay") {Eggs$FTrt[i] <- pairsStay$FTrt[Eggs$FID[i] == pairsStay$FID]}
if (!(is.na(Eggs$MTrt[i])) & Eggs$MTrt[i] == "stay") {Eggs$MTrt[i] <- pairsStay$MTrt[Eggs$MID[i] == pairsStay$MID]}
if (!(is.na(Eggs$FGenTrt[i])) & Eggs$FGenTrt[i] == "stay") {Eggs$FGenTrt[i] <- pairsStay$FTrt[Eggs$FGen[i] == pairsStay$FID]}
if (!(is.na(Eggs$MGenTrt[i])) & Eggs$MGenTrt[i] == "stay") {Eggs$MGenTrt[i] <- pairsStay$MTrt[Eggs$MGen[i] == pairsStay$MID]}
if (!(is.na(Eggs$FassTrt[i])) & Eggs$FassTrt[i] == "stay") {Eggs$FassTrt[i] <- pairsStay$FTrt[Eggs$Fass[i] == pairsStay$FID]}
if (!(is.na(Eggs$MassTrt[i])) & Eggs$MassTrt[i] == "stay") {Eggs$MassTrt[i] <- pairsStay$MTrt[Eggs$Mass[i] == pairsStay$MID]}
}
}

}

head(Eggs)

{#### table allbirds (60*2 - 1*2 + 42*2 - 1*2 = 204 - 4 = 200)

{allbirds12 <- sqlQuery(conDB, "
SELECT BreedingAviary_Birds.Season, BreedingAviary_Birds.Aviary, BreedingAviary_Birds.Treatment, BreedingAviary_Birds.Ind_ID, [BreedingAviary_Birds]![Ind_ID] & [BreedingAviary_Birds]![Season] AS IDYear, BreedingAviary_Birds.Sex, BreedingAviary_Birds.Colour, BreedingAviary_Birds.DaysPresent, BreedingAviary_Birds.PercPresent, BreedingAviary_Birds.PercPaired, BreedingAviary_Birds.Polystatus, BreedingAviary_Birds.Divorced, BreedingAviary_Birds.IniDivorce, BreedingAviary_Birds.Remarks
FROM BreedingAviary_Birds
WHERE (((BreedingAviary_Birds.Experiment)='force-pairing for choice'));
")}	# include 18bb: 11264 and 11292

head(allbirds12)

{allbirds13 <- sqlQuery(conDB, "
SELECT BreedingAviary_Birds.Season, BreedingAviary_Birds.Aviary, BreedingAviary_Birds.Treatment, BreedingAviary_Birds.Ind_ID, [BreedingAviary_Birds]![Ind_ID] & [BreedingAviary_Birds]![Season] AS IDYear, BreedingAviary_Birds.Sex, BreedingAviary_Birds.Colour, BreedingAviary_Birds.DaysPresent, BreedingAviary_Birds.PercPresent, BreedingAviary_Birds.PercPaired, BreedingAviary_Birds.Polystatus, BreedingAviary_Birds.Divorced, BreedingAviary_Birds.IniDivorce, BreedingAviary_Birds.Remarks
FROM BreedingAviary_Birds
WHERE (((BreedingAviary_Birds.Experiment)='force-pairing for choice s2'));
")
}

head(allbirds13)

{# change treatment 'stay' into C-NC
for (i in 1:nrow(allbirds13)){if (allbirds13$Treatment[i] == "stay")
{allbirds13$Treatment[i] <- allbirds12$Treatment[allbirds13$Ind_ID[i] == allbirds12$Ind_ID]}}
}

allbirds <- rbind(allbirds12,allbirds13)	# 204

{# add StayYN
for (i in 1:nrow(allbirds))
{
if (allbirds$Ind_ID[i]%in%pairsStay$MID |  allbirds$Ind_ID[i]%in%pairsStay$FID) {allbirds$StayYN[i] <- 'stay'}
else {allbirds$StayYN[i] <- 'new'}
}
}

{# add PartnerID, MIDFID, MIDFIDYear, JoiningDate, PairingDate, Pbdurlong, Pbdurshort to allbirds

allbirds$PartnerID <- NA
allbirds$MIDFID <- NA
allbirds$JoiningDate <- NA
allbirds$PairingDate <- NA
allbirds$Pbdurlong <- NA
allbirds$Pbdurshort <- NA

for (i in 1:nrow(allbirds))
{
if (allbirds$Polystatus[i] == 'monogamous' | allbirds$Polystatus[i] == 'primery female' | allbirds$Polystatus[i] == 'secondary female')
{
if (allbirds$IDYear[i]%in%pairs1213$MIDYear){allbirds$PartnerID[i] <- pairs1213$FID[allbirds$IDYear[i] == pairs1213$MIDYear]}
else{allbirds$PartnerID[i] <- pairs1213$MID[allbirds$IDYear[i] == pairs1213$FIDYear]}

allbirds$MIDFID[i] <- pairs1213$MIDFID[allbirds$IDYear[i] == pairs1213$MIDYear | allbirds$IDYear[i] == pairs1213$FIDYear]
allbirds$JoiningDate[i] <- as.character(pairs1213$JoiningDate[allbirds$IDYear[i] == pairs1213$MIDYear | allbirds$IDYear[i] == pairs1213$FIDYear])
allbirds$PairingDate[i] <- as.character(pairs1213$PairingDate[allbirds$IDYear[i] == pairs1213$MIDYear | allbirds$IDYear[i] == pairs1213$FIDYear])
allbirds$PairingEndDate[i] <- as.character(pairs1213$PairingEndDate[allbirds$IDYear[i] == pairs1213$MIDYear | allbirds$IDYear[i] == pairs1213$FIDYear])
allbirds$Pbdurlong[i] <- pairs1213$Pbdurlong[allbirds$IDYear[i] == pairs1213$MIDYear | allbirds$IDYear[i] == pairs1213$FIDYear]
allbirds$Pbdurshort[i] <- pairs1213$Pbdurshort[allbirds$IDYear[i] == pairs1213$MIDYear | allbirds$IDYear[i] == pairs1213$FIDYear]
}

if (allbirds$Polystatus[i] == 'polygynous')	# their secondary female is the one that was assigned
{
if (allbirds$IDYear[i]%in%pairs1213$MIDYear){allbirds$PartnerID[i] <- pairs1213$FID[allbirds$IDYear[i] == pairs1213$MIDYear& pairs1213$FPolySt == 'secondary female']}

allbirds$MIDFID[i] <- pairs1213$MIDFID[allbirds$IDYear[i] == pairs1213$MIDYear & pairs1213$FPolySt == 'secondary female']
allbirds$JoiningDate[i] <-  as.character(pairs1213$JoiningDate[allbirds$IDYear[i] == pairs1213$MIDYear & pairs1213$FPolySt == 'secondary female'])
allbirds$PairingDate[i] <- as.character(pairs1213$PairingDate[allbirds$IDYear[i] == pairs1213$MIDYear & pairs1213$FPolySt == 'secondary female'])
allbirds$PairingEndDate[i] <- as.character(pairs1213$PairingEndDate[allbirds$IDYear[i] == pairs1213$MIDYear & pairs1213$FPolySt == 'secondary female'])
allbirds$Pbdurlong[i] <- pairs1213$Pbdurlong[allbirds$IDYear[i] == pairs1213$MIDYear & pairs1213$FPolySt == 'secondary female']
allbirds$Pbdurshort[i] <- pairs1213$Pbdurshort[allbirds$IDYear[i] == pairs1213$MIDYear & pairs1213$FPolySt == 'secondary female']
}

if (allbirds$Polystatus[i] == 'unpaired')
{
allbirds$PartnerID[i] <- NA
allbirds$MIDFID[i] <- BrokenUpAssignedpairs12$MIDFID[allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$MID | allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$FID]
allbirds$JoiningDate[i] <-  as.character(BrokenUpAssignedpairs12$JoiningDate[allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$MID | allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$FID])
allbirds$PairingDate[i] <- as.character(BrokenUpAssignedpairs12$PairingDate[allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$MID | allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$FID])
allbirds$PairingEndDate[i] <- as.character(BrokenUpAssignedpairs12$PairingEndDate[allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$MID | allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$FID])
allbirds$Pbdurlong[i] <- BrokenUpAssignedpairs12$Pbdurlong[allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$MID | allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$FID]
allbirds$Pbdurshort[i] <- BrokenUpAssignedpairs12$Pbdurshort[allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$MID | allbirds$Ind_ID[i] == BrokenUpAssignedpairs12$FID]
}
}

allbirds$MIDFIDYear <- paste(allbirds$MIDFID, allbirds$Season, sep="")
}

{# add Massd45

Massd45 <- sqlQuery(conDB, "SELECT DISTINCT BreedingAviary_Birds.Ind_ID, Morph_Measurements.Mass
FROM BreedingAviary_Birds INNER JOIN Morph_Measurements ON BreedingAviary_Birds.Ind_ID = Morph_Measurements.Ind_ID
WHERE (((BreedingAviary_Birds.Experiment)='force-pairing for choice s2' Or (BreedingAviary_Birds.Experiment)='force-pairing for choice') AND ((Morph_Measurements.Occasion)='d45'));
")

for (i in 1:nrow(allbirds)){
allbirds$Massd45[i]  <-  Massd45$Mass[Massd45$Ind_ID == allbirds$Ind_ID[i]]
}

}

{# remove birds that were not present for the whole season (18bb 4.65%, 9cc 18.28%): change calcul of relative fitness
allbirds <- subset (allbirds, allbirds$PercPresent > 20)
}

nrow(allbirds)	# 200
}

head(allbirds)

{#### table Pairing status

{AccessPairingStatus <- sqlQuery(conDB,"
SELECT BreedingAviary_PairingStatus.Season, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Ind_ID, BreedingAviary_PairingStatus.Sex, BreedingAviary_PairingStatus.Colour, BreedingAviary_PairingStatus.Date, BreedingAviary_PairingStatus.Day, BreedingAviary_PairingStatus.IDyrday, BreedingAviary_PairingStatus.pairedYN, BreedingAviary_PairingStatus.polyStatus, BreedingAviary_PairingStatus.PartnerID, BreedingAviary_PairingStatus.PartnerSex, BreedingAviary_PairingStatus.PartnerCol, BreedingAviary_PairingStatus.FIDMID, BreedingAviary_PairingStatus.Pairingdate, BreedingAviary_PairingStatus.dayspaired, BreedingAviary_PairingStatus.SecPartnerID, BreedingAviary_PairingStatus.SecPartnerSex, BreedingAviary_PairingStatus.SecPartnerCol, BreedingAviary_PairingStatus.WatchedYN, BreedingAviary_PairingStatus.RecPosition, DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch]) AS minVideo
FROM Basic_TrialsTreatments INNER JOIN BreedingAviary_PairingStatus ON Basic_TrialsTreatments.Ind_ID = BreedingAviary_PairingStatus.Ind_ID
WHERE (((BreedingAviary_PairingStatus.Season)=2012) AND ((Basic_TrialsTreatments.TrialTreatment)='force-pairing for choice'))
ORDER BY BreedingAviary_PairingStatus.Season, BreedingAviary_PairingStatus.Date, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Sex, BreedingAviary_PairingStatus.Ind_ID;
UNION
SELECT BreedingAviary_PairingStatus.Season, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Ind_ID, BreedingAviary_PairingStatus.Sex, BreedingAviary_PairingStatus.Colour, BreedingAviary_PairingStatus.Date, BreedingAviary_PairingStatus.Day, BreedingAviary_PairingStatus.IDyrday, BreedingAviary_PairingStatus.pairedYN, BreedingAviary_PairingStatus.polyStatus, BreedingAviary_PairingStatus.PartnerID, BreedingAviary_PairingStatus.PartnerSex, BreedingAviary_PairingStatus.PartnerCol, BreedingAviary_PairingStatus.FIDMID, BreedingAviary_PairingStatus.Pairingdate, BreedingAviary_PairingStatus.dayspaired, BreedingAviary_PairingStatus.SecPartnerID, BreedingAviary_PairingStatus.SecPartnerSex, BreedingAviary_PairingStatus.SecPartnerCol, BreedingAviary_PairingStatus.WatchedYN, BreedingAviary_PairingStatus.RecPosition, DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch]) AS minVideo
FROM Basic_TrialsTreatments INNER JOIN BreedingAviary_PairingStatus ON Basic_TrialsTreatments.Ind_ID = BreedingAviary_PairingStatus.Ind_ID
WHERE (((BreedingAviary_PairingStatus.Season)=2013) AND ((Basic_TrialsTreatments.TrialTreatment)='force-pairing for choice (s2)'))
ORDER BY BreedingAviary_PairingStatus.Season, BreedingAviary_PairingStatus.Date, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Sex, BreedingAviary_PairingStatus.Ind_ID;
")}

AccessPairingStatus$IDyrday <- paste(AccessPairingStatus$Ind_ID,AccessPairingStatus$Season,AccessPairingStatus$Day, sep="")
AccessPairingStatus$PartnerIDyrday <- paste(AccessPairingStatus$PartnerID,AccessPairingStatus$Season,AccessPairingStatus$Day, sep="")
nrow(AccessPairingStatus)	# 18644 rows

{# remove birds that were not present for the whole season (18bb 5days(2012), 9cc 17days (2013), 4yy 1day(2013))
PairingStatus <- AccessPairingStatus[is.na(AccessPairingStatus$FIDMID) | AccessPairingStatus$FIDMID != 1126411292 & AccessPairingStatus$FIDMID != 1132011021 & AccessPairingStatus$FIDMID != 1127211262,]
}

nrow(PairingStatus)	# 18598 rows
listdaysdates <- unique(PairingStatus[,c('Date', 'Day')])
}

head(PairingStatus)	

{#### table all courtships																		# !! sqlFetch !
AllCourtships2012 <- sqlFetch(conXL2012,"ALL2012")
close(conXL2012)
AllCourtships2012$Year <- 2012

AllCourtships2013 <- sqlFetch(conXL2013,"ALL2013")
close(conXL2013)
AllCourtships2013$Year <- 2013

AllCourt <- rbind(AllCourtships2012, AllCourtships2013)
head(AllCourt)

for (i in 1:nrow(AllCourt))  {AllCourt$Day[i] <- listdaysdates$Day[listdaysdates$Date == AllCourt$Date[i]]}

AllCourt$MIDyrday <- paste(AllCourt$MID, AllCourt$Year, AllCourt$Day, sep="")
AllCourt$FIDyrday <- paste(AllCourt$FID, AllCourt$Year, AllCourt$Day, sep="")
AllCourt$FIDMID <- paste(AllCourt$FID,AllCourt$MID,sep="")
AllCourt$MIDyr <- paste(AllCourt$MID, AllCourt$Year, sep="")
AllCourt$FIDyr <- paste(AllCourt$FID, AllCourt$Year, sep="")

for (i in 1:nrow(AllCourt)) {if (AllCourt$c012[i] != 0) {AllCourt$c012yn[i] <- 1} else {AllCourt$c012yn[i] <- 0}}

for (i in 1:nrow(AllCourt)){
if(AllCourt$Resp[i] < 0.5)
{AllCourt$RespPos[i] <- 0}
else{AllCourt$RespPos[i] <- 1}
}

for (i in 1:nrow(AllCourt)){
if( AllCourt$succ[i] != 0) {AllCourt$succYN[i] <- 1}
else {AllCourt$succYN[i] <- 0}
}

{# Courtship type: heterosexual (remove homosexual + those with juveniles)
AllCourt1 <- subset(AllCourt, AllCourt$CourtshipType == 1)	#4923 rows
AllCourt <- AllCourt1
}

{# Courtships without those where female died
# Courtship of individuals that were not present for the whole season (18bb 5days(2012), 9cc 17days (2013), 4yy 1day(2013))
courtsbeforefemaledied <- AllCourt[AllCourt$MID == 11292 | (AllCourt$MID == 11021 & AllCourt$Year == 2013)| (AllCourt$MID == 11262 & AllCourt$Year == 2013) | AllCourt$FID == 11264 | (AllCourt$FID == 11320 & AllCourt$Year == 2013)| (AllCourt$FID ==11272 & AllCourt$Year == 2013),]

AllCourtwithoutFemaledied <- AllCourt[!(AllCourt$FID == 11320 & AllCourt$Year == 2013),]
nrow(AllCourtwithoutFemaledied)	# 4918
AllCourt <- AllCourtwithoutFemaledied
}
}

head(AllCourt)

{#### table weather

weather <- sqlQuery (conDB, "
SELECT Weather.Date, Weather.MaxTemp20
FROM Weather
WHERE (((Weather.Date)>#12/31/2011# And (Weather.Date)<#9/30/2013#))
ORDER BY Weather.Date;
")

for (i in 1:nrow(weather))
{
weather$AvMaxTemp4d[i] <- (weather$MaxTemp20[i]+weather$MaxTemp20[i+1]+weather$MaxTemp20[i+2]+weather$MaxTemp20[i+3])/4
	# calculations are wrong for end september 2012 (taking values in beginning april 2013) 
}

for (i in 1:nrow(weather))
{
weather$TempInc[i] <- round(max(weather$AvMaxTemp4d[i],weather$AvMaxTemp4d[i+1],weather$AvMaxTemp4d[i+2],weather$AvMaxTemp4d[i+3],weather$AvMaxTemp4d[i+4],weather$AvMaxTemp4d[i+5],weather$AvMaxTemp4d[i+6],weather$AvMaxTemp4d[i+7],weather$AvMaxTemp4d[i+8],weather$AvMaxTemp4d[i+9],weather$AvMaxTemp4d[i+10],weather$AvMaxTemp4d[i+11],weather$AvMaxTemp4d[i+12]),2)

weather$TempHatch[i] <- round(max(weather$AvMaxTemp4d[i],weather$AvMaxTemp4d[i+1],weather$AvMaxTemp4d[i+2],weather$AvMaxTemp4d[i+3],weather$AvMaxTemp4d[i+4],weather$AvMaxTemp4d[i+5],weather$AvMaxTemp4d[i+6]),2)
}
}

head(weather)

{#### table NestCheck

NestCheck <- sqlQuery (conDB, "
SELECT Breed_NestChecks.ClutchID, Breed_Clutches.ClutchNo, Breed_NestChecks.Pair_ID, [Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID] AS MIDFID, Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.Treatments, Breed_Clutches.StartIncubation, Min(Breed_EggsLaid.LayingDate) AS MinLayingDate, Min(Breed_EggsIncubated.HatchDate) AS MinHatchDate, Max(Breed_EggsIncubated.HatchDate) AS MaxHatchDate, Min(Breed_EggsIncubated.FledgeDate) AS MinFledgeDate, Max(Breed_EggsIncubated.DateOut) AS MaxDateOut, Breed_Clutches.BroodSize, Max(Breed_EggsIncubated.DateChickDied) AS MaxDateChickDied, Breed_NestChecks.Date, Breed_NestChecks.Aviary, Breed_NestChecks.BoxID, Breed_NestChecks.NestBuildingCat, Breed_NestChecks.AttendenceData, Breed_NestChecks.Incubated, Breed_NestChecks.NestState, Breed_NestChecks.BroodJuvYN, Breed_NestChecks.JuvYN, Breed_NestChecks.NewEggYN, Breed_NestChecks.NumEggs, Breed_NestChecks.NumChicks, Breed_NestChecks.Remarks
FROM ((Breed_NestChecks INNER JOIN Breed_Clutches ON Breed_NestChecks.ClutchID = Breed_Clutches.ClutchID) LEFT JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID) LEFT JOIN Breed_EggsIncubated ON Breed_EggsLaid.ClutchID = Breed_EggsIncubated.ClutchID
GROUP BY Breed_NestChecks.ClutchID, Breed_Clutches.ClutchNo, Breed_NestChecks.Pair_ID, [Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID], Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.Treatments, Breed_Clutches.StartIncubation, Breed_Clutches.BroodSize, Breed_NestChecks.Date, Breed_NestChecks.Aviary, Breed_NestChecks.BoxID, Breed_NestChecks.NestBuildingCat, Breed_NestChecks.AttendenceData, Breed_NestChecks.Incubated, Breed_NestChecks.NestState, Breed_NestChecks.BroodJuvYN, Breed_NestChecks.JuvYN, Breed_NestChecks.NewEggYN, Breed_NestChecks.NumEggs, Breed_NestChecks.NumChicks, Breed_NestChecks.Remarks, Breed_Clutches.CageAviary, Breed_Clutches.Experiment
HAVING (((Breed_Clutches.CageAviary)='A') AND ((Breed_Clutches.Experiment)='force-pairing for choice' Or (Breed_Clutches.Experiment)='force-pairing for choice s2' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice s2'))
ORDER BY Breed_NestChecks.ClutchID, Breed_NestChecks.Date;
")

for (i in 1:nrow(NestCheck))
{
if(NestCheck$Date[i] < as.POSIXct("2013-01-01 CEST"))
{NestCheck$Year[i] <- 2012}
if(NestCheck$Date[i] > as.POSIXct("2013-01-01 CEST"))
{NestCheck$Year[i] <- 2013}
}

NestCheck$ClutchIDdate <- paste(NestCheck$ClutchID, NestCheck$Date, sep="")
NestCheck$FIDDate <- paste(NestCheck$F_ID, NestCheck$Date, sep="")

nrow(NestCheck) #7107


{# rmv duplicates FIDDate 
# overlapp of clutches in 2 nests: chose the one with chicks (something remove an entire clutchID), or if 2 clutches with chicks, chose the one where social parents are the genetic parents

NestCheck <- NestCheck[
NestCheck$ClutchID != 925 &  NestCheck$ClutchID != 840 &  NestCheck$ClutchID != 891 &  NestCheck$ClutchID !=928 &  NestCheck$ClutchID !=553 
& NestCheck$ClutchIDdate != "8472013-07-31" & NestCheck$ClutchIDdate != "8472013-08-01" 
& NestCheck$ClutchIDdate != "9072013-08-08"& NestCheck$ClutchIDdate != "9072013-08-09" & NestCheck$ClutchIDdate != "9072013-08-11" & NestCheck$ClutchIDdate != "9072013-08-12" 
& NestCheck$ClutchIDdate != "6042012-08-13" & NestCheck$ClutchIDdate != "6042012-08-14"& NestCheck$ClutchIDdate != "6042012-08-15"& NestCheck$ClutchIDdate != "6042012-08-16"& NestCheck$ClutchIDdate != "6042012-08-17"& NestCheck$ClutchIDdate != "6042012-08-18"& NestCheck$ClutchIDdate != "6042012-08-19"& NestCheck$ClutchIDdate != "6042012-08-20"& NestCheck$ClutchIDdate != "6042012-08-21"
& NestCheck$ClutchIDdate != "8462013-07-28"& NestCheck$ClutchIDdate != "8462013-07-29"& NestCheck$ClutchIDdate != "8462013-07-30"& NestCheck$ClutchIDdate != "8462013-07-28"& NestCheck$ClutchIDdate != "8462013-07-28"& NestCheck$ClutchIDdate != "8462013-07-28"& NestCheck$ClutchIDdate != "8462013-07-31"& NestCheck$ClutchIDdate != "8462013-08-01"& NestCheck$ClutchIDdate != "8462013-08-02"& NestCheck$ClutchIDdate != "8462013-08-03"& NestCheck$ClutchIDdate != "8462013-08-04"& NestCheck$ClutchIDdate != "8462013-08-05"& NestCheck$ClutchIDdate != "8462013-08-06"& NestCheck$ClutchIDdate != "8462013-08-07"& NestCheck$ClutchIDdate != "8462013-08-08"& NestCheck$ClutchIDdate != "8462013-08-09"& NestCheck$ClutchIDdate != "8462013-08-10"& NestCheck$ClutchIDdate != "8462013-08-11"& NestCheck$ClutchIDdate != "8462013-08-12"& NestCheck$ClutchIDdate != "8462013-08-13"& NestCheck$ClutchIDdate != "8462013-08-14"& NestCheck$ClutchIDdate != "8462013-08-15"& NestCheck$ClutchIDdate != "8462013-08-16"& NestCheck$ClutchIDdate != "8462013-08-17"& NestCheck$ClutchIDdate != "8462013-08-18"& NestCheck$ClutchIDdate != "8462013-08-19"& NestCheck$ClutchIDdate != "8462013-08-20"& NestCheck$ClutchIDdate != "8462013-08-21"& NestCheck$ClutchIDdate != "8462013-08-22"& NestCheck$ClutchIDdate != "8462013-08-23"& NestCheck$ClutchIDdate != "8462013-08-24"& NestCheck$ClutchIDdate != "8462013-08-25"& NestCheck$ClutchIDdate != "8462013-08-26"& NestCheck$ClutchIDdate != "8462013-08-27"& NestCheck$ClutchIDdate != "8462013-08-28"& NestCheck$ClutchIDdate != "8462013-08-29"& NestCheck$ClutchIDdate != "8462013-08-30"& NestCheck$ClutchIDdate != "8462013-08-31"& NestCheck$ClutchIDdate != "8462013-09-01"& NestCheck$ClutchIDdate != "8462013-09-02"& NestCheck$ClutchIDdate != "8462013-09-03"& NestCheck$ClutchIDdate != "8462013-09-04"& NestCheck$ClutchIDdate != "8462013-09-05"
& NestCheck$ClutchIDdate != "8732013-08-14"
& NestCheck$ClutchIDdate != "5882012-08-08"& NestCheck$ClutchIDdate != "5882012-08-09"& NestCheck$ClutchIDdate != "5882012-08-10"& NestCheck$ClutchIDdate != "5882012-08-11"& NestCheck$ClutchIDdate != "5882012-08-12"
& NestCheck$ClutchIDdate != "4912012-08-05"& NestCheck$ClutchIDdate != "4912012-08-06"
& NestCheck$ClutchIDdate != "8422013-07-05"& NestCheck$ClutchIDdate != "8422013-07-06"& NestCheck$ClutchIDdate != "8422013-07-07" & NestCheck$ClutchIDdate != "8422013-07-08"& NestCheck$ClutchIDdate != "8422013-07-09"& NestCheck$ClutchIDdate != "8422013-07-10"& NestCheck$ClutchIDdate != "8422013-07-11"& NestCheck$ClutchIDdate != "8422013-07-12"& NestCheck$ClutchIDdate != "8422013-07-13"& NestCheck$ClutchIDdate != "8422013-07-14"& NestCheck$ClutchIDdate != "8422013-07-15"& NestCheck$ClutchIDdate != "8422013-07-16"& NestCheck$ClutchIDdate != "8422013-07-17"& NestCheck$ClutchIDdate != "8422013-07-18"& NestCheck$ClutchIDdate != "8422013-07-19"& NestCheck$ClutchIDdate != "8422013-07-20"
& NestCheck$ClutchIDdate != "8522013-07-12"& NestCheck$ClutchIDdate != "8522013-07-13"& NestCheck$ClutchIDdate != "8522013-07-14"& NestCheck$ClutchIDdate != "8522013-07-15"& NestCheck$ClutchIDdate != "8522013-07-16"& NestCheck$ClutchIDdate != "8522013-07-17"& NestCheck$ClutchIDdate != "8522013-07-18"& NestCheck$ClutchIDdate != "8522013-07-19"& NestCheck$ClutchIDdate != "8522013-07-20"& NestCheck$ClutchIDdate != "8522013-07-21"& NestCheck$ClutchIDdate != "8522013-07-22"& NestCheck$ClutchIDdate != "8522013-07-23"& NestCheck$ClutchIDdate != "8522013-07-24"& NestCheck$ClutchIDdate != "8522013-07-25"& NestCheck$ClutchIDdate != "8522013-07-26"& NestCheck$ClutchIDdate != "8522013-07-27"& NestCheck$ClutchIDdate != "8522013-07-28"& NestCheck$ClutchIDdate != "8522013-07-29"& NestCheck$ClutchIDdate != "8522013-07-30"& NestCheck$ClutchIDdate != "8522013-07-31"& NestCheck$ClutchIDdate != "8522013-08-01"& NestCheck$ClutchIDdate != "8522013-08-02"& NestCheck$ClutchIDdate != "8522013-08-03"& NestCheck$ClutchIDdate != "8522013-08-04"& NestCheck$ClutchIDdate != "8522013-08-05"& NestCheck$ClutchIDdate != "8522013-08-06"& NestCheck$ClutchIDdate != "8522013-08-07"
& NestCheck$ClutchIDdate != "5682012-08-08"& NestCheck$ClutchIDdate != "5682012-08-09"& NestCheck$ClutchIDdate != "5682012-08-10"& NestCheck$ClutchIDdate != "5682012-08-11"& NestCheck$ClutchIDdate != "5682012-08-12"
& NestCheck$ClutchIDdate != "8652013-08-21"
,]



}

{# check if duplicates left
# length(unique(NestCheck$FIDDate))	# 6911
# length(NestCheck$FIDDate)	# 6911
# x <-table(NestCheck$FIDDate)
# x <- as.data.frame(x, responseName = "Freq")
# x <- x[x$Freq >1,]
# nrow(x)
}

nrow(NestCheck) # 6911

{# add nbDayswithchicks
for (i in 1:nrow(NestCheck))
{
if (is.na(NestCheck$MinHatchDate[i])) {NestCheck$nbDayswithchicks[i] <- 0}
if (!(is.na(NestCheck$MinHatchDate[i])) & !(is.na(NestCheck$MaxDateOut[i]))) {NestCheck$nbDayswithchicks[i] <- as.numeric(difftime(NestCheck$MaxDateOut[i],NestCheck$MinHatchDate[i],units='days'))}
if (!(is.na(NestCheck$MinHatchDate[i])) & is.na(NestCheck$MaxDateOut[i])) {NestCheck$nbDayswithchicks[i] <- as.numeric(difftime(NestCheck$MaxDateChickDied[i],NestCheck$MinHatchDate[i],units='days'))}
}
}

{# Change Trt 'Stay' into 'C' and 'NC'
for (i in 1:nrow(NestCheck))
{
if (!(is.na(NestCheck$Treatments[i])) & NestCheck$Treatments[i] == "stay") {NestCheck$Treatments[i] <- pairsStay$FTrt[NestCheck$F_ID[i] == pairsStay$FID]}
}
}

{# add AttendenceYN
for (i in 1: nrow(NestCheck)) {
if (NestCheck$AttendenceData[i] == 3) {NestCheck$Attendence3YN[i] <- 1} else {NestCheck$Attendence3YN[i] <- 0}
if (NestCheck$AttendenceData[i] == 2) {NestCheck$Attendence2YN[i] <- 1} else {NestCheck$Attendence2YN[i] <- 0}
if (NestCheck$AttendenceData[i] == 1) {NestCheck$Attendence1YN[i] <- 1} else {NestCheck$Attendence1YN[i] <- 0}
if (NestCheck$AttendenceData[i] >= 1) {NestCheck$AttendenceYN[i] <- 1} else {NestCheck$AttendenceYN[i] <- 0}
if (NestCheck$AttendenceData[i] == 1 | NestCheck$AttendenceData[i] == 3) {NestCheck$Attendence13YN[i] <- 1} else {NestCheck$Attendence13YN[i] <- 0}
if (NestCheck$AttendenceData[i] == 2 | NestCheck$AttendenceData[i] == 3) {NestCheck$Attendence23YN[i] <- 1} else {NestCheck$Attendence23YN[i] <- 0}
}
}

{# add DayClutch

NestCheck_listperClutch <- split(NestCheck, NestCheck$ClutchID)

NestCheck_listperClutch_fun = function(x)  {
x = x[order(x$Date), ]
x$DayClutch[1] <- 1
for ( i in 2:nrow(x)){x$DayClutch[i] <- x$DayClutch[i-1]+1}
return(x)
}

NestCheck_listperClutch_out1 <- lapply(NestCheck_listperClutch,NestCheck_listperClutch_fun)
NestCheck <- data.frame(rownames(do.call(rbind, NestCheck_listperClutch_out1)),do.call(rbind, NestCheck_listperClutch_out1))

rownames(NestCheck) <- NULL
}

{# add DayBrood

NestCheck_listperBrood <- split(NestCheck[NestCheck$NumChicks != 0,], NestCheck$ClutchID[NestCheck$NumChicks != 0])
x <- NestCheck_listperBrood[[1]]

NestCheck_listperBrood_fun = function(x)  {
x = x[order(x$Date), ]
x$DayBrood[1] <- 1
if(nrow(x)>1){
for ( i in 2:nrow(x)){ x$DayBrood[i] <- x$DayBrood[i-1]+ 1} 
}
return(x)
}

NestCheck_listperBrood_out1 <- lapply(NestCheck_listperBrood,NestCheck_listperBrood_fun)
NestCheck_listperBrood_out2 <- data.frame(rownames(do.call(rbind, NestCheck_listperBrood_out1)),do.call(rbind, NestCheck_listperBrood_out1))
nrow(NestCheck_listperBrood_out2)	# 2500
rownames(NestCheck_listperBrood_out2) <- NULL


NestCheck <- merge(x=NestCheck, y = NestCheck_listperBrood_out2[,c('ClutchIDdate','DayBrood')], by.y = 'ClutchIDdate', by.x = "ClutchIDdate", all.x=TRUE)

rownames(NestCheck) <- NULL
}

# table(NestCheck$DayBrood[!(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks > 1] ,NestCheck$NumChicks[!(is.na(NestCheck$NumChicks)) &NestCheck$NumChicks > 1])


{# change nb of Chiks NA to 0 when Nb Eggs >0

NestCheck$NumChicks[is.na(NestCheck$NumChicks) & NestCheck$NumEggs >0] <- 0
}

#table(NestCheck$MinFledgeDate - NestCheck$MinHatchDate)

{# add MIDPbdurlong

head(allbirds)
NestCheck$MIDYear <- paste(NestCheck$M_ID, NestCheck$Year, sep="")

for (i in 1:nrow(NestCheck))
{
NestCheck$MIDJoiningDate[i] <- as.character(allbirds$JoiningDate[allbirds$IDYear == NestCheck$MIDYear[i]])
NestCheck$MIDPbdurlong[i] <- round(NestCheck$Date[i]-as.POSIXct(NestCheck$MIDJoiningDate[i]), 0)
}
}

}

head(NestCheck)

{#### table BreedingRate

{# clutches where MIDFIDSoc not Null and StartIncubation not null
BreedingRate <- sqlQuery (conDB, "
SELECT Breed_Clutches.ClutchID, Breed_Clutches.ClutchNo, [Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID] AS MIDFID, Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.Treatments, Breed_Clutches.StartIncubation, Min(Breed_EggsLaid.LayingDate) AS MinLayingDate, Min(Breed_EggsIncubated.HatchDate) AS MinHatchDate, Min(Breed_EggsIncubated.FledgeDate) AS MinFledgeDate, Max(Breed_EggsIncubated.DateOut) AS MaxDateOut, Breed_Clutches.BroodSize, Max(Breed_EggsIncubated.DateChickDied) AS MaxDateChickDied, IIf([Breed_Clutches]![Experiment]='force-pairing for choice' Or [Breed_Clutches]![Experiment]='new pair for force-pairing for choice',2012,2013) AS [Year], Query8.CountOfFledgeDate AS nbFL, Query8.CountOfDateOut AS nbJuvOut
FROM ((Breed_Clutches LEFT JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID) LEFT JOIN Breed_EggsIncubated ON Breed_EggsLaid.ClutchID = Breed_EggsIncubated.ClutchID) INNER JOIN (SELECT Breed_Clutches.ClutchID, Count(Breed_EggsIncubated.FledgeDate) AS CountOfFledgeDate, Count(Breed_EggsIncubated.DateOut) AS CountOfDateOut
FROM Breed_Clutches LEFT JOIN Breed_EggsIncubated ON Breed_Clutches.ClutchID = Breed_EggsIncubated.ClutchID
GROUP BY Breed_Clutches.ClutchID) AS
Query8 ON Breed_Clutches.ClutchID = Query8.ClutchID
GROUP BY Breed_Clutches.ClutchID, Breed_Clutches.ClutchNo, [Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID], Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.Treatments, Breed_Clutches.StartIncubation, Breed_Clutches.BroodSize, IIf([Breed_Clutches]![Experiment]='force-pairing for choice' Or [Breed_Clutches]![Experiment]='new pair for force-pairing for choice',2012,2013), Breed_Clutches.CageAviary, Breed_Clutches.Experiment, Query8.CountOfFledgeDate, Query8.CountOfDateOut
HAVING ((([Breed_Clutches]![M_ID] & [Breed_Clutches]![F_ID]) Is Not Null) AND ((Breed_Clutches.StartIncubation) Is Not Null) AND ((Breed_Clutches.CageAviary)='A') AND ((Breed_Clutches.Experiment)='force-pairing for choice' Or (Breed_Clutches.Experiment)='force-pairing for choice s2' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice s2'));
")

BreedingRate$MIDFIDyr <- paste(BreedingRate$MIDFID,BreedingRate$Year, sep="")

}

{# add Delay between start of Incubation and BroodSize previous clutch
BreedingRate_listperMIDFIDyr <- split(BreedingRate,BreedingRate$MIDFIDyr)
BreedingRate_listperMIDFIDyr[[1]]

BreedingRate_listperMIDFIDyr_fun = function(x) {
#print(x)
x = x[order(x$ClutchNo), ]
x$prevBroodSize[1] <- 0
x$prevFLSize[1] <- 0
x$prevJuvSize[1] <- 0

if (x$Year[1] == 2012)
{x$Delay[1] <- as.numeric(difftime (x$StartIncubation[1], as.POSIXct("2012-05-28"),units='days'))}

if (x$Year[1] == 2013)
{x$Delay[1] <- as.numeric(difftime (x$StartIncubation[1], as.POSIXct("2013-05-28"),units='days'))}

if (nrow(x) >1){
for (i in 2:nrow(x))
{
x$Delay[i] <- as.numeric(difftime (x$StartIncubation[i],x$StartIncubation[i-1]))
x$prevBroodSize[i] <- x$BroodSize[i-1]
x$prevFLSize[i] <- x$nbFL[i-1]
x$prevJuvSize[i] <- x$nbJuv[i-1]
}
}
return(x)
}

BreedingRate_listperMIDFIDyr_out1 <- lapply(BreedingRate_listperMIDFIDyr,BreedingRate_listperMIDFIDyr_fun)
BreedingRate <- data.frame(rownames(do.call(rbind, BreedingRate_listperMIDFIDyr_out1)),do.call(rbind, BreedingRate_listperMIDFIDyr_out1))
rownames(BreedingRate) <- NULL
}

{# Change Trt 'Stay' into 'C' and 'NC'
for (i in 1:nrow(BreedingRate))
{
if (!(is.na(BreedingRate$Treatments[i])) & BreedingRate$Treatments[i] == "stay") {BreedingRate$Treatments[i] <- pairsStay$FTrt[BreedingRate$F_ID[i] == pairsStay$FID]}
}
}

{# add PbDur of the pair

for (i in 1:nrow(BreedingRate))
{
BreedingRate$FIDJoiningDate[i] <- allbirds$JoiningDate[allbirds$Ind_ID == BreedingRate$F_ID[i] & allbirds$Season == BreedingRate$Year[i]]
BreedingRate$FIDPbdurlong[i] <- round(BreedingRate$MinLayingDate[i]-as.POSIXct(BreedingRate$FIDJoiningDate[i]), 0)

}
}

}

head(BreedingRate)

{#### table MalesBeakColor for sperm analyses

MalesBeakColor <- sqlQuery(conDB, "
SELECT Morph_Measurements.Ind_ID, Morph_Measurements.BeakColourScore
FROM Morph_Measurements INNER JOIN Basic_TrialsTreatments ON Morph_Measurements.Ind_ID = Basic_TrialsTreatments.Ind_ID
WHERE (((Morph_Measurements.Campaign)=3) AND ((Basic_TrialsTreatments.TrialTreatment)='force-pairing for choice') AND ((Basic_TrialsTreatments.Sex)=1));
")
}

head(MalesBeakColor)

close(conDB)



{### add Eggs data on table allbirds (pivot on fitness components)

{# real fitness of genetic parents relative to whole aviary or to pairs that kept the Trt

	{# add absolute fitness of individuals

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumFate56Gen[i] <- sum (Eggs$Fate56[Eggs$MGen == allbirds$Ind_ID[i] & Eggs$Season == allbirds$Season[i]],na.rm=T)}
else
{allbirds$sumFate56Gen[i] <- sum (Eggs$Fate56[Eggs$FGen == allbirds$Ind_ID[i] & Eggs$Season == allbirds$Season[i]],na.rm=T)}
}
}

	{# decomposition fitness into WPY-EPY
	
for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumFate56GenWP[i] <- sum (Eggs$Fate56[Eggs$MGen == allbirds$Ind_ID[i] & Eggs$EPY == 0& Eggs$Season == allbirds$Season[i]],na.rm=T)
allbirds$sumFate56GenEP[i] <- sum (Eggs$Fate56[Eggs$MGen == allbirds$Ind_ID[i] & Eggs$EPY == 1& Eggs$Season == allbirds$Season[i]],na.rm=T)}
else
{allbirds$sumFate56GenWP[i] <- sum (Eggs$Fate56[Eggs$FGen == allbirds$Ind_ID[i] & Eggs$EPY == 0& Eggs$Season == allbirds$Season[i]],na.rm=T)
allbirds$sumFate56GenEP[i] <- sum (Eggs$Fate56[Eggs$FGen == allbirds$Ind_ID[i] & Eggs$EPY == 1& Eggs$Season == allbirds$Season[i]],na.rm=T)}
}
}

	{# calcul of mean fitness per aviary

out12 = list()
a12 = list()

volID12 <- c(3,4,5,6,7,15,16,17,18,19)


for (vol in volID12){
out12[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2012, select=sumFate56Gen))),2)
a12[[vol]] <- cbind(out12[[vol]],vol)
}

b12 <- data.frame(do.call(rbind,a12))
colnames(b12) <- c("MeanVol","Vol")

allbirds$MeanVol <-NA

for (i in 1:nrow(allbirds[allbirds$Season == 2012,]))
{ 
if(allbirds$Season[i] == 2012)
{
allbirds$MeanVol[i] <- b12$MeanVol[b12$Vol==allbirds$Aviary[i]]
}
}

out13 = list()
a13 = list()

volID13 <- c(3,4,5,6,7,8,9)


for (vol in volID13){
out13[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2013, select=sumFate56Gen))),2)
a13[[vol]] <- cbind(out13[[vol]],vol)
}

b13 <- data.frame(do.call(rbind,a13))
colnames(b13) <- c("MeanVol","Vol")

for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2013)
{
allbirds$MeanVol[i] <- b13$MeanVol[b13$Vol==allbirds$Aviary[i]]
}
}
}
	
	{# calcul of mean fitness per aviary for the pairs that kept the Trt

out12TrtOk = list()
a12TrtOk = list()

volID12TrtOk <- c(3,4,5,6,7,15,16,17,18,19)


for (vol in volID12TrtOk){
out12TrtOk[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2012 & allbirds$Divorced == 0, select=sumFate56Gen))),2)
a12TrtOk[[vol]] <- cbind(out12TrtOk[[vol]],vol)
}

b12TrtOk <- data.frame(do.call(rbind,a12TrtOk))
colnames(b12TrtOk) <- c("MeanVol","Vol")


for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2012& allbirds$Divorced[i] == 0)
{
allbirds$MeanVolTrtOk[i] <- b12TrtOk$MeanVol[b12TrtOk$Vol==allbirds$Aviary[i]]
}
else {allbirds$MeanVolTrtOk[i] <-NA}
}

out13TrtOk = list()
a13TrtOk = list()

volID13TrtOk <- c(3,4,5,6,7,8,9)


for (vol in volID13TrtOk){
out13TrtOk[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2013& allbirds$Divorced == 0, select=sumFate56Gen))),2)
a13TrtOk[[vol]] <- cbind(out13TrtOk[[vol]],vol)
}

b13TrtOk <- data.frame(do.call(rbind,a13TrtOk))
colnames(b13TrtOk) <- c("MeanVol","Vol")

for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2013 & allbirds$Divorced[i] == 0)
{
allbirds$MeanVolTrtOk[i] <- b13TrtOk$MeanVol[b13TrtOk$Vol==allbirds$Aviary[i]]
}
}
}

	{# calcul of mean fitness per aviary for the pairs that kept the Trt excluding polygynous male 11190 and his female 11187

out12monogTrtOk = list()
a12monogTrtOk = list()

volID12monogTrtOk <- c(3,4,5,6,7,15,16,17,18,19)


for (vol in volID12monogTrtOk){
out12monogTrtOk[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2012 & allbirds$Divorced == 0 & allbirds$Ind_ID != 11190 & allbirds$Ind_ID != 11187, select=sumFate56Gen))),2)
a12monogTrtOk[[vol]] <- cbind(out12monogTrtOk[[vol]],vol)
}

b12monogTrtOk <- data.frame(do.call(rbind,a12monogTrtOk))
colnames(b12monogTrtOk) <- c("MeanVol","Vol")


for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2012& allbirds$Divorced[i] == 0)
{
allbirds$MeanVolmonogTrtOk[i] <- b12monogTrtOk$MeanVol[b12monogTrtOk$Vol==allbirds$Aviary[i]]
}
else {allbirds$MeanVolmonogTrtOk[i] <-NA}
}

out13monogTrtOk = list()
a13monogTrtOk = list()

volID13monogTrtOk <- c(3,4,5,6,7,8,9)


for (vol in volID13monogTrtOk){
out13monogTrtOk[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2013& allbirds$Divorced == 0& allbirds$Ind_ID != 11190 & allbirds$Ind_ID != 11187, select=sumFate56Gen))),2)
a13monogTrtOk[[vol]] <- cbind(out13monogTrtOk[[vol]],vol)
}

b13monogTrtOk <- data.frame(do.call(rbind,a13monogTrtOk))
colnames(b13monogTrtOk) <- c("MeanVol","Vol")

for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2013 & allbirds$Divorced[i] == 0)
{
allbirds$MeanVolmonogTrtOk[i] <- b13monogTrtOk$MeanVol[b13monogTrtOk$Vol==allbirds$Aviary[i]]
}
}
}

	{# calcul of mean fitness WP only per aviary for the pairs that kept the Trt

out12WPTrtOk = list()
a12WPTrtOk = list()

volID12WPTrtOk <- c(3,4,5,6,7,15,16,17,18,19)


for (vol in volID12WPTrtOk){
out12WPTrtOk[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2012 & allbirds$Divorced == 0, select=sumFate56GenWP))),2)
a12WPTrtOk[[vol]] <- cbind(out12WPTrtOk[[vol]],vol)
}

b12WPTrtOk <- data.frame(do.call(rbind,a12WPTrtOk))
colnames(b12WPTrtOk) <- c("MeanVol","Vol")


for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2012& allbirds$Divorced[i] == 0)
{
allbirds$MeanVolWPTrtOk[i] <- b12WPTrtOk$MeanVol[b12WPTrtOk$Vol==allbirds$Aviary[i]]
}
else {allbirds$MeanVolWPTrtOk[i] <-NA}
}

out13WPTrtOk = list()
a13WPTrtOk = list()

volID13WPTrtOk <- c(3,4,5,6,7,8,9)


for (vol in volID13WPTrtOk){
out13WPTrtOk[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2013& allbirds$Divorced == 0, select=sumFate56GenWP))),2)
a13WPTrtOk[[vol]] <- cbind(out13WPTrtOk[[vol]],vol)
}

b13WPTrtOk <- data.frame(do.call(rbind,a13WPTrtOk))
colnames(b13WPTrtOk) <- c("MeanVol","Vol")

for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2013 & allbirds$Divorced[i] == 0)
{
allbirds$MeanVolWPTrtOk[i] <- b13WPTrtOk$MeanVol[b13WPTrtOk$Vol==allbirds$Aviary[i]]
}
}
}

	{# calcul of mean fitness WP only per aviary for the pairs that kept the Trt excluding polygynous male 11190 and his female 11187

out12WPmonogTrtOk = list()
a12WPmonogTrtOk = list()

volID12WPmonogTrtOk <- c(3,4,5,6,7,15,16,17,18,19)


for (vol in volID12WPmonogTrtOk){
out12WPmonogTrtOk[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2012 & allbirds$Divorced == 0 & allbirds$Ind_ID != 11190 & allbirds$Ind_ID != 11187, select=sumFate56GenWP))),2)
a12WPmonogTrtOk[[vol]] <- cbind(out12WPmonogTrtOk[[vol]],vol)
}

b12WPmonogTrtOk <- data.frame(do.call(rbind,a12WPmonogTrtOk))
colnames(b12WPmonogTrtOk) <- c("MeanVol","Vol")


for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2012& allbirds$Divorced[i] == 0)
{
allbirds$MeanVolWPmonogTrtOk[i] <- b12WPmonogTrtOk$MeanVol[b12WPmonogTrtOk$Vol==allbirds$Aviary[i]]
}
else {allbirds$MeanVolWPmonogTrtOk[i] <-NA}
}

out13WPmonogTrtOk = list()
a13WPmonogTrtOk = list()

volID13WPmonogTrtOk <- c(3,4,5,6,7,8,9)


for (vol in volID13WPmonogTrtOk){
out13WPmonogTrtOk[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2013& allbirds$Divorced == 0& allbirds$Ind_ID != 11190 & allbirds$Ind_ID != 11187, select=sumFate56GenWP))),2)
a13WPmonogTrtOk[[vol]] <- cbind(out13WPmonogTrtOk[[vol]],vol)
}

b13WPmonogTrtOk <- data.frame(do.call(rbind,a13WPmonogTrtOk))
colnames(b13WPmonogTrtOk) <- c("MeanVol","Vol")

for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2013 & allbirds$Divorced[i] == 0)
{
allbirds$MeanVolWPmonogTrtOk[i] <- b13WPmonogTrtOk$MeanVol[b13WPmonogTrtOk$Vol==allbirds$Aviary[i]]
}
}
}

	{# add relative fitness of individuals relative to the whole aviary
for (i in 1:nrow(allbirds)){
allbirds$Relfitness[i] <- round(allbirds$sumFate56Gen[i]/allbirds$MeanVol[i],2) 
}
}

	{# add relative fitness of individuals relative to the pairs that kept the Trt
for (i in 1:nrow(allbirds)){
allbirds$RelfitnessTrtOk[i] <- round(allbirds$sumFate56Gen[i]/allbirds$MeanVolTrtOk[i],2) 
}
}

	{# add relative fitness of individuals relative to the pairs that kept the Trt
for (i in 1:nrow(allbirds)){
allbirds$RelfitnessmonogTrtOk[i] <- round(allbirds$sumFate56Gen[i]/allbirds$MeanVolmonogTrtOk[i],2) 
}
}

	{# add relative fitness WP only of individuals relative to the pairs that kept the Trt
for (i in 1:nrow(allbirds)){
allbirds$RelfitnessWPTrtOk[i] <- round(allbirds$sumFate56GenWP[i]/allbirds$MeanVolWPTrtOk[i],2) 
}
}
	
	{# add relative fitness WP only of individuals relative to the pairs that kept the Trt excluding polygynous male 11190 and his female 11187
for (i in 1:nrow(allbirds)){
allbirds$RelfitnessWPmonogTrtOk[i] <- round(allbirds$sumFate56GenWP[i]/allbirds$MeanVolWPmonogTrtOk[i],2) 
}
}



}

{# nb of eggs laid to assigned parents

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumEggIDass[i] <- length (Eggs$EggID[!(is.na(Eggs$Mass)) & Eggs$Mass == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]])}
else
{allbirds$sumEggIDass[i] <- length (Eggs$EggID[!(is.na(Eggs$Fass)) & Eggs$Fass == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]])}
}
}


{# nb of eggs laid to genetic parents

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumEggIDGen[i] <- length (Eggs$EggID[!(is.na(Eggs$MGen)) & Eggs$MGen == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]])}
else
{allbirds$sumEggIDGen[i] <- length (Eggs$EggID[!(is.na(Eggs$FGen)) & Eggs$FGen == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]])}
}
}

{# calcul of mean siring success per aviary

sout12 = list()
sa12 = list()

volID12 <- c(3,4,5,6,7,15,16,17,18,19)


for (vol in volID12){
sout12[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2012, select=sumEggIDGen))),2)
sa12[[vol]] <- cbind(sout12[[vol]],vol)
}

sb12 <- data.frame(do.call(rbind,sa12))
colnames(sb12) <- c("SiringMeanVol","Vol")

allbirds$SiringMeanVol <-NA

for (i in 1:nrow(allbirds[allbirds$Season == 2012,]))
{ 
if(allbirds$Season[i] == 2012)
{
allbirds$SiringMeanVol[i] <- sb12$SiringMeanVol[sb12$Vol==allbirds$Aviary[i]]
}
}

sout13 = list()
sa13 = list()

volID13 <- c(3,4,5,6,7,8,9)


for (vol in volID13){
sout13[[vol]] <- round((colMeans(subset(allbirds, Aviary == vol & Sex=='1' & Season == 2013, select=sumEggIDGen))),2)
sa13[[vol]] <- cbind(sout13[[vol]],vol)
}

sb13 <- data.frame(do.call(rbind,sa13))
colnames(sb13) <- c("SiringMeanVol","Vol")

for (i in 1:nrow(allbirds))
{ 
if(allbirds$Season[i] == 2013)
{
allbirds$SiringMeanVol[i] <- sb13$SiringMeanVol[sb13$Vol==allbirds$Aviary[i]]
}
}
}
	
{# add relative siring success of individuals relative to the whole aviary
for (i in 1:nrow(allbirds)){
allbirds$RelsiringSucc[i] <- round(allbirds$sumEggIDGen[i]/allbirds$SiringMeanVol[i],2) 
}
}

	
{# mean mass of chicks at day 8 (for those who got chicks day 8) for social parents

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$MeanMass8dChicksoc[i] <- mean (Eggs$Mass8dChick[Eggs$MID == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]], na.rm=T)}
else
{allbirds$MeanMass8dChicksoc[i] <- mean (Eggs$Mass8dChick[Eggs$FID == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]], na.rm=T)}
}	
}

{# Behavioural compatibility between social parents needed to raise chicks	

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumFate56soc[i] <- sum (Eggs$Fate56[Eggs$MID == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]], na.rm=T)}
else
{allbirds$sumFate56soc[i] <- sum (Eggs$Fate56[Eggs$FID == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]], na.rm=T)}
}	

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumFate34soc[i] <- sum (Eggs$Fate34[Eggs$MID == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]], na.rm=T)}
else
{allbirds$sumFate34soc[i] <- sum (Eggs$Fate34[Eggs$FID == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]], na.rm=T)}
}	
}

{# Genetic compatibility between genetic parents > EPY Removed

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumFate2GenWPY[i] <- sum (Eggs$Fate2[Eggs$MGen == allbirds$Ind_ID[i] & Eggs$EPY == 0 & Eggs$Season == allbirds$Season[i]], na.rm=T)}
else
{allbirds$sumFate2GenWPY[i] <- sum (Eggs$Fate2[Eggs$FGen == allbirds$Ind_ID[i]& Eggs$EPY == 0 & Eggs$Season == allbirds$Season[i]], na.rm=T)}
}	

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumFate3456GenWPY[i] <- sum (Eggs$Fate3456[Eggs$MGen == allbirds$Ind_ID[i]& Eggs$EPY == 0& Eggs$Season == allbirds$Season[i]], na.rm=T)}
else
{allbirds$sumFate3456GenWPY[i] <- sum (Eggs$Fate3456[Eggs$FGen == allbirds$Ind_ID[i]& Eggs$EPY == 0& Eggs$Season == allbirds$Season[i]], na.rm=T)}
}

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$sumFate1GenWPY[i] <- sum (Eggs$Fate1[Eggs$MGen == allbirds$Ind_ID[i] & Eggs$Fate1 == 1 & Eggs$EPY == 0& Eggs$Season == allbirds$Season[i]], na.rm=T)}
else
{allbirds$sumFate1GenWPY[i] <- sum (Eggs$Fate1[Eggs$FGen == allbirds$Ind_ID[i] & Eggs$Fate1 == 1 & Eggs$EPY == 0& Eggs$Season == allbirds$Season[i]], na.rm=T)}
}

}

{# EPY
nrow(Eggs[complete.cases(Eggs[,"MGen"]),])	# 1032
table(Eggs[complete.cases(Eggs[,"MGen"]),"EPY"])	# 9.30% EPP	

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$EPYYes[i] <- sum (Eggs$EPY[Eggs$MGen == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]], na.rm=T)}
else
{allbirds$EPYYes[i] <- sum (Eggs$EPY[Eggs$FGen == allbirds$Ind_ID[i]& Eggs$Season == allbirds$Season[i]], na.rm=T)}
}	

for (i in 1:nrow(allbirds))
{
if (allbirds$Sex[i] == 1)
{allbirds$EPYNo[i] <- length (Eggs$EPY[!(is.na(Eggs$MGen)) & Eggs$MGen == allbirds$Ind_ID[i] & Eggs$EPY == 0 & Eggs$Season == allbirds$Season[i]])}
else
{allbirds$EPYNo[i] <- length (Eggs$EPY[!(is.na(Eggs$MGen)) &Eggs$FGen == allbirds$Ind_ID[i] & Eggs$EPY == 0 & Eggs$Season == allbirds$Season[i]])}
}
}
}

head(allbirds)

{### add allbirds data on table Eggs (Pb duration of Fass)
	
for (i in 1:nrow(Eggs))
{
if (!is.na(Eggs$Fass[i]))
{
Eggs$FassJoiningDate[i] <- allbirds$JoiningDate[Eggs$Fass[i] == allbirds$Ind_ID & Eggs$Season[i] == allbirds$Season]	
Eggs$FassPairingDate[i] <- allbirds$PairingDate[Eggs$Fass[i] == allbirds$Ind_ID & Eggs$Season[i] == allbirds$Season]	
Eggs$FassPbdurlong[i] <- round(Eggs$LayingDate[i]-as.POSIXct(Eggs$FassJoiningDate[i]), 0)
Eggs$FassPbdurshort[i] <- round(Eggs$LayingDate[i]-as.POSIXct(Eggs$FassPairingDate[i]), 0)

Eggs$MassJoiningDate[i] <- allbirds$JoiningDate[Eggs$Mass[i] == allbirds$Ind_ID & Eggs$Season[i] == allbirds$Season]
Eggs$MassPbdurlong[i] <- round(Eggs$LayingDate[i]-as.POSIXct(Eggs$MassJoiningDate[i]), 0)

}
else
{
Eggs$FassJoiningDate[i] <- NA
Eggs$FassPairingDate[i] <- NA
Eggs$FassPbdurlong[i] <- NA
Eggs$FassPbdurshort[i] <- NA

Eggs$MassJoiningDate[i] <- NA
Eggs$MassPbdurlong[i] <- NA


}
}


for (i in 1:nrow(Eggs))
{
if (!is.na(Eggs$FID[i]))
{
Eggs$FIDJoiningDate[i] <- allbirds$JoiningDate[Eggs$FID[i] == allbirds$Ind_ID & Eggs$Season[i] == allbirds$Season]	
Eggs$FIDPbdurlong[i] <- round(Eggs$LayingDate[i]-as.POSIXct(Eggs$FIDJoiningDate[i]), 0)
}
else
{
Eggs$FIDJoiningDate[i] <- NA
Eggs$FIDPbdurlong[i] <- NA
}
}

}

head(Eggs)

{### add Eggs data on table pairs1213 (pivot on fitness components)

for (i in 1:nrow(pairs1213))
{
pairs1213$sumFate0MIDFIDass[i] <- sum (Eggs$Fate0[Eggs$MIDFIDass == pairs1213$MIDFID[i] & Eggs$Season == pairs1213$Season[i]],na.rm=T)
pairs1213$sumFate23456WP[i] <- sum (Eggs$Fate23456[Eggs$Fass == pairs1213$FID[i] & Eggs$EPY == 0 & Eggs$Season == pairs1213$Season[i]],na.rm=T)
pairs1213$sumFate23456FassEP[i] <- sum (Eggs$Fate23456[Eggs$Fass == pairs1213$FID[i] & Eggs$EPY == 1 & Eggs$Season == pairs1213$Season[i]],na.rm=T)
pairs1213$percFate0outof023456[i] <-  pairs1213$sumFate0MIDFIDass[i] / (pairs1213$sumFate0MIDFIDass[i] + pairs1213$sumFate23456WP[i])
pairs1213$percFassEP[i] <-  pairs1213$sumFate23456FassEP[i] / (pairs1213$sumFate23456FassEP[i] + pairs1213$sumFate23456WP[i])
}
}

head(pairs1213)

{### add PairingStatus data on table Eggs (Day, FassYearDay)

for (i in 1:nrow(Eggs))
{ Eggs$Day[i] <- listdaysdates$Day[Eggs$LayingDate[i] == listdaysdates$Date]
if (!(is.na(Eggs$Fass[i])))
{Eggs$FassYearDay[i] <- paste(Eggs$Fass[i],Eggs$Season[i], Eggs$Day[i], sep="")}
else{Eggs$FassYearDay[i] <- NA}
}
}

head(Eggs)

{### add weather data on table Eggs

for (i in 1:nrow(Eggs))
{
Eggs$TempInc[i] <- weather$TempInc[weather$Date == Eggs$LayingDate[i]]
}
for (i in 1:nrow(Eggs))
{
if(!(is.na(Eggs$HatchDate[i])))
{
Eggs$TempHatch[i] <- weather$TempHatch[weather$Date == Eggs$HatchDate[i]]
}
else {Eggs$TempHatch[i] <- NA}
}

}

tail(Eggs,20)

{### add Eggs data on table FemalePairingStatus

{# add nEggsAss in FemalePairingStatus
Eggs_listperFassYearDay <- split(Eggs, Eggs$FassYearDay)
Eggs_listperFassYearDay[[1]]
Eggs_listperFassYearDayout1 = lapply(Eggs_listperFassYearDay, FUN=nrow)
Eggs_listperFassYearDayout2 = data.frame(FassYearDay = names(Eggs_listperFassYearDayout1 ), nEggsAss = unlist(Eggs_listperFassYearDayout1))

FemalePairingStatus <- merge(y = Eggs_listperFassYearDayout2, x = PairingStatus[PairingStatus$Sex == 0,], by.y = 'FassYearDay', by.x = "IDyrday", all.x=TRUE)

FemalePairingStatus$nEggsAss[is.na(FemalePairingStatus$nEggsAss)] <- 0
}

{# add RelDayMod in FemalePairingStatus
FemalePairingStatus$IDyr <- paste(FemalePairingStatus$Ind_ID,FemalePairingStatus$Season, sep="")
FemalePairingStatus_listperIDyr <- split(FemalePairingStatus, FemalePairingStatus$IDyr)
	
	{# nDaysAfterLastEgg
FemalePairingStatus_listperIDyr_fun = function(x)  {
 
 x = x[order(x$Day), ]
 # print(head(x))
 
  if (x$nEggsAss[1] == 0)
  {x$nDaysAfterLastEgg[1] <- 1000}
   if (x$nEggsAss[1] > 0)
  {x$nDaysAfterLastEgg[1] <- 0}
	  
  for (i in 2:nrow(x) ){ 
	if (x$nEggsAss[i] > 0)
  {x$nDaysAfterLastEgg[i] <- 0}
   if (x$nEggsAss[i] == 0)
  {x$nDaysAfterLastEgg[i] <- x$nDaysAfterLastEgg[i-1]+1}
	}
 return(x) 
 }

FemalePairingStatus_listperIDyrout1 = lapply(FemalePairingStatus_listperIDyr, FemalePairingStatus_listperIDyr_fun)
FemalePairingStatus <- do.call(rbind, FemalePairingStatus_listperIDyrout1)
	}

	{# nDaysBeforeNextEgg
FemalePairingStatus_listperIDyr2 <- split(FemalePairingStatus,  FemalePairingStatus$IDyr)

FemalePairingStatus_listperIDyr_fun2 = function(x)  {
 
 x = x[order(-x$Day), ]
 # print(head(x))
 
  x$nDaysBeforeNextEgg[1] <- 1000
  
  for (i in 2:nrow(x) ){ 
	if (x$nEggsAss[i-1] > 0)
  {x$nDaysBeforeNextEgg[i] <- 1}
   if (x$nEggsAss[i-1] == 0)
  {x$nDaysBeforeNextEgg[i] <- x$nDaysBeforeNextEgg[i-1]+1}
	}
 return(x) 
 }

FemalePairingStatus_listperIDyrout2 = lapply(FemalePairingStatus_listperIDyr2, FemalePairingStatus_listperIDyr_fun2)
FemalePairingStatus <- do.call(rbind, FemalePairingStatus_listperIDyrout2)
}

	{# nDaysAfterLastPeak of Fertility (day -3)
FemalePairingStatus$nDaysAfterLastPeak <- FemalePairingStatus$nDaysAfterLastEgg + 3
	}
	
	{# nDaysBeforeNextPeak of Fertility (day -3)
FemalePairingStatus$nDaysBeforeNextPeak <-FemalePairingStatus$nDaysBeforeNextEgg -3
	}

	{# RelDay
for (i in 1:nrow(FemalePairingStatus))
{
if (FemalePairingStatus$nDaysAfterLastPeak[i] < FemalePairingStatus$nDaysBeforeNextPeak[i]) 
{FemalePairingStatus$RelDay[i] <- FemalePairingStatus$nDaysAfterLastPeak[i]}
if (FemalePairingStatus$nDaysAfterLastPeak[i] >= FemalePairingStatus$nDaysBeforeNextPeak[i]) 
{FemalePairingStatus$RelDay[i] <- -FemalePairingStatus$nDaysBeforeNextPeak[i]}
}
	}

	{# RelDayMod	
for (i in 1:nrow(FemalePairingStatus))
{
if (FemalePairingStatus$RelDay[i] < -5 | FemalePairingStatus$RelDay[i] > 5)
{FemalePairingStatus$RelDayMod[i] <- 5}
else {FemalePairingStatus$RelDayMod[i] <- abs(FemalePairingStatus$RelDay[i])}
}	
	}

rownames(FemalePairingStatus) <- NULL	
}	

{# check female without eggs assigned
unique(FemalePairingStatus$Ind_ID[FemalePairingStatus$RelDay < -1000 | FemalePairingStatus$RelDay >= 1000])
}

{# add nEggLayedlast5days in FemalePairingStatus
FemalePairingStatus_listperIDyr3 <- split(FemalePairingStatus,  FemalePairingStatus$IDyr)

FemalePairingStatus_listperIDyr_fun3 = function(x)  {
  x = x[order(x$Day),]
  x$nEggsLayedLast5Days[1] <- x$nEggsAss[1]
  x$nEggsLayedLast5Days[2] <- sum(x$nEggsAss[1]+x$nEggsAss[2])
  x$nEggsLayedLast5Days[3] <- sum(x$nEggsAss[1]+x$nEggsAss[2]+x$nEggsAss[3])
  x$nEggsLayedLast5Days[4] <- sum(x$nEggsAss[1]+x$nEggsAss[2]+x$nEggsAss[3]+x$nEggsAss[4])
  
 for (i in 5:nrow(x) )
 {x$nEggsLayedLast5Days[i] <- sum(x$nEggsAss[i]+x$nEggsAss[i-1]+x$nEggsAss[i-2]+x$nEggsAss[i-3]+x$nEggsAss[i-4])}
 return(x) 
 }

FemalePairingStatus_listperIDyrout3 = lapply(FemalePairingStatus_listperIDyr3, FemalePairingStatus_listperIDyr_fun3)
FemalePairingStatus <- do.call(rbind, FemalePairingStatus_listperIDyrout3)
rownames(FemalePairingStatus) <- NULL	
}

{# check out nb eggs assigned per females and change Fass to NA in table Eggs

{# per day > not more than 2 !
table(FemalePairingStatus$nEggsAss)	
FemalePairingStatus[FemalePairingStatus$nEggsAss > 2,]
duplicatedFassYearDay <- Eggs[Eggs$FassYearDay%in%Eggs$FassYearDay[!(is.na(Eggs$Fass)) & duplicated(Eggs$FassYearDay)],]
duplicatedFassYearDay <- duplicatedFassYearDay[order(duplicatedFassYearDay$FassYearDay),]
duplicatedFassYearDay[,c('Season', 'ClutchID' ,'MID' ,'FID' ,'StartIncubation', 'EggID' ,'EggNoClutch', 'EggFate' ,'FGen' ,'Fass', 'Remarks' ,'Day')]
	# Fass: 11224
	# EggID: 3457, 3309, 3310
	# ClutchID 825, 842 > no Parents assigned  ?
}

{# per 5 days > not more than 6 !
FemalePairingStatus[FemalePairingStatus$nEggsLayedLast5Days > 6,]
FemalePairingStatus[FemalePairingStatus$Ind_ID == 11224 & FemalePairingStatus$Season == 2013,c('Ind_ID' ,'Day','nEggsAss','nEggsLayedLast5Days')]
}

{# per 2 days > not more than 3 !
FemalePairingStatus_listperIDyr4 <- split(FemalePairingStatus,  FemalePairingStatus$IDyr)

FemalePairingStatus_listperIDyr_fun4 = function(x)  {
  x = x[order(x$Day),]
  x$nEggsLayedLast2Days[1] <- x$nEggsAss[1]
  x$nEggsLayedLast2Days[2] <- sum(x$nEggsAss[1]+x$nEggsAss[2])

 for (i in 3:nrow(x) )
 {x$nEggsLayedLast2Days[i] <- sum(x$nEggsAss[i]+x$nEggsAss[i-1])}
 return(x) 
 }

FemalePairingStatus_listperIDyrout4 = lapply(FemalePairingStatus_listperIDyr4, FemalePairingStatus_listperIDyr_fun4)
FemalePairingStatustocheck <- do.call(rbind, FemalePairingStatus_listperIDyrout4)
rownames(FemalePairingStatustocheck) <- NULL

FemalePairingStatustocheck[FemalePairingStatustocheck$nEggsLayedLast2Days > 3,]

Eggs[!(is.na(Eggs$FassYearDay)) & (Eggs$FassYearDay == 1122420139 |Eggs$FassYearDay == 11224201310 |Eggs$FassYearDay == 11224201311) ,]
Eggs[!(is.na(Eggs$FassYearDay)) & (Eggs$FassYearDay == 11236201391 |Eggs$FassYearDay == 11236201390 ) ,]
}
}

}

head(FemalePairingStatus)

{### add discriminant scores of MID (2012-2013) and FID (2013) to AllCourt								# !! sqlFetch !!

MaleDiscrim2012 <- sqlFetch(conXLdiscrim2012,"MaleDiscrimforR")
close(conXLdiscrim2012)

for (i in 1:nrow(AllCourt))  {
if(AllCourt$MID[i]%in%MaleDiscrim2012$MID) {AllCourt$Mdiscrim2012[i] <- MaleDiscrim2012$Mdiscrim[MaleDiscrim2012$MID == AllCourt$MID[i]]}
else {AllCourt$Mdiscrim2012[i] <- NA}
}


MaleDiscrim2013 <- sqlFetch(conXLdiscrim2013,"MaleDiscrimforR")
FemaleDiscrim2013 <- sqlFetch(conXLdiscrim2013,"FemaleDiscrimforR")
close(conXLdiscrim2013)

for (i in 1:nrow(AllCourt))  {
if(AllCourt$MID[i]%in%MaleDiscrim2013$MID) {AllCourt$Mdiscrim2013[i] <- MaleDiscrim2013$Mdiscrim[MaleDiscrim2013$MID == AllCourt$MID[i]]}
else {AllCourt$Mdiscrim2013[i] <- NA}
if(AllCourt$FID[i]%in%FemaleDiscrim2013$FID) {AllCourt$Fdiscrim2013[i] <- FemaleDiscrim2013$Fdiscrim[FemaleDiscrim2013$FID == AllCourt$FID[i]]}
else {AllCourt$Fdiscrim2013[i] <- NA}
}

for (i in 1:nrow(AllCourt))  {
if(is.na(AllCourt$Mdiscrim2013[i])) {AllCourt$MeanMdiscrim[i] <- AllCourt$Mdiscrim2012[i]}
else {AllCourt$MeanMdiscrim[i] <- (AllCourt$Mdiscrim2012[i] + AllCourt$Mdiscrim2013[i])/2}
}

head(AllCourt[is.na(AllCourt$Mdiscrim2013),])
}

head(AllCourt)

{### add Pairing St data to AllCourt 

AllCourt <- merge(y = AccessPairingStatus[,c('IDyrday','pairedYN','PartnerID','polyStatus')], x = AllCourt, by.y = 'IDyrday', by.x = "MIDyrday", all.x=TRUE)
colnames(AllCourt)[colnames(AllCourt) == "pairedYN"] <- "Mpaired"
colnames(AllCourt)[colnames(AllCourt) == "PartnerID"] <- "MPartnerID"
colnames(AllCourt)[colnames(AllCourt) == "polyStatus"] <- "MpolySt"

AllCourt <- merge(y = AccessPairingStatus[,c('IDyrday','pairedYN','PartnerID','polyStatus')], x = AllCourt, by.y = 'IDyrday', by.x = "FIDyrday", all.x=TRUE)
colnames(AllCourt)[colnames(AllCourt) == "pairedYN"] <- "Fpaired"
colnames(AllCourt)[colnames(AllCourt) == "PartnerID"] <- "FPartnerID"
colnames(AllCourt)[colnames(AllCourt) == "polyStatus"] <- "FpolySt"

for (i in 1:nrow(AllCourt)){
AllCourt$DiffMID[i] <- sum(AllCourt$MID[i],-AllCourt$FPartnerID[i],na.rm=T )
AllCourt$DiffFID[i] <- sum(AllCourt$FID[i],-AllCourt$MPartnerID[i],na.rm=T )
}

AllCourt$FIDMIDyr <- paste(AllCourt$FID, AllCourt$MIDyr, sep="")
}

head(AllCourt)

{### add courtship types (WEU) to AllCourt

# FWEU: courtship type from the female side
head(AllCourt[AllCourt$DiffMID == 0,])	# WP 
head(AllCourt[AllCourt$DiffMID == AllCourt$MID,])	# UP 
head(AllCourt[AllCourt$DiffMID != AllCourt$MID & AllCourt$DiffMID != 0,])	# EP 

for (i in 1:nrow(AllCourt)) {
if(AllCourt$DiffMID[i] == 0){AllCourt$FWEU[i] <- "WP"}
else if(AllCourt$DiffMID[i] == AllCourt$MID[i]){AllCourt$FWEU[i] <- "UP"}
else{AllCourt$FWEU[i] <- "EP"}
}

# MWEU: courtship type from the male side
head(AllCourt[AllCourt$DiffFID == 0,])	# WP 
head(AllCourt[AllCourt$DiffFID == AllCourt$FID,])	# UP 
head(AllCourt[AllCourt$DiffFID != AllCourt$FID & AllCourt$DiffFID != 0,])	# EP 

for (i in 1:nrow(AllCourt)) { 
if(AllCourt$DiffFID[i] == 0){AllCourt$MWEU[i] <- "WP"}
else if(AllCourt$DiffFID[i] == AllCourt$FID[i]){AllCourt$MWEU[i] <- "UP"}
else{AllCourt$MWEU[i] <- "EP"}
}

# MWEU for the polygynous male 11190

AllCourt$MWEU[AllCourt$MIDyr == 111902012 & AllCourt$FID == 11187] <- "WP"
AllCourt$MWEU[AllCourt$MIDyr == 111902012 & AllCourt$FID != 11187] <- "EP"

}

head(AllCourt)		

{### add Egg data of FemalePairingStatus on table AllCourt
AllCourt <- merge(y = FemalePairingStatus[,c('IDyrday','RelDayMod','nEggsLayedLast5Days','dayspaired')], x = AllCourt, by.y = 'IDyrday', by.x = "FIDyrday", all.x=TRUE)

colnames(AllCourt)[colnames(AllCourt) == "dayspaired"] <- "Fdayspaired"
}

head(AllCourt)

{### add allbirds data on table AllCourt

AllCourt <- merge(y = allbirds[,c('IDYear','Treatment','Divorced')], x = AllCourt, by.y = 'IDYear', by.x = "FIDyr", all.x=TRUE)
colnames(AllCourt)[colnames(AllCourt) == "Treatment"] <- "FTrt"
colnames(AllCourt)[colnames(AllCourt) == "Divorced"] <- "FDivorced"

AllCourt <- merge(y = allbirds[,c('IDYear','Treatment','Divorced')], x = AllCourt, by.y = 'IDYear', by.x = "MIDyr", all.x=TRUE)
colnames(AllCourt)[colnames(AllCourt) == "Treatment"] <- "MTrt"
colnames(AllCourt)[colnames(AllCourt) == "Divorced"] <- "MDivorced"
}

head(AllCourt)

{### add discriminant scores of MID (2012-2013) and FID (2013) + Massday45 for FID to allbirds

for (i in 1:nrow(allbirds))  {
if(allbirds$Ind_ID[i]%in%MaleDiscrim2012$MID) 
{allbirds$discrim2012[i] <- MaleDiscrim2012$Mdiscrim[MaleDiscrim2012$MID == allbirds$Ind_ID[i]]}
else {allbirds$discrim2012[i] <- NA}
}

for (i in 1:nrow(allbirds))  {
if(allbirds$Ind_ID[i]%in%MaleDiscrim2013$MID) 
{allbirds$discrim2013[i] <- MaleDiscrim2013$Mdiscrim[MaleDiscrim2013$MID == allbirds$Ind_ID[i]]}
if(allbirds$Ind_ID[i]%in%FemaleDiscrim2013$FID) 
{allbirds$discrim2013[i] <- FemaleDiscrim2013$Fdiscrim[FemaleDiscrim2013$FID == allbirds$Ind_ID[i]]}
if(!(allbirds$Ind_ID[i]%in%MaleDiscrim2013$MID) & !(allbirds$Ind_ID[i]%in%FemaleDiscrim2013$FID))
{allbirds$discrim2013[i] <- NA}
}

for (i in 1:nrow(allbirds))  {
if(is.na(allbirds$discrim2012[i])) {allbirds$MeanMdiscrim[i] <- NA}
if(is.na(allbirds$discrim2013[i])) {allbirds$MeanMdiscrim[i] <- allbirds$discrim2012[i]}
else {allbirds$MeanMdiscrim[i] <- (allbirds$discrim2012[i] + allbirds$discrim2013[i])/2}
}
}

head(allbirds)

{### add AllCourt and MalePairingstatus (Courtship rates) data in table allmales

allmales <- allbirds[allbirds$Sex == 1,]
MalePairingStatus <- PairingStatus[PairingStatus$Sex == 1,]
MalePairingStatus$IDyr <- paste(MalePairingStatus$Ind_ID,MalePairingStatus$Season, sep="")

{# add NB hours watched from MalePairingstatus
MalePairingStatus_listperIDyr <- split(MalePairingStatus, MalePairingStatus$IDyr)

MalePairingStatus_listperIDyr_fun = function(x)  {
return(c(

sum(x$WatchedYN), # NBHours
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1]),	#NBHoursPaired
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0]),	#NBHoursUnpaired 

sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1 & x$RecPosition == "Courtship P"]),	#NBHoursPairedCourtP
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1 & x$RecPosition == "Social P"]),	#NBHoursPairedSocialP
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1 & (x$RecPosition == "NB up" | x$RecPosition == "RAC")]),	#NBHoursPairedNestBox

sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0 & x$RecPosition == "Courtship P"]),	#NBHoursUnpairedCourtP
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0 & x$RecPosition == "Social P"]),	#NBHoursUnpairedSocialP
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0 & (x$RecPosition == "NB up" | x$RecPosition == "RAC")]),	#NBHoursUnpairedNestBox

sum(x$WatchedYN[x$Watched == 1 & x$RecPosition == "Courtship P"]),	#NBHoursCourtP
sum(x$WatchedYN[x$Watched == 1 & x$RecPosition == "Social P"]),	#NBHoursSocialP
sum(x$WatchedYN[x$Watched == 1 & (x$RecPosition == "NB up" | x$RecPosition == "RAC")])	#NBHoursNestBox


))
 
 }	
 
MalePairingStatus_listperIDyrout1 <- lapply(MalePairingStatus_listperIDyr, FUN=MalePairingStatus_listperIDyr_fun)
MalePairingStatus_listperIDyrout2 <- data.frame(rownames(do.call(rbind, MalePairingStatus_listperIDyrout1)),do.call(rbind, MalePairingStatus_listperIDyrout1))
rownames(MalePairingStatus_listperIDyrout2) <- NULL
colnames(MalePairingStatus_listperIDyrout2) <- c('IDyr','NBHours','NBHoursPaired','NBHoursUnpaired','NBHoursPairedCourtP','NBHoursPairedSocialP','NBHoursPairedNestBox','NBHoursUnpairedCourtP','NBHoursUnpairedSocialP','NBHoursUnpairedNestBox', 'NBHoursCourtP','NBHoursSocialP','NBHoursNestBox')

allmales <- merge(y = MalePairingStatus_listperIDyrout2, x = allmales, by.y = 'IDyr', by.x = "IDYear", all.x=TRUE)
}

{# add NB Courtships from AllCourt
AllCourt_listperMIDyr <- split(AllCourt, AllCourt$MIDyr)
x <- AllCourt_listperMIDyr[[1]]
AllCourt_listperMIDyr_fun = function(x)  {
return(c(

nrow(x), # NBCourt

nrow(x[x$MWEU == 'WP',]),	#NBCourtWP
nrow(x[x$MWEU == 'EP',]),	#NBCourtEP
nrow(x[x$MWEU == 'UP',]),	#NBCourtUP

nrow(x[x$MWEU == 'WP' & x$Position == "Courtship P",]),	#NBCourtWPCourtP 
nrow(x[x$MWEU == 'EP' & x$Position == "Courtship P",]),	#NBCourtEPCourtP 
nrow(x[x$MWEU == 'UP' & x$Position == "Courtship P",]),	#NBCourtUPCourtP 

nrow(x[x$MWEU == 'WP' & x$Position == "Social P",]),	#NBCourtWPSocialP 
nrow(x[x$MWEU == 'EP' & x$Position == "Social P",]),	#NBCourtEPSocialP 
nrow(x[x$MWEU == 'UP' & x$Position == "Social P",]),	#NBCourtUPSocialP 

nrow(x[x$MWEU == 'WP' & x$Position == "NestBox",]),	#NBCourtWPNestbox
nrow(x[x$MWEU == 'EP' & x$Position == "NestBox",]),	#NBCourtEPNestbox
nrow(x[x$MWEU == 'UP' & x$Position == "NestBox",]),	#NBCourtUPNestbox


nrow(x[x$Position == "Courtship P",]),	#NBCourtCourtP 
nrow(x[x$Position == "Social P",]),	#NBCourtSocialP
nrow(x[x$Position == "Nestbox",]),	#NBCourtNestbox

sum(x$DisplaySec[x$Position == "Courtship P"]),	#DisplaySecCourtP 
sum(x$DisplaySec[x$Position == "Social P"]),	#DisplaySecSocialP 
sum(x$DisplaySec[x$Position == "NestBox"])	# DisplaySecNestBox


))
 
 }

AllCourt_listperMIDyrout1 <- lapply(AllCourt_listperMIDyr, FUN=AllCourt_listperMIDyr_fun)
AllCourt_listperMIDyrout2 <- data.frame(rownames(do.call(rbind, AllCourt_listperMIDyrout1)),do.call(rbind, AllCourt_listperMIDyrout1))
rownames(AllCourt_listperMIDyrout2) <- NULL
colnames(AllCourt_listperMIDyrout2) <- c('IDyr','NBCourt','NBCourtWP','NBCourtEP','NBCourtUP','NBCourtWPCourtP','NBCourtEPCourtP ','NBCourtUPCourtP ','NBCourtWPSocialP','NBCourtEPSocialP','NBCourtUPSocialP','NBCourtWPNestbox','NBCourtEPNestBox','NBCourtUPNestBox','NBCourtCourtP','NBCourtSocialP','NBCourtNestBox','DisplaySecCourtP','DisplaySecSocialP','DisplaySecNestBox')

allmales <- merge(y = AllCourt_listperMIDyrout2, x = allmales, by.y = 'IDyr', by.x = "IDYear", all.x=TRUE)
}

{# add rates and sums of rates
for (i in 1:nrow(allmales))
{
allmales$RateWPCourtP[i] <- allmales$NBCourtWPCourtP[i]/allmales$NBHoursPairedCourtP[i]
allmales$RateEPCourtP[i] <- allmales$NBCourtEPCourtP[i]/allmales$NBHoursPairedCourtP[i]
allmales$RateUPCourtP[i] <- allmales$NBCourtUPCourtP[i]/allmales$NBHoursUnpairedCourtP[i]

allmales$RateWPSocialP[i] <- allmales$NBCourtWPSocialP[i]/allmales$NBHoursPairedSocialP[i]
allmales$RateEPSocialP[i] <- allmales$NBCourtEPSocialP[i]/allmales$NBHoursPairedSocialP[i]
allmales$RateUPSocialP[i] <- allmales$NBCourtUPSocialP[i]/allmales$NBHoursUnpairedSocialP[i]

allmales$RateWPNestBox[i] <- allmales$NBCourtWPNestBox[i]/allmales$NBHoursPairedNestBox[i]
allmales$RateEPNestBox[i] <- allmales$NBCourtEPNestBox[i]/allmales$NBHoursPairedNestBox[i]
allmales$RateUPNestBox[i] <- allmales$NBCourtUPNestBox[i]/allmales$NBHoursUnpairedNestBox[i]

allmales$SumRateWP[i] <- sum(allmales$RateWPCourtP[i],allmales$RateWPSocialP[i],allmales$RateWPNestBox[i], na.rm=T)
allmales$SumRateEP[i] <- sum(allmales$RateEPCourtP[i],allmales$RateEPSocialP[i],allmales$RateEPNestBox[i], na.rm=T)
allmales$SumRateUP[i] <- sum(allmales$RateUPCourtP[i],allmales$RateUPSocialP[i],allmales$RateUPNestBox[i], na.rm=T)

allmales$SumWEURate[i] <- sum(allmales$SumRateWP[i],allmales$SumRateEP[i],allmales$SumRateUP[i])

allmales$SumWERatePaired[i] <- sum(allmales$SumRateWP[i],allmales$SumRateEP[i])
allmales$RatioWERatePaired[i] <- allmales$SumRateWP[i]/allmales$SumRateEP[i]


allmales$RateCourtP[i] <- allmales$NBCourtCourtP[i]/allmales$NBHoursCourtP[i]
allmales$RateSocialP[i] <- allmales$NBCourtSocialP[i]/allmales$NBHoursSocialP[i]
allmales$RateNestBox[i] <- allmales$NBCourtNestBox[i]/allmales$NBHoursNestBox[i]

allmales$SumAllRate[i] <- sum(allmales$RateCourtP[i],allmales$RateSocialP[i],allmales$RateNestBox[i])


allmales$DisplaySecRateCourtP[i] <- allmales$DisplaySecCourtP[i]/allmales$NBHoursCourtP[i]
allmales$DisplaySecRateSocialP[i] <- allmales$DisplaySecSocialP[i]/allmales$NBHoursSocialP[i]
allmales$DisplaySecRateNestBox[i] <- allmales$DisplaySecNestBox[i]/allmales$NBHoursNestBox[i]


allmales$SumAllDisplaySecRate[i] <- sum(allmales$DisplaySecRateCourtP[i],allmales$DisplaySecRateSocialP[i],allmales$DisplaySecRateNestBox[i])



}

allmales$SumRateWP[allmales$PolySt == "unpaired"] <- NA
allmales$SumRateEP[allmales$PolySt == "unpaired"] <- NA
allmales$SumWERatePaired[allmales$PolySt == "unpaired"] <- NA
allmales$RatioWERatePaired[allmales$PolySt == "unpaired"] <- NA
}

hist(allmales$SumWEURate-allmales$SumAllRate)

{# add NB hours watched during the fertile period of the partner from MalePairingstatus

MalePairingStatus <- merge( x = MalePairingStatus, y = FemalePairingStatus[,c('IDyrday','RelDayMod','nEggsLayedLast5Days')], by.x = 'PartnerIDyrday', by.y = 'IDyrday', all.x = TRUE)
head(MalePairingStatus)
MalePairingStatusFertile <- MalePairingStatus [MalePairingStatus$RelDayMod != 5, ]
MalePairingStatusFertile_listperIDyr <- split(MalePairingStatusFertile, MalePairingStatusFertile$IDyr)

MalePairingStatusFertile_listperIDyr_fun = function(x)  {
return(c(

sum(x$WatchedYN), # NBHours
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1]),	#NBHoursPaired
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0]),	#NBHoursUnpaired 

sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1 & x$RecPosition == "Courtship P"]),	#NBHoursPairedCourtP
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1 & x$RecPosition == "Social P"]),	#NBHoursPairedSocialP
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1 & (x$RecPosition == "NB up" | x$RecPosition == "RAC")]),	#NBHoursPairedNestBox

sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0 & x$RecPosition == "Courtship P"]),	#NBHoursUnpairedCourtP
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0 & x$RecPosition == "Social P"]),	#NBHoursUnpairedSocialP
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0 & (x$RecPosition == "NB up" | x$RecPosition == "RAC")])	#NBHoursUnpairedNestBox

))
 
 }	
 
MalePairingStatusFertile_listperIDyrout1 <- lapply(MalePairingStatusFertile_listperIDyr, FUN=MalePairingStatusFertile_listperIDyr_fun)
MalePairingStatusFertile_listperIDyrout2 <- data.frame(rownames(do.call(rbind, MalePairingStatusFertile_listperIDyrout1)),do.call(rbind, MalePairingStatusFertile_listperIDyrout1))
rownames(MalePairingStatusFertile_listperIDyrout2) <- NULL
colnames(MalePairingStatusFertile_listperIDyrout2) <- c('IDyr','NBHoursFertile','NBHoursPairedFertile','NBHoursUnpairedFertile','NBHoursPairedCourtPFertile','NBHoursPairedSocialPFertile','NBHoursPairedNestBoxFertile','NBHoursUnpairedCourtPFertile','NBHoursUnpairedSocialPFertile','NBHoursUnpairedNestBoxFertile')

allmalesFertile <- merge(y = MalePairingStatusFertile_listperIDyrout2, x = allmales, by.y = 'IDyr', by.x = "IDYear", all.x=TRUE)
}

{# add NB WP Courtships during the fertile period of the female from AllCourt
AllCourtFertile_listperMIDyr <- split(AllCourt[AllCourt$RelDayMod !=5,], AllCourt$MIDyr[AllCourt$RelDayMod !=5])

AllCourtFertile_listperMIDyr_fun = function(x)  {
return(c(
nrow(x[x$MWEU == 'WP',]),	#NBCourtWP
nrow(x[x$MWEU == 'WP' & x$Position == "Courtship P",]),	#NBCourtWPCourtP 
nrow(x[x$MWEU == 'WP' & x$Position == "Social P",]),	#NBCourtWPSocialP 
nrow(x[x$MWEU == 'WP' & x$Position == "Nestbox",])	#NBCourtWPNestbox

))	
  }

AllCourtFertile_listperMIDyrout1 <- lapply(AllCourtFertile_listperMIDyr, FUN=AllCourtFertile_listperMIDyr_fun)
AllCourtFertile_listperMIDyrout2 <- data.frame(rownames(do.call(rbind, AllCourtFertile_listperMIDyrout1)),do.call(rbind, AllCourtFertile_listperMIDyrout1))
rownames(AllCourtFertile_listperMIDyrout2) <- NULL
colnames(AllCourtFertile_listperMIDyrout2) <- c('IDyr','NBCourtWPFertile','NBCourtWPCourtPFertile','NBCourtWPSocialPFertile','NBCourtWPNestboxFertile')

allmalesFertile <- merge(y = AllCourtFertile_listperMIDyrout2, x = allmalesFertile, by.y = 'IDyr', by.x = "IDYear", all.x=TRUE)
}

{# add rates and sums of rates during the fertile period of the female receiving the courtship

for (i in 1:nrow(allmalesFertile))
{
allmalesFertile$RateWPCourtPFertile[i] <- allmalesFertile$NBCourtWPCourtPFertile[i]/allmalesFertile$NBHoursPairedCourtP[i]
allmalesFertile$RateWPSocialPFertile[i] <- allmalesFertile$NBCourtWPSocialPFertile[i]/allmalesFertile$NBHoursPairedSocialP[i]
allmalesFertile$RateWPNestBoxFertile[i] <- allmalesFertile$NBCourtWPNestBoxFertile[i]/allmalesFertile$NBHoursPairedNestBox[i]
allmalesFertile$SumRateWPFertile[i] <- sum(allmalesFertile$RateWPCourtPFertile[i],allmalesFertile$RateWPSocialPFertile[i],allmalesFertile$RateWPNestBoxFertile[i], na.rm=T)
}

allmalesFertile$SumRateWPFertile[allmales$PolySt == "unpaired"] <- NA

}


}

head(allmales)
head(allmalesFertile)

{### add AllCourt and FemalePairingstatus (Courtship rates received) data in table allfemales

allfemales <- allbirds[allbirds$Sex == 0,]
head(FemalePairingStatus)
FemalePairingStatus$IDyr <- paste(FemalePairingStatus$Ind_ID,FemalePairingStatus$Season, sep="")

{# add NB hours watched from FemalePairingstatus
FemalePairingStatus_listperIDyr <- split(FemalePairingStatus, FemalePairingStatus$IDyr)

FemalePairingStatus_listperIDyr_fun = function(x)  {
return(c(
sum(x$WatchedYN), # NBHours
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 1]),	#NBHoursPaired
sum(x$WatchedYN[x$Watched == 1 & x$pairedYN == 0])	#NBHoursUnpaired 
))
}	
 
FemalePairingStatus_listperIDyrout1 <- lapply(FemalePairingStatus_listperIDyr, FUN=FemalePairingStatus_listperIDyr_fun)
FemalePairingStatus_listperIDyrout2 <- data.frame(rownames(do.call(rbind, FemalePairingStatus_listperIDyrout1)),do.call(rbind, FemalePairingStatus_listperIDyrout1))
rownames(FemalePairingStatus_listperIDyrout2) <- NULL
colnames(FemalePairingStatus_listperIDyrout2) <- c('IDyr','NBHours','NBHoursPaired','NBHoursUnpaired')

allfemales <- merge(y = FemalePairingStatus_listperIDyrout2, x = allfemales, by.y = 'IDyr', by.x = "IDYear", all.x=TRUE)
}

{# add NB Courtships from AllCourt to all females
AllCourt_listperFIDyr <- split(AllCourt, AllCourt$FIDyr)
AllCourt_listperFIDyr[[1]]

AllCourt_listperFIDyr_fun = function(x)  {
return(c(
nrow(x), # NBCourt
nrow(x[x$FWEU == 'WP',]),	#NBCourtWP
nrow(x[x$FWEU == 'EP',]),	#NBCourtEP
nrow(x[x$FWEU == 'UP',])	#NBCourtUP
))
}

AllCourt_listperFIDyrout1 <- lapply(AllCourt_listperFIDyr, FUN=AllCourt_listperFIDyr_fun)
AllCourt_listperFIDyrout2 <- data.frame(rownames(do.call(rbind, AllCourt_listperFIDyrout1)),do.call(rbind, AllCourt_listperFIDyrout1))
rownames(AllCourt_listperFIDyrout2) <- NULL
colnames(AllCourt_listperFIDyrout2) <- c('IDyr','NBCourt','NBCourtWP','NBCourtEP','NBCourtUP')

allfemales <- merge(y = AllCourt_listperFIDyrout2, x = allfemales, by.y = 'IDyr', by.x = "IDYear", all.x=TRUE)
}

{# add rates and sums of rates
for (i in 1:nrow(allfemales))
{
allfemales$RateWP[i] <- allfemales$NBCourtWP[i]/allfemales$NBHoursPaired[i]
allfemales$RateEP[i] <- allfemales$NBCourtEP[i]/allfemales$NBHoursPaired[i]
allfemales$RateUP[i] <- allfemales$NBCourtUP[i]/allfemales$NBHoursUnpaired[i]

allfemales$SumWEURate[i] <- sum(allfemales$RateWP[i],allfemales$RateEP[i],allfemales$RateUP[i])

allfemales$SumWERatePaired[i] <- sum(allfemales$RateWP[i],allfemales$RateEP[i])
allfemales$RatioWERatePaired[i] <- allfemales$RateWP[i]/allfemales$RateEP[i]
}

allfemales$RateWP[allfemales$PolySt == "unpaired"] <- NA
allfemales$RateEP[allfemales$PolySt == "unpaired"] <- NA
allfemales$SumWERatePaired[allfemales$PolySt == "unpaired"] <- NA
allfemales$RatioWERatePaired[allfemales$PolySt == "unpaired"] <- NA
}

}

head(allfemales)


###
{## list of Pairs, MID and FID that kept the Trt

MIDFIDOk <- unique(allbirds$MIDFID[allbirds$Divorced == 0 ])
length(MIDFIDOk)	# 70 (14 'stay' pairs, not repeated twice)

MIDFIDYearOk <- unique(allbirds$MIDFIDYear[allbirds$Divorced == 0 ])	#(or with '& allbirds$MIDFID != 1119011187' if Pbdur MIDFID ect for polygynous female considered their primery female)
length(MIDFIDYearOk)	# 84
length(unique(allbirds$MIDFIDYear[allbirds$Divorced == 0 & allbirds$Season == 2012 ]))#45
length(unique(allbirds$MIDFIDYear[allbirds$Divorced == 0 & allbirds$Season == 2012 & allbirds$Treatment == 'NC']))#19
length(unique(allbirds$MIDFIDYear[allbirds$Divorced == 0 & allbirds$Season == 2012 & allbirds$Treatment == 'C']))#26
length(unique(allbirds$MIDFIDYear[allbirds$Divorced == 0 & allbirds$Season == 2013 ]))#39
length(unique(allbirds$MIDFIDYear[allbirds$Divorced == 0 & allbirds$Season == 2013 & allbirds$Treatment == 'NC']))#19
length(unique(allbirds$MIDFIDYear[allbirds$Divorced == 0 & allbirds$Season == 2013 & allbirds$Treatment == 'C']))#20



MIDYearOk <- unique(allbirds$IDYear[allbirds$Divorced == 0 & allbirds$Sex == 1])
length(MIDYearOk)	# 84

FIDYearOk <- unique(allbirds$IDYear[allbirds$Divorced == 0 & allbirds$Sex == 0])
length(FIDYearOk)	# 84

}
###


{### add data Eggs in table Clutch as cbind for each fate and tests for Pairs (Ass or Soc) that kept the Trt

{# Fate0 : MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1

Eggs_listperClutchAssFate0 <- split(Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,], Eggs$ClutchAss[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1])

Eggs_listperClutchAssFate0_fun = function(x)  {
return(c(
nrow(x[x$EggFate == 0,]),
nrow(x[x$EggFate != 0,])
))
}

Eggs_listperClutchAssFate0_out1 <- lapply(Eggs_listperClutchAssFate0, FUN=Eggs_listperClutchAssFate0_fun)
Eggs_listperClutchAssFate0_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchAssFate0_out1)),do.call(rbind, Eggs_listperClutchAssFate0_out1))

nrow(Eggs_listperClutchAssFate0_out2)	# 216
rownames(Eggs_listperClutchAssFate0_out2) <- NULL
colnames(Eggs_listperClutchAssFate0_out2) <- c('ClutchAss', 'IF','nonIF')

TableClutchAssFate0 <- merge(x=Eggs_listperClutchAssFate0_out2, y = unique(Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,c('ClutchAss','MassTrt','MIDFIDass','Mass','Fass','Season')]), by.y = 'ClutchAss', by.x = "ClutchAss", all.x=TRUE)

head(TableClutchAssFate0)
nrow(TableClutchAssFate0) # 216

sum(TableClutchAssFate0$nonIF)# 717 (+63 =780)
sum(TableClutchAssFate0$IF)	# 63

}

{# Fate1 : MIDFIDSoc%in%MIDFIDOk

Eggs_listperClutchSocFate1 <- split(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk])
x <-Eggs_listperClutchSocFate1[[1]]

Eggs_listperClutchSocFate1_fun = function(x)  {
return(c(
nrow(x[x$EggFate == 1,]),
nrow(x[x$EggFate != 1,])
))
}

Eggs_listperClutchSocFate1_out1 <- lapply(Eggs_listperClutchSocFate1, FUN=Eggs_listperClutchSocFate1_fun)
Eggs_listperClutchSocFate1_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocFate1_out1)),do.call(rbind, Eggs_listperClutchSocFate1_out1))

nrow(Eggs_listperClutchSocFate1_out2)	# 222
rownames(Eggs_listperClutchSocFate1_out2) <- NULL
colnames(Eggs_listperClutchSocFate1_out2) <- c('ClutchID', 'Fate1','Fate023456')

TableClutchSocFate1 <- merge(x=Eggs_listperClutchSocFate1_out2, y = unique(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,c('ClutchID','MTrt','MIDFIDSoc','MID','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)

head(TableClutchSocFate1)
nrow(TableClutchSocFate1) # 222

sum(TableClutchSocFate1$Fate1)# 320
sum(TableClutchSocFate1$Fate023456)	# 852 (+320 = 1172)

}

{# Fate2 : MIDFIDGen%in%MIDFIDOk

Eggs_listperClutchGenFate2 <- split(Eggs[Eggs$MIDFIDGen%in%MIDFIDOk & Eggs$EggFate > 1,], Eggs$ClutchAss[Eggs$MIDFIDGen%in%MIDFIDOk & Eggs$EggFate > 1])
x <-Eggs_listperClutchGenFate2 [[1]]

Eggs_listperClutchGenFate2_fun = function(x)  {
return(c(
nrow(x[x$EggFate == 2,]),
nrow(x[x$EggFate > 2,])
))
}

Eggs_listperClutchGenFate2_out1 <- lapply(Eggs_listperClutchGenFate2, FUN=Eggs_listperClutchGenFate2_fun)
Eggs_listperClutchGenFate2_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchGenFate2_out1)),do.call(rbind, Eggs_listperClutchGenFate2_out1))

nrow(Eggs_listperClutchGenFate2_out2)	# 205
rownames(Eggs_listperClutchGenFate2_out2) <- NULL
colnames(Eggs_listperClutchGenFate2_out2) <- c('ClutchGen', 'Fate2','Fate3456')

TableClutchGenFate2 <- merge(x=Eggs_listperClutchGenFate2_out2, y = unique(Eggs[Eggs$MIDFIDGen%in%MIDFIDOk & Eggs$EggFate > 1,c('ClutchAss','MGenTrt','MIDFIDGen','MGen','FGen','Season')]), by.y = 'ClutchAss', by.x = "ClutchGen", all.x=TRUE)

head(TableClutchGenFate2)
nrow(TableClutchGenFate2) # 205

sum(TableClutchGenFate2$Fate2)# 167
sum(TableClutchGenFate2$Fate3456)	# 540 (+167 = 707)

}

{# Fate34 : MIDFIDSoc%in%MIDFIDOk

Eggs_listperClutchSocFate34 <- split(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$EggFate > 2])
x <-Eggs_listperClutchSocFate34[[1]]

Eggs_listperClutchSocFate34_fun = function(x)  {
return(c(
nrow(x[x$EggFate == 3 | x$EggFate == 4,]),
nrow(x[x$EggFate == 5 | x$EggFate == 6,])
))
}

Eggs_listperClutchSocFate34_out1 <- lapply(Eggs_listperClutchSocFate34, FUN=Eggs_listperClutchSocFate34_fun)
Eggs_listperClutchSocFate34_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocFate34_out1)),do.call(rbind, Eggs_listperClutchSocFate34_out1))

nrow(Eggs_listperClutchSocFate34_out2)	# 181
rownames(Eggs_listperClutchSocFate34_out2) <- NULL
colnames(Eggs_listperClutchSocFate34_out2) <- c('ClutchID', 'Fate34','Fate56')

TableClutchSocFate34 <- merge(x=Eggs_listperClutchSocFate34_out2, y = unique(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,c('ClutchID','MTrt','MIDFIDSoc','MID','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)

head(TableClutchSocFate34)
nrow(TableClutchSocFate34) # 181

sum(TableClutchSocFate34$Fate34)	# 245
sum(TableClutchSocFate34$Fate56)	# 349 (+245 = 594)

}

{# Fate56 Soc : MIDFIDSoc%in%MIDFIDOk

Eggs_listperClutchSocFate56 <- split(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk])
Eggs_listperClutchSocFate56[[1]]

Eggs_listperClutchSocFate56_fun = function(x)  {
return(c(
nrow(x[x$EggFate == 5 | x$EggFate == 6,]),
nrow(x[x$EggFate != 5 & x$EggFate != 6,])
))
}

Eggs_listperClutchSocFate56_out1 <- lapply(Eggs_listperClutchSocFate56, FUN=Eggs_listperClutchSocFate56_fun)
Eggs_listperClutchSocFate56_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocFate56_out1)),do.call(rbind, Eggs_listperClutchSocFate56_out1))

nrow(Eggs_listperClutchSocFate56_out2)	# 222
rownames(Eggs_listperClutchSocFate56_out2) <- NULL
colnames(Eggs_listperClutchSocFate56_out2) <- c('ClutchID', 'Fate56','Fate01234')

TableClutchSocFate56 <- merge(x=Eggs_listperClutchSocFate56_out2, y = unique(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,c('ClutchID','MTrt','MIDFIDSoc','MID','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)

head(TableClutchSocFate56)
nrow(TableClutchSocFate56) # 222

sum(TableClutchSocFate56$Fate56)	# 349
sum(TableClutchSocFate56$Fate01234)	# 823 (+349 = 1172)

}

{# Fate56 Ass : MIDFIDass%in%MIDFIDOk

Eggs_listperClutchAssFate56 <- split(Eggs[Eggs$MIDFIDass%in%MIDFIDOk,], Eggs$ClutchAss[Eggs$MIDFIDass%in%MIDFIDOk])
Eggs_listperClutchAssFate56[[1]]

Eggs_listperClutchAssFate56_fun = function(x)  {
return(c(
nrow(x[x$EggFate == 5 | x$EggFate == 6,]),
nrow(x[x$EggFate != 5 & x$EggFate != 6,])
))
}

Eggs_listperClutchAssFate56_out1 <- lapply(Eggs_listperClutchAssFate56, FUN=Eggs_listperClutchAssFate56_fun)
Eggs_listperClutchAssFate56_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchAssFate56_out1)),do.call(rbind, Eggs_listperClutchAssFate56_out1))

nrow(Eggs_listperClutchAssFate56_out2)	# 251
rownames(Eggs_listperClutchAssFate56_out2) <- NULL
colnames(Eggs_listperClutchAssFate56_out2) <- c('ClutchAss', 'Fate56','Fate01234')

TableClutchAssFate56 <- merge(x=Eggs_listperClutchAssFate56_out2, y = unique(Eggs[Eggs$MIDFIDass%in%MIDFIDOk,c('ClutchAss','MassTrt','MIDFIDass','Mass','Fass','Season')]), by.y = 'ClutchAss', by.x = "ClutchAss", all.x=TRUE)

head(TableClutchAssFate56)
nrow(TableClutchAssFate56) # 251

sum(TableClutchAssFate56$Fate56)	# 323
sum(TableClutchAssFate56$Fate01234)	# 752 (+323 = 1075)

}

{# EPY : FGenYear%in%FIDYearOk

Eggs_listperClutchGenEPY <- split(Eggs[Eggs$FGenYear%in%FIDYearOk ,], Eggs$ClutchAss[Eggs$FGenYear%in%FIDYearOk])
Eggs_listperClutchGenEPY [[1]]

Eggs_listperClutchGenEPY_fun = function(x)  {
return(c(
nrow(x[x$EPY == 1,]),
nrow(x[x$EPY == 0,])
))
}

Eggs_listperClutchGenEPY_out1 <- lapply(Eggs_listperClutchGenEPY, FUN=Eggs_listperClutchGenEPY_fun)
Eggs_listperClutchGenEPY_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchGenEPY_out1)),do.call(rbind, Eggs_listperClutchGenEPY_out1))

nrow(Eggs_listperClutchGenEPY_out2)	# 245
rownames(Eggs_listperClutchGenEPY_out2) <- NULL
colnames(Eggs_listperClutchGenEPY_out2) <- c('ClutchGen', 'EPY','WPY')

TableClutchGenEPY <- merge(x=Eggs_listperClutchGenEPY_out2, y = unique(Eggs[Eggs$FGenYear%in%FIDYearOk,c('ClutchAss','FGenTrt','FGen','Season')]), by.y = 'ClutchAss', by.x = "ClutchGen", all.x=TRUE)

head(TableClutchGenEPY)
nrow(TableClutchGenEPY) # 245

sum(TableClutchGenEPY$EPY) # 78
sum(TableClutchGenEPY$WPY)	# 793(+78 = 871)

}

{# Dumped : FIDYear%in%FIDYearOk

Eggs_listperClutchSocDumped <- split(Eggs[Eggs$FIDYear%in%FIDYearOk & !(is.na(Eggs$FGen)) ,], Eggs$ClutchID[Eggs$FIDYear%in%FIDYearOk& !(is.na(Eggs$FGen))])
nrow(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,])	#1172
nrow(Eggs[Eggs$FIDYear%in%FIDYearOk,])	#1172
length(unique(Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk]))	#222
length(unique(Eggs$ClutchID[Eggs$FIDYear%in%FIDYearOk]))	#222
length(unique(Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$FGen))]))	#209
length(unique(Eggs$ClutchID[Eggs$FIDYear%in%FIDYearOk & !(is.na(Eggs$FGen))]))	#209

Eggs_listperClutchSocDumped[[1]]

Eggs_listperClutchSocDumped_fun = function(x)  {
return(c(
nrow(x[x$DumpedEgg == 1,]),
nrow(x[x$DumpedEgg == 0,])
))
}

Eggs_listperClutchSocDumped_out1 <- lapply(Eggs_listperClutchSocDumped, FUN=Eggs_listperClutchSocDumped_fun)
Eggs_listperClutchSocDumped_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocDumped_out1)),do.call(rbind, Eggs_listperClutchSocDumped_out1))

rownames(Eggs_listperClutchSocDumped_out2) <- NULL
colnames(Eggs_listperClutchSocDumped_out2) <- c('ClutchID', 'DumpedY','DumpedN')

TableClutchSocDumped <- merge(x=Eggs_listperClutchSocDumped_out2, y = unique(Eggs[Eggs$FIDYear%in%FIDYearOk,c('ClutchID','FTrt','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)

head(TableClutchSocDumped)

TableClutchSocDumpedYN <- TableClutchSocDumped[TableClutchSocDumped$DumpedN!=0,]
nrow(TableClutchSocDumpedYN) # 195

TableClutchSocDumpedwithonlyDumpedEggs <-TableClutchSocDumped[TableClutchSocDumped$DumpedN==0,]	#14 clutches with only dumped eggs


sum(TableClutchSocDumpedYN$DumpedY) # 56
sum(TableClutchSocDumpedYN$DumpedN)	# 757(+56 = 813)

}

}

head(TableClutchAssFate0)
head(TableClutchSocFate1)
head(TableClutchGenFate2)
head(TableClutchSocFate34)
head(TableClutchSocFate56)
head(TableClutchAssFate56)
head(TableClutchGenEPY)
head(TableClutchSocDumpedYN)


{### add data Eggs in table Clutch as YN for each fate for Pairs (Ass or Soc) that kept the Trt

{# Fate0YN : MIDFIDass%in%MIDFIDOk
Eggs_listperClutchAssFate0YN <- split(Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1 ,], Eggs$ClutchAss[Eggs$MIDFIDass%in%MIDFIDOk& Eggs$EggFate != 1])
x<-Eggs_listperClutchAssFate0YN[[1]]

Eggs_listperClutchAssFate0YN_fun = function(x)  {
if (nrow(x[x$EggFate == 0,]) == 0) {return (c(0, nrow(x), min(x$FassPbdurlong)))} else{return(c(1, nrow(x), min(x$FassPbdurlong)))}
}

Eggs_listperClutchAssFate0YN_out1 <- lapply(Eggs_listperClutchAssFate0YN, FUN=Eggs_listperClutchAssFate0YN_fun)
Eggs_listperClutchAssFate0YN_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchAssFate0YN_out1)),do.call(rbind, Eggs_listperClutchAssFate0YN_out1))

nrow(Eggs_listperClutchAssFate0YN_out2)	# 216
rownames(Eggs_listperClutchAssFate0YN_out2) <- NULL
colnames(Eggs_listperClutchAssFate0YN_out2) <- c('ClutchAss', 'IFYN','ClutchSize','FassPbdurlong')

Eggs$MassTrt <- as.factor(Eggs$MassTrt)

TableClutchAssFate0YN <- merge(x=Eggs_listperClutchAssFate0YN_out2, y = unique(Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,c('ClutchAss','MassTrt','MIDFIDass','Mass','Fass','Season')]), by.y = 'ClutchAss', by.x = "ClutchAss", all.x=TRUE)

head(TableClutchAssFate0YN)
nrow(TableClutchAssFate0YN) # 216

sum(TableClutchAssFate0YN$IFYN) # 39 

}

{# EPY : FGenYear%in%FIDYearOk

Eggs_listperClutchGenEPYYN <- split(Eggs[Eggs$FGenYear%in%FIDYearOk ,], Eggs$ClutchAss[Eggs$FGenYear%in%FIDYearOk])
Eggs_listperClutchGenEPYYN [[32]]

Eggs_listperClutchGenEPYYN_fun = function(x)  {
if (nrow(x[x$EPY == 1,]) == 0) {return (c(0, nrow(x),min(x$FassPbdurlong)))} else{return(c(1, nrow(x),min(x$FassPbdurlong)))}
}

Eggs_listperClutchGenEPYYN_out1 <- lapply(Eggs_listperClutchGenEPYYN, FUN=Eggs_listperClutchGenEPYYN_fun)
Eggs_listperClutchGenEPYYN_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchGenEPYYN_out1)),do.call(rbind, Eggs_listperClutchGenEPYYN_out1))

nrow(Eggs_listperClutchGenEPYYN_out2)	# 245
rownames(Eggs_listperClutchGenEPYYN_out2) <- NULL
colnames(Eggs_listperClutchGenEPYYN_out2) <- c('ClutchGen', 'EPYYN', 'ClutchSize', 'FassPbdurlong')

TableClutchGenEPYYN <- merge(x=Eggs_listperClutchGenEPYYN_out2, y = unique(Eggs[Eggs$FGenYear%in%FIDYearOk,c('ClutchAss','FGenTrt','FGen','Season')]), by.y = 'ClutchAss', by.x = "ClutchGen", all.x=TRUE)

TableClutchGenEPYYN <- TableClutchGenEPYYN[!(is.na(TableClutchGenEPYYN$FGen)),]

head(TableClutchGenEPYYN)
nrow(TableClutchGenEPYYN) # 245

sum(TableClutchGenEPYYN$EPYYN) # 44

sum(TableClutchGenEPYYN$EPYYN[TableClutchGenEPYYN$FGenTrt == 'C'])/length(TableClutchGenEPYYN$EPYYN[TableClutchGenEPYYN$FGenTrt == 'C'])# 0.125 (17)

sum(TableClutchGenEPYYN$EPYYN[TableClutchGenEPYYN$FGenTrt == 'NC']) /length(TableClutchGenEPYYN$EPYYN[TableClutchGenEPYYN$FGenTrt == 'NC'])# 0.2477064 (27)
}

{# EPY : MGenYear%in%MIDYearOk

Eggs_listperMGenEPYYN <- split(Eggs[Eggs$MGenYear%in%MIDYearOk ,], Eggs$MGenYear[Eggs$MGenYear%in%MIDYearOk])
Eggs_listperMGenEPYYN [[1]]

Eggs_listperMGenEPYYN_fun = function(x)  {
if (nrow(x[x$EPY == 1,]) == 0) {return (0)} else{return(1)}
}

Eggs_listperMGenEPYYN_out1 <- lapply(Eggs_listperMGenEPYYN, FUN=Eggs_listperMGenEPYYN_fun)
Eggs_listperMGenEPYYN_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperMGenEPYYN_out1)),do.call(rbind, Eggs_listperMGenEPYYN_out1))

nrow(Eggs_listperMGenEPYYN_out2)	# 81
rownames(Eggs_listperMGenEPYYN_out2) <- NULL
colnames(Eggs_listperMGenEPYYN_out2) <- c('MGenYear', 'EPYYN')

TableMGenEPYYN <- merge(x=Eggs_listperMGenEPYYN_out2, y = unique(Eggs[Eggs$MGenYear%in%MIDYearOk,c('MGenYear','MGen','MGenTrt','Season')]), by.y = 'MGenYear', by.x = "MGenYear", all.x=TRUE)

TableMGenEPYYN <- merge(x=TableMGenEPYYN, y = allbirds[,c('IDYear','Pbdurlong')], by.y = 'IDYear', by.x = "MGenYear", all.x=TRUE)


head(TableMGenEPYYN)
nrow(TableMGenEPYYN) # 81

sum(TableMGenEPYYN$EPYYN) # 25

sum(TableMGenEPYYN$EPYYN[TableMGenEPYYN$MGenTrt == 'C'])/length(TableMGenEPYYN$EPYYN[TableMGenEPYYN$MGenTrt == 'C'])# 0.3695652 (17)

sum(TableMGenEPYYN$EPYYN[TableMGenEPYYN$MGenTrt == 'NC']) /length(TableMGenEPYYN$EPYYN[TableMGenEPYYN$MGenTrt == 'NC'])# 0.2285714 (8)
}

{# Dumped : FIDYear%in%FIDYearOk

Eggs_listperClutchSocDumpedYN <- split(Eggs[Eggs$FIDYear%in%FIDYearOk & !(is.na(Eggs$FGen)) ,], Eggs$ClutchID[Eggs$FIDYear%in%FIDYearOk& !(is.na(Eggs$FGen))])
x<-Eggs_listperClutchSocDumpedYN[[1]] # for 14 ClutchID, only dumped eggs !

Eggs_listperClutchSocDumpedYN_fun = function(x)  {
if (nrow(x[x$DumpedEgg == 1,]) == 0) 
{return (c(
0, 
nrow(x),
min(x$FassPbdurlong[x$DumpedEgg == 0])
))} 

if(nrow(x[x$DumpedEgg == 1,]) < nrow(x)) 
{return(c(
1, 
nrow(x),
min(x$FassPbdurlong[x$DumpedEgg == 0])
))}

if(nrow(x[x$DumpedEgg == 1,]) == nrow(x)) 
{return(c(
1, 
nrow(x),
NA
))}

}

Eggs_listperClutchSocDumpedYN_out1 <- lapply(Eggs_listperClutchSocDumpedYN, FUN=Eggs_listperClutchSocDumpedYN_fun)
Eggs_listperClutchSocDumpedYN_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocDumpedYN_out1)),do.call(rbind, Eggs_listperClutchSocDumpedYN_out1))

nrow(Eggs_listperClutchSocDumpedYN_out2) #209
rownames(Eggs_listperClutchSocDumpedYN_out2) <- NULL
colnames(Eggs_listperClutchSocDumpedYN_out2) <- c('ClutchID', 'DumpedYN','ClutchSize','FassPbdur')

TableClutchSocYNDumped <- merge(x=Eggs_listperClutchSocDumpedYN_out2, y = unique(Eggs[Eggs$FIDYear%in%FIDYearOk,c('ClutchID','FTrt','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)

TableClutchSocYNDumped <- TableClutchSocYNDumped[!(is.na(TableClutchSocYNDumped$FID)),]

nrow(TableClutchSocYNDumped) # 209
sum(TableClutchSocYNDumped$DumpedYN) # 55

}

}

head(TableClutchAssFate0YN)
head(TableClutchGenEPYYN)
head(TableMGenEPYYN)
head(TableClutchSocYNDumped)

{### add brood size (and brood mass) and FLSize per social Clutch of pairs that kept the Trt and add it to table Eggs

{# Brood Size
Eggs_listperClutchSocFated8 <- split(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$EggFate > 2])
x <-Eggs_listperClutchSocFated8[[14]]

Eggs_listperClutchSocFated8_fun = function(x)  {

return(c(
nrow(x[!(is.na(x$Fated8YN)) & x$Fated8YN == 1 ,]),
nrow(x[!(is.na(x$Fated8YN)) & x$Fated8YN == 1 | x$Fated8YN == 0,]),
nrow(x),
min(x$FIDPbdurlong)

))
}

Eggs_listperClutchSocFated8_out1 <- lapply(Eggs_listperClutchSocFated8, FUN=Eggs_listperClutchSocFated8_fun)
Eggs_listperClutchSocFated8_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocFated8_out1)),do.call(rbind, Eggs_listperClutchSocFated8_out1))

nrow(Eggs_listperClutchSocFated8_out2)	# 181
rownames(Eggs_listperClutchSocFated8_out2) <- NULL
colnames(Eggs_listperClutchSocFated8_out2) <- c('ClutchID', 'BroodSize','nbChickHatch', 'ClutchSize', 'Pbdur')

TableClutchSocFated8 <- merge(x=Eggs_listperClutchSocFated8_out2, y = unique(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,c('ClutchID','MTrt','MIDFIDSoc','MID','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)

nrow(TableClutchSocFated8[TableClutchSocFated8$BroodSize != 0,])
nrow(TableClutchSocFated8[TableClutchSocFated8$BroodSize != 0 & TableClutchSocFated8$MTrt =='C',]) # 87
nrow(TableClutchSocFated8[TableClutchSocFated8$BroodSize != 0 & TableClutchSocFated8$MTrt =='NC',]) # 62
nrow(TableClutchSocFated8[TableClutchSocFated8$MTrt =='C',]) # 101
nrow(TableClutchSocFated8[TableClutchSocFated8$MTrt =='NC',]) # 80



Eggs <- merge(x=Eggs, y = TableClutchSocFated8[,c('ClutchID','BroodSize')], by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)


Eggs_listperClutchSocFL <- split(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$EggFate > 2])
x <-Eggs_listperClutchSocFL[[14]]
}

{# Nb of FL
Eggs_listperClutchSocFL_fun = function(x)  {
return(c(
nrow(x[!(is.na(x$FLYN)) & x$FLYN == 1 ,]),
nrow(x[!(is.na(x$FLYN)) & x$FLYN == 1 | x$FLYN == 0,]),
nrow(x),
min(x$FIDPbdurlong)
))
}

Eggs_listperClutchSocFL_out1 <- lapply(Eggs_listperClutchSocFL, FUN=Eggs_listperClutchSocFL_fun)
Eggs_listperClutchSocFL_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocFL_out1)),do.call(rbind, Eggs_listperClutchSocFL_out1))

nrow(Eggs_listperClutchSocFL_out2)	# 181
rownames(Eggs_listperClutchSocFL_out2) <- NULL
colnames(Eggs_listperClutchSocFL_out2) <- c('ClutchID', 'FLSize','nbChickHatch', 'ClutchSize','Pbdur')

TableClutchSocFL <- merge(x=Eggs_listperClutchSocFL_out2, y = unique(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,c('ClutchID','MTrt','MIDFIDSoc','MID','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)

Eggs <- merge(x=Eggs, y = TableClutchSocFL[,c('ClutchID','FLSize')], by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)
}

{# Brood mass
Eggs_listperClutchSocBroodMass <- split(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$EggFate > 2])
x <-Eggs_listperClutchSocBroodMass[[14]]

Eggs_listperClutchSocBroodMass_fun = function(x)  {
return(c(
sum(x$Mass8dChick, na.rm=T),
nrow(x[!(is.na(x$Fated8YN)) & x$Fated8YN == 1,])
))
}

Eggs_listperClutchSocBroodMass_out1 <- lapply(Eggs_listperClutchSocBroodMass, FUN=Eggs_listperClutchSocBroodMass_fun)
Eggs_listperClutchSocBroodMass_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocBroodMass_out1)),do.call(rbind, Eggs_listperClutchSocBroodMass_out1))

nrow(Eggs_listperClutchSocBroodMass_out2)	# 181
rownames(Eggs_listperClutchSocBroodMass_out2) <- NULL
colnames(Eggs_listperClutchSocBroodMass_out2) <- c('ClutchID', 'BroodMass','BroodSize')

TableClutchSocBroodMass <- merge(x=Eggs_listperClutchSocBroodMass_out2, y = unique(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,c('ClutchID','MTrt','MIDFIDSoc','MID','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)
}
}

head(TableClutchSocFated8)
head(TableClutchSocFL)
head(TableClutchSocBroodMass)
head(Eggs)

{### join TableClutchGenEPYYN to TableClutchSocFate34a (exclude social clutches where only dumped eggs)

{# TableClutchSocFate34a (exclude social clutches where only dumped eggs)
Eggs_listperClutchSocFate34 <- split(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$EggFate > 2])

Eggs_listperClutchSocFate34[[41]]	# egg 1609: put clutchAss = 168
Eggs_listperClutchSocFate34[[75]]	# egg 2320, 2321: put clutchAss = 79
Eggs_listperClutchSocFate34[[123]]	# egg 3444: put clutchAss = 99

Eggs$uniqueClutchAss <- Eggs$ClutchAss
Eggs$uniqueClutchAss[Eggs$EggID == 1609] <- 168
Eggs$uniqueClutchAss[Eggs$EggID == 2320 | Eggs$EggID == 2321] <- 79
Eggs$uniqueClutchAss[Eggs$EggID == 3444] <- 99

Eggs_listperClutchSocFate34 <- split(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], Eggs$ClutchID[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$EggFate > 2])

x <- Eggs_listperClutchSocFate34[[74]]
x <- Eggs_listperClutchSocFate34[[98]]
x <- Eggs_listperClutchSocFate34[[104]]
x <- Eggs_listperClutchSocFate34[[134]]
x <- Eggs_listperClutchSocFate34[[151]]
x <- Eggs_listperClutchSocFate34[[159]]
x <- Eggs_listperClutchSocFate34[[162]]

Eggs_listperClutchSocFate34_fun2 = function(x)  {

if (length(unique(x$uniqueClutchAss[x$Fass == x$FID])) != 0)
{
return(c(
nrow(x[x$EggFate == 3 | x$EggFate == 4,]),
nrow(x[x$EggFate == 5 | x$EggFate == 6,]),

unique(x$uniqueClutchAss[x$Fass == x$FID])

))
}
}

Eggs_listperClutchSocFate34_out1a <- lapply(Eggs_listperClutchSocFate34, FUN=Eggs_listperClutchSocFate34_fun2)
Eggs_listperClutchSocFate34_out2a <- data.frame(rownames(do.call(rbind,Eggs_listperClutchSocFate34_out1a)),do.call(rbind, Eggs_listperClutchSocFate34_out1a))

nrow(Eggs_listperClutchSocFate34_out2a)	# 175
rownames(Eggs_listperClutchSocFate34_out2a) <- NULL
colnames(Eggs_listperClutchSocFate34_out2a) <- c('ClutchID', 'Fate34','Fate56', 'ClutchAss')

TableClutchSocFate34a <- merge(x=Eggs_listperClutchSocFate34_out2a, y = unique(Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,c('ClutchID','MTrt','MIDFIDSoc','MID','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)
}

head(TableClutchSocFate34a)
head(TableClutchGenEPYYN)

TableChickMortalityvsEPPYN <- merge (x = TableClutchSocFate34a, y =TableClutchGenEPYYN[,c('ClutchGen', 'EPYYN' ,'ClutchSize')], by.x = 'ClutchAss', by.y = 'ClutchGen', all.x = TRUE)

Eggs[Eggs$ClutchID == 891,]
Eggs[!(is.na(Eggs$ClutchAss)) & Eggs$ClutchAss == 214,]	# the only egg of that clutch was not sampled !
}

head(TableChickMortalityvsEPPYN)

{### add FGenStarvedYN on table Eggs
starvedFemales <- c(11046,11038,11128,11220,11322,11228,11224,11214,11295,11193,11211,11272,11168,11168,11182,11234,11310,11171,11296,11192,11251,11149,11196,11056,11280,11197,11316,11306,11110,11139)

head(Eggs)

Eggs$FGenStarvedYN <- 0

for (i in 1: nrow(Eggs))
{
if (Eggs$Season[i] == 2013 & !(is.na(Eggs$FGen[i])) & Eggs$FGen[i]%in%starvedFemales)
{Eggs$FGenStarvedYN[i] <- 1}

}
}

head(Eggs)

{### add BeforeClutchPeriod, BLUPS of WPesp, nest state and attendance data to FemalePairingStatus

{# add NB Court and BeforeClutchPeriod to FemalePairingStatus 

AllCourt_listperFIDyrday <- split(AllCourt, AllCourt$FIDyrday)
AllCourt_listperFIDyrday[[1]]

AllCourt_listperFIDyrday_fun = function(x)  {
  x = x[order(x$Date),]
return(c(
nrow(x), # NBCourt
nrow(x[x$FWEU == 'WP',]),	#NBCourtWP
nrow(x[x$FWEU == 'EP',]),	#NBCourtEP
nrow(x[x$FWEU == 'UP',])	#NBCourtUP
))
}

AllCourt_listperFIDyrdayout1 <- lapply(AllCourt_listperFIDyrday, FUN=AllCourt_listperFIDyrday_fun)
AllCourt_listperFIDyrdayout2 <- data.frame(rownames(do.call(rbind, AllCourt_listperFIDyrdayout1)),do.call(rbind, AllCourt_listperFIDyrdayout1))
rownames(AllCourt_listperFIDyrdayout2) <- NULL
colnames(AllCourt_listperFIDyrdayout2) <- c('FIDyrday','NBCourt','NBCourtWP','NBCourtEP','NBCourtUP')

FemalePairingStatus <- merge(y = AllCourt_listperFIDyrdayout2, x = FemalePairingStatus, by.y = 'FIDyrday', by.x = "IDyrday", all.x=TRUE)
FemalePairingStatus <- FemalePairingStatus[with(FemalePairingStatus,order(FemalePairingStatus$Ind_ID,FemalePairingStatus$Date)),]

FemalePairingStatus_listperIDyr5 <- split(FemalePairingStatus, FemalePairingStatus$IDyr)
x <-FemalePairingStatus_listperIDyr5[[1]]

FemalePairingStatus_listperIDyr_fun5 = function(x)  {
  x = x[order(x$Date),]
  x$BeforeClutchPeriod[1] <- 1

 for (i in 2:nrow(x) )
 {
 if (x$RelDay[i] == 4 & x$nDaysBeforeNextEgg[i] < 1000)
 { x$BeforeClutchPeriod[i] <- x$BeforeClutchPeriod[i-1]+1}
 if (x$RelDay[i] != 4 & x$nDaysBeforeNextEgg[i] < 1000)
  { x$BeforeClutchPeriod[i] <- x$BeforeClutchPeriod[i-1]}
  if (x$nDaysBeforeNextEgg[i] >= 1000) 
  {x$BeforeClutchPeriod[i] <- NA}
 }
 
 
 return(x) 
 }

FemalePairingStatus_listperIDyrout5 = lapply(FemalePairingStatus_listperIDyr5, FemalePairingStatus_listperIDyr_fun5)
FemalePairingStatus <- do.call(rbind, FemalePairingStatus_listperIDyrout5)

rownames(FemalePairingStatus) <- NULL
}

head(FemalePairingStatus)

{# add BeforeClutchPeriod to AllCourt

AllCourt <- merge(x = AllCourt, y = FemalePairingStatus[,c('IDyrday','BeforeClutchPeriod')], by.x = 'FIDyrday', by.y = "IDyrday", all.x=TRUE)
AllCourt <- AllCourt[with(AllCourt,order(AllCourt$FID,AllCourt$Date)),]

AllCourt$FIDyrBeforeClutchPeriod <- paste(AllCourt$FIDyr, AllCourt$BeforeClutchPeriod, sep="")
AllCourt$FIDyrBeforeClutchPeriod[is.na(AllCourt$BeforeClutchPeriod)] <- NA

}

head(AllCourt)

{# add attendence23YN from NestCheck to Female PairingStatus

head(NestCheck)
nrow(NestCheck)	# 6911
nrow(FemalePairingStatus)	# 9299

FemalePairingStatus$FIDDate <- paste(FemalePairingStatus$Ind_ID, FemalePairingStatus$Date, sep="")

FemalePairingStatus <- merge(x = FemalePairingStatus, y = NestCheck[,c('FIDDate','Attendence23YN','DayClutch','DayBrood','NumEggs','NumChicks','ClutchID')], by.x = 'FIDDate', by.y = "FIDDate", all.x=TRUE)

length(unique(FemalePairingStatus$FIDDate))	#9299

}

head(FemalePairingStatus)

{# add nest state first 15 days of incubation = -1, chicks = 1 (not if NumEggs = NA because fl)
FemalePairingStatus$NestState <- NA

for (i in 1:nrow(FemalePairingStatus))
{
if (!(is.na(FemalePairingStatus$DayClutch[i])) & FemalePairingStatus$DayClutch[i] <=15 & !(is.na(FemalePairingStatus$NumEggs[i])) & FemalePairingStatus$NumEggs[i]!= 0 & is.na(FemalePairingStatus$DayBrood[i])) {FemalePairingStatus$NestState[i] <- -1}
if (!(is.na(FemalePairingStatus$DayClutch[i])) & !(is.na(FemalePairingStatus$DayBrood[i]))) {FemalePairingStatus$NestState[i] <- 1}

}
}

head(FemalePairingStatus)

{# create BLUPs of WPResp for each FIDyrBeforeClutchPeriod for females that kept the Trt

require(lme4)

AllCourtFemaleTrtOkWP <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP")
nrow(AllCourt)	#4918
nrow(AllCourtFemaleTrtOkWP)	#1942

modRespFemaleTrtOkWPforBLUPFIDyrBeforeClutchPeriod <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|FIDyrBeforeClutchPeriod),data= AllCourtFemaleTrtOkWP,REML=FALSE)   
summary(modRespFemaleTrtOkWPforBLUPFIDyrBeforeClutchPeriod)

BLUPFIDyrBeforeClutchPeriod <- data.frame(rownames(ranef(modRespFemaleTrtOkWPforBLUPFIDyrBeforeClutchPeriod)$FIDyrBeforeClutchPeriod),ranef(modRespFemaleTrtOkWPforBLUPFIDyrBeforeClutchPeriod)$FIDyrBeforeClutchPeriod)
rownames(BLUPFIDyrBeforeClutchPeriod) <- NULL
colnames(BLUPFIDyrBeforeClutchPeriod) <- c('FIDyrBeforeClutchPeriod','BLUPFIDyrBeforeClutchPeriod')

modRespFemaleTrtOkWPforBLUPFIDyrBeforeClutchPeriodPairID <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|FIDyrBeforeClutchPeriod) + (1|FIDMID),data= AllCourtFemaleTrtOkWP,REML=FALSE)   
summary(modRespFemaleTrtOkWPforBLUPFIDyrBeforeClutchPeriodPairID)

BLUPFIDyrBeforeClutchPeriodPairID <- data.frame(rownames(ranef(modRespFemaleTrtOkWPforBLUPFIDyrBeforeClutchPeriodPairID)$FIDyrBeforeClutchPeriod),ranef(modRespFemaleTrtOkWPforBLUPFIDyrBeforeClutchPeriodPairID)$FIDyrBeforeClutchPeriod)
rownames(BLUPFIDyrBeforeClutchPeriodPairID) <- NULL
colnames(BLUPFIDyrBeforeClutchPeriodPairID) <- c('FIDyrBeforeClutchPeriod','BLUPFIDyrBeforeClutchPeriodPairID')

BLUPFIDyrBeforeClutchPeriod <- merge(x=BLUPFIDyrBeforeClutchPeriod, y=BLUPFIDyrBeforeClutchPeriodPairID, by.x='FIDyrBeforeClutchPeriod', by.y='FIDyrBeforeClutchPeriod', all.x=TRUE)
}

BLUPFIDyrBeforeClutchPeriod

{# add BLUPS NAs for PeriodBeforeClutch without courtships
MatrixPeriodBeforeClutchwithoutCourtship <-
matrix (
c('1127820122', NA,NA,
'1123520132', NA,NA,
'1123520123', NA,NA,
'1122020121', NA,NA,
'1121420123', NA,NA,
'1121420122', NA,NA,
'1121420121', NA,NA,
'1119720121', NA,NA,
'1118720121', NA,NA,
'1118220122', NA,NA,
'1116520131', NA,NA,
'1116520121', NA,NA,
'1114520124', NA,NA,
'1114520123', NA,NA,
'1114520122', NA,NA,
'1103820132', NA,NA,
'1100620132', NA,NA), nrow= 17, ncol =3, byrow = TRUE)
colnames(MatrixPeriodBeforeClutchwithoutCourtship) <- colnames(BLUPFIDyrBeforeClutchPeriod)
rownames(MatrixPeriodBeforeClutchwithoutCourtship) <- NULL

BLUPFIDyrBeforeClutchPeriod <- rbind (BLUPFIDyrBeforeClutchPeriod,MatrixPeriodBeforeClutchwithoutCourtship)
BLUPFIDyrBeforeClutchPeriod <- BLUPFIDyrBeforeClutchPeriod[order(as.numeric(as.character(BLUPFIDyrBeforeClutchPeriod$FIDyrBeforeClutchPeriod))),]
}

BLUPFIDyrBeforeClutchPeriod
 
{# add clutch order and IDyrClutchOrder to FemalePairingStatus
FemalePairingStatus <- FemalePairingStatus[with(FemalePairingStatus,order(FemalePairingStatus$Ind_ID,FemalePairingStatus$Date)),]
FemalePairingStatus$ClutchOrder <- unlist( lapply( split(FemalePairingStatus, FemalePairingStatus$IDyr), function (x) as.numeric(factor(x$ClutchID))) )
FemalePairingStatus$IDyrClutchOrder <- paste(FemalePairingStatus$IDyr,FemalePairingStatus$ClutchOrder, sep="")
}

head(FemalePairingStatus)

{# add BLUPS to FemalePairingStatus

FemalePairingStatus <- merge (x =FemalePairingStatus, y = BLUPFIDyrBeforeClutchPeriod, by.x = 'IDyrClutchOrder', by.y = 'FIDyrBeforeClutchPeriod', all.x = TRUE)
}

head(FemalePairingStatus)

{# models attendence ~ BlupWPresp

FemalePairingStatus$BLUPFIDyrBeforeClutchPeriod <- as.numeric(FemalePairingStatus$BLUPFIDyrBeforeClutchPeriod)
FemalePairingStatus$BLUPFIDyrBeforeClutchPeriodPairID <- as.numeric(FemalePairingStatus$BLUPFIDyrBeforeClutchPeriodPairID)


FemalePairingStatusTrtOk <- FemalePairingStatus[FemalePairingStatus$IDyr%in%FIDYearOk,]
nrow(FemalePairingStatusTrtOk)	# 7811
nrow(FemalePairingStatus)	# 9299
nrow(FemalePairingStatusTrtOk[!(is.na(FemalePairingStatusTrtOk$NestState)),])	# 3908
nrow(FemalePairingStatusTrtOk[!(is.na(FemalePairingStatusTrtOk$NestState)) &!(is.na(FemalePairingStatusTrtOk$BLUPFIDyrBeforeClutchPeriod)) ,])	# 3502
head(FemalePairingStatusTrtOk[!(is.na(FemalePairingStatusTrtOk$NestState)),])


dataWPrespAttendence <- FemalePairingStatusTrtOk[!(is.na(FemalePairingStatusTrtOk$NestState)) &!(is.na(FemalePairingStatusTrtOk$BLUPFIDyrBeforeClutchPeriod)) ,]


modAttendence23null <- glmer(Attendence23YN ~ BLUPFIDyrBeforeClutchPeriod+ (1|ClutchID), family = 'binomial', data = dataWPrespAttendence)
summary(modAttendence23null)

modAttendence23inter <- glmer(Attendence23YN ~ NestState*DayClutch + BLUPFIDyrBeforeClutchPeriod+ (1|ClutchID), family = 'binomial', data = dataWPrespAttendence)
summary(modAttendence23inter)

modAttendence23interpoly <- glmer(Attendence23YN ~ NestState*poly(DayClutch,2) + BLUPFIDyrBeforeClutchPeriod+ (1|ClutchID), family = 'binomial', data = dataWPrespAttendence)
summary(modAttendence23interpoly)

modAttendence23poly <- glmer(Attendence23YN ~ NestState+poly(DayClutch,2) + BLUPFIDyrBeforeClutchPeriod+ (1|ClutchID), family = 'binomial', data = dataWPrespAttendence)
summary(modAttendence23poly)



anova(modAttendence23null,modAttendence23inter)	# p = < 2.2e-16 ***
anova(modAttendence23null,modAttendence23interpoly)	# p =  < 2.2e-16 ***
anova(modAttendence23inter,modAttendence23interpoly)	# p = 9.868e-05 ***
anova(modAttendence23null,modAttendence23poly)	# p =  < 2.2e-16 ***



modAttendence23polyA <- glmer(Attendence23YN ~ NestState+poly(DayClutch,2) + BLUPFIDyrBeforeClutchPeriodPairID+ (1|ClutchID), family = 'binomial', data = dataWPrespAttendence)
summary(modAttendence23polyA)


}

{# BLUP Attendence23 to FemalePairingStatus

modAttendence23polywithoutBLUPresp <- glmer(Attendence23YN ~ NestState+poly(DayClutch,2) + (1|ClutchID), family = 'binomial', data = dataWPrespAttendence)
summary(modAttendence23polywithoutBLUPresp)


BLUPAttendence23polywithoutBLUPresp <- data.frame(rownames(ranef(modAttendence23polywithoutBLUPresp)$ClutchID),ranef(modAttendence23polywithoutBLUPresp)$ClutchID)
rownames(BLUPAttendence23polywithoutBLUPresp) <- NULL
colnames(BLUPAttendence23polywithoutBLUPresp) <- c('ClutchID','BLUPAttendence23polywithoutBLUPresp')

FemalePairingStatus <- merge (x =FemalePairingStatus, y = BLUPAttendence23polywithoutBLUPresp, by.x = 'ClutchID', by.y = 'ClutchID', all.x = TRUE)
FemalePairingStatus$FIDMIDyrClutchOrder <- paste(FemalePairingStatus$FIDMID, FemalePairingStatus$Season, FemalePairingStatus$ClutchOrder, sep = "")
FemalePairingStatus$FIDMIDyr<- paste(FemalePairingStatus$FIDMID, FemalePairingStatus$Season, sep = "")

FemalePairingStatusTrtOk <- FemalePairingStatus[FemalePairingStatus$IDyr%in%FIDYearOk,]
}

{# within pairs variation
plot(FemalePairingStatusTrtOk$BLUPAttendence23polywithoutBLUPresp,FemalePairingStatusTrtOk$BLUPFIDyrBeforeClutchPeriod)

BlupDataPerClutch <- unique(FemalePairingStatusTrtOk[!(is.na(FemalePairingStatusTrtOk$BLUPAttendence23polywithoutBLUPresp)),c('FIDMIDyr','FIDMIDyrClutchOrder','BLUPAttendence23polywithoutBLUPresp','BLUPFIDyrBeforeClutchPeriod')])
BlupDataPerClutch <- BlupDataPerClutch[order(as.numeric(as.character(BlupDataPerClutch$FIDMIDyrClutchOrder))),]
plot(BlupDataPerClutch)
}

}

head(FemalePairingStatusTrtOk)




# write.table(Eggs, file = "R_Eggs.xls", sep="\t", col.names=TRUE)
# write.table(AllCourt, file = "R_AllCourt.xls", sep="\t", col.names=TRUE)
# write.table(NestCheck, file = "R_NestCheck.xls", sep="\t", col.names=TRUE)
# write.table(FemalePairingStatus, file = "R_FemalePairingStatus.xls", sep="\t", col.names=TRUE)
# write.table(FemalePairingStatusTrtOk, file = "R_FemalePairingStatusTrtOk.xls", sep="\t", col.names=TRUE)


DurationScript <- Sys.time() - TimeStart
DurationScript
# Generation of this first set of data: 15 minutes













{################################################ Sperm MS braket


	##################################################################################
	## Creation of tables male breeding traits to analyse sperm traits consequences ##
	##################################################################################
	
#### server
# conDB= odbcConnectAccess("Z:\\Malika\\_CURRENT BACK UP\\ZebraFinchDBBielefeld.mdb")	

#### laptop
conDB= odbcConnectAccess("C:\\Users\\mihle\\Documents\\_Malika_MPIO\\_CURRENT BACK UP\\ZebraFinchDBBielefeld.mdb")


#############################
##### Malika's data set #####
#############################	

{### create 'allmalesqualities'

{# add info on allmales
allmales$PartnerIDYear <- paste(allmales$PartnerID, allmales$Season, sep="")

for (i in 1:nrow(allmales))
{
if(allmales$PartnerIDYear[i]%in%allfemales$IDYear)
{allmales$PartnerIDTrt[i] <- as.character(allfemales$Treatment[allfemales$IDYear == allmales$PartnerIDYear[i]])}
else{allmales$PartnerIDTrt[i] <-NA}

if (allmales$Polystatus[i] == 'unpaired')
{allmales$PairedYN[i] <- '0'}
else {allmales$PairedYN[i] <- '1'}
}
}

{# subset allmales into allmalesqualities
allmalesqualities <- allmales[,c('IDYear', 'Ind_ID','Season', 'Treatment','PercPresent','PercPaired','PairedYN', 'PartnerID', 'PartnerIDTrt', 'Relfitness', 'RelsiringSucc','SumAllRate','SumAllDisplaySecRate')]


allmalesqualities$PairedYN <- as.factor(allmalesqualities$PairedYN)
allmalesqualities$PartnerID[is.na(allmalesqualities$PartnerID)] <- '0'
allmalesqualities$PartnerID <- as.factor(allmalesqualities$PartnerID)
allmalesqualities$MIDFID <- as.factor(paste(allmalesqualities$Ind_ID, allmalesqualities$PartnerID, sep = ''))

for (i in 1:nrow(allmalesqualities)){
allmalesqualities$sqrtSumAllDisplaySecRate[i] <- sqrt(allmalesqualities$SumAllDisplaySecRate[i])
}
}

{# change partnerID and Trt of polygynous male
# relative fitness is genetic fitness relatively to the entore aviary average fitness, whther individuals kept the trt or not or were mono or polygynous

# male polygynous 11190 kept the treatment with his secondry female 11187. (primery female 11295). His courtships WP are towards 11187.
allmales[allmales$IDYear == 111902012,]
allfemales[allfemales$Ind_ID == 11295,]
allfemales[allfemales$Ind_ID == 11187,]
AllCourt[AllCourt$MIDyr == '111902012',] 
allmalesqualities[allmalesqualities$IDYear == 111902012,]

# male polygynous 11037 did not keep the treatment with his secondary female 11095. Hiw courtships WP are towards his primery female 11193
allmales[allmales$IDYear == 110372012,]
allfemales[allfemales$Ind_ID == 11193,]
allfemales[allfemales$Ind_ID == 11095,]
AllCourt[AllCourt$MIDyr == '110372012',] 
allmalesqualities[allmalesqualities$IDYear == 110372012,]

allmalesqualities$PartnerID[allmalesqualities$IDYear == 110372012] <- 11193
allmalesqualities$PartnerIDTrt[allmalesqualities$IDYear == 110372012] <- 'NC'
}

{# add beak color	

MalesBeakColor

for (i in 1:nrow(allmalesqualities))
{
allmalesqualities$BeakColor[i] <- MalesBeakColor$BeakColourScore[MalesBeakColor$Ind_ID == allmalesqualities$Ind_ID[i]]
}
}

}

head(allmalesqualities)

{### add data Eggs in table Clutch as YN for fate IF or EPloss

{# Fate0YN 
Eggs_listperClutchAssFate0YNAllMales <- split(Eggs[Eggs$EggFate != 1 ,], Eggs$ClutchAss[Eggs$EggFate != 1])
x<-Eggs_listperClutchAssFate0YNAllMales[[1]]


Eggs_listperClutchAssFate0YNAllMales_fun = function(x)  {
if (nrow(x[x$EggFate == 0,]) == 0) {return (c(unique(x$FassYear),unique(x$Fass), unique(as.character(x$FassTrt)), unique(x$Season),nrow(x),min(x$Day),0))} else{return(c(unique(x$FassYear),unique(x$Fass), unique(as.character(x$FassTrt)), unique(x$Season),nrow(x),min(x$Day),1))}
}

Eggs_listperClutchAssFate0YNAllMales_out1 <- lapply(Eggs_listperClutchAssFate0YNAllMales, FUN=Eggs_listperClutchAssFate0YNAllMales_fun)
Eggs_listperClutchAssFate0YNAllMales_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchAssFate0YNAllMales_out1)),do.call(rbind, Eggs_listperClutchAssFate0YNAllMales_out1))

nrow(Eggs_listperClutchAssFate0YNAllMales_out2)	# 271
rownames(Eggs_listperClutchAssFate0YNAllMales_out2) <- NULL
colnames(Eggs_listperClutchAssFate0YNAllMales_out2) <- c('ClutchAss', 'FassYear','Fass','FassTrt','Year','ClutchSize','minDay', 'IFYN')




for (i in 1:nrow(Eggs_listperClutchAssFate0YNAllMales_out2))
{
if( Eggs_listperClutchAssFate0YNAllMales_out2$FassYear[i]%in%allmales$PartnerIDYear)
{
Eggs_listperClutchAssFate0YNAllMales_out2$SocialMalePartner[i] <- allmales$Ind_ID[allmales$PartnerIDYear==Eggs_listperClutchAssFate0YNAllMales_out2$FassYear[i]]
}
else{Eggs_listperClutchAssFate0YNAllMales_out2$SocialMalePartner[i] <- NA}
}

allfemales[allfemales$Ind_ID == 11193,]
allfemales[allfemales$Ind_ID == 11272,]
allfemales[allfemales$Ind_ID == 11295,]

Eggs_listperClutchAssFate0YNAllMales_out2$SocialMalePartner[Eggs_listperClutchAssFate0YNAllMales_out2$FassYear == 111932012] <- 11037
Eggs_listperClutchAssFate0YNAllMales_out2$SocialMalePartner[Eggs_listperClutchAssFate0YNAllMales_out2$FassYear == 112952012] <- 11190


TableClutchAssFate0YNAllMales <- Eggs_listperClutchAssFate0YNAllMales_out2[!is.na(Eggs_listperClutchAssFate0YNAllMales_out2$SocialMalePartner),]
TableClutchAssFate0YNAllMales$MIDYear <- paste(TableClutchAssFate0YNAllMales$SocialMalePartner, TableClutchAssFate0YNAllMales$Year, sep='')


for (i in 1:nrow(TableClutchAssFate0YNAllMales))
{
TableClutchAssFate0YNAllMales$MTrt[i] <- as.character(allmales$Treatment[allmales$IDYear == TableClutchAssFate0YNAllMales$MIDYear[i]])
TableClutchAssFate0YNAllMales$polyStatus[i] <- as.character(MalePairingStatus$polyStatus[MalePairingStatus$IDyr == TableClutchAssFate0YNAllMales$MIDYear[i] & MalePairingStatus$Day==TableClutchAssFate0YNAllMales$minDay[i]])
TableClutchAssFate0YNAllMales$FemalepolyStatus[i] <- as.character(FemalePairingStatus$polyStatus[FemalePairingStatus$IDyr == TableClutchAssFate0YNAllMales$FassYear[i] & FemalePairingStatus$Day==TableClutchAssFate0YNAllMales$minDay[i]])

}

TableClutchAssFate0YNAllMales[TableClutchAssFate0YNAllMales$polyStatus == 'polygynous',]
TableClutchAssFate0YNAllMales[TableClutchAssFate0YNAllMales$FemalepolyStatus != 'monogamous',]


nrow(TableClutchAssFate0YNAllMales) # 270 ( -1 clutch because one clutch of one egg from an unpaired female)

TableClutchAssFate0YNAllMales$IFYN <- as.numeric(as.character(TableClutchAssFate0YNAllMales$IFYN))
TableClutchAssFate0YNAllMales$ClutchSize <- as.numeric(as.character(TableClutchAssFate0YNAllMales$ClutchSize))

sum(TableClutchAssFate0YNAllMales$IFYN) # 47
sum(TableClutchAssFate0YNAllMales$ClutchSize) # 1004

head(Eggs)
length(Eggs$Fass[!is.na(Eggs$Fass)]) #1346
length(Eggs$Fass[!is.na(Eggs$Fass) & Eggs$EggFate != 1]) #1005 (-1 egg from an unpaired female)
length(Eggs$Fass[!is.na(Eggs$Fass) & Eggs$EggFate ==0]) #73 IF eggs
sum (Eggs$Fate0)	# 80 IF eggs
sum (Eggs$Fate0[!is.na(Eggs$Fass)]) # 73

TableClutchAssFate0YNAllMales$IFYN <- as.factor(TableClutchAssFate0YNAllMales$IFYN)
TableClutchAssFate0YNAllMales$MTrt <- as.factor(TableClutchAssFate0YNAllMales$MTrt)
TableClutchAssFate0YNAllMales$Fass <- as.factor(TableClutchAssFate0YNAllMales$Fass)
TableClutchAssFate0YNAllMales$FassYear <- as.factor(TableClutchAssFate0YNAllMales$FassYear)
TableClutchAssFate0YNAllMales$FassTrt <- as.factor(TableClutchAssFate0YNAllMales$FassTrt)
TableClutchAssFate0YNAllMales$Year <-as.numeric(as.character(TableClutchAssFate0YNAllMales$Year))
TableClutchAssFate0YNAllMales$MIDFID <- as.factor(paste(TableClutchAssFate0YNAllMales$SocialMalePartner, TableClutchAssFate0YNAllMales$Fass, sep = ''))
}

{# EPY 

Eggs_listperClutchGenEPYYNAllMales <- split(Eggs[!is.na(Eggs$FGen),], Eggs$ClutchAss[!is.na(Eggs$FGen)])
Eggs_listperClutchGenEPYYNAllMales [[32]]

Eggs_listperClutchGenEPYYNAllMales_fun = function(x)  {
if (nrow(x[x$EPY == 1,]) == 0) 
{return (c(
unique(x$FassYear),
unique(x$Fass), 
unique(as.character(x$FassTrt)), 
unique(x$Season),
nrow(x),
min(x$Day),
0, 
0))} 

else{return(c(
unique(x$FassYear),
unique(x$Fass), 
unique(as.character(x$FassTrt)), 
unique(x$Season),
nrow(x),
min(x$Day),
1, 
nrow(x[x$EPY == 1,])))}
}

Eggs_listperClutchGenEPYYNAllMales_out1 <- lapply(Eggs_listperClutchGenEPYYNAllMales, FUN=Eggs_listperClutchGenEPYYNAllMales_fun)
Eggs_listperClutchGenEPYYNAllMales_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperClutchGenEPYYNAllMales_out1)),do.call(rbind, Eggs_listperClutchGenEPYYNAllMales_out1))

nrow(Eggs_listperClutchGenEPYYNAllMales_out2)	# 289
rownames(Eggs_listperClutchGenEPYYNAllMales_out2) <- NULL
colnames(Eggs_listperClutchGenEPYYNAllMales_out2) <- c('ClutchGen', 'FGenYear','FGen','FGenTrt','Year', 'ClutchSize','minDay','EPYYN', 'nbEPY')



for (i in 1:nrow(Eggs_listperClutchGenEPYYNAllMales_out2))
{
if( Eggs_listperClutchGenEPYYNAllMales_out2$FGenYear[i]%in%allmales$PartnerIDYear)
{
Eggs_listperClutchGenEPYYNAllMales_out2$SocialMalePartner[i] <- allmales$Ind_ID[allmales$PartnerIDYear==Eggs_listperClutchGenEPYYNAllMales_out2$FGenYear[i]]
}
else{Eggs_listperClutchGenEPYYNAllMales_out2$SocialMalePartner[i] <- NA}
}

allfemales[allfemales$Ind_ID == 11193,]
allfemales[allfemales$Ind_ID == 11272,]
allfemales[allfemales$Ind_ID == 11295,]

Eggs_listperClutchGenEPYYNAllMales_out2$SocialMalePartner[Eggs_listperClutchGenEPYYNAllMales_out2$FGenYear == 111932012] <- 11037
Eggs_listperClutchGenEPYYNAllMales_out2$SocialMalePartner[Eggs_listperClutchGenEPYYNAllMales_out2$FGenYear == 112952012] <- 11190


TableClutchGenEPYYNAllMales <- Eggs_listperClutchGenEPYYNAllMales_out2[!is.na(Eggs_listperClutchGenEPYYNAllMales_out2$SocialMalePartner),]
TableClutchGenEPYYNAllMales$MIDYear <- paste(TableClutchGenEPYYNAllMales$SocialMalePartner, TableClutchGenEPYYNAllMales$Year, sep='')

for (i in 1:nrow(TableClutchGenEPYYNAllMales))
{
TableClutchGenEPYYNAllMales$MTrt[i] <- as.character(allmales$Treatment[allmales$IDYear == TableClutchGenEPYYNAllMales$MIDYear[i]])
TableClutchGenEPYYNAllMales$polyStatus[i] <- as.character(MalePairingStatus$polyStatus[MalePairingStatus$IDyr == TableClutchGenEPYYNAllMales$MIDYear[i] & MalePairingStatus$Day==TableClutchGenEPYYNAllMales$minDay[i]])
TableClutchGenEPYYNAllMales$FemalepolyStatus[i] <- as.character(FemalePairingStatus$polyStatus[FemalePairingStatus$IDyr == TableClutchGenEPYYNAllMales$FGenYear[i] & FemalePairingStatus$Day==TableClutchGenEPYYNAllMales$minDay[i]])

}

nrow(TableClutchGenEPYYNAllMales) # 287 ( -2 clutches because two clutches of one egg from an unpaired female)

TableClutchGenEPYYNAllMales$EPYYN <- as.numeric(as.character(TableClutchGenEPYYNAllMales$EPYYN))
TableClutchGenEPYYNAllMales$nbEPY <- as.numeric(as.character(TableClutchGenEPYYNAllMales$nbEPY))
TableClutchGenEPYYNAllMales$ClutchSize <- as.numeric(as.character(TableClutchGenEPYYNAllMales$ClutchSize))

sum(TableClutchGenEPYYNAllMales$EPYYN) # 53
sum(TableClutchGenEPYYNAllMales$ClutchSize) # 1030
sum(TableClutchGenEPYYNAllMales$nbEPY)	# 95 (-1 egg judge EPY from the unpaired female)

head(Eggs)
nrow(Eggs[!is.na(Eggs$FGen),]) #1032
sum (Eggs$EPY, na.rm=T)	# 96 eggs EPY
sum (Eggs$Fate0[!is.na(Eggs$Fass)]) # 73




listEPYperClutchAss <- split(Eggs[!is.na(Eggs$EPY) & Eggs$EPY == 1,c('ClutchAss','MGen')], Eggs$ClutchAss[!is.na(Eggs$EPY) & Eggs$EPY == 1])
# ClutchAss 86, 130, 244 have two EPM siring one egg each > to remove

listEPYperClutchAss_fun = function(x)  {
return (x$MGen[1])
}

listEPYperClutchAss_out1 <- lapply(listEPYperClutchAss, FUN=listEPYperClutchAss_fun)
listEPYperClutchAss_out2 <- data.frame(rownames(do.call(rbind,listEPYperClutchAss_out1)),do.call(rbind, listEPYperClutchAss_out1))

nrow(listEPYperClutchAss_out2)	# 54
rownames(listEPYperClutchAss_out2) <- NULL
colnames(listEPYperClutchAss_out2) <- c('ClutchAss', 'EPM')
listEPYperClutchAss_out2$ClutchAss <- as.character(listEPYperClutchAss_out2$ClutchAss)
listEPYperClutchAss_out2 <- listEPYperClutchAss_out2[listEPYperClutchAss_out2$ClutchAss != '86' & listEPYperClutchAss_out2$ClutchAss != '130' & listEPYperClutchAss_out2$ClutchAss != '244',] # subseting of clutches with only one EPM



for (i in 1:nrow(TableClutchGenEPYYNAllMales))
{
if (TableClutchGenEPYYNAllMales$ClutchGen[i]%in%listEPYperClutchAss_out2$ClutchAss & TableClutchGenEPYYNAllMales$EPYYN[i] == 1)
{TableClutchGenEPYYNAllMales$EPM[i] <- listEPYperClutchAss_out2$EPM[listEPYperClutchAss_out2$ClutchAss == TableClutchGenEPYYNAllMales$ClutchGen[i]]}
else {TableClutchGenEPYYNAllMales$EPM[i] <- NA}
}

for (i in 1:nrow(TableClutchGenEPYYNAllMales))
{ if(!(is.na(TableClutchGenEPYYNAllMales$EPM[i])))
{TableClutchGenEPYYNAllMales$EPMYear[i] <- as.numeric(paste(TableClutchGenEPYYNAllMales$EPM[i], TableClutchGenEPYYNAllMales$Year[i], sep=''))}
else
{TableClutchGenEPYYNAllMales$EPMYear[i] <- NA}
}

TableClutchGenEPYYNAllMales$EPYYN <- as.factor(TableClutchGenEPYYNAllMales$EPYYN)
TableClutchGenEPYYNAllMales$Year <-as.numeric(as.character(TableClutchGenEPYYNAllMales$Year))
TableClutchGenEPYYNAllMales$MIDFID <- as.factor(paste(TableClutchGenEPYYNAllMales$SocialMalePartner, TableClutchGenEPYYNAllMales$FGen, sep = ''))
TableClutchGenEPYYNAllMales$FGen <- as.factor(TableClutchGenEPYYNAllMales$FGen)
TableClutchGenEPYYNAllMales$FGenYear <- as.factor(TableClutchGenEPYYNAllMales$FGenYear)
TableClutchGenEPYYNAllMales$FGenTrt <- as.factor(TableClutchGenEPYYNAllMales$FGenTrt)
TableClutchGenEPYYNAllMales$MTrt <- as.factor(TableClutchGenEPYYNAllMales$MTrt)

for (i in 1:nrow(TableClutchGenEPYYNAllMales)){
TableClutchGenEPYYNAllMales$percEPY[i] <-TableClutchGenEPYYNAllMales$nbEPY[i]/TableClutchGenEPYYNAllMales$ClutchSize[i]
TableClutchGenEPYYNAllMales$nbWPY[i] <-TableClutchGenEPYYNAllMales$ClutchSize[i]-TableClutchGenEPYYNAllMales$nbEPY[i]
}


}

{# sample sizes
	# see also _SummarySpermTests.xlsx 'Males with clutches'
Eggs[!(is.na(Eggs$MassYear)) & Eggs$MassYear == 112022012,] # only one EPY, therefore not in his social clutch
Eggs[!(is.na(Eggs$MIDYear)) & Eggs$MIDYear == 112082013,] # no Mass with Fate != 1 in his social clutches

	# allmales[,c('IDYear','Polystatus','sumEggIDass','sumEggIDGen')]
	# as.data.frame(unique(TableClutchAssFate0YNAllMales$MIDYear))
	# as.data.frame(unique(TableClutchGenEPYYNAllMales$MIDYear))
}

}

head(TableClutchAssFate0YNAllMales)
head(TableClutchGenEPYYNAllMales)

{### Table sperm traits per MID and MIDYear				# !! .txt !! #
RawSpermTraits <- read.table("MalikaSpermTraits.txt", header=T, sep='\t') 

{# data sperm averaged per male-year

List_SpermTraitPerMaleYear <- split(RawSpermTraits, RawSpermTraits$MIDYear)

List_SpermTraitPerMaleYear_fun = function(x)  {
return (c(mean(x$logAbnormal, na.rm=T), mean(x$VCL0s,na.rm=T),mean(x$Slength,na.rm=T) ))
}

List_SpermTraitPerMaleYear_out1 <- lapply(List_SpermTraitPerMaleYear, FUN=List_SpermTraitPerMaleYear_fun)
List_SpermTraitPerMaleYear_out2 <- data.frame(rownames(do.call(rbind,List_SpermTraitPerMaleYear_out1)),do.call(rbind, List_SpermTraitPerMaleYear_out1))

nrow(List_SpermTraitPerMaleYear_out2)	#106 (include spare males?)
rownames(List_SpermTraitPerMaleYear_out2) <- NULL
colnames(List_SpermTraitPerMaleYear_out2) <- c('MIDYear', 'logAbnormal','VCL0s','Slength')

SpermTraitPerMaleYear <- List_SpermTraitPerMaleYear_out2[List_SpermTraitPerMaleYear_out2$MIDYear%in%allmales$IDYear,]
nrow(SpermTraitPerMaleYear)	# 100
}

{# data sperm averaged per male

List_SpermTraitPerMale <- split(RawSpermTraits, RawSpermTraits$MID)

List_SpermTraitPerMale_fun = function(x)  {
return (c(mean(x$logAbnormal, na.rm=T), mean(x$VCL0s,na.rm=T), nrow(x), mean(x$Slength,na.rm=T)))
}

List_SpermTraitPerMale_out1 <- lapply(List_SpermTraitPerMale, FUN=List_SpermTraitPerMale_fun)
List_SpermTraitPerMale_out2 <- data.frame(rownames(do.call(rbind,List_SpermTraitPerMale_out1)),do.call(rbind, List_SpermTraitPerMale_out1))

nrow(List_SpermTraitPerMale_out2)	#63 (include 4 spares males with only one measurement)
allmales[allmales$Ind_ID == 11144 | allmales$Ind_ID == 11241 | allmales$Ind_ID == 11292 | allmales$Ind_ID == 11304,]	# 0 rows
allmales[allmales$Ind_ID == 11262 | allmales$Ind_ID == 11021 ,]	# 2 males that bred only in 2012 and where spare for 2013. 
#  > Make average sperm traits only for first 2 measurement for those two males that bred only in 2012

rownames(List_SpermTraitPerMale_out2) <- NULL
colnames(List_SpermTraitPerMale_out2) <- c('MID', 'logAbnormal','VCL0s','nbMeasures','Slength')

SpermTraitPerMale <- List_SpermTraitPerMale_out2[List_SpermTraitPerMale_out2$MID%in%allmales$Ind_ID,]
nrow(SpermTraitPerMale)	# 59

SpermTraitPerMale$VCL0s[SpermTraitPerMale$MID == 11262] <- mean (RawSpermTraits$VCL0s[RawSpermTraits$MID == 11262 & RawSpermTraits$Year == 2012])
SpermTraitPerMale$logAbnormal[SpermTraitPerMale$MID == 11262] <- mean (RawSpermTraits$logAbnormal[RawSpermTraits$MID == 11262 & RawSpermTraits$Year == 2012])
SpermTraitPerMale$Slength[SpermTraitPerMale$MID == 11262] <- mean (RawSpermTraits$Slength[RawSpermTraits$MID == 11262 & RawSpermTraits$Year == 2012])

SpermTraitPerMale$VCL0s[SpermTraitPerMale$MID == 11021] <- mean (RawSpermTraits$VCL0s[RawSpermTraits$MID == 11021 & RawSpermTraits$Year == 2012])
SpermTraitPerMale$logAbnormal[SpermTraitPerMale$MID == 11021] <- mean (RawSpermTraits$logAbnormal[RawSpermTraits$MID == 11021 & RawSpermTraits$Year == 2012])
SpermTraitPerMale$Slength[SpermTraitPerMale$MID == 11021] <- mean (RawSpermTraits$Slength[RawSpermTraits$MID == 11021 & RawSpermTraits$Year == 2012])

}

{# data sperm averaged per male Mean 2012

List_SpermTraitPerMale2012 <- split(RawSpermTraits[RawSpermTraits$Year == 2012,], RawSpermTraits$MID[RawSpermTraits$Year == 2012])

List_SpermTraitPerMale_fun2012 = function(x)  {
return (c(mean(x$logAbnormal, na.rm=T), mean(x$VCL0s,na.rm=T), nrow(x), mean(x$Slength,na.rm=T)))
}

List_SpermTraitPerMale2012_out1 <- lapply(List_SpermTraitPerMale2012, FUN=List_SpermTraitPerMale_fun2012)
List_SpermTraitPerMale2012_out2 <- data.frame(rownames(do.call(rbind,List_SpermTraitPerMale2012_out1)),do.call(rbind, List_SpermTraitPerMale2012_out1))

nrow(List_SpermTraitPerMale2012_out2)	#63 (include 4 spares males with only one measurement)

rownames(List_SpermTraitPerMale2012_out2) <- NULL
colnames(List_SpermTraitPerMale2012_out2) <- c('MID', 'logAbnormal2012','VCL0s2012','nbMeasures2012','Slength2012')

SpermTraitPerMale2012 <- List_SpermTraitPerMale2012_out2[List_SpermTraitPerMale2012_out2$MID%in%allmales$Ind_ID,]
nrow(SpermTraitPerMale2012)	# 59

SpermTraitPerMale <- merge(x=SpermTraitPerMale, y= SpermTraitPerMale2012, by='MID',all.x=TRUE)

}

{# sperm trait pre breeding season 2012

for (i in 1:nrow(SpermTraitPerMale))
{
SpermTraitPerMale$pre2012VCL0s[i] <- RawSpermTraits$VCL0s[RawSpermTraits$MID == SpermTraitPerMale$MID[i] & RawSpermTraits$Year == 2012 & RawSpermTraits$sampling == 'pre']

SpermTraitPerMale$pre2012logAbnormal[i] <- RawSpermTraits$logAbnormal[RawSpermTraits$MID == SpermTraitPerMale$MID[i] & RawSpermTraits$Year == 2012 & RawSpermTraits$sampling == 'pre']

SpermTraitPerMale$pre2012Slength[i] <- RawSpermTraits$Slength[RawSpermTraits$MID == SpermTraitPerMale$MID[i] & RawSpermTraits$Year == 2012 & RawSpermTraits$sampling == 'pre']

}
}

}

head(SpermTraitPerMale)
head(SpermTraitPerMaleYear)

{### Merge Sperm data to breeding data + Delta WP-EP + scale(Trt)		# !! .txt !! #
MalikaMaleF <- read.table("MalikaMaleF.txt", header=T, sep='\t')

## ClutchIFYN
TableClutchAssFate0YNAllMales <- merge(x=TableClutchAssFate0YNAllMales, y=SpermTraitPerMaleYear, by = 'MIDYear', all.x=T)
nrow(TableClutchAssFate0YNAllMales[TableClutchAssFate0YNAllMales$IFYN == 1,])#47

TableClutchAssFate0YNAllMales <- merge(x=TableClutchAssFate0YNAllMales, y=MalikaMaleF, by.x = 'SocialMalePartner', by.y = 'MID', all.x=T)

## ClutchEPYYN
TableClutchGenEPYYNAllMales <- merge(x=TableClutchGenEPYYNAllMales, y=SpermTraitPerMaleYear, by = 'MIDYear', all.x=T)
TableClutchGenEPYYNAllMales <- merge(x=TableClutchGenEPYYNAllMales, y=SpermTraitPerMaleYear, by.x = 'EPMYear', by.y = 'MIDYear', all.x=T)

colnames(TableClutchGenEPYYNAllMales) <- c('EPMYear','MIDYear','ClutchGen','FGenYear','FGen', 'FGenTrt','Year','ClutchSize','minDay','EPYYN','nbEPY','SocialMalePartner','MTrt','polyStatus', 'FemalepolyStatus','EPM','MIDFID','percEPY','nbWPY','MIDlogAbnormal','MIDVCL0s','MIDSlength','EPMlogAbnormal','EPMVCL0s','EPMSlength')

nrow(TableClutchGenEPYYNAllMales[TableClutchGenEPYYNAllMales$EPYYN == 1,])#51
TableClutchGenEPYYNAllMales <- merge(x=TableClutchGenEPYYNAllMales, y=MalikaMaleF, by.x = 'SocialMalePartner', by.y = 'MID', all.x=T)


# Delta WP-EP
for (i in 1:nrow(TableClutchGenEPYYNAllMales)){
TableClutchGenEPYYNAllMales$DeltalogAbnormal[i] <-TableClutchGenEPYYNAllMales$MIDlogAbnormal[i]-TableClutchGenEPYYNAllMales$EPMlogAbnormal[i]
TableClutchGenEPYYNAllMales$DeltaVCL0s[i] <-TableClutchGenEPYYNAllMales$MIDVCL0s[i]-TableClutchGenEPYYNAllMales$EPMVCL0s[i]
TableClutchGenEPYYNAllMales$DeltaSlength[i] <-TableClutchGenEPYYNAllMales$MIDSlength[i]-TableClutchGenEPYYNAllMales$EPMSlength[i]

}


## allmalesqualities male-year
allmalesqualities <- merge(x=allmalesqualities, y=SpermTraitPerMaleYear, by.x = 'IDYear', by.y = 'MIDYear', all.x=T)
allmalesqualities <- merge(x=allmalesqualities, y=MalikaMaleF, by.x = 'Ind_ID', by.y = 'MID', all.x=T)

## Sperm Trait and attributes Per Male
SpermTraitPerMale <- merge(x= SpermTraitPerMale, y = unique(allmalesqualities[,c('BeakColor', 'Ind_ID')]), by.x = 'MID', by.y = 'Ind_ID', all.x= TRUE)
SpermTraitPerMale <- merge(x= SpermTraitPerMale, y = unique(allmalesqualities[allmalesqualities$Season == 2012 ,c('sqrtSumAllDisplaySecRate', 'Ind_ID')]), by.x= 'MID', by.y = 'Ind_ID', all.x= TRUE)
colnames(SpermTraitPerMale)[which(names(SpermTraitPerMale) == "sqrtSumAllDisplaySecRate")] <- "sqrtSumAllDisplaySecRate2012"

for (i in 1:nrow(SpermTraitPerMale))
{
SpermTraitPerMale$MeansqrtSumAllDisplaySecRate[i] <- mean(allmalesqualities$sqrtSumAllDisplaySecRate[allmalesqualities$Ind_ID == SpermTraitPerMale$MID[i]])
}



# scale Trt
TableClutchAssFate0YNAllMales$numFassTrt <- as.numeric(TableClutchAssFate0YNAllMales$FassTrt)
TableClutchAssFate0YNAllMales$numMTrt <- as.numeric(TableClutchAssFate0YNAllMales$MTrt)
TableClutchGenEPYYNAllMales$numFGenTrt <- as.numeric(TableClutchGenEPYYNAllMales$FGenTrt)
TableClutchGenEPYYNAllMales$numMTrt <- as.numeric(TableClutchGenEPYYNAllMales$MTrt)
allmalesqualities$numMTrt <- as.numeric(allmalesqualities$Treatment)


SpermTraitPerMale <- merge(x= SpermTraitPerMale, y = unique(allmalesqualities[allmalesqualities$Season == 2012 ,c('numMTrt', 'Ind_ID')]), by.x= 'MID', by.y = 'Ind_ID', all.x= TRUE)
colnames(SpermTraitPerMale)[which(names(SpermTraitPerMale) == "numMTrt")] <- "numMTrt2012"

SpermTraitPerMale <- merge(x=SpermTraitPerMale, y=MalikaMaleF, by = 'MID', all.x=T)

}

{# sample sizes
nrow(allmalesqualities)
nrow(allmalesqualities[allmalesqualities$Season == 2013,])#41
nrow(SpermTraitPerMale)
nrow(TableClutchAssFate0YNAllMales)
nrow(TableClutchAssFate0YNAllMales[TableClutchAssFate0YNAllMales$IFYN == 1,])
nrow(TableClutchGenEPYYNAllMales)
nrow(TableClutchGenEPYYNAllMales[TableClutchGenEPYYNAllMales$EPYYN == 1,])
}


head(allmalesqualities)
head(TableClutchAssFate0YNAllMales)
head(TableClutchGenEPYYNAllMales)
head(SpermTraitPerMale)




############################
##### Sanja's data set #####
############################

{### get the tables .txt and merge					# !! .txt !! #

sanjaClutches <- read.table('sanjaClutches.txt', header=T, sep='\t')
sanjaMales <- read.table('sanjaMales.txt', header=T, sep='\t')
sanjaSpermTraits <- read.table('sanjaSpermTraits.txt', header=T, sep='\t')
sanjaFemalesFshort <- read.table('sanjaFFshort.txt', header=T, sep='\t')
sanjaClutcheswithEPM <- read.table('sanjaClutcheswithEPM.txt', header=T, sep='\t')
sanjaBeakMunsel <- read.table('sanjaBeakMunsel.txt', header=T, sep='\t')


sanjaMales <- merge(x=sanjaMales, y=sanjaSpermTraits, by.x = 'MID', by.y = 'MID', all.x=T)
sanjaMales <- merge(x=sanjaMales, y=sanjaBeakMunsel, by.x = 'MID', by.y = 'MID', all.x=T)


for (i in 1:nrow(sanjaMales))
{
if (sanjaMales$Fshort[i] == 0.25)
{sanjaMales$InbredYN[i] <- 1}
else{sanjaMales$InbredYN[i] <- 0}
}


sanjaClutches <- merge(x=sanjaClutches, y=sanjaSpermTraits, by.x = 'MID', by.y = 'MID', all.x=T)
sanjaClutches <- merge(x=sanjaClutches, y=sanjaFemalesFshort, by.x = 'FID', by.y = 'FID', all.x=T)

sanjaClutches <- merge(x=sanjaClutches, y=sanjaMales[,c('MID','InbredYN')], by = 'MID', all.x=T)

for (i in 1:nrow(sanjaClutches))
{
if (sanjaClutches$FFshort[i] == 0.25)
{sanjaClutches$FInbredYN[i] <- 1}
else{sanjaClutches$FInbredYN[i] <- 0}
}



{## sanjaClutcheswithEPM

sanjaClutcheswithEPM <- merge(x=sanjaClutcheswithEPM, y=sanjaSpermTraits, by.x = 'MID', by.y = 'MID', all.x=T)
sanjaClutcheswithEPM <- merge(x=sanjaClutcheswithEPM, y=sanjaSpermTraits, by.x = 'EPMID', by.y = 'MID', all.x=T)
colnames(sanjaClutcheswithEPM) <- c('EPMID',  'MID', 'CID' , 'FID','PID', 'WPY', 'EPY', 'Clutchsize', 'MIDnospermYN', 'MIDVCL0s', 'MIDlogAbnormal', 'MIDSlength','EPMIDnospermYN', 'EPMIDVCL0s', 'EPMIDlogAbnormal','EPMIDSlength')


for (i in 1:nrow(sanjaClutcheswithEPM)){
sanjaClutcheswithEPM$DeltalogAbnormal[i] <-sanjaClutcheswithEPM$MIDlogAbnormal[i]-sanjaClutcheswithEPM$EPMIDlogAbnormal[i]
sanjaClutcheswithEPM$DeltaVCL0s[i] <-sanjaClutcheswithEPM$MIDVCL0s[i]-sanjaClutcheswithEPM$EPMIDVCL0s[i]
sanjaClutcheswithEPM$DeltaSlength[i] <-sanjaClutcheswithEPM$MIDSlength[i]-sanjaClutcheswithEPM$EPMIDSlength[i]
sanjaClutcheswithEPM$percEPY[i] <-sanjaClutcheswithEPM$EPY[i]/sanjaClutcheswithEPM$Clutchsize[i]
}

}

{#nrow(sanjaClutches)
nrow(sanjaClutches)
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)),])#94
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & sanjaClutches$IFYN == 1,])#35
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & !(is.na(sanjaClutches$logAbnormal)),])#44
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & !(is.na(sanjaClutches$logAbnormal))& sanjaClutches$IFYN == 1,])#17
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & !(is.na(sanjaClutches$VCL0s)),])#47
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & !(is.na(sanjaClutches$VCL0s))& sanjaClutches$IFYN == 1,])#18
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & !(is.na(sanjaClutches$Slength)),])#43
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & !(is.na(sanjaClutches$Slength))& sanjaClutches$IFYN == 1,])#16
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & !(is.na(sanjaClutches$nospermYN)),])#52
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) & !(is.na(sanjaClutches$nospermYN))& sanjaClutches$IFYN == 1,])#20
nrow(sanjaClutches[!(is.na(sanjaClutches$IFYN)) &!(is.na(sanjaClutches$nospermYN)) & sanjaClutches$nospermYN == 1,]) #5

nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)),])#84
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & sanjaClutches$EPPYN == 1,])#34
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & !(is.na(sanjaClutches$logAbnormal)),])#39
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & !(is.na(sanjaClutches$logAbnormal))& sanjaClutches$EPPYN == 1,])#15
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & !(is.na(sanjaClutches$VCL0s)),])#42
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & !(is.na(sanjaClutches$VCL0s))& sanjaClutches$EPPYN == 1,])#16
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & !(is.na(sanjaClutches$Slength)),])#39
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & !(is.na(sanjaClutches$Slength))& sanjaClutches$EPPYN == 1,])#14
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & !(is.na(sanjaClutches$nospermYN)),])#46
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) & !(is.na(sanjaClutches$nospermYN))& sanjaClutches$EPPYN == 1,])#19
nrow(sanjaClutches[!(is.na(sanjaClutches$EPPYN)) &!(is.na(sanjaClutches$nospermYN)) & sanjaClutches$nospermYN == 1,] )#4

}

{#nrow(sanjaMales)
nrow(sanjaMales) #36
nrow(sanjaMales[!(is.na(sanjaMales$logAbnormal)), ])	# 13
nrow(sanjaMales[!(is.na(sanjaMales$VCL0s)), ])	# 14
nrow(sanjaMales[!(is.na(sanjaMales$nospermYN)), ])	# 17
nrow(sanjaMales[!(is.na(sanjaMales$nospermYN)) & sanjaMales$Fshort == 0.25, ])	# 7
nrow(sanjaMales[!(is.na(sanjaMales$nospermYN)) & sanjaMales$Fshort < 0.25, ])	# 10
nrow(sanjaMales[!(is.na(sanjaMales$nospermYN))& sanjaMales$nospermYN == 1, ])	# 3
sanjaMales$PercPresent
}

max(sanjaMales$Fshort[!(is.na(sanjaMales$nospermYN)) & sanjaMales$Fshort < 0.25])# 0.01563
median(sanjaMales$Fshort[!(is.na(sanjaMales$nospermYN)) & sanjaMales$Fshort < 0.25])#0
}


head(sanjaClutches)
head(sanjaMales)
head(sanjaClutcheswithEPM)

{### get extra domesticated						    # !! .txt !! #

extradomesticated <- read.table('extradomesticatedSpermTraits.txt', header=T, sep='\t')

sanjaMalesplusExtra <- rbind (extradomesticated, sanjaMales[,c('MID', 'nospermYN',  'Slength', 'VCL0s', 'logAbnormal', 'BeakColourScore', 'InbredYN')])

}

head(sanjaMalesplusExtra)



##############################
##### Johannes' data set #####
##############################

{# Johannes Males and Eggs and CourtshipDisplaySec		# !! sqlQuery!!

JohannesMales <- sqlQuery(conDB, "
SELECT BreedingAviary_Birds.Aviary, Basic_Individuals.Ind_ID, Basic_Individuals.InbredYN, Basic_Individuals.Fshort, Morph_Measurements.BeakColourScore, BreedingAviary_Birds.PercPaired, BreedingAviary_Birds.Polystatus
FROM (Basic_Individuals INNER JOIN (BreedingAviary_Birds INNER JOIN Basic_TrialsTreatments ON BreedingAviary_Birds.Ind_ID = Basic_TrialsTreatments.Ind_ID) ON Basic_Individuals.Ind_ID = Basic_TrialsTreatments.Ind_ID) INNER JOIN Morph_Measurements ON Basic_Individuals.Ind_ID = Morph_Measurements.Ind_ID
WHERE (((Basic_Individuals.Sex)=1) AND ((Basic_TrialsTreatments.TrialTreatment)='force-pairing for quality') AND ((Morph_Measurements.Occasion)='BeforeBreeding2012'));
")


JohannesEggs <- sqlQuery(conDB, "
SELECT Breed_Clutches.ClutchID, Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_Clutches.ClutchSize, Breed_EggsLaid.EggID, Breed_EggsLaid.EggFate, Breed_EggsLaid.EPY, Breed_EggsLaid.DumpedEgg, Breed_EggsLaid.M_Gen, Breed_EggsLaid.F_Gen, Breed_EggsLaid.LayingDate
FROM Breed_Clutches INNER JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID
WHERE (((Breed_Clutches.Experiment)='new pair for force-pairing for quality' Or (Breed_Clutches.Experiment)='force-pairing for quality') AND ((Breed_Clutches.CageAviary)='A') AND ((Breed_Clutches.Remarks) Is Null Or (Breed_Clutches.Remarks)<>'divorced'));
")

{# add Fass, Mass and ClutchAss (difference of 4 days between laying dates) to Johannes Eggs

{# Fass and Mass
for (i in 1:nrow(JohannesEggs))
{
if (!(is.na(JohannesEggs$F_Gen[i])))
{
JohannesEggs$Fass[i] <- JohannesEggs$F_Gen[i]
JohannesEggs$Mass[i] <- JohannesEggs$M_Gen[i]
}
if (is.na(JohannesEggs$F_Gen[i]) & !(is.na(JohannesEggs$F_ID[i])))
{
JohannesEggs$Fass[i] <- JohannesEggs$F_ID[i]
JohannesEggs$Mass[i] <- JohannesEggs$M_ID[i]
}

if (!(is.na(JohannesEggs$F_Gen[i])) & is.na(JohannesEggs$F_ID[i]))
{
JohannesEggs$Fass[i] <- NA
JohannesEggs$Mass[i] <- NA
}
}

}

{# ClutchAss
JohannesEggs <- JohannesEggs[order(JohannesEggs$Fass, JohannesEggs$LayingDate),]

JohannesEggs$ClutchAss <- NA
JohannesEggs$ClutchAss[1] <- 1 

for (i in 2:nrow(JohannesEggs))
{ if (!(is.na(JohannesEggs$Fass[i])))
	{ if((JohannesEggs$LayingDate[i]-JohannesEggs$LayingDate[i-1] < 5) & JohannesEggs$Fass[i] == JohannesEggs$Fass[i-1])
		{JohannesEggs$ClutchAss[i] <- JohannesEggs$ClutchAss[i-1]}
	else {JohannesEggs$ClutchAss[i] <- JohannesEggs$ClutchAss[i-1]+1}
}
 if (is.na(JohannesEggs$Fass[i]))
	{JohannesEggs$ClutchAss[i] <- NA }
}
}

}

{# JohannesNbHoursWatched <- sqlQuery(conDB, "
# SELECT BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Ind_ID, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='Courtship P',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoCourtshipP, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='Social P',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoSocialP, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='NB up' Or [BreedingAviary_PairingStatus]![RecPosition]='RAC',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoNestBoxes
# FROM BreedingAviary_PairingStatus
# GROUP BY BreedingAviary_PairingStatus.Season, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Sex, BreedingAviary_PairingStatus.Ind_ID, BreedingAviary_PairingStatus.WatchedYN
# HAVING (((BreedingAviary_PairingStatus.Season)=2012) AND ((BreedingAviary_PairingStatus.Aviary)=8 Or (BreedingAviary_PairingStatus.Aviary)=9 Or (BreedingAviary_PairingStatus.Aviary)=10 Or (BreedingAviary_PairingStatus.Aviary)=20 Or (BreedingAviary_PairingStatus.Aviary)=21 Or (BreedingAviary_PairingStatus.Aviary)=22) AND ((BreedingAviary_PairingStatus.Sex)=1) AND ((BreedingAviary_PairingStatus.WatchedYN)="1"));
# ")
}


JohannesFemaleFshort <- sqlQuery(conDB, "
SELECT Basic_Individuals.Ind_ID, Basic_Individuals.Fshort
FROM Basic_Individuals INNER JOIN Basic_TrialsTreatments ON Basic_Individuals.Ind_ID = Basic_TrialsTreatments.Ind_ID
WHERE (((Basic_Individuals.Sex)=0) AND ((Basic_TrialsTreatments.TrialTreatment)='force-pairing for quality'));
")


JoDisplay <- read.table("JohannesDisplay.txt", header=TRUE, sep='\t')
JohannesMales <- merge(x=JohannesMales,y=JoDisplay, by.x='Ind_ID',by.y='Ind_ID',all.x=TRUE)


JoBC <- read.table('JohannesBeakColor.txt', header=TRUE, sep='\t')
JohannesMales <- merge(x=JohannesMales,y=JoBC, by.x='Ind_ID',by.y='MID',all.x=TRUE)


JohannesParnterFFshort <- sqlQuery(conDB, "
SELECT Query1.Ind_ID, Sum(Query1.Expr1) AS SumOfExpr1, Sum(Query1.CountPartnerID) AS SumOfCountPartnerID, [SumOfExpr1]/[SumOfCountPartnerID] AS meanFFshort
FROM (SELECT BreedingAviary_Birds.Aviary, Basic_Individuals.Ind_ID, Basic_Individuals.InbredYN, Basic_Individuals.Fshort, Morph_Measurements.BeakColourScore, BreedingAviary_Birds.PercPaired, BreedingAviary_Birds.Polystatus, BreedingAviary_PairingStatus.PartnerID, Count(BreedingAviary_PairingStatus.PartnerID) AS CountPartnerID, Basic_Individuals_1.Fshort AS FFshort, [CountPartnerID]*[FFshort] AS Expr1
FROM Basic_Individuals AS Basic_Individuals_1 INNER JOIN (((Basic_Individuals INNER JOIN (BreedingAviary_Birds INNER JOIN Basic_TrialsTreatments ON BreedingAviary_Birds.Ind_ID = Basic_TrialsTreatments.Ind_ID) ON Basic_Individuals.Ind_ID = Basic_TrialsTreatments.Ind_ID) INNER JOIN Morph_Measurements ON Basic_Individuals.Ind_ID = Morph_Measurements.Ind_ID) INNER JOIN BreedingAviary_PairingStatus ON (BreedingAviary_Birds.Aviary = BreedingAviary_PairingStatus.Aviary) AND (BreedingAviary_Birds.Ind_ID = BreedingAviary_PairingStatus.Ind_ID) AND (BreedingAviary_Birds.Season = BreedingAviary_PairingStatus.Season)) ON Basic_Individuals_1.Ind_ID = BreedingAviary_PairingStatus.PartnerID
GROUP BY BreedingAviary_Birds.Aviary, Basic_Individuals.Ind_ID, Basic_Individuals.InbredYN, Basic_Individuals.Fshort, Morph_Measurements.BeakColourScore, BreedingAviary_Birds.PercPaired, BreedingAviary_Birds.Polystatus, Basic_Individuals.Sex, Basic_TrialsTreatments.TrialTreatment, Morph_Measurements.Occasion, BreedingAviary_PairingStatus.PartnerID, Basic_Individuals_1.Fshort, [CountPartnerID]*[FFshort]
HAVING (((Basic_Individuals.Sex)=1) AND ((Basic_TrialsTreatments.TrialTreatment)='force-pairing for quality') AND ((Morph_Measurements.Occasion)='BeforeBreeding2012'))) AS
Query1
GROUP BY Query1.Ind_ID, [SumOfExpr1]/[SumOfCountPartnerID];
")

max(JohannesMales$Fshort[JohannesMales$Fshort < 0.25])# 0.03125
median(JohannesMales$Fshort[JohannesMales$Fshort < 0.25])# 0
}

close(conDB)

head(JohannesEggs)
head(JohannesMales)
head(JohannesFemaleFshort)

{# Relative fitness and Relative siring success of MGen relative to whole aviary

	{# absolute Fitness or siring success or sired WP and EP

for (i in 1:nrow(JohannesMales))
{
JohannesMales$sumFate56Gen[i] <- nrow (JohannesEggs[!(is.na(JohannesEggs$M_Gen)) & JohannesEggs$M_Gen == JohannesMales$Ind_ID[i] & (JohannesEggs$EggFate == 5 |JohannesEggs$EggFate == 6),])

JohannesMales$sumEggIDGen[i] <- nrow (JohannesEggs[!(is.na(JohannesEggs$M_Gen)) & JohannesEggs$M_Gen == JohannesMales$Ind_ID[i],])

JohannesMales$sumGenWP[i] <- nrow (JohannesEggs[!(is.na(JohannesEggs$M_Gen)) & JohannesEggs$M_Gen == JohannesMales$Ind_ID[i] & !(is.na(JohannesEggs$EPY)) & JohannesEggs$EPY == 0,])

JohannesMales$sumGenEP[i] <- nrow (JohannesEggs[!(is.na(JohannesEggs$M_Gen)) & JohannesEggs$M_Gen == JohannesMales$Ind_ID[i] &  !(is.na(JohannesEggs$EPY)) & JohannesEggs$EPY == 1,])
}

}

	{# calcul of mean fitness and mean siring success per aviary

outJo = list()
aJo = list()

volIDJo <- c(8,9,10,20,21,22)


for (vol in volIDJo){
outJo[[vol]] <- round((colMeans(subset(JohannesMales, Aviary == vol , select=sumFate56Gen))),2)
aJo[[vol]] <- cbind(outJo[[vol]],vol)
}

bJo <- data.frame(do.call(rbind,aJo))
colnames(bJo) <- c("MeanVol","Vol")

JohannesMales$MeanVol <-NA

for (i in 1:nrow(JohannesMales))
{ 
JohannesMales$MeanVol[i] <- bJo$MeanVol[bJo$Vol==JohannesMales$Aviary[i]]
}


soutJo = list()
saJo = list()


for (vol in volIDJo){
soutJo[[vol]] <- round((colMeans(subset(JohannesMales, Aviary == vol , select=sumEggIDGen))),2)
saJo[[vol]] <- cbind(soutJo[[vol]],vol)
}

sbJo <- data.frame(do.call(rbind,saJo))
colnames(sbJo) <- c("SiringMeanVol","Vol")

JohannesMales$SiringMeanVol <-NA

for (i in 1:nrow(JohannesMales))
{ 
JohannesMales$SiringMeanVol[i] <- sbJo$SiringMeanVol[sbJo$Vol==JohannesMales$Aviary[i]]
}
}

	{# add relative fitness and siring success, relative to the whole aviary
for (i in 1:nrow(JohannesMales))
{
JohannesMales$Relfitness[i] <- round(JohannesMales$sumFate56Gen[i]/JohannesMales$MeanVol[i],2) 
JohannesMales$RelsiringSucc[i] <- round(JohannesMales$sumEggIDGen[i]/JohannesMales$SiringMeanVol[i],2)

}
}

}

head(JohannesMales)

{### add data JohannesEggs in table Clutch as YN for fate IF or EPloss

# contrary to script on Malika's data set, I did not consider PolyStatus to change over clutches (after having a look at DB Breeding aviaries Pairing Status)
# both polygynous males 110011 and 11297 kept their two females for the entire duration of the unique breeding season (although the 110011 partners switch back and forth being primery and secondary female)


{# Fate0YN 
Eggs_listperClutchFate0YNAllMalesJo <- split(JohannesEggs[JohannesEggs$EggFate != 1 ,], JohannesEggs$ClutchAss[JohannesEggs$EggFate != 1])
x<-Eggs_listperClutchFate0YNAllMalesJo[[1]]


Eggs_listperClutchFate0YNAllMales_funJo = function(x)  {
if (nrow(x[x$EggFate == 0,]) == 0) {return (c(unique(x$Fass), nrow(x),0))} else{return(c(unique(x$Fass), nrow(x),1))}
}

Eggs_listperClutchFate0YNAllMales_out1Jo <- lapply(Eggs_listperClutchFate0YNAllMalesJo, FUN=Eggs_listperClutchFate0YNAllMales_funJo)
Eggs_listperClutchFate0YNAllMales_out2Jo <- data.frame(rownames(do.call(rbind,Eggs_listperClutchFate0YNAllMales_out1Jo)),do.call(rbind, Eggs_listperClutchFate0YNAllMales_out1Jo))

nrow(Eggs_listperClutchFate0YNAllMales_out2Jo)	# 76
rownames(Eggs_listperClutchFate0YNAllMales_out2Jo) <- NULL
colnames(Eggs_listperClutchFate0YNAllMales_out2Jo) <- c('ClutchAss', 'Fass','ClutchSize','IFYN')

{## dealing with polygynous males
						# head(JohannesEggs)
						# JohannesEggs$MIDFID <- paste(JohannesEggs$M_ID, JohannesEggs$F_ID, sep='')
						# table(JohannesEggs$MIDFID,JohannesEggs$M_ID)

for (i in 1:nrow(Eggs_listperClutchFate0YNAllMales_out2Jo))
{ 
Eggs_listperClutchFate0YNAllMales_out2Jo$SocialMalePartner[i] <- unique(JohannesEggs$M_ID[!(is.na(JohannesEggs$F_ID)) & JohannesEggs$F_ID==Eggs_listperClutchFate0YNAllMales_out2Jo$Fass[i]])
}

Eggs_listperClutchFate0YNAllMales_out2Jo[Eggs_listperClutchFate0YNAllMales_out2Jo$SocialMalePartner ==11090,]
Eggs_listperClutchFate0YNAllMales_out2Jo[Eggs_listperClutchFate0YNAllMales_out2Jo$SocialMalePartner ==11011,]


TableClutchAssFate0YNAllMalesJo <- Eggs_listperClutchFate0YNAllMales_out2Jo

nrow(TableClutchAssFate0YNAllMalesJo) # 76

TableClutchAssFate0YNAllMalesJo$IFYN <- as.numeric(as.character(TableClutchAssFate0YNAllMalesJo$IFYN))
TableClutchAssFate0YNAllMalesJo$ClutchSize <- as.numeric(as.character(TableClutchAssFate0YNAllMalesJo$ClutchSize))

sum(TableClutchAssFate0YNAllMalesJo$IFYN) # 31
sum(TableClutchAssFate0YNAllMalesJo$ClutchSize) # 302
}

{## add polystatus and Male and Female Fshort

for (i in 1:nrow(TableClutchAssFate0YNAllMalesJo))
{
TableClutchAssFate0YNAllMalesJo$Polystatus[i] <- as.character(JohannesMales$Polystatus[JohannesMales$Ind_ID == TableClutchAssFate0YNAllMalesJo$SocialMalePartner[i]])
TableClutchAssFate0YNAllMalesJo$Fshort[i] <- as.character(JohannesMales$Fshort[JohannesMales$Ind_ID == TableClutchAssFate0YNAllMalesJo$SocialMalePartner[i]])
TableClutchAssFate0YNAllMalesJo$FFshort[i] <- JohannesFemaleFshort$Fshort[JohannesFemaleFshort$Ind_ID == TableClutchAssFate0YNAllMalesJo$Fass[i]]
}
}


}

{# EPY 

Eggs_listperClutchGenEPYYNAllMalesJo <- split(JohannesEggs[!is.na(JohannesEggs$F_Gen),], JohannesEggs$ClutchAss[!is.na(JohannesEggs$F_Gen)])
Eggs_listperClutchGenEPYYNAllMalesJo [[32]]

Eggs_listperClutchGenEPYYNAllMales_funJo = function(x)  {
if (nrow(x[x$EPY == 1,]) == 0) {return (c(unique(x$Fass), nrow(x),0, 0))} else{return(c(unique(x$Fass), nrow(x),1, nrow(x[x$EPY == 1,])))}
}

Eggs_listperClutchGenEPYYNAllMales_out1Jo <- lapply(Eggs_listperClutchGenEPYYNAllMalesJo, FUN=Eggs_listperClutchGenEPYYNAllMales_funJo)
Eggs_listperClutchGenEPYYNAllMales_out2Jo <- data.frame(rownames(do.call(rbind,Eggs_listperClutchGenEPYYNAllMales_out1Jo)),do.call(rbind, Eggs_listperClutchGenEPYYNAllMales_out1Jo))

nrow(Eggs_listperClutchGenEPYYNAllMales_out2Jo)	# 70
rownames(Eggs_listperClutchGenEPYYNAllMales_out2Jo) <- NULL
colnames(Eggs_listperClutchGenEPYYNAllMales_out2Jo) <- c('ClutchGen', 'FGen','ClutchSize','EPYYN', 'nbEPY')


for (i in 1:nrow(Eggs_listperClutchGenEPYYNAllMales_out2Jo))
{
Eggs_listperClutchGenEPYYNAllMales_out2Jo$SocialMalePartner[i] <- unique(JohannesEggs$M_ID[!(is.na(JohannesEggs$F_ID)) & JohannesEggs$F_ID==Eggs_listperClutchGenEPYYNAllMales_out2Jo$FGen[i]])
}

Eggs_listperClutchGenEPYYNAllMales_out2Jo[Eggs_listperClutchGenEPYYNAllMales_out2Jo$SocialMalePartner ==11090,]
Eggs_listperClutchGenEPYYNAllMales_out2Jo[Eggs_listperClutchGenEPYYNAllMales_out2Jo$SocialMalePartner ==11011,]


TableClutchGenEPYYNAllMalesJo <- Eggs_listperClutchGenEPYYNAllMales_out2Jo

TableClutchGenEPYYNAllMalesJo$EPYYN <- as.numeric(as.character(TableClutchGenEPYYNAllMalesJo$EPYYN))
TableClutchGenEPYYNAllMalesJo$nbEPY <- as.numeric(as.character(TableClutchGenEPYYNAllMalesJo$nbEPY))
TableClutchGenEPYYNAllMalesJo$ClutchSize <- as.numeric(as.character(TableClutchGenEPYYNAllMalesJo$ClutchSize))

sum(TableClutchGenEPYYNAllMalesJo$EPYYN) # 13
sum(TableClutchGenEPYYNAllMalesJo$ClutchSize) # 261
sum(TableClutchGenEPYYNAllMalesJo$nbEPY)	# 29


{### add info on EPM

listEPYperClutchAssJo <- split(JohannesEggs[!is.na(JohannesEggs$EPY) & JohannesEggs$EPY == 1,c('ClutchAss','M_Gen')], JohannesEggs$ClutchAss[!is.na(JohannesEggs$EPY) & JohannesEggs$EPY == 1])
#  ClutchAss 59 2 eggs by EPM 11067 (first in list), one egg by EPM 11020

listEPYperClutchAss_funJo = function(x)  {
return (x$M_Gen[1])
}

listEPYperClutchAss_out1Jo <- lapply(listEPYperClutchAssJo, FUN=listEPYperClutchAss_funJo)
listEPYperClutchAss_out2Jo <- data.frame(rownames(do.call(rbind,listEPYperClutchAss_out1Jo)),do.call(rbind, listEPYperClutchAss_out1Jo))

nrow(listEPYperClutchAss_out2Jo)	# 12
rownames(listEPYperClutchAss_out2Jo) <- NULL
colnames(listEPYperClutchAss_out2Jo) <- c('ClutchAss', 'EPM')
listEPYperClutchAss_out2Jo$ClutchAss <- as.character(listEPYperClutchAss_out2Jo$ClutchAss)
listEPYperClutchAss_out2Jo <- listEPYperClutchAss_out2Jo[listEPYperClutchAss_out2Jo$ClutchAss!= '59',]



for (i in 1:nrow(TableClutchGenEPYYNAllMalesJo))
{
if (TableClutchGenEPYYNAllMalesJo$ClutchGen[i]%in%listEPYperClutchAss_out2Jo$ClutchAss & TableClutchGenEPYYNAllMalesJo$EPYYN[i] == 1)
{TableClutchGenEPYYNAllMalesJo$EPM[i] <- listEPYperClutchAss_out2Jo$EPM[listEPYperClutchAss_out2Jo$ClutchAss == TableClutchGenEPYYNAllMalesJo$ClutchGen[i]]}
else {TableClutchGenEPYYNAllMalesJo$EPM[i] <- NA}
}


for (i in 1:nrow(TableClutchGenEPYYNAllMalesJo)){
TableClutchGenEPYYNAllMalesJo$percEPY[i] <-TableClutchGenEPYYNAllMalesJo$nbEPY[i]/TableClutchGenEPYYNAllMalesJo$ClutchSize[i]
TableClutchGenEPYYNAllMalesJo$nbWPY[i] <-TableClutchGenEPYYNAllMalesJo$ClutchSize[i]-TableClutchGenEPYYNAllMalesJo$nbEPY[i]
}

}

{## add polystatus and Male and Female Fshort

for (i in 1:nrow(TableClutchGenEPYYNAllMalesJo))
{
TableClutchGenEPYYNAllMalesJo$Polystatus[i] <- as.character(JohannesMales$Polystatus[JohannesMales$Ind_ID == TableClutchGenEPYYNAllMalesJo$MID[i]])
TableClutchGenEPYYNAllMalesJo$Fshort[i] <- as.character(JohannesMales$Fshort[JohannesMales$Ind_ID == TableClutchGenEPYYNAllMalesJo$MID[i]])

TableClutchGenEPYYNAllMalesJo$FFshort[i] <- JohannesFemaleFshort$Fshort[JohannesFemaleFshort$Ind_ID == TableClutchGenEPYYNAllMalesJo$FGen[i]]
}
}

}


}

head(TableClutchAssFate0YNAllMalesJo)
head(TableClutchGenEPYYNAllMalesJo)

{### Table sperm traits per MID (pre + post 2012 + pre 2013) ; MIDYear (2012) ; pre 2012			# !! .txt !!

RawSpermTraitsJo <- read.table("JohannesSpermTraits.txt", header=T, sep='\t') 
head(RawSpermTraitsJo)

{# data sperm averaged per male year (pre 2012, post 2012)

List_SpermTraitPerMaleYearJo <- split(RawSpermTraitsJo[RawSpermTraitsJo$Year == 2012,], RawSpermTraitsJo$MID[RawSpermTraitsJo$Year == 2012])

List_SpermTraitPerMaleYear_funJo = function(x)  {
return (c(mean(x$logAbnormal, na.rm=T), mean(x$VCL0s,na.rm=T) , mean(x$nospermYN,na.rm=T),mean(x$Slength,na.rm=T) ))
}

List_SpermTraitPerMaleYear_out1Jo <- lapply(List_SpermTraitPerMaleYearJo, FUN=List_SpermTraitPerMaleYear_funJo)
List_SpermTraitPerMaleYear_out2Jo <- data.frame(rownames(do.call(rbind,List_SpermTraitPerMaleYear_out1Jo)),do.call(rbind, List_SpermTraitPerMaleYear_out1Jo))

nrow(List_SpermTraitPerMaleYear_out2Jo)	#36
rownames(List_SpermTraitPerMaleYear_out2Jo) <- NULL
colnames(List_SpermTraitPerMaleYear_out2Jo) <- c('MID', 'logAbnormal','VCL0s','nospermYN', 'Slength')

SpermTraitPerMaleYearJo <- List_SpermTraitPerMaleYear_out2Jo
}

{# data sperm averaged per male (pre 2012, post 2012, pre 2013)

List_SpermTraitPerMaleJo <- split(RawSpermTraitsJo, RawSpermTraitsJo$MID)

List_SpermTraitPerMale_funJo = function(x)  {
return (c(mean(x$logAbnormal, na.rm=T), mean(x$VCL0s,na.rm=T), mean(x$nospermYN,na.rm=T),nrow(x),mean(x$Slength,na.rm=T) ))
}

List_SpermTraitPerMale_out1Jo <- lapply(List_SpermTraitPerMaleJo, FUN=List_SpermTraitPerMale_funJo)
List_SpermTraitPerMale_out2Jo <- data.frame(rownames(do.call(rbind,List_SpermTraitPerMale_out1Jo)),do.call(rbind, List_SpermTraitPerMale_out1Jo))

nrow(List_SpermTraitPerMale_out2Jo)	#36
rownames(List_SpermTraitPerMale_out2Jo) <- NULL
colnames(List_SpermTraitPerMale_out2Jo) <- c('MID', 'logAbnormal','VCL0s','nospermYN','nbMeasures','Slength')

SpermTraitPerMaleJo <- List_SpermTraitPerMale_out2Jo


}

{# sperm trait pre breeding season 2012

for (i in 1:nrow(SpermTraitPerMaleJo))
{
SpermTraitPerMaleJo$pre2012VCL0s[i] <- RawSpermTraitsJo$VCL0s[RawSpermTraitsJo$MID == SpermTraitPerMaleJo$MID[i] & RawSpermTraitsJo$Year == 2012 & RawSpermTraitsJo$sampling == 'pre']

SpermTraitPerMaleJo$pre2012logAbnormal[i] <- RawSpermTraitsJo$logAbnormal[RawSpermTraitsJo$MID == SpermTraitPerMaleJo$MID[i] & RawSpermTraitsJo$Year == 2012 & RawSpermTraitsJo$sampling == 'pre']

SpermTraitPerMaleJo$pre2012nospermYN[i] <- RawSpermTraitsJo$nospermYN[RawSpermTraitsJo$MID == SpermTraitPerMaleJo$MID[i] & RawSpermTraitsJo$Year == 2012 & RawSpermTraitsJo$sampling == 'pre']

SpermTraitPerMaleJo$pre2012Slength[i] <- RawSpermTraitsJo$Slength[RawSpermTraitsJo$MID == SpermTraitPerMaleJo$MID[i] & RawSpermTraitsJo$Year == 2012 & RawSpermTraitsJo$sampling == 'pre']

}


}

}

head(SpermTraitPerMaleYearJo)
head(SpermTraitPerMaleJo)

{### Merge Sperm data to breeding data + Delta WP-EP

## ClutchIFYN
TableClutchAssFate0YNAllMalesJo <- merge(x=TableClutchAssFate0YNAllMalesJo, y=SpermTraitPerMaleYearJo, by.y = 'MID',by.x='SocialMalePartner', all.x=T)
TableClutchAssFate0YNAllMalesJo$Fshort <- as.numeric(TableClutchAssFate0YNAllMalesJo$Fshort)

{#nrow TableClutchAssFate0YNAllMalesJo
nrow(TableClutchAssFate0YNAllMalesJo)#76
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & TableClutchAssFate0YNAllMalesJo$IFYN == 1,])#31
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & !(is.na(TableClutchAssFate0YNAllMalesJo$logAbnormal)),])#75
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & !(is.na(TableClutchAssFate0YNAllMalesJo$logAbnormal))& TableClutchAssFate0YNAllMalesJo$IFYN == 1,])#31
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & !(is.na(TableClutchAssFate0YNAllMalesJo$VCL0s)),])#75
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & !(is.na(TableClutchAssFate0YNAllMalesJo$VCL0s))& TableClutchAssFate0YNAllMalesJo$IFYN == 1,])#31
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & !(is.na(TableClutchAssFate0YNAllMalesJo$Slength)),])#75
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & !(is.na(TableClutchAssFate0YNAllMalesJo$Slength))& TableClutchAssFate0YNAllMalesJo$IFYN == 1,])#31
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & !(is.na(TableClutchAssFate0YNAllMalesJo$nospermYN)),])#76
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) & !(is.na(TableClutchAssFate0YNAllMalesJo$nospermYN))& TableClutchAssFate0YNAllMalesJo$IFYN == 1,])#31
nrow(TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$IFYN)) &!(is.na(TableClutchAssFate0YNAllMalesJo$nospermYN)) & TableClutchAssFate0YNAllMalesJo$nospermYN == 1,]) #1
}

## ClutchEPYYN
TableClutchGenEPYYNAllMalesJo <- merge(x=TableClutchGenEPYYNAllMalesJo, y=SpermTraitPerMaleYearJo, by.y = 'MID',by.x='SocialMalePartner', all.x=T)
TableClutchGenEPYYNAllMalesJo <- merge(x=TableClutchGenEPYYNAllMalesJo, y=SpermTraitPerMaleYearJo, by.x = 'EPM', by.y = 'MID', all.x=T)

colnames(TableClutchGenEPYYNAllMalesJo) <- c('EPM','MID','ClutchGen','FGen','ClutchSize','EPYYN','nbEPY','percEPY','nbWPY', 'FFshort','MIDlogAbnormal','MIDVCL0s','MIDnospermYN','MIDSlength','EPMlogAbnormal','EPMVCL0s','EPMnospermYN','EPMSlength')

TableClutchGenEPYYNAllMalesJo <- merge(x=TableClutchGenEPYYNAllMalesJo, y = JohannesMales[,c('Ind_ID','Fshort')], all.x = TRUE, by.x = 'MID', by.y = 'Ind_ID')

{# nrow TableClutchGenEPYYNAllMalesJo
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)),])#70
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & TableClutchGenEPYYNAllMalesJo$EPYYN == 1,])#13
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & !(is.na(TableClutchGenEPYYNAllMalesJo$MIDlogAbnormal)),])#69
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & !(is.na(TableClutchGenEPYYNAllMalesJo$MIDlogAbnormal))& TableClutchGenEPYYNAllMalesJo$EPYYN == 1,])#12
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & !(is.na(TableClutchGenEPYYNAllMalesJo$MIDVCL0s)),])#69
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & !(is.na(TableClutchGenEPYYNAllMalesJo$MIDVCL0s))& TableClutchGenEPYYNAllMalesJo$EPYYN == 1,])#12
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & !(is.na(TableClutchGenEPYYNAllMalesJo$MIDSlength)),])#69
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & !(is.na(TableClutchGenEPYYNAllMalesJo$MIDSlength))& TableClutchGenEPYYNAllMalesJo$EPYYN == 1,])#12
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & !(is.na(TableClutchGenEPYYNAllMalesJo$MIDnospermYN)),])#70
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) & !(is.na(TableClutchGenEPYYNAllMalesJo$MIDnospermYN))& TableClutchGenEPYYNAllMalesJo$EPYYN == 1,])#13
nrow(TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$EPYYN)) &!(is.na(TableClutchGenEPYYNAllMalesJo$MIDnospermYN)) & TableClutchGenEPYYNAllMalesJo$MIDnospermYN == 1,] )#1
}


## Delta WP-EP
for (i in 1:nrow(TableClutchGenEPYYNAllMalesJo)){
TableClutchGenEPYYNAllMalesJo$DeltalogAbnormal[i] <-TableClutchGenEPYYNAllMalesJo$MIDlogAbnormal[i]-TableClutchGenEPYYNAllMalesJo$EPMlogAbnormal[i]
TableClutchGenEPYYNAllMalesJo$DeltaVCL0s[i] <-TableClutchGenEPYYNAllMalesJo$MIDVCL0s[i]-TableClutchGenEPYYNAllMalesJo$EPMVCL0s[i]
TableClutchGenEPYYNAllMalesJo$DeltaSlength[i] <-TableClutchGenEPYYNAllMalesJo$MIDSlength[i]-TableClutchGenEPYYNAllMalesJo$EPMSlength[i]

}


## JohannesMales male-year
JohannesMales <- merge(x=JohannesMales, y=SpermTraitPerMaleYearJo, by.x = 'Ind_ID', by.y = 'MID', all.x=T)

## Sperm Trait and attributes Per Male
SpermTraitPerMaleJo <- merge(x= SpermTraitPerMaleJo, 
							  y = JohannesMales[,c('Fshort','BeakColourScore', 'beakPC1inverted','SqrtSumAllDisplaySecRate','Ind_ID')], 
							  by.x = 'MID', by.y = 'Ind_ID', all.x= TRUE)


## add InbredYN for male and females in Clutches

 for (i in 1:nrow(TableClutchAssFate0YNAllMalesJo))
 {
 if (TableClutchAssFate0YNAllMalesJo$Fshort[i] == 0.25)
 {TableClutchAssFate0YNAllMalesJo$InbredYN[i] <- 1}
 else  {TableClutchAssFate0YNAllMalesJo$InbredYN[i] <- 0}
 
 if (TableClutchAssFate0YNAllMalesJo$FFshort[i] == 0.25)
 {TableClutchAssFate0YNAllMalesJo$FInbredYN[i] <- 1}
 else  {TableClutchAssFate0YNAllMalesJo$FInbredYN[i] <- 0}
 }
 
 for (i in 1:nrow(TableClutchGenEPYYNAllMalesJo))
 {
 if (TableClutchGenEPYYNAllMalesJo$Fshort[i] == 0.25)
 {TableClutchGenEPYYNAllMalesJo$InbredYN[i] <- 1}
 else  {TableClutchGenEPYYNAllMalesJo$InbredYN[i] <- 0}
 
 if (TableClutchGenEPYYNAllMalesJo$FFshort[i] == 0.25)
 {TableClutchGenEPYYNAllMalesJo$FInbredYN[i] <- 1}
 else  {TableClutchGenEPYYNAllMalesJo$FInbredYN[i] <- 0}
 }
 
 
## add InbredYN for spermtrait per male

 for (i in 1:nrow(SpermTraitPerMaleJo))
 {
 if (SpermTraitPerMaleJo$Fshort[i] == 0.25)
 {SpermTraitPerMaleJo$InbredYN[i] <- 1}
 else  {SpermTraitPerMaleJo$InbredYN[i] <- 0}
 }
 
							  
# sample sizes

nrow(JohannesMales[!(is.na(JohannesMales$logAbnormal)),])#33
nrow(JohannesMales[!(is.na(JohannesMales$VCL0s)),])#32
nrow(JohannesMales[!(is.na(JohannesMales$Slength)),])	#33					  
}

head(JohannesMales)
head(TableClutchAssFate0YNAllMalesJo)
head(TableClutchGenEPYYNAllMalesJo)
head(SpermTraitPerMaleJo)

{### get spare Johannes					    # !! .txt !! #

spareJohannes <- read.table('spareJohannesSpermTraits.txt', header=T, sep='\t')

JohannesMalesplusSpare <- rbind(spareJohannes, JohannesMales[,c('Ind_ID', 'nospermYN',  'Slength', 'VCL0s', 'logAbnormal', 'BeakColourScore', 'InbredYN')])
colnames(spareJohannes)[which(names(spareJohannes) == "Ind_ID")] <- "MID"
SpermTraitPerMaleJoplusSpare <- rbind(spareJohannes, SpermTraitPerMaleJo[,c('MID', 'nospermYN',  'Slength', 'VCL0s', 'logAbnormal', 'BeakColourScore', 'InbredYN')])

}

head(JohannesMalesplusSpare)
head(SpermTraitPerMaleJoplusSpare)






{##### add parents ID to all three replicates			## !!! .txt !!!


parentsID <- read.table('MaleSpermedParentsID.txt', header=T, sep='\t')

allmalesqualities <- merge(x= allmalesqualities, y = parentsID, by.x='Ind_ID', by.y='MID')
TableClutchAssFate0YNAllMales<- merge(x= TableClutchAssFate0YNAllMales, y = parentsID, by.x='SocialMalePartner', by.y='MID')
TableClutchGenEPYYNAllMales<- merge(x= TableClutchGenEPYYNAllMales, y = parentsID, by.x='SocialMalePartner', by.y='MID')
SpermTraitPerMale<- merge(x= SpermTraitPerMale, y = parentsID, by='MID')


JohannesMales<- merge(x= JohannesMales, y = parentsID, by.x='Ind_ID', by.y='MID')
JohannesMalesplusSpare<- merge(x= JohannesMalesplusSpare, y = parentsID, by.x='Ind_ID', by.y='MID')
TableClutchAssFate0YNAllMalesJo<- merge(x= TableClutchAssFate0YNAllMalesJo, y = parentsID, by.x='SocialMalePartner', by.y='MID')
TableClutchGenEPYYNAllMalesJo<- merge(x= TableClutchGenEPYYNAllMalesJo, y = parentsID, by.x='MID', by.y='MID')
SpermTraitPerMaleJo<- merge(x= SpermTraitPerMaleJo, y = parentsID, by.x='MID', by.y='MID')
SpermTraitPerMaleJoplusSpare<- merge(x= SpermTraitPerMaleJoplusSpare, y = parentsID, by.x='MID', by.y='MID')


sanjaMales <- merge(x= sanjaMales, y = parentsID, by='MID')
sanjaMalesplusExtra <- merge(x= sanjaMalesplusExtra, y = parentsID, by='MID')
sanjaClutches <- merge(x= sanjaClutches, y = parentsID, by='MID')
sanjaClutcheswithEPM <- merge(x= sanjaClutcheswithEPM, y = parentsID, by='MID')
}



{#### all 353 raw sperm data with 3 phenotypic traits			## !!! .txt !!!
raw353 <- read.table('353samples.txt', header=T, sep='\t')

{# select column courtship rate in all three data sets

CourtMalika <- allmalesqualities[,c('sqrtSumAllDisplaySecRate','IDYear')]

CourtJohannes <- JohannesMales[,c('SqrtSumAllDisplaySecRate','Ind_ID')]
colnames(CourtJohannes)[which(names(CourtJohannes) == "SqrtSumAllDisplaySecRate")] <- "sqrtSumAllDisplaySecRate"
CourtJohannes$IDYear <- paste(CourtJohannes$Ind_ID,'2012',sep='')
CourtJohannes <- CourtJohannes[,c('sqrtSumAllDisplaySecRate','IDYear')]

CourtSanja <- sanjaMales[,c('sqrtSumAllDisplaySecRate','MID')]
CourtSanja$IDYear <- paste(CourtSanja$MID,'2011',sep='')
CourtSanja <- CourtSanja[,c('sqrtSumAllDisplaySecRate','IDYear')]

CourtAll3 <- rbind(CourtJohannes,CourtMalika,CourtSanja)

}

raw353 <- merge(x=raw353, y=CourtAll3, by.x='MIDYear',by.y='IDYear', all.x=TRUE)


# Exp == 1 -> Johannes + Spare
# Exp == 2 -> Malika
# Exp == 3 -> Sanja + Extra domesticated

SpermTraitPerMaleJo <- merge(x=SpermTraitPerMaleJo, y =unique(raw353[,c('MID','Tarsus')]), by = 'MID', all.x=TRUE)
sanjaMales <- merge(x=sanjaMales, y =unique(raw353[,c('MID','Tarsus')]), by = 'MID', all.x=TRUE)
SpermTraitPerMaleJoplusSpare <- merge(x=SpermTraitPerMaleJoplusSpare, y =unique(raw353[,c('MID','Tarsus')]), by = 'MID', all.x=TRUE)
sanjaMalesplusExtra <- merge(x=sanjaMalesplusExtra, y =unique(raw353[,c('MID','Tarsus')]), by = 'MID', all.x=TRUE)
SpermTraitPerMale <- merge(x=SpermTraitPerMale, y =unique(raw353[,c('MID','Tarsus')]), by = 'MID', all.x=TRUE)


{# descriptive values
# domesticated
length(unique(sanjaMalesplusExtra$MID[sanjaMalesplusExtra$InbredYN==0])) #25 outbred
length(unique(sanjaMalesplusExtra$parentsID[sanjaMalesplusExtra$InbredYN==0])) # from 16 family
length(unique(sanjaMalesplusExtra$MID[sanjaMalesplusExtra$InbredYN==1])) #16 outbred
length(unique(sanjaMalesplusExtra$parentsID[sanjaMalesplusExtra$InbredYN==1])) # from 11 family

# wild (in/out)
length(unique(SpermTraitPerMaleJoplusSpare$MID[SpermTraitPerMaleJoplusSpare$InbredYN==0])) #20 outbred
length(unique(SpermTraitPerMaleJoplusSpare$parentsID[SpermTraitPerMaleJoplusSpare$InbredYN==0])) # from 14 family
length(unique(SpermTraitPerMaleJoplusSpare$MID[SpermTraitPerMaleJoplusSpare$InbredYN==1])) #23 outbred
length(unique(SpermTraitPerMaleJoplusSpare$parentsID[SpermTraitPerMaleJoplusSpare$InbredYN==1])) # from 7 family

{# descriptive values from raw353 with courtship rate
#domesticated - watched all day
min(raw353$sqrtSumAllDisplaySecRate[raw353$Exp == 3], na.rm=T)^2
max(raw353$sqrtSumAllDisplaySecRate[raw353$Exp == 3], na.rm=T)^2
mean(raw353$sqrtSumAllDisplaySecRate[raw353$Exp == 3], na.rm=T)^2
median(raw353$sqrtSumAllDisplaySecRate[raw353$Exp == 3], na.rm=T)^2

# wild - watched for the first hour of the day
min(raw353$sqrtSumAllDisplaySecRate[raw353$Exp == 1 | raw353$Exp == 2], na.rm=T)^2
max(raw353$sqrtSumAllDisplaySecRate[raw353$Exp == 1 | raw353$Exp == 2], na.rm=T)^2
mean(raw353$sqrtSumAllDisplaySecRate[raw353$Exp == 1 | raw353$Exp == 2], na.rm=T)^2
median(raw353$sqrtSumAllDisplaySecRate[raw353$Exp == 1 | raw353$Exp == 2], na.rm=T)^2
}

}

}

head(raw353)
head(SpermTraitPerMaleJoplusSpare)
head(sanjaMalesplusExtra)
head(SpermTraitPerMale)
head(sanjaMales)
head(SpermTraitPerMaleJo)



	##################################################
	## 	  Models on Sperm traits - Breeding data    ##			
	##################################################

require(lme4)
require(arm)	
require(rmeta)

#############################
##### Malika's data set #####
#############################

head(TableClutchAssFate0YNAllMales)

{### sperm traits ~ IF

{## Abnormal sperm
# full model: MTrt and FassTrt largely aliased, control for all sources of pseudoreplication, both hypothesis: MTrt change his physiology, FassTrt change her motivation to copulate
nrow(TableClutchAssFate0YNAllMales[TableClutchAssFate0YNAllMales$FassTrt != TableClutchAssFate0YNAllMales$MTrt,])	# 8
	
# for meta
modAbnormalSpermIF3bisscaled <- glmer (IFYN ~ scale(logAbnormal) + scale(Year) + scale(ClutchSize) + scale(numFassTrt) +(1|MIDYear), 
family = 'binomial', data = TableClutchAssFate0YNAllMales)
summary(modAbnormalSpermIF3bisscaled)
estimatesMalikaIFAbn <- coef(summary(modAbnormalSpermIF3bisscaled))
NMalikaIFAbn <- nobs(modAbnormalSpermIF3bisscaled)

}

{## Velocity
# full model: MTrt and FassTrt largely aliased, control for all sources of pseudoreplication, both hypothesis: MTrt change his physiology, FassTrt change her motivation to copulate

# for meta
modVelocitySpermIF3bisscaled <- glmer (IFYN ~ scale(VCL0s) + scale(Year) + scale(ClutchSize) + scale(numFassTrt) +(1|MIDYear), 
family = 'binomial', data = TableClutchAssFate0YNAllMales)
summary(modVelocitySpermIF3bisscaled)
estimatesMalikaIFVelocity <- coef(summary(modVelocitySpermIF3bisscaled))
NMalikaIFVelocity <- nobs(modVelocitySpermIF3bisscaled)

}

{## Slength

# for meta
modSlengthSpermIF3bisscaled <- glmer (IFYN ~ scale(Slength) + scale(Year) + scale(ClutchSize) + scale(numFassTrt) +(1|MIDYear), 
family = 'binomial', data = TableClutchAssFate0YNAllMales)
summary(modSlengthSpermIF3bisscaled)
estimatesMalikaIFSlength <- coef(summary(modSlengthSpermIF3bisscaled))
NMalikaIFSlength <- nobs(modSlengthSpermIF3bisscaled)

# poly
modSlengthSpermIFpoly <- glmer (IFYN ~ poly(Slength,2) + scale(Year) + scale(ClutchSize) + scale(numFassTrt) +(1|MIDYear), 
family = 'binomial', data = TableClutchAssFate0YNAllMales)
summary(modSlengthSpermIFpoly)
estimatesMalikaIFSlengthPoly <- coef(summary(modSlengthSpermIFpoly))


}


}


head(TableClutchGenEPYYNAllMales)

{### sperm traits ~ EPP (paternity loss)

{## Abnormal sperm
# full model: MTrt and FGenTrt largely aliased, control for all sources of pseudoreplication, both hypothesis: MTrt change his physiology, FGenTrt change her motivation to engage in EP copulation

	
# for meta
modAbnormalSpermEPP3bisscaled <- glmer (EPYYN ~ scale(MIDlogAbnormal) + scale(Year) + scale(ClutchSize) + scale(numFGenTrt) +(1|MIDYear), 
family = 'binomial', data = TableClutchGenEPYYNAllMales)
summary(modAbnormalSpermEPP3bisscaled)
estimatesMalikaEPPAbn <- coef(summary(modAbnormalSpermEPP3bisscaled))
NMalikaEPPAbn <- nobs(modAbnormalSpermEPP3bisscaled)

	# TableClutchGenEPYYNAllMales[order(TableClutchGenEPYYNAllMales$SocialMalePartner,TableClutchGenEPYYNAllMales$MIDYear),c('SocialMalePartner','MIDYear', 'MIDFID')]	
	## MIDFID != MIDYear only for polygynous guys (11037 and 11190)

	
}

{## Velocity
# full model

#for meta
modVCL0EPP3bisscaled <- glmer (EPYYN ~ scale(MIDVCL0s) + scale(Year) + scale(ClutchSize) + scale(numFGenTrt) +(1|MIDYear), 
family = 'binomial', data = TableClutchGenEPYYNAllMales)
summary(modVCL0EPP3bisscaled)	# 239.7546  scale(MIDVCL0s)                   -0.3287     0.4716  -0.697    0.486 
estimatesMalikaEPPVelocity <- coef(summary(modVCL0EPP3bisscaled))
NMalikaEPPVelocity <- nobs(modVCL0EPP3bisscaled)

}

{## Slength

#for meta
modSlengthEPP3bisscaled <- glmer (EPYYN ~ scale(MIDSlength) + scale(Year) + scale(ClutchSize) + scale(numFGenTrt) +(1|MIDYear), 
family = 'binomial', data = TableClutchGenEPYYNAllMales)
summary(modSlengthEPP3bisscaled)
estimatesMalikaEPPSlength <- coef(summary(modSlengthEPP3bisscaled))
NMalikaEPPSlength <- nobs(modSlengthEPP3bisscaled)

# poly
modSlengthEPPPoly <- glmer (EPYYN ~ poly(MIDSlength,2) + scale(Year) + scale(ClutchSize) + scale(numFGenTrt) +(1|MIDYear), 
family = 'binomial', data = TableClutchGenEPYYNAllMales)
summary(modSlengthEPPPoly)
estimatesMalikaEPPSlengthPoly <- coef(summary(modSlengthEPPPoly))


}
}


head(allmalesqualities)

{### sperm traits ~ RelsiringSucc
# in this data set: PercPresent is always 100

{# Abnormal sperm

# for meta
modAbnormalSpermRelsiringSuccscaled <- lmer (scale(RelsiringSucc) ~ scale(logAbnormal) + scale(Season) + scale(PercPaired) + scale(numMTrt) + (1|Ind_ID) + (1|PartnerID) + (1|MIDFID), 
data = allmalesqualities)
summary(modAbnormalSpermRelsiringSuccscaled)	
estimatesMalikaSiringSuccAbn <- coef(summary(modAbnormalSpermRelsiringSuccscaled))

}

{# Velocity

# for meta
modVelocitySpermRelsiringSuccscaled <- lmer (scale(RelsiringSucc) ~ scale(VCL0s) + scale(Season) + scale(PercPaired) + scale(numMTrt) + (1|Ind_ID) + (1|PartnerID) + (1|MIDFID), 
data = allmalesqualities)
summary(modVelocitySpermRelsiringSuccscaled)	
estimatesMalikaSiringSuccVelocity <- coef(summary(modVelocitySpermRelsiringSuccscaled))

}

{# Slength
# for meta
modSlengthSpermRelsiringSuccscaled <- lmer (scale(RelsiringSucc) ~ scale(Slength) + scale(Season) + scale(PercPaired) + scale(numMTrt) + (1|Ind_ID) + (1|PartnerID) + (1|MIDFID), 
data = allmalesqualities)
summary(modSlengthSpermRelsiringSuccscaled)	
estimatesMalikaSiringSuccSlength <- coef(summary(modSlengthSpermRelsiringSuccscaled))

# poly
modSlengthRelsiringSuccPoly <- lmer (scale(RelsiringSucc) ~ poly(Slength,2) + scale(Season) + scale(PercPaired) + scale(numMTrt) + (1|Ind_ID) + (1|PartnerID) + (1|MIDFID), 
data = allmalesqualities)
summary(modSlengthRelsiringSuccPoly)	
estimatesMalikaSiringSuccSlengthPoly <- coef(summary(modSlengthRelsiringSuccPoly))

}

NMalikaSiringSucc<- nobs(modSlengthSpermRelsiringSuccscaled)
}


head(TableClutchGenEPYYNAllMales)

{### sperm traits WPM-EPM ~ %EPY

{# Abnormal sperm
plot(TableClutchGenEPYYNAllMales$DeltalogAbnormal~TableClutchGenEPYYNAllMales$percEPY)
hist(TableClutchGenEPYYNAllMales$percEPY[!(is.na(TableClutchGenEPYYNAllMales$DeltalogAbnormal))])
	
# for meta	!!! remove NA
modDeltaEPWPAbnscaled <-glmer(cbind(nbEPY,nbWPY)~scale(DeltalogAbnormal) + scale(numFGenTrt)+scale(ClutchSize) + (1|MIDFID) + (1|EPM)+(1|SocialMalePartner)+(1|FGen) ,
data= TableClutchGenEPYYNAllMales[!(is.na(TableClutchGenEPYYNAllMales$DeltalogAbnormal)),], family = "binomial")
summary(modDeltaEPWPAbnscaled)
estimatesMalikaDeltaAbn <- coef(summary(modDeltaEPWPAbnscaled))

}

{# Velocity
plot(TableClutchGenEPYYNAllMales$DeltaVCL0s~TableClutchGenEPYYNAllMales$percEPY)
hist(TableClutchGenEPYYNAllMales$percEPY[!(is.na(TableClutchGenEPYYNAllMales$DeltaVCL0s))])

# for meta	! remove NA
modDeltaEPWPVCLscaled <-glmer(cbind(nbEPY,nbWPY)~scale(DeltaVCL0s) + scale(numFGenTrt)+scale(ClutchSize) + (1|MIDFID) + (1|EPM)+(1|SocialMalePartner)+(1|FGen) ,
data= TableClutchGenEPYYNAllMales[!(is.na(TableClutchGenEPYYNAllMales$DeltaVCL0s)),], family = "binomial")
summary(modDeltaEPWPVCLscaled)
estimatesMalikaDeltaVelocity <- coef(summary(modDeltaEPWPVCLscaled))

}

{# Slength

# for meta	! remove NA
modDeltaEPWPSlengthscaled <-glmer(cbind(nbEPY,nbWPY)~scale(DeltaSlength) + scale(numFGenTrt)+scale(ClutchSize) + (1|MIDFID) + (1|EPM)+(1|SocialMalePartner)+(1|FGen) ,
data= TableClutchGenEPYYNAllMales[!(is.na(TableClutchGenEPYYNAllMales$DeltaSlength)),], family = "binomial")
summary(modDeltaEPWPSlengthscaled)
estimatesMalikaDeltaSlength <- coef(summary(modDeltaEPWPSlengthscaled))


}

}



{### sperm traits ~ beak color 

head(raw353)

{# Abnormal sperm	!! remove NAs !!
modMalikaBeakAbn <- lmer(scale(logAbnormal)~scale(BeakColourScore) + Session + (1|MID)+(1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$logAbnormal)),])
summary(modMalikaBeakAbn)
estimatesMalikaBeakAbn <- coef(summary(modMalikaBeakAbn))
NMalikaBeakAbn <- nobs(modMalikaBeakAbn)
NMalesMalikaBeakAbn <- data.frame(ngrps (modMalikaBeakAbn))['MID',]

}

{# Velocity
modMalikaBeakVCL <- lmer(scale(VCL0s)~scale(BeakColourScore) + Session + (1|MID)+(1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$VCL0s)),])
summary(modMalikaBeakVCL)
estimatesMalikaBeakVCL <- coef(summary(modMalikaBeakVCL))
NMalikaBeakVCL <- nobs(modMalikaBeakVCL)
NMalesMalikaBeakVCL <- data.frame(ngrps (modMalikaBeakVCL))['MID',]

}

{# Slength
modMalikaBeakSlength <- lmer(scale(Slength)~scale(BeakColourScore) + Session + (1|MID)+(1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$Slength)),])
summary(modMalikaBeakSlength)
estimatesMalikaBeakSlength <- coef(summary(modMalikaBeakSlength))
NMalikaBeakSlength <- nobs(modMalikaBeakSlength)
NMalesMalikaBeakSlength <- data.frame(ngrps (modMalikaBeakSlength))['MID',]

}

}

{### sperm traits ~ Tarsus

head(raw353)

{# Abnormal sperm	!! remove NAs !!
modMalikaTarsusAbn <- lmer(scale(logAbnormal)~scale(Tarsus) + Session + (1|MID)+(1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)),])
summary(modMalikaTarsusAbn)
estimatesMalikaTarsusAbn <- coef(summary(modMalikaTarsusAbn))
NMalikaTarsusAbn <- nobs(modMalikaTarsusAbn)
NMalesMalikaTarsusAbn <- data.frame(ngrps (modMalikaTarsusAbn))['MID',]

}

{# Velocity
modMalikaTarsusVCL <- lmer(scale(VCL0s)~scale(Tarsus) + Session + (1|MID)+(1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)),])
summary(modMalikaTarsusVCL)
estimatesMalikaTarsusVCL <- coef(summary(modMalikaTarsusVCL))
NMalikaTarsusVCL <- nobs(modMalikaTarsusVCL)
NMalesMalikaTarsusVCL <- data.frame(ngrps (modMalikaTarsusVCL))['MID',]
}

{# Slength
modMalikaTarsusSlength <- lmer(scale(Slength)~scale(Tarsus) + Session + (1|MID)+(1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)),])
summary(modMalikaTarsusSlength)
estimatesMalikaTarsusSlength <- coef(summary(modMalikaTarsusSlength))
NMalikaTarsusSlength <- nobs(modMalikaTarsusSlength)
NMalesMalikaTarsusSlength <- data.frame(ngrps (modMalikaTarsusSlength))['MID',]
}

}

{### sperm traits ~ Courtship rate (display sec)
# courtship rate 2012 indexed to first two sperm measurements (pre and post 2012 ), for 2013 respectively.

{# Abnormal sperm

# for meta
modAbnormalSpermCourtshipRatescaled <- lmer (scale(logAbnormal) ~ scale(sqrtSumAllDisplaySecRate) + Session + (1|MID) + (1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$logAbnormal)),])
summary(modAbnormalSpermCourtshipRatescaled)
estimatesMalikaDisplayAbn <- coef(summary(modAbnormalSpermCourtshipRatescaled))
NMalikaDisplayAbn <- nobs(modAbnormalSpermCourtshipRatescaled)
NMalesMalikaDisplayAbn <- data.frame(ngrps (modAbnormalSpermCourtshipRatescaled))['MID',]
}

{# Velocity

# for meta
modVelocitySpermCourtshipRatescaled <- lmer (scale(VCL0s) ~ scale(sqrtSumAllDisplaySecRate) + Session + (1|MID) + (1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$VCL0s)),])
summary(modVelocitySpermCourtshipRatescaled)
estimatesMalikaDisplayVelocity <- coef(summary(modVelocitySpermCourtshipRatescaled))
NMalikaDisplayVelocity <- nobs(modVelocitySpermCourtshipRatescaled)
NMalesMalikaDisplayVelocity <- data.frame(ngrps (modVelocitySpermCourtshipRatescaled))['MID',]

}

{# Slength
# for meta
modSlengthSpermCourtshipRatescaled <- lmer (scale(Slength) ~ scale(sqrtSumAllDisplaySecRate) + Session + (1|MID) + (1|parentsID), 
data = raw353[raw353$Exp == 2 & !(is.na(raw353$Slength)),])
summary(modSlengthSpermCourtshipRatescaled)
estimatesMalikaDisplaySlength <- coef(summary(modSlengthSpermCourtshipRatescaled))
NMalikaDisplaySlength <- nobs(modSlengthSpermCourtshipRatescaled)
NMalesMalikaDisplaySlength <- data.frame(ngrps (modSlengthSpermCourtshipRatescaled))['MID',]

}

}




############################
##### Sanja's data set #####		
############################

head(sanjaClutches)
head(sanjaMales)

{### sperm traits ~ IF

{## abnormal sperm

# for meta	   FF in/out ! remove NA
modsanjaAbnormalSpermIF3bisscaled <- glmer (IFYN ~ scale(logAbnormal) +  scale(clutchsizeforIF) + scale(FInbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$logAbnormal)),])
summary(modsanjaAbnormalSpermIF3bisscaled)
estimatesSanjaIFAbn <-coef(summary(modsanjaAbnormalSpermIF3bisscaled))
NSanjaIFAbn <- nobs(modsanjaAbnormalSpermIF3bisscaled)


# for meta + F    FF in/out	 ! remove NA
modsanjaAbnormalSpermIF3bisscaledF <- glmer (IFYN ~ scale(logAbnormal) + scale(InbredYN)+ scale(clutchsizeforIF) + scale(FInbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$logAbnormal)),])
summary(modsanjaAbnormalSpermIF3bisscaledF)	
estimatesSanjaIFAbnF <-coef(summary(modsanjaAbnormalSpermIF3bisscaledF))	

}

{## Velocity

# for meta		FF inout! remove NA
modsanjaVelocitySpermIF3bisscaled <- glmer (IFYN ~ scale(VCL0s) + scale(clutchsizeforIF) + scale(FInbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$VCL0s)),])
summary(modsanjaVelocitySpermIF3bisscaled)
estimatesSanjaIFVelocity <- coef(summary(modsanjaVelocitySpermIF3bisscaled))
NSanjaIFVelocity <- nobs(modsanjaVelocitySpermIF3bisscaled)

# for meta + F and FF in/out			! overwrite
modsanjaVelocitySpermIF3bisscaledF <- glmer (IFYN ~ scale(VCL0s) + scale(InbredYN)+ scale(clutchsizeforIF) + scale(FInbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$VCL0s)),])
summary(modsanjaVelocitySpermIF3bisscaledF)
estimatesSanjaIFVelocityF <- coef(summary(modsanjaVelocitySpermIF3bisscaledF))

}

{## Slength

# for meta		! remove NA
modsanjaSlengthSpermIF3bisscaled <- glmer (IFYN ~ scale(Slength) + scale(clutchsizeforIF) + scale(FInbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$Slength)),])
summary(modsanjaSlengthSpermIF3bisscaled)
estimatesSanjaIFSlength <- coef(summary(modsanjaSlengthSpermIF3bisscaled))
NSanjaIFSlength <- nobs(modsanjaSlengthSpermIF3bisscaled)

# for meta + F 	! remove NA
modsanjaSlengthSpermIF3bisscaledF <- glmer (IFYN ~ scale(Slength) + scale(InbredYN)+ scale(clutchsizeforIF) + scale(FInbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$Slength)),])
summary(modsanjaSlengthSpermIF3bisscaledF)
estimatesSanjaIFSlengthF <- coef(summary(modsanjaSlengthSpermIF3bisscaledF))

# poly
modsanjaSlengthSpermIFPoly <- glmer (IFYN ~ poly(Slength,2)+ scale(InbredYN) + scale(clutchsizeforIF) + scale(FInbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$Slength)),])
summary(modsanjaSlengthSpermIFPoly)
estimatesSanjaIFSlengthFPoly <- coef(summary(modsanjaSlengthSpermIFPoly))

}
}


{### sperm traits ~ EPP (paternity loss)

{## Abnormal sperm

# for meta	! remove NA
modsanjaAbnormalSpermEPP3bisscaled <- glmer (EPPYN ~ scale(logAbnormal) + scale(clutchsizeforEPP) +(1|MID) , 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$logAbnormal)),])
summary(modsanjaAbnormalSpermEPP3bisscaled)	
estimatesSanjaEPPAbn <- coef(summary(modsanjaAbnormalSpermEPP3bisscaled))
NSanjaEPPAbn <- nobs(modsanjaAbnormalSpermEPP3bisscaled)

# for meta	+ F ! remove NA
modsanjaAbnormalSpermEPP3bisscaledF <- glmer (EPPYN ~ scale(logAbnormal) +scale(InbredYN)+ scale(clutchsizeforEPP) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$logAbnormal)),])
summary(modsanjaAbnormalSpermEPP3bisscaledF)	
estimatesSanjaEPPAbnF <- coef(summary(modsanjaAbnormalSpermEPP3bisscaledF))

}

{## Velocity

# for meta	! remove NA
modSanjaVCL0EPP3bisscaled <- glmer (EPPYN ~ scale(VCL0s) + scale(clutchsizeforEPP) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$VCL0s)),])
summary(modSanjaVCL0EPP3bisscaled)
estimatesSanjaEPPVelocity <- coef(summary(modSanjaVCL0EPP3bisscaled))
NSanjaEPPVelocity <- nobs(modSanjaVCL0EPP3bisscaled)

# for meta + F	! remove NA
modSanjaVCL0EPP3bisscaledF <- glmer (EPPYN ~ scale(VCL0s) + scale(clutchsizeforEPP) +scale(InbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$VCL0s)),])
summary(modSanjaVCL0EPP3bisscaledF)
estimatesSanjaEPPVelocityF <- coef(summary(modSanjaVCL0EPP3bisscaledF))

}

{## Slength

# for meta	! remove NA
modSanjaSlengthEPP3bisscaled <- glmer (EPPYN ~ scale(Slength) + scale(clutchsizeforEPP) + (1|MID),
 family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$Slength)),])
summary(modSanjaSlengthEPP3bisscaled)	
estimatesSanjaEPPSlength <- coef(summary(modSanjaSlengthEPP3bisscaled))
NSanjaEPPSlength <- nobs(modSanjaSlengthEPP3bisscaled)

# for meta + F	! remove NA
modSanjaSlengthEPP3bisscaledF <- glmer (EPPYN ~ scale(Slength) + scale(clutchsizeforEPP) +scale(InbredYN) +(1|MID), 
family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$Slength)),])
summary(modSanjaSlengthEPP3bisscaledF)	
estimatesSanjaEPPSlengthF <- coef(summary(modSanjaSlengthEPP3bisscaledF))

# poly
modSanjaSlengthEPP3poly <- glmer (EPPYN ~ poly(Slength,2)+scale(InbredYN) + scale(clutchsizeforEPP) +(1|MID),
 family = 'binomial', data = sanjaClutches[!(is.na(sanjaClutches$Slength)),])
summary(modSanjaSlengthEPP3poly)
estimatesSanjaEPPSlengthFPoly <- coef(summary(modSanjaSlengthEPP3poly))

}

}


{### sperm traits ~ RelsiringSucc	
# in this data set: PercPresent is NOT always 100 but put it in gives NA (not enough variation ?)

{# Abnormal sperm	

# for meta		!! remove line NA !!
modSanjaAbnormalSpermRelsiringSuccscaled <- lm (scale(RelsiringSucc) ~ scale(logAbnormal) + scale(PercPaired) , 
data = sanjaMales[!(is.na(sanjaMales$logAbnormal)),])
summary(modSanjaAbnormalSpermRelsiringSuccscaled)
estimatesSanjaSiringSuccAbn <- coef(summary(modSanjaAbnormalSpermRelsiringSuccscaled))
NSanjaSiringSuccAbn <- nobs(modSanjaAbnormalSpermRelsiringSuccscaled)

# for meta	+ F	!! remove line NA !!
modSanjaAbnormalSpermRelsiringSuccscaledF <- lm (scale(RelsiringSucc) ~ scale(logAbnormal) +scale(InbredYN)+ scale(PercPaired), 
data = sanjaMales[!(is.na(sanjaMales$logAbnormal)),])
summary(modSanjaAbnormalSpermRelsiringSuccscaledF)
estimatesSanjaSiringSuccAbnF <- coef(summary(modSanjaAbnormalSpermRelsiringSuccscaledF))

}

{# Velocity 

# for meta		!! remove line NA !!
modsanjaVelocitySpermRelsiringSuccscaled <- lm(scale(RelsiringSucc) ~ scale(VCL0s) + scale(PercPaired) , 
data = sanjaMales[!(is.na(sanjaMales$VCL0s)),])
summary(modsanjaVelocitySpermRelsiringSuccscaled) 
estimatesSanjaSiringSuccVelocity <- coef(summary(modsanjaVelocitySpermRelsiringSuccscaled))
NSanjaSiringSuccVelocity <- nobs(modsanjaVelocitySpermRelsiringSuccscaled)


# for meta	+ F	!! remove line NA !!
modsanjaVelocitySpermRelsiringSuccscaledF <- lm(scale(RelsiringSucc) ~ scale(VCL0s) +scale(InbredYN) + scale(PercPaired) , 
data = sanjaMales[!(is.na(sanjaMales$VCL0s)),])
summary(modsanjaVelocitySpermRelsiringSuccscaledF)	
estimatesSanjaSiringSuccVelocityF <- coef(summary(modsanjaVelocitySpermRelsiringSuccscaledF))

}

{# Slength

# for meta		!! remove line NA !!
modsanjaSlengthSpermRelsiringSuccscaled <- lm(scale(RelsiringSucc) ~ scale(Slength) + scale(PercPaired) , 
data = sanjaMales[!(is.na(sanjaMales$Slength)),])
summary(modsanjaSlengthSpermRelsiringSuccscaled)	 
estimatesSanjaSiringSuccSlength <- coef(summary(modsanjaSlengthSpermRelsiringSuccscaled))
NSanjaSiringSuccSlength <- nobs(modsanjaSlengthSpermRelsiringSuccscaled)

# for meta	+ F	!! remove line NA !!
modsanjaSlengthSpermRelsiringSuccscaledF <- lm(scale(RelsiringSucc) ~ scale(Slength) +scale(InbredYN) + scale(PercPaired) , 
data = sanjaMales[!(is.na(sanjaMales$Slength)),])
summary(modsanjaSlengthSpermRelsiringSuccscaledF)	
estimatesSanjaSiringSuccSlengthF <- coef(summary(modsanjaSlengthSpermRelsiringSuccscaledF))

# poly
modsanjaSlengthRelsiringSuccFPoly <- lm(scale(RelsiringSucc) ~ poly(Slength,2) +scale(InbredYN)+ scale(PercPaired), 
data = sanjaMales[!(is.na(sanjaMales$Slength)),])
summary(modsanjaSlengthRelsiringSuccFPoly)
estimatesSanjaSiringSuccSlengthFPoly <- coef(summary(modsanjaSlengthRelsiringSuccFPoly))

}

}

sanjaClutcheswithEPM

{### sperm traits WPM-EPM ~ %EPY

sanjaClutcheswithEPM[!(is.na(sanjaClutcheswithEPM$DeltalogAbnormal)),] # no variation in percEPY !!

sanjaClutcheswithEPM[!(is.na(sanjaClutcheswithEPM$DeltaVCL0s)),] # almost no variation in percEPY !!

sanjaClutcheswithEPM[!(is.na(sanjaClutcheswithEPM$DeltaSlength)),] # almost no variation in percEPY !!

}



{### sperm traits ~ beak color		> munsel taken at d100 ; include Extra domesticated

head(raw353)

{# Abnormal sperm
# for meta
modSanjaBeakMunselAbn <- lmer(scale(logAbnormal)~scale(BeakColourScore)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)),])
summary(modSanjaBeakMunselAbn)
estimatesSanjaBeakMunselAbn <- coef(summary(modSanjaBeakMunselAbn))
NSanjaBeakMunselAbn <-nobs(modSanjaBeakMunselAbn)

# for meta + F ! remove NA !
modSanjaBeakMunselAbnF <- lmer(scale(logAbnormal)~scale(BeakColourScore)+scale(InbredYN)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)),])
summary(modSanjaBeakMunselAbnF)
estimatesSanjaBeakMunselAbnF <- coef(summary(modSanjaBeakMunselAbnF))


}

{# Velocity
# for meta
modSanjaBeakMunselVCL <- lmer(scale(VCL0s)~scale(BeakColourScore)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)),])
summary(modSanjaBeakMunselVCL)
estimatesSanjaBeakMunselVCL <- coef(summary(modSanjaBeakMunselVCL))
NSanjaBeakMunselVelocity <-nobs(modSanjaBeakMunselVCL)

# for meta + F ! remove NA !
modSanjaBeakMunselVCLF <- lmer(scale(VCL0s)~scale(BeakColourScore)+scale(InbredYN)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)),])
summary(modSanjaBeakMunselVCLF)
estimatesSanjaBeakMunselVCLF <- coef(summary(modSanjaBeakMunselVCLF))



}

{# Slength
# for meta
modSanjaBeakMunselSlength <- lmer(scale(Slength)~scale(BeakColourScore)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)),])
summary(modSanjaBeakMunselSlength)
estimatesSanjaBeakMunselSlength <- coef(summary(modSanjaBeakMunselSlength))
NSanjaBeakMunselSlength <-nobs(modSanjaBeakMunselSlength)

# for meta + F ! remove NA !
modSanjaBeakMunselSlengthF <- lmer(scale(Slength)~scale(BeakColourScore)+scale(InbredYN)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)),])
summary(modSanjaBeakMunselSlengthF)
estimatesSanjaBeakMunselSlengthF <- coef(summary(modSanjaBeakMunselSlengthF))

}

}

{### sperm traits ~ Tarsus

head(raw353)

{# Abnormal sperm
# for meta
modSanjaTarsusAbn <- lmer(scale(logAbnormal)~scale(Tarsus)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)),])
summary(modSanjaTarsusAbn)
estimatesSanjaTarsusAbn <- coef(summary(modSanjaTarsusAbn))
NSanjaTarsusAbn <-nobs(modSanjaTarsusAbn)

# for meta + F ! remove NA !
modSanjaTarsusAbnF <- lmer(scale(logAbnormal)~scale(Tarsus)+scale(InbredYN)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)),])
summary(modSanjaTarsusAbnF)
estimatesSanjaTarsusAbnF <- coef(summary(modSanjaTarsusAbnF))


}

{# Velocity
# for meta
modSanjaTarsusVCL <- lmer(scale(VCL0s)~scale(Tarsus)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)),])
summary(modSanjaTarsusVCL)
estimatesSanjaTarsusVCL <- coef(summary(modSanjaTarsusVCL))
NSanjaTarsusVelocity <-nobs(modSanjaTarsusVCL)

# for meta + F ! remove NA !
modSanjaTarsusVCLF <- lmer(scale(VCL0s)~scale(Tarsus)+scale(InbredYN)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)),])
summary(modSanjaTarsusVCLF)
estimatesSanjaTarsusVCLF <- coef(summary(modSanjaTarsusVCLF))

}

{# Slength
# for meta
modSanjaTarsusSlength <- lmer(scale(Slength)~scale(Tarsus)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)),])
summary(modSanjaTarsusSlength)
estimatesSanjaTarsusSlength <- coef(summary(modSanjaTarsusSlength))
NSanjaTarsusSlength <-nobs(modSanjaTarsusSlength)

# for meta + F ! remove NA !
modSanjaTarsusSlengthF <- lmer(scale(Slength)~scale(Tarsus)+scale(InbredYN)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)),])
summary(modSanjaTarsusSlengthF)
estimatesSanjaTarsusSlengthF <- coef(summary(modSanjaTarsusSlengthF))

}

}

{### sperm traits ~ Courtship rate (display sec)

head(raw353)

{# Abnormal sperm

# for meta	!! remove NA
modSanjaAbnormalSpermCourtshipRatescaled <- lmer (scale(logAbnormal) ~ scale(sqrtSumAllDisplaySecRate) +(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)),])
summary(modSanjaAbnormalSpermCourtshipRatescaled)
estimatesSanjaDisplayAbn <- coef(summary(modSanjaAbnormalSpermCourtshipRatescaled))
NSanjaDisplayAbn <-nobs(modSanjaAbnormalSpermCourtshipRatescaled)


# for meta + F	!! remove NA
modSanjaAbnormalSpermCourtshipRatescaledF <- lmer (scale(logAbnormal) ~ scale(sqrtSumAllDisplaySecRate) +scale(InbredYN)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)),])
summary(modSanjaAbnormalSpermCourtshipRatescaledF)
estimatesSanjaDisplayAbnF <- coef(summary(modSanjaAbnormalSpermCourtshipRatescaledF))

}

{# Velocity	

# for meta 	!! remove NA
modsanjaVelocitySpermCourtshipRatescaled <- lmer (scale(VCL0s) ~ scale(sqrtSumAllDisplaySecRate) +(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)),])
summary(modsanjaVelocitySpermCourtshipRatescaled)
estimatesSanjaDisplayVelocity <- coef(summary(modsanjaVelocitySpermCourtshipRatescaled))
NSanjaDisplayVelocity <-nobs(modsanjaVelocitySpermCourtshipRatescaled)

# for meta 	+ F !! remove NA
modsanjaVelocitySpermCourtshipRatescaledF <- lmer (scale(VCL0s) ~ scale(sqrtSumAllDisplaySecRate)+ scale(InbredYN)+(1|parentsID) , 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)),])
summary(modsanjaVelocitySpermCourtshipRatescaledF)
estimatesSanjaDisplayVelocityF <- coef(summary(modsanjaVelocitySpermCourtshipRatescaledF))

}

{# Slength

# for meta 	!! remove NA
modsanjaSlengthSpermCourtshipRatescaled <- lmer (scale(Slength) ~ scale(sqrtSumAllDisplaySecRate)+(1|parentsID) , 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)),])
summary(modsanjaSlengthSpermCourtshipRatescaled)
estimatesSanjaDisplaySlength <- coef(summary(modsanjaSlengthSpermCourtshipRatescaled))
NSanjaDisplaySlength <- nobs(modsanjaSlengthSpermCourtshipRatescaled)

# for meta 	+ F !! remove NA
modsanjaSlengthSpermCourtshipRatescaledF <- lmer (scale(Slength) ~ scale(sqrtSumAllDisplaySecRate) +scale(InbredYN)+(1|parentsID), 
data= raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)),])
summary(modsanjaSlengthSpermCourtshipRatescaledF)
estimatesSanjaDisplaySlengthF <- coef(summary(modsanjaSlengthSpermCourtshipRatescaledF))

}
}




##############################
##### Johannes' data set #####
##############################

head(TableClutchAssFate0YNAllMalesJo)

{### sperm traits ~ IF

{## abnormal sperm

# for meta 	! remove NA
modJohannesAbnormalSpermIFscaled <- glmer (IFYN ~ scale(logAbnormal)  + scale(ClutchSize) + scale(FInbredYN) + (1|SocialMalePartner), 
family = 'binomial', data = TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$logAbnormal)),])
summary(modJohannesAbnormalSpermIFscaled)	
estimatesJohannesIFAbn <- coef(summary(modJohannesAbnormalSpermIFscaled))
NJohannesIFAbn <- nobs(modJohannesAbnormalSpermIFscaled)

# for meta + F	! remove NA
modJohannesAbnormalSpermIFscaledF <- glmer (IFYN ~ scale(logAbnormal) + scale(InbredYN) + scale(ClutchSize) + scale(FInbredYN) + (1|SocialMalePartner),
family = 'binomial', data = TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$logAbnormal)),])
summary(modJohannesAbnormalSpermIFscaledF)	
estimatesJohannesIFAbnF <- coef(summary(modJohannesAbnormalSpermIFscaledF))

}

{## Velocity

# for meta 	! remove NA
modJohannesVelocitySpermIF3bisscaled <- glmer (IFYN ~ scale(VCL0s) + scale(ClutchSize) + scale(FInbredYN) +(1|SocialMalePartner) , 
family = 'binomial', data = TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$VCL0s)),])
summary(modJohannesVelocitySpermIF3bisscaled)
estimatesJohannesIFVelocity <- coef(summary(modJohannesVelocitySpermIF3bisscaled))
NJohannesIFVelocity <- nobs(modJohannesVelocitySpermIF3bisscaled)

# for meta + F 	! remove NA
modJohannesVelocitySpermIF3bisscaledF <- glmer (IFYN ~ scale(VCL0s)+ scale(InbredYN) + scale(ClutchSize) + scale(FInbredYN) +(1|SocialMalePartner),
family = 'binomial', data = TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$VCL0s)),])
summary(modJohannesVelocitySpermIF3bisscaledF)
estimatesJohannesIFVelocityF <- coef(summary(modJohannesVelocitySpermIF3bisscaledF))

}

{## Slength

# for meta 	! remove NA
modJohannesSlengthSpermIF3bisscaled <- glmer (IFYN ~ scale(Slength) + scale(ClutchSize) + scale(FInbredYN) +(1|SocialMalePartner), 
family = 'binomial', data = TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$Slength)),])
summary(modJohannesSlengthSpermIF3bisscaled)
estimatesJohannesIFSlength <- coef(summary(modJohannesSlengthSpermIF3bisscaled))
NJohannesIFSlength <- nobs(modJohannesSlengthSpermIF3bisscaled)


# for meta + F 	! remove NA
modJohannesSlengthSpermIF3bisscaledF <- glmer (IFYN ~ scale(Slength)+ scale(InbredYN) + scale(ClutchSize) + scale(FInbredYN) +(1|SocialMalePartner) ,
family = 'binomial', data = TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$Slength)),])
summary(modJohannesSlengthSpermIF3bisscaledF)
estimatesJohannesIFSlengthF <- coef(summary(modJohannesSlengthSpermIF3bisscaledF))

# poly
modJohannesSlengthSpermIFPoly <- glmer (IFYN ~ poly(Slength,2) +scale(InbredYN)+ scale(ClutchSize) + scale(FInbredYN) +(1|SocialMalePartner) , 
family = 'binomial', data = TableClutchAssFate0YNAllMalesJo[!(is.na(TableClutchAssFate0YNAllMalesJo$Slength)),])
summary(modJohannesSlengthSpermIFPoly)
estimatesJohannesIFSlengthFPoly <- coef(summary(modJohannesSlengthSpermIFPoly))

}

}


head(TableClutchGenEPYYNAllMalesJo)

{### sperm traits ~ EPP (paternity loss)

{## Abnormal sperm
	
# for meta	! remove NA
modsJohannesAbnormalSpermEPP3bisscaled <- glmer (EPYYN ~ scale(MIDlogAbnormal) + scale(ClutchSize) + (1|MID), 
family = 'binomial', data = TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$MIDlogAbnormal)),])
summary(modsJohannesAbnormalSpermEPP3bisscaled)	
estimatesJohannesEPPAbn <- coef(summary(modsJohannesAbnormalSpermEPP3bisscaled)	)
NJohannesEPPAbn <- nobs(modsJohannesAbnormalSpermEPP3bisscaled)


# for meta	+ F ! remove NA
modsJohannesAbnormalSpermEPP3bisscaledF <- glmer (EPYYN ~ scale(MIDlogAbnormal)+ scale(InbredYN) + scale(ClutchSize) +(1|MID), 
family = 'binomial', data = TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$MIDlogAbnormal)),])
summary(modsJohannesAbnormalSpermEPP3bisscaledF)	
estimatesJohannesEPPAbnF <- coef(summary(modsJohannesAbnormalSpermEPP3bisscaledF))


}

{## Velocity

# for meta 	! remove NA
modJohannesVCL0EPP3bisscaled <- glmer (EPYYN ~ scale(MIDVCL0s) + scale(ClutchSize) +(1|MID), 
family = 'binomial', data = TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$MIDVCL0s)),])
summary(modJohannesVCL0EPP3bisscaled)	
estimatesJohannesEPPVelocity <- coef(summary(modJohannesVCL0EPP3bisscaled)	)
NJohannesEPPVelocity <- nobs(modJohannesVCL0EPP3bisscaled)

# for meta  + F	! remove NA
modJohannesVCL0EPP3bisscaledF <- glmer (EPYYN ~ scale(MIDVCL0s) +scale(InbredYN)+ scale(ClutchSize) + (1|MID), 
family = 'binomial', data = TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$MIDVCL0s)),])
summary(modJohannesVCL0EPP3bisscaledF)	
estimatesJohannesEPPVelocityF <- coef(summary(modJohannesVCL0EPP3bisscaledF)	)


}

{## Slength

# for meta 	! remove NA
modJohannesSlengthEPP3bisscaled <- glmer (EPYYN ~ scale(MIDSlength) + scale(ClutchSize) + (1|MID) , 
family = 'binomial', data = TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$MIDSlength)),])
summary(modJohannesSlengthEPP3bisscaled)	
estimatesJohannesEPPSlength <- coef(summary(modJohannesSlengthEPP3bisscaled)	)
NJohannesEPPSlength <- nobs(modJohannesSlengthEPP3bisscaled)

# for meta  + F	! remove NA
modJohannesVCL0EPP3bisscaledF <- glmer (EPYYN ~ scale(MIDSlength) +scale(InbredYN)+ scale(ClutchSize)  +(1|MID), 
family = 'binomial', data = TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$MIDSlength)),])
summary(modJohannesVCL0EPP3bisscaledF)	
estimatesJohannesEPPSlengthF <- coef(summary(modJohannesVCL0EPP3bisscaledF)	)

# poly
modJohannesSlengthEPPPoly <- glmer (EPYYN ~ poly(MIDSlength,2) +scale(InbredYN)+ scale(ClutchSize)  +(1|MID) , 
family = 'binomial', data = TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$MIDSlength)),])
summary(modJohannesSlengthEPPPoly)
estimatesJohannesEPPSlengthFPoly <- coef(summary(modJohannesSlengthEPPPoly)	)
}
}


head(JohannesMales)

{### sperm traits ~ RelsiringSucc
# in this data set: PercPresent is NOT always 100 but put it in gives NA (not enough variation ?)

{# Abnormal sperm 

# for meta 		!! remove line NA !!
modJohannesAbnormalSpermRelsiringSuccscaled <- lm (scale(RelsiringSucc) ~ scale(logAbnormal) + scale(PercPaired), 
data = JohannesMales[!(is.na(JohannesMales$logAbnormal)),])
summary(modJohannesAbnormalSpermRelsiringSuccscaled)
estimatesJohannesSiringSuccAbn <- coef(summary(modJohannesAbnormalSpermRelsiringSuccscaled))
NJohannesSiringSuccAbn <- nobs(modJohannesAbnormalSpermRelsiringSuccscaled)

# for meta 	+ F	!! remove line NA !!
modJohannesAbnormalSpermRelsiringSuccscaledF <- lm (scale(RelsiringSucc) ~ scale(logAbnormal) +scale(InbredYN)+ scale(PercPaired), 
data = JohannesMales[!(is.na(JohannesMales$logAbnormal)),])
summary(modJohannesAbnormalSpermRelsiringSuccscaledF)	
estimatesJohannesSiringSuccAbnF <- coef(summary(modJohannesAbnormalSpermRelsiringSuccscaledF))

}

{# Velocity 

# for meta 		!! remove line NA !!
modJohannesVelocitySpermRelsiringSuccscaled <- lm(scale(RelsiringSucc) ~ scale(VCL0s) + scale(PercPaired), 
data = JohannesMales[!(is.na(JohannesMales$VCL0s)),])
summary(modJohannesVelocitySpermRelsiringSuccscaled)
estimatesJohannesSiringSuccVelocity <- coef(summary(modJohannesVelocitySpermRelsiringSuccscaled))
NJohannesSiringSuccVelocity <- nobs(modJohannesVelocitySpermRelsiringSuccscaled)

# for meta 	+ F	!! remove line NA !!
modJohannesVelocitySpermRelsiringSuccscaledF <- lm(scale(RelsiringSucc) ~ scale(VCL0s) + scale(InbredYN) + scale(PercPaired), 
data = JohannesMales[!(is.na(JohannesMales$VCL0s)),])
summary(modJohannesVelocitySpermRelsiringSuccscaledF)
estimatesJohannesSiringSuccVelocityF <- coef(summary(modJohannesVelocitySpermRelsiringSuccscaledF))

}

{# Slength

# for meta 		!! remove line NA !!
modJohannesSlengthSpermRelsiringSuccscaled <- lm(scale(RelsiringSucc) ~ scale(Slength) + scale(PercPaired)  , 
data = JohannesMales[!(is.na(JohannesMales$Slength)),])
summary(modJohannesSlengthSpermRelsiringSuccscaled)
estimatesJohannesSiringSuccSlength <- coef(summary(modJohannesSlengthSpermRelsiringSuccscaled))
NJohannesSiringSuccSlength <- nobs(modJohannesSlengthSpermRelsiringSuccscaled)

# for meta 	+ F	!! remove line NA !!
modJohannesSlengthSpermRelsiringSuccscaledF <- lm(scale(RelsiringSucc) ~ scale(Slength) + scale(InbredYN) + scale(PercPaired)  , 
data = JohannesMales[!(is.na(JohannesMales$Slength)),])
summary(modJohannesSlengthSpermRelsiringSuccscaledF)
estimatesJohannesSiringSuccSlengthF <- coef(summary(modJohannesSlengthSpermRelsiringSuccscaledF))

# poly
modJohannesSlengthRelsiringSuccPoly <- lm(scale(RelsiringSucc) ~ poly(Slength,2)+ scale(InbredYN) + scale(PercPaired)  , 
data = JohannesMales[!(is.na(JohannesMales$Slength)),])
summary(modJohannesSlengthRelsiringSuccPoly)
estimatesJohannesSiringSuccSlengthFPoly <- coef(summary(modJohannesSlengthRelsiringSuccPoly))

}

}


head(TableClutchGenEPYYNAllMalesJo,12)

{### sperm traits WPM-EPM ~ %EPY

{# Abnormal sperm

plot(TableClutchGenEPYYNAllMalesJo$DeltalogAbnormal~TableClutchGenEPYYNAllMalesJo$percEPY)
hist(TableClutchGenEPYYNAllMalesJo$percEPY[!(is.na(TableClutchGenEPYYNAllMalesJo$DeltalogAbnormal))])

# for meta		!! remove NA
modJoDeltaAbn <- glmer(cbind(nbEPY,nbWPY)~scale(DeltalogAbnormal) + scale(ClutchSize) + (1|MID) + (1|EPM),
data= TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$DeltalogAbnormal)),], family = "binomial")
summary(modJoDeltaAbn)
estimatesJohannesDeltaAbn <- coef(summary(modJoDeltaAbn))

}

{# Velocity
plot(TableClutchGenEPYYNAllMalesJo$DeltaVCL0s~TableClutchGenEPYYNAllMalesJo$percEPY)
hist(TableClutchGenEPYYNAllMalesJo$percEPY[!(is.na(TableClutchGenEPYYNAllMalesJo$DeltaVCL0s))])

# for meta		!! remove NA
modJohannesDeltaVelocity <- glmer(cbind(nbEPY,nbWPY)~scale(DeltaVCL0s) + scale(ClutchSize) + (1|MID) + (1|EPM),
data= TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$DeltaVCL0s)),], family = "binomial")
summary(modJohannesDeltaVelocity)
estimatesJohannesDeltaVelocity <- coef(summary(modJohannesDeltaVelocity))


}

{# Slength

# for meta		!! remove NA						### !!! doesn't work in 3.1.3
modJohannesDeltaSlength <- glmer(cbind(nbEPY,nbWPY)~scale(DeltaSlength) + scale(ClutchSize) + (1|MID) + (1|EPM),
data= TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$DeltaSlength)),], family = "binomial")
summary(modJohannesDeltaSlength)
estimatesJohannesDeltaSlength <- coef(summary(modJohannesDeltaSlength))


modJohannesDeltaSlengthGLM <- glm(cbind(nbEPY,nbWPY)~scale(DeltaSlength) + scale(ClutchSize),
data= TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$DeltaSlength)),], family = "binomial")
summary(modJohannesDeltaSlengthGLM)


plot (TableClutchGenEPYYNAllMalesJo$DeltaSlength,TableClutchGenEPYYNAllMalesJo$percEPY)
abline(h=0.5)
abline(v=0)
}

}




{### sperm traits ~ beak color		> munsel taken before breeding 2012 + Spare Johannes birds

{# Abnormal sperm

# for meta		!! remove NA !!
modJohannesBeakMunselAbn <- lmer(scale(logAbnormal)~scale(BeakColourScore) + (1|MID) + (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)),])
summary(modJohannesBeakMunselAbn)
estimatesJohannesBeakMunselAbn <- coef(summary(modJohannesBeakMunselAbn))
NJohannesBeakMunselAbn <- nobs(modJohannesBeakMunselAbn)
NMalesJohannesBeakMunselAbn <- data.frame(ngrps (modJohannesBeakMunselAbn))['MID',]


# for meta	+ F	!! remove NA !!
modJohannesBeakMunselAbnF <- lmer(scale(logAbnormal)~scale(BeakColourScore) + scale(InbredYN) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)),])
summary(modJohannesBeakMunselAbnF)
estimatesJohannesBeakMunselAbnF <- coef(summary(modJohannesBeakMunselAbnF))

}

{# Velocity

# for meta		!! remove NA !!
modJohannesBeakMunselVCL <- lmer(scale(VCL0s)~scale(BeakColourScore)  + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)),])
summary(modJohannesBeakMunselVCL)
estimatesJohannesBeakMunselVCL <- coef(summary(modJohannesBeakMunselVCL))
NJohannesBeakMunselVCL <- nobs(modJohannesBeakMunselVCL)
NMalesJohannesBeakMunselVCL <- data.frame(ngrps (modJohannesBeakMunselVCL))['MID',]


# for meta	+ F	!! remove NA !!
modJohannesBeakMunselVCLF <- lmer(scale(VCL0s)~scale(BeakColourScore) + scale(InbredYN)+ (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)),])
summary(modJohannesBeakMunselVCLF)
estimatesJohannesBeakMunselVCLF <- coef(summary(modJohannesBeakMunselVCLF))

}

{# Slength

# for meta		!! remove NA !!
modJohannesBeakMunselSlength <- lmer(scale(Slength)~scale(BeakColourScore) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)),])
summary(modJohannesBeakMunselSlength)
estimatesJohannesBeakMunselSlength <- coef(summary(modJohannesBeakMunselSlength))
NJohannesBeakMunselSlength <- nobs(modJohannesBeakMunselSlength)
NMalesJohannesBeakMunselSlength <- data.frame(ngrps (modJohannesBeakMunselSlength))['MID',]


# for meta	+ F	!! remove NA !!
modJohannesBeakMunselSlengthF <- lmer(scale(Slength)~scale(BeakColourScore) + scale(InbredYN)+ (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)),])
summary(modJohannesBeakMunselSlengthF)
estimatesJohannesBeakMunselSlengthF <- coef(summary(modJohannesBeakMunselSlengthF))

}
}

{### sperm traits ~ Tarsus

{# Abnormal sperm

# for meta		!! remove NA !!
modJohannesTarsusAbn <- lmer(scale(logAbnormal)~scale(Tarsus) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)),])
summary(modJohannesTarsusAbn)
estimatesJohannesTarsusAbn <- coef(summary(modJohannesTarsusAbn))
NJohannesTarsusAbn <- nobs(modJohannesTarsusAbn)
NMalesJohannesTarsusAbn <- data.frame(ngrps (modJohannesTarsusAbn))['MID',]


# for meta	+ F	!! remove NA !!
modJohannesTarsusAbnF <- lmer(scale(logAbnormal)~scale(Tarsus) + scale(InbredYN)+ (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)),])
summary(modJohannesTarsusAbnF)
estimatesJohannesTarsusAbnF <- coef(summary(modJohannesTarsusAbnF))

}

{# Velocity

# for meta		!! remove NA !!
modJohannesTarsusVCL <- lmer(scale(VCL0s)~scale(Tarsus) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)),])
summary(modJohannesTarsusVCL)
estimatesJohannesTarsusVCL <- coef(summary(modJohannesTarsusVCL))
NJohannesTarsusVCL <- nobs(modJohannesTarsusVCL)
NMalesJohannesTarsusVCL <- data.frame(ngrps (modJohannesTarsusVCL))['MID',]


# for meta	+ F	!! remove NA !!
modJohannesTarsusVCLF <- lmer(scale(VCL0s)~scale(Tarsus) + scale(InbredYN)+ (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)),])
summary(modJohannesTarsusVCLF)
estimatesJohannesTarsusVCLF <- coef(summary(modJohannesTarsusVCLF))

}

{# Slength

# for meta		!! remove NA !!
modJohannesTarsusSlength <- lmer(scale(Slength)~scale(Tarsus) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)),])
summary(modJohannesTarsusSlength)
estimatesJohannesTarsusSlength <- coef(summary(modJohannesTarsusSlength))
NJohannesTarsusSlength <- nobs(modJohannesTarsusSlength)
NMalesJohannesTarsusSlength <- data.frame(ngrps (modJohannesTarsusSlength))['MID',]


# for meta	+ F	!! remove NA !!
modJohannesTarsusSlengthF <- lmer(scale(Slength)~scale(Tarsus) + scale(InbredYN)+ (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)),])
summary(modJohannesTarsusSlengthF)
estimatesJohannesTarsusSlengthF <- coef(summary(modJohannesTarsusSlengthF))

}
}

{### sperm traits ~ Courtship rate (display sec)
# take the first two measurements of sperm (i.e. per MIDYear like in Malika)

{# Abnormal sperm

# for meta	!! remove NA
modJohannesAbnormalSpermCourtshipRatescaled <- lmer (scale(logAbnormal) ~ scale(sqrtSumAllDisplaySecRate) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$Year == 2012,])
summary(modJohannesAbnormalSpermCourtshipRatescaled)
estimatesJohannesDisplayAbn <- coef(summary(modJohannesAbnormalSpermCourtshipRatescaled))
NJohannesDisplayAbn <- nobs(modJohannesAbnormalSpermCourtshipRatescaled)
NMalesJohannesDisplayAbn <- data.frame(ngrps (modJohannesAbnormalSpermCourtshipRatescaled))['MID',]


# for meta	+ F !! remove NA
modJohannesAbnormalSpermCourtshipRatescaledF <- lmer (scale(logAbnormal) ~ scale(sqrtSumAllDisplaySecRate)+scale(InbredYN) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$Year == 2012,])
summary(modJohannesAbnormalSpermCourtshipRatescaledF)
estimatesJohannesDisplayAbnF <- coef(summary(modJohannesAbnormalSpermCourtshipRatescaledF))

}

{# Velocity

# for meta	!! remove NA
modJohannesVelocitySpermCourtshipRatescaled <- lmer (scale(VCL0s) ~ scale(sqrtSumAllDisplaySecRate) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$Year == 2012,])
summary(modJohannesVelocitySpermCourtshipRatescaled)
estimatesJohannesDisplayVelocity <- coef(summary(modJohannesVelocitySpermCourtshipRatescaled))
NJohannesDisplayVelocity <- nobs(modJohannesVelocitySpermCourtshipRatescaled)
NMalesJohannesDisplayVelocity <- data.frame(ngrps (modJohannesVelocitySpermCourtshipRatescaled))['MID',]

# for meta	+ F!! remove NA
modJohannesVelocitySpermCourtshipRatescaledF <- lmer (scale(VCL0s) ~ scale(sqrtSumAllDisplaySecRate) + scale(InbredYN) + (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$Year == 2012,])
summary(modJohannesVelocitySpermCourtshipRatescaledF)
estimatesJohannesDisplayVelocityF <- coef(summary(modJohannesVelocitySpermCourtshipRatescaledF))


}

{# Slength

# for meta	!! remove NA
modJohannesSlengthSpermCourtshipRatescaled <- lmer (scale(Slength) ~ scale(sqrtSumAllDisplaySecRate)+ (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$Year == 2012,])
summary(modJohannesSlengthSpermCourtshipRatescaled)
estimatesJohannesDisplaySlength <- coef(summary(modJohannesSlengthSpermCourtshipRatescaled))
NJohannesDisplaySlength <- nobs(modJohannesSlengthSpermCourtshipRatescaled)
NMalesJohannesDisplaySlength <- data.frame(ngrps (modJohannesSlengthSpermCourtshipRatescaled))['MID',]

# for meta	+ F !! remove NA
modJohannesSlengthSpermCourtshipRatescaledF <- lmer (scale(Slength) ~ scale(sqrtSumAllDisplaySecRate)+ scale(InbredYN)+ (1|MID)+ (1|parentsID), 
data= raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$Year == 2012,])
summary(modJohannesSlengthSpermCourtshipRatescaledF)
estimatesJohannesDisplaySlengthF <- coef(summary(modJohannesSlengthSpermCourtshipRatescaledF))


}

}










	######################################################
	#### Meta-analysis over 3 data sets, per questions ###
	######################################################

require(rmeta)

{#### phenotypes

{### without InbredYN controlled for in Johannes and Sanja datasets - meta.summaries

{## Beak color Munsel - sperm traits per male

{## metaBeakColorMunsel - Abnormal
metaBeakColorMunselAbn <- data.frame('study' = c('Sanja', 'Johannes'))

metaBeakColorMunselAbn$est[metaBeakColorMunselAbn$study == 'Sanja'] <- estimatesSanjaBeakMunselAbn[2,1]
metaBeakColorMunselAbn$SE[metaBeakColorMunselAbn$study == 'Sanja'] <- estimatesSanjaBeakMunselAbn[2,2]
metaBeakColorMunselAbn$lower[metaBeakColorMunselAbn$study == 'Sanja'] <- estimatesSanjaBeakMunselAbn[2,1]-1.96*estimatesSanjaBeakMunselAbn[2,2]
metaBeakColorMunselAbn$upper[metaBeakColorMunselAbn$study == 'Sanja'] <- estimatesSanjaBeakMunselAbn[2,1]+1.96*estimatesSanjaBeakMunselAbn[2,2]


metaBeakColorMunselAbn$est[metaBeakColorMunselAbn$study == 'Johannes'] <- estimatesJohannesBeakMunselAbn[2,1]
metaBeakColorMunselAbn$SE[metaBeakColorMunselAbn$study == 'Johannes'] <- estimatesJohannesBeakMunselAbn[2,2]
metaBeakColorMunselAbn$lower[metaBeakColorMunselAbn$study == 'Johannes'] <- estimatesJohannesBeakMunselAbn[2,1]-1.96*estimatesJohannesBeakMunselAbn[2,2]
metaBeakColorMunselAbn$upper[metaBeakColorMunselAbn$study == 'Johannes'] <- estimatesJohannesBeakMunselAbn[2,1]+1.96*estimatesJohannesBeakMunselAbn[2,2]

summarymetaBeakColorMunselAbn <- meta.summaries(metaBeakColorMunselAbn$est, metaBeakColorMunselAbn$SE,names=metaBeakColorMunselAbn$study, method="fixed")

rBeakAbn <- summarymetaBeakColorMunselAbn$summary
lowerBeakAbn <- summarymetaBeakColorMunselAbn$summary+1.96*summarymetaBeakColorMunselAbn$se
upperBeakAbn <- summarymetaBeakColorMunselAbn$summary-1.96*summarymetaBeakColorMunselAbn$se

PvalueBeakAbn <- 2* pnorm(-abs(summarymetaBeakColorMunselAbn$summary/summarymetaBeakColorMunselAbn$se))

}

{## metaBeakColorMunsel - Velocity
metaBeakColorMunselVCL <- data.frame('study' = c('Sanja', 'Johannes'))

metaBeakColorMunselVCL$est[metaBeakColorMunselVCL$study == 'Sanja'] <- estimatesSanjaBeakMunselVCL[2,1]
metaBeakColorMunselVCL$SE[metaBeakColorMunselVCL$study == 'Sanja'] <- estimatesSanjaBeakMunselVCL[2,2]
metaBeakColorMunselVCL$lower[metaBeakColorMunselVCL$study == 'Sanja'] <- estimatesSanjaBeakMunselVCL[2,1]-1.96*estimatesSanjaBeakMunselVCL[2,2]
metaBeakColorMunselVCL$upper[metaBeakColorMunselVCL$study == 'Sanja'] <- estimatesSanjaBeakMunselVCL[2,1]+1.96*estimatesSanjaBeakMunselVCL[2,2]


metaBeakColorMunselVCL$est[metaBeakColorMunselVCL$study == 'Johannes'] <- estimatesJohannesBeakMunselVCL[2,1]
metaBeakColorMunselVCL$SE[metaBeakColorMunselVCL$study == 'Johannes'] <- estimatesJohannesBeakMunselVCL[2,2]
metaBeakColorMunselVCL$lower[metaBeakColorMunselVCL$study == 'Johannes'] <- estimatesJohannesBeakMunselVCL[2,1]-1.96*estimatesJohannesBeakMunselVCL[2,2]
metaBeakColorMunselVCL$upper[metaBeakColorMunselVCL$study == 'Johannes'] <- estimatesJohannesBeakMunselVCL[2,1]+1.96*estimatesJohannesBeakMunselVCL[2,2]

summarymetaBeakColorMunselVCL <- meta.summaries(metaBeakColorMunselVCL$est, metaBeakColorMunselVCL$SE, names=metaBeakColorMunselVCL$study, method="fixed")

rBeakVCL <- summarymetaBeakColorMunselVCL$summary
lowerBeakVCL <- summarymetaBeakColorMunselVCL$summary+1.96*summarymetaBeakColorMunselVCL$se
upperBeakVCL <- summarymetaBeakColorMunselVCL$summary-1.96*summarymetaBeakColorMunselVCL$se

PvalueBeakVCL <- 2* pnorm(-abs(summarymetaBeakColorMunselVCL$summary/summarymetaBeakColorMunselVCL$se))

}

{## metaBeakColorMunsel - Slength 
metaBeakColorMunselSlength <- data.frame('study' = c( 'Sanja', 'Johannes'))

metaBeakColorMunselSlength$est[metaBeakColorMunselSlength$study == 'Sanja'] <- estimatesSanjaBeakMunselSlength[2,1]
metaBeakColorMunselSlength$SE[metaBeakColorMunselSlength$study == 'Sanja'] <- estimatesSanjaBeakMunselSlength[2,2]
metaBeakColorMunselSlength$lower[metaBeakColorMunselSlength$study == 'Sanja'] <- estimatesSanjaBeakMunselSlength[2,1]-1.96*estimatesSanjaBeakMunselSlength[2,2]
metaBeakColorMunselSlength$upper[metaBeakColorMunselSlength$study == 'Sanja'] <- estimatesSanjaBeakMunselSlength[2,1]+1.96*estimatesSanjaBeakMunselSlength[2,2]


metaBeakColorMunselSlength$est[metaBeakColorMunselSlength$study == 'Johannes'] <- estimatesJohannesBeakMunselSlength[2,1]
metaBeakColorMunselSlength$SE[metaBeakColorMunselSlength$study == 'Johannes'] <- estimatesJohannesBeakMunselSlength[2,2]
metaBeakColorMunselSlength$lower[metaBeakColorMunselSlength$study == 'Johannes'] <- estimatesJohannesBeakMunselSlength[2,1]-1.96*estimatesJohannesBeakMunselSlength[2,2]
metaBeakColorMunselSlength$upper[metaBeakColorMunselSlength$study == 'Johannes'] <- estimatesJohannesBeakMunselSlength[2,1]+1.96*estimatesJohannesBeakMunselSlength[2,2]

summarymetaBeakColorMunselSlength <- meta.summaries(metaBeakColorMunselSlength$est, metaBeakColorMunselSlength$SE, names=metaBeakColorMunselSlength$study, method="fixed")

rBeakSlength <- summarymetaBeakColorMunselSlength$summary
lowerBeakSlength <- summarymetaBeakColorMunselSlength$summary+1.96*summarymetaBeakColorMunselSlength$se
upperBeakSlength <- summarymetaBeakColorMunselSlength$summary-1.96*summarymetaBeakColorMunselSlength$se

PvalueBeakSlength  <- 2* pnorm(-abs(summarymetaBeakColorMunselSlength $summary/summarymetaBeakColorMunselSlength$se))
}

}

{## Courtship rate - sperm traits per male-year

{## metaDisplay - Abnormal 
metaDisplayAbn <- data.frame('study' = c('Sanja', 'Johannes'))

metaDisplayAbn$est[metaDisplayAbn$study == 'Sanja'] <- estimatesSanjaDisplayAbn[2,1]
metaDisplayAbn$SE[metaDisplayAbn$study == 'Sanja'] <- estimatesSanjaDisplayAbn[2,2]
metaDisplayAbn$lower[metaDisplayAbn$study == 'Sanja'] <- estimatesSanjaDisplayAbn[2,1]-1.96*estimatesSanjaDisplayAbn[2,2]
metaDisplayAbn$upper[metaDisplayAbn$study == 'Sanja'] <- estimatesSanjaDisplayAbn[2,1]+1.96*estimatesSanjaDisplayAbn[2,2]


metaDisplayAbn$est[metaDisplayAbn$study == 'Johannes'] <- estimatesJohannesDisplayAbn[2,1]
metaDisplayAbn$SE[metaDisplayAbn$study == 'Johannes'] <- estimatesJohannesDisplayAbn[2,2]
metaDisplayAbn$lower[metaDisplayAbn$study == 'Johannes'] <- estimatesJohannesDisplayAbn[2,1]-1.96*estimatesJohannesDisplayAbn[2,2]
metaDisplayAbn$upper[metaDisplayAbn$study == 'Johannes'] <- estimatesJohannesDisplayAbn[2,1]+1.96*estimatesJohannesDisplayAbn[2,2]


summarymetaDisplayAbn <-  meta.summaries(metaDisplayAbn$est, metaDisplayAbn$SE, names=metaDisplayAbn$study, method="fixed")

rDisplayAbn <- summarymetaDisplayAbn$summary
lowerDisplayAbn <- summarymetaDisplayAbn$summary+1.96*summarymetaDisplayAbn$se
upperDisplayAbn <- summarymetaDisplayAbn$summary-1.96*summarymetaDisplayAbn$se

PvalueDisplayAbn  <- 2* pnorm(-abs(summarymetaDisplayAbn $summary/summarymetaDisplayAbn$se))
}

{## metaDisplay - Velocity
metaDisplayVelocity <- data.frame('study' = c('Sanja', 'Johannes'))


metaDisplayVelocity$est[metaDisplayVelocity$study == 'Sanja'] <- estimatesSanjaDisplayVelocity[2,1]
metaDisplayVelocity$SE[metaDisplayVelocity$study == 'Sanja'] <- estimatesSanjaDisplayVelocity[2,2]
metaDisplayVelocity$lower[metaDisplayVelocity$study == 'Sanja'] <- estimatesSanjaDisplayVelocity[2,1]-1.96*estimatesSanjaDisplayVelocity[2,2]
metaDisplayVelocity$upper[metaDisplayVelocity$study == 'Sanja'] <- estimatesSanjaDisplayVelocity[2,1]+1.96*estimatesSanjaDisplayVelocity[2,2]


metaDisplayVelocity$est[metaDisplayVelocity$study == 'Johannes'] <- estimatesJohannesDisplayVelocity[2,1]
metaDisplayVelocity$SE[metaDisplayVelocity$study == 'Johannes'] <- estimatesJohannesDisplayVelocity[2,2]
metaDisplayVelocity$lower[metaDisplayVelocity$study == 'Johannes'] <- estimatesJohannesDisplayVelocity[2,1]-1.96*estimatesJohannesDisplayVelocity[2,2]
metaDisplayVelocity$upper[metaDisplayVelocity$study == 'Johannes'] <- estimatesJohannesDisplayVelocity[2,1]+1.96*estimatesJohannesDisplayVelocity[2,2]


summarymetaDisplayVelocity <- meta.summaries(metaDisplayVelocity$est, metaDisplayVelocity$SE, names=metaDisplayVelocity$study, method="fixed")

rDisplayVCL <- summarymetaDisplayVelocity$summary
lowerDisplayVCL <- summarymetaDisplayVelocity$summary+1.96*summarymetaDisplayVelocity$se
upperDisplayVCL <- summarymetaDisplayVelocity$summary-1.96*summarymetaDisplayVelocity$se

PvalueDisplayVCL<- 2* pnorm(-abs(summarymetaDisplayVelocity $summary/summarymetaDisplayVelocity$se))
}

{## metaDisplay - Slength 
metaDisplaySlength <- data.frame('study' = c('Sanja', 'Johannes'))

metaDisplaySlength$est[metaDisplaySlength$study == 'Sanja'] <- estimatesSanjaDisplaySlength[2,1]
metaDisplaySlength$SE[metaDisplaySlength$study == 'Sanja'] <- estimatesSanjaDisplaySlength[2,2]
metaDisplaySlength$lower[metaDisplaySlength$study == 'Sanja'] <- estimatesSanjaDisplaySlength[2,1]-1.96*estimatesSanjaDisplaySlength[2,2]
metaDisplaySlength$upper[metaDisplaySlength$study == 'Sanja'] <- estimatesSanjaDisplaySlength[2,1]+1.96*estimatesSanjaDisplaySlength[2,2]


metaDisplaySlength$est[metaDisplaySlength$study == 'Johannes'] <- estimatesJohannesDisplaySlength[2,1]
metaDisplaySlength$SE[metaDisplaySlength$study == 'Johannes'] <- estimatesJohannesDisplaySlength[2,2]
metaDisplaySlength$lower[metaDisplaySlength$study == 'Johannes'] <- estimatesJohannesDisplaySlength[2,1]-1.96*estimatesJohannesDisplaySlength[2,2]
metaDisplaySlength$upper[metaDisplaySlength$study == 'Johannes'] <- estimatesJohannesDisplaySlength[2,1]+1.96*estimatesJohannesDisplaySlength[2,2]


summarymetaDisplaySlength <- meta.summaries(metaDisplaySlength$est, metaDisplaySlength$SE, names=metaDisplaySlength$study, method="fixed")

rDisplaySlength <- summarymetaDisplaySlength$summary
lowerDisplaySlength <- summarymetaDisplaySlength$summary+1.96*summarymetaDisplaySlength$se
upperDisplaySlength <- summarymetaDisplaySlength$summary-1.96*summarymetaDisplaySlength$se

PvalueDisplaySlength <- 2* pnorm(-abs(summarymetaDisplaySlength $summary/summarymetaDisplaySlength$se))
}

}

{## Tarsus - sperm traits per male

{## metaTarsus - Abnormal
metaTarsusAbn <- data.frame('study' = c('Sanja', 'Johannes'))

metaTarsusAbn$est[metaTarsusAbn$study == 'Sanja'] <- estimatesSanjaTarsusAbn[2,1]
metaTarsusAbn$SE[metaTarsusAbn$study == 'Sanja'] <- estimatesSanjaTarsusAbn[2,2]
metaTarsusAbn$lower[metaTarsusAbn$study == 'Sanja'] <- estimatesSanjaTarsusAbn[2,1]-1.96*estimatesSanjaTarsusAbn[2,2]
metaTarsusAbn$upper[metaTarsusAbn$study == 'Sanja'] <- estimatesSanjaTarsusAbn[2,1]+1.96*estimatesSanjaTarsusAbn[2,2]


metaTarsusAbn$est[metaTarsusAbn$study == 'Johannes'] <- estimatesJohannesTarsusAbn[2,1]
metaTarsusAbn$SE[metaTarsusAbn$study == 'Johannes'] <- estimatesJohannesTarsusAbn[2,2]
metaTarsusAbn$lower[metaTarsusAbn$study == 'Johannes'] <- estimatesJohannesTarsusAbn[2,1]-1.96*estimatesJohannesTarsusAbn[2,2]
metaTarsusAbn$upper[metaTarsusAbn$study == 'Johannes'] <- estimatesJohannesTarsusAbn[2,1]+1.96*estimatesJohannesTarsusAbn[2,2]

summarymetaTarsusAbn <- meta.summaries(metaTarsusAbn$est, metaTarsusAbn$SE, names=metaTarsusAbn$study, method="fixed")

rTarsusAbn <- summarymetaTarsusAbn$summary
lowerTarsusAbn <- summarymetaTarsusAbn$summary+1.96*summarymetaTarsusAbn$se
upperTarsusAbn <- summarymetaTarsusAbn$summary-1.96*summarymetaTarsusAbn$se

PvalueTarsusAbn <- 2* pnorm(-abs(summarymetaTarsusAbn $summary/summarymetaTarsusAbn$se))
}

{## metaTarsus - Velocity
metaTarsusVCL <- data.frame('study' = c('Sanja', 'Johannes'))

metaTarsusVCL$est[metaTarsusVCL$study == 'Sanja'] <- estimatesSanjaTarsusVCL[2,1]
metaTarsusVCL$SE[metaTarsusVCL$study == 'Sanja'] <- estimatesSanjaTarsusVCL[2,2]
metaTarsusVCL$lower[metaTarsusVCL$study == 'Sanja'] <- estimatesSanjaTarsusVCL[2,1]-1.96*estimatesSanjaTarsusVCL[2,2]
metaTarsusVCL$upper[metaTarsusVCL$study == 'Sanja'] <- estimatesSanjaTarsusVCL[2,1]+1.96*estimatesSanjaTarsusVCL[2,2]


metaTarsusVCL$est[metaTarsusVCL$study == 'Johannes'] <- estimatesJohannesTarsusVCL[2,1]
metaTarsusVCL$SE[metaTarsusVCL$study == 'Johannes'] <- estimatesJohannesTarsusVCL[2,2]
metaTarsusVCL$lower[metaTarsusVCL$study == 'Johannes'] <- estimatesJohannesTarsusVCL[2,1]-1.96*estimatesJohannesTarsusVCL[2,2]
metaTarsusVCL$upper[metaTarsusVCL$study == 'Johannes'] <- estimatesJohannesTarsusVCL[2,1]+1.96*estimatesJohannesTarsusVCL[2,2]

summarymetaTarsusVCL <- meta.summaries(metaTarsusVCL$est, metaTarsusVCL$SE, names=metaTarsusVCL$study, method="fixed")

rTarsusVCL <- summarymetaTarsusVCL$summary
lowerTarsusVCL <- summarymetaTarsusVCL$summary+1.96*summarymetaTarsusVCL$se
upperTarsusVCL <- summarymetaTarsusVCL$summary-1.96*summarymetaTarsusVCL$se

PvalueTarsusVCL  <- 2* pnorm(-abs(summarymetaTarsusVCL $summary/summarymetaTarsusVCL$se))
}

{## metaTarsus - Slength 
metaTarsusSlength <- data.frame('study' = c( 'Sanja', 'Johannes'))

metaTarsusSlength$est[metaTarsusSlength$study == 'Sanja'] <- estimatesSanjaTarsusSlength[2,1]
metaTarsusSlength$SE[metaTarsusSlength$study == 'Sanja'] <- estimatesSanjaTarsusSlength[2,2]
metaTarsusSlength$lower[metaTarsusSlength$study == 'Sanja'] <- estimatesSanjaTarsusSlength[2,1]-1.96*estimatesSanjaTarsusSlength[2,2]
metaTarsusSlength$upper[metaTarsusSlength$study == 'Sanja'] <- estimatesSanjaTarsusSlength[2,1]+1.96*estimatesSanjaTarsusSlength[2,2]


metaTarsusSlength$est[metaTarsusSlength$study == 'Johannes'] <- estimatesJohannesTarsusSlength[2,1]
metaTarsusSlength$SE[metaTarsusSlength$study == 'Johannes'] <- estimatesJohannesTarsusSlength[2,2]
metaTarsusSlength$lower[metaTarsusSlength$study == 'Johannes'] <- estimatesJohannesTarsusSlength[2,1]-1.96*estimatesJohannesTarsusSlength[2,2]
metaTarsusSlength$upper[metaTarsusSlength$study == 'Johannes'] <- estimatesJohannesTarsusSlength[2,1]+1.96*estimatesJohannesTarsusSlength[2,2]

summarymetaTarsusSlength <- meta.summaries(metaTarsusSlength$est, metaTarsusSlength$SE, names=metaTarsusSlength$study, method="fixed")

rTarsusSlength <- summarymetaTarsusSlength$summary
lowerTarsusSlength <- summarymetaTarsusSlength$summary+1.96*summarymetaTarsusSlength$se
upperTarsusSlength <- summarymetaTarsusSlength$summary-1.96*summarymetaTarsusSlength$se

PvalueTarsusSlength  <- 2* pnorm(-abs(summarymetaTarsusSlength $summary/summarymetaTarsusSlength$se))
}

}


}

{### with InbredYN controlled for in all three datasets - meta.summaries

{## Beak color Munsel - sperm traits per male

{## metaBeakColorMunsel - Abnormal 	
metaBeakColorMunselAbnF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Malika'] <- estimatesMalikaBeakAbn[2,1]
metaBeakColorMunselAbnF$SE[metaBeakColorMunselAbnF$study == 'Malika'] <- estimatesMalikaBeakAbn[2,2]
metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Malika'] <- estimatesMalikaBeakAbn[2,1]-1.96*estimatesMalikaBeakAbn[2,2]
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Malika'] <- estimatesMalikaBeakAbn[2,1]+1.96*estimatesMalikaBeakAbn[2,2]


metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Sanja'] <- estimatesSanjaBeakMunselAbnF[2,1]
metaBeakColorMunselAbnF$SE[metaBeakColorMunselAbnF$study == 'Sanja'] <- estimatesSanjaBeakMunselAbnF[2,2]
metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Sanja'] <- estimatesSanjaBeakMunselAbnF[2,1]-1.96*estimatesSanjaBeakMunselAbnF[2,2]
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Sanja'] <- estimatesSanjaBeakMunselAbnF[2,1]+1.96*estimatesSanjaBeakMunselAbnF[2,2]


metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Johannes'] <- estimatesJohannesBeakMunselAbnF[2,1]
metaBeakColorMunselAbnF$SE[metaBeakColorMunselAbnF$study == 'Johannes'] <- estimatesJohannesBeakMunselAbnF[2,2]
metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Johannes'] <- estimatesJohannesBeakMunselAbnF[2,1]-1.96*estimatesJohannesBeakMunselAbnF[2,2]
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Johannes'] <- estimatesJohannesBeakMunselAbnF[2,1]+1.96*estimatesJohannesBeakMunselAbnF[2,2]

summarymetaBeakColorMunselAbnF <- meta.summaries(metaBeakColorMunselAbnF$est, metaBeakColorMunselAbnF$SE, names=metaBeakColorMunselAbnF$study, method="fixed")

rBeakAbnF <- summarymetaBeakColorMunselAbnF$summary
lowerBeakAbnF <- summarymetaBeakColorMunselAbnF$summary+1.96*summarymetaBeakColorMunselAbnF$se
upperBeakAbnF <- summarymetaBeakColorMunselAbnF$summary-1.96*summarymetaBeakColorMunselAbnF$se

PvalueBeakAbnF  <- 2* pnorm(-abs(summarymetaBeakColorMunselAbnF $summary/summarymetaBeakColorMunselAbnF$se))
}

{## metaBeakColorMunsel - Velocity
metaBeakColorMunselVCLF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Malika'] <- estimatesMalikaBeakVCL[2,1]
metaBeakColorMunselVCLF$SE[metaBeakColorMunselVCLF$study == 'Malika'] <- estimatesMalikaBeakVCL[2,2]
metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Malika'] <- estimatesMalikaBeakVCL[2,1]-1.96*estimatesMalikaBeakVCL[2,2]
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Malika'] <- estimatesMalikaBeakVCL[2,1]+1.96*estimatesMalikaBeakVCL[2,2]

metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Sanja'] <- estimatesSanjaBeakMunselVCLF[2,1]
metaBeakColorMunselVCLF$SE[metaBeakColorMunselVCLF$study == 'Sanja'] <- estimatesSanjaBeakMunselVCLF[2,2]
metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Sanja'] <- estimatesSanjaBeakMunselVCLF[2,1]-1.96*estimatesSanjaBeakMunselVCLF[2,2]
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Sanja'] <- estimatesSanjaBeakMunselVCLF[2,1]+1.96*estimatesSanjaBeakMunselVCLF[2,2]


metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Johannes'] <- estimatesJohannesBeakMunselVCLF[2,1]
metaBeakColorMunselVCLF$SE[metaBeakColorMunselVCLF$study == 'Johannes'] <- estimatesJohannesBeakMunselVCLF[2,2]
metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Johannes'] <- estimatesJohannesBeakMunselVCLF[2,1]-1.96*estimatesJohannesBeakMunselVCLF[2,2]
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Johannes'] <- estimatesJohannesBeakMunselVCLF[2,1]+1.96*estimatesJohannesBeakMunselVCLF[2,2]

summarymetaBeakColorMunselVCLF <- meta.summaries(metaBeakColorMunselVCLF$est, metaBeakColorMunselVCLF$SE, names=metaBeakColorMunselVCLF$study, method="fixed")

rBeakVCLF <- summarymetaBeakColorMunselVCLF$summary
lowerBeakVCLF <- summarymetaBeakColorMunselVCLF$summary+1.96*summarymetaBeakColorMunselVCLF$se
upperBeakVCLF <- summarymetaBeakColorMunselVCLF$summary-1.96*summarymetaBeakColorMunselVCLF$se

PvalueBeakVCLF  <- 2* pnorm(-abs(summarymetaBeakColorMunselVCLF $summary/summarymetaBeakColorMunselVCLF$se))
}

{## metaBeakColorMunsel - Slength 
metaBeakColorMunselSlengthF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Malika'] <- estimatesMalikaBeakSlength[2,1]
metaBeakColorMunselSlengthF$SE[metaBeakColorMunselSlengthF$study == 'Malika'] <- estimatesMalikaBeakSlength[2,2]
metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Malika'] <- estimatesMalikaBeakSlength[2,1]-1.96*estimatesMalikaBeakSlength[2,2]
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Malika'] <- estimatesMalikaBeakSlength[2,1]+1.96*estimatesMalikaBeakSlength[2,2]

metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Sanja'] <- estimatesSanjaBeakMunselSlengthF[2,1]
metaBeakColorMunselSlengthF$SE[metaBeakColorMunselSlengthF$study == 'Sanja'] <- estimatesSanjaBeakMunselSlengthF[2,2]
metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Sanja'] <- estimatesSanjaBeakMunselSlengthF[2,1]-1.96*estimatesSanjaBeakMunselSlengthF[2,2]
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Sanja'] <- estimatesSanjaBeakMunselSlengthF[2,1]+1.96*estimatesSanjaBeakMunselSlengthF[2,2]


metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Johannes'] <- estimatesJohannesBeakMunselSlengthF[2,1]
metaBeakColorMunselSlengthF$SE[metaBeakColorMunselSlengthF$study == 'Johannes'] <- estimatesJohannesBeakMunselSlengthF[2,2]
metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Johannes'] <- estimatesJohannesBeakMunselSlengthF[2,1]-1.96*estimatesJohannesBeakMunselSlengthF[2,2]
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Johannes'] <- estimatesJohannesBeakMunselSlengthF[2,1]+1.96*estimatesJohannesBeakMunselSlengthF[2,2]

summarymetaBeakColorMunselSlengthF <- meta.summaries(metaBeakColorMunselSlengthF$est, metaBeakColorMunselSlengthF$SE, names=metaBeakColorMunselSlengthF$study, method="fixed")

rBeakSlengthF <- summarymetaBeakColorMunselSlengthF$summary
lowerBeakSlengthF <- summarymetaBeakColorMunselSlengthF$summary+1.96*summarymetaBeakColorMunselSlengthF$se
upperBeakSlengthF <- summarymetaBeakColorMunselSlengthF$summary-1.96*summarymetaBeakColorMunselSlengthF$se

PvalueBeakSlengthF  <- 2* pnorm(-abs(summarymetaBeakColorMunselSlengthF $summary/summarymetaBeakColorMunselSlengthF$se))
}

}

{## Courtship rate - sperm traits per male-year

{## metaDisplay - Abnormal
metaDisplayAbnF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

metaDisplayAbnF$est[metaDisplayAbnF$study == 'Malika'] <- estimatesMalikaDisplayAbn[2,1]
metaDisplayAbnF$SE[metaDisplayAbnF$study == 'Malika'] <- estimatesMalikaDisplayAbn[2,2]
metaDisplayAbnF$lower[metaDisplayAbnF$study == 'Malika'] <- estimatesMalikaDisplayAbn[2,1]-1.96*estimatesMalikaDisplayAbn[2,2]
metaDisplayAbnF$upper[metaDisplayAbnF$study == 'Malika'] <- estimatesMalikaDisplayAbn[2,1]+1.96*estimatesMalikaDisplayAbn[2,2]

metaDisplayAbnF$est[metaDisplayAbnF$study == 'Sanja'] <- estimatesSanjaDisplayAbnF[2,1]
metaDisplayAbnF$SE[metaDisplayAbnF$study == 'Sanja'] <- estimatesSanjaDisplayAbnF[2,2]
metaDisplayAbnF$lower[metaDisplayAbnF$study == 'Sanja'] <- estimatesSanjaDisplayAbnF[2,1]-1.96*estimatesSanjaDisplayAbnF[2,2]
metaDisplayAbnF$upper[metaDisplayAbnF$study == 'Sanja'] <- estimatesSanjaDisplayAbnF[2,1]+1.96*estimatesSanjaDisplayAbnF[2,2]


metaDisplayAbnF$est[metaDisplayAbnF$study == 'Johannes'] <- estimatesJohannesDisplayAbnF[2,1]
metaDisplayAbnF$SE[metaDisplayAbnF$study == 'Johannes'] <- estimatesJohannesDisplayAbnF[2,2]
metaDisplayAbnF$lower[metaDisplayAbnF$study == 'Johannes'] <- estimatesJohannesDisplayAbnF[2,1]-1.96*estimatesJohannesDisplayAbnF[2,2]
metaDisplayAbnF$upper[metaDisplayAbnF$study == 'Johannes'] <- estimatesJohannesDisplayAbnF[2,1]+1.96*estimatesJohannesDisplayAbnF[2,2]


summarymetaDisplayAbnF <-  meta.summaries(metaDisplayAbnF$est, metaDisplayAbnF$SE, names=metaDisplayAbnF$study, method="fixed")

rDisplayAbnF <- summarymetaDisplayAbnF$summary
lowerDisplayAbnF <- summarymetaDisplayAbnF$summary+1.96*summarymetaDisplayAbnF$se
upperDisplayAbnF <- summarymetaDisplayAbnF$summary-1.96*summarymetaDisplayAbnF$se


PvalueDisplayAbnF <- 2* pnorm(-abs(summarymetaDisplayAbnF$summary/summarymetaDisplayAbnF$se))

}

{## metaDisplay - Velocity
metaDisplayVelocityF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Malika'] <- estimatesMalikaDisplayVelocity[2,1]
metaDisplayVelocityF$SE[metaDisplayVelocityF$study == 'Malika'] <- estimatesMalikaDisplayVelocity[2,2]
metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Malika'] <- estimatesMalikaDisplayVelocity[2,1]-1.96*estimatesMalikaDisplayVelocity[2,2]
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Malika'] <- estimatesMalikaDisplayVelocity[2,1]+1.96*estimatesMalikaDisplayVelocity[2,2]


metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Sanja'] <- estimatesSanjaDisplayVelocityF[2,1]
metaDisplayVelocityF$SE[metaDisplayVelocityF$study == 'Sanja'] <- estimatesSanjaDisplayVelocityF[2,2]
metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Sanja'] <- estimatesSanjaDisplayVelocityF[2,1]-1.96*estimatesSanjaDisplayVelocityF[2,2]
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Sanja'] <- estimatesSanjaDisplayVelocityF[2,1]+1.96*estimatesSanjaDisplayVelocityF[2,2]


metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Johannes'] <- estimatesJohannesDisplayVelocityF[2,1]
metaDisplayVelocityF$SE[metaDisplayVelocityF$study == 'Johannes'] <- estimatesJohannesDisplayVelocityF[2,2]
metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Johannes'] <- estimatesJohannesDisplayVelocityF[2,1]-1.96*estimatesJohannesDisplayVelocityF[2,2]
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Johannes'] <- estimatesJohannesDisplayVelocityF[2,1]+1.96*estimatesJohannesDisplayVelocityF[2,2]


summarymetaDisplayVelocityF <- meta.summaries(metaDisplayVelocityF$est, metaDisplayVelocityF$SE, names=metaDisplayVelocityF$study, method="fixed")

rDisplayVCLF <- summarymetaDisplayVelocityF$summary
lowerDisplayVCLF <- summarymetaDisplayVelocityF$summary+1.96*summarymetaDisplayVelocityF$se
upperDisplayVCLF <- summarymetaDisplayVelocityF$summary-1.96*summarymetaDisplayVelocityF$se

PvalueDisplayVCLF <- 2* pnorm(-abs(summarymetaDisplayVelocityF$summary/summarymetaDisplayVelocityF$se))

}

{## metaDisplay - Slength 
metaDisplaySlengthF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Malika'] <- estimatesMalikaDisplaySlength[2,1]
metaDisplaySlengthF$SE[metaDisplaySlengthF$study == 'Malika'] <- estimatesMalikaDisplaySlength[2,2]
metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Malika'] <- estimatesMalikaDisplaySlength[2,1]-1.96*estimatesMalikaDisplaySlength[2,2]
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Malika'] <- estimatesMalikaDisplaySlength[2,1]+1.96*estimatesMalikaDisplaySlength[2,2]


metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Sanja'] <- estimatesSanjaDisplaySlengthF[2,1]
metaDisplaySlengthF$SE[metaDisplaySlengthF$study == 'Sanja'] <- estimatesSanjaDisplaySlengthF[2,2]
metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Sanja'] <- estimatesSanjaDisplaySlengthF[2,1]-1.96*estimatesSanjaDisplaySlengthF[2,2]
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Sanja'] <- estimatesSanjaDisplaySlengthF[2,1]+1.96*estimatesSanjaDisplaySlengthF[2,2]


metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Johannes'] <- estimatesJohannesDisplaySlengthF[2,1]
metaDisplaySlengthF$SE[metaDisplaySlengthF$study == 'Johannes'] <- estimatesJohannesDisplaySlengthF[2,2]
metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Johannes'] <- estimatesJohannesDisplaySlengthF[2,1]-1.96*estimatesJohannesDisplaySlengthF[2,2]
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Johannes'] <- estimatesJohannesDisplaySlengthF[2,1]+1.96*estimatesJohannesDisplaySlengthF[2,2]


summarymetaDisplaySlengthF <- meta.summaries(metaDisplaySlengthF$est, metaDisplaySlengthF$SE, names=metaDisplaySlengthF$study, method="fixed")

rDisplaySlengthF <- summarymetaDisplaySlengthF$summary
lowerDisplaySlengthF <- summarymetaDisplaySlengthF$summary+1.96*summarymetaDisplaySlengthF$se
upperDisplaySlengthF <- summarymetaDisplaySlengthF$summary-1.96*summarymetaDisplaySlengthF$se

PvalueDisplaySlengthF <- 2* pnorm(-abs(summarymetaDisplaySlengthF$summary/summarymetaDisplaySlengthF$se))


}

}

{## Tarsus - sperm traits per male

{## metaTarsus - Abnormal 	
metaTarsusAbnF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaTarsusAbnF$est[metaTarsusAbnF$study == 'Malika'] <- estimatesMalikaTarsusAbn[2,1]
metaTarsusAbnF$SE[metaTarsusAbnF$study == 'Malika'] <- estimatesMalikaTarsusAbn[2,2]
metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Malika'] <- estimatesMalikaTarsusAbn[2,1]-1.96*estimatesMalikaTarsusAbn[2,2]
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Malika'] <- estimatesMalikaTarsusAbn[2,1]+1.96*estimatesMalikaTarsusAbn[2,2]


metaTarsusAbnF$est[metaTarsusAbnF$study == 'Sanja'] <- estimatesSanjaTarsusAbnF[2,1]
metaTarsusAbnF$SE[metaTarsusAbnF$study == 'Sanja'] <- estimatesSanjaTarsusAbnF[2,2]
metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Sanja'] <- estimatesSanjaTarsusAbnF[2,1]-1.96*estimatesSanjaTarsusAbnF[2,2]
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Sanja'] <- estimatesSanjaTarsusAbnF[2,1]+1.96*estimatesSanjaTarsusAbnF[2,2]


metaTarsusAbnF$est[metaTarsusAbnF$study == 'Johannes'] <- estimatesJohannesTarsusAbnF[2,1]
metaTarsusAbnF$SE[metaTarsusAbnF$study == 'Johannes'] <- estimatesJohannesTarsusAbnF[2,2]
metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Johannes'] <- estimatesJohannesTarsusAbnF[2,1]-1.96*estimatesJohannesTarsusAbnF[2,2]
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Johannes'] <- estimatesJohannesTarsusAbnF[2,1]+1.96*estimatesJohannesTarsusAbnF[2,2]

summarymetaTarsusAbnF <- meta.summaries(metaTarsusAbnF$est, metaTarsusAbnF$SE, names=metaTarsusAbnF$study, method="fixed")

rTarsusAbnF <- summarymetaTarsusAbnF$summary
lowerTarsusAbnF <- summarymetaTarsusAbnF$summary+1.96*summarymetaTarsusAbnF$se
upperTarsusAbnF <- summarymetaTarsusAbnF$summary-1.96*summarymetaTarsusAbnF$se

PvalueTarsusAbnF <- 2* pnorm(-abs(summarymetaTarsusAbnF$summary/summarymetaTarsusAbnF$se))

}

{## metaTarsus - Velocity
metaTarsusVCLF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaTarsusVCLF$est[metaTarsusVCLF$study == 'Malika'] <- estimatesMalikaTarsusVCL[2,1]
metaTarsusVCLF$SE[metaTarsusVCLF$study == 'Malika'] <- estimatesMalikaTarsusVCL[2,2]
metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Malika'] <- estimatesMalikaTarsusVCL[2,1]-1.96*estimatesMalikaTarsusVCL[2,2]
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Malika'] <- estimatesMalikaTarsusVCL[2,1]+1.96*estimatesMalikaTarsusVCL[2,2]

metaTarsusVCLF$est[metaTarsusVCLF$study == 'Sanja'] <- estimatesSanjaTarsusVCLF[2,1]
metaTarsusVCLF$SE[metaTarsusVCLF$study == 'Sanja'] <- estimatesSanjaTarsusVCLF[2,2]
metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Sanja'] <- estimatesSanjaTarsusVCLF[2,1]-1.96*estimatesSanjaTarsusVCLF[2,2]
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Sanja'] <- estimatesSanjaTarsusVCLF[2,1]+1.96*estimatesSanjaTarsusVCLF[2,2]


metaTarsusVCLF$est[metaTarsusVCLF$study == 'Johannes'] <- estimatesJohannesTarsusVCLF[2,1]
metaTarsusVCLF$SE[metaTarsusVCLF$study == 'Johannes'] <- estimatesJohannesTarsusVCLF[2,2]
metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Johannes'] <- estimatesJohannesTarsusVCLF[2,1]-1.96*estimatesJohannesTarsusVCLF[2,2]
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Johannes'] <- estimatesJohannesTarsusVCLF[2,1]+1.96*estimatesJohannesTarsusVCLF[2,2]

summarymetaTarsusVCLF <- meta.summaries(metaTarsusVCLF$est, metaTarsusVCLF$SE, names=metaTarsusVCLF$study, method="fixed")

rTarsusVCLF <- summarymetaTarsusVCLF$summary
lowerTarsusVCLF <- summarymetaTarsusVCLF$summary+1.96*summarymetaTarsusVCLF$se
upperTarsusVCLF <- summarymetaTarsusVCLF$summary-1.96*summarymetaTarsusVCLF$se

PvalueTarsusVCLF <- 2* pnorm(-abs(summarymetaTarsusVCLF$summary/summarymetaTarsusVCLF$se))
}

{## metaTarsus - Slength 
metaTarsusSlengthF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Malika'] <- estimatesMalikaTarsusSlength[2,1]
metaTarsusSlengthF$SE[metaTarsusSlengthF$study == 'Malika'] <- estimatesMalikaTarsusSlength[2,2]
metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Malika'] <- estimatesMalikaTarsusSlength[2,1]-1.96*estimatesMalikaTarsusSlength[2,2]
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Malika'] <- estimatesMalikaTarsusSlength[2,1]+1.96*estimatesMalikaTarsusSlength[2,2]

metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Sanja'] <- estimatesSanjaTarsusSlengthF[2,1]
metaTarsusSlengthF$SE[metaTarsusSlengthF$study == 'Sanja'] <- estimatesSanjaTarsusSlengthF[2,2]
metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Sanja'] <- estimatesSanjaTarsusSlengthF[2,1]-1.96*estimatesSanjaTarsusSlengthF[2,2]
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Sanja'] <- estimatesSanjaTarsusSlengthF[2,1]+1.96*estimatesSanjaTarsusSlengthF[2,2]


metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Johannes'] <- estimatesJohannesTarsusSlengthF[2,1]
metaTarsusSlengthF$SE[metaTarsusSlengthF$study == 'Johannes'] <- estimatesJohannesTarsusSlengthF[2,2]
metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Johannes'] <- estimatesJohannesTarsusSlengthF[2,1]-1.96*estimatesJohannesTarsusSlengthF[2,2]
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Johannes'] <- estimatesJohannesTarsusSlengthF[2,1]+1.96*estimatesJohannesTarsusSlengthF[2,2]

summarymetaTarsusSlengthF <- meta.summaries(metaTarsusSlengthF$est, metaTarsusSlengthF$SE, names=metaTarsusSlengthF$study, method="fixed")

rTarsusSlengthF <- summarymetaTarsusSlengthF$summary
lowerTarsusSlengthF <- summarymetaTarsusSlengthF$summary+1.96*summarymetaTarsusSlengthF$se
upperTarsusSlengthF <- summarymetaTarsusSlengthF$summary-1.96*summarymetaTarsusSlengthF$se

PvalueTarsusSlengthF <- 2* pnorm(-abs(summarymetaTarsusSlengthF$summary/summarymetaTarsusSlengthF$se))
}

}


}

}

{### table corrspermtraitsphenotypictraits

corrspermtraitsphenotypictraits <- data.frame('corr' = c('BeakAbn', 'BeakVCL', 'BeakSlength',
														'DisplayAbn', 'DisplayVCL', 'DisplaySlength',
														'TarsusAbn', 'TarsusVCL', 'TarsusSlength',
														'BeakAbnF', 'BeakVCLF', 'BeakSlengthF',
														'DisplayAbnF', 'DisplayVCLF', 'DisplaySlengthF',
														'TarsusAbnF', 'TarsusVCLF', 'TarsusSlengthF'))
										
corrspermtraitsphenotypictraits$r <- rbind(rBeakAbn,rBeakVCL, rBeakSlength,
											rDisplayAbn, rDisplayVCL, rDisplaySlength,
											rTarsusAbn, rTarsusVCL, rTarsusSlength,
											rBeakAbnF,rBeakVCLF, rBeakSlengthF,
											rDisplayAbnF, rDisplayVCLF, rDisplaySlengthF,
											rTarsusAbnF, rTarsusVCLF, rTarsusSlengthF)
											
corrspermtraitsphenotypictraits$lower <- rbind(lowerBeakAbn,lowerBeakVCL, lowerBeakSlength,
											lowerDisplayAbn, lowerDisplayVCL, lowerDisplaySlength,
											lowerTarsusAbn, lowerTarsusVCL, lowerTarsusSlength,
											lowerBeakAbnF,lowerBeakVCLF, lowerBeakSlengthF,
											lowerDisplayAbnF, lowerDisplayVCLF, lowerDisplaySlengthF,
											lowerTarsusAbnF, lowerTarsusVCLF, lowerTarsusSlengthF)
											
corrspermtraitsphenotypictraits$upper <- rbind(upperBeakAbn,upperBeakVCL, upperBeakSlength,
											upperDisplayAbn, upperDisplayVCL, upperDisplaySlength,
											upperTarsusAbn, upperTarsusVCL, upperTarsusSlength,
											upperBeakAbnF,upperBeakVCLF, upperBeakSlengthF,
											upperDisplayAbnF, upperDisplayVCLF, upperDisplaySlengthF,
											upperTarsusAbnF, upperTarsusVCLF, upperTarsusSlengthF)
											
corrspermtraitsphenotypictraits$Pvalue <- rbind(PvalueBeakAbn,PvalueBeakVCL, PvalueBeakSlength,
											PvalueDisplayAbn, PvalueDisplayVCL, PvalueDisplaySlength,
											PvalueTarsusAbn, PvalueTarsusVCL, PvalueTarsusSlength,
											PvalueBeakAbnF,PvalueBeakVCLF, PvalueBeakSlengthF,
											PvalueDisplayAbnF, PvalueDisplayVCLF, PvalueDisplaySlengthF,
											PvalueTarsusAbnF, PvalueTarsusVCLF, PvalueTarsusSlengthF)											
											
corrspermtraitsphenotypictraits$N <- rbind(sum(NSanjaBeakMunselAbn,NJohannesBeakMunselAbn),	
										   sum(NSanjaBeakMunselVelocity,NJohannesBeakMunselVCL),
										   sum(NSanjaBeakMunselSlength,NJohannesBeakMunselSlength),
										   sum(NSanjaDisplayAbn,NJohannesDisplayAbn),	
										   sum(NSanjaDisplayVelocity,NJohannesDisplayVelocity),
										   sum(NSanjaDisplaySlength,NJohannesDisplaySlength),
										   sum(NSanjaTarsusAbn,NJohannesTarsusAbn),	
										   sum(NSanjaTarsusVelocity,NJohannesTarsusVCL),
										   sum(NSanjaTarsusSlength,NJohannesTarsusSlength),
										   
										   sum(NMalikaBeakAbn,NSanjaBeakMunselAbn,NJohannesBeakMunselAbn),	
										   sum(NMalikaBeakVCL,NSanjaBeakMunselVelocity,NJohannesBeakMunselVCL),
										   sum(NMalikaBeakSlength,NSanjaBeakMunselSlength,NJohannesBeakMunselSlength),
										   sum(NMalikaDisplayAbn,NSanjaDisplayAbn,NJohannesDisplayAbn),	
										   sum(NMalikaDisplayVelocity,NSanjaDisplayVelocity,NJohannesDisplayVelocity),
										   sum(NMalikaDisplaySlength,NSanjaDisplaySlength,NJohannesDisplaySlength),
										   sum(NMalikaTarsusAbn,NSanjaTarsusAbn,NJohannesTarsusAbn),	
										   sum(NMalikaTarsusVCL,NSanjaTarsusVelocity,NJohannesTarsusVCL),
										   sum(NMalikaTarsusSlength,NSanjaTarsusSlength,NJohannesTarsusSlength)	)	


corrspermtraitsphenotypictraits$NMales <- rbind(sum(NSanjaBeakMunselAbn,NMalesJohannesBeakMunselAbn),	
										   sum(NSanjaBeakMunselVelocity,NMalesJohannesBeakMunselVCL),
										   sum(NSanjaBeakMunselSlength,NMalesJohannesBeakMunselSlength),
										   sum(NSanjaDisplayAbn,NMalesJohannesDisplayAbn),	
										   sum(NSanjaDisplayVelocity,NMalesJohannesDisplayVelocity),
										   sum(NSanjaDisplaySlength,NMalesJohannesDisplaySlength),
										   sum(NSanjaTarsusAbn,NMalesJohannesTarsusAbn),	
										   sum(NSanjaTarsusVelocity,NMalesJohannesTarsusVCL),
										   sum(NSanjaTarsusSlength,NMalesJohannesTarsusSlength),
										   
										   sum(NMalesMalikaBeakAbn,NSanjaBeakMunselAbn,NMalesJohannesBeakMunselAbn),	
										   sum(NMalesMalikaBeakVCL,NSanjaBeakMunselVelocity,NMalesJohannesBeakMunselVCL),
										   sum(NMalesMalikaBeakSlength,NSanjaBeakMunselSlength,NMalesJohannesBeakMunselSlength),
										   sum(NMalesMalikaDisplayAbn,NSanjaDisplayAbn,NMalesJohannesDisplayAbn),	
										   sum(NMalesMalikaDisplayVelocity,NSanjaDisplayVelocity,NMalesJohannesDisplayVelocity),
										   sum(NMalesMalikaDisplaySlength,NSanjaDisplaySlength,NMalesJohannesDisplaySlength),
										   sum(NMalesMalikaTarsusAbn,NSanjaTarsusAbn,NMalesJohannesTarsusAbn),	
										   sum(NMalesMalikaTarsusVCL,NSanjaTarsusVelocity,NMalesJohannesTarsusVCL),
										   sum(NMalesMalikaTarsusSlength,NSanjaTarsusSlength,NMalesJohannesTarsusSlength)	)	
										   
										   
										   
corrspermtraitsphenotypictraits
}


{### overall Phenotype meta-analysis

{## reversed expectation meta-analyses with Abnormal

{# without InbredYN controlled for in Johannes and Sanja datasets - meta.summaries

{## Beak color Munsel - sperm traits per male

{## metaBeakColorMunsel - Abnormal
metaBeakColorMunselAbnREV <- data.frame('study' = c('Sanja', 'Johannes'))

metaBeakColorMunselAbnREV$est[metaBeakColorMunselAbnREV$study == 'Sanja'] <- -estimatesSanjaBeakMunselAbn[2,1]
metaBeakColorMunselAbnREV$SE[metaBeakColorMunselAbnREV$study == 'Sanja'] <- estimatesSanjaBeakMunselAbn[2,2]
metaBeakColorMunselAbnREV$lower[metaBeakColorMunselAbnREV$study == 'Sanja'] <- -estimatesSanjaBeakMunselAbn[2,1]-1.96*estimatesSanjaBeakMunselAbn[2,2]
metaBeakColorMunselAbnREV$upper[metaBeakColorMunselAbnREV$study == 'Sanja'] <- -estimatesSanjaBeakMunselAbn[2,1]+1.96*estimatesSanjaBeakMunselAbn[2,2]


metaBeakColorMunselAbnREV$est[metaBeakColorMunselAbnREV$study == 'Johannes'] <- -estimatesJohannesBeakMunselAbn[2,1]
metaBeakColorMunselAbnREV$SE[metaBeakColorMunselAbnREV$study == 'Johannes'] <- estimatesJohannesBeakMunselAbn[2,2]
metaBeakColorMunselAbnREV$lower[metaBeakColorMunselAbnREV$study == 'Johannes'] <- -estimatesJohannesBeakMunselAbn[2,1]-1.96*estimatesJohannesBeakMunselAbn[2,2]
metaBeakColorMunselAbnREV$upper[metaBeakColorMunselAbnREV$study == 'Johannes'] <- -estimatesJohannesBeakMunselAbn[2,1]+1.96*estimatesJohannesBeakMunselAbn[2,2]

summarymetaBeakColorMunselAbnREV <- meta.summaries(metaBeakColorMunselAbnREV$est, metaBeakColorMunselAbnREV$SE, names=metaBeakColorMunselAbnREV$study, method="fixed")

rBeakAbnREV <- summarymetaBeakColorMunselAbnREV$summary
lowerBeakAbnREV <- summarymetaBeakColorMunselAbnREV$summary+1.96*summarymetaBeakColorMunselAbnREV$se
upperBeakAbnREV <- summarymetaBeakColorMunselAbnREV$summary-1.96*summarymetaBeakColorMunselAbnREV$se

}

}

{## Courtship rate - sperm traits per male-year

{## metaDisplay - Abnormal 
metaDisplayAbnREV <- data.frame('study' = c('Sanja', 'Johannes'))

metaDisplayAbnREV$est[metaDisplayAbnREV$study == 'Sanja'] <- -estimatesSanjaDisplayAbn[2,1]
metaDisplayAbnREV$SE[metaDisplayAbnREV$study == 'Sanja'] <- estimatesSanjaDisplayAbn[2,2]
metaDisplayAbnREV$lower[metaDisplayAbnREV$study == 'Sanja'] <-- estimatesSanjaDisplayAbn[2,1]-1.96*estimatesSanjaDisplayAbn[2,2]
metaDisplayAbnREV$upper[metaDisplayAbnREV$study == 'Sanja'] <- -estimatesSanjaDisplayAbn[2,1]+1.96*estimatesSanjaDisplayAbn[2,2]


metaDisplayAbnREV$est[metaDisplayAbnREV$study == 'Johannes'] <- -estimatesJohannesDisplayAbn[2,1]
metaDisplayAbnREV$SE[metaDisplayAbnREV$study == 'Johannes'] <- estimatesJohannesDisplayAbn[2,2]
metaDisplayAbnREV$lower[metaDisplayAbnREV$study == 'Johannes'] <- -estimatesJohannesDisplayAbn[2,1]-1.96*estimatesJohannesDisplayAbn[2,2]
metaDisplayAbnREV$upper[metaDisplayAbnREV$study == 'Johannes'] <- -estimatesJohannesDisplayAbn[2,1]+1.96*estimatesJohannesDisplayAbn[2,2]


summarymetaDisplayAbnREV <-  meta.summaries(metaDisplayAbnREV$est, metaDisplayAbnREV$SE, names=metaDisplayAbnREV$study, method="fixed")

rDisplayAbnREV <- summarymetaDisplayAbnREV$summary
lowerDisplayAbnREV <- summarymetaDisplayAbnREV$summary+1.96*summarymetaDisplayAbnREV$se
upperDisplayAbnREV <- summarymetaDisplayAbnREV$summary-1.96*summarymetaDisplayAbnREV$se

}

}

{## Tarsus - sperm traits per male

{## metaTarsus - Abnormal
metaTarsusAbnREV <- data.frame('study' = c('Sanja', 'Johannes'))

metaTarsusAbnREV$est[metaTarsusAbnREV$study == 'Sanja'] <- -estimatesSanjaTarsusAbn[2,1]
metaTarsusAbnREV$SE[metaTarsusAbnREV$study == 'Sanja'] <- estimatesSanjaTarsusAbn[2,2]
metaTarsusAbnREV$lower[metaTarsusAbnREV$study == 'Sanja'] <- -estimatesSanjaTarsusAbn[2,1]-1.96*estimatesSanjaTarsusAbn[2,2]
metaTarsusAbnREV$upper[metaTarsusAbnREV$study == 'Sanja'] <- -estimatesSanjaTarsusAbn[2,1]+1.96*estimatesSanjaTarsusAbn[2,2]


metaTarsusAbnREV$est[metaTarsusAbnREV$study == 'Johannes'] <- -estimatesJohannesTarsusAbn[2,1]
metaTarsusAbnREV$SE[metaTarsusAbnREV$study == 'Johannes'] <- estimatesJohannesTarsusAbn[2,2]
metaTarsusAbnREV$lower[metaTarsusAbnREV$study == 'Johannes'] <- -estimatesJohannesTarsusAbn[2,1]-1.96*estimatesJohannesTarsusAbn[2,2]
metaTarsusAbnREV$upper[metaTarsusAbnREV$study == 'Johannes'] <- -estimatesJohannesTarsusAbn[2,1]+1.96*estimatesJohannesTarsusAbn[2,2]

summarymetaTarsusAbnREV <- meta.summaries(metaTarsusAbnREV$est, metaTarsusAbnREV$SE, names=metaTarsusAbnREV$study, method="fixed")

rTarsusAbnREV <- summarymetaTarsusAbnREV$summary
lowerTarsusAbnREV <- summarymetaTarsusAbnREV$summary+1.96*summarymetaTarsusAbnREV$se
upperTarsusAbnREV <- summarymetaTarsusAbnREV$summary-1.96*summarymetaTarsusAbnREV$se

}

}


}

{# with InbredYN controlled for in all three datasets - meta.summaries

{## Beak color Munsel - sperm traits per male

{## metaBeakColorMunsel - Abnormal 	
metaBeakColorMunselAbnREVF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaBeakColorMunselAbnREVF$est[metaBeakColorMunselAbnREVF$study == 'Malika'] <- -estimatesMalikaBeakAbn[2,1]
metaBeakColorMunselAbnREVF$SE[metaBeakColorMunselAbnREVF$study == 'Malika'] <- estimatesMalikaBeakAbn[2,2]
metaBeakColorMunselAbnREVF$lower[metaBeakColorMunselAbnREVF$study == 'Malika'] <- -estimatesMalikaBeakAbn[2,1]-1.96*estimatesMalikaBeakAbn[2,2]
metaBeakColorMunselAbnREVF$upper[metaBeakColorMunselAbnREVF$study == 'Malika'] <- -estimatesMalikaBeakAbn[2,1]+1.96*estimatesMalikaBeakAbn[2,2]


metaBeakColorMunselAbnREVF$est[metaBeakColorMunselAbnREVF$study == 'Sanja'] <- -estimatesSanjaBeakMunselAbnF[2,1]
metaBeakColorMunselAbnREVF$SE[metaBeakColorMunselAbnREVF$study == 'Sanja'] <- estimatesSanjaBeakMunselAbnF[2,2]
metaBeakColorMunselAbnREVF$lower[metaBeakColorMunselAbnREVF$study == 'Sanja'] <- -estimatesSanjaBeakMunselAbnF[2,1]-1.96*estimatesSanjaBeakMunselAbnF[2,2]
metaBeakColorMunselAbnREVF$upper[metaBeakColorMunselAbnREVF$study == 'Sanja'] <- -estimatesSanjaBeakMunselAbnF[2,1]+1.96*estimatesSanjaBeakMunselAbnF[2,2]


metaBeakColorMunselAbnREVF$est[metaBeakColorMunselAbnREVF$study == 'Johannes'] <- -estimatesJohannesBeakMunselAbnF[2,1]
metaBeakColorMunselAbnREVF$SE[metaBeakColorMunselAbnREVF$study == 'Johannes'] <- estimatesJohannesBeakMunselAbnF[2,2]
metaBeakColorMunselAbnREVF$lower[metaBeakColorMunselAbnREVF$study == 'Johannes'] <- -estimatesJohannesBeakMunselAbnF[2,1]-1.96*estimatesJohannesBeakMunselAbnF[2,2]
metaBeakColorMunselAbnREVF$upper[metaBeakColorMunselAbnREVF$study == 'Johannes'] <- -estimatesJohannesBeakMunselAbnF[2,1]+1.96*estimatesJohannesBeakMunselAbnF[2,2]

summarymetaBeakColorMunselAbnREVF <- meta.summaries(metaBeakColorMunselAbnREVF$est, metaBeakColorMunselAbnREVF$SE, names=metaBeakColorMunselAbnREVF$study, method="fixed")

rBeakAbnREVF <- summarymetaBeakColorMunselAbnREVF$summary
lowerBeakAbnREVF <- summarymetaBeakColorMunselAbnREVF$summary+1.96*summarymetaBeakColorMunselAbnREVF$se
upperBeakAbnREVF <- summarymetaBeakColorMunselAbnREVF$summary-1.96*summarymetaBeakColorMunselAbnREVF$se


}

}

{## Courtship rate - sperm traits per male-year

{## metaDisplay - Abnormal
metaDisplayAbnREVF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

metaDisplayAbnREVF$est[metaDisplayAbnREVF$study == 'Malika'] <- -estimatesMalikaDisplayAbn[2,1]
metaDisplayAbnREVF$SE[metaDisplayAbnREVF$study == 'Malika'] <- estimatesMalikaDisplayAbn[2,2]
metaDisplayAbnREVF$lower[metaDisplayAbnREVF$study == 'Malika'] <- -estimatesMalikaDisplayAbn[2,1]-1.96*estimatesMalikaDisplayAbn[2,2]
metaDisplayAbnREVF$upper[metaDisplayAbnREVF$study == 'Malika'] <- -estimatesMalikaDisplayAbn[2,1]+1.96*estimatesMalikaDisplayAbn[2,2]

metaDisplayAbnREVF$est[metaDisplayAbnREVF$study == 'Sanja'] <- -estimatesSanjaDisplayAbnF[2,1]
metaDisplayAbnREVF$SE[metaDisplayAbnREVF$study == 'Sanja'] <- estimatesSanjaDisplayAbnF[2,2]
metaDisplayAbnREVF$lower[metaDisplayAbnREVF$study == 'Sanja'] <- -estimatesSanjaDisplayAbnF[2,1]-1.96*estimatesSanjaDisplayAbnF[2,2]
metaDisplayAbnREVF$upper[metaDisplayAbnREVF$study == 'Sanja'] <- -estimatesSanjaDisplayAbnF[2,1]+1.96*estimatesSanjaDisplayAbnF[2,2]


metaDisplayAbnREVF$est[metaDisplayAbnREVF$study == 'Johannes'] <- -estimatesJohannesDisplayAbnF[2,1]
metaDisplayAbnREVF$SE[metaDisplayAbnREVF$study == 'Johannes'] <- estimatesJohannesDisplayAbnF[2,2]
metaDisplayAbnREVF$lower[metaDisplayAbnREVF$study == 'Johannes'] <- -estimatesJohannesDisplayAbnF[2,1]-1.96*estimatesJohannesDisplayAbnF[2,2]
metaDisplayAbnREVF$upper[metaDisplayAbnREVF$study == 'Johannes'] <- -estimatesJohannesDisplayAbnF[2,1]+1.96*estimatesJohannesDisplayAbnF[2,2]


summarymetaDisplayAbnREVF <-  meta.summaries(metaDisplayAbnREVF$est, metaDisplayAbnREVF$SE, names=metaDisplayAbnREVF$study, method="fixed")

rDisplayAbnREVF <- summarymetaDisplayAbnREVF$summary
lowerDisplayAbnREVF <- summarymetaDisplayAbnREVF$summary+1.96*summarymetaDisplayAbnREVF$se
upperDisplayAbnREVF <- summarymetaDisplayAbnREVF$summary-1.96*summarymetaDisplayAbnREVF$se

}

}

{## Tarsus - sperm traits per male

{## metaTarsus - Abnormal 	
metaTarsusAbnREVF <- data.frame('study' = c('Malika','Sanja', 'Johannes'))

metaTarsusAbnREVF$est[metaTarsusAbnREVF$study == 'Malika'] <- -estimatesMalikaTarsusAbn[2,1]
metaTarsusAbnREVF$SE[metaTarsusAbnREVF$study == 'Malika'] <- estimatesMalikaTarsusAbn[2,2]
metaTarsusAbnREVF$lower[metaTarsusAbnREVF$study == 'Malika'] <- -estimatesMalikaTarsusAbn[2,1]-1.96*estimatesMalikaTarsusAbn[2,2]
metaTarsusAbnREVF$upper[metaTarsusAbnREVF$study == 'Malika'] <- -estimatesMalikaTarsusAbn[2,1]+1.96*estimatesMalikaTarsusAbn[2,2]


metaTarsusAbnREVF$est[metaTarsusAbnREVF$study == 'Sanja'] <- -estimatesSanjaTarsusAbnF[2,1]
metaTarsusAbnREVF$SE[metaTarsusAbnREVF$study == 'Sanja'] <- estimatesSanjaTarsusAbnF[2,2]
metaTarsusAbnREVF$lower[metaTarsusAbnREVF$study == 'Sanja'] <- -estimatesSanjaTarsusAbnF[2,1]-1.96*estimatesSanjaTarsusAbnF[2,2]
metaTarsusAbnREVF$upper[metaTarsusAbnREVF$study == 'Sanja'] <- -estimatesSanjaTarsusAbnF[2,1]+1.96*estimatesSanjaTarsusAbnF[2,2]


metaTarsusAbnREVF$est[metaTarsusAbnREVF$study == 'Johannes'] <- -estimatesJohannesTarsusAbnF[2,1]
metaTarsusAbnREVF$SE[metaTarsusAbnREVF$study == 'Johannes'] <- estimatesJohannesTarsusAbnF[2,2]
metaTarsusAbnREVF$lower[metaTarsusAbnREVF$study == 'Johannes'] <- -estimatesJohannesTarsusAbnF[2,1]-1.96*estimatesJohannesTarsusAbnF[2,2]
metaTarsusAbnREVF$upper[metaTarsusAbnREVF$study == 'Johannes'] <- -estimatesJohannesTarsusAbnF[2,1]+1.96*estimatesJohannesTarsusAbnF[2,2]

summarymetaTarsusAbnREVF <- meta.summaries(metaTarsusAbnREVF$est, metaTarsusAbnREVF$SE, names=metaTarsusAbnREVF$study, method="fixed")

rTarsusAbnREVF <- summarymetaTarsusAbnREVF$summary
lowerTarsusAbnREVF <- summarymetaTarsusAbnREVF$summary+1.96*summarymetaTarsusAbnREVF$se
upperTarsusAbnREVF <- summarymetaTarsusAbnREVF$summary-1.96*summarymetaTarsusAbnREVF$se

}

}


}

}


{# Overall without F
AllPhenotypesSperm <- rbind(
metaBeakColorMunselAbnREV,
metaBeakColorMunselVCL,
metaBeakColorMunselSlength,
metaDisplayAbnREV,
metaDisplayVelocity,
metaDisplaySlength,
metaTarsusAbnREV,
metaTarsusVCL,
metaTarsusSlength)

metasummaryAllPhenotypesSperm <- meta.summaries(AllPhenotypesSperm$est, AllPhenotypesSperm$SE, method="random")
rAllPhenotypesSperm <- metasummaryAllPhenotypesSperm$summary
lowerAllPhenotypesSperm <- metasummaryAllPhenotypesSperm$summary-1.96*metasummaryAllPhenotypesSperm$se
upperAllPhenotypesSperm <- metasummaryAllPhenotypesSperm$summary+1.96*metasummaryAllPhenotypesSperm$se
}

{# Overall with F

AllPhenotypesSpermF <- rbind(
metaBeakColorMunselAbnREVF,
metaBeakColorMunselVCLF,
metaBeakColorMunselSlengthF,
metaDisplayAbnREVF,
metaDisplayVelocityF,
metaDisplaySlengthF,
metaTarsusAbnREVF,
metaTarsusVCLF,
metaTarsusSlengthF)

metasummaryAllPhenotypesSpermF <- meta.summaries(AllPhenotypesSpermF$est, AllPhenotypesSpermF$SE, method="random")
rAllPhenotypesSpermF <- metasummaryAllPhenotypesSpermF$summary
lowerAllPhenotypesSpermF <- metasummaryAllPhenotypesSpermF$summary-1.96*metasummaryAllPhenotypesSpermF$se
upperAllPhenotypesSpermF <- metasummaryAllPhenotypesSpermF$summary+1.96*metasummaryAllPhenotypesSpermF$se

}

{# Overall with F without Malika

AllPhenotypesSpermFwithoutMalika <- AllPhenotypesSpermF[AllPhenotypesSpermF$study != "Malika",]

metasummaryAllPhenotypesSpermFwithoutMalika <- meta.summaries(AllPhenotypesSpermFwithoutMalika$est, AllPhenotypesSpermFwithoutMalika$SE, method="random")
rAllPhenotypesSpermFwithoutMalika <- metasummaryAllPhenotypesSpermFwithoutMalika$summary
lowerAllPhenotypesSpermFwithoutMalika <- metasummaryAllPhenotypesSpermFwithoutMalika$summary-1.96*metasummaryAllPhenotypesSpermFwithoutMalika$se
upperAllPhenotypesSpermFwithoutMalika <- metasummaryAllPhenotypesSpermFwithoutMalika$summary+1.96*metasummaryAllPhenotypesSpermFwithoutMalika$se

}

}

{### table Overallspermtraitsphenotypictraits

Overallspermtraitsphenotypictraits <- data.frame('corr' = c('withoutF', 'withF'))
Overallspermtraitsphenotypictraits$r <- rbind(rAllPhenotypesSperm,rAllPhenotypesSpermF)
Overallspermtraitsphenotypictraits$lower <- rbind(lowerAllPhenotypesSperm,lowerAllPhenotypesSpermF)
Overallspermtraitsphenotypictraits$upper <- rbind(upperAllPhenotypesSperm,upperAllPhenotypesSpermF)
Overallspermtraitsphenotypictraits
}







{#### fitness 

{### without InbredYN controlled for in Johannes and Sanja datasets  - meta.summaries

{## metaClutchIF - Abnormal
metaClutchIFAbn <- data.frame('study' = c('Sanja', 'Johannes'))

# sanja
metaClutchIFAbn$odds[metaClutchIFAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1])/
(1-invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]))/
(invlogit(estimatesSanjaIFAbn[1,1])/(1-invlogit(estimatesSanjaIFAbn[1,1])))

metaClutchIFAbn$lower1SE[metaClutchIFAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]-estimatesSanjaIFAbn[2,2])/
(1-invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]-estimatesSanjaIFAbn[2,2]))/
(invlogit(estimatesSanjaIFAbn[1,1])/(1-invlogit(estimatesSanjaIFAbn[1,1])))

metaClutchIFAbn$upper1SE[metaClutchIFAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]+estimatesSanjaIFAbn[2,2])/
(1-invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]+estimatesSanjaIFAbn[2,2]))/
(invlogit(estimatesSanjaIFAbn[1,1])/(1-invlogit(estimatesSanjaIFAbn[1,1])))

metaClutchIFAbn$lower2SE[metaClutchIFAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]-1.96*estimatesSanjaIFAbn[2,2])/
(1-invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]-1.96*estimatesSanjaIFAbn[2,2]))/
(invlogit(estimatesSanjaIFAbn[1,1])/(1-invlogit(estimatesSanjaIFAbn[1,1])))

metaClutchIFAbn$upper2SE[metaClutchIFAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]+1.96*estimatesSanjaIFAbn[2,2])/
(1-invlogit(estimatesSanjaIFAbn[1,1]+estimatesSanjaIFAbn[2,1]+1.96*estimatesSanjaIFAbn[2,2]))/
(invlogit(estimatesSanjaIFAbn[1,1])/(1-invlogit(estimatesSanjaIFAbn[1,1])))

# Johannes
metaClutchIFAbn$odds[metaClutchIFAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1])/
(1-invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]))/
(invlogit(estimatesJohannesIFAbn[1,1])/(1-invlogit(estimatesJohannesIFAbn[1,1])))

metaClutchIFAbn$lower1SE[metaClutchIFAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]-estimatesJohannesIFAbn[2,2])/
(1-invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]-estimatesJohannesIFAbn[2,2]))/
(invlogit(estimatesJohannesIFAbn[1,1])/(1-invlogit(estimatesJohannesIFAbn[1,1])))

metaClutchIFAbn$upper1SE[metaClutchIFAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]+estimatesJohannesIFAbn[2,2])/
(1-invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]+estimatesJohannesIFAbn[2,2]))/
(invlogit(estimatesJohannesIFAbn[1,1])/(1-invlogit(estimatesJohannesIFAbn[1,1])))

metaClutchIFAbn$lower2SE[metaClutchIFAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]-1.96*estimatesJohannesIFAbn[2,2])/
(1-invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]-1.96*estimatesJohannesIFAbn[2,2]))/
(invlogit(estimatesJohannesIFAbn[1,1])/(1-invlogit(estimatesJohannesIFAbn[1,1])))

metaClutchIFAbn$upper2SE[metaClutchIFAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]+1.96*estimatesJohannesIFAbn[2,2])/
(1-invlogit(estimatesJohannesIFAbn[1,1]+estimatesJohannesIFAbn[2,1]+1.96*estimatesJohannesIFAbn[2,2]))/
(invlogit(estimatesJohannesIFAbn[1,1])/(1-invlogit(estimatesJohannesIFAbn[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchIFAbn$logodds <- log10(metaClutchIFAbn$odds)
metaClutchIFAbn$loglower1SE <- log10(metaClutchIFAbn$lower1SE)
metaClutchIFAbn$logupper1SE <- log10(metaClutchIFAbn$upper1SE)
metaClutchIFAbn$SElower <- metaClutchIFAbn$logodds-metaClutchIFAbn$loglower1SE
metaClutchIFAbn$SEupper <- metaClutchIFAbn$logupper1SE-metaClutchIFAbn$logodds
metaClutchIFAbn$meanSE <- (metaClutchIFAbn$SElower+metaClutchIFAbn$SEupper)/2

summarymetaClutchIFAbn  <-meta.summaries(metaClutchIFAbn$logodds, metaClutchIFAbn$meanSE, names=metaClutchIFAbn$study, method="fixed")

# odds
10^0.0952	#1.245088
#lower
10^-0.0368	#0.9187556
#upper
10^0.227	#1.686553


}

{## metaClutchIF - Velocity
metaClutchIFVelocity <- data.frame('study' = c( 'Sanja', 'Johannes'))

# sanja
metaClutchIFVelocity$odds[metaClutchIFVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1])/
(1-invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]))/
(invlogit(estimatesSanjaIFVelocity[1,1])/(1-invlogit(estimatesSanjaIFVelocity[1,1])))

metaClutchIFVelocity$lower1SE[metaClutchIFVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]-estimatesSanjaIFVelocity[2,2])/
(1-invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]-estimatesSanjaIFVelocity[2,2]))/
(invlogit(estimatesSanjaIFVelocity[1,1])/(1-invlogit(estimatesSanjaIFVelocity[1,1])))

metaClutchIFVelocity$upper1SE[metaClutchIFVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]+estimatesSanjaIFVelocity[2,2])/
(1-invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]+estimatesSanjaIFVelocity[2,2]))/
(invlogit(estimatesSanjaIFVelocity[1,1])/(1-invlogit(estimatesSanjaIFVelocity[1,1])))

metaClutchIFVelocity$lower2SE[metaClutchIFVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]-1.96*estimatesSanjaIFVelocity[2,2])/
(1-invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]-1.96*estimatesSanjaIFVelocity[2,2]))/
(invlogit(estimatesSanjaIFVelocity[1,1])/(1-invlogit(estimatesSanjaIFVelocity[1,1])))

metaClutchIFVelocity$upper2SE[metaClutchIFVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]+1.96*estimatesSanjaIFVelocity[2,2])/
(1-invlogit(estimatesSanjaIFVelocity[1,1]+estimatesSanjaIFVelocity[2,1]+1.96*estimatesSanjaIFVelocity[2,2]))/
(invlogit(estimatesSanjaIFVelocity[1,1])/(1-invlogit(estimatesSanjaIFVelocity[1,1])))

# Johannes
metaClutchIFVelocity$odds[metaClutchIFVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1])/
(1-invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]))/
(invlogit(estimatesJohannesIFVelocity[1,1])/(1-invlogit(estimatesJohannesIFVelocity[1,1])))

metaClutchIFVelocity$lower1SE[metaClutchIFVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]-estimatesJohannesIFVelocity[2,2])/
(1-invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]-estimatesJohannesIFVelocity[2,2]))/
(invlogit(estimatesJohannesIFVelocity[1,1])/(1-invlogit(estimatesJohannesIFVelocity[1,1])))

metaClutchIFVelocity$upper1SE[metaClutchIFVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]+estimatesJohannesIFVelocity[2,2])/
(1-invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]+estimatesJohannesIFVelocity[2,2]))/
(invlogit(estimatesJohannesIFVelocity[1,1])/(1-invlogit(estimatesJohannesIFVelocity[1,1])))

metaClutchIFVelocity$lower2SE[metaClutchIFVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]-1.96*estimatesJohannesIFVelocity[2,2])/
(1-invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]-1.96*estimatesJohannesIFVelocity[2,2]))/
(invlogit(estimatesJohannesIFVelocity[1,1])/(1-invlogit(estimatesJohannesIFVelocity[1,1])))

metaClutchIFVelocity$upper2SE[metaClutchIFVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]+1.96*estimatesJohannesIFVelocity[2,2])/
(1-invlogit(estimatesJohannesIFVelocity[1,1]+estimatesJohannesIFVelocity[2,1]+1.96*estimatesJohannesIFVelocity[2,2]))/
(invlogit(estimatesJohannesIFVelocity[1,1])/(1-invlogit(estimatesJohannesIFVelocity[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchIFVelocity$logodds <- log10(metaClutchIFVelocity$odds)
metaClutchIFVelocity$loglower1SE <- log10(metaClutchIFVelocity$lower1SE)
metaClutchIFVelocity$logupper1SE <- log10(metaClutchIFVelocity$upper1SE)
metaClutchIFVelocity$SElower <- metaClutchIFVelocity$logodds-metaClutchIFVelocity$loglower1SE
metaClutchIFVelocity$SEupper <- metaClutchIFVelocity$logupper1SE-metaClutchIFVelocity$logodds
metaClutchIFVelocity$meanSE <- (metaClutchIFVelocity$SElower+metaClutchIFVelocity$SEupper)/2

summarymetaClutchIFVelocity  <-meta.summaries(metaClutchIFVelocity$logodds, metaClutchIFVelocity$meanSE, names=metaClutchIFVelocity$study, method="fixed")

# odds
10^0.151	#1.415794
#lower
10^-0.298	#0.5035006
#upper
10^0.00441	#1.010206



}

{## metaClutchIF - Slength 

metaClutchIFSlength <- data.frame('study' = c( 'Sanja', 'Johannes'))

# sanja
metaClutchIFSlength$odds[metaClutchIFSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1])/
(1-invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]))/
(invlogit(estimatesSanjaIFSlength[1,1])/(1-invlogit(estimatesSanjaIFSlength[1,1])))

metaClutchIFSlength$lower1SE[metaClutchIFSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]-estimatesSanjaIFSlength[2,2])/
(1-invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]-estimatesSanjaIFSlength[2,2]))/
(invlogit(estimatesSanjaIFSlength[1,1])/(1-invlogit(estimatesSanjaIFSlength[1,1])))

metaClutchIFSlength$upper1SE[metaClutchIFSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]+estimatesSanjaIFSlength[2,2])/
(1-invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]+estimatesSanjaIFSlength[2,2]))/
(invlogit(estimatesSanjaIFSlength[1,1])/(1-invlogit(estimatesSanjaIFSlength[1,1])))

metaClutchIFSlength$lower2SE[metaClutchIFSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]-1.96*estimatesSanjaIFSlength[2,2])/
(1-invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]-1.96*estimatesSanjaIFSlength[2,2]))/
(invlogit(estimatesSanjaIFSlength[1,1])/(1-invlogit(estimatesSanjaIFSlength[1,1])))

metaClutchIFSlength$upper2SE[metaClutchIFSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]+1.96*estimatesSanjaIFSlength[2,2])/
(1-invlogit(estimatesSanjaIFSlength[1,1]+estimatesSanjaIFSlength[2,1]+1.96*estimatesSanjaIFSlength[2,2]))/
(invlogit(estimatesSanjaIFSlength[1,1])/(1-invlogit(estimatesSanjaIFSlength[1,1])))

# Johannes
metaClutchIFSlength$odds[metaClutchIFSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1])/
(1-invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]))/
(invlogit(estimatesJohannesIFSlength[1,1])/(1-invlogit(estimatesJohannesIFSlength[1,1])))

metaClutchIFSlength$lower1SE[metaClutchIFSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]-estimatesJohannesIFSlength[2,2])/
(1-invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]-estimatesJohannesIFSlength[2,2]))/
(invlogit(estimatesJohannesIFSlength[1,1])/(1-invlogit(estimatesJohannesIFSlength[1,1])))

metaClutchIFSlength$upper1SE[metaClutchIFSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]+estimatesJohannesIFSlength[2,2])/
(1-invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]+estimatesJohannesIFSlength[2,2]))/
(invlogit(estimatesJohannesIFSlength[1,1])/(1-invlogit(estimatesJohannesIFSlength[1,1])))

metaClutchIFSlength$lower2SE[metaClutchIFSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]-1.96*estimatesJohannesIFSlength[2,2])/
(1-invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]-1.96*estimatesJohannesIFSlength[2,2]))/
(invlogit(estimatesJohannesIFSlength[1,1])/(1-invlogit(estimatesJohannesIFSlength[1,1])))

metaClutchIFSlength$upper2SE[metaClutchIFSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]+1.96*estimatesJohannesIFSlength[2,2])/
(1-invlogit(estimatesJohannesIFSlength[1,1]+estimatesJohannesIFSlength[2,1]+1.96*estimatesJohannesIFSlength[2,2]))/
(invlogit(estimatesJohannesIFSlength[1,1])/(1-invlogit(estimatesJohannesIFSlength[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchIFSlength$logodds <- log10(metaClutchIFSlength$odds)
metaClutchIFSlength$loglower1SE <- log10(metaClutchIFSlength$lower1SE)
metaClutchIFSlength$logupper1SE <- log10(metaClutchIFSlength$upper1SE)
metaClutchIFSlength$SElower <- metaClutchIFSlength$logodds-metaClutchIFSlength$loglower1SE
metaClutchIFSlength$SEupper <- metaClutchIFSlength$logupper1SE-metaClutchIFSlength$logodds
metaClutchIFSlength$meanSE <- (metaClutchIFSlength$SElower+metaClutchIFSlength$SEupper)/2

summarymetaClutchIFSlength  <-meta.summaries(metaClutchIFSlength$logodds, metaClutchIFSlength$meanSE, names=metaClutchIFSlength$study, method="fixed")

# odds
10^-0.0427	#0.9063585
#lower
10^-0.174	#0.6698846
#upper
10^0.089	#1.227439
}


{## metaClutchEPP - Abnormal
metaClutchEPPAbn <- data.frame('study' = c('Sanja', 'Johannes'))

# sanja
metaClutchEPPAbn$odds[metaClutchEPPAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1])/
(1-invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]))/
(invlogit(estimatesSanjaEPPAbn[1,1])/(1-invlogit(estimatesSanjaEPPAbn[1,1])))

metaClutchEPPAbn$lower1SE[metaClutchEPPAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]-estimatesSanjaEPPAbn[2,2])/
(1-invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]-estimatesSanjaEPPAbn[2,2]))/
(invlogit(estimatesSanjaEPPAbn[1,1])/(1-invlogit(estimatesSanjaEPPAbn[1,1])))

metaClutchEPPAbn$upper1SE[metaClutchEPPAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]+estimatesSanjaEPPAbn[2,2])/
(1-invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]+estimatesSanjaEPPAbn[2,2]))/
(invlogit(estimatesSanjaEPPAbn[1,1])/(1-invlogit(estimatesSanjaEPPAbn[1,1])))

metaClutchEPPAbn$lower2SE[metaClutchEPPAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]-1.96*estimatesSanjaEPPAbn[2,2])/
(1-invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]-1.96*estimatesSanjaEPPAbn[2,2]))/
(invlogit(estimatesSanjaEPPAbn[1,1])/(1-invlogit(estimatesSanjaEPPAbn[1,1])))

metaClutchEPPAbn$upper2SE[metaClutchEPPAbn$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]+1.96*estimatesSanjaEPPAbn[2,2])/
(1-invlogit(estimatesSanjaEPPAbn[1,1]+estimatesSanjaEPPAbn[2,1]+1.96*estimatesSanjaEPPAbn[2,2]))/
(invlogit(estimatesSanjaEPPAbn[1,1])/(1-invlogit(estimatesSanjaEPPAbn[1,1])))

# Johannes
metaClutchEPPAbn$odds[metaClutchEPPAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1])/
(1-invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]))/
(invlogit(estimatesJohannesEPPAbn[1,1])/(1-invlogit(estimatesJohannesEPPAbn[1,1])))

metaClutchEPPAbn$lower1SE[metaClutchEPPAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]-estimatesJohannesEPPAbn[2,2])/
(1-invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]-estimatesJohannesEPPAbn[2,2]))/
(invlogit(estimatesJohannesEPPAbn[1,1])/(1-invlogit(estimatesJohannesEPPAbn[1,1])))

metaClutchEPPAbn$upper1SE[metaClutchEPPAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]+estimatesJohannesEPPAbn[2,2])/
(1-invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]+estimatesJohannesEPPAbn[2,2]))/
(invlogit(estimatesJohannesEPPAbn[1,1])/(1-invlogit(estimatesJohannesEPPAbn[1,1])))

metaClutchEPPAbn$lower2SE[metaClutchEPPAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]-1.96*estimatesJohannesEPPAbn[2,2])/
(1-invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]-1.96*estimatesJohannesEPPAbn[2,2]))/
(invlogit(estimatesJohannesEPPAbn[1,1])/(1-invlogit(estimatesJohannesEPPAbn[1,1])))

metaClutchEPPAbn$upper2SE[metaClutchEPPAbn$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]+1.96*estimatesJohannesEPPAbn[2,2])/
(1-invlogit(estimatesJohannesEPPAbn[1,1]+estimatesJohannesEPPAbn[2,1]+1.96*estimatesJohannesEPPAbn[2,2]))/
(invlogit(estimatesJohannesEPPAbn[1,1])/(1-invlogit(estimatesJohannesEPPAbn[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchEPPAbn$logodds <- log10(metaClutchEPPAbn$odds)
metaClutchEPPAbn$loglower1SE <- log10(metaClutchEPPAbn$lower1SE)
metaClutchEPPAbn$logupper1SE <- log10(metaClutchEPPAbn$upper1SE)
metaClutchEPPAbn$SElower <- metaClutchEPPAbn$logodds-metaClutchEPPAbn$loglower1SE
metaClutchEPPAbn$SEupper <- metaClutchEPPAbn$logupper1SE-metaClutchEPPAbn$logodds
metaClutchEPPAbn$meanSE <- (metaClutchEPPAbn$SElower+metaClutchEPPAbn$SEupper)/2

summarymetaClutchEPPAbn  <-meta.summaries(metaClutchEPPAbn$logodds, metaClutchEPPAbn$meanSE, names=metaClutchEPPAbn$study, method="fixed")

# odds
10^0.186	#1.534617
#lower
10^-0.0227	#0.9490738
#upper
10^0.395	#2.483133


}

{## metaClutchEPP - Velocity
metaClutchEPPVelocity <- data.frame('study' = c('Sanja', 'Johannes'))

# sanja
metaClutchEPPVelocity$odds[metaClutchEPPVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1])/
(1-invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]))/
(invlogit(estimatesSanjaEPPVelocity[1,1])/(1-invlogit(estimatesSanjaEPPVelocity[1,1])))

metaClutchEPPVelocity$lower1SE[metaClutchEPPVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]-estimatesSanjaEPPVelocity[2,2])/
(1-invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]-estimatesSanjaEPPVelocity[2,2]))/
(invlogit(estimatesSanjaEPPVelocity[1,1])/(1-invlogit(estimatesSanjaEPPVelocity[1,1])))

metaClutchEPPVelocity$upper1SE[metaClutchEPPVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]+estimatesSanjaEPPVelocity[2,2])/
(1-invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]+estimatesSanjaEPPVelocity[2,2]))/
(invlogit(estimatesSanjaEPPVelocity[1,1])/(1-invlogit(estimatesSanjaEPPVelocity[1,1])))

metaClutchEPPVelocity$lower2SE[metaClutchEPPVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]-1.96*estimatesSanjaEPPVelocity[2,2])/
(1-invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]-1.96*estimatesSanjaEPPVelocity[2,2]))/
(invlogit(estimatesSanjaEPPVelocity[1,1])/(1-invlogit(estimatesSanjaEPPVelocity[1,1])))

metaClutchEPPVelocity$upper2SE[metaClutchEPPVelocity$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]+1.96*estimatesSanjaEPPVelocity[2,2])/
(1-invlogit(estimatesSanjaEPPVelocity[1,1]+estimatesSanjaEPPVelocity[2,1]+1.96*estimatesSanjaEPPVelocity[2,2]))/
(invlogit(estimatesSanjaEPPVelocity[1,1])/(1-invlogit(estimatesSanjaEPPVelocity[1,1])))

# Johannes
metaClutchEPPVelocity$odds[metaClutchEPPVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1])/
(1-invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]))/
(invlogit(estimatesJohannesEPPVelocity[1,1])/(1-invlogit(estimatesJohannesEPPVelocity[1,1])))

metaClutchEPPVelocity$lower1SE[metaClutchEPPVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]-estimatesJohannesEPPVelocity[2,2])/
(1-invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]-estimatesJohannesEPPVelocity[2,2]))/
(invlogit(estimatesJohannesEPPVelocity[1,1])/(1-invlogit(estimatesJohannesEPPVelocity[1,1])))

metaClutchEPPVelocity$upper1SE[metaClutchEPPVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]+estimatesJohannesEPPVelocity[2,2])/
(1-invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]+estimatesJohannesEPPVelocity[2,2]))/
(invlogit(estimatesJohannesEPPVelocity[1,1])/(1-invlogit(estimatesJohannesEPPVelocity[1,1])))

metaClutchEPPVelocity$lower2SE[metaClutchEPPVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]-1.96*estimatesJohannesEPPVelocity[2,2])/
(1-invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]-1.96*estimatesJohannesEPPVelocity[2,2]))/
(invlogit(estimatesJohannesEPPVelocity[1,1])/(1-invlogit(estimatesJohannesEPPVelocity[1,1])))

metaClutchEPPVelocity$upper2SE[metaClutchEPPVelocity$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]+1.96*estimatesJohannesEPPVelocity[2,2])/
(1-invlogit(estimatesJohannesEPPVelocity[1,1]+estimatesJohannesEPPVelocity[2,1]+1.96*estimatesJohannesEPPVelocity[2,2]))/
(invlogit(estimatesJohannesEPPVelocity[1,1])/(1-invlogit(estimatesJohannesEPPVelocity[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchEPPVelocity$logodds <- log10(metaClutchEPPVelocity$odds)
metaClutchEPPVelocity$loglower1SE <- log10(metaClutchEPPVelocity$lower1SE)
metaClutchEPPVelocity$logupper1SE <- log10(metaClutchEPPVelocity$upper1SE)
metaClutchEPPVelocity$SElower <- metaClutchEPPVelocity$logodds-metaClutchEPPVelocity$loglower1SE
metaClutchEPPVelocity$SEupper <- metaClutchEPPVelocity$logupper1SE-metaClutchEPPVelocity$logodds
metaClutchEPPVelocity$meanSE <- (metaClutchEPPVelocity$SElower+metaClutchEPPVelocity$SEupper)/2

summarymetaClutchEPPVelocity  <-meta.summaries(metaClutchEPPVelocity$logodds, metaClutchEPPVelocity$meanSE, names=metaClutchEPPVelocity$study, method="fixed")

# odds
10^-0.312	#0.4875285
#lower
10^-0.57	#0.2691535
#upper
10^-0.0548	#0.8814547



}

{## metaClutchEPP - Slength 

metaClutchEPPSlength <- data.frame('study' = c( 'Sanja', 'Johannes'))

# sanja
metaClutchEPPSlength$odds[metaClutchEPPSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1])/
(1-invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]))/
(invlogit(estimatesSanjaEPPSlength[1,1])/(1-invlogit(estimatesSanjaEPPSlength[1,1])))

metaClutchEPPSlength$lower1SE[metaClutchEPPSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]-estimatesSanjaEPPSlength[2,2])/
(1-invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]-estimatesSanjaEPPSlength[2,2]))/
(invlogit(estimatesSanjaEPPSlength[1,1])/(1-invlogit(estimatesSanjaEPPSlength[1,1])))

metaClutchEPPSlength$upper1SE[metaClutchEPPSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]+estimatesSanjaEPPSlength[2,2])/
(1-invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]+estimatesSanjaEPPSlength[2,2]))/
(invlogit(estimatesSanjaEPPSlength[1,1])/(1-invlogit(estimatesSanjaEPPSlength[1,1])))

metaClutchEPPSlength$lower2SE[metaClutchEPPSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]-1.96*estimatesSanjaEPPSlength[2,2])/
(1-invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]-1.96*estimatesSanjaEPPSlength[2,2]))/
(invlogit(estimatesSanjaEPPSlength[1,1])/(1-invlogit(estimatesSanjaEPPSlength[1,1])))

metaClutchEPPSlength$upper2SE[metaClutchEPPSlength$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]+1.96*estimatesSanjaEPPSlength[2,2])/
(1-invlogit(estimatesSanjaEPPSlength[1,1]+estimatesSanjaEPPSlength[2,1]+1.96*estimatesSanjaEPPSlength[2,2]))/
(invlogit(estimatesSanjaEPPSlength[1,1])/(1-invlogit(estimatesSanjaEPPSlength[1,1])))

# Johannes
metaClutchEPPSlength$odds[metaClutchEPPSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1])/
(1-invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]))/
(invlogit(estimatesJohannesEPPSlength[1,1])/(1-invlogit(estimatesJohannesEPPSlength[1,1])))

metaClutchEPPSlength$lower1SE[metaClutchEPPSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]-estimatesJohannesEPPSlength[2,2])/
(1-invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]-estimatesJohannesEPPSlength[2,2]))/
(invlogit(estimatesJohannesEPPSlength[1,1])/(1-invlogit(estimatesJohannesEPPSlength[1,1])))

metaClutchEPPSlength$upper1SE[metaClutchEPPSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]+estimatesJohannesEPPSlength[2,2])/
(1-invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]+estimatesJohannesEPPSlength[2,2]))/
(invlogit(estimatesJohannesEPPSlength[1,1])/(1-invlogit(estimatesJohannesEPPSlength[1,1])))

metaClutchEPPSlength$lower2SE[metaClutchEPPSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]-1.96*estimatesJohannesEPPSlength[2,2])/
(1-invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]-1.96*estimatesJohannesEPPSlength[2,2]))/
(invlogit(estimatesJohannesEPPSlength[1,1])/(1-invlogit(estimatesJohannesEPPSlength[1,1])))

metaClutchEPPSlength$upper2SE[metaClutchEPPSlength$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]+1.96*estimatesJohannesEPPSlength[2,2])/
(1-invlogit(estimatesJohannesEPPSlength[1,1]+estimatesJohannesEPPSlength[2,1]+1.96*estimatesJohannesEPPSlength[2,2]))/
(invlogit(estimatesJohannesEPPSlength[1,1])/(1-invlogit(estimatesJohannesEPPSlength[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchEPPSlength$logodds <- log10(metaClutchEPPSlength$odds)
metaClutchEPPSlength$loglower1SE <- log10(metaClutchEPPSlength$lower1SE)
metaClutchEPPSlength$logupper1SE <- log10(metaClutchEPPSlength$upper1SE)
metaClutchEPPSlength$SElower <- metaClutchEPPSlength$logodds-metaClutchEPPSlength$loglower1SE
metaClutchEPPSlength$SEupper <- metaClutchEPPSlength$logupper1SE-metaClutchEPPSlength$logodds
metaClutchEPPSlength$meanSE <- (metaClutchEPPSlength$SElower+metaClutchEPPSlength$SEupper)/2

summarymetaClutchEPPSlength  <-meta.summaries(metaClutchEPPSlength$logodds, metaClutchEPPSlength$meanSE, names=metaClutchEPPSlength$study, method="fixed")

# odds
10^-0.0941	#0.805193
#lower
10^-0.478	#0.3326596
#upper
10^0.289	#1.94536
}

	
{## metaSiringSucc - Abnormal 
metaSiringSuccAbn <- data.frame('study' = c('Sanja', 'Johannes'))

metaSiringSuccAbn$est[metaSiringSuccAbn$study == 'Sanja'] <- estimatesSanjaSiringSuccAbn[2,1]
metaSiringSuccAbn$SE[metaSiringSuccAbn$study == 'Sanja'] <- estimatesSanjaSiringSuccAbn[2,2]
metaSiringSuccAbn$lower[metaSiringSuccAbn$study == 'Sanja'] <- estimatesSanjaSiringSuccAbn[2,1]-1.96*estimatesSanjaSiringSuccAbn[2,2]
metaSiringSuccAbn$upper[metaSiringSuccAbn$study == 'Sanja'] <- estimatesSanjaSiringSuccAbn[2,1]+1.96*estimatesSanjaSiringSuccAbn[2,2]


metaSiringSuccAbn$est[metaSiringSuccAbn$study == 'Johannes'] <- estimatesJohannesSiringSuccAbn[2,1]
metaSiringSuccAbn$SE[metaSiringSuccAbn$study == 'Johannes'] <- estimatesJohannesSiringSuccAbn[2,2]
metaSiringSuccAbn$lower[metaSiringSuccAbn$study == 'Johannes'] <- estimatesJohannesSiringSuccAbn[2,1]-1.96*estimatesJohannesSiringSuccAbn[2,2]
metaSiringSuccAbn$upper[metaSiringSuccAbn$study == 'Johannes'] <- estimatesJohannesSiringSuccAbn[2,1]+1.96*estimatesJohannesSiringSuccAbn[2,2]


summarymetaSiringSuccAbn <- meta.summaries(metaSiringSuccAbn$est, metaSiringSuccAbn$SE, names=metaSiringSuccAbn$study, method="fixed")


}

{## metaSiringSucc - Velocity
metaSiringSuccVelocity <- data.frame('study' = c('Sanja', 'Johannes'))

metaSiringSuccVelocity$est[metaSiringSuccVelocity$study == 'Sanja'] <- estimatesSanjaSiringSuccVelocity[2,1]
metaSiringSuccVelocity$SE[metaSiringSuccVelocity$study == 'Sanja'] <- estimatesSanjaSiringSuccVelocity[2,2]
metaSiringSuccVelocity$lower[metaSiringSuccVelocity$study == 'Sanja'] <- estimatesSanjaSiringSuccVelocity[2,1]-1.96*estimatesSanjaSiringSuccVelocity[2,2]
metaSiringSuccVelocity$upper[metaSiringSuccVelocity$study == 'Sanja'] <- estimatesSanjaSiringSuccVelocity[2,1]+1.96*estimatesSanjaSiringSuccVelocity[2,2]

metaSiringSuccVelocity$est[metaSiringSuccVelocity$study == 'Johannes'] <- estimatesJohannesSiringSuccVelocity[2,1]
metaSiringSuccVelocity$SE[metaSiringSuccVelocity$study == 'Johannes'] <- estimatesJohannesSiringSuccVelocity[2,2]
metaSiringSuccVelocity$lower[metaSiringSuccVelocity$study == 'Johannes'] <- estimatesJohannesSiringSuccVelocity[2,1]-1.96*estimatesJohannesSiringSuccVelocity[2,2]
metaSiringSuccVelocity$upper[metaSiringSuccVelocity$study == 'Johannes'] <- estimatesJohannesSiringSuccVelocity[2,1]+1.96*estimatesJohannesSiringSuccVelocity[2,2]

summarymetaSiringSuccVelocity <- meta.summaries(metaSiringSuccVelocity$est, metaSiringSuccVelocity$SE, names=metaSiringSuccVelocity$study, method="fixed")


}

{## metaSiringSucc - Slength 
metaSiringSuccSlength <- data.frame('study' = c('Sanja', 'Johannes'))

metaSiringSuccSlength$est[metaSiringSuccSlength$study == 'Sanja'] <- estimatesSanjaSiringSuccSlength[2,1]
metaSiringSuccSlength$SE[metaSiringSuccSlength$study == 'Sanja'] <- estimatesSanjaSiringSuccSlength[2,2]
metaSiringSuccSlength$lower[metaSiringSuccSlength$study == 'Sanja'] <- estimatesSanjaSiringSuccSlength[2,1]-1.96*estimatesSanjaSiringSuccSlength[2,2]
metaSiringSuccSlength$upper[metaSiringSuccSlength$study == 'Sanja'] <- estimatesSanjaSiringSuccSlength[2,1]+1.96*estimatesSanjaSiringSuccSlength[2,2]

metaSiringSuccSlength$est[metaSiringSuccSlength$study == 'Johannes'] <- estimatesJohannesSiringSuccSlength[2,1]
metaSiringSuccSlength$SE[metaSiringSuccSlength$study == 'Johannes'] <- estimatesJohannesSiringSuccSlength[2,2]
metaSiringSuccSlength$lower[metaSiringSuccSlength$study == 'Johannes'] <- estimatesJohannesSiringSuccSlength[2,1]-1.96*estimatesJohannesSiringSuccSlength[2,2]
metaSiringSuccSlength$upper[metaSiringSuccSlength$study == 'Johannes'] <- estimatesJohannesSiringSuccSlength[2,1]+1.96*estimatesJohannesSiringSuccSlength[2,2]

summarymetaSiringSuccSlength <- meta.summaries(metaSiringSuccSlength$est, metaSiringSuccSlength$SE, names=metaSiringSuccSlength$study, method="fixed")
}


}

{### with InbredYN all 3 datasets  - meta.summaries

{## metaClutchIF - Abnormal
metaClutchIFAbnF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

# malika
metaClutchIFAbnF$odds[metaClutchIFAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1])/
(1-invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]))/
(invlogit(estimatesMalikaIFAbn[1,1])/(1-invlogit(estimatesMalikaIFAbn[1,1])))

metaClutchIFAbnF$lower1SE[metaClutchIFAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]-estimatesMalikaIFAbn[2,2])/
(1-invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]-estimatesMalikaIFAbn[2,2]))/
(invlogit(estimatesMalikaIFAbn[1,1])/(1-invlogit(estimatesMalikaIFAbn[1,1])))

metaClutchIFAbnF$upper1SE[metaClutchIFAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]+estimatesMalikaIFAbn[2,2])/
(1-invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]+estimatesMalikaIFAbn[2,2]))/
(invlogit(estimatesMalikaIFAbn[1,1])/(1-invlogit(estimatesMalikaIFAbn[1,1])))

metaClutchIFAbnF$lower2SE[metaClutchIFAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]-1.96*estimatesMalikaIFAbn[2,2])/
(1-invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]-1.96*estimatesMalikaIFAbn[2,2]))/
(invlogit(estimatesMalikaIFAbn[1,1])/(1-invlogit(estimatesMalikaIFAbn[1,1])))

metaClutchIFAbnF$upper2SE[metaClutchIFAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]+1.96*estimatesMalikaIFAbn[2,2])/
(1-invlogit(estimatesMalikaIFAbn[1,1]+estimatesMalikaIFAbn[2,1]+1.96*estimatesMalikaIFAbn[2,2]))/
(invlogit(estimatesMalikaIFAbn[1,1])/(1-invlogit(estimatesMalikaIFAbn[1,1])))

# sanja
metaClutchIFAbnF$odds[metaClutchIFAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1])/
(1-invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]))/
(invlogit(estimatesSanjaIFAbnF[1,1])/(1-invlogit(estimatesSanjaIFAbnF[1,1])))

metaClutchIFAbnF$lower1SE[metaClutchIFAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]-estimatesSanjaIFAbnF[2,2])/
(1-invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]-estimatesSanjaIFAbnF[2,2]))/
(invlogit(estimatesSanjaIFAbnF[1,1])/(1-invlogit(estimatesSanjaIFAbnF[1,1])))

metaClutchIFAbnF$upper1SE[metaClutchIFAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]+estimatesSanjaIFAbnF[2,2])/
(1-invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]+estimatesSanjaIFAbnF[2,2]))/
(invlogit(estimatesSanjaIFAbnF[1,1])/(1-invlogit(estimatesSanjaIFAbnF[1,1])))

metaClutchIFAbnF$lower2SE[metaClutchIFAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]-1.96*estimatesSanjaIFAbnF[2,2])/
(1-invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]-1.96*estimatesSanjaIFAbnF[2,2]))/
(invlogit(estimatesSanjaIFAbnF[1,1])/(1-invlogit(estimatesSanjaIFAbnF[1,1])))

metaClutchIFAbnF$upper2SE[metaClutchIFAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]+1.96*estimatesSanjaIFAbnF[2,2])/
(1-invlogit(estimatesSanjaIFAbnF[1,1]+estimatesSanjaIFAbnF[2,1]+1.96*estimatesSanjaIFAbnF[2,2]))/
(invlogit(estimatesSanjaIFAbnF[1,1])/(1-invlogit(estimatesSanjaIFAbnF[1,1])))

# Johannes
metaClutchIFAbnF$odds[metaClutchIFAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1])/
(1-invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]))/
(invlogit(estimatesJohannesIFAbnF[1,1])/(1-invlogit(estimatesJohannesIFAbnF[1,1])))

metaClutchIFAbnF$lower1SE[metaClutchIFAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]-estimatesJohannesIFAbnF[2,2])/
(1-invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]-estimatesJohannesIFAbnF[2,2]))/
(invlogit(estimatesJohannesIFAbnF[1,1])/(1-invlogit(estimatesJohannesIFAbnF[1,1])))

metaClutchIFAbnF$upper1SE[metaClutchIFAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]+estimatesJohannesIFAbnF[2,2])/
(1-invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]+estimatesJohannesIFAbnF[2,2]))/
(invlogit(estimatesJohannesIFAbnF[1,1])/(1-invlogit(estimatesJohannesIFAbnF[1,1])))

metaClutchIFAbnF$lower2SE[metaClutchIFAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]-1.96*estimatesJohannesIFAbnF[2,2])/
(1-invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]-1.96*estimatesJohannesIFAbnF[2,2]))/
(invlogit(estimatesJohannesIFAbnF[1,1])/(1-invlogit(estimatesJohannesIFAbnF[1,1])))

metaClutchIFAbnF$upper2SE[metaClutchIFAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]+1.96*estimatesJohannesIFAbnF[2,2])/
(1-invlogit(estimatesJohannesIFAbnF[1,1]+estimatesJohannesIFAbnF[2,1]+1.96*estimatesJohannesIFAbnF[2,2]))/
(invlogit(estimatesJohannesIFAbnF[1,1])/(1-invlogit(estimatesJohannesIFAbnF[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchIFAbnF$logodds <- log10(metaClutchIFAbnF$odds)
metaClutchIFAbnF$loglower1SE <- log10(metaClutchIFAbnF$lower1SE)
metaClutchIFAbnF$logupper1SE <- log10(metaClutchIFAbnF$upper1SE)
metaClutchIFAbnF$SElower <- metaClutchIFAbnF$logodds-metaClutchIFAbnF$loglower1SE
metaClutchIFAbnF$SEupper <- metaClutchIFAbnF$logupper1SE-metaClutchIFAbnF$logodds
metaClutchIFAbnF$meanSE <- (metaClutchIFAbnF$SElower+metaClutchIFAbnF$SEupper)/2

summarymetaClutchIFAbnF  <-meta.summaries(metaClutchIFAbnF$logodds, metaClutchIFAbnF$meanSE, names=metaClutchIFAbnF$study, method="fixed")

# odds
10^0.0565	#1.138938
#lower
10^-0.0958	#0.8020473
#upper
10^0.209	#1.61808


}

{## metaClutchIF - Velocity
metaClutchIFVelocityF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

# malika
metaClutchIFVelocityF$odds[metaClutchIFVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1])/
(1-invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]))/
(invlogit(estimatesMalikaIFVelocity[1,1])/(1-invlogit(estimatesMalikaIFVelocity[1,1])))

metaClutchIFVelocityF$lower1SE[metaClutchIFVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]-estimatesMalikaIFVelocity[2,2])/
(1-invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]-estimatesMalikaIFVelocity[2,2]))/
(invlogit(estimatesMalikaIFVelocity[1,1])/(1-invlogit(estimatesMalikaIFVelocity[1,1])))

metaClutchIFVelocityF$upper1SE[metaClutchIFVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]+estimatesMalikaIFVelocity[2,2])/
(1-invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]+estimatesMalikaIFVelocity[2,2]))/
(invlogit(estimatesMalikaIFVelocity[1,1])/(1-invlogit(estimatesMalikaIFVelocity[1,1])))

metaClutchIFVelocityF$lower2SE[metaClutchIFVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]-1.96*estimatesMalikaIFVelocity[2,2])/
(1-invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]-1.96*estimatesMalikaIFVelocity[2,2]))/
(invlogit(estimatesMalikaIFVelocity[1,1])/(1-invlogit(estimatesMalikaIFVelocity[1,1])))

metaClutchIFVelocityF$upper2SE[metaClutchIFVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]+1.96*estimatesMalikaIFVelocity[2,2])/
(1-invlogit(estimatesMalikaIFVelocity[1,1]+estimatesMalikaIFVelocity[2,1]+1.96*estimatesMalikaIFVelocity[2,2]))/
(invlogit(estimatesMalikaIFVelocity[1,1])/(1-invlogit(estimatesMalikaIFVelocity[1,1])))

# sanja
metaClutchIFVelocityF$odds[metaClutchIFVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1])/
(1-invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]))/
(invlogit(estimatesSanjaIFVelocityF[1,1])/(1-invlogit(estimatesSanjaIFVelocityF[1,1])))

metaClutchIFVelocityF$lower1SE[metaClutchIFVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]-estimatesSanjaIFVelocityF[2,2])/
(1-invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]-estimatesSanjaIFVelocityF[2,2]))/
(invlogit(estimatesSanjaIFVelocityF[1,1])/(1-invlogit(estimatesSanjaIFVelocityF[1,1])))

metaClutchIFVelocityF$upper1SE[metaClutchIFVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]+estimatesSanjaIFVelocityF[2,2])/
(1-invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]+estimatesSanjaIFVelocityF[2,2]))/
(invlogit(estimatesSanjaIFVelocityF[1,1])/(1-invlogit(estimatesSanjaIFVelocityF[1,1])))

metaClutchIFVelocityF$lower2SE[metaClutchIFVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]-1.96*estimatesSanjaIFVelocityF[2,2])/
(1-invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]-1.96*estimatesSanjaIFVelocityF[2,2]))/
(invlogit(estimatesSanjaIFVelocityF[1,1])/(1-invlogit(estimatesSanjaIFVelocityF[1,1])))

metaClutchIFVelocityF$upper2SE[metaClutchIFVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]+1.96*estimatesSanjaIFVelocityF[2,2])/
(1-invlogit(estimatesSanjaIFVelocityF[1,1]+estimatesSanjaIFVelocityF[2,1]+1.96*estimatesSanjaIFVelocityF[2,2]))/
(invlogit(estimatesSanjaIFVelocityF[1,1])/(1-invlogit(estimatesSanjaIFVelocityF[1,1])))

# Johannes
metaClutchIFVelocityF$odds[metaClutchIFVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1])/
(1-invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]))/
(invlogit(estimatesJohannesIFVelocityF[1,1])/(1-invlogit(estimatesJohannesIFVelocityF[1,1])))

metaClutchIFVelocityF$lower1SE[metaClutchIFVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]-estimatesJohannesIFVelocityF[2,2])/
(1-invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]-estimatesJohannesIFVelocityF[2,2]))/
(invlogit(estimatesJohannesIFVelocityF[1,1])/(1-invlogit(estimatesJohannesIFVelocityF[1,1])))

metaClutchIFVelocityF$upper1SE[metaClutchIFVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]+estimatesJohannesIFVelocityF[2,2])/
(1-invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]+estimatesJohannesIFVelocityF[2,2]))/
(invlogit(estimatesJohannesIFVelocityF[1,1])/(1-invlogit(estimatesJohannesIFVelocityF[1,1])))

metaClutchIFVelocityF$lower2SE[metaClutchIFVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]-1.96*estimatesJohannesIFVelocityF[2,2])/
(1-invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]-1.96*estimatesJohannesIFVelocityF[2,2]))/
(invlogit(estimatesJohannesIFVelocityF[1,1])/(1-invlogit(estimatesJohannesIFVelocityF[1,1])))

metaClutchIFVelocityF$upper2SE[metaClutchIFVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]+1.96*estimatesJohannesIFVelocityF[2,2])/
(1-invlogit(estimatesJohannesIFVelocityF[1,1]+estimatesJohannesIFVelocityF[2,1]+1.96*estimatesJohannesIFVelocityF[2,2]))/
(invlogit(estimatesJohannesIFVelocityF[1,1])/(1-invlogit(estimatesJohannesIFVelocityF[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchIFVelocityF$logodds <- log10(metaClutchIFVelocityF$odds)
metaClutchIFVelocityF$loglower1SE <- log10(metaClutchIFVelocityF$lower1SE)
metaClutchIFVelocityF$logupper1SE <- log10(metaClutchIFVelocityF$upper1SE)
metaClutchIFVelocityF$SElower <- metaClutchIFVelocityF$logodds-metaClutchIFVelocityF$loglower1SE
metaClutchIFVelocityF$SEupper <- metaClutchIFVelocityF$logupper1SE-metaClutchIFVelocityF$logodds
metaClutchIFVelocityF$meanSE <- (metaClutchIFVelocityF$SElower+metaClutchIFVelocityF$SEupper)/2

summarymetaClutchIFVelocityF  <-meta.summaries(metaClutchIFVelocityF$logodds, metaClutchIFVelocityF$meanSE, names=metaClutchIFVelocityF$study, method="fixed")

# odds
10^-0.12	#0.7585776
#lower
10^-0.286	#0.5176068
#upper
10^0.0466	#1.113269


}

{## metaClutchIF - Slength
metaClutchIFSlengthF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

# malika
metaClutchIFSlengthF$odds[metaClutchIFSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1])/
(1-invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]))/
(invlogit(estimatesMalikaIFSlength[1,1])/(1-invlogit(estimatesMalikaIFSlength[1,1])))

metaClutchIFSlengthF$lower1SE[metaClutchIFSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]-estimatesMalikaIFSlength[2,2])/
(1-invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]-estimatesMalikaIFSlength[2,2]))/
(invlogit(estimatesMalikaIFSlength[1,1])/(1-invlogit(estimatesMalikaIFSlength[1,1])))

metaClutchIFSlengthF$upper1SE[metaClutchIFSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]+estimatesMalikaIFSlength[2,2])/
(1-invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]+estimatesMalikaIFSlength[2,2]))/
(invlogit(estimatesMalikaIFSlength[1,1])/(1-invlogit(estimatesMalikaIFSlength[1,1])))

metaClutchIFSlengthF$lower2SE[metaClutchIFSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]-1.96*estimatesMalikaIFSlength[2,2])/
(1-invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]-1.96*estimatesMalikaIFSlength[2,2]))/
(invlogit(estimatesMalikaIFSlength[1,1])/(1-invlogit(estimatesMalikaIFSlength[1,1])))

metaClutchIFSlengthF$upper2SE[metaClutchIFSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]+1.96*estimatesMalikaIFSlength[2,2])/
(1-invlogit(estimatesMalikaIFSlength[1,1]+estimatesMalikaIFSlength[2,1]+1.96*estimatesMalikaIFSlength[2,2]))/
(invlogit(estimatesMalikaIFSlength[1,1])/(1-invlogit(estimatesMalikaIFSlength[1,1])))

# sanja
metaClutchIFSlengthF$odds[metaClutchIFSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1])/
(1-invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]))/
(invlogit(estimatesSanjaIFSlengthF[1,1])/(1-invlogit(estimatesSanjaIFSlengthF[1,1])))

metaClutchIFSlengthF$lower1SE[metaClutchIFSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]-estimatesSanjaIFSlengthF[2,2])/
(1-invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]-estimatesSanjaIFSlengthF[2,2]))/
(invlogit(estimatesSanjaIFSlengthF[1,1])/(1-invlogit(estimatesSanjaIFSlengthF[1,1])))

metaClutchIFSlengthF$upper1SE[metaClutchIFSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]+estimatesSanjaIFSlengthF[2,2])/
(1-invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]+estimatesSanjaIFSlengthF[2,2]))/
(invlogit(estimatesSanjaIFSlengthF[1,1])/(1-invlogit(estimatesSanjaIFSlengthF[1,1])))

metaClutchIFSlengthF$lower2SE[metaClutchIFSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]-1.96*estimatesSanjaIFSlengthF[2,2])/
(1-invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]-1.96*estimatesSanjaIFSlengthF[2,2]))/
(invlogit(estimatesSanjaIFSlengthF[1,1])/(1-invlogit(estimatesSanjaIFSlengthF[1,1])))

metaClutchIFSlengthF$upper2SE[metaClutchIFSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]+1.96*estimatesSanjaIFSlengthF[2,2])/
(1-invlogit(estimatesSanjaIFSlengthF[1,1]+estimatesSanjaIFSlengthF[2,1]+1.96*estimatesSanjaIFSlengthF[2,2]))/
(invlogit(estimatesSanjaIFSlengthF[1,1])/(1-invlogit(estimatesSanjaIFSlengthF[1,1])))

# Johannes
metaClutchIFSlengthF$odds[metaClutchIFSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1])/
(1-invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]))/
(invlogit(estimatesJohannesIFSlengthF[1,1])/(1-invlogit(estimatesJohannesIFSlengthF[1,1])))

metaClutchIFSlengthF$lower1SE[metaClutchIFSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]-estimatesJohannesIFSlengthF[2,2])/
(1-invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]-estimatesJohannesIFSlengthF[2,2]))/
(invlogit(estimatesJohannesIFSlengthF[1,1])/(1-invlogit(estimatesJohannesIFSlengthF[1,1])))

metaClutchIFSlengthF$upper1SE[metaClutchIFSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]+estimatesJohannesIFSlengthF[2,2])/
(1-invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]+estimatesJohannesIFSlengthF[2,2]))/
(invlogit(estimatesJohannesIFSlengthF[1,1])/(1-invlogit(estimatesJohannesIFSlengthF[1,1])))

metaClutchIFSlengthF$lower2SE[metaClutchIFSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]-1.96*estimatesJohannesIFSlengthF[2,2])/
(1-invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]-1.96*estimatesJohannesIFSlengthF[2,2]))/
(invlogit(estimatesJohannesIFSlengthF[1,1])/(1-invlogit(estimatesJohannesIFSlengthF[1,1])))

metaClutchIFSlengthF$upper2SE[metaClutchIFSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]+1.96*estimatesJohannesIFSlengthF[2,2])/
(1-invlogit(estimatesJohannesIFSlengthF[1,1]+estimatesJohannesIFSlengthF[2,1]+1.96*estimatesJohannesIFSlengthF[2,2]))/
(invlogit(estimatesJohannesIFSlengthF[1,1])/(1-invlogit(estimatesJohannesIFSlengthF[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchIFSlengthF$logodds <- log10(metaClutchIFSlengthF$odds)
metaClutchIFSlengthF$loglower1SE <- log10(metaClutchIFSlengthF$lower1SE)
metaClutchIFSlengthF$logupper1SE <- log10(metaClutchIFSlengthF$upper1SE)
metaClutchIFSlengthF$SElower <- metaClutchIFSlengthF$logodds-metaClutchIFSlengthF$loglower1SE
metaClutchIFSlengthF$SEupper <- metaClutchIFSlengthF$logupper1SE-metaClutchIFSlengthF$logodds
metaClutchIFSlengthF$meanSE <- (metaClutchIFSlengthF$SElower+metaClutchIFSlengthF$SEupper)/2

summarymetaClutchIFSlengthF  <-meta.summaries(metaClutchIFSlengthF$logodds, metaClutchIFSlengthF$meanSE, names=metaClutchIFSlengthF$study, method="fixed")

# odds
10^-0.0748	#0.8417827
#lower
10^-0.211	#0.6151769
#upper
10^0.0617	#1.152657


}


{## metaClutchEPP - Abnormal
metaClutchEPPAbnF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

# malika
metaClutchEPPAbnF$odds[metaClutchEPPAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1])/
(1-invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]))/
(invlogit(estimatesMalikaEPPAbn[1,1])/(1-invlogit(estimatesMalikaEPPAbn[1,1])))

metaClutchEPPAbnF$lower1SE[metaClutchEPPAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]-estimatesMalikaEPPAbn[2,2])/
(1-invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]-estimatesMalikaEPPAbn[2,2]))/
(invlogit(estimatesMalikaEPPAbn[1,1])/(1-invlogit(estimatesMalikaEPPAbn[1,1])))

metaClutchEPPAbnF$upper1SE[metaClutchEPPAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]+estimatesMalikaEPPAbn[2,2])/
(1-invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]+estimatesMalikaEPPAbn[2,2]))/
(invlogit(estimatesMalikaEPPAbn[1,1])/(1-invlogit(estimatesMalikaEPPAbn[1,1])))

metaClutchEPPAbnF$lower2SE[metaClutchEPPAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]-1.96*estimatesMalikaEPPAbn[2,2])/
(1-invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]-1.96*estimatesMalikaEPPAbn[2,2]))/
(invlogit(estimatesMalikaEPPAbn[1,1])/(1-invlogit(estimatesMalikaEPPAbn[1,1])))

metaClutchEPPAbnF$upper2SE[metaClutchEPPAbnF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]+1.96*estimatesMalikaEPPAbn[2,2])/
(1-invlogit(estimatesMalikaEPPAbn[1,1]+estimatesMalikaEPPAbn[2,1]+1.96*estimatesMalikaEPPAbn[2,2]))/
(invlogit(estimatesMalikaEPPAbn[1,1])/(1-invlogit(estimatesMalikaEPPAbn[1,1])))

# sanja
metaClutchEPPAbnF$odds[metaClutchEPPAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1])/
(1-invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]))/
(invlogit(estimatesSanjaEPPAbnF[1,1])/(1-invlogit(estimatesSanjaEPPAbnF[1,1])))

metaClutchEPPAbnF$lower1SE[metaClutchEPPAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]-estimatesSanjaEPPAbnF[2,2])/
(1-invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]-estimatesSanjaEPPAbnF[2,2]))/
(invlogit(estimatesSanjaEPPAbnF[1,1])/(1-invlogit(estimatesSanjaEPPAbnF[1,1])))

metaClutchEPPAbnF$upper1SE[metaClutchEPPAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]+estimatesSanjaEPPAbnF[2,2])/
(1-invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]+estimatesSanjaEPPAbnF[2,2]))/
(invlogit(estimatesSanjaEPPAbnF[1,1])/(1-invlogit(estimatesSanjaEPPAbnF[1,1])))

metaClutchEPPAbnF$lower2SE[metaClutchEPPAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]-1.96*estimatesSanjaEPPAbnF[2,2])/
(1-invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]-1.96*estimatesSanjaEPPAbnF[2,2]))/
(invlogit(estimatesSanjaEPPAbnF[1,1])/(1-invlogit(estimatesSanjaEPPAbnF[1,1])))

metaClutchEPPAbnF$upper2SE[metaClutchEPPAbnF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]+1.96*estimatesSanjaEPPAbnF[2,2])/
(1-invlogit(estimatesSanjaEPPAbnF[1,1]+estimatesSanjaEPPAbnF[2,1]+1.96*estimatesSanjaEPPAbnF[2,2]))/
(invlogit(estimatesSanjaEPPAbnF[1,1])/(1-invlogit(estimatesSanjaEPPAbnF[1,1])))

# Johannes
metaClutchEPPAbnF$odds[metaClutchEPPAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1])/
(1-invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]))/
(invlogit(estimatesJohannesEPPAbnF[1,1])/(1-invlogit(estimatesJohannesEPPAbnF[1,1])))

metaClutchEPPAbnF$lower1SE[metaClutchEPPAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]-estimatesJohannesEPPAbnF[2,2])/
(1-invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]-estimatesJohannesEPPAbnF[2,2]))/
(invlogit(estimatesJohannesEPPAbnF[1,1])/(1-invlogit(estimatesJohannesEPPAbnF[1,1])))

metaClutchEPPAbnF$upper1SE[metaClutchEPPAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]+estimatesJohannesEPPAbnF[2,2])/
(1-invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]+estimatesJohannesEPPAbnF[2,2]))/
(invlogit(estimatesJohannesEPPAbnF[1,1])/(1-invlogit(estimatesJohannesEPPAbnF[1,1])))

metaClutchEPPAbnF$lower2SE[metaClutchEPPAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]-1.96*estimatesJohannesEPPAbnF[2,2])/
(1-invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]-1.96*estimatesJohannesEPPAbnF[2,2]))/
(invlogit(estimatesJohannesEPPAbnF[1,1])/(1-invlogit(estimatesJohannesEPPAbnF[1,1])))

metaClutchEPPAbnF$upper2SE[metaClutchEPPAbnF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]+1.96*estimatesJohannesEPPAbnF[2,2])/
(1-invlogit(estimatesJohannesEPPAbnF[1,1]+estimatesJohannesEPPAbnF[2,1]+1.96*estimatesJohannesEPPAbnF[2,2]))/
(invlogit(estimatesJohannesEPPAbnF[1,1])/(1-invlogit(estimatesJohannesEPPAbnF[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchEPPAbnF$logodds <- log10(metaClutchEPPAbnF$odds)
metaClutchEPPAbnF$loglower1SE <- log10(metaClutchEPPAbnF$lower1SE)
metaClutchEPPAbnF$logupper1SE <- log10(metaClutchEPPAbnF$upper1SE)
metaClutchEPPAbnF$SElower <- metaClutchEPPAbnF$logodds-metaClutchEPPAbnF$loglower1SE
metaClutchEPPAbnF$SEupper <- metaClutchEPPAbnF$logupper1SE-metaClutchEPPAbnF$logodds
metaClutchEPPAbnF$meanSE <- (metaClutchEPPAbnF$SElower+metaClutchEPPAbnF$SEupper)/2

summarymetaClutchEPPAbnF  <-meta.summaries(metaClutchEPPAbnF$logodds, metaClutchEPPAbnF$meanSE, names=metaClutchEPPAbnF$study, method="fixed")

# odds
10^0.184	#1.527566
#lower
10^-0.0604	#0.8701618
#upper
10^0.429	#2.685344


}

{## metaClutchEPP - Velocity
metaClutchEPPVelocityF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

# malika
metaClutchEPPVelocityF$odds[metaClutchEPPVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1])/
(1-invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]))/
(invlogit(estimatesMalikaEPPVelocity[1,1])/(1-invlogit(estimatesMalikaEPPVelocity[1,1])))

metaClutchEPPVelocityF$lower1SE[metaClutchEPPVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]-estimatesMalikaEPPVelocity[2,2])/
(1-invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]-estimatesMalikaEPPVelocity[2,2]))/
(invlogit(estimatesMalikaEPPVelocity[1,1])/(1-invlogit(estimatesMalikaEPPVelocity[1,1])))

metaClutchEPPVelocityF$upper1SE[metaClutchEPPVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]+estimatesMalikaEPPVelocity[2,2])/
(1-invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]+estimatesMalikaEPPVelocity[2,2]))/
(invlogit(estimatesMalikaEPPVelocity[1,1])/(1-invlogit(estimatesMalikaEPPVelocity[1,1])))

metaClutchEPPVelocityF$lower2SE[metaClutchEPPVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]-1.96*estimatesMalikaEPPVelocity[2,2])/
(1-invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]-1.96*estimatesMalikaEPPVelocity[2,2]))/
(invlogit(estimatesMalikaEPPVelocity[1,1])/(1-invlogit(estimatesMalikaEPPVelocity[1,1])))

metaClutchEPPVelocityF$upper2SE[metaClutchEPPVelocityF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]+1.96*estimatesMalikaEPPVelocity[2,2])/
(1-invlogit(estimatesMalikaEPPVelocity[1,1]+estimatesMalikaEPPVelocity[2,1]+1.96*estimatesMalikaEPPVelocity[2,2]))/
(invlogit(estimatesMalikaEPPVelocity[1,1])/(1-invlogit(estimatesMalikaEPPVelocity[1,1])))

# sanja
metaClutchEPPVelocityF$odds[metaClutchEPPVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1])/
(1-invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]))/
(invlogit(estimatesSanjaEPPVelocityF[1,1])/(1-invlogit(estimatesSanjaEPPVelocityF[1,1])))

metaClutchEPPVelocityF$lower1SE[metaClutchEPPVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]-estimatesSanjaEPPVelocityF[2,2])/
(1-invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]-estimatesSanjaEPPVelocityF[2,2]))/
(invlogit(estimatesSanjaEPPVelocityF[1,1])/(1-invlogit(estimatesSanjaEPPVelocityF[1,1])))

metaClutchEPPVelocityF$upper1SE[metaClutchEPPVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]+estimatesSanjaEPPVelocityF[2,2])/
(1-invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]+estimatesSanjaEPPVelocityF[2,2]))/
(invlogit(estimatesSanjaEPPVelocityF[1,1])/(1-invlogit(estimatesSanjaEPPVelocityF[1,1])))

metaClutchEPPVelocityF$lower2SE[metaClutchEPPVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]-1.96*estimatesSanjaEPPVelocityF[2,2])/
(1-invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]-1.96*estimatesSanjaEPPVelocityF[2,2]))/
(invlogit(estimatesSanjaEPPVelocityF[1,1])/(1-invlogit(estimatesSanjaEPPVelocityF[1,1])))

metaClutchEPPVelocityF$upper2SE[metaClutchEPPVelocityF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]+1.96*estimatesSanjaEPPVelocityF[2,2])/
(1-invlogit(estimatesSanjaEPPVelocityF[1,1]+estimatesSanjaEPPVelocityF[2,1]+1.96*estimatesSanjaEPPVelocityF[2,2]))/
(invlogit(estimatesSanjaEPPVelocityF[1,1])/(1-invlogit(estimatesSanjaEPPVelocityF[1,1])))

# Johannes
metaClutchEPPVelocityF$odds[metaClutchEPPVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1])/
(1-invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]))/
(invlogit(estimatesJohannesEPPVelocityF[1,1])/(1-invlogit(estimatesJohannesEPPVelocityF[1,1])))

metaClutchEPPVelocityF$lower1SE[metaClutchEPPVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]-estimatesJohannesEPPVelocityF[2,2])/
(1-invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]-estimatesJohannesEPPVelocityF[2,2]))/
(invlogit(estimatesJohannesEPPVelocityF[1,1])/(1-invlogit(estimatesJohannesEPPVelocityF[1,1])))

metaClutchEPPVelocityF$upper1SE[metaClutchEPPVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]+estimatesJohannesEPPVelocityF[2,2])/
(1-invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]+estimatesJohannesEPPVelocityF[2,2]))/
(invlogit(estimatesJohannesEPPVelocityF[1,1])/(1-invlogit(estimatesJohannesEPPVelocityF[1,1])))

metaClutchEPPVelocityF$lower2SE[metaClutchEPPVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]-1.96*estimatesJohannesEPPVelocityF[2,2])/
(1-invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]-1.96*estimatesJohannesEPPVelocityF[2,2]))/
(invlogit(estimatesJohannesEPPVelocityF[1,1])/(1-invlogit(estimatesJohannesEPPVelocityF[1,1])))

metaClutchEPPVelocityF$upper2SE[metaClutchEPPVelocityF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]+1.96*estimatesJohannesEPPVelocityF[2,2])/
(1-invlogit(estimatesJohannesEPPVelocityF[1,1]+estimatesJohannesEPPVelocityF[2,1]+1.96*estimatesJohannesEPPVelocityF[2,2]))/
(invlogit(estimatesJohannesEPPVelocityF[1,1])/(1-invlogit(estimatesJohannesEPPVelocityF[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchEPPVelocityF$logodds <- log10(metaClutchEPPVelocityF$odds)
metaClutchEPPVelocityF$loglower1SE <- log10(metaClutchEPPVelocityF$lower1SE)
metaClutchEPPVelocityF$logupper1SE <- log10(metaClutchEPPVelocityF$upper1SE)
metaClutchEPPVelocityF$SElower <- metaClutchEPPVelocityF$logodds-metaClutchEPPVelocityF$loglower1SE
metaClutchEPPVelocityF$SEupper <- metaClutchEPPVelocityF$logupper1SE-metaClutchEPPVelocityF$logodds
metaClutchEPPVelocityF$meanSE <- (metaClutchEPPVelocityF$SElower+metaClutchEPPVelocityF$SEupper)/2

summarymetaClutchEPPVelocityF  <-meta.summaries(metaClutchEPPVelocityF$logodds, metaClutchEPPVelocityF$meanSE, names=metaClutchEPPVelocityF$study, method="fixed")

# odds
10^-0.304	#0.4965923
#lower
10^-0.556	#0.2779713
#upper
10^-0.0512	#0.8887917


}

{## metaClutchEPP - Slength
metaClutchEPPSlengthF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

# malika
metaClutchEPPSlengthF$odds[metaClutchEPPSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1])/
(1-invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]))/
(invlogit(estimatesMalikaEPPSlength[1,1])/(1-invlogit(estimatesMalikaEPPSlength[1,1])))

metaClutchEPPSlengthF$lower1SE[metaClutchEPPSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]-estimatesMalikaEPPSlength[2,2])/
(1-invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]-estimatesMalikaEPPSlength[2,2]))/
(invlogit(estimatesMalikaEPPSlength[1,1])/(1-invlogit(estimatesMalikaEPPSlength[1,1])))

metaClutchEPPSlengthF$upper1SE[metaClutchEPPSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]+estimatesMalikaEPPSlength[2,2])/
(1-invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]+estimatesMalikaEPPSlength[2,2]))/
(invlogit(estimatesMalikaEPPSlength[1,1])/(1-invlogit(estimatesMalikaEPPSlength[1,1])))

metaClutchEPPSlengthF$lower2SE[metaClutchEPPSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]-1.96*estimatesMalikaEPPSlength[2,2])/
(1-invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]-1.96*estimatesMalikaEPPSlength[2,2]))/
(invlogit(estimatesMalikaEPPSlength[1,1])/(1-invlogit(estimatesMalikaEPPSlength[1,1])))

metaClutchEPPSlengthF$upper2SE[metaClutchEPPSlengthF$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]+1.96*estimatesMalikaEPPSlength[2,2])/
(1-invlogit(estimatesMalikaEPPSlength[1,1]+estimatesMalikaEPPSlength[2,1]+1.96*estimatesMalikaEPPSlength[2,2]))/
(invlogit(estimatesMalikaEPPSlength[1,1])/(1-invlogit(estimatesMalikaEPPSlength[1,1])))

# sanja
metaClutchEPPSlengthF$odds[metaClutchEPPSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1])/
(1-invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]))/
(invlogit(estimatesSanjaEPPSlengthF[1,1])/(1-invlogit(estimatesSanjaEPPSlengthF[1,1])))

metaClutchEPPSlengthF$lower1SE[metaClutchEPPSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]-estimatesSanjaEPPSlengthF[2,2])/
(1-invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]-estimatesSanjaEPPSlengthF[2,2]))/
(invlogit(estimatesSanjaEPPSlengthF[1,1])/(1-invlogit(estimatesSanjaEPPSlengthF[1,1])))

metaClutchEPPSlengthF$upper1SE[metaClutchEPPSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]+estimatesSanjaEPPSlengthF[2,2])/
(1-invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]+estimatesSanjaEPPSlengthF[2,2]))/
(invlogit(estimatesSanjaEPPSlengthF[1,1])/(1-invlogit(estimatesSanjaEPPSlengthF[1,1])))

metaClutchEPPSlengthF$lower2SE[metaClutchEPPSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]-1.96*estimatesSanjaEPPSlengthF[2,2])/
(1-invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]-1.96*estimatesSanjaEPPSlengthF[2,2]))/
(invlogit(estimatesSanjaEPPSlengthF[1,1])/(1-invlogit(estimatesSanjaEPPSlengthF[1,1])))

metaClutchEPPSlengthF$upper2SE[metaClutchEPPSlengthF$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]+1.96*estimatesSanjaEPPSlengthF[2,2])/
(1-invlogit(estimatesSanjaEPPSlengthF[1,1]+estimatesSanjaEPPSlengthF[2,1]+1.96*estimatesSanjaEPPSlengthF[2,2]))/
(invlogit(estimatesSanjaEPPSlengthF[1,1])/(1-invlogit(estimatesSanjaEPPSlengthF[1,1])))

# Johannes
metaClutchEPPSlengthF$odds[metaClutchEPPSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1])/
(1-invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]))/
(invlogit(estimatesJohannesEPPSlengthF[1,1])/(1-invlogit(estimatesJohannesEPPSlengthF[1,1])))

metaClutchEPPSlengthF$lower1SE[metaClutchEPPSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]-estimatesJohannesEPPSlengthF[2,2])/
(1-invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]-estimatesJohannesEPPSlengthF[2,2]))/
(invlogit(estimatesJohannesEPPSlengthF[1,1])/(1-invlogit(estimatesJohannesEPPSlengthF[1,1])))

metaClutchEPPSlengthF$upper1SE[metaClutchEPPSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]+estimatesJohannesEPPSlengthF[2,2])/
(1-invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]+estimatesJohannesEPPSlengthF[2,2]))/
(invlogit(estimatesJohannesEPPSlengthF[1,1])/(1-invlogit(estimatesJohannesEPPSlengthF[1,1])))

metaClutchEPPSlengthF$lower2SE[metaClutchEPPSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]-1.96*estimatesJohannesEPPSlengthF[2,2])/
(1-invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]-1.96*estimatesJohannesEPPSlengthF[2,2]))/
(invlogit(estimatesJohannesEPPSlengthF[1,1])/(1-invlogit(estimatesJohannesEPPSlengthF[1,1])))

metaClutchEPPSlengthF$upper2SE[metaClutchEPPSlengthF$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]+1.96*estimatesJohannesEPPSlengthF[2,2])/
(1-invlogit(estimatesJohannesEPPSlengthF[1,1]+estimatesJohannesEPPSlengthF[2,1]+1.96*estimatesJohannesEPPSlengthF[2,2]))/
(invlogit(estimatesJohannesEPPSlengthF[1,1])/(1-invlogit(estimatesJohannesEPPSlengthF[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchEPPSlengthF$logodds <- log10(metaClutchEPPSlengthF$odds)
metaClutchEPPSlengthF$loglower1SE <- log10(metaClutchEPPSlengthF$lower1SE)
metaClutchEPPSlengthF$logupper1SE <- log10(metaClutchEPPSlengthF$upper1SE)
metaClutchEPPSlengthF$SElower <- metaClutchEPPSlengthF$logodds-metaClutchEPPSlengthF$loglower1SE
metaClutchEPPSlengthF$SEupper <- metaClutchEPPSlengthF$logupper1SE-metaClutchEPPSlengthF$logodds
metaClutchEPPSlengthF$meanSE <- (metaClutchEPPSlengthF$SElower+metaClutchEPPSlengthF$SEupper)/2

summarymetaClutchEPPSlengthF  <-meta.summaries(metaClutchEPPSlengthF$logodds, metaClutchEPPSlengthF$meanSE, names=metaClutchEPPSlengthF$study, method="fixed")

# odds
10^-0.127	#0.7464488
#lower
10^-0.555	#0.2786121
#upper
10^0.301	#1.999862


}


{## metaSiringSucc - Abnormal  	
metaSiringSuccAbnF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'), 'est' = c(NA,NA,NA),'SE' = c(NA,NA,NA))

metaSiringSuccAbnF$est[metaSiringSuccAbnF$study == 'Malika'] <- estimatesMalikaSiringSuccAbn[2,1]
metaSiringSuccAbnF$SE[metaSiringSuccAbnF$study == 'Malika'] <- estimatesMalikaSiringSuccAbn[2,2]
metaSiringSuccAbnF$lower[metaSiringSuccAbnF$study == 'Malika'] <- estimatesMalikaSiringSuccAbn[2,1]-1.96*estimatesMalikaSiringSuccAbn[2,2]
metaSiringSuccAbnF$upper[metaSiringSuccAbnF$study == 'Malika'] <- estimatesMalikaSiringSuccAbn[2,1]+1.96*estimatesMalikaSiringSuccAbn[2,2]


metaSiringSuccAbnF$est[metaSiringSuccAbnF$study == 'Sanja'] <- estimatesSanjaSiringSuccAbnF[2,1]
metaSiringSuccAbnF$SE[metaSiringSuccAbnF$study == 'Sanja'] <- estimatesSanjaSiringSuccAbnF[2,2]
metaSiringSuccAbnF$lower[metaSiringSuccAbnF$study == 'Sanja'] <- estimatesSanjaSiringSuccAbnF[2,1]-1.96*estimatesSanjaSiringSuccAbnF[2,2]
metaSiringSuccAbnF$upper[metaSiringSuccAbnF$study == 'Sanja'] <- estimatesSanjaSiringSuccAbnF[2,1]+1.96*estimatesSanjaSiringSuccAbnF[2,2]


metaSiringSuccAbnF$est[metaSiringSuccAbnF$study == 'Johannes'] <- estimatesJohannesSiringSuccAbnF[2,1]
metaSiringSuccAbnF$SE[metaSiringSuccAbnF$study == 'Johannes'] <- estimatesJohannesSiringSuccAbnF[2,2]
metaSiringSuccAbnF$lower[metaSiringSuccAbnF$study == 'Johannes'] <- estimatesJohannesSiringSuccAbnF[2,1]-1.96*estimatesJohannesSiringSuccAbnF[2,2]
metaSiringSuccAbnF$upper[metaSiringSuccAbnF$study == 'Johannes'] <- estimatesJohannesSiringSuccAbnF[2,1]+1.96*estimatesJohannesSiringSuccAbnF[2,2]


summarymetaSiringSuccAbnF <- meta.summaries(metaSiringSuccAbnF$est, metaSiringSuccAbnF$SE, names=metaSiringSuccAbnF$study, method="fixed")



}

{## metaSiringSucc - Velocity
metaSiringSuccVelocityF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'), 'est' = c(NA,NA,NA),'SE' = c(NA,NA,NA))

metaSiringSuccVelocityF$est[metaSiringSuccVelocityF$study == 'Malika'] <- estimatesMalikaSiringSuccVelocity[2,1]
metaSiringSuccVelocityF$SE[metaSiringSuccVelocityF$study == 'Malika'] <- estimatesMalikaSiringSuccVelocity[2,2]
metaSiringSuccVelocityF$lower[metaSiringSuccVelocityF$study == 'Malika'] <- estimatesMalikaSiringSuccVelocity[2,1]-1.96*estimatesMalikaSiringSuccVelocity[2,2]
metaSiringSuccVelocityF$upper[metaSiringSuccVelocityF$study == 'Malika'] <- estimatesMalikaSiringSuccVelocity[2,1]+1.96*estimatesMalikaSiringSuccVelocity[2,2]

metaSiringSuccVelocityF$est[metaSiringSuccVelocityF$study == 'Sanja'] <- estimatesSanjaSiringSuccVelocityF[2,1]
metaSiringSuccVelocityF$SE[metaSiringSuccVelocityF$study == 'Sanja'] <- estimatesSanjaSiringSuccVelocityF[2,2]
metaSiringSuccVelocityF$lower[metaSiringSuccVelocityF$study == 'Sanja'] <- estimatesSanjaSiringSuccVelocityF[2,1]-1.96*estimatesSanjaSiringSuccVelocityF[2,2]
metaSiringSuccVelocityF$upper[metaSiringSuccVelocityF$study == 'Sanja'] <- estimatesSanjaSiringSuccVelocityF[2,1]+1.96*estimatesSanjaSiringSuccVelocityF[2,2]

metaSiringSuccVelocityF$est[metaSiringSuccVelocityF$study == 'Johannes'] <- estimatesJohannesSiringSuccVelocityF[2,1]
metaSiringSuccVelocityF$SE[metaSiringSuccVelocityF$study == 'Johannes'] <- estimatesJohannesSiringSuccVelocityF[2,2]
metaSiringSuccVelocityF$lower[metaSiringSuccVelocityF$study == 'Johannes'] <- estimatesJohannesSiringSuccVelocityF[2,1]-1.96*estimatesJohannesSiringSuccVelocityF[2,2]
metaSiringSuccVelocityF$upper[metaSiringSuccVelocityF$study == 'Johannes'] <- estimatesJohannesSiringSuccVelocityF[2,1]+1.96*estimatesJohannesSiringSuccVelocityF[2,2]

summarymetaSiringSuccVelocityF <- meta.summaries(metaSiringSuccVelocityF$est, metaSiringSuccVelocityF$SE, names=metaSiringSuccVelocityF$study, method="fixed")



}

{## metaSiringSucc - Slength

metaSiringSuccSlengthF <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'), 'est' = c(NA,NA,NA),'SE' = c(NA,NA,NA))

metaSiringSuccSlengthF$est[metaSiringSuccSlengthF$study == 'Malika'] <- estimatesMalikaSiringSuccSlength[2,1]
metaSiringSuccSlengthF$SE[metaSiringSuccSlengthF$study == 'Malika'] <- estimatesMalikaSiringSuccSlength[2,2]
metaSiringSuccSlengthF$lower[metaSiringSuccSlengthF$study == 'Malika'] <- estimatesMalikaSiringSuccSlength[2,1]-1.96*estimatesMalikaSiringSuccSlength[2,2]
metaSiringSuccSlengthF$upper[metaSiringSuccSlengthF$study == 'Malika'] <- estimatesMalikaSiringSuccSlength[2,1]+1.96*estimatesMalikaSiringSuccSlength[2,2]

metaSiringSuccSlengthF$est[metaSiringSuccSlengthF$study == 'Sanja'] <- estimatesSanjaSiringSuccSlengthF[2,1]
metaSiringSuccSlengthF$SE[metaSiringSuccSlengthF$study == 'Sanja'] <- estimatesSanjaSiringSuccSlengthF[2,2]
metaSiringSuccSlengthF$lower[metaSiringSuccSlengthF$study == 'Sanja'] <- estimatesSanjaSiringSuccSlengthF[2,1]-1.96*estimatesSanjaSiringSuccSlengthF[2,2]
metaSiringSuccSlengthF$upper[metaSiringSuccSlengthF$study == 'Sanja'] <- estimatesSanjaSiringSuccSlengthF[2,1]+1.96*estimatesSanjaSiringSuccSlengthF[2,2]

metaSiringSuccSlengthF$est[metaSiringSuccSlengthF$study == 'Johannes'] <- estimatesJohannesSiringSuccSlengthF[2,1]
metaSiringSuccSlengthF$SE[metaSiringSuccSlengthF$study == 'Johannes'] <- estimatesJohannesSiringSuccSlengthF[2,2]
metaSiringSuccSlengthF$lower[metaSiringSuccSlengthF$study == 'Johannes'] <- estimatesJohannesSiringSuccSlengthF[2,1]-1.96*estimatesJohannesSiringSuccSlengthF[2,2]
metaSiringSuccSlengthF$upper[metaSiringSuccSlengthF$study == 'Johannes'] <- estimatesJohannesSiringSuccSlengthF[2,1]+1.96*estimatesJohannesSiringSuccSlengthF[2,2]

summarymetaSiringSuccSlengthF <- meta.summaries(metaSiringSuccSlengthF$est, metaSiringSuccSlengthF$SE, names=metaSiringSuccSlengthF$study, method="fixed")
}


}

}

{#### fitness - poly Slength

{### with InbredYN all 3 datasets  - meta.summaries

{## metaClutchIF - Slength
metaClutchIFSlengthFPoly <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

# malika
metaClutchIFSlengthFPoly$odds[metaClutchIFSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1])/
(1-invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]))/
(invlogit(estimatesMalikaIFSlengthPoly[1,1])/(1-invlogit(estimatesMalikaIFSlengthPoly[1,1])))

metaClutchIFSlengthFPoly$lower1SE[metaClutchIFSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]-estimatesMalikaIFSlengthPoly[3,2])/
(1-invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]-estimatesMalikaIFSlengthPoly[3,2]))/
(invlogit(estimatesMalikaIFSlengthPoly[1,1])/(1-invlogit(estimatesMalikaIFSlengthPoly[1,1])))

metaClutchIFSlengthFPoly$upper1SE[metaClutchIFSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]+estimatesMalikaIFSlengthPoly[3,2])/
(1-invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]+estimatesMalikaIFSlengthPoly[3,2]))/
(invlogit(estimatesMalikaIFSlengthPoly[1,1])/(1-invlogit(estimatesMalikaIFSlengthPoly[1,1])))

metaClutchIFSlengthFPoly$lower2SE[metaClutchIFSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]-1.96*estimatesMalikaIFSlengthPoly[3,2])/
(1-invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]-1.96*estimatesMalikaIFSlengthPoly[3,2]))/
(invlogit(estimatesMalikaIFSlengthPoly[1,1])/(1-invlogit(estimatesMalikaIFSlengthPoly[1,1])))

metaClutchIFSlengthFPoly$upper2SE[metaClutchIFSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]+1.96*estimatesMalikaIFSlengthPoly[3,2])/
(1-invlogit(estimatesMalikaIFSlengthPoly[1,1]+estimatesMalikaIFSlengthPoly[3,1]+1.96*estimatesMalikaIFSlengthPoly[3,2]))/
(invlogit(estimatesMalikaIFSlengthPoly[1,1])/(1-invlogit(estimatesMalikaIFSlengthPoly[1,1])))

# sanja
metaClutchIFSlengthFPoly$odds[metaClutchIFSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1])/
(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]))/
(invlogit(estimatesSanjaIFSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1])))

metaClutchIFSlengthFPoly$lower1SE[metaClutchIFSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]-estimatesSanjaIFSlengthFPoly[3,2])/
(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]-estimatesSanjaIFSlengthFPoly[3,2]))/
(invlogit(estimatesSanjaIFSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1])))

metaClutchIFSlengthFPoly$upper1SE[metaClutchIFSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]+estimatesSanjaIFSlengthFPoly[3,2])/
(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]+estimatesSanjaIFSlengthFPoly[3,2]))/
(invlogit(estimatesSanjaIFSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1])))

metaClutchIFSlengthFPoly$lower2SE[metaClutchIFSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]-1.96*estimatesSanjaIFSlengthFPoly[3,2])/
(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]-1.96*estimatesSanjaIFSlengthFPoly[3,2]))/
(invlogit(estimatesSanjaIFSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1])))

metaClutchIFSlengthFPoly$upper2SE[metaClutchIFSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]+1.96*estimatesSanjaIFSlengthFPoly[3,2])/
(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1]+estimatesSanjaIFSlengthFPoly[3,1]+1.96*estimatesSanjaIFSlengthFPoly[3,2]))/
(invlogit(estimatesSanjaIFSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaIFSlengthFPoly[1,1])))

# Johannes
metaClutchIFSlengthFPoly$odds[metaClutchIFSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1])/
(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]))/
(invlogit(estimatesJohannesIFSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1])))

metaClutchIFSlengthFPoly$lower1SE[metaClutchIFSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]-estimatesJohannesIFSlengthFPoly[3,2])/
(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]-estimatesJohannesIFSlengthFPoly[3,2]))/
(invlogit(estimatesJohannesIFSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1])))

metaClutchIFSlengthFPoly$upper1SE[metaClutchIFSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]+estimatesJohannesIFSlengthFPoly[3,2])/
(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]+estimatesJohannesIFSlengthFPoly[3,2]))/
(invlogit(estimatesJohannesIFSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1])))

metaClutchIFSlengthFPoly$lower2SE[metaClutchIFSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]-1.96*estimatesJohannesIFSlengthFPoly[3,2])/
(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]-1.96*estimatesJohannesIFSlengthFPoly[3,2]))/
(invlogit(estimatesJohannesIFSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1])))

metaClutchIFSlengthFPoly$upper2SE[metaClutchIFSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]+1.96*estimatesJohannesIFSlengthFPoly[3,2])/
(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1]+estimatesJohannesIFSlengthFPoly[3,1]+1.96*estimatesJohannesIFSlengthFPoly[3,2]))/
(invlogit(estimatesJohannesIFSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesIFSlengthFPoly[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchIFSlengthFPoly$logodds <- log10(metaClutchIFSlengthFPoly$odds)
metaClutchIFSlengthFPoly$loglower1SE <- log10(metaClutchIFSlengthFPoly$lower1SE)
metaClutchIFSlengthFPoly$logupper1SE <- log10(metaClutchIFSlengthFPoly$upper1SE)
metaClutchIFSlengthFPoly$SElower <- metaClutchIFSlengthFPoly$logodds-metaClutchIFSlengthFPoly$loglower1SE
metaClutchIFSlengthFPoly$SEupper <- metaClutchIFSlengthFPoly$logupper1SE-metaClutchIFSlengthFPoly$logodds
metaClutchIFSlengthFPoly$meanSE <- (metaClutchIFSlengthFPoly$SElower+metaClutchIFSlengthFPoly$SEupper)/2

summarymetaClutchIFSlengthFPoly  <-meta.summaries(metaClutchIFSlengthFPoly$logodds, metaClutchIFSlengthFPoly$meanSE, names=metaClutchIFSlengthFPoly$study, method="fixed")

# odds
10
#lower
10
#upper
10


}

{## metaClutchEPP - Slength
metaClutchEPPSlengthFPoly <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'))

# malika
metaClutchEPPSlengthFPoly$odds[metaClutchEPPSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1])/
(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]))/
(invlogit(estimatesMalikaEPPSlengthPoly[1,1])/(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1])))

metaClutchEPPSlengthFPoly$lower1SE[metaClutchEPPSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]-estimatesMalikaEPPSlengthPoly[3,2])/
(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]-estimatesMalikaEPPSlengthPoly[3,2]))/
(invlogit(estimatesMalikaEPPSlengthPoly[1,1])/(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1])))

metaClutchEPPSlengthFPoly$upper1SE[metaClutchEPPSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]+estimatesMalikaEPPSlengthPoly[3,2])/
(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]+estimatesMalikaEPPSlengthPoly[3,2]))/
(invlogit(estimatesMalikaEPPSlengthPoly[1,1])/(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1])))

metaClutchEPPSlengthFPoly$lower2SE[metaClutchEPPSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]-1.96*estimatesMalikaEPPSlengthPoly[3,2])/
(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]-1.96*estimatesMalikaEPPSlengthPoly[3,2]))/
(invlogit(estimatesMalikaEPPSlengthPoly[1,1])/(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1])))

metaClutchEPPSlengthFPoly$upper2SE[metaClutchEPPSlengthFPoly$study == 'Malika'] <- 
invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]+1.96*estimatesMalikaEPPSlengthPoly[3,2])/
(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1]+estimatesMalikaEPPSlengthPoly[3,1]+1.96*estimatesMalikaEPPSlengthPoly[3,2]))/
(invlogit(estimatesMalikaEPPSlengthPoly[1,1])/(1-invlogit(estimatesMalikaEPPSlengthPoly[1,1])))

# sanja
metaClutchEPPSlengthFPoly$odds[metaClutchEPPSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1])/
(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]))/
(invlogit(estimatesSanjaEPPSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1])))

metaClutchEPPSlengthFPoly$lower1SE[metaClutchEPPSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]-estimatesSanjaEPPSlengthFPoly[3,2])/
(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]-estimatesSanjaEPPSlengthFPoly[3,2]))/
(invlogit(estimatesSanjaEPPSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1])))

metaClutchEPPSlengthFPoly$upper1SE[metaClutchEPPSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]+estimatesSanjaEPPSlengthFPoly[3,2])/
(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]+estimatesSanjaEPPSlengthFPoly[3,2]))/
(invlogit(estimatesSanjaEPPSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1])))

metaClutchEPPSlengthFPoly$lower2SE[metaClutchEPPSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]-1.96*estimatesSanjaEPPSlengthFPoly[3,2])/
(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]-1.96*estimatesSanjaEPPSlengthFPoly[3,2]))/
(invlogit(estimatesSanjaEPPSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1])))

metaClutchEPPSlengthFPoly$upper2SE[metaClutchEPPSlengthFPoly$study == 'Sanja'] <- 
invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]+1.96*estimatesSanjaEPPSlengthFPoly[3,2])/
(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1]+estimatesSanjaEPPSlengthFPoly[3,1]+1.96*estimatesSanjaEPPSlengthFPoly[3,2]))/
(invlogit(estimatesSanjaEPPSlengthFPoly[1,1])/(1-invlogit(estimatesSanjaEPPSlengthFPoly[1,1])))

# Johannes
metaClutchEPPSlengthFPoly$odds[metaClutchEPPSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1])/
(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]))/
(invlogit(estimatesJohannesEPPSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1])))

metaClutchEPPSlengthFPoly$lower1SE[metaClutchEPPSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]-estimatesJohannesEPPSlengthFPoly[3,2])/
(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]-estimatesJohannesEPPSlengthFPoly[3,2]))/
(invlogit(estimatesJohannesEPPSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1])))

metaClutchEPPSlengthFPoly$upper1SE[metaClutchEPPSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]+estimatesJohannesEPPSlengthFPoly[3,2])/
(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]+estimatesJohannesEPPSlengthFPoly[3,2]))/
(invlogit(estimatesJohannesEPPSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1])))

metaClutchEPPSlengthFPoly$lower2SE[metaClutchEPPSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]-1.96*estimatesJohannesEPPSlengthFPoly[3,2])/
(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]-1.96*estimatesJohannesEPPSlengthFPoly[3,2]))/
(invlogit(estimatesJohannesEPPSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1])))

metaClutchEPPSlengthFPoly$upper2SE[metaClutchEPPSlengthFPoly$study == 'Johannes'] <- 
invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]+1.96*estimatesJohannesEPPSlengthFPoly[3,2])/
(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1]+estimatesJohannesEPPSlengthFPoly[3,1]+1.96*estimatesJohannesEPPSlengthFPoly[3,2]))/
(invlogit(estimatesJohannesEPPSlengthFPoly[1,1])/(1-invlogit(estimatesJohannesEPPSlengthFPoly[1,1])))



# odds or proba > need log transformation to be 'normal'
metaClutchEPPSlengthFPoly$logodds <- log10(metaClutchEPPSlengthFPoly$odds)
metaClutchEPPSlengthFPoly$loglower1SE <- log10(metaClutchEPPSlengthFPoly$lower1SE)
metaClutchEPPSlengthFPoly$logupper1SE <- log10(metaClutchEPPSlengthFPoly$upper1SE)
metaClutchEPPSlengthFPoly$SElower <- metaClutchEPPSlengthFPoly$logodds-metaClutchEPPSlengthFPoly$loglower1SE
metaClutchEPPSlengthFPoly$SEupper <- metaClutchEPPSlengthFPoly$logupper1SE-metaClutchEPPSlengthFPoly$logodds
metaClutchEPPSlengthFPoly$meanSE <- (metaClutchEPPSlengthFPoly$SElower+metaClutchEPPSlengthFPoly$SEupper)/2

summarymetaClutchEPPSlengthFPoly  <-meta.summaries(metaClutchEPPSlengthFPoly$logodds, metaClutchEPPSlengthFPoly$meanSE, names=metaClutchEPPSlengthFPoly$study, method="fixed")

# odds
10
#lower
10
#upper
10


}

{## metaSiringSucc - Slength

metaSiringSuccSlengthFPoly <- data.frame('study' = c('Malika', 'Sanja', 'Johannes'), 'est' = c(NA,NA,NA),'SE' = c(NA,NA,NA))

metaSiringSuccSlengthFPoly$est[metaSiringSuccSlengthFPoly$study == 'Malika'] <- estimatesMalikaSiringSuccSlengthPoly[3,1]
metaSiringSuccSlengthFPoly$SE[metaSiringSuccSlengthFPoly$study == 'Malika'] <- estimatesMalikaSiringSuccSlengthPoly[3,2]
metaSiringSuccSlengthFPoly$lower[metaSiringSuccSlengthFPoly$study == 'Malika'] <- estimatesMalikaSiringSuccSlengthPoly[3,1]-1.96*estimatesMalikaSiringSuccSlengthPoly[3,2]
metaSiringSuccSlengthFPoly$upper[metaSiringSuccSlengthFPoly$study == 'Malika'] <- estimatesMalikaSiringSuccSlengthPoly[3,1]+1.96*estimatesMalikaSiringSuccSlengthPoly[3,2]

metaSiringSuccSlengthFPoly$est[metaSiringSuccSlengthFPoly$study == 'Sanja'] <- estimatesSanjaSiringSuccSlengthFPoly[3,1]
metaSiringSuccSlengthFPoly$SE[metaSiringSuccSlengthFPoly$study == 'Sanja'] <- estimatesSanjaSiringSuccSlengthFPoly[3,2]
metaSiringSuccSlengthFPoly$lower[metaSiringSuccSlengthFPoly$study == 'Sanja'] <- estimatesSanjaSiringSuccSlengthFPoly[3,1]-1.96*estimatesSanjaSiringSuccSlengthFPoly[3,2]
metaSiringSuccSlengthFPoly$upper[metaSiringSuccSlengthFPoly$study == 'Sanja'] <- estimatesSanjaSiringSuccSlengthFPoly[3,1]+1.96*estimatesSanjaSiringSuccSlengthFPoly[3,2]

metaSiringSuccSlengthFPoly$est[metaSiringSuccSlengthFPoly$study == 'Johannes'] <- estimatesJohannesSiringSuccSlengthFPoly[3,1]
metaSiringSuccSlengthFPoly$SE[metaSiringSuccSlengthFPoly$study == 'Johannes'] <- estimatesJohannesSiringSuccSlengthFPoly[3,2]
metaSiringSuccSlengthFPoly$lower[metaSiringSuccSlengthFPoly$study == 'Johannes'] <- estimatesJohannesSiringSuccSlengthFPoly[3,1]-1.96*estimatesJohannesSiringSuccSlengthFPoly[3,2]
metaSiringSuccSlengthFPoly$upper[metaSiringSuccSlengthFPoly$study == 'Johannes'] <- estimatesJohannesSiringSuccSlengthFPoly[3,1]+1.96*estimatesJohannesSiringSuccSlengthFPoly[3,2]

summarymetaSiringSuccSlengthFPoly <- meta.summaries(metaSiringSuccSlengthFPoly$est, metaSiringSuccSlengthFPoly$SE, names=metaSiringSuccSlengthFPoly$study, method="fixed")

# without sanja (crasy model output)
subsetmetaSiringSuccSlengthFPoly <- metaSiringSuccSlengthFPoly[metaSiringSuccSlengthFPoly$study != 'Sanja',]
summarysubsetmetaSiringSuccSlengthFPoly <- meta.summaries(subsetmetaSiringSuccSlengthFPoly$est, subsetmetaSiringSuccSlengthFPoly$SE, names=subsetmetaSiringSuccSlengthFPoly$study, method="fixed")



}

}

}





	############################
	#### Meta-analyses PLOTS ###
	############################

{### GRAPH phenotype - sperm trait 

# with Abnormal sperm
{dev.new(width=8, heigth =10)
mat <- matrix(c(0,0,0,0,0,1,2,3,0,4,5,6,0,7,8,9,0,0,0,0), nrow=5, ncol=4, byrow=T)
layout(mat, widths = c(1,2,2,2),
       heights = c(0.1,1,1,1,0.2))

par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(-0.29,10,-0.29,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Courtship rate",at=0, side = 3, line = 1, cex=1, font=2)
# without F in the model
arrows(metaDisplayAbn$lower[metaDisplayAbn$study == 'Johannes'],5.85,
metaDisplayAbn$upper[metaDisplayAbn$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaDisplayAbn$est[metaDisplayAbn$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesDisplayAbn)*0.3, col='grey', bg='white')
arrows(metaDisplayAbn$lower[metaDisplayAbn$study == 'Sanja'],3.7,
metaDisplayAbn$upper[metaDisplayAbn$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaDisplayAbn$est[metaDisplayAbn$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaDisplayAbn)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaDisplayAbn$summary -summarymetaDisplayAbn$se.summary*1.96,
			 summarymetaDisplayAbn$summary,
			 summarymetaDisplayAbn$summary+summarymetaDisplayAbn$se.summary*1.96,
			 summarymetaDisplayAbn$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3),border='grey')
# with F in the model
points(x= metaDisplayAbnF$est[metaDisplayAbnF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaDisplayAbn)*0.3)
arrows(metaDisplayAbnF$lower[metaDisplayAbnF$study == 'Malika'],7.6,
metaDisplayAbnF$upper[metaDisplayAbnF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaDisplayAbnF$est[metaDisplayAbnF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesDisplayAbn)*0.3)
arrows(metaDisplayAbnF$lower[metaDisplayAbnF$study == 'Johannes'],5.05,
metaDisplayAbnF$upper[metaDisplayAbnF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaDisplayAbnF$est[metaDisplayAbnF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaDisplayAbn)*0.3)
arrows(metaDisplayAbnF$lower[metaDisplayAbnF$study == 'Sanja'],2.9,
metaDisplayAbnF$upper[metaDisplayAbnF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaDisplayAbnF$summary -summarymetaDisplayAbnF$se.summary*1.96,
			 summarymetaDisplayAbnF$summary,
			 summarymetaDisplayAbnF$summary+summarymetaDisplayAbnF$se.summary*1.96,
			 summarymetaDisplayAbnF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')


		
mtext(side = 2, at=0.95,'Abnormal sperm    ', cex=1, font=2, adj=1, las=2)
mtext(side = 2, at=3.6,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=3,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.75,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.15,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.9,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.3,'(outbreds)    ',  adj=1, las=2, cex=0.8)		




par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n", xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(-0.26,10,-0.26,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Beak Color",at=0, side = 3, line = 1, cex=1, font=2)
# without F in model
arrows(metaBeakColorMunselAbn$lower[metaBeakColorMunselAbn$study == 'Johannes'],5.85,
metaBeakColorMunselAbn$upper[metaBeakColorMunselAbn$study == 'Johannes'],5.85, length=0, col='grey', lwd=1)
points(x= metaBeakColorMunselAbn$est[metaBeakColorMunselAbn$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesBeakMunselAbn)*0.3, col='grey',bg='white')
arrows(metaBeakColorMunselAbn$lower[metaBeakColorMunselAbn$study == 'Sanja'],3.7,
metaBeakColorMunselAbn$upper[metaBeakColorMunselAbn$study == 'Sanja'],3.7, length=0, col ="grey", lwd=1)
points(x= metaBeakColorMunselAbn$est[metaBeakColorMunselAbn$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaBeakMunselAbn)*0.3, col='grey',bg='white')
polygon(x= c(summarymetaBeakColorMunselAbn$summary -summarymetaBeakColorMunselAbn$se.summary*1.96,
			 summarymetaBeakColorMunselAbn$summary,
			 summarymetaBeakColorMunselAbn$summary+summarymetaBeakColorMunselAbn$se.summary*1.96,
			 summarymetaBeakColorMunselAbn$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in model
points(x= metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaBeakAbn)*0.3)
arrows(metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Malika'],7.6,
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesBeakMunselAbn)*0.3)
arrows(metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Johannes'],5.05,
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Sanja'], y=2.9, pch=19, cex=sqrt(NSanjaBeakMunselAbn)*0.3)
arrows(metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Sanja'],2.9,
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaBeakColorMunselAbnF$summary -summarymetaBeakColorMunselAbnF$se.summary*1.96,
			 summarymetaBeakColorMunselAbnF$summary,
			 summarymetaBeakColorMunselAbnF$summary+summarymetaBeakColorMunselAbnF$se.summary*1.96,
			 summarymetaBeakColorMunselAbnF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')

		

par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n", xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(-0.23,10,-0.23,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Tarsus length",at=0, side = 3, line = 1, cex=1, font=2)
# without F in model
arrows(metaTarsusAbn$lower[metaTarsusAbn$study == 'Johannes'],5.85,
metaTarsusAbn$upper[metaTarsusAbn$study == 'Johannes'],5.85, length=0, col='grey', lwd=1)
points(x= metaTarsusAbn$est[metaTarsusAbn$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesTarsusAbn)*0.3, col='grey',bg='white')
arrows(metaTarsusAbn$lower[metaTarsusAbn$study == 'Sanja'],3.7,
metaTarsusAbn$upper[metaTarsusAbn$study == 'Sanja'],3.7, length=0, col ="grey", lwd=1)
points(x= metaTarsusAbn$est[metaTarsusAbn$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaTarsusAbn)*0.3, col='grey',bg='white')
polygon(x= c(summarymetaTarsusAbn$summary -summarymetaTarsusAbn$se.summary*1.96,
			 summarymetaTarsusAbn$summary,
			 summarymetaTarsusAbn$summary+summarymetaTarsusAbn$se.summary*1.96,
			 summarymetaTarsusAbn$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in model
points(x= metaTarsusAbnF$est[metaTarsusAbnF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaTarsusAbn)*0.3)
arrows(metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Malika'],7.6,
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaTarsusAbnF$est[metaTarsusAbnF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesTarsusAbn)*0.3)
arrows(metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Johannes'],5.05,
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaTarsusAbnF$est[metaTarsusAbnF$study == 'Sanja'], y=2.9, pch=19, cex=sqrt(NSanjaTarsusAbn)*0.3)
arrows(metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Sanja'],2.9,
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaTarsusAbnF$summary -summarymetaTarsusAbnF$se.summary*1.96,
			 summarymetaTarsusAbnF$summary,
			 summarymetaTarsusAbnF$summary+summarymetaTarsusAbnF$se.summary*1.96,
			 summarymetaTarsusAbnF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')



par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.18,10,0.18,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
# without F in the model
arrows(metaDisplayVelocity$lower[metaDisplayVelocity$study == 'Johannes'],5.85,
metaDisplayVelocity$upper[metaDisplayVelocity$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaDisplayVelocity$est[metaDisplayVelocity$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesDisplayVelocity)*0.3, col='grey', bg='white')
arrows(metaDisplayVelocity$lower[metaDisplayVelocity$study == 'Sanja'],3.7,
metaDisplayVelocity$upper[metaDisplayVelocity$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaDisplayVelocity$est[metaDisplayVelocity$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaDisplayVelocity)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaDisplayVelocity$summary -summarymetaDisplayVelocity$se.summary*1.96,
			 summarymetaDisplayVelocity$summary,
			 summarymetaDisplayVelocity$summary+summarymetaDisplayVelocity$se.summary*1.96,
			 summarymetaDisplayVelocity$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3),border='grey')
# with F in the model
points(x= metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaDisplayVelocity)*0.3)
arrows(metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Malika'],7.6,
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesDisplayVelocity)*0.3)
arrows(metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Johannes'],5.05,
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaDisplayVelocity)*0.3)
arrows(metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Sanja'],2.9,
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaDisplayVelocityF$summary -summarymetaDisplayVelocityF$se.summary*1.96,
			 summarymetaDisplayVelocityF$summary,
			 summarymetaDisplayVelocityF$summary+summarymetaDisplayVelocityF$se.summary*1.96,
			 summarymetaDisplayVelocityF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')

		

mtext(side = 2, at=0.95,'Sperm velocity    ', cex=1, font=2, adj=1, las=2)
mtext(side = 2, at=3.6,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=3,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.75,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.15,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.9,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.3,'(outbreds)    ',  adj=1, las=2, cex=0.8)		
	
	
	


		
par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.16,10,0.16,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
# without F in the model
arrows(metaBeakColorMunselVCL$lower[metaBeakColorMunselVCL$study == 'Johannes'],5.85,
metaBeakColorMunselVCL$upper[metaBeakColorMunselVCL$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaBeakColorMunselVCL$est[metaBeakColorMunselVCL$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesBeakMunselVCL)*0.3,col = "grey",bg='white')
arrows(metaBeakColorMunselVCL$lower[metaBeakColorMunselVCL$study == 'Sanja'],3.7,
metaBeakColorMunselVCL$upper[metaBeakColorMunselVCL$study == 'Sanja'],3.7, length=0, col = "grey",lwd=1)
points(x= metaBeakColorMunselVCL$est[metaBeakColorMunselVCL$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaBeakMunselVelocity)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaBeakColorMunselVCL$summary -summarymetaBeakColorMunselVCL$se.summary*1.96,
			 summarymetaBeakColorMunselVCL$summary,
			 summarymetaBeakColorMunselVCL$summary+summarymetaBeakColorMunselVCL$se.summary*1.96,
			 summarymetaBeakColorMunselVCL$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(x= metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaBeakVCL)*0.3)
arrows(metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Malika'],7.6,
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesBeakMunselVCL)*0.3)
arrows(metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Johannes'],5.05,
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaBeakMunselVelocity)*0.3)
arrows(metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Sanja'],2.9,
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaBeakColorMunselVCLF$summary -summarymetaBeakColorMunselVCLF$se.summary*1.96,
			 summarymetaBeakColorMunselVCLF$summary,
			 summarymetaBeakColorMunselVCLF$summary+summarymetaBeakColorMunselVCLF$se.summary*1.96,
			 summarymetaBeakColorMunselVCLF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')
	
		
		
par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.14,10,0.14,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
# without F in the model
arrows(metaTarsusVCL$lower[metaTarsusVCL$study == 'Johannes'],5.85,
metaTarsusVCL$upper[metaTarsusVCL$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaTarsusVCL$est[metaTarsusVCL$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesTarsusVCL)*0.3,col = "grey",bg='white')
arrows(metaTarsusVCL$lower[metaTarsusVCL$study == 'Sanja'],3.7,
metaTarsusVCL$upper[metaTarsusVCL$study == 'Sanja'],3.7, length=0, col = "grey",lwd=1)
points(x= metaTarsusVCL$est[metaTarsusVCL$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaTarsusVelocity)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaTarsusVCL$summary -summarymetaTarsusVCL$se.summary*1.96,
			 summarymetaTarsusVCL$summary,
			 summarymetaTarsusVCL$summary+summarymetaTarsusVCL$se.summary*1.96,
			 summarymetaTarsusVCL$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(x= metaTarsusVCLF$est[metaTarsusVCLF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaTarsusVCL)*0.3)
arrows(metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Malika'],7.6,
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaTarsusVCLF$est[metaTarsusVCLF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesTarsusVCL)*0.3)
arrows(metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Johannes'],5.05,
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaTarsusVCLF$est[metaTarsusVCLF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaTarsusVelocity)*0.3)
arrows(metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Sanja'],2.9,
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaTarsusVCLF$summary -summarymetaTarsusVCLF$se.summary*1.96,
			 summarymetaTarsusVCLF$summary,
			 summarymetaTarsusVCLF$summary+summarymetaTarsusVCLF$se.summary*1.96,
			 summarymetaTarsusVCLF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')



par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.14,10,0.14,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext(c(-1,-0.5,0,0.5,1), at = c(-1,-0.5,0,0.5,1), side = 1, line = 0.5, cex=0.8)
#without F in the model
arrows(metaDisplaySlength$lower[metaDisplaySlength$study == 'Johannes'],5.85,
metaDisplaySlength$upper[metaDisplaySlength$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaDisplaySlength$est[metaDisplaySlength$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesDisplaySlength)*0.3, col='grey', bg='white')
arrows(metaDisplaySlength$lower[metaDisplaySlength$study == 'Sanja'],3.7,
metaDisplaySlength$upper[metaDisplaySlength$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaDisplaySlength$est[metaDisplaySlength$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaDisplaySlength)*0.3,col='grey', bg='white')
polygon(x= c(summarymetaDisplaySlength$summary -summarymetaDisplaySlength$se.summary*1.96,
			 summarymetaDisplaySlength$summary,
			 summarymetaDisplaySlength$summary+summarymetaDisplaySlength$se.summary*1.96,
			 summarymetaDisplaySlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3),border='grey')
# with F in the model
points(x= metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaDisplaySlength)*0.3)
arrows(metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Malika'],7.6,
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesDisplaySlength)*0.3)
arrows(metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Johannes'],5.05,
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaDisplaySlength)*0.3)
arrows(metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Sanja'],2.9,
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaDisplaySlengthF$summary -summarymetaDisplaySlengthF$se.summary*1.96,
			 summarymetaDisplaySlengthF$summary,
			 summarymetaDisplaySlengthF$summary+summarymetaDisplaySlengthF$se.summary*1.96,
			 summarymetaDisplaySlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')

	
mtext(side = 2, at=0.95,'Sperm length    ', cex=1, font=2, adj=1, las=2)
mtext(side = 2, at=3.6,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=3,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.75,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.15,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.9,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.3,'(outbreds)    ',  adj=1, las=2, cex=0.8)		

	
	

par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.12,10,0.12,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext(c(-1,-0.5,0,0.5,1), at = c(-1,-0.5,0,0.5,1), side = 1, line = 0.5, cex=0.8)
# without F in the model
arrows(metaBeakColorMunselSlength$lower[metaBeakColorMunselSlength$study == 'Johannes'],5.85,
metaBeakColorMunselSlength$upper[metaBeakColorMunselSlength$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaBeakColorMunselSlength$est[metaBeakColorMunselSlength$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesBeakMunselSlength)*0.3, col='grey', bg='white')
arrows(metaBeakColorMunselSlength$lower[metaBeakColorMunselSlength$study == 'Sanja'],3.7,
metaBeakColorMunselSlength$upper[metaBeakColorMunselSlength$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaBeakColorMunselSlength$est[metaBeakColorMunselSlength$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaBeakMunselSlength)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaBeakColorMunselSlength$summary -summarymetaBeakColorMunselSlength$se.summary*1.96,
			 summarymetaBeakColorMunselSlength$summary,
			 summarymetaBeakColorMunselSlength$summary+summarymetaBeakColorMunselSlength$se.summary*1.96,
			 summarymetaBeakColorMunselSlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
		# with F in the model
points(x= metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaBeakSlength)*0.3)
arrows(metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Malika'],7.6,
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesBeakMunselSlength)*0.3)
arrows(metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Johannes'],5.05,
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaBeakMunselSlength)*0.3)
arrows(metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Sanja'],2.9,
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaBeakColorMunselSlengthF$summary -summarymetaBeakColorMunselSlengthF$se.summary*1.96,
			 summarymetaBeakColorMunselSlengthF$summary,
			 summarymetaBeakColorMunselSlengthF$summary+summarymetaBeakColorMunselSlengthF$se.summary*1.96,
			 summarymetaBeakColorMunselSlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')

		


		
mtext("Correlation coefficient (  )",at=0, side = 1, line = 2.5, cex=1, font=2)
mtext("r",at=0.65, side = 1, line = 2.5, cex=1, font=4)
		


par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.11,10,0.11,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext(c(-1,-0.5,0,0.5,1), at = c(-1,-0.5,0,0.5,1), side = 1, line = 0.5, cex=0.8)
# without F in the model
arrows(metaTarsusSlength$lower[metaTarsusSlength$study == 'Johannes'],5.85,
metaTarsusSlength$upper[metaTarsusSlength$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaTarsusSlength$est[metaTarsusSlength$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesTarsusSlength)*0.3, col='grey', bg='white')
arrows(metaTarsusSlength$lower[metaTarsusSlength$study == 'Sanja'],3.7,
metaTarsusSlength$upper[metaTarsusSlength$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaTarsusSlength$est[metaTarsusSlength$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaTarsusSlength)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaTarsusSlength$summary -summarymetaTarsusSlength$se.summary*1.96,
			 summarymetaTarsusSlength$summary,
			 summarymetaTarsusSlength$summary+summarymetaTarsusSlength$se.summary*1.96,
			 summarymetaTarsusSlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
		# with F in the model
points(x= metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaTarsusSlength)*0.3)
arrows(metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Malika'],7.6,
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesTarsusSlength)*0.3)
arrows(metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Johannes'],5.05,
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaTarsusSlength)*0.3)
arrows(metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Sanja'],2.9,
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaTarsusSlengthF$summary -summarymetaTarsusSlengthF$se.summary*1.96,
			 summarymetaTarsusSlengthF$summary,
			 summarymetaTarsusSlengthF$summary+summarymetaTarsusSlengthF$se.summary*1.96,
			 summarymetaTarsusSlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')		
		
}


# with Functional sperm
{dev.new(width=8, heigth =10)
mat <- matrix(c(0,0,0,0,0,1,2,3,0,4,5,6,0,7,8,9,0,0,0,0), nrow=5, ncol=4, byrow=T)
layout(mat, widths = c(1,2,2,2),
       heights = c(0.1,1,1,1,0.2))

par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.29,10,0.29,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Courtship rate",at=0, side = 3, line = 1, cex=1, font=2)
# without F in the model
arrows(metaDisplayAbnREV$lower[metaDisplayAbnREV$study == 'Johannes'],5.85,
metaDisplayAbnREV$upper[metaDisplayAbnREV$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaDisplayAbnREV$est[metaDisplayAbnREV$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesDisplayAbn)*0.3, col='grey', bg='white')
arrows(metaDisplayAbnREV$lower[metaDisplayAbnREV$study == 'Sanja'],3.7,
metaDisplayAbnREV$upper[metaDisplayAbnREV$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaDisplayAbnREV$est[metaDisplayAbnREV$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaDisplayAbn)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaDisplayAbnREV$summary -summarymetaDisplayAbnREV$se.summary*1.96,
			 summarymetaDisplayAbnREV$summary,
			 summarymetaDisplayAbnREV$summary+summarymetaDisplayAbnREV$se.summary*1.96,
			 summarymetaDisplayAbnREV$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3),border='grey')
# with F in the model
points(x= metaDisplayAbnREVF$est[metaDisplayAbnREVF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaDisplayAbn)*0.3)
arrows(metaDisplayAbnREVF$lower[metaDisplayAbnREVF$study == 'Malika'],7.6,
metaDisplayAbnREVF$upper[metaDisplayAbnREVF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaDisplayAbnREVF$est[metaDisplayAbnREVF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesDisplayAbn)*0.3)
arrows(metaDisplayAbnREVF$lower[metaDisplayAbnREVF$study == 'Johannes'],5.05,
metaDisplayAbnREVF$upper[metaDisplayAbnREVF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaDisplayAbnREVF$est[metaDisplayAbnREVF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaDisplayAbn)*0.3)
arrows(metaDisplayAbnREVF$lower[metaDisplayAbnREVF$study == 'Sanja'],2.9,
metaDisplayAbnREVF$upper[metaDisplayAbnREVF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaDisplayAbnREVF$summary -summarymetaDisplayAbnREVF$se.summary*1.96,
			 summarymetaDisplayAbnREVF$summary,
			 summarymetaDisplayAbnREVF$summary+summarymetaDisplayAbnREVF$se.summary*1.96,
			 summarymetaDisplayAbnREVF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')


		
mtext(side = 2, at=0.95,'Functional sperm    ', cex=1, font=2, adj=1, las=2)
mtext(side = 2, at=3.6,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=3,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.75,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.15,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.9,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.3,'(outbreds)    ',  adj=1, las=2, cex=0.8)		




par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n", xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.26,10,0.26,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Beak Color",at=0, side = 3, line = 1, cex=1, font=2)
# without F in model
arrows(metaBeakColorMunselAbn$lower[metaBeakColorMunselAbn$study == 'Johannes'],5.85,
metaBeakColorMunselAbn$upper[metaBeakColorMunselAbn$study == 'Johannes'],5.85, length=0, col='grey', lwd=1)
points(x= metaBeakColorMunselAbn$est[metaBeakColorMunselAbn$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesBeakMunselAbn)*0.3, col='grey',bg='white')
arrows(metaBeakColorMunselAbn$lower[metaBeakColorMunselAbn$study == 'Sanja'],3.7,
metaBeakColorMunselAbn$upper[metaBeakColorMunselAbn$study == 'Sanja'],3.7, length=0, col ="grey", lwd=1)
points(x= metaBeakColorMunselAbn$est[metaBeakColorMunselAbn$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaBeakMunselAbn)*0.3, col='grey',bg='white')
polygon(x= c(summarymetaBeakColorMunselAbn$summary -summarymetaBeakColorMunselAbn$se.summary*1.96,
			 summarymetaBeakColorMunselAbn$summary,
			 summarymetaBeakColorMunselAbn$summary+summarymetaBeakColorMunselAbn$se.summary*1.96,
			 summarymetaBeakColorMunselAbn$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in model
points(x= metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaBeakAbn)*0.3)
arrows(metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Malika'],7.6,
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesBeakMunselAbn)*0.3)
arrows(metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Johannes'],5.05,
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselAbnF$est[metaBeakColorMunselAbnF$study == 'Sanja'], y=2.9, pch=19, cex=sqrt(NSanjaBeakMunselAbn)*0.3)
arrows(metaBeakColorMunselAbnF$lower[metaBeakColorMunselAbnF$study == 'Sanja'],2.9,
metaBeakColorMunselAbnF$upper[metaBeakColorMunselAbnF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaBeakColorMunselAbnF$summary -summarymetaBeakColorMunselAbnF$se.summary*1.96,
			 summarymetaBeakColorMunselAbnF$summary,
			 summarymetaBeakColorMunselAbnF$summary+summarymetaBeakColorMunselAbnF$se.summary*1.96,
			 summarymetaBeakColorMunselAbnF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')

		

par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n", xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.23,10,0.23,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Tarsus length",at=0, side = 3, line = 1, cex=1, font=2)
# without F in model
arrows(metaTarsusAbn$lower[metaTarsusAbn$study == 'Johannes'],5.85,
metaTarsusAbn$upper[metaTarsusAbn$study == 'Johannes'],5.85, length=0, col='grey', lwd=1)
points(x= metaTarsusAbn$est[metaTarsusAbn$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesTarsusAbn)*0.3, col='grey',bg='white')
arrows(metaTarsusAbn$lower[metaTarsusAbn$study == 'Sanja'],3.7,
metaTarsusAbn$upper[metaTarsusAbn$study == 'Sanja'],3.7, length=0, col ="grey", lwd=1)
points(x= metaTarsusAbn$est[metaTarsusAbn$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaTarsusAbn)*0.3, col='grey',bg='white')
polygon(x= c(summarymetaTarsusAbn$summary -summarymetaTarsusAbn$se.summary*1.96,
			 summarymetaTarsusAbn$summary,
			 summarymetaTarsusAbn$summary+summarymetaTarsusAbn$se.summary*1.96,
			 summarymetaTarsusAbn$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in model
points(x= metaTarsusAbnF$est[metaTarsusAbnF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaTarsusAbn)*0.3)
arrows(metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Malika'],7.6,
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaTarsusAbnF$est[metaTarsusAbnF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesTarsusAbn)*0.3)
arrows(metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Johannes'],5.05,
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaTarsusAbnF$est[metaTarsusAbnF$study == 'Sanja'], y=2.9, pch=19, cex=sqrt(NSanjaTarsusAbn)*0.3)
arrows(metaTarsusAbnF$lower[metaTarsusAbnF$study == 'Sanja'],2.9,
metaTarsusAbnF$upper[metaTarsusAbnF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaTarsusAbnF$summary -summarymetaTarsusAbnF$se.summary*1.96,
			 summarymetaTarsusAbnF$summary,
			 summarymetaTarsusAbnF$summary+summarymetaTarsusAbnF$se.summary*1.96,
			 summarymetaTarsusAbnF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')



par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.18,10,0.18,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
# without F in the model
arrows(metaDisplayVelocity$lower[metaDisplayVelocity$study == 'Johannes'],5.85,
metaDisplayVelocity$upper[metaDisplayVelocity$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaDisplayVelocity$est[metaDisplayVelocity$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesDisplayVelocity)*0.3, col='grey', bg='white')
arrows(metaDisplayVelocity$lower[metaDisplayVelocity$study == 'Sanja'],3.7,
metaDisplayVelocity$upper[metaDisplayVelocity$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaDisplayVelocity$est[metaDisplayVelocity$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaDisplayVelocity)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaDisplayVelocity$summary -summarymetaDisplayVelocity$se.summary*1.96,
			 summarymetaDisplayVelocity$summary,
			 summarymetaDisplayVelocity$summary+summarymetaDisplayVelocity$se.summary*1.96,
			 summarymetaDisplayVelocity$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3),border='grey')
# with F in the model
points(x= metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaDisplayVelocity)*0.3)
arrows(metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Malika'],7.6,
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesDisplayVelocity)*0.3)
arrows(metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Johannes'],5.05,
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaDisplayVelocityF$est[metaDisplayVelocityF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaDisplayVelocity)*0.3)
arrows(metaDisplayVelocityF$lower[metaDisplayVelocityF$study == 'Sanja'],2.9,
metaDisplayVelocityF$upper[metaDisplayVelocityF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaDisplayVelocityF$summary -summarymetaDisplayVelocityF$se.summary*1.96,
			 summarymetaDisplayVelocityF$summary,
			 summarymetaDisplayVelocityF$summary+summarymetaDisplayVelocityF$se.summary*1.96,
			 summarymetaDisplayVelocityF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')

		

mtext(side = 2, at=0.95,'Sperm velocity    ', cex=1, font=2, adj=1, las=2)
mtext(side = 2, at=3.6,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=3,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.75,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.15,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.9,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.3,'(outbreds)    ',  adj=1, las=2, cex=0.8)		
	
	
	


		
par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.16,10,0.16,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
# without F in the model
arrows(metaBeakColorMunselVCL$lower[metaBeakColorMunselVCL$study == 'Johannes'],5.85,
metaBeakColorMunselVCL$upper[metaBeakColorMunselVCL$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaBeakColorMunselVCL$est[metaBeakColorMunselVCL$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesBeakMunselVCL)*0.3,col = "grey",bg='white')
arrows(metaBeakColorMunselVCL$lower[metaBeakColorMunselVCL$study == 'Sanja'],3.7,
metaBeakColorMunselVCL$upper[metaBeakColorMunselVCL$study == 'Sanja'],3.7, length=0, col = "grey",lwd=1)
points(x= metaBeakColorMunselVCL$est[metaBeakColorMunselVCL$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaBeakMunselVelocity)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaBeakColorMunselVCL$summary -summarymetaBeakColorMunselVCL$se.summary*1.96,
			 summarymetaBeakColorMunselVCL$summary,
			 summarymetaBeakColorMunselVCL$summary+summarymetaBeakColorMunselVCL$se.summary*1.96,
			 summarymetaBeakColorMunselVCL$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(x= metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaBeakVCL)*0.3)
arrows(metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Malika'],7.6,
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesBeakMunselVCL)*0.3)
arrows(metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Johannes'],5.05,
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselVCLF$est[metaBeakColorMunselVCLF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaBeakMunselVelocity)*0.3)
arrows(metaBeakColorMunselVCLF$lower[metaBeakColorMunselVCLF$study == 'Sanja'],2.9,
metaBeakColorMunselVCLF$upper[metaBeakColorMunselVCLF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaBeakColorMunselVCLF$summary -summarymetaBeakColorMunselVCLF$se.summary*1.96,
			 summarymetaBeakColorMunselVCLF$summary,
			 summarymetaBeakColorMunselVCLF$summary+summarymetaBeakColorMunselVCLF$se.summary*1.96,
			 summarymetaBeakColorMunselVCLF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')
	
		
		
par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.14,10,0.14,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
# without F in the model
arrows(metaTarsusVCL$lower[metaTarsusVCL$study == 'Johannes'],5.85,
metaTarsusVCL$upper[metaTarsusVCL$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaTarsusVCL$est[metaTarsusVCL$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesTarsusVCL)*0.3,col = "grey",bg='white')
arrows(metaTarsusVCL$lower[metaTarsusVCL$study == 'Sanja'],3.7,
metaTarsusVCL$upper[metaTarsusVCL$study == 'Sanja'],3.7, length=0, col = "grey",lwd=1)
points(x= metaTarsusVCL$est[metaTarsusVCL$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaTarsusVelocity)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaTarsusVCL$summary -summarymetaTarsusVCL$se.summary*1.96,
			 summarymetaTarsusVCL$summary,
			 summarymetaTarsusVCL$summary+summarymetaTarsusVCL$se.summary*1.96,
			 summarymetaTarsusVCL$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(x= metaTarsusVCLF$est[metaTarsusVCLF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaTarsusVCL)*0.3)
arrows(metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Malika'],7.6,
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaTarsusVCLF$est[metaTarsusVCLF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesTarsusVCL)*0.3)
arrows(metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Johannes'],5.05,
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaTarsusVCLF$est[metaTarsusVCLF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaTarsusVelocity)*0.3)
arrows(metaTarsusVCLF$lower[metaTarsusVCLF$study == 'Sanja'],2.9,
metaTarsusVCLF$upper[metaTarsusVCLF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaTarsusVCLF$summary -summarymetaTarsusVCLF$se.summary*1.96,
			 summarymetaTarsusVCLF$summary,
			 summarymetaTarsusVCLF$summary+summarymetaTarsusVCLF$se.summary*1.96,
			 summarymetaTarsusVCLF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')



par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.14,10,0.14,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext(c(-1,-0.5,0,0.5,1), at = c(-1,-0.5,0,0.5,1), side = 1, line = 0.5, cex=0.8)
#without F in the model
arrows(metaDisplaySlength$lower[metaDisplaySlength$study == 'Johannes'],5.85,
metaDisplaySlength$upper[metaDisplaySlength$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaDisplaySlength$est[metaDisplaySlength$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesDisplaySlength)*0.3, col='grey', bg='white')
arrows(metaDisplaySlength$lower[metaDisplaySlength$study == 'Sanja'],3.7,
metaDisplaySlength$upper[metaDisplaySlength$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaDisplaySlength$est[metaDisplaySlength$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaDisplaySlength)*0.3,col='grey', bg='white')
polygon(x= c(summarymetaDisplaySlength$summary -summarymetaDisplaySlength$se.summary*1.96,
			 summarymetaDisplaySlength$summary,
			 summarymetaDisplaySlength$summary+summarymetaDisplaySlength$se.summary*1.96,
			 summarymetaDisplaySlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3),border='grey')
# with F in the model
points(x= metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaDisplaySlength)*0.3)
arrows(metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Malika'],7.6,
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesDisplaySlength)*0.3)
arrows(metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Johannes'],5.05,
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaDisplaySlengthF$est[metaDisplaySlengthF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaDisplaySlength)*0.3)
arrows(metaDisplaySlengthF$lower[metaDisplaySlengthF$study == 'Sanja'],2.9,
metaDisplaySlengthF$upper[metaDisplaySlengthF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaDisplaySlengthF$summary -summarymetaDisplaySlengthF$se.summary*1.96,
			 summarymetaDisplaySlengthF$summary,
			 summarymetaDisplaySlengthF$summary+summarymetaDisplaySlengthF$se.summary*1.96,
			 summarymetaDisplaySlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')

	
mtext(side = 2, at=0.95,'Sperm length    ', cex=1, font=2, adj=1, las=2)
mtext(side = 2, at=3.6,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=3,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.75,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.15,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.9,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.3,'(outbreds)    ',  adj=1, las=2, cex=0.8)		

	
	

par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.12,10,0.12,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext(c(-1,-0.5,0,0.5,1), at = c(-1,-0.5,0,0.5,1), side = 1, line = 0.5, cex=0.8)
# without F in the model
arrows(metaBeakColorMunselSlength$lower[metaBeakColorMunselSlength$study == 'Johannes'],5.85,
metaBeakColorMunselSlength$upper[metaBeakColorMunselSlength$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaBeakColorMunselSlength$est[metaBeakColorMunselSlength$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesBeakMunselSlength)*0.3, col='grey', bg='white')
arrows(metaBeakColorMunselSlength$lower[metaBeakColorMunselSlength$study == 'Sanja'],3.7,
metaBeakColorMunselSlength$upper[metaBeakColorMunselSlength$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaBeakColorMunselSlength$est[metaBeakColorMunselSlength$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaBeakMunselSlength)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaBeakColorMunselSlength$summary -summarymetaBeakColorMunselSlength$se.summary*1.96,
			 summarymetaBeakColorMunselSlength$summary,
			 summarymetaBeakColorMunselSlength$summary+summarymetaBeakColorMunselSlength$se.summary*1.96,
			 summarymetaBeakColorMunselSlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
		# with F in the model
points(x= metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaBeakSlength)*0.3)
arrows(metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Malika'],7.6,
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesBeakMunselSlength)*0.3)
arrows(metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Johannes'],5.05,
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaBeakColorMunselSlengthF$est[metaBeakColorMunselSlengthF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaBeakMunselSlength)*0.3)
arrows(metaBeakColorMunselSlengthF$lower[metaBeakColorMunselSlengthF$study == 'Sanja'],2.9,
metaBeakColorMunselSlengthF$upper[metaBeakColorMunselSlengthF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaBeakColorMunselSlengthF$summary -summarymetaBeakColorMunselSlengthF$se.summary*1.96,
			 summarymetaBeakColorMunselSlengthF$summary,
			 summarymetaBeakColorMunselSlengthF$summary+summarymetaBeakColorMunselSlengthF$se.summary*1.96,
			 summarymetaBeakColorMunselSlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')

		


		
mtext("Correlation coefficient (  )",at=0, side = 1, line = 2.5, cex=1, font=2)
mtext("r",at=0.65, side = 1, line = 2.5, cex=1, font=4)
		


par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=c(-1,1), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1,-0.5,0,0.5,1), tck=0.03, labels=c(rep("",5)))
arrows(0.11,10,0.11,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext(c(-1,-0.5,0,0.5,1), at = c(-1,-0.5,0,0.5,1), side = 1, line = 0.5, cex=0.8)
# without F in the model
arrows(metaTarsusSlength$lower[metaTarsusSlength$study == 'Johannes'],5.85,
metaTarsusSlength$upper[metaTarsusSlength$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaTarsusSlength$est[metaTarsusSlength$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesTarsusSlength)*0.3, col='grey', bg='white')
arrows(metaTarsusSlength$lower[metaTarsusSlength$study == 'Sanja'],3.7,
metaTarsusSlength$upper[metaTarsusSlength$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaTarsusSlength$est[metaTarsusSlength$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaTarsusSlength)*0.3, col='grey', bg='white')
polygon(x= c(summarymetaTarsusSlength$summary -summarymetaTarsusSlength$se.summary*1.96,
			 summarymetaTarsusSlength$summary,
			 summarymetaTarsusSlength$summary+summarymetaTarsusSlength$se.summary*1.96,
			 summarymetaTarsusSlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
		# with F in the model
points(x= metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaTarsusSlength)*0.3)
arrows(metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Malika'],7.6,
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesTarsusSlength)*0.3)
arrows(metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Johannes'],5.05,
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaTarsusSlengthF$est[metaTarsusSlengthF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaTarsusSlength)*0.3)
arrows(metaTarsusSlengthF$lower[metaTarsusSlengthF$study == 'Sanja'],2.9,
metaTarsusSlengthF$upper[metaTarsusSlengthF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaTarsusSlengthF$summary -summarymetaTarsusSlengthF$se.summary*1.96,
			 summarymetaTarsusSlengthF$summary,
			 summarymetaTarsusSlengthF$summary+summarymetaTarsusSlengthF$se.summary*1.96,
			 summarymetaTarsusSlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')		
		
}


}


{### GRAPH clutches - sperm trait

{dev.new(width=13, heigth =6)
mat <- matrix(c(0,0,0,0,0,1,2,3,0,4,5,6,0,0,0,0), nrow=4, ncol=4, byrow=T)
layout(mat, widths = c(1.5,2,2,2),
       heights = c(0.1,1,1,0.15))


par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=log10(c(0.25,42)), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=log10(1),lwd=0.5, lty=2, col='grey')
arrows(log10(25),8.5,log10(35),8.5,code=2, length=0.08,lwd=2, col='grey40', angle=45)
axis(side=1, at= log10(c(2,3,4)), tck=0.03, labels=c(rep("",3)), col='grey')
axis(side=1, at= log10(c(0.5,1,5,10,15,20,25,30,35,40,45)), tck=0.03, labels=c(rep("",length(c(0.5,1,5,10,15,20,25,30,35,40,45)))))
axis(side=3, at= log10(c(2,3,4)), tck=0.03, labels=c(rep("",3)), col='grey')
axis(side=3, at= log10(c(0.5,1,5,10,15,20,25,30,35,40,45)), tck=0.03, labels=c(rep("",length(c(0.5,1,5,10,15,20,25,30,35,40,45)))))
mtext("Abnormal sperm",at=(log10(0.0)+log10(42))/2, side = 3, line = 1, cex=1, font=2)
# without F in model
arrows(log10(metaClutchIFAbn$lower2SE[metaClutchIFAbn$study == 'Johannes']),5.85,
log10(metaClutchIFAbn$upper2SE[metaClutchIFAbn$study == 'Johannes']),5.85, length=0, col='grey', lwd=1)
points(x= log10(metaClutchIFAbn$odds[metaClutchIFAbn$study == 'Johannes']), y=5.85,pch=21, cex=sqrt(NJohannesIFAbn)*0.5, col='grey',bg='white')
arrows(log10(metaClutchIFAbn$lower2SE[metaClutchIFAbn$study == 'Sanja']),3.7,
log10(metaClutchIFAbn$upper2SE[metaClutchIFAbn$study == 'Sanja']),3.7, length=0, col ="grey", lwd=1)
points(x= log10(metaClutchIFAbn$odds[metaClutchIFAbn$study == 'Sanja']), y=3.7,pch=21, cex=sqrt(NSanjaIFAbn)*0.5, col='grey',bg='white')
polygon(x= c(summarymetaClutchIFAbn$summary -summarymetaClutchIFAbn$se.summary*1.96,
			 summarymetaClutchIFAbn$summary,
			 summarymetaClutchIFAbn$summary+summarymetaClutchIFAbn$se.summary*1.96,
			 summarymetaClutchIFAbn$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in model
points(x= log10(metaClutchIFAbnF$odds[metaClutchIFAbnF$study == 'Malika']), y=7.6,pch=19, cex=sqrt(NMalikaIFAbn)*0.5)
arrows(log10(metaClutchIFAbnF$lower2SE[metaClutchIFAbnF$study == 'Malika']),7.6,
log10(metaClutchIFAbnF$upper2SE[metaClutchIFAbnF$study == 'Malika']),7.6, length=0, col = "black", lwd=2)
points(x= log10(metaClutchIFAbnF$odds[metaClutchIFAbnF$study == 'Johannes']), y=5.05,pch=19, cex=sqrt(NJohannesIFAbn)*0.5)
arrows(log10(metaClutchIFAbnF$lower2SE[metaClutchIFAbnF$study == 'Johannes']),5.05,
log10(metaClutchIFAbnF$upper2SE[metaClutchIFAbnF$study == 'Johannes']),5.05, length=0, col = "black", lwd=2)
points(x= log10(metaClutchIFAbnF$odds[metaClutchIFAbnF$study == 'Sanja']), y=2.9,pch=19, cex=sqrt(NSanjaIFAbn)*0.5)
arrows(log10(metaClutchIFAbnF$lower2SE[metaClutchIFAbnF$study == 'Sanja']),2.9,
log10(metaClutchIFAbnF$upper2SE[metaClutchIFAbnF$study == 'Sanja']),2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaClutchIFAbnF$summary -summarymetaClutchIFAbnF$se.summary*1.96,
			 summarymetaClutchIFAbnF$summary,
			 summarymetaClutchIFAbnF$summary+summarymetaClutchIFAbnF$se.summary*1.96,
			 summarymetaClutchIFAbnF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')

mtext(side = 2, at=0.95,'Infertility    ', cex=1, font=2, adj=1, las=2)

mtext(side = 2, at=3.5,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=2.9,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.65,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.05,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.8,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.2,'(outbreds)    ',  adj=1, las=2, cex=0.8)		
		


par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=log10(c(0.09,4)), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt='n')
abline(v=log10(1),lwd=0.5, lty=2, col='grey')
arrows(log10(0.12),8.5,log10(0.09),8.5,code=2, length=0.08,lwd=2, col='grey40', angle=45)
axis(side=1, at= log10(c(0.1,0.5,1,2,3)), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= log10(c(0.1,0.5,1,2,3)), tck=0.03, labels=c(rep("",5)))
mtext("Sperm Velocity",at=(log10(0.06)+log10(4))/2, side = 3, line = 1, cex=1, font=2)
# without F in the model
arrows(log10(metaClutchIFVelocity$lower2SE[metaClutchIFVelocity$study == 'Johannes']),5.85,
log10(metaClutchIFVelocity$upper2SE[metaClutchIFVelocity$study == 'Johannes']),5.85, length=0, col = "grey", lwd=1)
points(x= log10(metaClutchIFVelocity$odds[metaClutchIFVelocity$study == 'Johannes']), y=5.85,pch=21, cex=sqrt(NJohannesIFVelocity)*0.5,col = "grey",bg='white')
arrows(log10(metaClutchIFVelocity$lower2SE[metaClutchIFVelocity$study == 'Sanja']),3.7,
log10(metaClutchIFVelocity$upper2SE[metaClutchIFVelocity$study == 'Sanja']),3.7, length=0, col = "grey",lwd=1)
points(log10(x= metaClutchIFVelocity$odds[metaClutchIFVelocity$study == 'Sanja']), y=3.7,pch=21, cex=sqrt(NSanjaIFVelocity)*0.5, col='grey', bg='white')
polygon(x= c((summarymetaClutchIFVelocity$summary -summarymetaClutchIFVelocity$se.summary*1.96),
			 summarymetaClutchIFVelocity$summary,
			 (summarymetaClutchIFVelocity$summary+summarymetaClutchIFVelocity$se.summary*1.96),
			 summarymetaClutchIFVelocity$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(log10(x= metaClutchIFVelocityF$odds[metaClutchIFVelocityF$study == 'Malika']), y=7.6,pch=19, cex=sqrt(NMalikaIFVelocity)*0.5)
arrows(log10(metaClutchIFVelocityF$lower2SE[metaClutchIFVelocityF$study == 'Malika']),7.6,
log10(metaClutchIFVelocityF$upper2SE[metaClutchIFVelocityF$study == 'Malika']),7.6, length=0, col = "black", lwd=2)
points(log10(x= metaClutchIFVelocityF$odds[metaClutchIFVelocityF$study == 'Johannes']), y=5.05,pch=19, cex=sqrt(NJohannesIFVelocity)*0.5)
arrows(log10(metaClutchIFVelocityF$lower2SE[metaClutchIFVelocityF$study == 'Johannes']),5.05,
log10(metaClutchIFVelocityF$upper2SE[metaClutchIFVelocityF$study == 'Johannes']),5.05, length=0, col = "black", lwd=2)
points(log10(x= metaClutchIFVelocityF$odds[metaClutchIFVelocityF$study == 'Sanja']), y=2.9,pch=19, cex=sqrt(NSanjaIFVelocity)*0.5)
arrows(log10(metaClutchIFVelocityF$lower2SE[metaClutchIFVelocityF$study == 'Sanja']),2.9,
log10(metaClutchIFVelocityF$upper2SE[metaClutchIFVelocityF$study == 'Sanja']),2.9, length=0, col = "black", lwd=2)
polygon(x= c((summarymetaClutchIFVelocityF$summary -summarymetaClutchIFVelocityF$se.summary*1.96),
			 summarymetaClutchIFVelocityF$summary,
			 (summarymetaClutchIFVelocityF$summary+summarymetaClutchIFVelocityF$se.summary*1.96),
			 summarymetaClutchIFVelocityF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')



par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=log10(c(0.06,4.5)), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt='n')
abline(v=log10(1),lwd=0.5, lty=2, col='grey')
arrows(log10(0.12),8.5,log10(0.09),8.5,code=2, length=0.08,lwd=2, col='grey40', angle=45)
axis(side=1, at= log10(c(0.1,0.5,1,2,3,4)), tck=0.03, labels=c(rep("",6)))
axis(side=3, at= log10(c(0.1,0.5,1,2,3,4)), tck=0.03, labels=c(rep("",6)))
mtext("Sperm length",at=(log10(0.06)+log10(4))/2, side = 3, line = 1, cex=1, font=2)
# without F in the model
arrows(log10(metaClutchIFSlength$lower2SE[metaClutchIFSlength$study == 'Johannes']),5.85,
log10(metaClutchIFSlength$upper2SE[metaClutchIFSlength$study == 'Johannes']),5.85, length=0, col = "grey", lwd=1)
points(x= log10(metaClutchIFSlength$odds[metaClutchIFSlength$study == 'Johannes']), y=5.85,pch=21, cex=sqrt(NJohannesIFSlength)*0.5,col = "grey",bg='white')
arrows(log10(metaClutchIFSlength$lower2SE[metaClutchIFSlength$study == 'Sanja']),3.7,
log10(metaClutchIFSlength$upper2SE[metaClutchIFSlength$study == 'Sanja']),3.7, length=0, col = "grey",lwd=1)
points(x= log10(metaClutchIFSlength$odds[metaClutchIFSlength$study == 'Sanja']), y=3.7,pch=21, cex=sqrt(NSanjaIFSlength)*0.5, col='grey', bg='white')
polygon(x= c((summarymetaClutchIFSlength$summary -summarymetaClutchIFSlength$se.summary*1.96),
			 summarymetaClutchIFSlength$summary,
			 (summarymetaClutchIFSlength$summary+summarymetaClutchIFSlength$se.summary*1.96),
			 summarymetaClutchIFSlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(x= log10(metaClutchIFSlengthF$odds[metaClutchIFSlengthF$study == 'Malika']), y=7.6,pch=19, cex=sqrt(NMalikaIFSlength)*0.5)
arrows(log10(metaClutchIFSlengthF$lower2SE[metaClutchIFSlengthF$study == 'Malika']),7.6,
log10(metaClutchIFSlengthF$upper2SE[metaClutchIFSlengthF$study == 'Malika']),7.6, length=0, col = "black", lwd=2)
points(x= log10(metaClutchIFSlengthF$odds[metaClutchIFSlengthF$study == 'Johannes']), y=5.05,pch=19, cex=sqrt(NJohannesIFSlength)*0.5)
arrows(log10(metaClutchIFSlengthF$lower2SE[metaClutchIFSlengthF$study == 'Johannes']),5.05,
log10(metaClutchIFSlengthF$upper2SE[metaClutchIFSlengthF$study == 'Johannes']),5.05, length=0, col = "black", lwd=2)
points(x= log10(metaClutchIFSlengthF$odds[metaClutchIFSlengthF$study == 'Sanja']), y=2.9,pch=19, cex=sqrt(NSanjaIFSlength)*0.5)
arrows(log10(metaClutchIFSlengthF$lower2SE[metaClutchIFSlengthF$study == 'Sanja']),2.9,
log10(metaClutchIFSlengthF$upper2SE[metaClutchIFSlengthF$study == 'Sanja']),2.9, length=0, col = "black", lwd=2)
polygon(x= c((summarymetaClutchIFSlengthF$summary -summarymetaClutchIFSlengthF$se.summary*1.96),
			 summarymetaClutchIFSlengthF$summary,
			 (summarymetaClutchIFSlengthF$summary+summarymetaClutchIFSlengthF$se.summary*1.96),
			 summarymetaClutchIFSlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')



par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=log10(c(0.25,42)), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=log10(1),lwd=0.5, lty=2, col='grey')
arrows(log10(25),8.5,log10(35),8.5,code=2, length=0.08,lwd=2, col='grey40', angle=45)
axis(side=1, at= log10(c(2,3,4)), tck=0.03, labels=c(rep("",3)), col='grey')
axis(side=1, at= log10(c(0.5,1,5,10,15,20,25,30,35,40,45)), tck=0.03, labels=c(rep("",length(c(0.5,1,5,10,15,20,25,30,35,40,45)))))
axis(side=3, at= log10(c(2,3,4)), tck=0.03, labels=c(rep("",3)), col='grey')
axis(side=3, at= log10(c(0.5,1,5,10,15,20,25,30,35,40,45)), tck=0.03, labels=c(rep("",length(c(0.5,1,5,10,15,20,25,30,35,40,45)))))
mtext(c(0.5,1,5,10,20,40), at = log10(c(0.5,1,5,10,20,40)), side = 1, line = 0.5, cex=0.8)
# without F in the model
arrows(log10(metaClutchEPPAbn$lower2SE[metaClutchEPPAbn$study == 'Johannes']),5.85,
log10(metaClutchEPPAbn$upper2SE[metaClutchEPPAbn$study == 'Johannes']),5.85, length=0, col = "grey", lwd=1)
points(x= log10(metaClutchEPPAbn$odds[metaClutchEPPAbn$study == 'Johannes']), y=5.85,pch=21, cex=sqrt(NJohannesEPPAbn)*0.5,col = "grey",bg='white')
arrows(log10(metaClutchEPPAbn$lower2SE[metaClutchEPPAbn$study == 'Sanja']),3.7,
log10(metaClutchEPPAbn$upper2SE[metaClutchEPPAbn$study == 'Sanja']),3.7, length=0, col = "grey",lwd=1)
points(x= log10(metaClutchEPPAbn$odds[metaClutchEPPAbn$study == 'Sanja']), y=3.7,pch=21, cex=sqrt(NSanjaEPPAbn)*0.5, col='grey', bg='white')
polygon(x= c(summarymetaClutchEPPAbn$summary -summarymetaClutchEPPAbn$se.summary*1.96,
			 summarymetaClutchEPPAbn$summary,
			 summarymetaClutchEPPAbn$summary+summarymetaClutchEPPAbn$se.summary*1.96,
			 summarymetaClutchEPPAbn$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(x= log10(metaClutchEPPAbnF$odds[metaClutchEPPAbnF$study == 'Malika']), y=7.6,pch=19, cex=sqrt(NMalikaEPPAbn)*0.5)
arrows(log10(metaClutchEPPAbnF$lower2SE[metaClutchEPPAbnF$study == 'Malika']),7.6,
log10(metaClutchEPPAbnF$upper2SE[metaClutchEPPAbnF$study == 'Malika']),7.6, length=0, col = "black", lwd=2)
points(x= log10(metaClutchEPPAbnF$odds[metaClutchEPPAbnF$study == 'Johannes']), y=5.05,pch=19, cex=sqrt(NJohannesEPPAbn)*0.5)
arrows(log10(metaClutchEPPAbnF$lower2SE[metaClutchEPPAbnF$study == 'Johannes']),5.05,
log10(metaClutchEPPAbnF$upper2SE[metaClutchEPPAbnF$study == 'Johannes']),5.05, length=0, col = "black", lwd=2)
points(x= log10(metaClutchEPPAbnF$odds[metaClutchEPPAbnF$study == 'Sanja']), y=2.9,pch=19, cex=sqrt(NSanjaEPPAbn)*0.5)
arrows(log10(metaClutchEPPAbnF$lower2SE[metaClutchEPPAbnF$study == 'Sanja']),2.9,
log10(metaClutchEPPAbnF$upper2SE[metaClutchEPPAbnF$study == 'Sanja']),2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaClutchEPPAbnF$summary -summarymetaClutchEPPAbnF$se.summary*1.96,
			 summarymetaClutchEPPAbnF$summary,
			 summarymetaClutchEPPAbnF$summary+summarymetaClutchEPPAbnF$se.summary*1.96,
			 summarymetaClutchEPPAbnF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')
		
mtext(side = 2, at=0.95,'Within-pair paternity loss   ', cex=1, font=2, adj=1, las=2)
mtext(side = 2, at=3.5,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=2.9,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.65,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.05,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.8,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.2,'(outbreds)    ',  adj=1, las=2, cex=0.8)	
		


par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=log10(c(0.09,4)), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt='n')
abline(v=log10(1),lwd=0.5, lty=2, col='grey')
arrows(log10(0.12),8.5,log10(0.09),8.5,code=2, length=0.08,lwd=2, col='grey40', angle=45)
axis(side=1, at= log10(c(0.1,0.5,1,2,3)), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= log10(c(0.1,0.5,1,2,3)), tck=0.03, labels=c(rep("",5)))
mtext(c(0.1,0.5,1,2,3), at = log10(c(0.1,0.5,1,2,3)), side = 1, line = 0.5, cex=0.8)
mtext("Odds ratio",at=(log10(0.07)+log10(3))/2, side = 1, line = 2.5, cex=1, font=2)
# without F in the model
arrows(log10(metaClutchEPPVelocity$lower2SE[metaClutchEPPVelocity$study == 'Johannes']),5.85,
log10(metaClutchEPPVelocity$upper2SE[metaClutchEPPVelocity$study == 'Johannes']),5.85, length=0, col = "grey", lwd=1)
points(x= log10(metaClutchEPPVelocity$odds[metaClutchEPPVelocity$study == 'Johannes']), y=5.85,pch=21, cex=sqrt(NJohannesEPPVelocity)*0.5,col = "grey",bg='white')
arrows(log10(metaClutchEPPVelocity$lower2SE[metaClutchEPPVelocity$study == 'Sanja']),3.7,
log10(metaClutchEPPVelocity$upper2SE[metaClutchEPPVelocity$study == 'Sanja']),3.7, length=0, col = "grey",lwd=1)
points(x= log10(metaClutchEPPVelocity$odds[metaClutchEPPVelocity$study == 'Sanja']), y=3.7,pch=21, cex=sqrt(NSanjaEPPVelocity)*0.5, col='grey', bg='white')
polygon(x= c((summarymetaClutchEPPVelocity$summary -summarymetaClutchEPPVelocity$se.summary*1.96),
			 summarymetaClutchEPPVelocity$summary,
			 (summarymetaClutchEPPVelocity$summary+summarymetaClutchEPPVelocity$se.summary*1.96),
			 summarymetaClutchEPPVelocity$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(x= log10(metaClutchEPPVelocityF$odds[metaClutchEPPVelocityF$study == 'Malika']), y=7.6,pch=19, cex=sqrt(NMalikaEPPVelocity)*0.5)
arrows(log10(metaClutchEPPVelocityF$lower2SE[metaClutchEPPVelocityF$study == 'Malika']),7.6,
log10(metaClutchEPPVelocityF$upper2SE[metaClutchEPPVelocityF$study == 'Malika']),7.6, length=0, col = "black", lwd=2)
points(x= log10(metaClutchEPPVelocityF$odds[metaClutchEPPVelocityF$study == 'Johannes']), y=5.05,pch=19, cex=sqrt(NJohannesEPPVelocity)*0.5)
arrows(log10(metaClutchEPPVelocityF$lower2SE[metaClutchEPPVelocityF$study == 'Johannes']),5.05,
log10(metaClutchEPPVelocityF$upper2SE[metaClutchEPPVelocityF$study == 'Johannes']),5.05, length=0, col = "black", lwd=2)
points(x= log10(metaClutchEPPVelocityF$odds[metaClutchEPPVelocityF$study == 'Sanja']), y=2.9,pch=19, cex=sqrt(NSanjaEPPVelocity)*0.5)
arrows(log10(metaClutchEPPVelocityF$lower2SE[metaClutchEPPVelocityF$study == 'Sanja']),2.9,
log10(metaClutchEPPVelocityF$upper2SE[metaClutchEPPVelocityF$study == 'Sanja']),2.9, length=0, col = "black", lwd=2)
polygon(x= c((summarymetaClutchEPPVelocityF$summary -summarymetaClutchEPPVelocityF$se.summary*1.96),
			 summarymetaClutchEPPVelocityF$summary,
			 (summarymetaClutchEPPVelocityF$summary+summarymetaClutchEPPVelocityF$se.summary*1.96),
			 summarymetaClutchEPPVelocityF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')

		
par(mar=c(1, 1, 1, 1))
plot(NULL, xlim=log10(c(0.06,4.5)), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt='n')
abline(v=log10(1),lwd=0.5, lty=2, col='grey')
arrows(log10(0.12),8.5,log10(0.09),8.5,code=2, length=0.08,lwd=2, col='grey40', angle=45)
axis(side=1, at= log10(c(0.1,0.5,1,2,3,4)), tck=0.03, labels=c(rep("",6)))
axis(side=3, at= log10(c(0.1,0.5,1,2,3,4)), tck=0.03, labels=c(rep("",6)))
mtext(c(0.1,0.5,1,2,3,4), at = log10(c(0.1,0.5,1,2,3,4)), side = 1, line = 0.5, cex=0.8)
# without F in the model
arrows(log10(metaClutchEPPSlength$lower2SE[metaClutchEPPSlength$study == 'Johannes']),5.85,
log10(metaClutchEPPSlength$upper2SE[metaClutchEPPSlength$study == 'Johannes']),5.85, length=0, col = "grey", lwd=1)
points(log10(x= metaClutchEPPSlength$odds[metaClutchEPPSlength$study == 'Johannes']), y=5.85,pch=21, cex=sqrt(NJohannesEPPSlength)*0.5,col = "grey",bg='white')
arrows(log10(metaClutchEPPSlength$lower2SE[metaClutchEPPSlength$study == 'Sanja']),3.7,
log10(metaClutchEPPSlength$upper2SE[metaClutchEPPSlength$study == 'Sanja']),3.7, length=0, col = "grey",lwd=1)
points(log10(x= metaClutchEPPSlength$odds[metaClutchEPPSlength$study == 'Sanja']), y=3.7,pch=21, cex=sqrt(NSanjaEPPSlength)*0.5, col='grey', bg='white')
polygon(x= c((summarymetaClutchEPPSlength$summary -summarymetaClutchEPPSlength$se.summary*1.96),
			 summarymetaClutchEPPSlength$summary,
			 (summarymetaClutchEPPSlength$summary+summarymetaClutchEPPSlength$se.summary*1.96),
			 summarymetaClutchEPPSlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(log10(x= metaClutchEPPSlengthF$odds[metaClutchEPPSlengthF$study == 'Malika']), y=7.6,pch=19, cex=sqrt(NMalikaEPPSlength)*0.5)
arrows(log10(metaClutchEPPSlengthF$lower2SE[metaClutchEPPSlengthF$study == 'Malika']),7.6,
log10(metaClutchEPPSlengthF$upper2SE[metaClutchEPPSlengthF$study == 'Malika']),7.6, length=0, col = "black", lwd=2)
points(x= log10(metaClutchEPPSlengthF$odds[metaClutchEPPSlengthF$study == 'Johannes']), y=5.05,pch=19, cex=sqrt(NJohannesEPPSlength)*0.5)
arrows(log10(metaClutchEPPSlengthF$lower2SE[metaClutchEPPSlengthF$study == 'Johannes']),5.05,
log10(metaClutchEPPSlengthF$upper2SE[metaClutchEPPSlengthF$study == 'Johannes']),5.05, length=0, col = "black", lwd=2)
points(x= log10(metaClutchEPPSlengthF$odds[metaClutchEPPSlengthF$study == 'Sanja']), y=2.9,pch=19, cex=sqrt(NSanjaEPPSlength)*0.5)
arrows(log10(metaClutchEPPSlengthF$lower2SE[metaClutchEPPSlengthF$study == 'Sanja']),2.9,
log10(metaClutchEPPSlengthF$upper2SE[metaClutchEPPSlengthF$study == 'Sanja']),2.9, length=0, col = "black", lwd=2)
polygon(x= c((summarymetaClutchEPPSlengthF$summary -summarymetaClutchEPPSlengthF$se.summary*1.96),
			 summarymetaClutchEPPSlengthF$summary,
			 (summarymetaClutchEPPSlengthF$summary+summarymetaClutchEPPSlengthF$se.summary*1.96),
			 summarymetaClutchEPPSlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')
}

}


{### GRAPH siring success- sperm traits

{dev.new(width=11, heigth =4)
mat <- matrix(c(0,1,2,3), nrow=1, ncol=4, byrow=T)
layout(mat, widths = c(1,2,2,2),
       heights = c(1,1))

par(mar=c(4.5, 1, 3, 1))
plot(NULL, xlim=c(-1.5,0.5), ylim = c(0,9), yaxt ="n", xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-1.5,-1,-0.5,0,0.5), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-1.5,-1,-0.5,0,0.5), tck=0.03, labels=c(rep("",5)))
arrows(-1,8.5,-1.2,8.5,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Abnormal sperm",at=-0.5, side = 3, line = 1, cex=1, font=2)
mtext(c(-1.5,-1,-0.5,0,0.5), at = c(-1.5,-1,-0.5,0,0.5), side = 1, line = 0.5, cex=0.8)
# without F in model
arrows(metaSiringSuccAbn$lower[metaSiringSuccAbn$study == 'Johannes'],5.85,
metaSiringSuccAbn$upper[metaSiringSuccAbn$study == 'Johannes'],5.85, length=0, col='grey', lwd=1)
points(x= metaSiringSuccAbn$est[metaSiringSuccAbn$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesSiringSuccAbn)*2/3, col='grey',bg='white')
arrows(metaSiringSuccAbn$lower[metaSiringSuccAbn$study == 'Sanja'],3.7,
metaSiringSuccAbn$upper[metaSiringSuccAbn$study == 'Sanja'],3.7, length=0, col ="grey", lwd=1)
points(x= metaSiringSuccAbn$est[metaSiringSuccAbn$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaSiringSuccAbn)*2/3, col='grey',bg='white')
polygon(x= c(summarymetaSiringSuccAbn$summary -summarymetaSiringSuccAbn$se.summary*1.96,
			 summarymetaSiringSuccAbn$summary,
			 summarymetaSiringSuccAbn$summary+summarymetaSiringSuccAbn$se.summary*1.96,
			 summarymetaSiringSuccAbn$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in model
points(x= metaSiringSuccAbnF$est[metaSiringSuccAbnF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaSiringSucc)*2/3)
arrows(metaSiringSuccAbnF$lower[metaSiringSuccAbnF$study == 'Malika'],7.6,
metaSiringSuccAbnF$upper[metaSiringSuccAbnF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaSiringSuccAbnF$est[metaSiringSuccAbnF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesSiringSuccAbn)*2/3)
arrows(metaSiringSuccAbnF$lower[metaSiringSuccAbnF$study == 'Johannes'],5.05,
metaSiringSuccAbnF$upper[metaSiringSuccAbnF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaSiringSuccAbnF$est[metaSiringSuccAbnF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaSiringSuccAbn)*2/3)
arrows(metaSiringSuccAbnF$lower[metaSiringSuccAbnF$study == 'Sanja'],2.9,
metaSiringSuccAbnF$upper[metaSiringSuccAbnF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaSiringSuccAbnF$summary -summarymetaSiringSuccAbnF$se.summary*1.96,
			 summarymetaSiringSuccAbnF$summary,
			 summarymetaSiringSuccAbnF$summary+summarymetaSiringSuccAbnF$se.summary*1.96,
			 summarymetaSiringSuccAbnF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')

mtext(side = 2, at=0.95,'Siring success    ', cex=1, font=2, adj=1, las=2)
mtext(side = 2, at=3.6,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=3)
mtext(side = 2, at=3,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8)
mtext(side = 2, at=5.75,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=3) 
mtext(side = 2, at=5.15,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8)
mtext(side = 2, at=7.9,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=3)	 
mtext(side = 2, at=7.3,'(outbreds)    ',  adj=1, las=2, cex=0.8)		


		



par(mar=c(4.5, 1, 3, 1))
plot(NULL, xlim=c(-0.5,1.5), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-0.5,0,0.5,1,1.5), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-0.5,0,0.5,1,1.5), tck=0.03, labels=c(rep("",5)))
arrows(1,8.5,1.2,8.5,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Sperm Velocity",at=0.5, side = 3, line = 1, cex=1, font=2)
mtext(c(-0.5,0,0.5,1,1.5), at = c(-0.5,0,0.5,1,1.5), side = 1, line = 0.5, cex=0.8)
mtext("Standardized regression coefficient",at=0, side = 1, line = 2.5, cex=1, font=2)
# without F in the model
arrows(metaSiringSuccVelocity$lower[metaSiringSuccVelocity$study == 'Johannes'],5.85,
metaSiringSuccVelocity$upper[metaSiringSuccVelocity$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaSiringSuccVelocity$est[metaSiringSuccVelocity$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesSiringSuccVelocity)*2/3,col = "grey",bg='white')
arrows(metaSiringSuccVelocity$lower[metaSiringSuccVelocity$study == 'Sanja'],3.7,
metaSiringSuccVelocity$upper[metaSiringSuccVelocity$study == 'Sanja'],3.7, length=0, col = "grey",lwd=1)
points(x= metaSiringSuccVelocity$est[metaSiringSuccVelocity$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaSiringSuccVelocity)*2/3, col='grey', bg='white')
polygon(x= c(summarymetaSiringSuccVelocity$summary -summarymetaSiringSuccVelocity$se.summary*1.96,
			 summarymetaSiringSuccVelocity$summary,
			 summarymetaSiringSuccVelocity$summary+summarymetaSiringSuccVelocity$se.summary*1.96,
			 summarymetaSiringSuccVelocity$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
# with F in the model
points(x= metaSiringSuccVelocityF$est[metaSiringSuccVelocityF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaSiringSucc)*2/3)
arrows(metaSiringSuccVelocityF$lower[metaSiringSuccVelocityF$study == 'Malika'],7.6,
metaSiringSuccVelocityF$upper[metaSiringSuccVelocityF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaSiringSuccVelocityF$est[metaSiringSuccVelocityF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesSiringSuccVelocity)*2/3)
arrows(metaSiringSuccVelocityF$lower[metaSiringSuccVelocityF$study == 'Johannes'],5.05,
metaSiringSuccVelocityF$upper[metaSiringSuccVelocityF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaSiringSuccVelocityF$est[metaSiringSuccVelocityF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaSiringSuccVelocity)*2/3)
arrows(metaSiringSuccVelocityF$lower[metaSiringSuccVelocityF$study == 'Sanja'],2.9,
metaSiringSuccVelocityF$upper[metaSiringSuccVelocityF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaSiringSuccVelocityF$summary -summarymetaSiringSuccVelocityF$se.summary*1.96,
			 summarymetaSiringSuccVelocityF$summary,
			 summarymetaSiringSuccVelocityF$summary+summarymetaSiringSuccVelocityF$se.summary*1.96,
			 summarymetaSiringSuccVelocityF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3), col='black')


par(mar=c(4.5, 1, 3, 1))
plot(NULL, xlim=c(-0.5,1.5), ylim = c(0,9), yaxt ="n",  xlab="", ylab="",xaxt="n")
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=1, at= c(-0.5,0,0.5,1,1.5), tck=0.03, labels=c(rep("",5)))
axis(side=3, at= c(-0.5,0,0.5,1,1.5), tck=0.03, labels=c(rep("",5)))
arrows(1,8.7,1.2,8.7,code=2, length=0.08,lwd=2, col='grey40', angle=45)
mtext("Sperm length",at=0.5, side = 3, line = 1, cex=1, font=2)
mtext(c(-0.5,0,0.5,1,1.5), at = c(-0.5,0,0.5,1,1.5), side = 1, line = 0.5, cex=0.8)
# without F in the model
arrows(metaSiringSuccSlength$lower[metaSiringSuccSlength$study == 'Johannes'],5.85,
metaSiringSuccSlength$upper[metaSiringSuccSlength$study == 'Johannes'],5.85, length=0, col = "grey", lwd=1)
points(x= metaSiringSuccSlength$est[metaSiringSuccSlength$study == 'Johannes'], y=5.85,pch=21, cex=sqrt(NJohannesSiringSuccSlength)*2/3, col='grey', bg='white')
arrows(metaSiringSuccSlength$lower[metaSiringSuccSlength$study == 'Sanja'],3.7,
metaSiringSuccSlength$upper[metaSiringSuccSlength$study == 'Sanja'],3.7, length=0, col = "grey", lwd=1)
points(x= metaSiringSuccSlength$est[metaSiringSuccSlength$study == 'Sanja'], y=3.7,pch=21, cex=sqrt(NSanjaSiringSuccSlength)*2/3, col='grey', bg='white')
polygon(x= c(summarymetaSiringSuccSlength$summary -summarymetaSiringSuccSlength$se.summary*1.96,
			 summarymetaSiringSuccSlength$summary,
			 summarymetaSiringSuccSlength$summary+summarymetaSiringSuccSlength$se.summary*1.96,
			 summarymetaSiringSuccSlength$summary),
		y=c(1.3,1.3-0.3,1.3,1.3+0.3), border='grey')
		# with F in the model
points(x= metaSiringSuccSlengthF$est[metaSiringSuccSlengthF$study == 'Malika'], y=7.6,pch=19, cex=sqrt(NMalikaSiringSucc)*2/3)
arrows(metaSiringSuccSlengthF$lower[metaSiringSuccSlengthF$study == 'Malika'],7.6,
metaSiringSuccSlengthF$upper[metaSiringSuccSlengthF$study == 'Malika'],7.6, length=0, col = "black", lwd=2)
points(x= metaSiringSuccSlengthF$est[metaSiringSuccSlengthF$study == 'Johannes'], y=5.05,pch=19, cex=sqrt(NJohannesSiringSuccSlength)*2/3)
arrows(metaSiringSuccSlengthF$lower[metaSiringSuccSlengthF$study == 'Johannes'],5.05,
metaSiringSuccSlengthF$upper[metaSiringSuccSlengthF$study == 'Johannes'],5.05, length=0, col = "black", lwd=2)
points(x= metaSiringSuccSlengthF$est[metaSiringSuccSlengthF$study == 'Sanja'], y=2.9,pch=19, cex=sqrt(NSanjaSiringSuccSlength)*2/3)
arrows(metaSiringSuccSlengthF$lower[metaSiringSuccSlengthF$study == 'Sanja'],2.9,
metaSiringSuccSlengthF$upper[metaSiringSuccSlengthF$study == 'Sanja'],2.9, length=0, col = "black", lwd=2)
polygon(x= c(summarymetaSiringSuccSlengthF$summary -summarymetaSiringSuccSlengthF$se.summary*1.96,
			 summarymetaSiringSuccSlengthF$summary,
			 summarymetaSiringSuccSlengthF$summary+summarymetaSiringSuccSlengthF$se.summary*1.96,
			 summarymetaSiringSuccSlengthF$summary),
		y=c(0.6,0.6-0.3,0.6,0.6+0.3),col='black')
}

}


{### Delta MID-EPM sperm traits - GRAPH cbind(EPY, WPY)

{# get all the data in one table and one model
MixedclutchesMalika <- TableClutchGenEPYYNAllMales[!(is.na(TableClutchGenEPYYNAllMales$DeltalogAbnormal)),c('nbWPY','nbEPY','percEPY','ClutchSize','DeltalogAbnormal','DeltaVCL0s','DeltaSlength','SocialMalePartner')]
colnames(MixedclutchesMalika)[colnames(MixedclutchesMalika) == "SocialMalePartner"] <- "MID"
MixedclutchesJohannes <- TableClutchGenEPYYNAllMalesJo[!(is.na(TableClutchGenEPYYNAllMalesJo$DeltaSlength)),c('nbWPY','nbEPY','percEPY','ClutchSize','DeltalogAbnormal','DeltaVCL0s','DeltaSlength','MID')]
MixedclutchesSanja <- sanjaClutcheswithEPM[!(is.na(sanjaClutcheswithEPM$DeltaSlength)),c('WPY','EPY','percEPY','Clutchsize','DeltalogAbnormal','DeltaVCL0s','DeltaSlength','MID')]
colnames(MixedclutchesSanja)[colnames(MixedclutchesSanja) == "Clutchsize"] <- "ClutchSize"
colnames(MixedclutchesSanja)[colnames(MixedclutchesSanja) == "WPY"] <- "nbWPY"
colnames(MixedclutchesSanja)[colnames(MixedclutchesSanja) == "EPY"] <- "nbEPY"

ALLClutcheswithmixedpaternity <- rbind(MixedclutchesMalika,MixedclutchesJohannes,MixedclutchesSanja)

modDELTAAbn <- glmer(cbind(nbEPY,nbWPY)~ DeltalogAbnormal + scale(ClutchSize, scale=FALSE) +(1|MID), 
data=ALLClutcheswithmixedpaternity, family='binomial')
summary(modDELTAAbn)
estimatesDELTAAbn <- coef(summary(modDELTAAbn))


modDELTAVel <- glmer(cbind(nbEPY,nbWPY)~ DeltaVCL0s + scale(ClutchSize, scale=FALSE) +(1|MID), 
data=ALLClutcheswithmixedpaternity, family='binomial')
summary(modDELTAVel)
estimatesDELTAVel <- coef(summary(modDELTAVel))

modDELTASlength <- glmer(cbind(nbEPY,nbWPY)~ DeltaSlength + scale(ClutchSize, scale=FALSE) +(1|MID), 
data=ALLClutcheswithmixedpaternity, family='binomial')
summary(modDELTASlength)
estimatesDELTASlength <- coef(summary(modDELTASlength))
}


{dev.new(width=11, heigth =3.5)
mat <- matrix(c(0,1,2,3), nrow=1, ncol=4, byrow=T)
layout(mat, heights = c(1,1,1,1), width = c(0.23,1,1,1))

par(mar=c(5,1,1,1))
plot(NULL,
xlim=c(-1,1), ylim = c(0,102), xlab="", ylab="",tck=F, xaxt='n', yaxt='n',)
abline(v=0,lwd=0.5, lty=2, col='grey')
mtext(side=1, expression(bold(paste(Delta, ' Abnormal sperm', sep=" "))), cex=1, line=3.25)
axis(side=2, at= c(0,20,40,60,80,100), tck=0.03, labels=c(rep("",6)))
axis(side=4, at= c(0,20,40,60,80,100), tck=0.03, labels=c(rep("",6)))
axis(side=1, at= c(-1,-0.5,0,0.5,1), tck=-0.03, labels=c(rep("",5)))
mtext(c(-1,-0.5,0,0.5,1),at= c(-1,-0.5,0,0.5,1), line = 1, side=1, cex=0.8)
arrows(-0.9,1,-0.78,1+50*0.12,code=2,length=0.08,lwd=2,angle=45, col='grey40')
mtext(c(0,20,40,60,80,100),at= c(1,21,41,61,81,101), line = 1, side=2, cex=0.8, las=2)

points(jitter(TableClutchGenEPYYNAllMales$percEPY*100, factor=2)~TableClutchGenEPYYNAllMales$DeltalogAbnormal, pch= 21, cex=2, col='white', bg='black')
points(jitter(TableClutchGenEPYYNAllMalesJo$percEPY*100, factor=2)~TableClutchGenEPYYNAllMalesJo$DeltalogAbnormal, col='grey', pch=17, cex=1.5)
points(jitter(sanjaClutcheswithEPM$percEPY*100, factor=2)~sanjaClutcheswithEPM$DeltalogAbnormal, pch=0, cex=1.5)

mtext(side=2, 'Percentage of EPY
 in clutches with mixed paternity', cex=1, line=3.2, font=2)

XAbn <- seq(min(TableClutchGenEPYYNAllMales$DeltalogAbnormal, na.rm=T),max(TableClutchGenEPYYNAllMales$DeltalogAbnormal, na.rm=T), 0.0001)
yAbn <- (invlogit(estimatesDELTAAbn[1,1] + XAbn*estimatesDELTAAbn[2,1]))*100
lines(XAbn,yAbn, pch='.', cex=0.01)

 
 
 

par(mar=c(5,1,1,1))
plot(NULL,
xlim=c(-60,60), ylim = c(0,102), ylab="", xlab="", font.lab=2, yaxt='n', xaxt='n')
abline(v=0,lwd=0.5, lty=2, col='grey')
mtext(side=1, expression(bold(paste(Delta, ' Sperm Velocity', sep=" "))), cex=1, line=3.25)
axis(side=2, at= c(0,20,40,60,80,100), tck=0.03, labels=c(rep("",6)))
axis(side=4, at= c(0,20,40,60,80,100), tck=0.03, labels=c(rep("",6)))
axis(side=1, at= c(-60,-40,-20,0,20,40,60), tck=-0.03, labels=c(rep("",7)))
mtext(c(-60,-40,-20,0,20,40,60),at= c(-60,-40,-20,0,20,40,60), line = 1, side=1, cex=0.8)
arrows(56,100,48.8,100-50*0.12,code=2,length=0.08,lwd=2,angle=45, col='grey40')

points(jitter(TableClutchGenEPYYNAllMales$percEPY*100, factor=2)~TableClutchGenEPYYNAllMales$DeltaVCL0s, pch= 21, cex=2, col='white', bg='black')
points(jitter(TableClutchGenEPYYNAllMalesJo$percEPY*100, factor=2)~TableClutchGenEPYYNAllMalesJo$DeltaVCL0s, col='grey', pch=17, cex=1.5)
points(jitter(sanjaClutcheswithEPM$percEPY*100, factor=2)~sanjaClutcheswithEPM$DeltaVCL0s, pch=0, cex=1.5)


XVel <- seq(min(sanjaClutcheswithEPM$DeltaVCL0s, na.rm=T),max(TableClutchGenEPYYNAllMales$DeltaVCL0s, na.rm=T), 1)
yVel <- (invlogit(estimatesDELTAVel[1,1] + XVel*estimatesDELTAVel[2,1]))*100
lines(XVel,yVel, pch='.', cex=0.01)


par(mar=c(5,1,1,1))
plot(NULL,xlim=c(-15,15), ylim = c(0,102), ylab="", xlab="", cex.lab=1.4, font.lab=2, yaxt='n', xaxt='n')
abline(v=0,lwd=0.5, lty=2, col='grey')
axis(side=2, at= c(0,20,40,60,80,100), tck=0.03, labels=c(rep("",6)))
axis(side=4, at= c(0,20,40,60,80,100), tck=0.03, labels=c(rep("",6)))
mtext(side=1, expression(bold(paste(Delta, ' Sperm length', sep=" "))), cex=1, line=3.25)
axis(side=1, at= c(-15,-10,-5,0,5,10,15), tck=-0.03, labels=c(rep("",7)))
mtext(c(-15,-10,-5,0,5,10,15),at= c(-15,-10,-5,0,5,10,15), line = 1, side=1, cex=0.8)
arrows(13,100,11.2,100-50*0.12,code=2,length=0.08,lwd=2,angle=45, col='grey40')

points(jitter(TableClutchGenEPYYNAllMales$percEPY, factor=2)*100~TableClutchGenEPYYNAllMales$DeltaSlength,  pch= 21, cex=2, col='white', bg='black')
points(jitter(TableClutchGenEPYYNAllMalesJo$percEPY, factor=2)*100~TableClutchGenEPYYNAllMalesJo$DeltaSlength, col='grey', pch=17, cex=1.5)
points(jitter(sanjaClutcheswithEPM$percEPY, factor=2)*100~sanjaClutcheswithEPM$DeltaSlength, pch=0, cex=1.5)


XSlength <- seq(min(sanjaClutcheswithEPM$DeltaSlength, na.rm=T),max(TableClutchGenEPYYNAllMales$DeltaSlength, na.rm=T), 1)
ySlength  <- (invlogit(estimatesDELTASlength[1,1] + XSlength*estimatesDELTASlength[2,1]))*100
lines(XSlength,ySlength, pch='.', cex=0.01)


}

}








	#####################################################
	#### Joint-analysis over 3 data sets - Fitness MS ###
{	#####################################################
	
head(TableClutchAssFate0YNAllMales)
head(sanjaClutches)	
head(TableClutchAssFate0YNAllMalesJo)

{# combine the three data sets on clutches IF
subTableClutchAssFate0YNAllMales <- TableClutchAssFate0YNAllMales[,c('SocialMalePartner', 'MIDYear', 'Year', 'MTrt','ClutchSize', 'IFYN','logAbnormal', 'VCL0s', 'Slength', 'parentsID')]
colnames(subTableClutchAssFate0YNAllMales)[which(names(subTableClutchAssFate0YNAllMales) == "SocialMalePartner")] <- "MID"
subTableClutchAssFate0YNAllMales$InbredYN <- 0
subTableClutchAssFate0YNAllMales$FInbredYN <- 0
subTableClutchAssFate0YNAllMales$MTrt <- paste('Malika',subTableClutchAssFate0YNAllMales$MTrt, sep='')
colnames(subTableClutchAssFate0YNAllMales)[which(names(subTableClutchAssFate0YNAllMales) == "MTrt")] <- "Exp"
head(subTableClutchAssFate0YNAllMales)

subTableClutchAssFate0YNAllMalesJo <- TableClutchAssFate0YNAllMalesJo[,c('SocialMalePartner', 'ClutchSize','IFYN', 'logAbnormal', 'VCL0s', 'Slength', 'parentsID','InbredYN','FInbredYN')]
colnames(subTableClutchAssFate0YNAllMalesJo)[which(names(subTableClutchAssFate0YNAllMalesJo) == "SocialMalePartner")] <- "MID"
subTableClutchAssFate0YNAllMalesJo$Year <- 2012
subTableClutchAssFate0YNAllMalesJo$MIDYear <- paste(subTableClutchAssFate0YNAllMalesJo$MID,subTableClutchAssFate0YNAllMalesJo$Year, sep="")
subTableClutchAssFate0YNAllMalesJo$Exp <- 'Johannes'
head(subTableClutchAssFate0YNAllMalesJo)

subsanjaClutchesIF <- sanjaClutches[,c('MID', 'clutchsizeforIF','IFYN', 'logAbnormal', 'VCL0s', 'Slength', 'parentsID','InbredYN','FInbredYN')]
colnames(subsanjaClutchesIF)[which(names(subsanjaClutchesIF) == "clutchsizeforIF")] <- "ClutchSize"
subsanjaClutchesIF$Year <- 2009
subsanjaClutchesIF$MIDYear <- paste(subsanjaClutchesIF$MID,subsanjaClutchesIF$Year, sep="")
subsanjaClutchesIF$Exp <- 'Sanja'
head(subsanjaClutchesIF)


allClutchesIF <- rbind(subTableClutchAssFate0YNAllMales,subTableClutchAssFate0YNAllMalesJo,subsanjaClutchesIF)
allClutchesIF$ExpYear <- paste(allClutchesIF$Exp,allClutchesIF$Year, sep="")
}

head(allClutchesIF)

{# combined model IF
modallSpermTraitIF <- glmer (IFYN ~ scale(logAbnormal) + scale(VCL0s) + scale(Slength)  + 
									scale(ClutchSize)+ scale(InbredYN) + scale(FInbredYN) + Exp+
									(1|MIDYear) + (1|parentsID), 
									family = 'binomial', data = allClutchesIF)
summary(modallSpermTraitIF)

}



head(TableClutchGenEPYYNAllMales)
head(TableClutchGenEPYYNAllMalesJo)
head(sanjaClutches)	

{# combine the three data sets on clutches EPP
subTableClutchGenEPYYNAllMales <- TableClutchGenEPYYNAllMales[,c('SocialMalePartner', 'MIDYear', 'Year', 'ClutchSize','MTrt', 'EPYYN','MIDlogAbnormal', 'MIDVCL0s', 'MIDSlength', 'parentsID')]
colnames(subTableClutchGenEPYYNAllMales)[which(names(subTableClutchGenEPYYNAllMales) == "SocialMalePartner")] <- "MID"
colnames(subTableClutchGenEPYYNAllMales)[which(names(subTableClutchGenEPYYNAllMales) == "MIDlogAbnormal")] <- "logAbnormal"
colnames(subTableClutchGenEPYYNAllMales)[which(names(subTableClutchGenEPYYNAllMales) == "MIDVCL0s")] <- "VCL0s"
colnames(subTableClutchGenEPYYNAllMales)[which(names(subTableClutchGenEPYYNAllMales) == "MIDSlength")] <- "Slength"
subTableClutchGenEPYYNAllMales$InbredYN <- 0
subTableClutchGenEPYYNAllMales$FInbredYN <- 0
subTableClutchGenEPYYNAllMales$MTrt <- paste('Malika',subTableClutchGenEPYYNAllMales$MTrt, sep='')
colnames(subTableClutchGenEPYYNAllMales)[which(names(subTableClutchGenEPYYNAllMales) == "MTrt")] <- "Exp"
head(subTableClutchGenEPYYNAllMales)

subTableClutchGenEPYYNAllMalesJo <- TableClutchGenEPYYNAllMalesJo[,c('MID', 'ClutchSize','EPYYN', 'MIDlogAbnormal', 'MIDVCL0s', 'MIDSlength', 'parentsID','InbredYN','FInbredYN')]
colnames(subTableClutchGenEPYYNAllMalesJo)[which(names(subTableClutchGenEPYYNAllMalesJo) == "SocialMalePartner")] <- "MID"
colnames(subTableClutchGenEPYYNAllMalesJo)[which(names(subTableClutchGenEPYYNAllMalesJo) == "MIDlogAbnormal")] <- "logAbnormal"
colnames(subTableClutchGenEPYYNAllMalesJo)[which(names(subTableClutchGenEPYYNAllMalesJo) == "MIDVCL0s")] <- "VCL0s"
colnames(subTableClutchGenEPYYNAllMalesJo)[which(names(subTableClutchGenEPYYNAllMalesJo) == "MIDSlength")] <- "Slength"
subTableClutchGenEPYYNAllMalesJo$Year <- 2012
subTableClutchGenEPYYNAllMalesJo$MIDYear <- paste(subTableClutchGenEPYYNAllMalesJo$MID,subTableClutchGenEPYYNAllMalesJo$Year, sep="")
subTableClutchGenEPYYNAllMalesJo$Exp <- 'Johannes'
head(subTableClutchGenEPYYNAllMalesJo)

subsanjaClutchesEPP <- sanjaClutches[,c('MID', 'clutchsizeforEPP','EPPYN', 'logAbnormal', 'VCL0s', 'Slength', 'parentsID','InbredYN','FInbredYN')]
colnames(subsanjaClutchesEPP)[which(names(subsanjaClutchesEPP) == "clutchsizeforEPP")] <- "ClutchSize"
colnames(subsanjaClutchesEPP)[which(names(subsanjaClutchesEPP) == "EPPYN")] <- "EPYYN"
subsanjaClutchesEPP$Year <- 2009
subsanjaClutchesEPP$MIDYear <- paste(subsanjaClutchesEPP$MID,subsanjaClutchesEPP$Year, sep="")
subsanjaClutchesEPP$Exp <- 'Sanja'
head(subsanjaClutchesEPP)


allClutchesEPP <- rbind(subTableClutchGenEPYYNAllMales,subTableClutchGenEPYYNAllMalesJo,subsanjaClutchesEPP)

}

head(allClutchesEPP)

{# combined model EPP
modallSpermTraitEPPF <- glmer (EPYYN ~  scale(logAbnormal) + scale(VCL0s) + scale(Slength)  + 
										scale(InbredYN)  + Exp + #scale(ClutchSize)
										(1|MID)+(1|MIDYear) + (1|parentsID), 
										family = 'binomial', data = allClutchesEPP)
summary(modallSpermTraitEPPF)

modallSpermTraitEPP <- glmer (EPYYN ~  scale(logAbnormal) + scale(VCL0s) + scale(Slength) +  
										Exp + #scale(ClutchSize)
										(1|MID)+(1|MIDYear) + (1|parentsID), 
										family = 'binomial', data = allClutchesEPP)
summary(modallSpermTraitEPP)


	#ranef(modallSpermTraitEPP)
	#hist(unlist(ranef(modallSpermTraitEPP)$MIDYear))

}

}






	###############################################################
	#### Correlation between dependent var and between expl var ###
	###############################################################

head(allmalesqualities)
head(SpermTraitPerMale)
head(sanjaMalesplusExtra)
head(SpermTraitPerMaleJoplusSpare)

{## all correlations between 3 sperm traits per data sets per inbreds or outbreds
	
{# Malika

# Abnormal - VCL
modMalikaAbnVCL <- lm(scale(logAbnormal)~scale(VCL0s), data=SpermTraitPerMale)
summary(modMalikaAbnVCL)
estimatesMalikaAbnVCL <- coef(summary(modMalikaAbnVCL))
NMalikaAbnVCL <- nobs(modMalikaAbnVCL)


# Abnormal - Slength
modMalikaAbnSlength <- lm(scale(logAbnormal)~scale(Slength), data=SpermTraitPerMale)
summary(modMalikaAbnSlength)
estimatesMalikaAbnSlength <- coef(summary(modMalikaAbnSlength))
NMalikaAbnSlength <- nobs(modMalikaAbnSlength)

# VCL - Slength
modMalikaVCLSlength <- lm(scale(VCL0s)~scale(Slength), data=SpermTraitPerMale)
summary(modMalikaVCLSlength)
estimatesMalikaVCLSlength <- coef(summary(modMalikaVCLSlength))
NMalikaVCLSlength <- nobs(modMalikaVCLSlength)

}

{# Sanja + Extra

{# Abnormal - VCL

# inbreds
modSanjaAbnVCLin <- lm(scale(logAbnormal)~scale(VCL0s),
data=sanjaMalesplusExtra[!(is.na(sanjaMalesplusExtra$logAbnormal)) & !(is.na(sanjaMalesplusExtra$VCL0s)) & sanjaMalesplusExtra$InbredYN == 1,])
summary(modSanjaAbnVCLin)
estimatesSanjaAbnVCLin <- coef(summary(modSanjaAbnVCLin))
NSanjaAbnVCLin <- nobs(modSanjaAbnVCLin)

# outbreds
modSanjaAbnVCLout <- lm(scale(logAbnormal)~scale(VCL0s),
data=sanjaMalesplusExtra[!(is.na(sanjaMalesplusExtra$logAbnormal)) & !(is.na(sanjaMalesplusExtra$VCL0s)) & sanjaMalesplusExtra$InbredYN == 0,])
summary(modSanjaAbnVCLout)
estimatesSanjaAbnVCLout <- coef(summary(modSanjaAbnVCLout))
NSanjaAbnVCLout <- nobs(modSanjaAbnVCLout)

}

{# Abnormal - Slength

# inbreds
modSanjaAbnSlengthin <- lm(scale(logAbnormal)~scale(Slength),
data=sanjaMalesplusExtra[!(is.na(sanjaMalesplusExtra$logAbnormal)) & !(is.na(sanjaMalesplusExtra$Slength)) & sanjaMalesplusExtra$InbredYN == 1,])
summary(modSanjaAbnSlengthin)
estimatesSanjaAbnSlengthin <- coef(summary(modSanjaAbnSlengthin))
NSanjaAbnSlengthin <- nobs(modSanjaAbnSlengthin)

# outbreds
modSanjaAbnSlengthout <- lm(scale(logAbnormal)~scale(Slength),
data=sanjaMalesplusExtra[!(is.na(sanjaMalesplusExtra$logAbnormal)) & !(is.na(sanjaMalesplusExtra$Slength)) & sanjaMalesplusExtra$InbredYN == 0,])
summary(modSanjaAbnSlengthout)
estimatesSanjaAbnSlengthout <- coef(summary(modSanjaAbnSlengthout))
NSanjaAbnSlengthout <- nobs(modSanjaAbnSlengthout)

}

{# VCL - Slength

# inbreds
modSanjaVCLSlengthin <- lm(scale(VCL0s)~scale(Slength),
data=sanjaMalesplusExtra[!(is.na(sanjaMalesplusExtra$VCL0s)) & !(is.na(sanjaMalesplusExtra$Slength)) & sanjaMalesplusExtra$InbredYN == 1,])
summary(modSanjaVCLSlengthin)
estimatesSanjaVCLSlengthin <- coef(summary(modSanjaVCLSlengthin))
NSanjaVCLSlengthin <- nobs(modSanjaVCLSlengthin)

# outbreds
modSanjaVCLSlengthout <- lm(scale(VCL0s)~scale(Slength),
data=sanjaMalesplusExtra[!(is.na(sanjaMalesplusExtra$VCL0s)) & !(is.na(sanjaMalesplusExtra$Slength)) & sanjaMalesplusExtra$InbredYN == 0,])
summary(modSanjaVCLSlengthout)
estimatesSanjaVCLSlengthout <- coef(summary(modSanjaVCLSlengthout))
NSanjaVCLSlengthout <- nobs(modSanjaVCLSlengthout)

}

}

{# Johannes + Spare

{# Abnormal - VCL 

	cor.test(SpermTraitPerMaleJo$pre2012logAbnormal,SpermTraitPerMaleJo$pre2012VCL0s) # r = -0.410961 ; p = 0.01946*
	plot(SpermTraitPerMaleJo$pre2012logAbnormal,SpermTraitPerMaleJo$pre2012VCL0s)


# inbreds
modJohannesAbnVCLin <- lm(scale(logAbnormal)~scale(VCL0s),
data=SpermTraitPerMaleJoplusSpare[!(is.na(SpermTraitPerMaleJoplusSpare$logAbnormal)) & !(is.na(SpermTraitPerMaleJoplusSpare$VCL0s)) & SpermTraitPerMaleJoplusSpare$InbredYN == 1,])
summary(modJohannesAbnVCLin)
estimatesJohannesAbnVCLin <- coef(summary(modJohannesAbnVCLin))
NJohannesAbnVCLin <- nobs(modJohannesAbnVCLin)

# outbreds
modJohannesAbnVCLout <- lm(scale(logAbnormal)~scale(VCL0s),
data=SpermTraitPerMaleJoplusSpare[!(is.na(SpermTraitPerMaleJoplusSpare$logAbnormal)) & !(is.na(SpermTraitPerMaleJoplusSpare$VCL0s)) & SpermTraitPerMaleJoplusSpare$InbredYN == 0,])
summary(modJohannesAbnVCLout)
estimatesJohannesAbnVCLout <- coef(summary(modJohannesAbnVCLout))
NJohannesAbnVCLout <- nobs(modJohannesAbnVCLout)	
		

}	

{# Abnormal - Slength	

# inbreds
modJohannesAbnSlengthin <- lm(scale(logAbnormal)~scale(Slength),
data=SpermTraitPerMaleJoplusSpare[!(is.na(SpermTraitPerMaleJoplusSpare$logAbnormal)) & !(is.na(SpermTraitPerMaleJoplusSpare$Slength)) & SpermTraitPerMaleJoplusSpare$InbredYN == 1,])
summary(modJohannesAbnSlengthin)
estimatesJohannesAbnSlengthin <- coef(summary(modJohannesAbnSlengthin))
NJohannesAbnSlengthin <- nobs(modJohannesAbnSlengthin)

# outbreds
modJohannesAbnSlengthout <- lm(scale(logAbnormal)~scale(Slength),
data=SpermTraitPerMaleJoplusSpare[!(is.na(SpermTraitPerMaleJoplusSpare$logAbnormal)) & !(is.na(SpermTraitPerMaleJoplusSpare$Slength)) & SpermTraitPerMaleJoplusSpare$InbredYN == 0,])
summary(modJohannesAbnSlengthout)
estimatesJohannesAbnSlengthout <- coef(summary(modJohannesAbnSlengthout))
NJohannesAbnSlengthout <- nobs(modJohannesAbnSlengthout)	

}

{# VCL - Slength

# inbreds
modJohannesVCLSlengthin <- lm(scale(VCL0s)~scale(Slength),
data=SpermTraitPerMaleJoplusSpare[!(is.na(SpermTraitPerMaleJoplusSpare$VCL0s)) & !(is.na(SpermTraitPerMaleJoplusSpare$Slength)) & SpermTraitPerMaleJoplusSpare$InbredYN == 1,])
summary(modJohannesVCLSlengthin)
estimatesJohannesVCLSlengthin <- coef(summary(modJohannesVCLSlengthin))
NJohannesVCLSlengthin <- nobs(modJohannesVCLSlengthin)

# outbreds
modJohannesVCLSlengthout <- lm(scale(VCL0s)~scale(Slength),
data=SpermTraitPerMaleJoplusSpare[!(is.na(SpermTraitPerMaleJoplusSpare$VCL0s)) & !(is.na(SpermTraitPerMaleJoplusSpare$Slength)) & SpermTraitPerMaleJoplusSpare$InbredYN == 0,])
summary(modJohannesVCLSlengthout)
estimatesJohannesVCLSlengthout <- coef(summary(modJohannesVCLSlengthout))
NJohannesVCLSlengthout <- nobs(modJohannesVCLSlengthout)	


}

}

}

{## meta-analysis per sperm trait correlation: pooled 5 correlation coefficients

{# meta analysis Abn - VCL

metaAbnVCL <- data.frame('study' = c('Malika', 'SanjaIn', 'SanjaOut', 'JohannesIn','JohannesOut'))

metaAbnVCL$est[metaAbnVCL$study == 'Malika'] <- estimatesMalikaAbnVCL[2,1]
metaAbnVCL$SE[metaAbnVCL$study == 'Malika'] <- estimatesMalikaAbnVCL[2,2]
metaAbnVCL$lower[metaAbnVCL$study == 'Malika'] <- estimatesMalikaAbnVCL[2,1]-1.96*estimatesMalikaAbnVCL[2,2]
metaAbnVCL$upper[metaAbnVCL$study == 'Malika'] <- estimatesMalikaAbnVCL[2,1]+1.96*estimatesMalikaAbnVCL[2,2]


metaAbnVCL$est[metaAbnVCL$study == 'SanjaIn'] <- estimatesSanjaAbnVCLin[2,1]
metaAbnVCL$SE[metaAbnVCL$study == 'SanjaIn'] <- estimatesSanjaAbnVCLin[2,2]
metaAbnVCL$lower[metaAbnVCL$study == 'SanjaIn'] <- estimatesSanjaAbnVCLin[2,1]-1.96*estimatesSanjaAbnVCLin[2,2]
metaAbnVCL$upper[metaAbnVCL$study == 'SanjaIn'] <- estimatesSanjaAbnVCLin[2,1]+1.96*estimatesSanjaAbnVCLin[2,2]

metaAbnVCL$est[metaAbnVCL$study == 'SanjaOut'] <- estimatesSanjaAbnVCLout[2,1]
metaAbnVCL$SE[metaAbnVCL$study == 'SanjaOut'] <- estimatesSanjaAbnVCLout[2,2]
metaAbnVCL$lower[metaAbnVCL$study == 'SanjaOut'] <- estimatesSanjaAbnVCLout[2,1]-1.96*estimatesSanjaAbnVCLout[2,2]
metaAbnVCL$upper[metaAbnVCL$study == 'SanjaOut'] <- estimatesSanjaAbnVCLout[2,1]+1.96*estimatesSanjaAbnVCLout[2,2]



metaAbnVCL$est[metaAbnVCL$study == 'JohannesIn'] <- estimatesJohannesAbnVCLin[2,1]
metaAbnVCL$SE[metaAbnVCL$study == 'JohannesIn'] <- estimatesJohannesAbnVCLin[2,2]
metaAbnVCL$lower[metaAbnVCL$study == 'JohannesIn'] <- estimatesJohannesAbnVCLin[2,1]-1.96*estimatesJohannesAbnVCLin[2,2]
metaAbnVCL$upper[metaAbnVCL$study == 'JohannesIn'] <- estimatesJohannesAbnVCLin[2,1]+1.96*estimatesJohannesAbnVCLin[2,2]

metaAbnVCL$est[metaAbnVCL$study == 'JohannesOut'] <- estimatesJohannesAbnVCLout[2,1]
metaAbnVCL$SE[metaAbnVCL$study == 'JohannesOut'] <- estimatesJohannesAbnVCLout[2,2]
metaAbnVCL$lower[metaAbnVCL$study == 'JohannesOut'] <- estimatesJohannesAbnVCLout[2,1]-1.96*estimatesJohannesAbnVCLout[2,2]
metaAbnVCL$upper[metaAbnVCL$study == 'JohannesOut'] <- estimatesJohannesAbnVCLout[2,1]+1.96*estimatesJohannesAbnVCLout[2,2]


summarymetaAbnVCL <- meta.summaries(metaAbnVCL$est, metaAbnVCL$SE, names=metaAbnVCL$study, method="fixed")

rAbnVCL <- summarymetaAbnVCL$summary
lowerAbnVCL <- summarymetaAbnVCL$summary+1.96*summarymetaAbnVCL$se
upperAbnVCL <- summarymetaAbnVCL$summary-1.96*summarymetaAbnVCL$se

}

{# meta analysis Abn - Slength

metaAbnSlength <-  data.frame('study' = c('Malika', 'SanjaIn', 'SanjaOut', 'JohannesIn','JohannesOut'))

metaAbnSlength$est[metaAbnSlength$study == 'Malika'] <- estimatesMalikaAbnSlength[2,1]
metaAbnSlength$SE[metaAbnSlength$study == 'Malika'] <- estimatesMalikaAbnSlength[2,2]
metaAbnSlength$lower[metaAbnSlength$study == 'Malika'] <- estimatesMalikaAbnSlength[2,1]-1.96*estimatesMalikaAbnSlength[2,2]
metaAbnSlength$upper[metaAbnSlength$study == 'Malika'] <- estimatesMalikaAbnSlength[2,1]+1.96*estimatesMalikaAbnSlength[2,2]


metaAbnSlength$est[metaAbnSlength$study == 'SanjaIn'] <- estimatesSanjaAbnSlengthin[2,1]
metaAbnSlength$SE[metaAbnSlength$study == 'SanjaIn'] <- estimatesSanjaAbnSlengthin[2,2]
metaAbnSlength$lower[metaAbnSlength$study == 'SanjaIn'] <- estimatesSanjaAbnSlengthin[2,1]-1.96*estimatesSanjaAbnSlengthin[2,2]
metaAbnSlength$upper[metaAbnSlength$study == 'SanjaIn'] <- estimatesSanjaAbnSlengthin[2,1]+1.96*estimatesSanjaAbnSlengthin[2,2]



metaAbnSlength$est[metaAbnSlength$study == 'SanjaOut'] <- estimatesSanjaAbnSlengthout[2,1]
metaAbnSlength$SE[metaAbnSlength$study == 'SanjaOut'] <- estimatesSanjaAbnSlengthout[2,2]
metaAbnSlength$lower[metaAbnSlength$study == 'SanjaOut'] <- estimatesSanjaAbnSlengthout[2,1]-1.96*estimatesSanjaAbnSlengthout[2,2]
metaAbnSlength$upper[metaAbnSlength$study == 'SanjaOut'] <- estimatesSanjaAbnSlengthout[2,1]+1.96*estimatesSanjaAbnSlengthout[2,2]


metaAbnSlength$est[metaAbnSlength$study == 'JohannesIn'] <- estimatesJohannesAbnSlengthin[2,1]
metaAbnSlength$SE[metaAbnSlength$study == 'JohannesIn'] <- estimatesJohannesAbnSlengthin[2,2]
metaAbnSlength$lower[metaAbnSlength$study == 'JohannesIn'] <- estimatesJohannesAbnSlengthin[2,1]-1.96*estimatesJohannesAbnSlengthin[2,2]
metaAbnSlength$upper[metaAbnSlength$study == 'JohannesIn'] <- estimatesJohannesAbnSlengthin[2,1]+1.96*estimatesJohannesAbnSlengthin[2,2]


metaAbnSlength$est[metaAbnSlength$study == 'JohannesOut'] <- estimatesJohannesAbnSlengthout[2,1]
metaAbnSlength$SE[metaAbnSlength$study == 'JohannesOut'] <- estimatesJohannesAbnSlengthout[2,2]
metaAbnSlength$lower[metaAbnSlength$study == 'JohannesOut'] <- estimatesJohannesAbnSlengthout[2,1]-1.96*estimatesJohannesAbnSlengthout[2,2]
metaAbnSlength$upper[metaAbnSlength$study == 'JohannesOut'] <- estimatesJohannesAbnSlengthout[2,1]+1.96*estimatesJohannesAbnSlengthout[2,2]


summarymetaAbnSlength <- meta.summaries(metaAbnSlength$est, metaAbnSlength$SE, names=metaAbnSlength$study, method="fixed")

rAbnSlength <- summarymetaAbnSlength$summary
lowerAbnSlength <- summarymetaAbnSlength$summary+1.96*summarymetaAbnSlength$se
upperAbnSlength <- summarymetaAbnSlength$summary-1.96*summarymetaAbnSlength$se

}

{# meta analysis VCL - Slength

metaVCLSlength <- data.frame('study' = c('Malika', 'SanjaIn', 'SanjaOut', 'JohannesIn','JohannesOut'))

metaVCLSlength$est[metaVCLSlength$study == 'Malika'] <- estimatesMalikaVCLSlength[2,1]
metaVCLSlength$SE[metaVCLSlength$study == 'Malika'] <- estimatesMalikaVCLSlength[2,2]
metaVCLSlength$lower[metaVCLSlength$study == 'Malika'] <- estimatesMalikaVCLSlength[2,1]-1.96*estimatesMalikaVCLSlength[2,2]
metaVCLSlength$upper[metaVCLSlength$study == 'Malika'] <- estimatesMalikaVCLSlength[2,1]+1.96*estimatesMalikaVCLSlength[2,2]


metaVCLSlength$est[metaVCLSlength$study == 'SanjaIn'] <- estimatesSanjaVCLSlengthin[2,1]
metaVCLSlength$SE[metaVCLSlength$study == 'SanjaIn'] <- estimatesSanjaVCLSlengthin[2,2]
metaVCLSlength$lower[metaVCLSlength$study == 'SanjaIn'] <- estimatesSanjaVCLSlengthin[2,1]-1.96*estimatesSanjaVCLSlengthin[2,2]
metaVCLSlength$upper[metaVCLSlength$study == 'SanjaIn'] <- estimatesSanjaVCLSlengthin[2,1]+1.96*estimatesSanjaVCLSlengthin[2,2]


metaVCLSlength$est[metaVCLSlength$study == 'SanjaOut'] <- estimatesSanjaVCLSlengthout[2,1]
metaVCLSlength$SE[metaVCLSlength$study == 'SanjaOut'] <- estimatesSanjaVCLSlengthout[2,2]
metaVCLSlength$lower[metaVCLSlength$study == 'SanjaOut'] <- estimatesSanjaVCLSlengthout[2,1]-1.96*estimatesSanjaVCLSlengthout[2,2]
metaVCLSlength$upper[metaVCLSlength$study == 'SanjaOut'] <- estimatesSanjaVCLSlengthout[2,1]+1.96*estimatesSanjaVCLSlengthout[2,2]



metaVCLSlength$est[metaVCLSlength$study == 'JohannesIn'] <- estimatesJohannesVCLSlengthin[2,1]
metaVCLSlength$SE[metaVCLSlength$study == 'JohannesIn'] <- estimatesJohannesVCLSlengthin[2,2]
metaVCLSlength$lower[metaVCLSlength$study == 'JohannesIn'] <- estimatesJohannesVCLSlengthin[2,1]-1.96*estimatesJohannesVCLSlengthin[2,2]
metaVCLSlength$upper[metaVCLSlength$study == 'JohannesIn'] <- estimatesJohannesVCLSlengthin[2,1]+1.96*estimatesJohannesVCLSlengthin[2,2]

metaVCLSlength$est[metaVCLSlength$study == 'JohannesOut'] <- estimatesJohannesVCLSlengthout[2,1]
metaVCLSlength$SE[metaVCLSlength$study == 'JohannesOut'] <- estimatesJohannesVCLSlengthout[2,2]
metaVCLSlength$lower[metaVCLSlength$study == 'JohannesOut'] <- estimatesJohannesVCLSlengthout[2,1]-1.96*estimatesJohannesVCLSlengthout[2,2]
metaVCLSlength$upper[metaVCLSlength$study == 'JohannesOut'] <- estimatesJohannesVCLSlengthout[2,1]+1.96*estimatesJohannesVCLSlengthout[2,2]

summarymetaVCLSlength <- meta.summaries(metaVCLSlength$est, metaVCLSlength$SE, names=metaVCLSlength$study, method="fixed")

rVCLSlength <- summarymetaVCLSlength$summary
lowerVCLSlength <- summarymetaVCLSlength$summary+1.96*summarymetaVCLSlength$se
upperVCLSlength <- summarymetaVCLSlength$summary-1.96*summarymetaVCLSlength$se


}

}

{## table corrspermtraits

corrspermtraits <- data.frame('corr' = c('AbnVCL', 'AbnSlength', 'VCLSlength'))
corrspermtraits$r <- rbind(rAbnVCL,rAbnSlength, rVCLSlength)
corrspermtraits$lower <- rbind(lowerAbnVCL,lowerAbnSlength, lowerVCLSlength)
corrspermtraits$upper <- rbind(upperAbnVCL,upperAbnSlength, upperVCLSlength)
corrspermtraits$NMales <- rbind(sum(NMalikaAbnVCL,NSanjaAbnVCLin,NSanjaAbnVCLout, NJohannesAbnVCLin,NJohannesAbnVCLout),
						   sum(NMalikaAbnSlength,NSanjaAbnSlengthin,NSanjaAbnSlengthout, NJohannesAbnSlengthin,NJohannesAbnSlengthout),
						   sum(NMalikaVCLSlength,NSanjaVCLSlengthin,NSanjaVCLSlengthout, NJohannesVCLSlengthin,NJohannesVCLSlengthout))
corrspermtraits
}


{## correlations between 3 phenotypic traits per data sets per inbreds or outbreds
	
{# Malika

{# courtship rate - beak color
modMalikaBeakDisplay <- lm(scale(MeansqrtSumAllDisplaySecRate)~scale(BeakColor), 
data=SpermTraitPerMale)
summary(modMalikaBeakDisplay)
estimatesMalikaBeakDisplay <- coef(summary(modMalikaBeakDisplay))
NMalikaBeakDisplay <- nobs(modMalikaBeakDisplay)
}

{# courtship rate - Tarsus
modMalikaDisplayTarsus <- lm(scale(MeansqrtSumAllDisplaySecRate)~scale(Tarsus), 
data=SpermTraitPerMale)
summary(modMalikaDisplayTarsus)
estimatesMalikaDisplayTarsus <- coef(summary(modMalikaDisplayTarsus))
NMalikaDisplayTarsus <- nobs(modMalikaDisplayTarsus)
}

{# beak color - Tarsus
modMalikaBeakTarsus <- lm(scale(BeakColor)~scale(Tarsus), 
data=SpermTraitPerMale)
summary(modMalikaBeakTarsus)
estimatesMalikaBeakTarsus <- coef(summary(modMalikaBeakTarsus))
NMalikaBeakTarsus <- nobs(modMalikaBeakTarsus)

SpermTraitPerMale$MID[is.na(SpermTraitPerMale$Tarsus)]

}

}

{# Sanja

{# courtship rate - beak color
#inbreds
modSanjaBeakDisplayin <- lm(scale(BeakColourScore)~scale(sqrtSumAllDisplaySecRate), 
data=sanjaMales[!(is.na(sanjaMales$BeakColourScore)) & !(is.na(sanjaMales$sqrtSumAllDisplaySecRate))& sanjaMales$Fshort == 0.25,])
summary(modSanjaBeakDisplayin)
estimatesSanjaBeakDisplayin <- coef(summary(modSanjaBeakDisplayin))
NSanjaBeakDisplayin <- nobs(modSanjaBeakDisplayin)

#outbreds
modSanjaBeakDisplayout <- lm(scale(BeakColourScore)~scale(sqrtSumAllDisplaySecRate), 
data=sanjaMales[!(is.na(sanjaMales$BeakColourScore)) & !(is.na(sanjaMales$sqrtSumAllDisplaySecRate))& sanjaMales$Fshort < 0.25,])
summary(modSanjaBeakDisplayout)
estimatesSanjaBeakDisplayout <- coef(summary(modSanjaBeakDisplayout))
NSanjaBeakDisplayout <- nobs(modSanjaBeakDisplayout)
}

{# courtship rate - Tarsus
#inbreds
modSanjaDisplayTarsusin <- lm(scale(Tarsus)~scale(sqrtSumAllDisplaySecRate), 
data=sanjaMales[!(is.na(sanjaMales$Tarsus)) & !(is.na(sanjaMales$sqrtSumAllDisplaySecRate))& sanjaMales$Fshort == 0.25,])
summary(modSanjaDisplayTarsusin)
estimatesSanjaDisplayTarsusin <- coef(summary(modSanjaDisplayTarsusin))
NSanjaDisplayTarsusin <- nobs(modSanjaDisplayTarsusin)

#outbreds
modSanjaDisplayTarsusout <- lm(scale(Tarsus)~scale(sqrtSumAllDisplaySecRate), 
data=sanjaMales[!(is.na(sanjaMales$Tarsus)) & !(is.na(sanjaMales$sqrtSumAllDisplaySecRate))& sanjaMales$Fshort < 0.25,])
summary(modSanjaDisplayTarsusout)
estimatesSanjaDisplayTarsusout <- coef(summary(modSanjaDisplayTarsusout))
NSanjaDisplayTarsusout <- nobs(modSanjaDisplayTarsusout)
}

{# beak color - Tarsus !!! including extra domesticated !!!
#inbreds
modSanjaplusExtraBeakTarsusin <- lm(scale(Tarsus)~scale(BeakColourScore), 
data=sanjaMalesplusExtra[!(is.na(sanjaMalesplusExtra$Tarsus)) & !(is.na(sanjaMalesplusExtra$BeakColourScore))& sanjaMalesplusExtra$InbredYN == 1,])
summary(modSanjaplusExtraBeakTarsusin)
estimatesSanjaplusExtraBeakTarsusin <- coef(summary(modSanjaplusExtraBeakTarsusin))
NSanjaplusExtraBeakTarsusin <- nobs(modSanjaplusExtraBeakTarsusin)

#outbreds
modSanjaplusExtraBeakTarsusout <- lm(scale(Tarsus)~scale(BeakColourScore), 
data=sanjaMalesplusExtra[!(is.na(sanjaMalesplusExtra$Tarsus)) & !(is.na(sanjaMalesplusExtra$BeakColourScore))& sanjaMalesplusExtra$InbredYN == 0,])
summary(modSanjaplusExtraBeakTarsusout)
estimatesSanjaplusExtraBeakTarsusout <- coef(summary(modSanjaplusExtraBeakTarsusout))
NSanjaplusExtraBeakTarsusout <- nobs(modSanjaplusExtraBeakTarsusout)
}

}

{# Johannes

{# courtship rate - beak color
#inbreds
modJohannesBeakDisplayin <- lm(scale(BeakColourScore)~scale(SqrtSumAllDisplaySecRate), 
data=SpermTraitPerMaleJo[!(is.na(SpermTraitPerMaleJo$BeakColourScore)) & !(is.na(SpermTraitPerMaleJo$SqrtSumAllDisplaySecRate))& SpermTraitPerMaleJo$Fshort == 0.25,])
summary(modJohannesBeakDisplayin)
estimatesJohannesBeakDisplayin <- coef(summary(modJohannesBeakDisplayin))
NJohannesBeakDisplayin <- nobs(modJohannesBeakDisplayin)

#outbreds
modJohannesBeakDisplayout <- lm(scale(BeakColourScore)~scale(SqrtSumAllDisplaySecRate), 
data=SpermTraitPerMaleJo[!(is.na(SpermTraitPerMaleJo$BeakColourScore)) & !(is.na(SpermTraitPerMaleJo$SqrtSumAllDisplaySecRate))& SpermTraitPerMaleJo$Fshort < 0.25,])
summary(modJohannesBeakDisplayout)
estimatesJohannesBeakDisplayout <- coef(summary(modJohannesBeakDisplayout))
NJohannesBeakDisplayout <- nobs(modJohannesBeakDisplayout)
}

{# courtship rate - Tarsus
#inbreds
modJohannesDisplayTarsusin <- lm(scale(Tarsus)~scale(SqrtSumAllDisplaySecRate), 
data=SpermTraitPerMaleJo[!(is.na(SpermTraitPerMaleJo$Tarsus)) & !(is.na(SpermTraitPerMaleJo$SqrtSumAllDisplaySecRate))& SpermTraitPerMaleJo$Fshort == 0.25,])
summary(modJohannesDisplayTarsusin)
estimatesJohannesDisplayTarsusin <- coef(summary(modJohannesDisplayTarsusin))
NJohannesDisplayTarsusin <- nobs(modJohannesDisplayTarsusin)

#outbreds
modJohannesDisplayTarsusout <- lm(scale(Tarsus)~scale(SqrtSumAllDisplaySecRate), 
data=SpermTraitPerMaleJo[!(is.na(SpermTraitPerMaleJo$Tarsus)) & !(is.na(SpermTraitPerMaleJo$SqrtSumAllDisplaySecRate))& SpermTraitPerMaleJo$Fshort < 0.25,])
summary(modJohannesDisplayTarsusout)
estimatesJohannesDisplayTarsusout <- coef(summary(modJohannesDisplayTarsusout))
NJohannesDisplayTarsusout <- nobs(modJohannesDisplayTarsusout)
}

{# Beak - Tarsus !!! including spare Johannes !!!
#inbreds
modJohannesplusSpareBeakTarsusin <- lm(scale(BeakColourScore)~scale(Tarsus), 
data=SpermTraitPerMaleJoplusSpare[!(is.na(SpermTraitPerMaleJoplusSpare$Tarsus)) & !(is.na(SpermTraitPerMaleJoplusSpare$BeakColourScore))& SpermTraitPerMaleJoplusSpare$InbredYN == 1,])
summary(modJohannesplusSpareBeakTarsusin)
estimatesJohannesplusSpareBeakTarsusin <- coef(summary(modJohannesplusSpareBeakTarsusin))
NJohannesplusSpareBeakTarsusin <- nobs(modJohannesplusSpareBeakTarsusin)

#outbreds
modJohannesplusSpareBeakTarsusout <- lm(scale(Tarsus)~scale(BeakColourScore), 
data=SpermTraitPerMaleJoplusSpare[!(is.na(SpermTraitPerMaleJoplusSpare$Tarsus)) & !(is.na(SpermTraitPerMaleJoplusSpare$BeakColourScore))& SpermTraitPerMaleJoplusSpare$InbredYN == 0,])
summary(modJohannesplusSpareBeakTarsusout)
estimatesJohannesplusSpareBeakTarsusout <- coef(summary(modJohannesplusSpareBeakTarsusout))
NJohannesplusSpareBeakTarsusout <- nobs(modJohannesplusSpareBeakTarsusout)
}

}

}

{## meta analysis beak color - display : pooled 5 elatin coefficients

{# meta analysis Beak - Display
metaBeakDisplay <- data.frame('study' = c('Malika', 'SanjaIn', 'SanjaOut', 'JohannesIn','JohannesOut'))

metaBeakDisplay$est[metaBeakDisplay$study == 'Malika'] <- estimatesMalikaBeakDisplay[2,1]
metaBeakDisplay$SE[metaBeakDisplay$study == 'Malika'] <- estimatesMalikaBeakDisplay[2,2]
metaBeakDisplay$lower[metaBeakDisplay$study == 'Malika'] <- estimatesMalikaBeakDisplay[2,1]-1.96*estimatesMalikaBeakDisplay[2,2]
metaBeakDisplay$upper[metaBeakDisplay$study == 'Malika'] <- estimatesMalikaBeakDisplay[2,1]+1.96*estimatesMalikaBeakDisplay[2,2]


metaBeakDisplay$est[metaBeakDisplay$study == 'SanjaIn'] <- estimatesSanjaBeakDisplayin[2,1]
metaBeakDisplay$SE[metaBeakDisplay$study == 'SanjaIn'] <- estimatesSanjaBeakDisplayin[2,2]
metaBeakDisplay$lower[metaBeakDisplay$study == 'SanjaIn'] <- estimatesSanjaBeakDisplayin[2,1]-1.96*estimatesSanjaBeakDisplayin[2,2]
metaBeakDisplay$upper[metaBeakDisplay$study == 'SanjaIn'] <- estimatesSanjaBeakDisplayin[2,1]+1.96*estimatesSanjaBeakDisplayin[2,2]

metaBeakDisplay$est[metaBeakDisplay$study == 'SanjaOut'] <- estimatesSanjaBeakDisplayout[2,1]
metaBeakDisplay$SE[metaBeakDisplay$study == 'SanjaOut'] <- estimatesSanjaBeakDisplayout[2,2]
metaBeakDisplay$lower[metaBeakDisplay$study == 'SanjaOut'] <- estimatesSanjaBeakDisplayout[2,1]-1.96*estimatesSanjaBeakDisplayout[2,2]
metaBeakDisplay$upper[metaBeakDisplay$study == 'SanjaOut'] <- estimatesSanjaBeakDisplayout[2,1]+1.96*estimatesSanjaBeakDisplayout[2,2]


metaBeakDisplay$est[metaBeakDisplay$study == 'JohannesIn'] <- estimatesJohannesBeakDisplayin[2,1]
metaBeakDisplay$SE[metaBeakDisplay$study == 'JohannesIn'] <- estimatesJohannesBeakDisplayin[2,2]
metaBeakDisplay$lower[metaBeakDisplay$study == 'JohannesIn'] <- estimatesJohannesBeakDisplayin[2,1]-1.96*estimatesJohannesBeakDisplayin[2,2]
metaBeakDisplay$upper[metaBeakDisplay$study == 'JohannesIn'] <- estimatesJohannesBeakDisplayin[2,1]+1.96*estimatesJohannesBeakDisplayin[2,2]

metaBeakDisplay$est[metaBeakDisplay$study == 'JohannesOut'] <- estimatesJohannesBeakDisplayout[2,1]
metaBeakDisplay$SE[metaBeakDisplay$study == 'JohannesOut'] <- estimatesJohannesBeakDisplayout[2,2]
metaBeakDisplay$lower[metaBeakDisplay$study == 'JohannesOut'] <- estimatesJohannesBeakDisplayout[2,1]-1.96*estimatesJohannesBeakDisplayout[2,2]
metaBeakDisplay$upper[metaBeakDisplay$study == 'JohannesOut'] <- estimatesJohannesBeakDisplayout[2,1]+1.96*estimatesJohannesBeakDisplayout[2,2]

summarymetaBeakDisplay <- meta.summaries(metaBeakDisplay$est, metaBeakDisplay$SE, names=metaBeakDisplay$study, method="fixed")

rBeakDisplay <- summarymetaBeakDisplay$summary
lowerBeakDisplay <- summarymetaBeakDisplay$summary+1.96*summarymetaBeakDisplay$se
upperBeakDisplay <- summarymetaBeakDisplay$summary-1.96*summarymetaBeakDisplay$se

}

{# meta analysis Display  - Tarsus
metaDisplayTarsus <- data.frame('study' = c('Malika', 'SanjaIn', 'SanjaOut', 'JohannesIn','JohannesOut'))

metaDisplayTarsus$est[metaDisplayTarsus$study == 'Malika'] <- estimatesMalikaDisplayTarsus[2,1]
metaDisplayTarsus$SE[metaDisplayTarsus$study == 'Malika'] <- estimatesMalikaDisplayTarsus[2,2]
metaDisplayTarsus$lower[metaDisplayTarsus$study == 'Malika'] <- estimatesMalikaDisplayTarsus[2,1]-1.96*estimatesMalikaDisplayTarsus[2,2]
metaDisplayTarsus$upper[metaDisplayTarsus$study == 'Malika'] <- estimatesMalikaDisplayTarsus[2,1]+1.96*estimatesMalikaDisplayTarsus[2,2]


metaDisplayTarsus$est[metaDisplayTarsus$study == 'SanjaIn'] <- estimatesSanjaDisplayTarsusin[2,1]
metaDisplayTarsus$SE[metaDisplayTarsus$study == 'SanjaIn'] <- estimatesSanjaDisplayTarsusin[2,2]
metaDisplayTarsus$lower[metaDisplayTarsus$study == 'SanjaIn'] <- estimatesSanjaDisplayTarsusin[2,1]-1.96*estimatesSanjaDisplayTarsusin[2,2]
metaDisplayTarsus$upper[metaDisplayTarsus$study == 'SanjaIn'] <- estimatesSanjaDisplayTarsusin[2,1]+1.96*estimatesSanjaDisplayTarsusin[2,2]

metaDisplayTarsus$est[metaDisplayTarsus$study == 'SanjaOut'] <- estimatesSanjaDisplayTarsusout[2,1]
metaDisplayTarsus$SE[metaDisplayTarsus$study == 'SanjaOut'] <- estimatesSanjaDisplayTarsusout[2,2]
metaDisplayTarsus$lower[metaDisplayTarsus$study == 'SanjaOut'] <- estimatesSanjaDisplayTarsusout[2,1]-1.96*estimatesSanjaDisplayTarsusout[2,2]
metaDisplayTarsus$upper[metaDisplayTarsus$study == 'SanjaOut'] <- estimatesSanjaDisplayTarsusout[2,1]+1.96*estimatesSanjaDisplayTarsusout[2,2]


metaDisplayTarsus$est[metaDisplayTarsus$study == 'JohannesIn'] <- estimatesJohannesDisplayTarsusin[2,1]
metaDisplayTarsus$SE[metaDisplayTarsus$study == 'JohannesIn'] <- estimatesJohannesDisplayTarsusin[2,2]
metaDisplayTarsus$lower[metaDisplayTarsus$study == 'JohannesIn'] <- estimatesJohannesDisplayTarsusin[2,1]-1.96*estimatesJohannesDisplayTarsusin[2,2]
metaDisplayTarsus$upper[metaDisplayTarsus$study == 'JohannesIn'] <- estimatesJohannesDisplayTarsusin[2,1]+1.96*estimatesJohannesDisplayTarsusin[2,2]

metaDisplayTarsus$est[metaDisplayTarsus$study == 'JohannesOut'] <- estimatesJohannesDisplayTarsusout[2,1]
metaDisplayTarsus$SE[metaDisplayTarsus$study == 'JohannesOut'] <- estimatesJohannesDisplayTarsusout[2,2]
metaDisplayTarsus$lower[metaDisplayTarsus$study == 'JohannesOut'] <- estimatesJohannesDisplayTarsusout[2,1]-1.96*estimatesJohannesDisplayTarsusout[2,2]
metaDisplayTarsus$upper[metaDisplayTarsus$study == 'JohannesOut'] <- estimatesJohannesDisplayTarsusout[2,1]+1.96*estimatesJohannesDisplayTarsusout[2,2]

summarymetaDisplayTarsus <- meta.summaries(metaDisplayTarsus$est, metaDisplayTarsus$SE, names=metaDisplayTarsus$study, method="fixed")

rDisplayTarsus <- summarymetaDisplayTarsus$summary
lowerDisplayTarsus <- summarymetaDisplayTarsus$summary+1.96*summarymetaDisplayTarsus$se
upperDisplayTarsus <- summarymetaDisplayTarsus$summary-1.96*summarymetaDisplayTarsus$se

}

{# meta analysis Beak  - Tarsus
metaBeakTarsus <- data.frame('study' = c('Malika', 'SanjaIn', 'SanjaOut', 'JohannesIn','JohannesOut'))

metaBeakTarsus$est[metaBeakTarsus$study == 'Malika'] <- estimatesMalikaBeakTarsus[2,1]
metaBeakTarsus$SE[metaBeakTarsus$study == 'Malika'] <- estimatesMalikaBeakTarsus[2,2]
metaBeakTarsus$lower[metaBeakTarsus$study == 'Malika'] <- estimatesMalikaBeakTarsus[2,1]-1.96*estimatesMalikaBeakTarsus[2,2]
metaBeakTarsus$upper[metaBeakTarsus$study == 'Malika'] <- estimatesMalikaBeakTarsus[2,1]+1.96*estimatesMalikaBeakTarsus[2,2]


metaBeakTarsus$est[metaBeakTarsus$study == 'SanjaIn'] <- estimatesSanjaplusExtraBeakTarsusin[2,1]
metaBeakTarsus$SE[metaBeakTarsus$study == 'SanjaIn'] <- estimatesSanjaplusExtraBeakTarsusin[2,2]
metaBeakTarsus$lower[metaBeakTarsus$study == 'SanjaIn'] <- estimatesSanjaplusExtraBeakTarsusin[2,1]-1.96*estimatesSanjaplusExtraBeakTarsusin[2,2]
metaBeakTarsus$upper[metaBeakTarsus$study == 'SanjaIn'] <- estimatesSanjaplusExtraBeakTarsusin[2,1]+1.96*estimatesSanjaplusExtraBeakTarsusin[2,2]

metaBeakTarsus$est[metaBeakTarsus$study == 'SanjaOut'] <- estimatesSanjaplusExtraBeakTarsusout[2,1]
metaBeakTarsus$SE[metaBeakTarsus$study == 'SanjaOut'] <- estimatesSanjaplusExtraBeakTarsusout[2,2]
metaBeakTarsus$lower[metaBeakTarsus$study == 'SanjaOut'] <- estimatesSanjaplusExtraBeakTarsusout[2,1]-1.96*estimatesSanjaplusExtraBeakTarsusout[2,2]
metaBeakTarsus$upper[metaBeakTarsus$study == 'SanjaOut'] <- estimatesSanjaplusExtraBeakTarsusout[2,1]+1.96*estimatesSanjaplusExtraBeakTarsusout[2,2]


metaBeakTarsus$est[metaBeakTarsus$study == 'JohannesIn'] <- estimatesJohannesplusSpareBeakTarsusin[2,1]
metaBeakTarsus$SE[metaBeakTarsus$study == 'JohannesIn'] <- estimatesJohannesplusSpareBeakTarsusin[2,2]
metaBeakTarsus$lower[metaBeakTarsus$study == 'JohannesIn'] <- estimatesJohannesplusSpareBeakTarsusin[2,1]-1.96*estimatesJohannesplusSpareBeakTarsusin[2,2]
metaBeakTarsus$upper[metaBeakTarsus$study == 'JohannesIn'] <- estimatesJohannesplusSpareBeakTarsusin[2,1]+1.96*estimatesJohannesplusSpareBeakTarsusin[2,2]

metaBeakTarsus$est[metaBeakTarsus$study == 'JohannesOut'] <- estimatesJohannesplusSpareBeakTarsusout[2,1]
metaBeakTarsus$SE[metaBeakTarsus$study == 'JohannesOut'] <- estimatesJohannesplusSpareBeakTarsusout[2,2]
metaBeakTarsus$lower[metaBeakTarsus$study == 'JohannesOut'] <- estimatesJohannesplusSpareBeakTarsusout[2,1]-1.96*estimatesJohannesplusSpareBeakTarsusout[2,2]
metaBeakTarsus$upper[metaBeakTarsus$study == 'JohannesOut'] <- estimatesJohannesplusSpareBeakTarsusout[2,1]+1.96*estimatesJohannesplusSpareBeakTarsusout[2,2]

summarymetaBeakTarsus <- meta.summaries(metaBeakTarsus$est, metaBeakTarsus$SE, names=metaBeakTarsus$study, method="fixed")

rBeakTarsus <- summarymetaBeakTarsus$summary
lowerBeakTarsus <- summarymetaBeakTarsus$summary+1.96*summarymetaBeakTarsus$se
upperBeakTarsus <- summarymetaBeakTarsus$summary-1.96*summarymetaBeakTarsus$se

}

}

{## table corrphenotypictraits

corrphenotypictraits <- data.frame('corr' = c('BeakDisplay', 'DisplayTarsus', 'BeakTarsus'))
corrphenotypictraits$r <- rbind(rBeakDisplay,rDisplayTarsus, rBeakTarsus)
corrphenotypictraits$lower <- rbind(lowerBeakDisplay,lowerDisplayTarsus, lowerBeakTarsus)
corrphenotypictraits$upper <- rbind(upperBeakDisplay,upperDisplayTarsus, upperBeakTarsus)
corrphenotypictraits$NMales <- rbind(sum(NMalikaBeakDisplay,NSanjaBeakDisplayin,NSanjaBeakDisplayout, NJohannesBeakDisplayin,NJohannesBeakDisplayout),
						   sum(NMalikaDisplayTarsus,NSanjaDisplayTarsusin,NSanjaDisplayTarsusout, NJohannesDisplayTarsusin,NJohannesDisplayTarsusout),
						   sum(NMalikaBeakTarsus,NSanjaplusExtraBeakTarsusin,NSanjaplusExtraBeakTarsusout, NJohannesplusSpareBeakTarsusin,NJohannesplusSpareBeakTarsusout))
corrphenotypictraits
}


{# FIGURE sampling design

## timeline

{dev.new(width=14, heigth =3)
par(mar=c(10, 1, 4, 1))
plot(NULL, xlim=c(-1,70), ylim = c(-0.1,0.1), xlab="", ylab="", axes=F)

polygon(x=c(14,17,17,14), y=c(0,0,0.1,0.1), col='grey85', border='grey85')
polygon(x=c(51,54,54,51), y=c(0,0,0.1,0.1), col='grey17', border='grey17')
polygon(x=c(51,54,54,51), y=c(0,0,-0.1,-0.1), col='grey50', border='grey50')
polygon(x=c(63,66,66,63), y=c(0,0,0.1,0.1), col='grey17', border='grey17')

abline(v=seq(51,54,0.1),col='white')
abline(v=seq(63,66,0.1),col='white')

arrows(-2,0,71.5,0,lwd=3, lty=1, col='black')

mtext(side=3,at=0,'Beak color',font=4, line=2, col='grey70')
arrows(0,0,0,0.1,length=0)

mtext(side=3,at=50,'Beak color',font=4, col='grey30',line=2)
arrows(50,0,50,0.1,length=0)

mtext(side=1,at=15.5,'Breeding 2009', line=0.5, font=2)
mtext(side=1,at=15.5,'Domesticated, N=36', col='grey70',line=1.5)
 
mtext(side=1,at=52.5,'Breeding 2012', line=0.5, font=2)
mtext(side=1,at=52.5,'Wild-derived (outbreds), N=59', col='grey17', line=1.5) 
mtext(side=1,at=52.5,'Wild-derived (inbreds + outbreds), N=36', col='grey50',line=2.5) 

mtext(side=1,at=64.5,'Breeding 2013', line=0.5, font=2)
mtext(side=1,at=64.5,'Wild-derived (outbreds), N=41', col='grey17', line=1.5) 

mtext(side=3,at=15.5,'Courtship rate', line=0.5, font=4, col='grey70')
mtext(side=3,at=52.5,'Courtship rate', line=0.5, font=4, col='grey30')
mtext(side=3,at=64.5,'Courtship rate', line=0.5, font=4, col='grey17')




mtext(side=1,at=40,'Start "sperm project"
2011', line=4.5, font=2)
points(40, 0, pch=4, cex=2)

mtext(side=1,at=40,'Sperm traits', font=4,line=6,col='grey70')
mtext(side=1,at=40,'N=17 (14)',line=7, col='grey70')

mtext(side=1,at=50,'Sperm traits', font=4,line=6, col='grey30')
mtext(side=1,at=50,'N=59 (59)',line=7, col='grey17')
mtext(side=1,at=50,'N=36 (33)',line=8, col='grey50')
points(50, 0, pch=4, cex=2)

mtext(side=1,at=54,'Sperm traits', font=4,line=6, col='grey30')
mtext(side=1,at=54,'N=59 (59)',line=7, col='grey17')
mtext(side=1,at=54,'N=36 (33)',line=8, col='grey50')
points(54, 0, pch=4, cex=2)

mtext(side=1,at=62,'Sperm traits', font=4,line=6,col='grey30')
mtext(side=1,at=62,'N=41 (41)',line=7, col='grey17')
mtext(side=1,at=62,'N=33 (31)',line=8, col='grey50')
points(62, 0, pch=4, cex=2)

mtext(side=1,at=66,'Sperm traits', font=4,line=6,col='grey17')
mtext(side=1,at=66,'N=41 (41)',line=7, col='grey17')
points(66, 0, pch=4, cex=2)

}


## scheme

{dev.new(width=14, heigth =3)

mat <- matrix(c(0,1), nrow=1, ncol=2, byrow=T)
layout(mat, widths = c(1,6),
       heights = c(1,1))
	   
par(mar=c(0, 1, 0, 0))
plot(NULL, xlim=c(0,10), ylim = c(2,10), yaxt ="n", xlab="", ylab="",xaxt="n")

mtext(side = 2, at=3.3,'Domesticated    ' ,  adj=1, las=2, cex=0.8, font=4)
mtext(side = 2, at=2.7,'(inbreds + outbreds)    ' ,  adj=1, las=2, cex=0.8, font=2)
mtext(side = 2, at=6.3,'Wild-derived    ' ,  adj=1, las=2, cex=0.8, font=4) 
mtext(side = 2, at=5.7,'(inbreds + outbreds)    ', adj=1, las=2, cex=0.8, font=2)
mtext(side = 2, at=9.3,'Wild-derived    ',  adj=1, las=2, cex=0.8, font=4)	 
mtext(side = 2, at=8.7,'(outbreds)    ',  adj=1, las=2, cex=0.8, font=2)		

# Beak measurement
polygon(x=c(0.1,0.3,0.1), y=c(3.05,3.20,3.35), col='red', border='red')
polygon(x=c(0.1,0.3,0.1), y=c(6.05,6.20,6.35), col='red', border='red')
polygon(x=c(0.1,0.3,0.1), y=c(9.05,9.20,9.35), col='red', border='red')

# Tarsus length measurements
arrows(0.1, 2.90, 0.3 , 2.80,length=0.1, angle=150, lwd=2)
arrows(0.1, 2.90, 0.3 , 2.80,length=0.1, angle=180, lwd=2)
arrows(0.1, 5.90, 0.3 , 5.80,length=0.1, angle=150, lwd=2)
arrows(0.1, 5.90, 0.3 , 5.80,length=0.1, angle=180, lwd=2)
arrows(0.1, 8.90, 0.3 , 8.80,length=0.1, angle=150, lwd=2)
arrows(0.1, 8.90, 0.3 , 8.80,length=0.1, angle=180, lwd=2)

# timelines
arrows(0,9,10,9,lwd=3, lty=1, col='black')
arrows(0,6,5,6,lwd=3, lty=1, col='black')
arrows(0,3,5,3,lwd=3, lty=1, col='black')

# sperm samples
points(4, 3, pch='S', cex=2)
points(1, 6, pch='S', cex=2)
points(4, 6, pch='S', cex=2)
points(1, 9, pch='S', cex=2)
points(4, 9, pch='S', cex=2)
points(6, 9, pch='S', cex=2)
points(9, 9, pch='S', cex=2)

# Breeding periods

polygon(x=c(6.5,8.5,8.5,6.5), y=c(8.7,8.7,9.3,9.3), col='grey85', border='grey85')
polygon(x=c(1.5,3.5,3.5,1.5), y=c(8.7,8.7,9.3,9.3), col='grey85', border='grey85')
polygon(x=c(1.5,3.5,3.5,1.5), y=c(5.7,5.7,6.3,6.3), col='grey85', border='grey85')

abline(v=seq(6.5,8.5,0.04),col='white')
abline(v=seq(1.5,3.5,0.04),col='white')

polygon(x=c(1.5,3.5,3.5,1.5), y=c(2.7,2.7,3.3,3.3), col='grey85', border='grey85')

# legend
arrows(6.5,5,6.5,5.4,length=0, col='darkgrey', lwd=2)
text(6.8,5.2,'Beak color', adj=0 )
polygon(x=c(6,6.5,6.5,6), y=c(4,4,4.5,4.5), col='grey85', border='grey85')
text(6.8,4.2,'Courtship rate', adj=0 )
points(6.4, 3, pch='S', cex=3)
text(6.8,3.5,'Sperm sampling', adj=0 )


box(col='white')
}

}







	###############################################################
	#### Phenotypes inbreeding depression and conceptual graph  ###
	###############################################################


head(sanjaMales)
head(JohannesMales)

{### coutship rate cohens d inbreeding depression

{# sanja
CourtshipDiffMeanSanja <- lm (sqrtSumAllDisplaySecRate ~ InbredYN, data = sanjaMales[!(is.na(sanjaMales$nospermYN)),])
summary(CourtshipDiffMeanSanja)

DeltaCourtshipSanja <- coef(CourtshipDiffMeanSanja)[2]

CSDSanjaIn <- sd(sanjaMales$sqrtSumAllDisplaySecRate[sanjaMales$Fshort == 0.25 & !(is.na(sanjaMales$nospermYN)) ])
CSDSanjaOut <- sd(sanjaMales$sqrtSumAllDisplaySecRate[sanjaMales$Fshort < 0.25 & !(is.na(sanjaMales$nospermYN))])

CcohenSanja <- DeltaCourtshipSanja/((CSDSanjaIn+CSDSanjaOut)/2)
	
	# identic to
	# CrawMeanSanjaIn <- mean(sanjaMales$sqrtSumAllDisplaySecRate[sanjaMales$Fshort == 0.25&!(is.na(sanjaMales$nospermYN))])
	# CrawMeanSanjaOut <- mean(sanjaMales$sqrtSumAllDisplaySecRate[sanjaMales$Fshort < 0.25&!(is.na(sanjaMales$nospermYN))])
		
	# CrawcohenSanja <- 	(CrawMeanSanjaIn- CrawMeanSanjaOut)/((CSDSanjaIn+CSDSanjaOut)/2)
}

{# Johannes

CourtshipDiffMeanJo <- lm (SqrtSumAllDisplaySecRate ~ InbredYN, data = JohannesMales[!(is.na(JohannesMales$nospermYN)),])
summary(CourtshipDiffMeanJo)

DeltaCourtshipJo <- coef(CourtshipDiffMeanJo)[2]

CSDJoIn <- sd(JohannesMales$SqrtSumAllDisplaySecRate[JohannesMales$Fshort == 0.25 & !(is.na(JohannesMales$nospermYN))])
CSDJoOut <- sd(JohannesMales$SqrtSumAllDisplaySecRate[JohannesMales$Fshort < 0.25 & !(is.na(JohannesMales$nospermYN))])

CcohenJo <- DeltaCourtshipJo/((CSDJoIn+CSDJoOut)/2)

	# identic to
	# CrawMeanJoIn <- mean(JohannesMales$SqrtSumAllDisplaySecRate[JohannesMales$Fshort == 0.25])
	# CrawMeanJoOut <- mean(JohannesMales$SqrtSumAllDisplaySecRate[JohannesMales$Fshort < 0.25])
	
	# CrawcohenJo <- 	(CrawMeanJoIn- CrawMeanJoOut)/((CSDJoIn+CSDJoOut)/2)

}
	
{# Elisabeth

CcohenBolund <- -18.9/17.3 # about (miss the SD for inbreds)  = -1.09
CcohenBolund <- -1.18 # from graph

}

}
	
{### beak color cohens d inbreeding depression

{# sanja + Extra
BeakDiffMeanSanja <- lm (BeakColourScore ~ InbredYN, data = raw353[!(is.na(raw353$nospermYN)) & raw353$Exp == 3,])
summary(BeakDiffMeanSanja)

DeltaCourtshipSanja <- coef(BeakDiffMeanSanja)[2]


BSDSanjaIn <- sd(raw353$BeakColourScore[raw353$InbredYN == 1 & !(is.na(raw353$nospermYN)) & raw353$Exp == 3])
BSDSanjaOut <- sd(raw353$BeakColourScore[raw353$InbredYN ==0 & !(is.na(raw353$nospermYN)) & raw353$Exp == 3])
	
BcohenSanja <- 	DeltaCourtshipSanja/((BSDSanjaIn+BSDSanjaOut)/2)
	
}
	
{# johannes + Spare
BeakDiffMeanJo <- lm (BeakColourScore ~ InbredYN, data = raw353[!(is.na(raw353$nospermYN)) & raw353$Exp == 1,])
summary(BeakDiffMeanJo)

DeltaCourtshipJo <- coef(BeakDiffMeanJo)[2]

BSDJoIn <- sd(raw353$BeakColourScore[raw353$InbredYN == 1 & !(is.na(raw353$nospermYN)) & raw353$Exp == 1])
BSDJoOut <- sd(raw353$BeakColourScore[raw353$InbredYN == 0 & !(is.na(raw353$nospermYN)) & raw353$Exp == 1])
	
BcohenJo <- DeltaCourtshipJo/((BSDJoIn+BSDJoOut)/2)
		
}

{# elisabeth
	
BcohenBolund  <- -0.37/0.24 # about because don't have SD inbred   = -1.54
BcohenBolund  <- -1.04 # from graph
	
	
}	

}

{### Tarsus length cohens d inbreeding depression

{# sanja
TarsusDiffMeanSanja <- lm (Tarsus ~ InbredYN, data = raw353[!(is.na(raw353$nospermYN)) & raw353$Exp == 3,])
summary(TarsusDiffMeanSanja)

DeltaTarsusSanja <- coef(TarsusDiffMeanSanja)[2]

TarsusSDSanjaIn <- sd(raw353$Tarsus[raw353$InbredYN == 1 & !(is.na(raw353$nospermYN)) & !(is.na(raw353$Tarsus))& raw353$Exp == 3])
TarsusSDSanjaOut <- sd(raw353$Tarsus[raw353$InbredYN == 0 & !(is.na(raw353$nospermYN)) & !(is.na(raw353$Tarsus))& raw353$Exp == 3])

TarsuscohenSanja <- DeltaTarsusSanja/((TarsusSDSanjaIn+TarsusSDSanjaOut)/2)
	

}

{# Johannes

TarsusDiffMeanJo <- lm (Tarsus ~ InbredYN, data = raw353[!(is.na(raw353$nospermYN)) & raw353$Exp == 1,])
summary(TarsusDiffMeanJo)

DeltaTarsusJo <- coef(TarsusDiffMeanJo)[2]

TarsusSDJoIn <- sd(raw353$Tarsus[raw353$InbredYN == 1 & !(is.na(raw353$nospermYN)) & !(is.na(raw353$Tarsus))& raw353$Exp == 1])
TarsusSDJoOut <- sd(raw353$Tarsus[raw353$InbredYN == 0 & !(is.na(raw353$nospermYN)) & !(is.na(raw353$Tarsus))& raw353$Exp == 1])

TarsuscohenJo <- DeltaTarsusJo/((TarsusSDJoIn+TarsusSDJoOut)/2)

}
	
{# Elisabeth

CcohenBolund <- -18.9/17.3 # about (miss the SD for inbreds)  = -1.09
CcohenBolund <- -1.18 # from graph

}

}


{# beak - sperm trait	 accross group correlation
	
BeakoutX <- rnorm(1000000,0,1)
BeakinX <-rnorm(1000000,-1.04,1)	# Bolund
BeakallX <- c(BeakoutX,BeakinX)

AbnormaloutY <- rnorm(1000000,0,1)
AbnormalinY <- rnorm(1000000,1.40,1) # Opatova
AbnormalallY <- c(AbnormaloutY,AbnormalinY)
cor.test(AbnormalallY,BeakallX) # -0.263907


VelocityoutY <- rnorm(1000000,0,1)
VelocityinY <- rnorm(1000000,-0.74,1) # Opatova
VelocityallY <- c(VelocityoutY,VelocityinY)
cor.test(VelocityallY,BeakallX) # 0.1595751



SlengthoutY <- rnorm(1000000,0,1)
SlengthinY <- rnorm(1000000,-0.55,1) # Opatova
SlengthallY <- c(SlengthoutY,SlengthinY)
cor.test(SlengthallY,BeakallX) # 0.1221773 

}

{# courtship - sperm trait	 accross group correlation
	
CourtshipoutX <- rnorm(1000000,0,1)
CourtshipinX <-rnorm(1000000,-1.18,1)	# Bolund
CourtshipallX <- c(CourtshipoutX,CourtshipinX)

AbnormaloutY <- rnorm(1000000,0,1)
AbnormalinY <- rnorm(1000000,1.40,1) # Opatova
AbnormalallY <- c(AbnormaloutY,AbnormalinY)
cor.test(AbnormalallY,CourtshipallX) # -0.2916641


VelocityoutY <- rnorm(1000000,0,1)
VelocityinY <- rnorm(1000000,-0.74,1) # Opatova
VelocityallY <- c(VelocityoutY,VelocityinY)
cor.test(VelocityallY,CourtshipallX) # 0.1761102



SlengthoutY <- rnorm(1000000,0,1)
SlengthinY <- rnorm(1000000,-0.55,1) # Opatova
SlengthallY <- c(SlengthoutY,SlengthinY)
cor.test(SlengthallY,CourtshipallX) # 0.1362448

}

{# tarsus - sperm trait	 accross group correlation
	
TarsusoutX <- rnorm(1000000,0,1)
TarsusinX <-rnorm(1000000,-0.90,1)	# Bolund
TarsusallX <- c(TarsusoutX,TarsusinX)

AbnormaloutY <- rnorm(1000000,0,1)
AbnormalinY <- rnorm(1000000,1.40,1) # Opatova
AbnormalallY <- c(AbnormaloutY,AbnormalinY)
cor.test(AbnormalallY,TarsusallX) # -0.2341361


VelocityoutY <- rnorm(1000000,0,1)
VelocityinY <- rnorm(1000000,-0.74,1) # Opatova
VelocityallY <- c(VelocityoutY,VelocityinY)
cor.test(VelocityallY,TarsusallX) # 0.1423961



SlengthoutY <- rnorm(1000000,0,1)
SlengthinY <- rnorm(1000000,-0.55,1) # Opatova
SlengthallY <- c(SlengthoutY,SlengthinY)
cor.test(SlengthallY,TarsusallX) # 0.1079714

}


{# GRAPH conceptual graph correlation accross inbreds - outbreds

conceptXout <- rnorm(1000,0,1)
conceptXin <- rnorm(1000,-1.5,1)
conceptYout <- rnorm(1000,0,1)
conceptYin <- rnorm(1000,-1.5,1)
conceptallX <- c(conceptXout,conceptXin)
conceptallY <- c(conceptYout,conceptYin)
cor.test(conceptallX,conceptallY) # 0.4899885

par(mar=c(5,5,1,1))
plot(conceptXin,conceptYin, col='gold',xlim = c(-5,3), ylim=c(-5,3),  xlab="", ylab="", pch=6, cex=1.5)
mtext('Phenotypic indicator trait', side=1, line=3, font=2, cex=2)
mtext('Sperm trait', side=2, line=3, font=2, cex=2)
points(conceptXout,conceptYout, col='slateblue', pch=2, cex=1.5)	

arrows(0,0,0,-6, length=0, col='slateblue3', lwd=2, lty =2)
arrows(0,0,-6,0, length=0, col='slateblue3', lwd=2, lty =2)
arrows(-1.5,-1.5,-1.5,-6, length=0, col='gold2', lwd=2, lty =2)
arrows(-1.5,-1.5,-6,-1.5, length=0, col='gold2', lwd=2, lty =2)

points(x=0,y=0,pch=19, cex=2,col='black')
points(x=0,y=0,pch=19, cex=1.05,col='slateblue3')
points(x=-1.5,y=-1.5,pch=19, cex=2,col='black')
points(x=-1.5,y=-1.5,pch=19, cex=1.05,col='gold2')

abline(lm(conceptallY~conceptallX), col ='black', lwd=2)
text('Outbreds', x=1.5,y=3, font=2, adj=0, col = 'slateblue3', cex=1.5)
text('Inbreds', x=-5,y=-5, font=2, col='gold2', adj=0, cex=1.5)



}
	
	
	
{# simulation expected correlation in inbred/outbred groups, with real sample size, published cohens d, metanalyse of 18 correlations, run a 1000 times

head(raw353)	# write.table(raw353, file = "R_raw353withDisplay.xls", sep="\t", col.names=TRUE)

{# sample sizes Sanja and Johannes for each phenotypic trait - sperm trait correlations (N=18)
NSanjaBeakMunselAbnIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NSanjaBeakMunselAbnOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])
NSanjaBeakMunselVelocityIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NSanjaBeakMunselVelocityOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])
NSanjaBeakMunselSlengthIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NSanjaBeakMunselSlengthOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])

NSanjaDisplayAbnIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NSanjaDisplayAbnOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])
NSanjaDisplayVelocityIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NSanjaDisplayVelocityOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])
NSanjaDisplaySlengthIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NSanjaDisplaySlengthOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])

NSanjaTarsusAbnIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NSanjaTarsusAbnOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])
NSanjaTarsusVelocityIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NSanjaTarsusVelocityOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])
NSanjaTarsusSlengthIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NSanjaTarsusSlengthOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])


NJohannesBeakMunselAbnIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NJohannesBeakMunselAbnOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])
NJohannesBeakMunselVelocityIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NJohannesBeakMunselVelocityOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])
NJohannesBeakMunselSlengthIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NJohannesBeakMunselSlengthOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])

NJohannesDisplayAbnIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NJohannesDisplayAbnOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])
NJohannesDisplayVelocityIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NJohannesDisplayVelocityOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])
NJohannesDisplaySlengthIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NJohannesDisplaySlengthOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])

NJohannesTarsusAbnIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NJohannesTarsusAbnOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])
NJohannesTarsusVelocityIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NJohannesTarsusVelocityOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])
NJohannesTarsusSlengthIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NJohannesTarsusSlengthOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])

}

{# 18 correlations in a data frame

metaSimlist <- list()

for (j in 1:1000){

{# beak - Abnormal Sanja
	
SanjaBeakMunselAbnOutX <- rnorm(NSanjaBeakMunselAbnOut,0,1)
SanjaBeakMunselAbnInX <-rnorm(NSanjaBeakMunselAbnIn,-1.04,1)	# Bolund
SanjaBeakMunselAbnallX <- c(SanjaBeakMunselAbnOutX,SanjaBeakMunselAbnInX)

SanjaAbnBeakMunselOutY <- rnorm(NSanjaBeakMunselAbnOut,0,1)
SanjaAbnBeakMunselInY <- rnorm(NSanjaBeakMunselAbnIn,-1.40,1) # Opatova !! reverse
SanjaAbnBeakMunselallY <- c(SanjaAbnBeakMunselOutY,SanjaAbnBeakMunselInY)

corSanjaBeakMunselAbn <- cor.test(SanjaAbnBeakMunselallY,SanjaBeakMunselAbnallX) #
seSanjaBeakMunselAbnLower <- abs((corSanjaBeakMunselAbn$conf.int[1]-corSanjaBeakMunselAbn$estimate)/1.96)
seSanjaBeakMunselAbnUpper <- abs((corSanjaBeakMunselAbn$conf.int[2]-corSanjaBeakMunselAbn$estimate)/-1.96)
seSanjaBeakMunselAbn <- mean(seSanjaBeakMunselAbnLower,seSanjaBeakMunselAbnUpper)

}

{# beak - velocity Sanja

SanjaBeakMunselVelocityOutX <- rnorm(NSanjaBeakMunselVelocityOut,0,1)
SanjaBeakMunselVelocityInX <-rnorm(NSanjaBeakMunselVelocityIn,-1.04,1)	# Bolund
SanjaBeakMunselVelocityallX <- c(SanjaBeakMunselVelocityOutX,SanjaBeakMunselVelocityInX)

SanjaVelocityBeakMunselOutY <- rnorm(NSanjaBeakMunselVelocityOut,0,1)
SanjaVelocityBeakMunselInY <- rnorm(NSanjaBeakMunselVelocityIn,-0.74,1) # Opatova
SanjaVelocityBeakMunselallY <- c(SanjaVelocityBeakMunselOutY,SanjaVelocityBeakMunselInY)

corSanjaBeakMunselVelocity <- cor.test(SanjaVelocityBeakMunselallY,SanjaBeakMunselVelocityallX) # 
seSanjaBeakMunselVelocityLower <- abs((corSanjaBeakMunselVelocity$conf.int[1]-corSanjaBeakMunselVelocity$estimate)/1.96)
seSanjaBeakMunselVelocityUpper <- abs((corSanjaBeakMunselVelocity$conf.int[2]-corSanjaBeakMunselVelocity$estimate)/-1.96)
seSanjaBeakMunselVelocity <- mean(seSanjaBeakMunselVelocityLower,seSanjaBeakMunselVelocityUpper)

}

{# beak - Slength Sanja

SanjaBeakMunselSlengthOutX <- rnorm(NSanjaBeakMunselSlengthOut,0,1)
SanjaBeakMunselSlengthInX <-rnorm(NSanjaBeakMunselSlengthIn,-1.04,1)	# Bolund
SanjaBeakMunselSlengthallX <- c(SanjaBeakMunselSlengthOutX,SanjaBeakMunselSlengthInX)

SanjaSlengthBeakMunselOutY <- rnorm(NSanjaBeakMunselSlengthOut,0,1)
SanjaSlengthBeakMunselInY <- rnorm(NSanjaBeakMunselSlengthIn,-0.55,1) # Opatova
SanjaSlengthBeakMunselallY <- c(SanjaSlengthBeakMunselOutY,SanjaSlengthBeakMunselInY)

corSanjaBeakMunselSlength <- cor.test(SanjaSlengthBeakMunselallY,SanjaBeakMunselSlengthallX) # 
seSanjaBeakMunselSlengthLower <- abs((corSanjaBeakMunselSlength$conf.int[1]-corSanjaBeakMunselSlength$estimate)/1.96)
seSanjaBeakMunselSlengthUpper <- abs((corSanjaBeakMunselSlength$conf.int[2]-corSanjaBeakMunselSlength$estimate)/-1.96)
seSanjaBeakMunselSlength <- mean(seSanjaBeakMunselSlengthLower,seSanjaBeakMunselSlengthUpper)


}

{# courtship - Abnormal Sanja

SanjaDisplayAbnOutX <- rnorm(NSanjaDisplayAbnOut,0,1)
SanjaDisplayAbnInX <-rnorm(NSanjaDisplayAbnIn,-1.18,1)	# Bolund
SanjaDisplayAbnallX <- c(SanjaDisplayAbnOutX,SanjaDisplayAbnInX)

SanjaAbnDisplayOutY <- rnorm(NSanjaDisplayAbnOut,0,1)
SanjaAbnDisplayInY <- rnorm(NSanjaDisplayAbnIn,-1.40,1) # Opatova !! reverse
SanjaAbnDisplayallY <- c(SanjaAbnDisplayOutY,SanjaAbnDisplayInY)

corSanjaDisplayAbn <- cor.test(SanjaAbnDisplayallY,SanjaDisplayAbnallX) #
seSanjaDisplayAbnLower <- abs((corSanjaDisplayAbn$conf.int[1]-corSanjaDisplayAbn$estimate)/1.96)
seSanjaDisplayAbnUpper <- abs((corSanjaDisplayAbn$conf.int[2]-corSanjaDisplayAbn$estimate)/-1.96)
seSanjaDisplayAbn <- mean(seSanjaDisplayAbnLower,seSanjaDisplayAbnUpper)

}

{# courtship - velocity Sanja

SanjaDisplayVelocityOutX <- rnorm(NSanjaDisplayVelocityOut,0,1)
SanjaDisplayVelocityInX <-rnorm(NSanjaDisplayVelocityIn,-1.18,1)	# Bolund
SanjaDisplayVelocityallX <- c(SanjaDisplayVelocityOutX,SanjaDisplayVelocityInX)

SanjaVelocityDisplayOutY <- rnorm(NSanjaDisplayVelocityOut,0,1)
SanjaVelocityDisplayInY <- rnorm(NSanjaDisplayVelocityIn,-0.74,1) # Opatova
SanjaVelocityDisplayallY <- c(SanjaVelocityDisplayOutY,SanjaVelocityDisplayInY)

corSanjaDisplayVelocity <- cor.test(SanjaVelocityDisplayallY,SanjaDisplayVelocityallX) #
seSanjaDisplayVelocityLower <- abs((corSanjaDisplayVelocity$conf.int[1]-corSanjaDisplayVelocity$estimate)/1.96)
seSanjaDisplayVelocityUpper <- abs((corSanjaDisplayVelocity$conf.int[2]-corSanjaDisplayVelocity$estimate)/-1.96)
seSanjaDisplayVelocity <- mean(seSanjaDisplayVelocityLower,seSanjaDisplayVelocityUpper)

}

{# courtship - Slength Sanja

SanjaDisplaySlengthOutX <- rnorm(NSanjaDisplaySlengthOut,0,1)
SanjaDisplaySlengthInX <-rnorm(NSanjaDisplaySlengthIn,-1.18,1)	# Bolund
SanjaDisplaySlengthallX <- c(SanjaDisplaySlengthOutX,SanjaDisplaySlengthInX)

SanjaSlengthDisplayOutY <- rnorm(NSanjaDisplaySlengthOut,0,1)
SanjaSlengthDisplayInY <- rnorm(NSanjaDisplaySlengthIn,-0.55,1) # Opatova
SanjaSlengthDisplayallY <- c(SanjaSlengthDisplayOutY,SanjaSlengthDisplayInY)

corSanjaDisplaySlength <- cor.test(SanjaSlengthDisplayallY,SanjaDisplaySlengthallX) #
seSanjaDisplaySlengthLower <- abs((corSanjaDisplaySlength$conf.int[1]-corSanjaDisplaySlength$estimate)/1.96)
seSanjaDisplaySlengthUpper <- abs((corSanjaDisplaySlength$conf.int[2]-corSanjaDisplaySlength$estimate)/-1.96)
seSanjaDisplaySlength <- mean(seSanjaDisplaySlengthLower,seSanjaDisplaySlengthUpper)

}

{# tarsus - Abnormal Sanja

SanjaTarsusAbnOutX <- rnorm(NSanjaTarsusAbnOut,0,1)
SanjaTarsusAbnInX <-rnorm(NSanjaTarsusAbnIn,-0.90,1)	# Bolund
SanjaTarsusAbnallX <- c(SanjaTarsusAbnOutX,SanjaTarsusAbnInX)

SanjaAbnTarsusOutY <- rnorm(NSanjaTarsusAbnOut,0,1)
SanjaAbnTarsusInY <- rnorm(NSanjaTarsusAbnIn,-1.40,1) # Opatova !! reverse !!
SanjaAbnTarsusallY <- c(SanjaAbnTarsusOutY,SanjaAbnTarsusInY)

corSanjaTarsusAbn <- cor.test(SanjaAbnTarsusallY,SanjaTarsusAbnallX) #
seSanjaTarsusAbnLower <- abs((corSanjaTarsusAbn$conf.int[1]-corSanjaTarsusAbn$estimate)/1.96)
seSanjaTarsusAbnUpper <- abs((corSanjaTarsusAbn$conf.int[2]-corSanjaTarsusAbn$estimate)/-1.96)
seSanjaTarsusAbn <- mean(seSanjaTarsusAbnLower,seSanjaTarsusAbnUpper)

}

{# tarsus - velocity Sanja

SanjaTarsusVelocityOutX <- rnorm(NSanjaTarsusVelocityOut,0,1)
SanjaTarsusVelocityInX <-rnorm(NSanjaTarsusVelocityIn,-0.90,1)	# Bolund
SanjaTarsusVelocityallX <- c(SanjaTarsusVelocityOutX,SanjaTarsusVelocityInX)

SanjaVelocityTarsusOutY <- rnorm(NSanjaTarsusVelocityOut,0,1)
SanjaVelocityTarsusInY <- rnorm(NSanjaTarsusVelocityIn,-0.74,1) # Opatova
SanjaVelocityTarsusallY <- c(SanjaVelocityTarsusOutY,SanjaVelocityTarsusInY)

corSanjaTarsusVelocity <- cor.test(SanjaVelocityTarsusallY,SanjaTarsusVelocityallX) #
seSanjaTarsusVelocityLower <- abs((corSanjaTarsusVelocity$conf.int[1]-corSanjaTarsusVelocity$estimate)/1.96)
seSanjaTarsusVelocityUpper <- abs((corSanjaTarsusVelocity$conf.int[2]-corSanjaTarsusVelocity$estimate)/-1.96)
seSanjaTarsusVelocity <- mean(seSanjaTarsusVelocityLower,seSanjaTarsusVelocityUpper)
	
}

{# tarsus - Slength Sanja

SanjaTarsusSlengthOutX <- rnorm(NSanjaTarsusSlengthOut,0,1)
SanjaTarsusSlengthInX <-rnorm(NSanjaTarsusSlengthIn,-0.90,1)	# Bolund
SanjaTarsusSlengthallX <- c(SanjaTarsusSlengthOutX,SanjaTarsusSlengthInX)

SanjaSlengthTarsusOutY <- rnorm(NSanjaTarsusSlengthOut,0,1)
SanjaSlengthTarsusInY <- rnorm(NSanjaTarsusSlengthIn,-0.55,1) # Opatova
SanjaSlengthTarsusallY <- c(SanjaSlengthTarsusOutY,SanjaSlengthTarsusInY)

corSanjaTarsusSlength <- cor.test(SanjaSlengthTarsusallY,SanjaTarsusSlengthallX) #
seSanjaTarsusSlengthLower <- abs((corSanjaTarsusSlength$conf.int[1]-corSanjaTarsusSlength$estimate)/1.96)
seSanjaTarsusSlengthUpper <- abs((corSanjaTarsusSlength$conf.int[2]-corSanjaTarsusSlength$estimate)/-1.96)
seSanjaTarsusSlength <- mean(seSanjaTarsusSlengthLower,seSanjaTarsusSlengthUpper)
	
}


{# beak - Abnormal Johannes
	
JohannesBeakMunselAbnOutX <- rnorm(NJohannesBeakMunselAbnOut,0,1)
JohannesBeakMunselAbnInX <-rnorm(NJohannesBeakMunselAbnIn,-1.04,1)	# Bolund
JohannesBeakMunselAbnallX <- c(JohannesBeakMunselAbnOutX,JohannesBeakMunselAbnInX)

JohannesAbnBeakMunselOutY <- rnorm(NJohannesBeakMunselAbnOut,0,1)
JohannesAbnBeakMunselInY <- rnorm(NJohannesBeakMunselAbnIn,-1.40,1) # Opatova !! reverse !!
JohannesAbnBeakMunselallY <- c(JohannesAbnBeakMunselOutY,JohannesAbnBeakMunselInY)

corJohannesBeakMunselAbn <- cor.test(JohannesAbnBeakMunselallY,JohannesBeakMunselAbnallX) #
seJohannesBeakMunselAbnLower <- abs((corJohannesBeakMunselAbn$conf.int[1]-corJohannesBeakMunselAbn$estimate)/1.96)
seJohannesBeakMunselAbnUpper <- abs((corJohannesBeakMunselAbn$conf.int[2]-corJohannesBeakMunselAbn$estimate)/-1.96)
seJohannesBeakMunselAbn <- mean(seJohannesBeakMunselAbnLower,seJohannesBeakMunselAbnUpper)

}

{# beak - velocity Johannes

JohannesBeakMunselVelocityOutX <- rnorm(NJohannesBeakMunselVelocityOut,0,1)
JohannesBeakMunselVelocityInX <-rnorm(NJohannesBeakMunselVelocityIn,-1.04,1)	# Bolund
JohannesBeakMunselVelocityallX <- c(JohannesBeakMunselVelocityOutX,JohannesBeakMunselVelocityInX)

JohannesVelocityBeakMunselOutY <- rnorm(NJohannesBeakMunselVelocityOut,0,1)
JohannesVelocityBeakMunselInY <- rnorm(NJohannesBeakMunselVelocityIn,-0.74,1) # Opatova
JohannesVelocityBeakMunselallY <- c(JohannesVelocityBeakMunselOutY,JohannesVelocityBeakMunselInY)

corJohannesBeakMunselVelocity <- cor.test(JohannesVelocityBeakMunselallY,JohannesBeakMunselVelocityallX) # 
seJohannesBeakMunselVelocityLower <- abs((corJohannesBeakMunselVelocity$conf.int[1]-corJohannesBeakMunselVelocity$estimate)/1.96)
seJohannesBeakMunselVelocityUpper <- abs((corJohannesBeakMunselVelocity$conf.int[2]-corJohannesBeakMunselVelocity$estimate)/-1.96)
seJohannesBeakMunselVelocity <- mean(seJohannesBeakMunselVelocityLower,seJohannesBeakMunselVelocityUpper)

}

{# beak - Slength Johannes

JohannesBeakMunselSlengthOutX <- rnorm(NJohannesBeakMunselSlengthOut,0,1)
JohannesBeakMunselSlengthInX <-rnorm(NJohannesBeakMunselSlengthIn,-1.04,1)	# Bolund
JohannesBeakMunselSlengthallX <- c(JohannesBeakMunselSlengthOutX,JohannesBeakMunselSlengthInX)

JohannesSlengthBeakMunselOutY <- rnorm(NJohannesBeakMunselSlengthOut,0,1)
JohannesSlengthBeakMunselInY <- rnorm(NJohannesBeakMunselSlengthIn,-0.55,1) # Opatova
JohannesSlengthBeakMunselallY <- c(JohannesSlengthBeakMunselOutY,JohannesSlengthBeakMunselInY)

corJohannesBeakMunselSlength <- cor.test(JohannesSlengthBeakMunselallY,JohannesBeakMunselSlengthallX) # 
seJohannesBeakMunselSlengthLower <- abs((corJohannesBeakMunselSlength$conf.int[1]-corJohannesBeakMunselSlength$estimate)/1.96)
seJohannesBeakMunselSlengthUpper <- abs((corJohannesBeakMunselSlength$conf.int[2]-corJohannesBeakMunselSlength$estimate)/-1.96)
seJohannesBeakMunselSlength <- mean(seJohannesBeakMunselSlengthLower,seJohannesBeakMunselSlengthUpper)


}

{# courtship - Abnormal Johannes

JohannesDisplayAbnOutX <- rnorm(NJohannesDisplayAbnOut,0,1)
JohannesDisplayAbnInX <-rnorm(NJohannesDisplayAbnIn,-1.18,1)	# Bolund
JohannesDisplayAbnallX <- c(JohannesDisplayAbnOutX,JohannesDisplayAbnInX)

JohannesAbnDisplayOutY <- rnorm(NJohannesDisplayAbnOut,0,1)
JohannesAbnDisplayInY <- rnorm(NJohannesDisplayAbnIn,-1.40,1) # Opatova !! reverse !!
JohannesAbnDisplayallY <- c(JohannesAbnDisplayOutY,JohannesAbnDisplayInY)

corJohannesDisplayAbn <- cor.test(JohannesAbnDisplayallY,JohannesDisplayAbnallX) #
seJohannesDisplayAbnLower <- abs((corJohannesDisplayAbn$conf.int[1]-corJohannesDisplayAbn$estimate)/1.96)
seJohannesDisplayAbnUpper <- abs((corJohannesDisplayAbn$conf.int[2]-corJohannesDisplayAbn$estimate)/-1.96)
seJohannesDisplayAbn <- mean(seJohannesDisplayAbnLower,seJohannesDisplayAbnUpper)

}

{# courtship - velocity Johannes

JohannesDisplayVelocityOutX <- rnorm(NJohannesDisplayVelocityOut,0,1)
JohannesDisplayVelocityInX <-rnorm(NJohannesDisplayVelocityIn,-1.18,1)	# Bolund
JohannesDisplayVelocityallX <- c(JohannesDisplayVelocityOutX,JohannesDisplayVelocityInX)

JohannesVelocityDisplayOutY <- rnorm(NJohannesDisplayVelocityOut,0,1)
JohannesVelocityDisplayInY <- rnorm(NJohannesDisplayVelocityIn,-0.74,1) # Opatova
JohannesVelocityDisplayallY <- c(JohannesVelocityDisplayOutY,JohannesVelocityDisplayInY)

corJohannesDisplayVelocity <- cor.test(JohannesVelocityDisplayallY,JohannesDisplayVelocityallX) #
seJohannesDisplayVelocityLower <- abs((corJohannesDisplayVelocity$conf.int[1]-corJohannesDisplayVelocity$estimate)/1.96)
seJohannesDisplayVelocityUpper <- abs((corJohannesDisplayVelocity$conf.int[2]-corJohannesDisplayVelocity$estimate)/-1.96)
seJohannesDisplayVelocity <- mean(seJohannesDisplayVelocityLower,seJohannesDisplayVelocityUpper)

}

{# courtship - Slength Johannes

JohannesDisplaySlengthOutX <- rnorm(NJohannesDisplaySlengthOut,0,1)
JohannesDisplaySlengthInX <-rnorm(NJohannesDisplaySlengthIn,-1.18,1)	# Bolund
JohannesDisplaySlengthallX <- c(JohannesDisplaySlengthOutX,JohannesDisplaySlengthInX)

JohannesSlengthDisplayOutY <- rnorm(NJohannesDisplaySlengthOut,0,1)
JohannesSlengthDisplayInY <- rnorm(NJohannesDisplaySlengthIn,-0.55,1) # Opatova
JohannesSlengthDisplayallY <- c(JohannesSlengthDisplayOutY,JohannesSlengthDisplayInY)

corJohannesDisplaySlength <- cor.test(JohannesSlengthDisplayallY,JohannesDisplaySlengthallX) #
seJohannesDisplaySlengthLower <- abs((corJohannesDisplaySlength$conf.int[1]-corJohannesDisplaySlength$estimate)/1.96)
seJohannesDisplaySlengthUpper <- abs((corJohannesDisplaySlength$conf.int[2]-corJohannesDisplaySlength$estimate)/-1.96)
seJohannesDisplaySlength <- mean(seJohannesDisplaySlengthLower,seJohannesDisplaySlengthUpper)

}

{# tarsus - Abnormal Johannes

JohannesTarsusAbnOutX <- rnorm(NJohannesTarsusAbnOut,0,1)
JohannesTarsusAbnInX <-rnorm(NJohannesTarsusAbnIn,-0.90,1)	# Bolund
JohannesTarsusAbnallX <- c(JohannesTarsusAbnOutX,JohannesTarsusAbnInX)

JohannesAbnTarsusOutY <- rnorm(NJohannesTarsusAbnOut,0,1)
JohannesAbnTarsusInY <- rnorm(NJohannesTarsusAbnIn,-1.40,1) # Opatova !! reverse !!
JohannesAbnTarsusallY <- c(JohannesAbnTarsusOutY,JohannesAbnTarsusInY)

corJohannesTarsusAbn <- cor.test(JohannesAbnTarsusallY,JohannesTarsusAbnallX) #
seJohannesTarsusAbnLower <- abs((corJohannesTarsusAbn$conf.int[1]-corJohannesTarsusAbn$estimate)/1.96)
seJohannesTarsusAbnUpper <- abs((corJohannesTarsusAbn$conf.int[2]-corJohannesTarsusAbn$estimate)/-1.96)
seJohannesTarsusAbn <- mean(seJohannesTarsusAbnLower,seJohannesTarsusAbnUpper)

}

{# tarsus - velocity Johannes

JohannesTarsusVelocityOutX <- rnorm(NJohannesTarsusVelocityOut,0,1)
JohannesTarsusVelocityInX <-rnorm(NJohannesTarsusVelocityIn,-0.90,1)	# Bolund
JohannesTarsusVelocityallX <- c(JohannesTarsusVelocityOutX,JohannesTarsusVelocityInX)

JohannesVelocityTarsusOutY <- rnorm(NJohannesTarsusVelocityOut,0,1)
JohannesVelocityTarsusInY <- rnorm(NJohannesTarsusVelocityIn,-0.74,1) # Opatova
JohannesVelocityTarsusallY <- c(JohannesVelocityTarsusOutY,JohannesVelocityTarsusInY)

corJohannesTarsusVelocity <- cor.test(JohannesVelocityTarsusallY,JohannesTarsusVelocityallX) #
seJohannesTarsusVelocityLower <- abs((corJohannesTarsusVelocity$conf.int[1]-corJohannesTarsusVelocity$estimate)/1.96)
seJohannesTarsusVelocityUpper <- abs((corJohannesTarsusVelocity$conf.int[2]-corJohannesTarsusVelocity$estimate)/-1.96)
seJohannesTarsusVelocity <- mean(seJohannesTarsusVelocityLower,seJohannesTarsusVelocityUpper)
	
}

{# tarsus - Slength Johannes

JohannesTarsusSlengthOutX <- rnorm(NJohannesTarsusSlengthOut,0,1)
JohannesTarsusSlengthInX <-rnorm(NJohannesTarsusSlengthIn,-0.90,1)	# Bolund
JohannesTarsusSlengthallX <- c(JohannesTarsusSlengthOutX,JohannesTarsusSlengthInX)

JohannesSlengthTarsusOutY <- rnorm(NJohannesTarsusSlengthOut,0,1)
JohannesSlengthTarsusInY <- rnorm(NJohannesTarsusSlengthIn,-0.55,1) # Opatova
JohannesSlengthTarsusallY <- c(JohannesSlengthTarsusOutY,JohannesSlengthTarsusInY)

corJohannesTarsusSlength <- cor.test(JohannesSlengthTarsusallY,JohannesTarsusSlengthallX) #
seJohannesTarsusSlengthLower <- abs((corJohannesTarsusSlength$conf.int[1]-corJohannesTarsusSlength$estimate)/1.96)
seJohannesTarsusSlengthUpper <- abs((corJohannesTarsusSlength$conf.int[2]-corJohannesTarsusSlength$estimate)/-1.96)
seJohannesTarsusSlength <- mean(seJohannesTarsusSlengthLower,seJohannesTarsusSlengthUpper)
	
}


metaSimcorr <- c(corSanjaBeakMunselAbn$estimate, corSanjaBeakMunselVelocity$estimate, corSanjaBeakMunselSlength$estimate,
				 corSanjaDisplayAbn$estimate, corSanjaDisplayVelocity$estimate, corSanjaDisplaySlength$estimate,
				 corSanjaTarsusAbn$estimate, corSanjaTarsusVelocity$estimate, corSanjaTarsusSlength$estimate,
				 
				 corJohannesBeakMunselAbn$estimate, corJohannesBeakMunselVelocity$estimate, corJohannesBeakMunselSlength$estimate,
				 corJohannesDisplayAbn$estimate, corJohannesDisplayVelocity$estimate, corJohannesDisplaySlength$estimate,
				 corJohannesTarsusAbn$estimate, corJohannesTarsusVelocity$estimate, corJohannesTarsusSlength$estimate)
				 
metaSimse <- c(seSanjaBeakMunselAbn, seSanjaBeakMunselVelocity, seSanjaBeakMunselSlength,
				 seSanjaDisplayAbn, seSanjaDisplayVelocity, seSanjaDisplaySlength,
				 seSanjaTarsusAbn, seSanjaTarsusVelocity, seSanjaTarsusSlength,
				 
				 seJohannesBeakMunselAbn, seJohannesBeakMunselVelocity, seJohannesBeakMunselSlength,
				 seJohannesDisplayAbn, seJohannesDisplayVelocity, seJohannesDisplaySlength,
				 seJohannesTarsusAbn, seJohannesTarsusVelocity, seJohannesTarsusSlength)

summarymetaSim <- meta.summaries(metaSimcorr, metaSimse, method="random")

rmetaSim <- summarymetaSim$summary
lowermetaSimlist <- summarymetaSim$summary-1.96*summarymetaSim$se
metaSimlist[[j]] <- c(rmetaSim,lowermetaSimlist)


}

bindmetaSimList <- do.call(rbind,metaSimlist)
head(bindmetaSimList)
hist(bindmetaSimList[,1], breaks = 20)
hist(bindmetaSimList[,2], breaks = 20)
min(bindmetaSimList)



}
}





}################################################










	################################################################################
	## Creation of tables Live obsvt data: upload data from DB + add informations ##			!!working directory!!
	################################################################################

#### server
conDB2= odbcConnectAccess("Z:\\Malika\\_CURRENTBACKUP\\Stats Breeding 2013\\LiveObservation2012-2013.mdb")	

#### laptop
# conDB2= odbcConnectAccess("C:\\Users\\mihle\\Desktop\\_CURRENT BACK UP\\Stats Breeding 2013\\LiveObservation2012-2013.mdb")



{#### tables Live observations

# LiveCourts without matching in duplicatescourtshipsLiveVideo 
LiveCourts <- sqlQuery(conDB2,"
SELECT LiveCourts.CourtshipID, LiveCourts.Season, LiveCourts.ObservationID, LiveCourts.ObsvtDate, LiveCourts.LogRelTimeMinute, LiveCourts.Author, LiveCourts.AviaryNumber, LiveCourts.TreatmentMale, LiveCourts.TreatmentFemale, LiveCourts.Mid, LiveCourts.FID, LiveCourts.Mcol, LiveCourts.Fcol, LiveCourts.SongDur, LiveCourts.Resp, LiveCourts.c0, LiveCourts.c1, LiveCourts.c1ns, LiveCourts.c2, LiveCourts.c2ns, LiveCourts.c3, LiveCourts.location, IIf([duplicatesCourtshipsLiveVideo]![CourtshipID] Is Not Null,1,0) AS DuplicateVideo
FROM (SELECT Courtships.CourtshipID, [_Males].Season, Courtships.ObservationID, FocalPairBehaviour.ObsvtDate, Log(DateDiff('n',[VideoRecordingsSchedule]![LightOn],[FocalPairBehaviour]![ObsvtTime])+1)/Log(10) AS LogRelTimeMinute, FocalPairBehaviour.Author, FocalPairBehaviour.AviaryNumber, [_Males].TreatmentMale, [_Females].TreatmentFemale, [_Males].Mid, [_Females].FID, Courtships.Mcol, Courtships.Fcol, Courtships.SongDur, Courtships.Resp, Courtships.c0, Courtships.c1, Courtships.c1ns, Courtships.c2, Courtships.c2ns, Courtships.c3, Courtships.location
FROM ((_Females INNER JOIN (_Males INNER JOIN Courtships ON [_Males].RingColour = Courtships.Mcol) ON [_Females].RingColour = Courtships.Fcol) INNER JOIN FocalPairBehaviour ON ([_Males].Season = FocalPairBehaviour.Season) AND ([_Females].Season = FocalPairBehaviour.Season) AND ([_Males].AviaryNumber = FocalPairBehaviour.AviaryNumber) AND ([_Females].AviaryNumber = FocalPairBehaviour.AviaryNumber) AND (Courtships.ObservationID = FocalPairBehaviour.ObservationID)) INNER JOIN VideoRecordingsSchedule ON (VideoRecordingsSchedule.Aviary = FocalPairBehaviour.AviaryNumber) AND (FocalPairBehaviour.ObsvtDate = VideoRecordingsSchedule.Date) AND (FocalPairBehaviour.Season = VideoRecordingsSchedule.Season)
WHERE ((([_Males].Mid)<>11292) AND (([_Females].FID)<>11264)))  AS LiveCourts LEFT JOIN (SELECT LiveCourts.CourtshipID, LiveCourts.Season, LiveCourts.ObsvtDate, FocalPairBehaviour.ObsvtTime, LiveCourts.Author, LiveCourts.AviaryNumber, LiveCourts.Mcol, LiveCourts.Fcol, LiveCourts.SongDur, LiveCourts.Resp, LiveCourts.c1, LiveCourts.c0, LiveCourts.c1ns, LiveCourts.c2ns, LiveCourts.c2
FROM (VideoRecordingsSchedule INNER JOIN LiveCourts ON (VideoRecordingsSchedule.Season=LiveCourts.Season) AND (VideoRecordingsSchedule.Aviary=LiveCourts.AviaryNumber) AND (VideoRecordingsSchedule.Date=LiveCourts.ObsvtDate)) INNER JOIN FocalPairBehaviour ON LiveCourts.ObservationID=FocalPairBehaviour.ObservationID
WHERE (((FocalPairBehaviour.ObsvtTime)<VideoRecordingsSchedule!TimeStopWatch) And ((VideoRecordingsSchedule.WatchedYN)='1') And ((LiveCourts.location)=VideoRecordingsSchedule!RecPosition))
ORDER BY LiveCourts.Season, LiveCourts.ObsvtDate, FocalPairBehaviour.ObsvtTime, LiveCourts.AviaryNumber)  AS duplicatesCourtshipsLiveVideo ON LiveCourts.[CourtshipID] = duplicatesCourtshipsLiveVideo.[CourtshipID];
")

table(LiveCourts$Position[LiveCourts$FIDyr%in%FIDYearOk]) # 68.8% of the live courthips happened on the Courthsip P

AllFocal <- sqlQuery(conDB2, "
SELECT FocalPairBehaviour.ObservationID, [_Males].Season, FocalPairBehaviour.ObsvtDate, FocalPairBehaviour.Author, FocalPairBehaviour.AviaryNumber, [_Males].TreatmentMale, [_Males].Mid, FocalPairBehaviour.Mcol, [_Females].TreatmentFemale, FocalPairBehaviour.Fcol, [_Females].FID, FocalPairBehaviour.Maggr, FocalPairBehaviour.Faggr, FocalPairBehaviour.Mallo, FocalPairBehaviour.Fallo, FocalPairBehaviour.Mus, FocalPairBehaviour.MeanDist, (([FocalPairBehaviour]![FeedBoth]+[FocalPairBehaviour]![CleanBoth]+[FocalPairBehaviour]![NestBoth]+[FocalPairBehaviour]![SleepBoth]+[FocalPairBehaviour]![SitBoth]+[FocalPairBehaviour]![AggrBoth]+[FocalPairBehaviour]![OtherBoth]+[FocalPairBehaviour]![FlyBoth]+[FocalPairBehaviour]![CourtBoth])/6)*100 AS Synchrony, [FocalPairBehaviour]![Mback]+[FocalPairBehaviour]![Fback] AS SumBack, [FocalPairBehaviour]![Moff]+[FocalPairBehaviour]![Foff] AS SumOff, ([FocalPairBehaviour]![Foff]-[FocalPairBehaviour]![Fback])-([FocalPairBehaviour]![Moff]-[FocalPairBehaviour]![Mback]) AS Mateguarding, Abs(([FocalPairBehaviour]![Foff]-[FocalPairBehaviour]![Fback])-([FocalPairBehaviour]![Moff]-[FocalPairBehaviour]![Mback])) AS AbsMateguarding, IIf([FocalPairBehaviour]![Maggr]=No And [FocalPairBehaviour]![Faggr]=No,0,1) AS PairAggr, IIf([FocalPairBehaviour]![Mallo]=No And [FocalPairBehaviour]![Fallo]=No,0,1) AS PairAllo, FocalPairBehaviour.NestBoth, FocalPairBehaviour.NestM, FocalPairBehaviour.NestF
FROM _Males INNER JOIN (_Females INNER JOIN FocalPairBehaviour ON ([_Females].RingColour = FocalPairBehaviour.Fcol) AND ([_Females].AviaryNumber = FocalPairBehaviour.AviaryNumber) AND ([_Females].Season = FocalPairBehaviour.Season)) ON ([_Males].RingColour = FocalPairBehaviour.Mcol) AND ([_Males].AviaryNumber = FocalPairBehaviour.AviaryNumber) AND ([_Males].Season = FocalPairBehaviour.Season)
GROUP BY FocalPairBehaviour.ObservationID, [_Males].Season, FocalPairBehaviour.ObsvtDate, FocalPairBehaviour.Author, FocalPairBehaviour.AviaryNumber, [_Males].TreatmentMale, [_Males].Mid, FocalPairBehaviour.Mcol, [_Females].TreatmentFemale, FocalPairBehaviour.Fcol, [_Females].FID, FocalPairBehaviour.Maggr, FocalPairBehaviour.Faggr, FocalPairBehaviour.Mallo, FocalPairBehaviour.Fallo, FocalPairBehaviour.Mus, FocalPairBehaviour.MeanDist, (([FocalPairBehaviour]![FeedBoth]+[FocalPairBehaviour]![CleanBoth]+[FocalPairBehaviour]![NestBoth]+[FocalPairBehaviour]![SleepBoth]+[FocalPairBehaviour]![SitBoth]+[FocalPairBehaviour]![AggrBoth]+[FocalPairBehaviour]![OtherBoth]+[FocalPairBehaviour]![FlyBoth]+[FocalPairBehaviour]![CourtBoth])/6)*100, [FocalPairBehaviour]![Mback]+[FocalPairBehaviour]![Fback], [FocalPairBehaviour]![Moff]+[FocalPairBehaviour]![Foff], ([FocalPairBehaviour]![Foff]-[FocalPairBehaviour]![Fback])-([FocalPairBehaviour]![Moff]-[FocalPairBehaviour]![Mback]), Abs(([FocalPairBehaviour]![Foff]-[FocalPairBehaviour]![Fback])-([FocalPairBehaviour]![Moff]-[FocalPairBehaviour]![Mback])), IIf([FocalPairBehaviour]![Maggr]=No And [FocalPairBehaviour]![Faggr]=No,0,1), IIf([FocalPairBehaviour]![Mallo]=No And [FocalPairBehaviour]![Fallo]=No,0,1), FocalPairBehaviour.Comments, [ObsvtDate] & [Author] & [FocalPairBehaviour]![AviaryNumber] & [Mcol] & [Fcol], FocalPairBehaviour.ObsvtTime, FocalPairBehaviour.NestBoth, FocalPairBehaviour.NestM, FocalPairBehaviour.NestF
HAVING ((([_Males].Mid)<>11292) AND (([_Females].FID)<>11264));
")

AllFocal$PropBack <- AllFocal$SumBack / AllFocal$SumOff
AllFocal$PropBack[AllFocal$PropBack>1] <- 1
AllFocal$PropBack[is.infinite(AllFocal$PropBack) | is.nan(AllFocal$PropBack)]<- NA
AllFocal$FIDdateAuth <- paste(AllFocal$FID,AllFocal$ObsvtDate, AllFocal$Author, sep="")
AllFocal$MIDdateAuth <- paste(AllFocal$Mid,AllFocal$ObsvtDate, AllFocal$Author, sep="")
AllFocal$MIDFIDyr <- paste(AllFocal$Mid, AllFocal$FID,AllFocal$Season, sep="")

nrow(AllFocal)	#6900
AllFocal <- subset(AllFocal, AllFocal$MIDFIDyr%in%MIDFIDYearOk)	# to get only focal observations of real pairs
nrow(AllFocal)	#5700

AllFocal <- AllFocal[order(AllFocal$MIDFIDyr, AllFocal$ObsvtDate),]
}

close(conDB2)

head(LiveCourts)
head(AllFocal)



#### server
conDB= odbcConnectAccess("Z:\\Malika\\_CURRENT BACK UP\\ZebraFinchDBBielefeld.mdb")	

#### laptop
# conDB= odbcConnectAccess("C:\\Users\\mihle\\Desktop\\_CURRENT BACK UP\\ZebraFinchDBBielefeld.mdb")



{#### table AllCourtshipsRates

AllCourtshipRates <- sqlQuery(conDB, "
SELECT BreedingAviary_PairingStatus.Ind_ID AS MID, BreedingAviary_PairingStatus.PartnerID AS FID, BreedingAviary_PairingStatus.FIDMID, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Season, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='Courtship P',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoCourtshipP, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='Social P',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoSocialP, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='NB up' Or [BreedingAviary_PairingStatus]![RecPosition]='RAC',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoNestBoxes
FROM BreedingAviary_PairingStatus
GROUP BY BreedingAviary_PairingStatus.Ind_ID, BreedingAviary_PairingStatus.PartnerID, BreedingAviary_PairingStatus.FIDMID, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Season, BreedingAviary_PairingStatus.WatchedYN, BreedingAviary_PairingStatus.Sex
HAVING (((BreedingAviary_PairingStatus.FIDMID) Is Not Null And (BreedingAviary_PairingStatus.FIDMID)<>'1118711190' And (BreedingAviary_PairingStatus.FIDMID)<>'1129511190') AND ((BreedingAviary_PairingStatus.WatchedYN)='1') AND ((BreedingAviary_PairingStatus.Sex)=1));
UNION
SELECT BreedingAviary_PairingStatus.Ind_ID AS MID, 11187 AS FID, 1118711190 AS FIDMID, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Season, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='Courtship P',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoCourtshipP, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='Social P',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoSocialP, Sum(IIf([BreedingAviary_PairingStatus]![RecPosition]='NB up' Or [BreedingAviary_PairingStatus]![RecPosition]='RAC',DateDiff('n',[BreedingAviary_PairingStatus]![LightOn],[BreedingAviary_PairingStatus]![TimeStopWatch],0))) AS minVideoNestBoxes
FROM BreedingAviary_PairingStatus
GROUP BY BreedingAviary_PairingStatus.Ind_ID, 11187, 1118711190, BreedingAviary_PairingStatus.Aviary, BreedingAviary_PairingStatus.Season, BreedingAviary_PairingStatus.WatchedYN, BreedingAviary_PairingStatus.Sex
HAVING (((BreedingAviary_PairingStatus.Ind_ID)=11190) AND ((BreedingAviary_PairingStatus.Season)=2012) AND ((BreedingAviary_PairingStatus.WatchedYN)='1') AND ((BreedingAviary_PairingStatus.Sex)=1));
")

}

close(conDB)


{### add info on LiveCourts like in AllCourt

{# more colums
for (i in 1:nrow(LiveCourts))  {LiveCourts$Day[i] <- listdaysdates$Day[listdaysdates$Date == LiveCourts$ObsvtDate[i]]}
LiveCourts$MIDyrday <- paste(LiveCourts$Mid, LiveCourts$Season, LiveCourts$Day, sep="")
LiveCourts$FIDyrday <- paste(LiveCourts$FID, LiveCourts$Season, LiveCourts$Day, sep="")
LiveCourts$FIDMID <- paste(LiveCourts$FID,LiveCourts$Mid,sep="")
LiveCourts$MIDyr <- paste(LiveCourts$Mid, LiveCourts$Season, sep="")
LiveCourts$FIDyr <- paste(LiveCourts$FID, LiveCourts$Season, sep="")
LiveCourts$FIDdate <- paste(LiveCourts$FID,LiveCourts$ObsvtDate, sep="")
LiveCourts$MIDdate <- paste(LiveCourts$Mid,LiveCourts$ObsvtDate, sep="")
LiveCourts$FIDdateAuth <- paste(LiveCourts$FID,LiveCourts$ObsvtDate, LiveCourts$Author, sep="")
LiveCourts$MIDdateAuth <- paste(LiveCourts$Mid,LiveCourts$ObsvtDate, LiveCourts$Author, sep="")



for (i in 1:nrow(LiveCourts)) 
{LiveCourts$c012[i] <- sum (LiveCourts$c0[i] , LiveCourts$c1[i] , LiveCourts$c2[i] )
if (LiveCourts$c012[i] != 0) {LiveCourts$c012yn[i] <- 1} else {LiveCourts$c012yn[i] <- 0}}

for (i in 1:nrow(LiveCourts)){
if(is.na(LiveCourts$Resp[i])) {LiveCourts$RespPos[i] <- NA}
if(!is.na(LiveCourts$Resp[i]) & LiveCourts$Resp[i] < 0.5)
{LiveCourts$RespPos[i] <- 0}
if(!is.na(LiveCourts$Resp[i]) & LiveCourts$Resp[i] >= 0.5){LiveCourts$RespPos[i] <- 1}
}

for (i in 1:nrow(LiveCourts)){
LiveCourts$succ[i] <- sum ( LiveCourts$c1[i] , LiveCourts$c2[i] )
if( LiveCourts$succ[i] != 0) {LiveCourts$succYN[i] <- 1}
else {LiveCourts$succYN[i] <- 0}
}
}

{# add Pairing St data to LiveCourts 

LiveCourts <- merge(y = AccessPairingStatus[,c('IDyrday','pairedYN','PartnerID','polyStatus')], x = LiveCourts, by.y = 'IDyrday', by.x = "MIDyrday", all.x=TRUE)
colnames(LiveCourts)[colnames(LiveCourts) == "pairedYN"] <- "Mpaired"
colnames(LiveCourts)[colnames(LiveCourts) == "PartnerID"] <- "MPartnerID"
colnames(LiveCourts)[colnames(LiveCourts) == "polyStatus"] <- "MpolySt"

LiveCourts <- merge(y = AccessPairingStatus[,c('IDyrday','pairedYN','PartnerID','polyStatus')], x = LiveCourts, by.y = 'IDyrday', by.x = "FIDyrday", all.x=TRUE)
colnames(LiveCourts)[colnames(LiveCourts) == "pairedYN"] <- "Fpaired"
colnames(LiveCourts)[colnames(LiveCourts) == "PartnerID"] <- "FPartnerID"
colnames(LiveCourts)[colnames(LiveCourts) == "polyStatus"] <- "FpolySt"

for (i in 1:nrow(LiveCourts)){
LiveCourts$DiffMID[i] <- sum(LiveCourts$Mid[i],-LiveCourts$FPartnerID[i],na.rm=T )
LiveCourts$DiffFID[i] <- sum(LiveCourts$FID[i],-LiveCourts$MPartnerID[i],na.rm=T )
}

}

{# add courtship types (WEU) to LiveCourts

# FWEU: courtship type from the female side
head(LiveCourts[LiveCourts$DiffMID == 0,])	# WP 
head(LiveCourts[LiveCourts$DiffMID == LiveCourts$Mid,])	# UP 
head(LiveCourts[LiveCourts$DiffMID != LiveCourts$Mid & LiveCourts$DiffMID != 0,])	# EP 

for (i in 1:nrow(LiveCourts)) {
if(LiveCourts$DiffMID[i] == 0){LiveCourts$FWEU[i] <- "WP"}
else if(LiveCourts$DiffMID[i] == LiveCourts$Mid[i]){LiveCourts$FWEU[i] <- "UP"}
else{LiveCourts$FWEU[i] <- "EP"}
}

# MWEU: courtship type from the male side
head(LiveCourts[LiveCourts$DiffFID == 0,])	# WP 
head(LiveCourts[LiveCourts$DiffFID == LiveCourts$FID,])	# UP 
head(LiveCourts[LiveCourts$DiffFID != LiveCourts$FID & LiveCourts$DiffFID != 0,])	# EP 

for (i in 1:nrow(LiveCourts)) { 
if(LiveCourts$DiffFID[i] == 0){LiveCourts$MWEU[i] <- "WP"}
else if(LiveCourts$DiffFID[i] == LiveCourts$FID[i]){LiveCourts$MWEU[i] <- "UP"}
else{LiveCourts$MWEU[i] <- "EP"}
}

# MWEU for the polygynous male 11190 in 2012

LiveCourts$MWEU[LiveCourts$MIDyr == 111902012 & LiveCourts$FID == 11187] <- "WP"
LiveCourts$MWEU[LiveCourts$MIDyr == 111902012 & LiveCourts$FID != 11187] <- "EP"


}

{# add Egg data of FemalePairingStatus on table LiveCourts
LiveCourts <- merge(y = FemalePairingStatus[,c('IDyrday','RelDayMod','nEggsLayedLast5Days','dayspaired')], x = LiveCourts, by.y = 'IDyrday', by.x = "FIDyrday", all.x=TRUE)

colnames(LiveCourts)[colnames(LiveCourts) == "dayspaired"] <- "Fdayspaired"
}

{# add allbirds data on table LiveCourts

LiveCourts <- merge(y = allbirds[,c('IDYear','Treatment','Divorced')], x = LiveCourts, by.y = 'IDYear', by.x = "FIDyr", all.x=TRUE)
colnames(LiveCourts)[colnames(LiveCourts) == "Treatment"] <- "FTrt"
colnames(LiveCourts)[colnames(LiveCourts) == "Divorced"] <- "FDivorced"

LiveCourts <- merge(y = allbirds[,c('IDYear','Treatment','Divorced')], x = LiveCourts, by.y = 'IDYear', by.x = "MIDyr", all.x=TRUE)
colnames(LiveCourts)[colnames(LiveCourts) == "Treatment"] <- "MTrt"
colnames(LiveCourts)[colnames(LiveCourts) == "Divorced"] <- "MDivorced"
}

colnames(LiveCourts)[colnames(LiveCourts) == "Mid"] <- "MID"
colnames(LiveCourts)[colnames(LiveCourts) == "Season"] <- "Year"
colnames(LiveCourts)[colnames(LiveCourts) == "ObsvtDate"] <- "Date"
colnames(LiveCourts)[colnames(LiveCourts) == "location"] <- "Position"
}

head(LiveCourts)

{### add fitness data from allfemales and allmales to Pairs (= subset of pairs1213 that kept the Trt)

head(pairs1213)
nrow(pairs1213)	#100
Pairs <- pairs1213[pairs1213$MIDFIDyr%in%MIDFIDYearOk,]
nrow(Pairs)	#84
head(Pairs)
head(allfemales)
head(allmales)

Pairs <- merge (x = Pairs, y = allfemales[,c('IDYear','RelfitnessTrtOk','RelfitnessWPTrtOk','MeanMass8dChicksoc','sumFate56soc','sumFate34soc','sumFate2GenWPY','sumFate3456GenWPY','EPYYes','EPYNo')], by.x = 'FIDYear', by.y = 'IDYear', all.x = TRUE)
head(Pairs)

colnames(Pairs)[colnames(Pairs) == "RelfitnessTrtOk"] <- "FRelfit"

Pairs <-merge (x = Pairs, y = allmales[,c('IDYear','RelfitnessTrtOk')], by.x = 'MIDYear', by.y = 'IDYear', all.x = TRUE)
head(Pairs)

colnames(Pairs)[colnames(Pairs) == "RelfitnessTrtOk"] <- "MRelfit"

# for the polygynous male, the values for RelfitnessWPTrtOk, sumFate56soc, sumFate34soc, sumFate3456GenWPY and EPYNo are different of those of his partner
# for the WP courtship rate, the one calculated for males took into account the positions recorded
}

head(Pairs)

{### add agregate data from AllFocal to Pairs

for (i in 1: nrow(AllFocal))
{
if (AllFocal$ObsvtDate[i] < as.POSIXct ("2012-05-28 CEST") | (AllFocal$ObsvtDate[i] > as.POSIXct ("2013-05-20 CEST") & AllFocal$ObsvtDate[i] < as.POSIXct ("2013-05-28 CEST")))
{AllFocal$Period[i] <- 'w1'}
else {AllFocal$Period[i] <- 'breeding'}
}

AllFocal$MIDFIDyrPeriod <- paste(AllFocal$MIDFIDyr,AllFocal$Period, sep = "")


{## first week ("w1")
AllFocal_listperMIDFIDyrPeriodw1 <- split(AllFocal[AllFocal$Period == 'w1',], AllFocal$MIDFIDyrPeriod[AllFocal$Period== 'w1'])
x <-AllFocal_listperMIDFIDyrPeriodw1[[1]]


AllFocal_listperMIDFIDyrPeriodw1_fun <- function(x){
return (c(
unique(x$MIDFIDyr),
nrow (x),	# w1Focal
mean (x$Maggr),	# w1Maggr
mean (x$Faggr),	# w1Faggr
mean (x$PairAggr),	# w1PairAggr
mean (x$Mallo),	# w1Mallo
mean (x$Fallo),	# w1Fallo
mean (x$PairAllo),	#w1PairAllo
mean (x$Mus),	#w1Mus
mean (x$MeanDist),	#w1MeanDist
mean (x$Synchrony),	#w1Synchrony
mean (x$PropBack, na.rm = T),	#w1PropBack
mean (x$Mateguarding),	#w1Mateguarding
mean (x$AbsMateguarding)	#w1AbsMateguarding
))
}

AllFocal_listperMIDFIDyrPeriodw1_out1 <- lapply(AllFocal_listperMIDFIDyrPeriodw1, FUN= AllFocal_listperMIDFIDyrPeriodw1_fun)
AllFocal_listperMIDFIDyrPeriodw1_out2 <- data.frame(do.call(rbind, AllFocal_listperMIDFIDyrPeriodw1_out1))
rownames(AllFocal_listperMIDFIDyrPeriodw1_out2) <- NULL
colnames(AllFocal_listperMIDFIDyrPeriodw1_out2) <- c('MIDFIDyr','w1Focal','w1Maggr','w1Faggr','w1PairAggr','w1Mallo','w1Fallo','w1PairAllo','w1Mus','w1MeanDist','w1Synchrony','w1PropBack','w1Mateguarding','w1AbsMateguarding')

Pairs <- merge(x = Pairs, y = AllFocal_listperMIDFIDyrPeriodw1_out2, by.x = 'MIDFIDyr', by.y= 'MIDFIDyr', all.x = TRUE)
}

{## breeding ("breeding")
AllFocal_listperMIDFIDyrPeriodbreeding <- split(AllFocal[AllFocal$Period == 'breeding',], AllFocal$MIDFIDyrPeriod[AllFocal$Period== 'breeding'])
AllFocal_listperMIDFIDyrPeriodbreeding[[1]]


AllFocal_listperMIDFIDyrPeriodbreeding_fun <- function(x){
return (c(
unique(x$MIDFIDyr),
nrow (x),	# breedingFocal
mean (x$Maggr),	# breedingMaggr
mean (x$Faggr),	# breedingFaggr
mean (x$PairAggr),	# breedingPairAggr
mean (x$Mallo),	# breedingMallo
mean (x$Fallo),	# breedingFallo
mean (x$PairAllo),	#breedingPairAllo
mean (x$Mus),	#breedingMus
mean (x$MeanDist),	#breedingMeanDist
mean (x$Synchrony),	#breedingSynchrony
mean (x$PropBack, na.rm = T),	#breedingPropBack
mean (x$Mateguarding),	#breedingMateguarding
mean (x$AbsMateguarding)	#breedingAbsMateguarding
))
}

AllFocal_listperMIDFIDyrPeriodbreeding_out1 <- lapply(AllFocal_listperMIDFIDyrPeriodbreeding, FUN= AllFocal_listperMIDFIDyrPeriodbreeding_fun)
AllFocal_listperMIDFIDyrPeriodbreeding_out2 <- data.frame(do.call(rbind, AllFocal_listperMIDFIDyrPeriodbreeding_out1))
rownames(AllFocal_listperMIDFIDyrPeriodbreeding_out2) <- NULL
colnames(AllFocal_listperMIDFIDyrPeriodbreeding_out2) <- c('MIDFIDyr','breedingFocal','breedingMaggr','breedingFaggr','breedingPairAggr','breedingMallo','breedingFallo','breedingPairAllo','breedingMus','breedingMeanDist','breedingSynchrony','breedingPropBack','breedingMateguarding','breedingAbsMateguarding')

Pairs <- merge(x = Pairs, y = AllFocal_listperMIDFIDyrPeriodbreeding_out2, by.x = 'MIDFIDyr', by.y= 'MIDFIDyr', all.x = TRUE)
}

{## both combined: ALL

AllFocal_listperMIDFIDyr <- split(AllFocal, AllFocal$MIDFIDyr)
AllFocal_listperMIDFIDyr[[1]]


AllFocal_listperMIDFIDyr_fun <- function(x){
return (c(
unique(x$MIDFIDyr),
nrow (x),	# ALLFocal
mean (x$Maggr),	# ALLMaggr
mean (x$Faggr),	# ALLFaggr
mean (x$PairAggr),	# ALLPairAggr
mean (x$Mallo),	# ALLMallo
mean (x$Fallo),	# ALLFallo
mean (x$PairAllo),	#ALLPairAllo
mean (x$Mus),	#ALLMus
mean (x$MeanDist),	#ALLMeanDist
mean (x$Synchrony),	#ALLSynchrony
mean (x$PropBack, na.rm = T),	#ALLPropBack
mean (x$Mateguarding),	#ALLMateguarding
mean (x$AbsMateguarding)	#ALLAbsMateguarding
))
}

AllFocal_listperMIDFIDyr_out1 <- lapply(AllFocal_listperMIDFIDyr, FUN= AllFocal_listperMIDFIDyr_fun)
AllFocal_listperMIDFIDyr_out2 <- data.frame(do.call(rbind, AllFocal_listperMIDFIDyr_out1))
rownames(AllFocal_listperMIDFIDyr_out2) <- NULL
colnames(AllFocal_listperMIDFIDyr_out2) <- c('MIDFIDyr','nbALLFocal','ALLMaggr','ALLFaggr','ALLPairAggr','ALLMallo','ALLFallo','ALLPairAllo','ALLMus','ALLMeanDist','ALLSynchrony','ALLPropBack','ALLMateguarding','ALLAbsMateguarding')

Pairs <- merge(x = Pairs, y = AllFocal_listperMIDFIDyr_out2, by.x = 'MIDFIDyr', by.y= 'MIDFIDyr', all.x = TRUE)

}
}

head(Pairs)

{### add columns and data from Pairs to AllCourtshipRates

AllCourtshipRates$MIDFID <- paste(AllCourtshipRates$MID, AllCourtshipRates$FID, sep ="")
AllCourtshipRates <- AllCourtshipRates[AllCourtshipRates$MIDFID%in%MIDFIDOk,]
nrow(AllCourtshipRates)	# 84

AllCourtshipRates$MIDFIDyr <- paste(AllCourtshipRates$MIDFID,AllCourtshipRates$Season, sep="")
AllCourtshipRates$MIDyr <- paste(AllCourtshipRates$MID,AllCourtshipRates$Season, sep="")
AllCourtshipRates$FIDyr <- paste(AllCourtshipRates$FID,AllCourtshipRates$Season, sep="")


AllCourtshipRates <- merge(x = AllCourtshipRates, y = Pairs[,c('MIDFIDyr', 'nbALLFocal')], by.x = 'MIDFIDyr', by.y = 'MIDFIDyr')
AllCourtshipRates$nbMinLive <- as.numeric(as.character(AllCourtshipRates$nbALLFocal)) *18
AllCourtshipRates$nbMinLive[AllCourtshipRates$Aviary == 18 & AllCourtshipRates$Season == 2012] <- 48*15+9	# only 3 pairs wacthed on 28/05/2012
AllCourtshipRates$nbMinLive[AllCourtshipRates$Aviary == 6 & AllCourtshipRates$Season == 2013] <- 90*18	# one pair done twice, one missed
AllCourtshipRates$nbMinLive[AllCourtshipRates$Aviary == 7 & AllCourtshipRates$Season == 2013] <- 90*18	# one pair done twice, one missed on 25/05/2013
AllCourtshipRates$nbMinLive[AllCourtshipRates$Aviary == 4 & AllCourtshipRates$Season == 2013] # one pair replaced another on the 22/05/2013
AllCourtshipRates$nbMinLive[AllCourtshipRates$Aviary == 9 & AllCourtshipRates$Season == 2013] <- 239*3+260*3 # one pair died on the 06/06/2013
AllCourtshipRates <- AllCourtshipRates[order(AllCourtshipRates$Season, AllCourtshipRates$Aviary),]
}

head(AllCourtshipRates)

{# discrepency courtshiprate on allmales and courtshiprate on allfemales

# discrepencyCourtshipRate <- merge(x= Pairs[,c('MIDYear','FIDYear')],y=allmales[,c('IDYear', 'SumRateWP')] , by.x = 'MIDYear', by.y = 'IDYear')
# discrepencyCourtshipRate <- merge(x= discrepencyCourtshipRate,y=allfemales[,c('IDYear', 'RateWP')] , by.x = 'FIDYear', by.y = 'IDYear')
# plot(discrepencyCourtshipRate$RateWP~discrepencyCourtshipRate$SumRateWP)
# abline(0,1)
# lines(lowess(discrepencyCourtshipRate$RateWP~discrepencyCourtshipRate$SumRateWP), col="blue") 
# abline(lm(discrepencyCourtshipRate$RateWP~discrepencyCourtshipRate$SumRateWP), col="red") 
# cor.test(discrepencyCourtshipRate$SumRateWP, discrepencyCourtshipRate$RateWP) # cor = 0.9879533 ; t = 57.8105, df = 82, p-value < 2.2e-16
# discrepencyCourtshipRate[discrepencyCourtshipRate$RateWP < 0.1 & discrepencyCourtshipRate$SumRateWP < 0.4,] #> the biggest discrepency is for the secondary female (male had much more WP court but with another female) > fixed !
# AllCourtships[AllCourtships$MID == 11190 & AllCourtships$Year == 2012,]
# head(Pairs)
# head(allfemales)
# head(allmales)
# discrepencyCourtshipRate <- merge(x= discrepencyCourtshipRate,y=allmales[,c('IDYear', 'NBHoursPaired','')] , by.x = 'MIDYear', by.y = 'IDYear')
# discrepencyCourtshipRate <- merge(x= discrepencyCourtshipRate,y=allfemales[,c('IDYear', 'RateWP')] , by.x = 'FIDYear', by.y = 'IDYear')
}


{## add Period 'w1' or 'breeding' to AllCourt, Livecourts and MalePairingStatus

for (i in 1: nrow(AllCourt))
{
if (AllCourt$Date[i] < as.POSIXct ("2012-05-28 CEST") | (AllCourt$Date[i] > as.POSIXct ("2013-05-20 CEST") & AllCourt$Date[i] < as.POSIXct ("2013-05-28 CEST")))
{AllCourt$Period[i] <- 'w1'}
else {AllCourt$Period[i] <- 'breeding'}
}

for (i in 1: nrow(LiveCourts))
{
if (LiveCourts$Date[i] < as.POSIXct ("2012-05-28 CEST") | (LiveCourts$Date[i] > as.POSIXct ("2013-05-20 CEST") & LiveCourts$Date[i] < as.POSIXct ("2013-05-28 CEST")))
{LiveCourts$Period[i] <- 'w1'}
else {LiveCourts$Period[i] <- 'breeding'}
}

for (i in 1: nrow(MalePairingStatus))
{
if (MalePairingStatus$Date[i] < as.POSIXct ("2012-05-28 CEST") | (MalePairingStatus$Date[i] > as.POSIXct ("2013-05-20 CEST") & MalePairingStatus$Date[i] < as.POSIXct ("2013-05-28 CEST")))
{MalePairingStatus$Period[i] <- 'w1'}
else {MalePairingStatus$Period[i] <- 'breeding'}
}

AllCourt$MIDyrPeriod <- paste(AllCourt$MIDyr,AllCourt$Period, sep = "")
LiveCourts$MIDyrPeriod <- paste(LiveCourts$MIDyr,LiveCourts$Period, sep = "")
MalePairingStatus$MIDyrPeriod <- paste(MalePairingStatus$IDyr, MalePairingStatus$Period, sep = "")

}

head(AllCourt)
head(LiveCourts)
head(MalePairingStatus)


{### add AllCourthips data (Courtship rates per position for videos) in table AllCourtshipRates (for pairs that kept the Trt) w1 - breeding - all
## R bug ??? column AllCourtshipRates$w1NBCourtEPCourtP and AllCourtshipRates$breedingNBCourtEPCourtP are duplicated when used


{## nb of minVideo per position	w1/breeding

{# first week ("w1")

MalePairingStatus_listperMIDyrPeriodw1 <- split(MalePairingStatus[MalePairingStatus$Period == 'w1',], MalePairingStatus$MIDyrPeriod[MalePairingStatus$Period == 'w1'])

x <- MalePairingStatus_listperMIDyrPeriodw1[[1]]

MalePairingStatus_listperMIDyrPeriodw1_fun <- function(x) {
return(c(
unique(x$IDyr),
sum(x$minVideo[x$RecPosition == 'Courtship P'], na.rm = T), # w1minVideoCourtshipP
sum(x$minVideo[x$RecPosition == 'Social P'], na.rm = T)  # w1minVideoSocialP
))
}

MalePairingStatus_listperMIDyrPeriodw1_out1 <- lapply(MalePairingStatus_listperMIDyrPeriodw1, FUN=MalePairingStatus_listperMIDyrPeriodw1_fun)
MalePairingStatus_listperMIDyrPeriodw1_out2 <- data.frame(rownames(do.call(rbind, MalePairingStatus_listperMIDyrPeriodw1_out1)),do.call(rbind, MalePairingStatus_listperMIDyrPeriodw1_out1))
rownames(MalePairingStatus_listperMIDyrPeriodw1_out2) <- NULL
colnames(MalePairingStatus_listperMIDyrPeriodw1_out2) <- c('MIDyrPeriod','MIDyr','w1minVideoCourtshipP','w1minVideoSocialP')

AllCourtshipRates <- merge(y = MalePairingStatus_listperMIDyrPeriodw1_out2[,c('MIDyr','w1minVideoCourtshipP','w1minVideoSocialP')], x = AllCourtshipRates, by.y = 'MIDyr', by.x = "MIDyr", all.x=TRUE)
}

{# breeding

MalePairingStatus_listperMIDyrPeriodbreeding <- split(MalePairingStatus[MalePairingStatus$Period == 'breeding',], MalePairingStatus$MIDyrPeriod[MalePairingStatus$Period == 'breeding'])

x <- MalePairingStatus_listperMIDyrPeriodbreeding[[1]]

MalePairingStatus_listperMIDyrPeriodbreeding_fun <- function(x) {
return(c(
unique(x$IDyr),
sum(x$minVideo[x$RecPosition == 'Courtship P'], na.rm = T), # w1minVideoCourtshipP
sum(x$minVideo[x$RecPosition == 'Social P'], na.rm = T),  # w1minVideoSocialP
sum(x$minVideo[x$RecPosition == 'RAC' | x$RecPosition == 'NB up'], na.rm = T)  # w1minVideoNestBoxes
))
}

MalePairingStatus_listperMIDyrPeriodbreeding_out1 <- lapply(MalePairingStatus_listperMIDyrPeriodbreeding, FUN=MalePairingStatus_listperMIDyrPeriodbreeding_fun)
MalePairingStatus_listperMIDyrPeriodbreeding_out2 <- data.frame(rownames(do.call(rbind, MalePairingStatus_listperMIDyrPeriodbreeding_out1)),do.call(rbind, MalePairingStatus_listperMIDyrPeriodbreeding_out1))
rownames(MalePairingStatus_listperMIDyrPeriodbreeding_out2) <- NULL
colnames(MalePairingStatus_listperMIDyrPeriodbreeding_out2) <- c('MIDyrPeriod','MIDyr','breedingminVideoCourtshipP','breedingminVideoSocialP','breedingminVideoNestBoxes')

AllCourtshipRates <- merge(y = MalePairingStatus_listperMIDyrPeriodbreeding_out2[,c('MIDyr','breedingminVideoCourtshipP','breedingminVideoSocialP','breedingminVideoNestBoxes')], x = AllCourtshipRates, by.y = 'MIDyr', by.x = 'MIDyr', all.x=TRUE)
}

}

{## nb Courtships from AllCourt (Video)	w1/breeding

{# first week

AllCourt_listperMIDyrPeriodw1 <- split(AllCourt[AllCourt$Period == 'w1',], AllCourt$MIDyrPeriod[AllCourt$Period== 'w1'])
x <- AllCourt_listperMIDyrPeriodw1[[1]]

AllCourt_listperMIDyrPeriodw1_fun <- function(x){
return(c(
unique(x$MIDyr),
nrow(x[x$MWEU == 'WP',]),	#NBCourtWP
nrow(x[x$MWEU == 'EP',]),	#NBCourtEP

nrow(x[x$MWEU == 'WP' & x$Position == "Courtship P",]),	#NBCourtWPCourtP 
nrow(x[x$MWEU == 'EP' & x$Position == "Courtship P",]),	#NBCourtEPCourtP 

nrow(x[x$MWEU == 'WP' & x$Position == "Social P",]),	#NBCourtWPSocialP 
nrow(x[x$MWEU == 'EP' & x$Position == "Social P",])	#NBCourtEPSocialP 
))
}

AllCourt_listperMIDyrPeriodw1_out1 <- lapply(AllCourt_listperMIDyrPeriodw1, FUN=AllCourt_listperMIDyrPeriodw1_fun)
AllCourt_listperMIDyrPeriodw1_out2 <- data.frame(rownames(do.call(rbind, AllCourt_listperMIDyrPeriodw1_out1)),do.call(rbind, AllCourt_listperMIDyrPeriodw1_out1))
rownames(AllCourt_listperMIDyrPeriodw1_out2) <- NULL
colnames(AllCourt_listperMIDyrPeriodw1_out2) <- c('IDyrPeriod','MIDyr','w1NBCourtWP','w1NBCourtEP','w1NBCourtWPCourtP','w1NBCourtEPCourtP ','w1NBCourtWPSocialP','w1NBCourtEPSocialP')

AllCourtshipRates <- merge(y = AllCourt_listperMIDyrPeriodw1_out2[,c('MIDyr','w1NBCourtWPCourtP','w1NBCourtEPCourtP ','w1NBCourtWPSocialP','w1NBCourtEPSocialP')], x = AllCourtshipRates, by.y = 'MIDyr', by.x = "MIDyr", all.x=TRUE)
}

AllCourtshipRates$w1NBCourtWPCourtP[is.na(AllCourtshipRates$w1NBCourtWPCourtP)] <- 0
AllCourtshipRates$w1NBCourtEPCourtP[is.na(AllCourtshipRates$w1NBCourtEPCourtP)]<- 0
AllCourtshipRates$w1NBCourtWPSocialP[is.na(AllCourtshipRates$w1NBCourtWPSocialP)]<- 0
AllCourtshipRates$w1NBCourtEPSocialP[is.na(AllCourtshipRates$w1NBCourtEPSocialP)]<- 0

{# breeding

AllCourt_listperMIDyrPeriodbreeding <- split(AllCourt[AllCourt$Period == 'breeding',], AllCourt$MIDyrPeriod[AllCourt$Period== 'breeding'])
x <- AllCourt_listperMIDyrPeriodbreeding[[1]]

AllCourt_listperMIDyrPeriodbreeding_fun <- function(x){
return(c(
unique(x$MIDyr),
nrow(x[x$MWEU == 'WP',]),	#NBCourtWP
nrow(x[x$MWEU == 'EP',]),	#NBCourtEP

nrow(x[x$MWEU == 'WP' & x$Position == "Courtship P",]),	#NBCourtWPCourtP 
nrow(x[x$MWEU == 'EP' & x$Position == "Courtship P",]),	#NBCourtEPCourtP 

nrow(x[x$MWEU == 'WP' & x$Position == "Social P",]),	#NBCourtWPSocialP 
nrow(x[x$MWEU == 'EP' & x$Position == "Social P",]),	#NBCourtEPSocialP 

nrow(x[x$MWEU == 'WP' & x$Position == "Nestbox",]),	#NBCourtWPNestbox
nrow(x[x$MWEU == 'EP' & x$Position == "Nestbox",])	#NBCourtEPNestbox

))
 
 }

AllCourt_listperMIDyrPeriodbreeding_out1 <- lapply(AllCourt_listperMIDyrPeriodbreeding, FUN=AllCourt_listperMIDyrPeriodbreeding_fun)
AllCourt_listperMIDyrPeriodbreeding_out2 <- data.frame(rownames(do.call(rbind, AllCourt_listperMIDyrPeriodbreeding_out1)),do.call(rbind, AllCourt_listperMIDyrPeriodbreeding_out1))
rownames(AllCourt_listperMIDyrPeriodbreeding_out2) <- NULL
colnames(AllCourt_listperMIDyrPeriodbreeding_out2) <- c('MIDyrPeriod','MIDyr','breedingNBCourtWP','breedingNBCourtEP','breedingNBCourtWPCourtP','breedingNBCourtEPCourtP ','breedingNBCourtWPSocialP','breedingNBCourtEPSocialP','breedingNBCourtWPNestbox','breedingNBCourtEPNestbox')

AllCourtshipRates <- merge(y = AllCourt_listperMIDyrPeriodbreeding_out2[,c('MIDyr','breedingNBCourtWPCourtP','breedingNBCourtEPCourtP ','breedingNBCourtWPSocialP','breedingNBCourtEPSocialP','breedingNBCourtWPNestbox','breedingNBCourtEPNestbox')], x = AllCourtshipRates, by.y = 'MIDyr', by.x = "MIDyr", all.x=TRUE)
}

{# ALL

AllCourt_listperMIDyr2 <- split(AllCourt, AllCourt$MIDyr)

AllCourt_listperMIDyr_fun2 = function(x)  {
return(c(

nrow(x[x$MWEU == 'WP',]),	#NBCourtWP
nrow(x[x$MWEU == 'EP',]),	#NBCourtEP

nrow(x[x$MWEU == 'WP' & x$Position == "Courtship P",]),	#NBCourtWPCourtP 
nrow(x[x$MWEU == 'EP' & x$Position == "Courtship P",]),	#NBCourtEPCourtP 

nrow(x[x$MWEU == 'WP' & x$Position == "Social P",]),	#NBCourtWPSocialP 
nrow(x[x$MWEU == 'EP' & x$Position == "Social P",]),	#NBCourtEPSocialP 

nrow(x[x$MWEU == 'WP' & x$Position == "Nestbox",]),	#NBCourtWPNestbox
nrow(x[x$MWEU == 'EP' & x$Position == "Nestbox",])	#NBCourtEPNestbox

))
 
 }

AllCourt_listperMIDyrout12 <- lapply(AllCourt_listperMIDyr2, FUN=AllCourt_listperMIDyr_fun2)
AllCourt_listperMIDyrout22 <- data.frame(rownames(do.call(rbind, AllCourt_listperMIDyrout12)),do.call(rbind, AllCourt_listperMIDyrout12))
rownames(AllCourt_listperMIDyrout22) <- NULL
colnames(AllCourt_listperMIDyrout22) <- c('IDyr','NBCourtWP','NBCourtEP','NBCourtWPCourtP','NBCourtEPCourtP ','NBCourtWPSocialP','NBCourtEPSocialP','NBCourtWPNestbox','NBCourtEPNestbox')

AllCourtshipRates <- merge(y = AllCourt_listperMIDyrout22, x = AllCourtshipRates, by.y = 'IDyr', by.x = "MIDyr", all.x=TRUE)
}


}

{## add rates and sums of rates for videos 	w1/breeding

{# as.numeric
AllCourtshipRates$w1minVideoCourtshipP <- as.numeric(as.character(AllCourtshipRates$w1minVideoCourtshipP))
AllCourtshipRates$w1minVideoSocialP <- as.numeric(as.character(AllCourtshipRates$w1minVideoSocialP))
AllCourtshipRates$breedingminVideoCourtshipP <- as.numeric(as.character(AllCourtshipRates$breedingminVideoCourtshipP))
AllCourtshipRates$breedingminVideoSocialP <- as.numeric(as.character(AllCourtshipRates$breedingminVideoSocialP))
AllCourtshipRates$breedingminVideoNestBoxes <- as.numeric(as.character(AllCourtshipRates$breedingminVideoNestBoxes))
AllCourtshipRates$w1NBCourtWPCourtP  <- as.numeric(as.character(AllCourtshipRates$w1NBCourtWPCourtP))    
AllCourtshipRates$w1NBCourtEPCourtP  <- as.numeric(as.character(AllCourtshipRates$w1NBCourtEPCourtP))       
AllCourtshipRates$w1NBCourtWPSocialP   <- as.numeric(as.character(AllCourtshipRates$w1NBCourtWPSocialP))     
AllCourtshipRates$w1NBCourtEPSocialP   <- as.numeric(as.character(AllCourtshipRates$w1NBCourtEPSocialP))     
AllCourtshipRates$breedingNBCourtWPCourtP  <- as.numeric(as.character(AllCourtshipRates$breedingNBCourtWPCourtP))    
AllCourtshipRates$breedingNBCourtEPCourtP  <- as.numeric(as.character(AllCourtshipRates$breedingNBCourtEPCourtP))       
AllCourtshipRates$breedingNBCourtWPSocialP   <- as.numeric(as.character(AllCourtshipRates$breedingNBCourtWPSocialP))     
AllCourtshipRates$breedingNBCourtEPSocialP   <- as.numeric(as.character(AllCourtshipRates$breedingNBCourtEPSocialP))     
AllCourtshipRates$breedingNBCourtWPNestbox <- as.numeric(as.character(AllCourtshipRates$breedingNBCourtWPNestbox))
AllCourtshipRates$breedingNBCourtEPNestbox <- as.numeric(as.character(AllCourtshipRates$breedingNBCourtEPNestbox))
str(AllCourtshipRates)
}

{# first week

for (i in 1:nrow(AllCourtshipRates))
{
AllCourtshipRates$w1RateWPCourtP[i] <- AllCourtshipRates$w1NBCourtWPCourtP[i]/AllCourtshipRates$w1minVideoCourtshipP[i]
AllCourtshipRates$w1RateEPCourtP[i] <- AllCourtshipRates$w1NBCourtEPCourtP[i]/AllCourtshipRates$w1minVideoCourtshipP[i]

AllCourtshipRates$w1RateWPSocialP[i] <- AllCourtshipRates$w1NBCourtWPSocialP[i]/AllCourtshipRates$w1minVideoSocialP[i]
AllCourtshipRates$w1RateEPSocialP[i] <- AllCourtshipRates$w1NBCourtEPSocialP[i]/AllCourtshipRates$w1minVideoSocialP[i]

AllCourtshipRates$w1SumRateWP[i] <- sum(AllCourtshipRates$w1RateWPCourtP[i],AllCourtshipRates$w1RateWPSocialP[i], na.rm=T)
AllCourtshipRates$w1SumRateEP[i] <- sum(AllCourtshipRates$w1RateEPCourtP[i],AllCourtshipRates$w1RateEPSocialP[i], na.rm=T)

AllCourtshipRates$w1SumWERate[i] <- sum(AllCourtshipRates$w1SumRateWP[i],AllCourtshipRates$w1SumRateEP[i])

AllCourtshipRates$w1RatioWERate[i] <- AllCourtshipRates$w1SumRateWP[i]/AllCourtshipRates$w1SumRateEP[i]

}
}

{# breeding

for (i in 1:nrow(AllCourtshipRates))
{
AllCourtshipRates$breedingRateWPCourtP[i] <- AllCourtshipRates$breedingNBCourtWPCourtP[i]/AllCourtshipRates$breedingminVideoCourtshipP[i]
AllCourtshipRates$breedingRateEPCourtP[i] <- AllCourtshipRates$breedingNBCourtEPCourtP[i]/AllCourtshipRates$breedingminVideoCourtshipP[i]

AllCourtshipRates$breedingRateWPSocialP[i] <- AllCourtshipRates$breedingNBCourtWPSocialP[i]/AllCourtshipRates$breedingminVideoSocialP[i]
AllCourtshipRates$breedingRateEPSocialP[i] <- AllCourtshipRates$breedingNBCourtEPSocialP[i]/AllCourtshipRates$breedingminVideoSocialP[i]

AllCourtshipRates$breedingRateWPNestBox[i] <- AllCourtshipRates$breedingNBCourtWPNestBox[i]/AllCourtshipRates$breedingminVideoNestBoxes[i]
AllCourtshipRates$breedingRateEPNestBox[i] <- AllCourtshipRates$breedingNBCourtEPNestBox[i]/AllCourtshipRates$breedingminVideoNestBoxes[i]

AllCourtshipRates$breedingSumRateWP[i] <- sum(AllCourtshipRates$breedingRateWPCourtP[i],AllCourtshipRates$breedingRateWPSocialP[i],AllCourtshipRates$breedingRateWPNestBox[i], na.rm=T)
AllCourtshipRates$breedingSumRateEP[i] <- sum(AllCourtshipRates$breedingRateEPCourtP[i],AllCourtshipRates$breedingRateEPSocialP[i],AllCourtshipRates$breedingRateEPNestBox[i], na.rm=T)

AllCourtshipRates$breedingSumWERate[i] <- sum(AllCourtshipRates$breedingSumRateWP[i],AllCourtshipRates$breedingSumRateEP[i])

AllCourtshipRates$breedingRatioWERate[i] <- AllCourtshipRates$breedingSumRateWP[i]/AllCourtshipRates$breedingSumRateEP[i]

}
}

{# ALL
for (i in 1:nrow(AllCourtshipRates))
{
AllCourtshipRates$RateWPCourtP[i] <- AllCourtshipRates$NBCourtWPCourtP[i]/AllCourtshipRates$minVideoCourtshipP[i]
AllCourtshipRates$RateEPCourtP[i] <- AllCourtshipRates$NBCourtEPCourtP[i]/AllCourtshipRates$minVideoCourtshipP[i]

AllCourtshipRates$RateWPSocialP[i] <- AllCourtshipRates$NBCourtWPSocialP[i]/AllCourtshipRates$minVideoSocialP[i]
AllCourtshipRates$RateEPSocialP[i] <- AllCourtshipRates$NBCourtEPSocialP[i]/AllCourtshipRates$minVideoSocialP[i]

AllCourtshipRates$RateWPNestBox[i] <- AllCourtshipRates$NBCourtWPNestBox[i]/AllCourtshipRates$minVideoNestBoxes[i]
AllCourtshipRates$RateEPNestBox[i] <- AllCourtshipRates$NBCourtEPNestBox[i]/AllCourtshipRates$minVideoNestBoxes[i]

AllCourtshipRates$SumRateWP[i] <- sum(AllCourtshipRates$RateWPCourtP[i],AllCourtshipRates$RateWPSocialP[i],AllCourtshipRates$RateWPNestBox[i], na.rm=T)
AllCourtshipRates$SumRateEP[i] <- sum(AllCourtshipRates$RateEPCourtP[i],AllCourtshipRates$RateEPSocialP[i],AllCourtshipRates$RateEPNestBox[i], na.rm=T)

AllCourtshipRates$SumWERate[i] <- sum(AllCourtshipRates$SumRateWP[i],AllCourtshipRates$SumRateEP[i])

AllCourtshipRates$RatioWERate[i] <- AllCourtshipRates$SumRateWP[i]/AllCourtshipRates$SumRateEP[i]

}

}

}


{## nb of minLive w1/breeding

{# first week ("w1")

AllFocal$MIDyr<- paste(AllFocal$Mid, AllFocal$Season, sep="")
AllFocal$MIDyrPeriod <- paste(AllFocal$Mid, AllFocal$Season, AllFocal$Period, sep="")

AllFocal_listperMIDyrPeriodw1 <- split(AllFocal[AllFocal$Period == 'w1',], AllFocal$MIDyrPeriod[AllFocal$Period == 'w1'])

x <- AllFocal_listperMIDyrPeriodw1[[1]]

AllFocal_listperMIDyrPeriodw1_fun <- function(x) {
return(c(
unique(x$MIDyr),
nrow(x)
))
}

AllFocal_listperMIDyrPeriodw1_out1 <- lapply(AllFocal_listperMIDyrPeriodw1, FUN=AllFocal_listperMIDyrPeriodw1_fun)
AllFocal_listperMIDyrPeriodw1_out2 <- data.frame(rownames(do.call(rbind, AllFocal_listperMIDyrPeriodw1_out1)),do.call(rbind, AllFocal_listperMIDyrPeriodw1_out1))
rownames(AllFocal_listperMIDyrPeriodw1_out2) <- NULL
colnames(AllFocal_listperMIDyrPeriodw1_out2) <- c('MIDyrPeriod','MIDyr','w1nbFocal')

AllCourtshipRates <- merge(y = AllFocal_listperMIDyrPeriodw1_out2[,c('MIDyr','w1nbFocal')], x = AllCourtshipRates, by.y = 'MIDyr', by.x = 'MIDyr', all.x=TRUE)

AllCourtshipRates[,c('MIDyr','Aviary','nbALLFocal','w1nbFocal')]
AllCourtshipRates$w1nbMinLive <- as.numeric(as.character(AllCourtshipRates$w1nbFocal)) *18
AllCourtshipRates$w1nbMinLive[AllCourtshipRates$Aviary == 7 & AllCourtshipRates$Season == 2013] <- 21*18	# one pair done twice, one missed on 25/05/2013
}

{# breeding

for (i in 1:nrow(AllCourtshipRates))
{
AllCourtshipRates$breedingnbMinLive[i] <- AllCourtshipRates$nbMinLive[i]-AllCourtshipRates$w1nbMinLive[i]
}

AllCourtshipRates[,c('MIDyr','Aviary','nbALLFocal','w1nbFocal','nbMinLive','w1nbMinLive','breedingnbMinLive')]
}

}

{## nb Courtships from LiveCourts (Live) w1/breeding

{# first week

LiveCourts_listperMIDyrPeriodw1 <- split(LiveCourts[LiveCourts$Period == 'w1',], LiveCourts$MIDyrPeriod[LiveCourts$Period == 'w1'])

LiveCourts_listperMIDyrPeriodw1_fun = function(x)  {
return(c(
unique(x$MIDyr),
nrow(x[x$MWEU == 'WP',]),	#NBCourtWP
nrow(x[x$MWEU == 'EP',])	#NBCourtEP
))
}

LiveCourts_listperMIDyrPeriodw1_out1 <- lapply(LiveCourts_listperMIDyrPeriodw1, FUN=LiveCourts_listperMIDyrPeriodw1_fun)
LiveCourts_listperMIDyrPeriodw1_out2 <- data.frame(rownames(do.call(rbind, LiveCourts_listperMIDyrPeriodw1_out1)),do.call(rbind, LiveCourts_listperMIDyrPeriodw1_out1))
rownames(LiveCourts_listperMIDyrPeriodw1_out2) <- NULL
colnames(LiveCourts_listperMIDyrPeriodw1_out2) <- c('MIDyrPeriod','MIDyr','w1NBCourtWPLive','w1NBCourtEPLive')

AllCourtshipRates <- merge(y = LiveCourts_listperMIDyrPeriodw1_out2[,c('MIDyr','w1NBCourtWPLive','w1NBCourtEPLive')], x = AllCourtshipRates, by.y = 'MIDyr', by.x = "MIDyr", all.x=TRUE)
AllCourtshipRates$w1NBCourtWPLive[is.na(AllCourtshipRates$w1NBCourtWPLive)] <- 0
AllCourtshipRates$w1NBCourtEPLive[is.na(AllCourtshipRates$w1NBCourtEPLive)] <- 0
}

{# breeding

LiveCourts_listperMIDyrPeriodbreeding <- split(LiveCourts[LiveCourts$Period == 'breeding',], LiveCourts$MIDyrPeriod[LiveCourts$Period == 'breeding'])

LiveCourts_listperMIDyrPeriodbreeding_fun = function(x)  {
return(c(
unique(x$MIDyr),
nrow(x[x$MWEU == 'WP',]),	#NBCourtWP
nrow(x[x$MWEU == 'EP',])	#NBCourtEP
))
}

LiveCourts_listperMIDyrPeriodbreeding_out1 <- lapply(LiveCourts_listperMIDyrPeriodbreeding, FUN=LiveCourts_listperMIDyrPeriodbreeding_fun)
LiveCourts_listperMIDyrPeriodbreeding_out2 <- data.frame(rownames(do.call(rbind, LiveCourts_listperMIDyrPeriodbreeding_out1)),do.call(rbind, LiveCourts_listperMIDyrPeriodbreeding_out1))
rownames(LiveCourts_listperMIDyrPeriodbreeding_out2) <- NULL
colnames(LiveCourts_listperMIDyrPeriodbreeding_out2) <- c('MIDyrPeriod','MIDyr','breedingNBCourtWPLive','breedingNBCourtEPLive')

AllCourtshipRates <- merge(y = LiveCourts_listperMIDyrPeriodbreeding_out2[,c('MIDyr','breedingNBCourtWPLive','breedingNBCourtEPLive')], x = AllCourtshipRates, by.y = 'MIDyr', by.x = "MIDyr", all.x=TRUE)
AllCourtshipRates$breedingNBCourtWPLive[is.na(AllCourtshipRates$breedingNBCourtWPLive)] <- 0
AllCourtshipRates$breedingNBCourtEPLive[is.na(AllCourtshipRates$breedingNBCourtEPLive)] <- 0
}

{# ALL

LiveCourts_listperMIDyr <- split(LiveCourts, LiveCourts$MIDyr)

LiveCourts_listperMIDyr_fun = function(x)  {
return(c(
unique(x$MIDyr),
nrow(x[x$MWEU == 'WP',]),	#NBCourtWP
nrow(x[x$MWEU == 'EP',])	#NBCourtEP
))
}

LiveCourts_listperMIDyr_out1 <- lapply(LiveCourts_listperMIDyr, FUN=LiveCourts_listperMIDyr_fun)
LiveCourts_listperMIDyr_out2 <- data.frame(rownames(do.call(rbind, LiveCourts_listperMIDyr_out1)),do.call(rbind, LiveCourts_listperMIDyr_out1))
rownames(LiveCourts_listperMIDyr_out2) <- NULL
colnames(LiveCourts_listperMIDyr_out2) <- c('MIDyrPeriod','MIDyr','NBCourtWPLive','NBCourtEPLive')

AllCourtshipRates <- merge(y = LiveCourts_listperMIDyr_out2[,c('MIDyr','NBCourtWPLive','NBCourtEPLive')], x = AllCourtshipRates, by.y = 'MIDyr', by.x = "MIDyr", all.x=TRUE)
AllCourtshipRates$NBCourtWPLive[is.na(AllCourtshipRates$NBCourtWPLive)] <- 0
AllCourtshipRates$NBCourtEPLive[is.na(AllCourtshipRates$NBCourtEPLive)] <- 0
}
}

{## add rates and sums of rates for live obsvt

{# as.numeric
AllCourtshipRates$w1NBCourtWPLive  <- as.numeric(as.character(AllCourtshipRates$w1NBCourtWPLive))    
AllCourtshipRates$w1NBCourtEPLive  <- as.numeric(as.character(AllCourtshipRates$w1NBCourtEPLive))       
AllCourtshipRates$breedingNBCourtWPLive  <- as.numeric(as.character(AllCourtshipRates$breedingNBCourtWPLive))    
AllCourtshipRates$breedingNBCourtEPLive  <- as.numeric(as.character(AllCourtshipRates$breedingNBCourtEPLive)) 
AllCourtshipRates$NBCourtWPLive <- as.numeric(as.character(AllCourtshipRates$NBCourtWPLive))
AllCourtshipRates$NBCourtEPLive <- as.numeric(as.character(AllCourtshipRates$NBCourtEPLive))
str(AllCourtshipRates)
}

{# w1 - breeding - ALL
for (i in 1:nrow(AllCourtshipRates))
{
AllCourtshipRates$w1RateWPLive[i] <- AllCourtshipRates$w1NBCourtWPLive[i]/AllCourtshipRates$w1nbMinLive[i]
AllCourtshipRates$w1RateEPLive[i] <- AllCourtshipRates$w1NBCourtEPLive[i]/AllCourtshipRates$w1nbMinLive[i]

AllCourtshipRates$w1SumWERateLive[i] <- sum(AllCourtshipRates$w1RateWPLive[i],AllCourtshipRates$w1RateEPLive[i])

AllCourtshipRates$w1RatioWERateLive[i] <- AllCourtshipRates$w1RateWPLive[i]/AllCourtshipRates$w1RateEPLive[i]


AllCourtshipRates$breedingRateWPLive[i] <- AllCourtshipRates$breedingNBCourtWPLive[i]/AllCourtshipRates$breedingnbMinLive[i]
AllCourtshipRates$breedingRateEPLive[i] <- AllCourtshipRates$breedingNBCourtEPLive[i]/AllCourtshipRates$breedingnbMinLive[i]

AllCourtshipRates$breedingSumWERateLive[i] <- sum(AllCourtshipRates$breedingRateWPLive[i],AllCourtshipRates$breedingRateEPLive[i])

AllCourtshipRates$breedingRatioWERateLive[i] <- AllCourtshipRates$breedingRateWPLive[i]/AllCourtshipRates$breedingRateEPLive[i]


AllCourtshipRates$RateWPLive[i] <- AllCourtshipRates$NBCourtWPLive[i]/AllCourtshipRates$nbMinLive[i]
AllCourtshipRates$RateEPLive[i] <- AllCourtshipRates$NBCourtEPLive[i]/AllCourtshipRates$nbMinLive[i]

AllCourtshipRates$SumWERateLive[i] <- sum(AllCourtshipRates$RateWPLive[i],AllCourtshipRates$RateEPLive[i])

AllCourtshipRates$RatioWERateLive[i] <- AllCourtshipRates$RateWPLive[i]/AllCourtshipRates$RateEPLive[i]


}

}
}

AllCourtshipRates <- AllCourtshipRates[order(AllCourtshipRates$Season, AllCourtshipRates$Aviary),]

{## plot courtship rates video ~ Live for checking

## Video ~ Live
# w1
par(mfrow=c(1,2))
plot(AllCourtshipRates$w1SumRateWP~AllCourtshipRates$w1RateWPLive)
abline(0,1)
abline(lm(AllCourtshipRates$w1SumRateWP~AllCourtshipRates$w1RateWPLive), col="red") 
plot(AllCourtshipRates$w1SumRateEP~AllCourtshipRates$w1RateEPLive)
abline(0,1)
abline(lm(AllCourtshipRates$w1SumRateEP~AllCourtshipRates$w1RateEPLive), col="red") 

# breeding
par(mfrow=c(1,2))
plot(AllCourtshipRates$breedingSumRateWP~AllCourtshipRates$breedingRateWPLive)
abline(0,1)
abline(lm(AllCourtshipRates$breedingSumRateWP~AllCourtshipRates$breedingRateWPLive), col="red") 
plot(AllCourtshipRates$breedingSumRateEP~AllCourtshipRates$breedingRateEPLive)
abline(0,1)
abline(lm(AllCourtshipRates$breedingSumRateEP~AllCourtshipRates$breedingRateEPLive), col="red") 

# all
par(mfrow=c(1,2))
plot(AllCourtshipRates$SumRateWP~AllCourtshipRates$RateWPLive)
abline(0,1)
abline(lm(AllCourtshipRates$SumRateWP~AllCourtshipRates$RateWPLive), col="red") 
plot(AllCourtshipRates$SumRateEP~AllCourtshipRates$RateEPLive)
abline(0,1)
abline(lm(AllCourtshipRates$SumRateEP~AllCourtshipRates$RateEPLive), col="red") 

## w1 ~ breeding
# video
par(mfrow=c(1,2))
plot(AllCourtshipRates$w1SumRateWP~AllCourtshipRates$breedingSumRateWP)
abline(0,1)
abline(lm(AllCourtshipRates$w1SumRateWP~AllCourtshipRates$breedingSumRateWP), col="red") 
plot(AllCourtshipRates$w1SumRateEP~AllCourtshipRates$breedingSumRateEP)
abline(0,1)
abline(lm(AllCourtshipRates$w1SumRateEP~AllCourtshipRates$breedingSumRateEP), col="red") 

# live
par(mfrow=c(1,2))
plot(AllCourtshipRates$w1RateWPLive~AllCourtshipRates$breedingRateWPLive)
abline(0,1)
abline(lm(AllCourtshipRates$w1RateWPLive~AllCourtshipRates$breedingRateWPLive), col="red") 
plot(AllCourtshipRates$w1RateEPLive~AllCourtshipRates$breedingRateEPLive)
abline(0,1)
abline(lm(AllCourtshipRates$w1RateEPLive~AllCourtshipRates$breedingRateEPLive), col="red") 


}
}

head(AllCourtshipRates)

{### add  MeanZsqrtCourtRate video and live courtship rates PER HOUR to AllCourtshipRates w1 - breeding - all + MTrt & FTrt

for (i in 1:nrow(AllCourtshipRates))
{
if(AllCourtshipRates$Season[i] == 2012)
{
AllCourtshipRates$w1ZSqrtWPRateLive[i] <-  (sqrt(AllCourtshipRates$w1RateWPLive[i]*60) - mean(sqrt(AllCourtshipRates$w1RateWPLive[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$w1RateWPLive[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$w1ZSqrtEPRateLive[i] <-  (sqrt(AllCourtshipRates$w1RateEPLive[i]*60) - mean(sqrt(AllCourtshipRates$w1RateEPLive[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$w1RateEPLive[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$breedingZSqrtWPRateLive[i] <-  (sqrt(AllCourtshipRates$breedingRateWPLive[i]*60) - mean(sqrt(AllCourtshipRates$breedingRateWPLive[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$breedingRateWPLive[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$breedingZSqrtEPRateLive[i] <-   (sqrt(AllCourtshipRates$breedingRateEPLive[i]*60) - mean(sqrt(AllCourtshipRates$breedingRateEPLive[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$breedingRateEPLive[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$ALLZSqrtWPRateLive[i] <-  (sqrt(AllCourtshipRates$RateWPLive[i]*60) - mean(sqrt(AllCourtshipRates$RateWPLive[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$RateWPLive[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$ALLZSqrtEPRateLive[i] <-  (sqrt(AllCourtshipRates$RateEPLive[i]*60) - mean(sqrt(AllCourtshipRates$RateEPLive[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$RateEPLive[AllCourtshipRates$Season == 2012]*60))

AllCourtshipRates$w1ZSqrtWPRateVideo[i] <- (sqrt(AllCourtshipRates$w1SumRateWP[i]*60) - mean(sqrt(AllCourtshipRates$w1SumRateWP[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$w1SumRateWP[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$w1ZSqrtEPRateVideo[i] <- (sqrt(AllCourtshipRates$w1SumRateEP[i]*60) - mean(sqrt(AllCourtshipRates$w1SumRateEP[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$w1SumRateEP[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$breedingZSqrtWPRateVideo[i] <- (sqrt(AllCourtshipRates$breedingSumRateWP[i]*60) - mean(sqrt(AllCourtshipRates$breedingSumRateWP[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$breedingSumRateWP[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$breedingZSqrtEPRateVideo[i] <- (sqrt(AllCourtshipRates$breedingSumRateEP[i]*60) - mean(sqrt(AllCourtshipRates$breedingSumRateEP[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$breedingSumRateEP[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$ALLZSqrtWPRateVideo[i] <- (sqrt(AllCourtshipRates$SumRateWP[i]*60) - mean(sqrt(AllCourtshipRates$SumRateWP[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$SumRateWP[AllCourtshipRates$Season == 2012]*60))
AllCourtshipRates$ALLZSqrtEPRateVideo[i] <- (sqrt(AllCourtshipRates$SumRateEP[i]*60) - mean(sqrt(AllCourtshipRates$SumRateEP[AllCourtshipRates$Season == 2012]*60))) / sd(sqrt(AllCourtshipRates$SumRateEP[AllCourtshipRates$Season == 2012]*60))
}

if(AllCourtshipRates$Season[i] == 2013)
{
AllCourtshipRates$w1ZSqrtWPRateLive[i] <-  (sqrt(AllCourtshipRates$w1RateWPLive[i]*60) - mean(sqrt(AllCourtshipRates$w1RateWPLive[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$w1RateWPLive[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$w1ZSqrtEPRateLive[i] <-  (sqrt(AllCourtshipRates$w1RateEPLive[i]*60) - mean(sqrt(AllCourtshipRates$w1RateEPLive[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$w1RateEPLive[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$breedingZSqrtWPRateLive[i] <-  (sqrt(AllCourtshipRates$breedingRateWPLive[i]*60) - mean(sqrt(AllCourtshipRates$breedingRateWPLive[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$breedingRateWPLive[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$breedingZSqrtEPRateLive[i] <-   (sqrt(AllCourtshipRates$breedingRateEPLive[i]*60) - mean(sqrt(AllCourtshipRates$breedingRateEPLive[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$breedingRateEPLive[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$ALLZSqrtWPRateLive[i] <-  (sqrt(AllCourtshipRates$RateWPLive[i]*60) - mean(sqrt(AllCourtshipRates$RateWPLive[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$RateWPLive[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$ALLZSqrtEPRateLive[i] <-  (sqrt(AllCourtshipRates$RateEPLive[i]*60) - mean(sqrt(AllCourtshipRates$RateEPLive[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$RateEPLive[AllCourtshipRates$Season == 2013]*60))

AllCourtshipRates$w1ZSqrtWPRateVideo[i] <- (sqrt(AllCourtshipRates$w1SumRateWP[i]*60) - mean(sqrt(AllCourtshipRates$w1SumRateWP[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$w1SumRateWP[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$w1ZSqrtEPRateVideo[i] <- (sqrt(AllCourtshipRates$w1SumRateEP[i]*60) - mean(sqrt(AllCourtshipRates$w1SumRateEP[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$w1SumRateEP[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$breedingZSqrtWPRateVideo[i] <- (sqrt(AllCourtshipRates$breedingSumRateWP[i]*60) - mean(sqrt(AllCourtshipRates$breedingSumRateWP[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$breedingSumRateWP[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$breedingZSqrtEPRateVideo[i] <- (sqrt(AllCourtshipRates$breedingSumRateEP[i]*60) - mean(sqrt(AllCourtshipRates$breedingSumRateEP[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$breedingSumRateEP[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$ALLZSqrtWPRateVideo[i] <- (sqrt(AllCourtshipRates$SumRateWP[i]*60) - mean(sqrt(AllCourtshipRates$SumRateWP[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$SumRateWP[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$ALLZSqrtEPRateVideo[i] <- (sqrt(AllCourtshipRates$SumRateEP[i]*60) - mean(sqrt(AllCourtshipRates$SumRateEP[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$SumRateEP[AllCourtshipRates$Season == 2013]*60))
}
}

for (i in 1:nrow(AllCourtshipRates))
{
AllCourtshipRates$w1MeanZsqrtWPRates[i] <- mean(c(AllCourtshipRates$w1ZSqrtWPRateLive[i],AllCourtshipRates$w1ZSqrtWPRateVideo[i]))
AllCourtshipRates$w1MeanZsqrtEPRates[i] <- mean(c(AllCourtshipRates$w1ZSqrtEPRateLive[i],AllCourtshipRates$w1ZSqrtEPRateVideo[i]))
AllCourtshipRates$breedingMeanZsqrtWPRates[i] <- mean(c(AllCourtshipRates$breedingZSqrtWPRateLive[i],AllCourtshipRates$breedingZSqrtWPRateVideo[i]))
AllCourtshipRates$breedingMeanZsqrtEPRates[i] <- mean(c(AllCourtshipRates$breedingZSqrtEPRateLive[i],AllCourtshipRates$breedingZSqrtEPRateVideo[i]))
AllCourtshipRates$ALLMeanZsqrtWPRates[i] <- mean(c(AllCourtshipRates$ALLZSqrtWPRateLive[i],AllCourtshipRates$ALLZSqrtWPRateVideo[i]))
AllCourtshipRates$ALLMeanZsqrtEPRates[i] <- mean(c(AllCourtshipRates$ALLZSqrtEPRateLive[i],AllCourtshipRates$ALLZSqrtEPRateVideo[i]))
}

par(mfrow=c(2,3))
hist(AllCourtshipRates$w1MeanZsqrtWPRates)
hist(AllCourtshipRates$w1MeanZsqrtEPRates)
hist(AllCourtshipRates$breedingMeanZsqrtWPRates)
hist(AllCourtshipRates$breedingMeanZsqrtEPRates)
hist(AllCourtshipRates$ALLMeanZsqrtWPRates)
hist(AllCourtshipRates$ALLMeanZsqrtEPRates)

# AllCourtshipRates$MIDyr[AllCourtshipRates$w1MeanWPRate == 0] # "112162012" "112502012" "112912012" "111352012" "111902012" "110512012"
# AllCourtshipRates$MIDyr[AllCourtshipRates$breedingMeanWPRate == 0] #  "110782012" "111352012"
# AllCourtshipRates$MIDyr[AllCourtshipRates$MeanWPRate == 0] # "111352012"
# AllCourtshipRates$MIDyr[AllCourtshipRates$w1MeanMEPRate == 0] # 36 MIDyr
# AllCourtshipRates$MIDyr[AllCourtshipRates$breedingMeanMEPRate == 0] #  0 MIDyr
# AllCourtshipRates$MIDyr[AllCourtshipRates$MeanMEPRate == 0] # 0 MIDyr


# index Trt from Pairs
nrow(AllCourtshipRates)
AllCourtshipRates <- merge (x = AllCourtshipRates, y = Pairs[,c('MIDYear','MTrt','FTrt')], by.x = 'MIDyr', by.y = 'MIDYear', all.x= TRUE)

}

head(AllCourtshipRates)

{### add MeanMeanZsqrtCourtRate from AllCourtshipRates to Pairs

Pairs <- merge (x = Pairs, y = AllCourtshipRates[,c('MIDyr','w1MeanZsqrtWPRates', 'w1MeanZsqrtEPRates', 'breedingMeanZsqrtWPRates', 'breedingMeanZsqrtEPRates','ALLMeanZsqrtWPRates', 'ALLMeanZsqrtEPRates')], by.x = 'MIDYear', by.y = 'MIDyr')

par(mfrow=c(1,2))
plot(Pairs$w1MeanZsqrtWPRates~Pairs$breedingMeanZsqrtWPRates, col = Pairs$MTrt)	# C black, NC red
abline(0,1, col = 'green')
abline(lm(Pairs$w1MeanZsqrtWPRates~Pairs$breedingMeanZsqrtWPRates), col="blue") 
plot(Pairs$w1MeanZsqrtEPRates~Pairs$breedingMeanZsqrtEPRates, col = Pairs$MTrt)
abline(0,1, col = 'green')
abline(lm(Pairs$w1MeanZsqrtEPRates~Pairs$breedingMeanZsqrtEPRates), col="blue") 
}

head(Pairs)

{### merge AllCourt (video) and LiveCourts (live) into AllCourtships and add Period 'w1' or 'breeding'

head(AllCourt)
nrow(AllCourt)# 4918
head(LiveCourts)
nrow(LiveCourts)# 1570 with duplicates 			and female 11320 who died on the 06/06/2013 and females who didn't keep the Trt

AllCourt$LogRelTimeMinute <- log10(AllCourt$RelTime/60+1)
AllCourt$Obsv <- 'Video'
LiveCourts$Obsv <- 'Live'
LiveCourtwithoutduplicates <- LiveCourts[LiveCourts$DuplicateVideo == 0 ,]
nrow(LiveCourtwithoutduplicates)# 1533
nrow(LiveCourtwithoutduplicates[LiveCourtwithoutduplicates$FWEU == 'WP',])# 667
nrow(LiveCourtwithoutduplicates[LiveCourtwithoutduplicates$FWEU == 'EP',])# 840
nrow(LiveCourtwithoutduplicates[LiveCourtwithoutduplicates$FWEU == 'WP'& is.na(LiveCourtwithoutduplicates$Resp),])# 58
nrow(LiveCourtwithoutduplicates[LiveCourtwithoutduplicates$FWEU == 'EP'& is.na(LiveCourtwithoutduplicates$Resp),])# 19


AllCourtships <- rbind(AllCourt[,c('MID','FID','FIDMID','Year','Date','Day','LogRelTimeMinute','Position','FWEU','MWEU','Resp','succ','succYN','RelDayMod','nEggsLayedLast5Days','Fdayspaired','FTrt','MTrt', 'Obsv')], LiveCourtwithoutduplicates[,c('MID','FID','FIDMID','Year','Date','Day','LogRelTimeMinute','Position','FWEU','MWEU','Resp','succ','succYN','RelDayMod','nEggsLayedLast5Days','Fdayspaired','FTrt','MTrt','Obsv')])

nrow(AllCourtships)#6451

for (i in 1: nrow(AllCourtships))
{
if (AllCourtships$Date[i] < as.POSIXct ("2012-05-28 CEST") | (AllCourtships$Date[i] > as.POSIXct ("2013-05-20 CEST") & AllCourtships$Date[i] < as.POSIXct ("2013-05-28 CEST")))
{AllCourtships$Period[i] <- 'w1'}
else {AllCourtships$Period[i] <- 'breeding'}
}

AllCourtships$MIDyr <- paste(AllCourtships$MID, AllCourtships$Year, sep="")
AllCourtships$FIDyr <- paste(AllCourtships$FID, AllCourtships$Year, sep="")
AllCourtships$FIDyrPeriod <- paste(AllCourtships$FIDyr,AllCourtships$Period, sep = "")


nrow(LiveCourts[LiveCourts$FWEU == "EP" & LiveCourts$succYN == 1,])#1
nrow(LiveCourts[LiveCourts$FWEU == "EP" & LiveCourts$succYN == 0,])#857
nrow(AllCourt[AllCourt$FWEU == "EP" & AllCourt$succYN == 1,])#26
nrow(AllCourt[AllCourt$FWEU == "EP" & AllCourt$succYN == 0,])#2374
nrow(LiveCourts[LiveCourts$FWEU == "WP" & LiveCourts$succYN == 1,])#95
nrow(LiveCourts[LiveCourts$FWEU == "WP" & LiveCourts$succYN == 0,])#588
nrow(AllCourt[AllCourt$FWEU == "WP" & AllCourt$succYN == 1,])#469
nrow(AllCourt[AllCourt$FWEU == "WP" & AllCourt$succYN == 0,])#1726


nrow(AllCourtships[AllCourtships$FWEU == "EP" & AllCourtships$succYN == 1 & AllCourtships$FIDyr%in%FIDYearOk,]) #17
nrow(AllCourtships[AllCourtships$FWEU == "EP" & AllCourtships$succYN == 0 & AllCourtships$FIDyr%in%FIDYearOk,])	#2752
nrow(AllCourtships[AllCourtships$FWEU == "WP" & AllCourtships$succYN == 1 & AllCourtships$FIDyr%in%FIDYearOk,]) #492
nrow(AllCourtships[AllCourtships$FWEU == "WP" & AllCourtships$succYN == 0 & AllCourtships$FIDyr%in%FIDYearOk,])	#2063
nrow(AllCourtships[AllCourtships$FWEU == "WP" & AllCourtships$succYN == 1 & AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$Obsv == 'Live',]) #85

}

head(AllCourtships)

{### AllCourtshipsFTrtOk, calculation BLUPS, replacement of BLUPS NA by the mean of BlupResp of that period (i.e. = 0)

AllCourtshipsFTrtOk <- AllCourtships[AllCourtships$FIDyr%in%FIDYearOk,]
nrow(AllCourtshipsFTrtOk) # 5324
head(AllCourtshipsFTrtOk)

AllCourtshipsForMTrtOk <- AllCourtships[AllCourtships$FIDyr%in%FIDYearOk | AllCourtships$MIDyr%in%MIDYearOk,]
nrow(AllCourtshipsForMTrtOk) # 5588
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Video',])#4175
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Video'& AllCourtshipsForMTrtOk$FWEU == 'WP'& AllCourtshipsForMTrtOk$MWEU == 'WP',])#1942
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Video'& (AllCourtshipsForMTrtOk$FWEU == 'EP'| AllCourtshipsForMTrtOk$MWEU == 'EP'),])#2233
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Live',])#1413
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Live'& AllCourtshipsForMTrtOk$FWEU == 'WP'& AllCourtshipsForMTrtOk$MWEU == 'WP',])#613
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Live'& (AllCourtshipsForMTrtOk$FWEU == 'EP'| AllCourtshipsForMTrtOk$MWEU == 'EP'),])#800
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Live'& AllCourtshipsForMTrtOk$FWEU == 'WP'& AllCourtshipsForMTrtOk$MWEU == 'WP'& !is.na(AllCourtshipsForMTrtOk$Resp),])#561
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Live'& (AllCourtshipsForMTrtOk$FWEU == 'EP'| AllCourtshipsForMTrtOk$MWEU == 'EP'),])#800
nrow(AllCourtshipsForMTrtOk[AllCourtshipsForMTrtOk$Obsv == 'Live'& (AllCourtshipsForMTrtOk$FWEU == 'EP'| AllCourtshipsForMTrtOk$MWEU == 'EP')& !is.na(AllCourtshipsForMTrtOk$Resp),])#782


AllCourtshipsFTrtOkWP <- AllCourtshipsFTrtOk[AllCourtshipsFTrtOk$FWEU == 'WP',]
nrow(AllCourtshipsFTrtOkWP)	# 2555
nrow(AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Obsv == 'Video',])#1942
nrow(AllCourtshipsFTrtOkWP[is.na(AllCourtshipsFTrtOkWP$Resp),])	#52
nrow(AllCourtshipsFTrtOkWP[is.na(AllCourtshipsFTrtOkWP$Resp)&AllCourtshipsFTrtOkWP$Obsv == 'Video',])	#0

AllCourtshipsFTrtOkEP <- AllCourtshipsFTrtOk[AllCourtshipsFTrtOk$FWEU == 'EP',]
nrow(AllCourtshipsFTrtOkEP)	# 2769
nrow(AllCourtshipsFTrtOkEP[is.na(AllCourtshipsFTrtOkEP$Resp),])	# 17
nrow(AllCourtshipsFTrtOkEP[is.na(AllCourtshipsFTrtOkEP$Resp)&AllCourtshipsFTrtOkEP$Obsv == 'Video',])	# 0
nrow(AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Period == 'w1' & AllCourtshipsFTrtOkWP$Year == 2012,]) # 157
nrow(AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Period == 'w1' & AllCourtshipsFTrtOkWP$Year == 2013,])




{## WP per Period (w1-breeding) per year

{# w1 2012

modAllCourtshipsRespFemaleTrtOkWP_w1_2012 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + (1|FID),data= AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Period == 'w1' & AllCourtshipsFTrtOkWP$Year == 2012,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkWP_w1_2012)

femalesTrtOkWP_w1_2012 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkWP$FID[AllCourtshipsFTrtOkWP$Period == 'w1' & AllCourtshipsFTrtOkWP$Year == 2012])))
ranefWPResp_w1_2012 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkWP_w1_2012)$FID))
tableranefsWPResp_w1_2012 <- cbind (femalesTrtOkWP_w1_2012, ranefWPResp_w1_2012)
rownames(tableranefsWPResp_w1_2012) <- NULL
colnames(tableranefsWPResp_w1_2012)[1] <- "FID"
colnames(tableranefsWPResp_w1_2012)[2] <- "ranefWPResp_w1"
mean(tableranefsWPResp_w1_2012$ranefWPResp_w1)
}

{# w1 2013

modAllCourtshipsRespFemaleTrtOkWP_w1_2013 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + (1|FID),data= AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Period == 'w1' & AllCourtshipsFTrtOkWP$Year == 2013,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkWP_w1_2013)

femalesTrtOkWP_w1_2013 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkWP$FID[AllCourtshipsFTrtOkWP$Period == 'w1' & AllCourtshipsFTrtOkWP$Year == 2013])))
ranefWPResp_w1_2013 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkWP_w1_2013)$FID))

AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Period == 'w1' & AllCourtshipsFTrtOkWP$Year == 2013 & AllCourtshipsFTrtOkWP$FID == 11128,]
femalesTrtOkWP_w1_2013 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkWP$FID[AllCourtshipsFTrtOkWP$Period == 'w1' & AllCourtshipsFTrtOkWP$Year == 2013 & AllCourtshipsFTrtOkWP$FID != 11128])))	# 4 courtships with Resp = NA

tableranefsWPResp_w1_2013 <- cbind (femalesTrtOkWP_w1_2013, ranefWPResp_w1_2013)
rownames(tableranefsWPResp_w1_2013) <- NULL
colnames(tableranefsWPResp_w1_2013)[1] <- "FID"
colnames(tableranefsWPResp_w1_2013)[2] <- "ranefWPResp_w1"
mean(tableranefsWPResp_w1_2013$ranefWPResp_w1)
}

{# breeding 2012

modAllCourtshipsRespFemaleTrtOkWP_breeding_2012 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) +(1|FID),data= AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Period == 'breeding' & AllCourtshipsFTrtOkWP$Year == 2012,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkWP_breeding_2012)

femalesTrtOkWP_breeding_2012 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkWP$FID[AllCourtshipsFTrtOkWP$Period == 'breeding' & AllCourtshipsFTrtOkWP$Year == 2012])))
ranefWPResp_breeding_2012 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkWP_breeding_2012)$FID))
tableranefsWPResp_breeding_2012 <- cbind (femalesTrtOkWP_breeding_2012, ranefWPResp_breeding_2012)
rownames(tableranefsWPResp_breeding_2012) <- NULL
colnames(tableranefsWPResp_breeding_2012)[1] <- "FID"
colnames(tableranefsWPResp_breeding_2012)[2] <- "ranefWPResp_breeding"
mean(tableranefsWPResp_breeding_2012$ranefWPResp_breeding)
}

{# breeding 2013

modAllCourtshipsRespFemaleTrtOkWP_breeding_2013 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE)+(1|FID),data= AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Period == 'breeding' & AllCourtshipsFTrtOkWP$Year == 2013,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkWP_breeding_2013)

femalesTrtOkWP_breeding_2013 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkWP$FID[AllCourtshipsFTrtOkWP$Period == 'breeding' & AllCourtshipsFTrtOkWP$Year == 2013])))
ranefWPResp_breeding_2013 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkWP_breeding_2013)$FID))
tableranefsWPResp_breeding_2013 <- cbind (femalesTrtOkWP_breeding_2013, ranefWPResp_breeding_2013)
rownames(tableranefsWPResp_breeding_2013) <- NULL
colnames(tableranefsWPResp_breeding_2013)[1] <- "FID"
colnames(tableranefsWPResp_breeding_2013)[2] <- "ranefWPResp_breeding"
mean(tableranefsWPResp_breeding_2013$ranefWPResp_breeding)
}

{# ALL 2012

modAllCourtshipsRespFemaleTrtOkWP_ALL_2012 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) +(1|FID),data= AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Year == 2012,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkWP_ALL_2012)

femalesTrtOkWP_ALL_2012 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkWP$FID[AllCourtshipsFTrtOkWP$Year == 2012])))
ranefWPResp_ALL_2012 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkWP_ALL_2012)$FID))
tableranefsWPResp_ALL_2012 <- cbind (femalesTrtOkWP_ALL_2012, ranefWPResp_ALL_2012)
rownames(tableranefsWPResp_ALL_2012) <- NULL
colnames(tableranefsWPResp_ALL_2012)[1] <- "FID"
colnames(tableranefsWPResp_ALL_2012)[2] <- "ranefWPResp_ALL"
mean(tableranefsWPResp_ALL_2012$ranefWPResp_ALL)
}

{# ALL 2013

modAllCourtshipsRespFemaleTrtOkWP_ALL_2013 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) +(1|FID),data= AllCourtshipsFTrtOkWP[AllCourtshipsFTrtOkWP$Year == 2013,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkWP_ALL_2013)

femalesTrtOkWP_ALL_2013 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkWP$FID[AllCourtshipsFTrtOkWP$Year == 2013])))
ranefWPResp_ALL_2013 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkWP_ALL_2013)$FID))
tableranefsWPResp_ALL_2013 <- cbind (femalesTrtOkWP_ALL_2013, ranefWPResp_ALL_2013)
rownames(tableranefsWPResp_ALL_2013) <- NULL
colnames(tableranefsWPResp_ALL_2013)[1] <- "FID"
colnames(tableranefsWPResp_ALL_2013)[2] <- "ranefWPResp_ALL"
mean(tableranefsWPResp_ALL_2013$ranefWPResp_ALL)
}
}

{## EP per Period (w1-breeding) per year

{# w1 2012

modAllCourtshipsRespFemaleTrtOkEP_w1_2012 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + (1|MID) + (1|FID) + (1|FIDMID),data= AllCourtshipsFTrtOkEP[AllCourtshipsFTrtOkEP$Period == 'w1' & AllCourtshipsFTrtOkEP$Year == 2012,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkEP_w1_2012)

femalesTrtOkEP_w1_2012 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkEP$FID[AllCourtshipsFTrtOkEP$Period == 'w1' & AllCourtshipsFTrtOkEP$Year == 2012])))
ranefEPResp_w1_2012 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkEP_w1_2012)$FID))
tableranefsEPResp_w1_2012 <- cbind (femalesTrtOkEP_w1_2012, ranefEPResp_w1_2012)
rownames(tableranefsEPResp_w1_2012) <- NULL
colnames(tableranefsEPResp_w1_2012)[1] <- "FID"
colnames(tableranefsEPResp_w1_2012)[2] <- "ranefEPResp_w1"
mean(tableranefsEPResp_w1_2012$ranefEPResp_w1)
}

{# w1 2013

modAllCourtshipsRespFemaleTrtOkEP_w1_2013 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + (1|MID) + (1|FID) + (1|FIDMID),data= AllCourtshipsFTrtOkEP[AllCourtshipsFTrtOkEP$Period == 'w1' & AllCourtshipsFTrtOkEP$Year == 2013,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkEP_w1_2013)

femalesTrtOkEP_w1_2013 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkEP$FID[AllCourtshipsFTrtOkEP$Period == 'w1' & AllCourtshipsFTrtOkEP$Year == 2013])))
ranefEPResp_w1_2013 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkEP_w1_2013)$FID))
tableranefsEPResp_w1_2013 <- cbind (femalesTrtOkEP_w1_2013, ranefEPResp_w1_2013)
rownames(tableranefsEPResp_w1_2013) <- NULL
colnames(tableranefsEPResp_w1_2013)[1] <- "FID"
colnames(tableranefsEPResp_w1_2013)[2] <- "ranefEPResp_w1"
mean(tableranefsEPResp_w1_2013$ranefEPResp_w1)
}

{# breeding 2012

modAllCourtshipsRespFemaleTrtOkEP_breeding_2012 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + (1|MID) + (1|FID) + (1|FIDMID),data= AllCourtshipsFTrtOkEP[AllCourtshipsFTrtOkEP$Period == 'breeding' & AllCourtshipsFTrtOkEP$Year == 2012,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkEP_breeding_2012)

femalesTrtOkEP_breeding_2012 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkEP$FID[AllCourtshipsFTrtOkEP$Period == 'breeding' & AllCourtshipsFTrtOkEP$Year == 2012])))
ranefEPResp_breeding_2012 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkEP_breeding_2012)$FID))
tableranefsEPResp_breeding_2012 <- cbind (femalesTrtOkEP_breeding_2012, ranefEPResp_breeding_2012)
rownames(tableranefsEPResp_breeding_2012) <- NULL
colnames(tableranefsEPResp_breeding_2012)[1] <- "FID"
colnames(tableranefsEPResp_breeding_2012)[2] <- "ranefEPResp_breeding"
mean(tableranefsEPResp_breeding_2012$ranefEPResp_breeding)
}

{# breeding 2013

modAllCourtshipsRespFemaleTrtOkEP_breeding_2013 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE)+ (1|MID) + (1|FID) + (1|FIDMID),data= AllCourtshipsFTrtOkEP[AllCourtshipsFTrtOkEP$Period == 'breeding' & AllCourtshipsFTrtOkEP$Year == 2013,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkEP_breeding_2013)

femalesTrtOkEP_breeding_2013 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkEP$FID[AllCourtshipsFTrtOkEP$Period == 'breeding' & AllCourtshipsFTrtOkEP$Year == 2013])))
ranefEPResp_breeding_2013 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkEP_breeding_2013)$FID))
tableranefsEPResp_breeding_2013 <- cbind (femalesTrtOkEP_breeding_2013, ranefEPResp_breeding_2013)
rownames(tableranefsEPResp_breeding_2013) <- NULL
colnames(tableranefsEPResp_breeding_2013)[1] <- "FID"
colnames(tableranefsEPResp_breeding_2013)[2] <- "ranefEPResp_breeding"
mean(tableranefsEPResp_breeding_2013$ranefEPResp_breeding)
}

{# ALL 2012

modAllCourtshipsRespFemaleTrtOkEP_ALL_2012 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + (1|MID) + (1|FID) + (1|FIDMID),data= AllCourtshipsFTrtOkEP[AllCourtshipsFTrtOkEP$Year == 2012,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkEP_ALL_2012)

femalesTrtOkEP_ALL_2012 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkEP$FID[AllCourtshipsFTrtOkEP$Year == 2012])))
ranefEPResp_ALL_2012 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkEP_ALL_2012)$FID))
tableranefsEPResp_ALL_2012 <- cbind (femalesTrtOkEP_ALL_2012, ranefEPResp_ALL_2012)
rownames(tableranefsEPResp_ALL_2012) <- NULL
colnames(tableranefsEPResp_ALL_2012)[1] <- "FID"
colnames(tableranefsEPResp_ALL_2012)[2] <- "ranefEPResp_ALL"
mean(tableranefsEPResp_ALL_2012$ranefEPResp_ALL)
}

{# ALL 2013

modAllCourtshipsRespFemaleTrtOkEP_ALL_2013 <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE) + scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + (1|MID) + (1|FID) + (1|FIDMID),data= AllCourtshipsFTrtOkEP[AllCourtshipsFTrtOkEP$Year == 2013,],REML=FALSE)   
summary(modAllCourtshipsRespFemaleTrtOkEP_ALL_2013)

femalesTrtOkEP_ALL_2013 <- as.data.frame(sort(unique(AllCourtshipsFTrtOkEP$FID[AllCourtshipsFTrtOkEP$Year == 2013])))
ranefEPResp_ALL_2013 <- as.data.frame(unlist(ranef(modAllCourtshipsRespFemaleTrtOkEP_ALL_2013)$FID))
tableranefsEPResp_ALL_2013 <- cbind (femalesTrtOkEP_ALL_2013, ranefEPResp_ALL_2013)
rownames(tableranefsEPResp_ALL_2013) <- NULL
colnames(tableranefsEPResp_ALL_2013)[1] <- "FID"
colnames(tableranefsEPResp_ALL_2013)[2] <- "ranefEPResp_ALL"
mean(tableranefsEPResp_ALL_2013$ranefEPResp_ALL)
}
}

{## merge ranefs with Pairs
tableranefsWPResp_w1_2012$FIDyr <- paste(tableranefsWPResp_w1_2012$FID, '2012', sep='')
tableranefsWPResp_w1_2013$FIDyr <- paste(tableranefsWPResp_w1_2013$FID, '2013', sep='')
tableranefsWPResp_breeding_2012$FIDyr <- paste(tableranefsWPResp_breeding_2012$FID, '2012', sep='')
tableranefsWPResp_breeding_2013$FIDyr <- paste(tableranefsWPResp_breeding_2013$FID, '2013', sep='')
tableranefsWPResp_ALL_2012$FIDyr <- paste(tableranefsWPResp_ALL_2012$FID, '2012', sep='')
tableranefsWPResp_ALL_2013$FIDyr <- paste(tableranefsWPResp_ALL_2013$FID, '2013', sep='')

tableranefsEPResp_w1_2012$FIDyr <- paste(tableranefsEPResp_w1_2012$FID, '2012', sep='')
tableranefsEPResp_w1_2013$FIDyr <- paste(tableranefsEPResp_w1_2013$FID, '2013', sep='')
tableranefsEPResp_breeding_2012$FIDyr <- paste(tableranefsEPResp_breeding_2012$FID, '2012', sep='')
tableranefsEPResp_breeding_2013$FIDyr <- paste(tableranefsEPResp_breeding_2013$FID, '2013', sep='')
tableranefsEPResp_ALL_2012$FIDyr <- paste(tableranefsEPResp_ALL_2012$FID, '2012', sep='')
tableranefsEPResp_ALL_2013$FIDyr <- paste(tableranefsEPResp_ALL_2013$FID, '2013', sep='')

tableranefsWPResp_w1 <- rbind(tableranefsWPResp_w1_2012,tableranefsWPResp_w1_2013)
tableranefsWPResp_breeding <- rbind(tableranefsWPResp_breeding_2012,tableranefsWPResp_breeding_2013)
tableranefsWPResp_ALL <- rbind(tableranefsWPResp_ALL_2012,tableranefsWPResp_ALL_2013)

tableranefsEPResp_w1 <- rbind(tableranefsEPResp_w1_2012,tableranefsEPResp_w1_2013)
tableranefsEPResp_breeding <- rbind(tableranefsEPResp_breeding_2012,tableranefsEPResp_breeding_2013)
tableranefsEPResp_ALL <- rbind(tableranefsEPResp_ALL_2012,tableranefsEPResp_ALL_2013)


Pairs <- merge(x=Pairs, y =tableranefsWPResp_w1[,c('ranefWPResp_w1', 'FIDyr')], by.x = 'FIDYear', by.y = 'FIDyr', all.x = TRUE)
Pairs <- merge(x=Pairs, y =tableranefsWPResp_breeding[,c('ranefWPResp_breeding', 'FIDyr')], by.x = 'FIDYear', by.y = 'FIDyr', all.x = TRUE)
Pairs <- merge(x=Pairs, y =tableranefsWPResp_ALL[,c('ranefWPResp_ALL', 'FIDyr')], by.x = 'FIDYear', by.y = 'FIDyr', all.x = TRUE)

Pairs <- merge(x=Pairs, y =tableranefsEPResp_w1[,c('ranefEPResp_w1', 'FIDyr')], by.x = 'FIDYear', by.y = 'FIDyr', all.x = TRUE)
Pairs <- merge(x=Pairs, y =tableranefsEPResp_breeding[,c('ranefEPResp_breeding', 'FIDyr')], by.x = 'FIDYear', by.y = 'FIDyr', all.x = TRUE)
Pairs <- merge(x=Pairs, y =tableranefsEPResp_ALL[,c('ranefEPResp_ALL', 'FIDyr')], by.x = 'FIDYear', by.y = 'FIDyr', all.x = TRUE)

AllCourtships[AllCourtships$FIDyr == 112272012 & AllCourtships$FWEU == 'EP' &  AllCourtships$Period == 'breeding',] # no EP courthsip observed
AllCourtships[AllCourtships$FIDyr == 112142012 & AllCourtships$FWEU == 'WP',] # no WP courtship observed

Pairs$ranefWPResp_w1[is.na(Pairs$ranefWPResp_w1)] <- 0
Pairs$ranefWPResp_breeding[is.na(Pairs$ranefWPResp_breeding)] <- 0
Pairs$ranefWPResp_ALL[is.na(Pairs$ranefWPResp_ALL)] <- 0

Pairs$ranefEPResp_w1[is.na(Pairs$ranefEPResp_w1)] <- 0
Pairs$ranefEPResp_breeding[is.na(Pairs$ranefEPResp_breeding)] <- 0



}

}

head(Pairs)

{### add  ZSynchrony per year (w1 - breeding - all) to Pairs
Pairs[,c('MIDFIDyr','Season','w1Synchrony','breedingSynchrony','ALLSynchrony')]

Pairs$w1Synchrony <- as.numeric(as.character(Pairs$w1Synchrony))
Pairs$breedingSynchrony <- as.numeric(as.character(Pairs$breedingSynchrony))
Pairs$ALLSynchrony <- as.numeric(as.character(Pairs$ALLSynchrony))


for (i in 1:nrow(Pairs))
{
if(Pairs$Season[i] == 2012)
{
Pairs$w1ZSynchrony[i] <-(Pairs$w1Synchrony[i]- mean(Pairs$w1Synchrony[Pairs$Season == 2012])) / sd(Pairs$w1Synchrony[Pairs$Season == 2012])
Pairs$breedingZSynchrony[i] <-(Pairs$breedingSynchrony[i]- mean(Pairs$breedingSynchrony[Pairs$Season == 2012])) / sd(Pairs$breedingSynchrony[Pairs$Season == 2012])
Pairs$ALLZSynchrony[i] <-(Pairs$ALLSynchrony[i]- mean(Pairs$ALLSynchrony[Pairs$Season == 2012])) / sd(Pairs$ALLSynchrony[Pairs$Season == 2012])
}

if(Pairs$Season[i] == 2013)
{
Pairs$w1ZSynchrony[i] <-(Pairs$w1Synchrony[i]- mean(Pairs$w1Synchrony[Pairs$Season == 2013])) / sd(Pairs$w1Synchrony[Pairs$Season == 2013])
Pairs$breedingZSynchrony[i] <-(Pairs$breedingSynchrony[i]- mean(Pairs$breedingSynchrony[Pairs$Season == 2013])) / sd(Pairs$breedingSynchrony[Pairs$Season == 2013])
Pairs$ALLZSynchrony[i] <-(Pairs$ALLSynchrony[i]- mean(Pairs$ALLSynchrony[Pairs$Season == 2013])) / sd(Pairs$ALLSynchrony[Pairs$Season == 2013])
}
}

Pairs[,c('MIDFIDyr','Season','w1Synchrony','breedingSynchrony','ALLSynchrony','w1ZSynchrony','breedingZSynchrony','ALLZSynchrony')]

summary(Pairs$w1Synchrony)
summary(Pairs$w1Synchrony[Pairs$Season == 2012])
summary(Pairs$w1Synchrony[Pairs$Season == 2013])
summary(Pairs$w1ZSynchrony[Pairs$Season == 2012])
summary(Pairs$w1ZSynchrony[Pairs$Season == 2013])


}

head(Pairs)


{### add data AllCourtships as YN in table individuals Trt Ok
head(AllCourtships)

{# for EPCourt of females Trt Ok
AllCourtshipsFemaleTrtOkEP <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="EP")
nrow(AllCourtshipsFemaleTrtOkEP)	#2769
length(unique(AllCourtshipsFemaleTrtOkEP$FID[AllCourtshipsFemaleTrtOkEP$succYN ==1]))	# 11

AllCourtshipsFemaleTrtOkEP_listperFID <- split(AllCourtshipsFemaleTrtOkEP,AllCourtshipsFemaleTrtOkEP$FIDyr)
AllCourtshipsFemaleTrtOkEP_listperFID[[1]]

AllCourtshipsFemaleTrtOkEP_listperFID_fun = function(x)  {
if (nrow(x[x$succYN == 1,]) == 0) {return (c(0, nrow(x)))} else{return(c(1, nrow(x)))}
}

AllCourtshipsFemaleTrtOkEP_listperFID_out1 <- lapply(AllCourtshipsFemaleTrtOkEP_listperFID, FUN=AllCourtshipsFemaleTrtOkEP_listperFID_fun)
AllCourtshipsFemaleTrtOkEP_listperFID_out2 <- data.frame(rownames(do.call(rbind,AllCourtshipsFemaleTrtOkEP_listperFID_out1)),do.call(rbind, AllCourtshipsFemaleTrtOkEP_listperFID_out1))

nrow(AllCourtshipsFemaleTrtOkEP_listperFID_out2)	# 84
rownames(AllCourtshipsFemaleTrtOkEP_listperFID_out2) <- NULL
colnames(AllCourtshipsFemaleTrtOkEP_listperFID_out2) <- c('FIDyr', 'succYN', 'NbCourt')

AllCourtshipsFemaleTrtOkEP_listperFID_out2 <- subset(AllCourtshipsFemaleTrtOkEP_listperFID_out2,AllCourtshipsFemaleTrtOkEP_listperFID_out2$NbCourt != 0)

TableFemaleTrtOkSuccEPperfemale <- merge(x=AllCourtshipsFemaleTrtOkEP_listperFID_out2, y = unique(AllCourtshipsFemaleTrtOkEP[,c('FIDyr','FID','Year','FTrt')]), by.y = 'FIDyr', by.x = "FIDyr", all.x=TRUE)

head(TableFemaleTrtOkSuccEPperfemale)
nrow(TableFemaleTrtOkSuccEPperfemale) # 84

sum(TableFemaleTrtOkSuccEPperfemale$succYN) # 11
TableFemaleTrtOkSuccEPperfemale[TableFemaleTrtOkSuccEPperfemale$succYN==1,]
}

{# for EPCourt of males Trt Ok
AllCourtshipsMaleTrtOkEP <- subset (AllCourtships, AllCourtships$MIDyr%in%MIDYearOk & AllCourtships$MWEU =="EP")
nrow(AllCourtshipsMaleTrtOkEP)	#2606
length(unique(AllCourtshipsMaleTrtOkEP$MIDyr[AllCourtshipsMaleTrtOkEP$succYN ==1]))	# 15

AllCourtshipsMaleTrtOkEP_listperMID <- split(AllCourtshipsMaleTrtOkEP,AllCourtshipsMaleTrtOkEP$MIDyr)
AllCourtshipsMaleTrtOkEP_listperMID[[1]]

AllCourtshipsMaleTrtOkEP_listperMID_fun = function(x)  {
if (nrow(x[x$succYN == 1,]) == 0) {return (c(0, nrow(x)))} else{return(c(1, nrow(x)))}
}

AllCourtshipsMaleTrtOkEP_listperMID_out1 <- lapply(AllCourtshipsMaleTrtOkEP_listperMID, FUN=AllCourtshipsMaleTrtOkEP_listperMID_fun)
AllCourtshipsMaleTrtOkEP_listperMID_out2 <- data.frame(rownames(do.call(rbind,AllCourtshipsMaleTrtOkEP_listperMID_out1)),do.call(rbind, AllCourtshipsMaleTrtOkEP_listperMID_out1))

nrow(AllCourtshipsMaleTrtOkEP_listperMID_out2)	# 84
rownames(AllCourtshipsMaleTrtOkEP_listperMID_out2) <- NULL
colnames(AllCourtshipsMaleTrtOkEP_listperMID_out2) <- c('MIDyr', 'succYN', 'NbCourt')

AllCourtshipsMaleTrtOkEP_listperMID_out2 <- subset(AllCourtshipsMaleTrtOkEP_listperMID_out2,AllCourtshipsMaleTrtOkEP_listperMID_out2$NbCourt != 0)

TableMaleTrtOkSuccEPperMale <- merge(x=AllCourtshipsMaleTrtOkEP_listperMID_out2, y = unique(AllCourtshipsMaleTrtOkEP[,c('MIDyr','MID','Year','MTrt')]), by.y = 'MIDyr', by.x = "MIDyr", all.x=TRUE)

head(TableMaleTrtOkSuccEPperMale)
nrow(TableMaleTrtOkSuccEPperMale) # 84

sum(TableMaleTrtOkSuccEPperMale$succYN) # 15
TableMaleTrtOkSuccEPperMale[TableMaleTrtOkSuccEPperMale$succYN==1,]
}

}

head(TableFemaleTrtOkSuccEPperfemale)
head(TableMaleTrtOkSuccEPperMale)


{### merge AllFocal Nest activity to NestCheck

head(NestCheck)
head(AllFocal)

NestCheck$MIDFIDdate <- paste(NestCheck$MIDFID, NestCheck$Date, sep='')
AllFocal$MIDFID <- paste(AllFocal$Mid,AllFocal$FID, sep='')
AllFocal$MIDFIDdate <- paste(AllFocal$MIDFID, AllFocal$ObsvtDate, sep='')


AllFocal_listperMIDFIDDate <- split(AllFocal, AllFocal$MIDFIDdate)
x <-AllFocal_listperMIDFIDDate[[1]]


AllFocal_listperMIDFIDDate_fun <- function(x){
return (c(
unique(x$MIDFIDdate),
nrow (x),	# nbFocal
mean (x$NestBoth),	# NestBoth
mean (x$NestM),	# NestM
mean (x$NestF)	# NestF
))
}

AllFocal_listperMIDFIDDate_out1 <- lapply(AllFocal_listperMIDFIDDate, FUN= AllFocal_listperMIDFIDDate_fun)
AllFocal_listperMIDFIDDate_out2 <- data.frame(do.call(rbind, AllFocal_listperMIDFIDDate_out1))
rownames(AllFocal_listperMIDFIDDate_out2) <- NULL
colnames(AllFocal_listperMIDFIDDate_out2) <- c('MIDFIDdate','nbDayFocal','DayNestBoth','DayNestM','DayNestF')

NestCheck <- merge(x = NestCheck, y = AllFocal_listperMIDFIDDate_out2, by.x = 'MIDFIDdate', by.y= 'MIDFIDdate', all.x = TRUE)
head(NestCheck,30)

NestCheck$DayNestBoth <- as.numeric(as.character(NestCheck$DayNestBoth))
NestCheck$DayNestM <- as.numeric(as.character(NestCheck$DayNestM))
NestCheck$DayNestF <- as.numeric(as.character(NestCheck$DayNestF))

hist(NestCheck$DayNestBoth)
hist(NestCheck$DayNestM)
hist(NestCheck$DayNestF)

NestChecksubsetforNestActivity <- NestCheck[!is.na(NestCheck$nbDayFocal),c('ClutchID', 'ClutchNo','MIDFID',  'M_ID',  'F_ID', 'Treatments','NestState','NumEggs', 'NumChicks','DayClutch' ,'DayBrood', 'nbDayFocal', 'DayNestBoth', 'DayNestM', 'DayNestF')]

table(NestChecksubsetforNestActivity$DayNestBoth)
table(NestChecksubsetforNestActivity$DayNestM)
table(NestChecksubsetforNestActivity$DayNestF)

for (i in 1:nrow(NestChecksubsetforNestActivity))
{
if(NestChecksubsetforNestActivity$DayNestBoth[i] > 0)
{NestChecksubsetforNestActivity$NestBothYN[i] <- 1}
else {NestChecksubsetforNestActivity$NestBothYN[i] <- 0}

if(NestChecksubsetforNestActivity$DayNestM[i] > 0)
{NestChecksubsetforNestActivity$NestMYN[i] <- 1}
else {NestChecksubsetforNestActivity$NestMYN[i] <- 0}

if(NestChecksubsetforNestActivity$DayNestF[i] > 0)
{NestChecksubsetforNestActivity$NestFYN[i] <- 1}
else {NestChecksubsetforNestActivity$NestFYN[i] <- 0}
}

hist(NestChecksubsetforNestActivity$NestBothYN)
hist(NestChecksubsetforNestActivity$NestMYN)
hist(NestChecksubsetforNestActivity$NestFYN)

}

head(NestChecksubsetforNestActivity)



{### NEW ### Effect of number of copulation to fertility: add data AllCourt > Female Pairing Status > Eggs > clutchesIFYN
head(AllCourtships)

{# add nCop to each FIDyrday in FemalePairingStatus
AllCourtships$FIDyrday <- paste(AllCourtships$FID,AllCourtships$Year, AllCourtships$Day, sep="")

AllCourtships_listperFIDyrday <- split(AllCourtships, AllCourtships$FIDyrday)
AllCourtships_listperFIDyrday$'1132320126'


AllCourtships_listperFIDyrday_fun = function(x)  {
  x = x[order(x$Date),]
return(sum(x$succ))
}

AllCourtships_listperFIDyrday_out1 <- lapply(AllCourtships_listperFIDyrday, FUN=AllCourtships_listperFIDyrday_fun)
AllCourtships_listperFIDyrday_out2 <- data.frame(rownames(do.call(rbind, AllCourtships_listperFIDyrday_out1)),do.call(rbind, AllCourtships_listperFIDyrday_out1))
rownames(AllCourtships_listperFIDyrday_out2) <- NULL
colnames(AllCourtships_listperFIDyrday_out2) <- c('FIDyrday','nCop')

FemalePairingStatus <- merge(y = AllCourtships_listperFIDyrday_out2, x = FemalePairingStatus, by.y = 'FIDyrday', by.x = "IDyrday", all.x=TRUE)
}

{# add nCoplast10days in FemalePairingStatus
FemalePairingStatus_listperIDyr6 <- split(FemalePairingStatus,  FemalePairingStatus$IDyr)
x<-FemalePairingStatus_listperIDyr6[[2]]

FemalePairingStatus_listperIDyr_fun6 = function(x)  {
x = x[order(x$Day),]
x$nCoplast10days[1] <- x$nCop[1]
x$nCoplast10days[2] <- sum(x$nCop[1],x$nCop[2], na.rm=T)
x$nCoplast10days[3] <- sum(x$nCop[1],x$nCop[2],x$nCop[3], na.rm=T)
x$nCoplast10days[4] <- sum(x$nCop[1],x$nCop[2],x$nCop[3],x$nCop[4], na.rm=T)
x$nCoplast10days[5] <- sum(x$nCop[1],x$nCop[2],x$nCop[3],x$nCop[4],x$nCop[5], na.rm=T)
x$nCoplast10days[6] <- sum(x$nCop[1],x$nCop[2],x$nCop[3],x$nCop[4],x$nCop[5],x$nCop[6], na.rm=T)
x$nCoplast10days[7] <- sum(x$nCop[1],x$nCop[2],x$nCop[3],x$nCop[4],x$nCop[5],x$nCop[6] ,x$nCop[7], na.rm=T)  
x$nCoplast10days[8] <- sum(x$nCop[1],x$nCop[2],x$nCop[3],x$nCop[4],x$nCop[5],x$nCop[6] ,x$nCop[7] ,x$nCop[8], na.rm=T)   
x$nCoplast10days[9] <- sum(x$nCop[1],x$nCop[2],x$nCop[3],x$nCop[4],x$nCop[5],x$nCop[6] ,x$nCop[7] ,x$nCop[8] ,x$nCop[9], na.rm=T)  
x$nCoplast10days[10]<- sum(x$nCop[1],x$nCop[2],x$nCop[3],x$nCop[4],x$nCop[5],x$nCop[6] ,x$nCop[7] ,x$nCop[8] ,x$nCop[9] ,x$nCop[10], na.rm=T)  

  
for (i in 10:nrow(x) )
{x$nCoplast10days[i] <- sum(x$nCop[i],x$nCop[i-1],x$nCop[i-2],x$nCop[i-3],x$nCop[i-4],x$nCop[i-5],x$nCop[i-6],x$nCop[i-7],x$nCop[i-8],x$nCop[i-9], na.rm=T)}
return(x) 
 }

FemalePairingStatus_listperIDyrout6 = lapply(FemalePairingStatus_listperIDyr6, FemalePairingStatus_listperIDyr_fun6)
FemalePairingStatus <- do.call(rbind, FemalePairingStatus_listperIDyrout6)
rownames(FemalePairingStatus) <- NULL	


hist(log(FemalePairingStatus$nCoplast10days[FemalePairingStatus$nEggsAss >0]+1,10))

}

head(FemalePairingStatus)

{# add nCoplast10days in Eggs

Eggs <- merge(x=Eggs, y = FemalePairingStatus[,c('IDyrday','nCoplast10days' )], by.x='FassYearDay', by.y='IDyrday', all.x=TRUE)
}

head(Eggs)

	{# model EggFate = 0 (with violated assumptions)
# modPairsOkFate0outof023456 <- glmer(Fate0 ~ log(nCoplast10days+1) + scale(Season, scale=FALSE)+ scale(EggNoClutchAss, scale=FALSE) +
# (1|Fass), 
# data = Eggs[Eggs$EggFate != 1,] , family = "binomial")
# summary(modPairsOkFate0outof023456)	
}

head(TableClutchAssFate0YN)

{# add mean nb cop to clutchesIFYN
Eggs_listperClutchFAss <- split(Eggs, Eggs$ClutchAss)

Eggs_listperClutchFAss_fun = function(x) {
return(mean(x$nCoplast10days, na.rm=TRUE))
}

Eggs_listperClutchFAss_out1 <- lapply(Eggs_listperClutchFAss, FUN=Eggs_listperClutchFAss_fun)
Eggs_listperClutchFAss_out2 <- data.frame(rownames(do.call(rbind, Eggs_listperClutchFAss_out1)),do.call(rbind, Eggs_listperClutchFAss_out1))
rownames(Eggs_listperClutchFAss_out2) <- NULL
colnames(Eggs_listperClutchFAss_out2) <- c('ClutchAss','meanNCop')

TableClutchAssFate0YN <- merge(x=TableClutchAssFate0YN, y=Eggs_listperClutchFAss_out2, by='ClutchAss', all.x=TRUE)
}

	{# model ClutchIFYN
modPairsOkFate0vs23456YNPbdurlongnbCop <- glmer(IFYN ~ MassTrt + meanNCop+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE) 
+(1|Mass)+(1|Fass), 
data = TableClutchAssFate0YN , family = "binomial")
summary(modPairsOkFate0vs23456YNPbdurlongnbCop)	
}

}

head(TableClutchAssFate0YN)





# write.table(AllCourtshipRates, file = "R_AllCourtshipRates.xls", sep="\t", col.names=TRUE)
# write.table(AllCourtships, file = "R_AllCourtships.xls", sep="\t", col.names=TRUE)
# write.table(Pairs, file = "R_Pairs.xls", sep="\t", col.names=TRUE)
# write.table(allbirds, file = "R_allbirds.xls", sep="\t", col.names=TRUE)




DurationScript <- Sys.time() - TimeStart
DurationScript
# Generation of all data: 10 minutes









{#### for Uli

### laptop									# !!! working directory !! #
conDB= odbcConnectAccess("C:\\Users\\mihle\\Desktop\\_CURRENT BACK UP\\ZebraFinchDBBielefeld.mdb")

{##  birds

{# Malika's birds both seasons
MalikabirdsforUli <- allbirds[,c('Season', 'Aviary', 'Ind_ID', 'Sex','DaysPresent','sumFate56Gen','MeanVol','Relfitness', 'sumEggIDGen', 'SiringMeanVol', 'RelsiringSucc')]

MalikabirdsforUli$DaysPresent <- MalikabirdsforUli$DaysPresent - 7
MalikabirdsforUli$Exp <- 'Malika'
}

head(MalikabirdsforUli)


{# Johannes birds

{# Johannes Males
JoMaleforUli <- JohannesMales[,c('Ind_ID', 'Aviary','sumFate56Gen', 'sumEggIDGen', 'MeanVol', 'SiringMeanVol', 'Relfitness', 'RelsiringSucc')]

JoMaleforUli$Sex <- 1
}

{# Johannes Females

JohannesFemales <- sqlQuery(conDB, "
SELECT BreedingAviary_Birds.Aviary, Basic_Individuals.Ind_ID
FROM Basic_Individuals INNER JOIN (BreedingAviary_Birds INNER JOIN Basic_TrialsTreatments ON BreedingAviary_Birds.Ind_ID = Basic_TrialsTreatments.Ind_ID) ON Basic_Individuals.Ind_ID = Basic_TrialsTreatments.Ind_ID
WHERE (((Basic_Individuals.Sex)=0) AND ((Basic_TrialsTreatments.TrialTreatment)='force-pairing for quality'));
")

}

head(JoMaleforUli)
head(JohannesFemales)


{# Relative fitness and Relative siring success of FGen relative to whole aviary

	{# absolute Fitness or siring success 

for (i in 1:nrow(JohannesFemales))
{
JohannesFemales$sumFate56Gen[i] <- nrow (JohannesEggs[!(is.na(JohannesEggs$F_Gen)) & JohannesEggs$F_Gen == JohannesFemales$Ind_ID[i] & (JohannesEggs$EggFate == 5 |JohannesEggs$EggFate == 6),])

JohannesFemales$sumEggIDGen[i] <- nrow (JohannesEggs[!(is.na(JohannesEggs$F_Gen)) & JohannesEggs$F_Gen == JohannesFemales$Ind_ID[i],])

}

}

	{# calcul of mean fitness and mean siring success per aviary

outJoF = list()
aJoF = list()

volIDJoF <- c(8,9,10,20,21,22)


for (vol in volIDJoF){
outJoF[[vol]] <- round((colMeans(subset(JohannesFemales, Aviary == vol , select=sumFate56Gen))),2)
aJoF[[vol]] <- cbind(outJoF[[vol]],vol)
}

bJoF <- data.frame(do.call(rbind,aJoF))
colnames(bJoF) <- c("MeanVol","Vol")

JohannesFemales$MeanVol <-NA

for (i in 1:nrow(JohannesFemales))
{ 
JohannesFemales$MeanVol[i] <- bJoF$MeanVol[bJoF$Vol==JohannesFemales$Aviary[i]]
}


soutJoF = list()
saJoF = list()


for (vol in volIDJo){
soutJoF[[vol]] <- round((colMeans(subset(JohannesFemales, Aviary == vol , select=sumEggIDGen))),2)
saJoF[[vol]] <- cbind(soutJoF[[vol]],vol)
}

sbJoF <- data.frame(do.call(rbind,saJoF))
colnames(sbJoF) <- c("SiringMeanVol","Vol")

JohannesFemales$SiringMeanVol <-NA

for (i in 1:nrow(JohannesFemales))
{ 
JohannesFemales$SiringMeanVol[i] <- sbJo$SiringMeanVol[sbJoF$Vol==JohannesFemales$Aviary[i]]
}
}

	{# add relative fitness and siring success, relative to the whole aviary
for (i in 1:nrow(JohannesFemales))
{
JohannesFemales$Relfitness[i] <- round(JohannesFemales$sumFate56Gen[i]/JohannesFemales$MeanVol[i],2) 
JohannesFemales$RelsiringSucc[i] <- round(JohannesFemales$sumEggIDGen[i]/JohannesFemales$SiringMeanVol[i],2)

}
}

}

head(JohannesFemales)

JohannesFemales$Sex <- 0

Johannesbirds <- rbind(JoMaleforUli,JohannesFemales)

Johannesbirds$Season <- 2012
Johannesbirds$DaysPresent <- 86
Johannesbirds$DaysPresent[Johannesbirds$Ind_ID == 11010] <- 74
Johannesbirds$DaysPresent[Johannesbirds$Ind_ID == 11010] <- 64
Johannesbirds$Exp <- 'Johannes'
}

head(Johannesbirds)


BirdsForUli <- rbind(Johannesbirds,MalikabirdsforUli)
head(BirdsForUli)
# write.table(BirdsForUli, file = "R_BirdsForUli.xls", sep="\t", col.names=TRUE)

}

{## EggVolume

{# Johannes Eggs
JohannesEggs <- sqlQuery(conDB, "
SELECT Breed_Clutches.ClutchID, Breed_Clutches.M_ID, Breed_Clutches.F_ID, Breed_EggsLaid.EggID, Breed_EggsLaid.EggFate, Breed_EggsLaid.EPY, Breed_EggsLaid.DumpedEgg, Breed_EggsLaid.M_Gen, Breed_EggsLaid.F_Gen, Breed_EggsLaid.EggVolume
FROM Breed_Clutches INNER JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID
WHERE (((Breed_Clutches.Experiment)='new pair for force-pairing for quality' Or (Breed_Clutches.Experiment)='force-pairing for quality') AND ((Breed_Clutches.CageAviary)='A') AND ((Breed_Clutches.Remarks) Is Null Or (Breed_Clutches.Remarks)<>'divorced'));
")

head(JohannesEggs)
JohannesEggs$Season <- 2012
JohannesEggs$Exp <- 'Johannes'
}

{# Malika Eggs
{alles12forUli <- sqlQuery(conDB, 
"SELECT BreedingAviary_Birds2012_5.Season, alleggs2012.ClutchID, alleggs2012.M_ID, alleggs2012.F_ID, alleggs2012.EggID, alleggs2012.EggVolume, alleggs2012.EggFate, alleggs2012.M_Gen, alleggs2012.F_Gen, alleggs2012.DumpedEgg, alleggs2012.EPY
FROM (SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_5 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_4 RIGHT JOIN (SELECT Breed_Clutches.ClutchID, Breed_Clutches.Aviary, Breed_Clutches.Treatments AS PairTrt, Breed_Clutches.ClutchNo, Breed_Clutches.Pair_ID, Breed_Clutches.M_ID, BreedingAviary_Birds2012.Treatment AS MTrt, Breed_Clutches.F_ID, BreedingAviary_Birds2012_1.Treatment AS FTrt, Breed_Clutches.ClutchStart, Breed_Clutches.ClutchEnd, Breed_Clutches.StartIncubation, Breed_Clutches.ClutchSize, Breed_EggsLaid.EggID, Breed_EggsLaid.EggNoClutch, Breed_EggsLaid.LayingDate, Breed_EggsLaid.EggVolume, Breed_EggsLaid.EggFate, Breed_EggsLaid.Ind_ID, Breed_EggsLaid.SexMol, Breed_EggsLaid.M_Gen, BreedingAviary_Birds2012_2.Treatment AS MGenTrt, Breed_EggsLaid.F_Gen, BreedingAviary_Birds2012_3.Treatment AS FGenTrt, Breed_EggsLaid.DumpedEgg, Breed_EggsLaid.EPY, IIf([Breed_Clutches]![StartIncubation]-[Breed_EggsLaid]![DateFate1]>=0,0,(IIf([Breed_EggsLaid]![M_Gen] Is Not Null,[Breed_EggsLaid]![M_Gen],[Breed_Clutches]![M_ID]))) AS Mass, IIf([Breed_Clutches]![StartIncubation]-[Breed_EggsLaid]![DateFate1]>=0,0,(IIf([Breed_EggsLaid]![F_Gen] Is Not Null,[Breed_EggsLaid]![F_Gen],[Breed_Clutches]![F_ID]))) AS Fass, Breed_EggsIncubated.HatchDate, Breed_EggsIncubated.HatchOrder, Breed_EggsIncubated.Mass8dChick, Breed_EggsIncubated.FledgeDate, Breed_EggsIncubated.DateChickDied, Breed_EggsIncubated.EmbryoDiedAge, Breed_EggsIncubated.HatchOrderSurv, Breed_EggsIncubated.DateOut, Breed_EggsLaid.Remarks
FROM ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_3 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_2 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012_1 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2012)))  AS BreedingAviary_Birds2012 RIGHT JOIN (Breed_Clutches LEFT JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID) ON BreedingAviary_Birds2012.Ind_ID = Breed_Clutches.M_ID) ON BreedingAviary_Birds2012_1.Ind_ID = Breed_Clutches.F_ID) ON BreedingAviary_Birds2012_2.Ind_ID = Breed_EggsLaid.M_Gen) ON BreedingAviary_Birds2012_3.Ind_ID = Breed_EggsLaid.F_Gen) LEFT JOIN Breed_EggsIncubated ON Breed_EggsLaid.EggID = Breed_EggsIncubated.EggID
WHERE (((Breed_Clutches.Experiment)='force-pairing for choice' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice') AND ((Breed_Clutches.CageAviary)='A'))
ORDER BY Breed_EggsLaid.EggFate, Breed_EggsLaid.DumpedEgg DESC , Breed_EggsLaid.EPY DESC)  AS alleggs2012 ON BreedingAviary_Birds2012_4.Ind_ID = alleggs2012.Mass) ON BreedingAviary_Birds2012_5.Ind_ID = alleggs2012.Fass;
")
}

nrow(alles12forUli)	# 781 lines

alles12forUli$Season <- 2012	# Season for eggs with no social parents or genetic parents

Eggs12forUli <- alles12forUli[complete.cases(alles12forUli[,"EggFate"]),]	# take only eggs were egg fate was known (3 'I broke it', eggs not incubated by social parents and not genotyped)

nrow(Eggs12forUli)	# 761 eggs considered with fate <> NA


{alles13forUli <- sqlQuery(conDB, 
"SELECT BreedingAviary_Birds2013_5.Season, alleggs2013.ClutchID, alleggs2013.M_ID, alleggs2013.F_ID, alleggs2013.EggID, alleggs2013.EggVolume, alleggs2013.EggFate, alleggs2013.M_Gen, alleggs2013.F_Gen, alleggs2013.DumpedEgg, alleggs2013.EPY
FROM (SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_5 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_4 RIGHT JOIN (SELECT Breed_Clutches.ClutchID, Breed_Clutches.Aviary, Breed_Clutches.Treatments AS PairTrt, Breed_Clutches.ClutchNo, Breed_Clutches.Pair_ID, Breed_Clutches.M_ID, BreedingAviary_Birds2013.Treatment AS MTrt, Breed_Clutches.F_ID, BreedingAviary_Birds2013_1.Treatment AS FTrt, Breed_Clutches.ClutchStart, Breed_Clutches.ClutchEnd, Breed_Clutches.StartIncubation, Breed_Clutches.ClutchSize, Breed_EggsLaid.EggID, Breed_EggsLaid.EggNoClutch, Breed_EggsLaid.LayingDate, Breed_EggsLaid.EggVolume, Breed_EggsLaid.EggFate, Breed_EggsLaid.Ind_ID, Breed_EggsLaid.SexMol, Breed_EggsLaid.M_Gen, BreedingAviary_Birds2013_2.Treatment AS MGenTrt, Breed_EggsLaid.F_Gen, BreedingAviary_Birds2013_3.Treatment AS FGenTrt, Breed_EggsLaid.DumpedEgg, Breed_EggsLaid.EPY, IIf([Breed_Clutches]![StartIncubation]-[Breed_EggsLaid]![DateFate1]>=0,0,(IIf([Breed_EggsLaid]![M_Gen] Is Not Null,[Breed_EggsLaid]![M_Gen],[Breed_Clutches]![M_ID]))) AS Mass, IIf([Breed_Clutches]![StartIncubation]-[Breed_EggsLaid]![DateFate1]>=0,0,(IIf([Breed_EggsLaid]![F_Gen] Is Not Null,[Breed_EggsLaid]![F_Gen],[Breed_Clutches]![F_ID]))) AS Fass, Breed_EggsIncubated.HatchDate, Breed_EggsIncubated.HatchOrder, Breed_EggsIncubated.Mass8dChick, Breed_EggsIncubated.FledgeDate, Breed_EggsIncubated.DateChickDied, Breed_EggsIncubated.EmbryoDiedAge, Breed_EggsIncubated.HatchOrderSurv, Breed_EggsIncubated.DateOut, Breed_EggsLaid.Remarks
FROM ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_3 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_2 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013_1 RIGHT JOIN ((SELECT BreedingAviary_Birds.* FROM BreedingAviary_Birds WHERE (((BreedingAviary_Birds.Season)=2013)))  AS BreedingAviary_Birds2013 RIGHT JOIN (Breed_Clutches LEFT JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID) ON BreedingAviary_Birds2013.Ind_ID = Breed_Clutches.M_ID) ON BreedingAviary_Birds2013_1.Ind_ID = Breed_Clutches.F_ID) ON BreedingAviary_Birds2013_2.Ind_ID = Breed_EggsLaid.M_Gen) ON BreedingAviary_Birds2013_3.Ind_ID = Breed_EggsLaid.F_Gen) LEFT JOIN Breed_EggsIncubated ON Breed_EggsLaid.EggID = Breed_EggsIncubated.EggID
WHERE (((Breed_Clutches.Experiment)='force-pairing for choice s2' Or (Breed_Clutches.Experiment)='new pair for force-pairing for choice s2') AND ((Breed_Clutches.CageAviary)='A'))
ORDER BY Breed_EggsLaid.EggFate, Breed_EggsLaid.DumpedEgg DESC , Breed_EggsLaid.EPY DESC)  AS alleggs2013 ON BreedingAviary_Birds2013_4.Ind_ID = alleggs2013.Mass) ON BreedingAviary_Birds2013_5.Ind_ID = alleggs2013.Fass;

")
}

nrow(alles13forUli)	# 715 total lines

alles13forUli$Season <- 2013	# season for eggs without social parents

EggsnotNA13 <- alles13forUli[complete.cases(alles13forUli[,"EggFate"]),]	# take only eggs were egg fate was known (3 'I broke it', eggs not incubated by social parents and not genotyped)

Eggs13forUli <- subset (EggsnotNA13, EggsnotNA13$EggFate != -1)	# 24 eggs Fate -1 (laid after 21/08/2013)

nrow(Eggs13forUli)	# 673 eggs considered	


head(Eggs12forUli)
head(Eggs13forUli)
EggsForUli <- rbind(Eggs12forUli, Eggs13forUli)


EggsforUli <- EggsForUli[,c('Season','ClutchID',  'M_ID',  'F_ID', 'EggID', 'EggFate', 'EPY', 'DumpedEgg', 'M_Gen', 'F_Gen', 'EggVolume')]

EggsforUli$Exp <- 'Malika'
}

head(EggsforUli)
head(JohannesEggs)

AllEggsforUli <- rbind(JohannesEggs,EggsforUli)
head(AllEggsforUli)
# write.table(AllEggsforUli, file = "R_AllEggsforUli.xls", sep="\t", col.names=TRUE)
}


close (conDB)
}













#######################################################################################################################
#######################################################################################################################
###############################################							###############################################
###############################################	 STATISTICAl ANALYSES	###############################################
###############################################							###############################################
#######################################################################################################################
#######################################################################################################################

require(lme4)
require(arm)

# require(MASS) # works with nlme > conflict with lme4 !
# search()
# detach(pos=2) # or specify lme4::ranef
# library(effects)



	##################################################
	## 	      GLMER Models on tables Eggs 	        ##			( !! individuals/pairs with no assigned/genetic eggs are not 
	##################################################						included with a value of zero !! )

head(Eggs)

{# as.factor
Eggs$Season <- as.numeric(Eggs$Season)
Eggs$ClutchID <- as.factor(Eggs$ClutchID)
Eggs$MID <-as.factor(Eggs$MID)
Eggs$MTrt <-as.factor(Eggs$MTrt)
Eggs$FID <-as.factor(Eggs$FID)
Eggs$FTrt <-as.factor(Eggs$FTrt)
Eggs$MIDFIDSoc <-as.factor(Eggs$MIDFIDSoc)
Eggs$MGen <-as.factor(Eggs$MGen)
Eggs$MGenTrt <-as.factor(Eggs$MGenTrt)
Eggs$FGen <-as.factor(Eggs$FGen)
Eggs$FGenTrt <-as.factor(Eggs$FGenTrt)
Eggs$MIDFIDGen <-as.factor(Eggs$MIDFIDGen)
Eggs$Mass <-as.factor(Eggs$Mass )
Eggs$MassTrt <-as.factor(Eggs$MassTrt)
Eggs$Fass <-as.factor(Eggs$Fass)
Eggs$FassTrt <-as.factor(Eggs$FassTrt )
Eggs$MIDFIDass <-as.factor(Eggs$MIDFIDass)
Eggs$ClutchAss <- as.factor(Eggs$ClutchAss)
}

{# hist
dev.new()
hist(Eggs$FassPbdurlong)
hist(Eggs$FassPbdurlong[Eggs$MIDFIDass%in%MIDFIDOk & (is.na(Eggs$EPY) | Eggs$EPY == "0" )])
hist(sqrt(Eggs$FassPbdurlong))
hist(sqrt(Eggs$FassPbdurlong[Eggs$MIDFIDass%in%MIDFIDOk & (is.na(Eggs$EPY) | Eggs$EPY == "0" )]))
scatter.smooth(Eggs$TempInc,Eggs$EggFate)
scatter.smooth(Eggs$TempInc,Eggs$Fate1)

par(mfrow=c(1,2))
scatter.smooth(Eggs$TempInc[Eggs$Season == 2012],Eggs$Fate1[Eggs$Season == 2012], xlim = c(22,38))
scatter.smooth(Eggs$TempInc[Eggs$Season == 2013],Eggs$Fate1[Eggs$Season == 2013], xlim = c(22,38))

par(mfrow=c(1,2))
scatter.smooth(Eggs$TempHatch[Eggs$Season == 2012 ],Eggs$Fate34[Eggs$Season == 2012], xlim = c(15,40))
scatter.smooth(Eggs$TempHatch[Eggs$Season == 2013],Eggs$Fate34[Eggs$Season == 2013], xlim = c(15,40))


# how many eggs per day season
par(mfrow=c(2,1))
plot(table(Eggs$Day[Eggs$Season == 2012]), xlim = c(6,93), ylab = 'Nb eggs', main ='2012')
plot(table(Eggs$Day[Eggs$Season == 2013]), xlim = c(6,93),ylab = 'Nb eggs', main ='2013')

# how many eggs genotyped
nrow(Eggs)	#1434
nrow(Eggs[!is.na(Eggs$FGen),])		# 1032 eggs genotyped
nrow(Eggs[is.na(Eggs$FGen),])	# 402
nrow(Eggs[!is.na(Eggs$FGen) & Eggs$FGenYear%in%FIDYearOk,])	#871
nrow(Eggs[is.na(Eggs$FGen) & Eggs$FIDYear%in%FIDYearOk,])	#330
nrow(Eggs[!is.na(Eggs$FGen) & Eggs$MGenYear%in%MIDYearOk,])	#883
nrow(Eggs[is.na(Eggs$FGen) & Eggs$MIDYear%in%MIDYearOk,])	#334
nrow(Eggs[is.na(Eggs$FGen) & Eggs$EggFate == 0 ,]) #80
nrow(Eggs[is.na(Eggs$FGen) & Eggs$EggFate == 1 ,]) #310 > 1124 valid eggs
nrow(Eggs[is.na(Eggs$FGen) & Eggs$EggFate == 2 ,]) #8
nrow(Eggs[is.na(Eggs$FGen) & Eggs$EggFate == 3 ,]) #3
nrow(Eggs[is.na(Eggs$FGen) & Eggs$EggFate == 4 ,]) #1
nrow(Eggs[is.na(Eggs$FGen) & Eggs$EggFate == 5 ,]) #0


# what temperature inc per day season
par(mfrow=c(2,1))
plot(Eggs$Day[Eggs$Season == 2012],Eggs$TempInc[Eggs$Season == 2012], xlim = c(6,93),xaxp = c(0,93,93), ylab = 'TempInc', xlab ='', main ='2012')
plot(Eggs$Day[Eggs$Season == 2013],Eggs$TempInc[Eggs$Season == 2013], xlim = c(6,93),xaxp = c(0,93,93), ylab = 'TempInc', xlab ='', main ='2013')

# what temperature hatch per day season
par(mfrow=c(2,1))
plot(Eggs$Day[Eggs$Season == 2012],Eggs$TempHatch[Eggs$Season == 2012], xlim = c(6,93),xaxp = c(0,93,93), ylab = 'TempHatch', xlab ='', main ='2012')
plot(Eggs$Day[Eggs$Season == 2013],Eggs$TempHatch[Eggs$Season == 2013], xlim = c(6,93),xaxp = c(0,93,93), ylab = 'TempHatch', xlab ='', main ='2013')

# how many eggs per day season
par(mfrow=c(5,1))
plot(table(Eggs$Day[Eggs$Season == 2012 & Eggs$EggFate == 0]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 0', main ='2012')
plot(table(Eggs$Day[Eggs$Season == 2012 & Eggs$EggFate == 1]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 1')
plot(table(Eggs$Day[Eggs$Season == 2012 & Eggs$EggFate == 2]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 2')
plot(table(Eggs$Day[Eggs$Season == 2012 & Eggs$EggFate == 3 | Eggs$EggFate == 4]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 34')
plot(table(Eggs$Day[Eggs$Season == 2012 & Eggs$EggFate == 5 | Eggs$EggFate == 6]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 56')

par(mfrow=c(5,1))
plot(table(Eggs$Day[Eggs$Season == 2013 & Eggs$EggFate == 0]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 0', main ='2013')
plot(table(Eggs$Day[Eggs$Season == 2013 & Eggs$EggFate == 1]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 1')
plot(table(Eggs$Day[Eggs$Season == 2013 & Eggs$EggFate == 2]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 2')
plot(table(Eggs$Day[Eggs$Season == 2013 & Eggs$EggFate == 3 | Eggs$EggFate == 4]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 34')
plot(table(Eggs$Day[Eggs$Season == 2013 & Eggs$EggFate == 5 | Eggs$EggFate == 6]), xlim = c(6,93),xaxp = c(0,93,93), ylab = 'Fate 56')

# chick/fledgling mortality
table(Eggs$AgeChickDied[Eggs$MIDFIDSoc%in%MIDFIDOk])
plot(table(Eggs$AgeChickDied[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$AgeChickDied <35]))

table(Eggs$AgeChickDied[Eggs$MIDFIDSoc%in%MIDFIDOk],Eggs$MTrt[Eggs$MIDFIDSoc%in%MIDFIDOk] )
table(Eggs$AgeChickDied[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$AgeChickDied <=35],Eggs$MTrt[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$AgeChickDied <=35] )
colSums(table(Eggs$AgeChickDied[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$AgeChickDied <=35],Eggs$MTrt[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$AgeChickDied <=35] ))
colSums(table(Eggs$AgeChickDied[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$AgeChickDied <=3],Eggs$MTrt[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$AgeChickDied <=3] ))
colSums(table(Eggs$AgeChickDied[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$AgeChickDied <=2],Eggs$MTrt[Eggs$MIDFIDSoc%in%MIDFIDOk& Eggs$AgeChickDied <=2] ))


par(mfrow=c(1,2)) 
hist(TableClutchSocFated8$BroodSize[TableClutchSocFated8$MTrt == 'NC'], ylim = c(0,35) )
hist(TableClutchSocFated8$BroodSize[TableClutchSocFated8$MTrt == 'C'], ylim = c(0,35) )


hist(Eggs$AgeChickDiedasFL)
table(Eggs$AgeChickDiedasFL)
head(Eggs[!(is.na(Eggs$FledgeDate)),])

nrow(Eggs[!(is.na(Eggs$FledgeDate)),])	#491 FL

nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk,])	#406 FL from MIDFIDSocOk

nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'C',])	#251
nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'NC',])	# 155

nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'C' & !(is.na(Eggs$DateChickDied)),])	# 38
nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'NC'& !(is.na(Eggs$DateChickDied)),])	# 34

# 15.13944% dead FL for C 
# 21.93548% dead FL for NC 

hist(Eggs$AgeChickDied, breaks=120)

nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'C' & !(is.na(Eggs$DateChickDied)) & Eggs$AgeChickDied <= 35,])	# 29
nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'NC'& !(is.na(Eggs$DateChickDied)) & Eggs$AgeChickDied <= 35,])	# 28

nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'C' & Eggs$EggFate == 4,])	# 29
nrow(Eggs[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'NC' & Eggs$EggFate == 4,])	# 28

Eggs$EggFate[!(is.na(Eggs$FledgeDate)) & Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'C' & !(is.na(Eggs$DateChickDied)) & Eggs$AgeChickDiedasFL < 35]

Eggs[Eggs$EggFate == 4,c('ClutchID','Ind_ID','FLYN','AgeChickFL','AgeChickDied','AgeChickDiedasFL')]

Eggs[Eggs$EggFate == 4 & Eggs$FLYN == 1 & is.na(Eggs$Ind_ID),c('ClutchID','Ind_ID','FLYN','AgeChickFL','AgeChickDied','AgeChickDiedasFL')]

hist(Eggs$AgeChickFL)
hist(Eggs$AgeChickFL[Eggs$EggFate>4])
}


{### Pairs that kept the treatment									( !! ! Model assumptions violated ? !! )
# function poly: center x around zero so that x and x^2 are not correlated anymore

# MIDFIDOk <- unique(allbirds$MIDFID[allbirds$Divorced == 0 & allbirds$Ind_ID != 11190 & allbirds$Ind_ID != 11187])# Pairs that kept the treatment and are monogamous 


{# EggFate 56 out of 0123456	.
# MIDFIDass has to belong to MIDFIDOk: EPY removed from the subset

modPairsOk <- glmer(Fate56 ~ MassTrt+scale(Season, scale=FALSE)*(poly(Day,2))+scale(EggNoClutchAss, scale=FALSE) +(1|MIDFIDass)+(1|ClutchAss) +(1|Fass) +(1|Mass) , data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk,], family = "binomial")
summary(modPairsOk)	# p = 0.08880 .	(p = 0.12971 if mongamous only)

invlogit(-0.96666)	# 28 %
invlogit(-1.51299)	# 18 %

modPairsOk <- glmer(Fate56 ~ MassTrt+scale(Season, scale=FALSE)+scale(EggNoClutchAss, scale=FALSE) +(1|MIDFIDass)+(1|ClutchAss) +(1|Fass) +(1|Mass) , data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk,], family = "binomial")
summary(modPairsOk)	# p = 0.0753 . (p = 0.112 if mongamous only)

invlogit(-0.95289)	# 28 %
invlogit(-1.52729)	# 18 %


modPairsOkSoc <- glmer(Fate56 ~ MTrt+scale(Season, scale=FALSE)*(poly(Day,2))+scale(EggNoClutch, scale=FALSE) +(1|MIDFIDSoc)+(1|ClutchID) +(1|FID) +(1|MID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkSoc)	# p =  0.019695 *	(p = 0.034337 *  if mongamous only)

invlogit( -0.78842)	# 31 %
invlogit( -1.56172)	# 17 %

modPairsOkSoc <- glmer(Fate56 ~ MTrt+scale(Season, scale=FALSE)+scale(EggNoClutch, scale=FALSE) +(1|MIDFIDSoc)+(1|ClutchID) +(1|FID) +(1|MID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkSoc)	# p = 0.01379 * 	(p = 0.025413 *  if mongamous only)

invlogit(-0.76489)	# 32 %
invlogit(-1.59191)	# 17 %



modPairsOk <- glmmPQL(Fate56 ~ MassTrt+scale(Season, scale=FALSE)*(poly(Day,2))+scale(EggNoClutchAss, scale=FALSE) ,random= ~1|Fass/ClutchAss, data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk,], family = "binomial")
summary(modPairsOk)	# p = 0.12 .


modPairsOk <- glmmPQL(Fate56 ~ FassTrt+scale(Season, scale=FALSE)+scale(EggNoClutchAss, scale=FALSE) ,random= ~1|Fass/ClutchAss, data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk,], family = "binomial")
summary(modPairsOk)	# p = 0.1110 .

modPairsOk <- glmmPQL(Fate56 ~ FTrt+scale(Season, scale=FALSE)+scale(EggNoClutch, scale=FALSE) ,random= ~1|FID/ClutchID, data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOk)	# p = 0.0196 *



	{# Mihai stuff
	require(effects)	
	e <- Effect('MassTrt',modPairsOk,Eggs[Eggs$MIDFIDass%in%MIDFIDOk,],list(link=binomial()$linkfun, inverse=binomial()$linkinv))	
	plot(e)
	Est <- summary(modPairsOk)$coefficients[,1]
	data.frame(e)$fit
	binomial()$linkinv (Est)	# 27% C	17% NC
}	

	{## model assumptions checking Bernoulli model with random factors		!! assumptions violated ? !!
	
	mean(unlist(ranef(modPairsOk)$MIDFIDass))
	mean(unlist(ranef(modPairsOk)$ClutchAss))	
	mean(unlist(ranef(modPairsOk)$Fass))
	mean(unlist(ranef(modPairsOk)$Mass))	
	
	# qqplots residuals and ranef
	qqnorm(resid(modPairsOk))
	qqline(resid(modPairsOk))
	qqnorm(unlist(ranef(modPairsOk)$MIDFIDass))
	qqline(unlist(ranef(modPairsOk)$MIDFIDass))	
	qqnorm(unlist(ranef(modPairsOk)$ClutchAss))
	qqline(unlist(ranef(modPairsOk)$ClutchAss))		
	qqnorm(unlist(ranef(modPairsOk)$Fass))
	qqline(unlist(ranef(modPairsOk)$Fass))
	qqnorm(unlist(ranef(modPairsOk)$Mass))
	qqline(unlist(ranef(modPairsOk)$Mass))

	# residuals vs fitted

								# Lotte stuff
							resid_fitted = function(x, probs = c((0:40)*0.025), ...) {{
									 q = quantile(fitted(x), probs = probs)
									 q = cbind(q[1:(length(q)-1)], q[2:length(q)])
									 q2 = apply(q, MARGIN = 1, FUN = function(x, resid, fitted) {{ 
							mean(resid[which(fitted < x[2] & fitted >= x[1])]) }}, resid(x), fitted(x) )
									 q = q[,1]
									 plot(q2 ~ q, ylim = c(min(resid(x)), max(resid(x))), xlim = 
							c(min(q), max(q)), col = 'red', xlab = '', ylab = '', axes = FALSE, 
							...); par(new = TRUE); plot(resid(x) ~ fitted(x), ylim = 
							c(min(resid(x)), max(resid(x))), xlim = c(min(fitted(x)), 
							max(fitted(x)))); abline(h = 0, lty = 3)
								 }}
	 
par(mfrow=c(1,2))  
resid_fitted(modPairsOk)
scatter.smooth(fitted(modPairsOk), resid(modPairsOk))
abline(h=0, lty=2)

	
	# residuals vs predictors
	scatter.smooth(Eggs$FassPbdurlong[Eggs$MIDFIDass%in%MIDFIDOk], resid(modPairsOk))
	abline(h=0, lty=2)
	scatter.smooth(Eggs$EggNoClutchAss[Eggs$MIDFIDass%in%MIDFIDOk], resid(modPairsOk))
	abline(h=0, lty=2)
	scatter.smooth(Eggs$Day[Eggs$MIDFIDass%in%MIDFIDOk], resid(modPairsOk))
	abline(h=0, lty=2)
	
	# data vs. fitted ?
	dat56 <- Eggs[Eggs$MIDFIDass%in%MIDFIDOk,]
	dat56$fitted <- fitted(modPairsOk)
	scatter.smooth(dat56$fitted, jitter(dat56$Fate56/1, 0.05),ylim=c(0, 1))
	abline(0,1)
	
	# data and fitted against all predictors
	boxplot(fitted~MassTrt, dat56, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate56 probability", xlab="MassTrt")
	boxplot(fitted~Season, dat56, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate56 probability", xlab="Season")
	scatter.smooth(dat56$FassPbdurlong,dat56$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate56 probability", xlab="FassPbdurlong")

	}

	{# percentages of 56 out of 0123456 > fit the model estimates ?
sum(Eggs$Fate56[Eggs$MIDFIDass%in%MIDFIDOk])	#323

percentFate56outof0123456forC <- sum(Eggs$Fate56[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "C"]) / (length(Eggs$EggID[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "C"]))	# 35% 	C

percentFate56outof0123456forNC <- sum(Eggs$Fate56[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "NC"]) / (length(Eggs$EggID[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "NC"]))	# 23.4% 	NC	


sum(Eggs$Fate56[Eggs$MIDFIDSoc%in%MIDFIDOk])	#349

percentFate56outof0123456forCSoc <- sum(Eggs$Fate56[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]) / (length(Eggs$EggID[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]))	# 37% 	C

percentFate56outof0123456forNCSoc <- sum(Eggs$Fate56[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]) / (length(Eggs$EggID[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]))	# 22% 	NC
}
}

{# EggFate 34 out of 3456		*
# MIDFIDSoc has to belong to MIDFIDOk: EPY and dumped eggs included in the subset

modPairsOkFate34outof3456 <- glmer(Fate34 ~ MTrt+poly(Day,2)*scale(Season, scale=FALSE)+ scale(HatchOrder, scale=FALSE) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# p = 0.048*	(p = 0.08596 .  if mongamous only)
	
invlogit(-0.77817)	# 31%	C
invlogit(-0.02291)	# 49%	NC	

modPairsOkFate34outof3456 <- glmer(Fate34 ~ MTrt+scale(Season, scale=FALSE)+ scale(HatchOrder, scale=FALSE) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# p = 0.02929 *	(p =  0.05505 .  if mongamous only)

invlogit(-0.76143)#0.3183359
invlogit(0.07710)#0.5192655




modPairsOkFate34outof3456 <- glmer(Fate34 ~ -1+MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# p =  0.02917 * 	(p =  0.05381 .  if mongamous only)

invlogit(-0.75064)#0.3206819
(invlogit(-0.75064+0.24794)-invlogit(-0.75064)+invlogit(-0.75064)-invlogit(-0.75064-0.24794))/2	# 0.05384283
invlogit(0.06064)#0.5151554
(invlogit(-0.06064+0.28135)-invlogit(-0.06064)+invlogit(-0.06064)-invlogit(-0.06064-0.28135))/2	# 0.06981422

# the difference:
0.5151554-0.3206819 # 0.1944735
0.1944735*100/0.5151554 # 37.75045


### year 2012 2013 separated

modPairsOk2012Fate34outof3456 <- glmer(Fate34 ~ -1+MTrt+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2 & Eggs$Season == 2012,], family = "binomial")
summary(modPairsOk2012Fate34outof3456)	# p =  0.05019 . 
invlogit(-0.5829)#0.3582656
(invlogit(-0.5829+0.3179)-invlogit(-0.5829)+invlogit(-0.5829)-invlogit(-0.5829-0.3179))/2	# 0.07262444
invlogit(0.4124)#0.6016632
(invlogit(0.4124+0.28135)-invlogit(0.4124)+invlogit(0.4124)-invlogit(0.4124-0.28135))/2	# 0.06704246

modPairsOk2013Fate34outof3456 <- glmer(Fate34 ~ -1+MTrt+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2 & Eggs$Season == 2013,], family = "binomial")
summary(modPairsOk2013Fate34outof3456)	# p =  0.1798
invlogit(-0.9439)#0.2801132
(invlogit(-0.9439+0.3158)-invlogit(-0.9439)+invlogit(-0.9439)-invlogit(-0.9439-0.3158))/2	# 0.06345797
invlogit(-0.3345)#0.4171461
(invlogit(-0.3345+0.3268)-invlogit(-0.3345)+invlogit(-0.3345)-invlogit(-0.3345-0.3268))/2	# 0.07881368



# controlling for EPY/dumped status

modPairsOkFate34outof3456 <- glmer(Fate34 ~ MTrt + EPY + DumpedEgg +scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# 

Eggs$MTrtnum <- as.numeric(Eggs$MTrt)
modPairsOkFate34outof3456 <- glmer(Fate34 ~ scale(MTrtnum) + EPY + scale(DumpedEgg) +scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# 


modPairsOkFate34outof3456 <- glmer(Fate34 ~ scale(MTrtnum) + scale(EPY) + DumpedEgg +scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# 



# dataset T1-6
Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,c('EggID','ClutchID','MIDFIDSoc','MID','FID','Fate34','MTrt','EPY','DumpedEgg','Season','HatchOrder','FassPbdurlong')]




modPairsOkFate34outof3456 <- glmer(Fate34 ~ MTrt*poly(HatchOrder, 2) +scale(Season, scale=FALSE)+ (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# MTrtNC:poly(HatchOrder, 2)2  p = 0.06191 .


modPairsOkFate34outof3456Ass <- glmer(Fate34 ~ -1+MassTrt+scale(Season, scale=FALSE)+ scale(HatchOrder, scale=FALSE) + (1|ClutchAss)+ (1|MIDFIDass)+(1|Mass)+ (1|Fass) , data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456Ass)	# p = 0.11304

invlogit(-0.72706)# 0.3258402
invlogit(-0.11959)# 0.4701381






# editor's choice (in genetic clutch but without Dumped eggs):
dataeditor <- Eggs[Eggs$MIDFIDGen%in%MIDFIDOk & !(is.na(Eggs$Dumped)) & Eggs$Dumped == 0 & Eggs$EggFate > 2 & Eggs$MIDFIDGen == Eggs$MIDFIDSoc,]
nrow(dataeditor)#500

modPairsOkFate34outof3456GEN <- glmer(Fate34 ~ MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchAss)+ (1|MIDFIDass)+(1|Mass)+ (1|Fass) , data = dataeditor, family = "binomial")
summary(modPairsOkFate34outof3456GEN)
# !!! model fails to converge !!  p = 0.10617

modPairsOkFate34outof3456GENwithoutMID <- glmer(Fate34 ~ -1+MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchAss)+ (1|MIDFIDass)+ (1|Fass) , data = dataeditor, family = "binomial")
summary(modPairsOkFate34outof3456GENwithoutMID)
# model converge   p = 0.10625  the one

invlogit(-0.77071) # C 0.3163255
(invlogit(-0.77071+0.27781)-invlogit(-0.77071)+invlogit(-0.77071)-invlogit(-0.77071-0.27781))/2	# 0.05985062
invlogit(-0.07974) # NC 0.4800756
(invlogit(-0.07974+0.32432)-invlogit(-0.07974)+invlogit(-0.07974)-invlogit(-0.07974-0.32432))/2	# 0.08025237


modPairsOkFate34outof3456GENwithouFID <- glmer(Fate34 ~ MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchAss)+ (1|MIDFIDass)+(1|Mass) , data = dataeditor, family = "binomial")
summary(modPairsOkFate34outof3456GENwithouFID)
# model converge   p = 0.08030 .

modPairsOkFate34outof3456GENwithoutMIDFID <- glmer(Fate34 ~ MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchAss)+ (1|Fass)+(1|Mass) , data = dataeditor, family = "binomial")
summary(modPairsOkFate34outof3456GENwithoutMIDFID)
# model converge p = 0.10628 

modPairsOkFate34outof3456GENwithjustClutchID <- glmer(Fate34 ~ MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchAss) , data = dataeditor, family = "binomial")
summary(modPairsOkFate34outof3456GENwithjustClutchID)
# model converge   p = 0.08030 .

modPairsOkFate34outof3456GENwithoutMIDFIDandMID <- glmer(Fate34 ~ MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchAss)+ (1|Fass) , data = dataeditor, family = "binomial")
summary(modPairsOkFate34outof3456GENwithoutMIDFIDandMID)
# model converge   p = 0.10625 







modPairsOkFate34outof3456 <- glmmPQL(Fate34 ~ MTrt+poly(Day,2)*scale(Season, scale=FALSE)+ scale(HatchOrder, scale=FALSE), random= ~1|FID/ClutchID, data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	 # p = 0.0723 .


modPairsOkFate34outof3456 <- glmmPQL(Fate34 ~ MTrt+scale(Season, scale=FALSE)+ scale(HatchOrder, scale=FALSE), random= ~1|FID/ClutchID, data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	 # p =  0.045 *

modPairsOkFate34outof3456Ass <- glmmPQL(Fate34 ~ MassTrt+scale(Season, scale=FALSE)+ scale(HatchOrder, scale=FALSE), random= ~1|Fass/ClutchAss , data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456Ass)	# p = 0.1457


	{# model assumptions checking
	mean(unlist(ranef(modPairsOkFate34outof3456)$ClutchID))
	mean(unlist(ranef(modPairsOkFate34outof3456)$FID))
	
	
	# qqplots residuals and ranef
	qqnorm(resid(modPairsOkFate34outof3456))
	qqline(resid(modPairsOkFate34outof3456))
	qqnorm(unlist(ranef(modPairsOkFate34outof3456)))
	qqline(unlist(ranef(modPairsOkFate34outof3456)))
	
	# residuals vs fitted									# !! quite awful !!	
	scatter.smooth(fitted(modPairsOkFate34outof3456), resid(modPairsOkFate34outof3456))	
	abline(h=0, lty=2)
	
	# residuals vs predictors
	scatter.smooth(Eggs$FassPbdurlong[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2], resid(modPairsOkFate34outof3456))
	abline(h=0, lty=2)
	scatter.smooth(Eggs$TempHatch[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2], resid(modPairsOkFate34outof3456))
	abline(h=0, lty=2)
	scatter.smooth(Eggs$Day[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2], resid(modPairsOkFate34outof3456))
	abline(h=0, lty=2)	
	plot(Eggs$Season[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2], resid(modPairsOkFate34outof3456))
	abline(h=0, lty=2)	
	plot(Eggs$MTrt[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2], resid(modPairsOkFate34outof3456))
	abline(h=0, lty=2)	
	
	
	# data vs. fitted ?
	dat34 <- Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,]
	dat34$fitted <- fitted(modPairsOkFate34outof3456)
	scatter.smooth(dat34$fitted, jitter(dat34$Fate34/(dat34$Fate34+dat34$Fate56), 0.05),ylim=c(0, 1))
	abline(0,1)	

	# data and fitted against all predictors
	boxplot(fitted~MTrt, dat34, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate34 probability", xlab="MTrt")
	boxplot(fitted~Season, dat34, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate34 probability", xlab="Season")
	scatter.smooth(dat34$FassPbdurlong,dat34$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate34 probability", xlab="FassPbdurlong")
	scatter.smooth(dat34$TempHatch,dat34$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate34 probability", xlab="TempHatch")

	}

	{# percentage of 34 out of 3456	> fit the model estimates ?
sum(Eggs$Fate34[Eggs$MIDFIDSoc%in%MIDFIDOk])	#245

percentFate34outof3456forC <- sum(Eggs$Fate34[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]) / (sum(Eggs$Fate3456[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]))	# 36.4% 	C	N=349

percentFate34outof3456forNC <- sum(Eggs$Fate34[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]) / (sum(Eggs$Fate3456[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]))	# 48.1% 	NC	N= 245

sum(Eggs$Fate34[Eggs$MIDFIDass%in%MIDFIDOk])	#220

percentFate34outof3456AssforC <- sum(Eggs$Fate34[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "C"]) / (sum(Eggs$Fate3456[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "C"]))	# 36.8% 	C

percentFate34outof3456AssforNC <- sum(Eggs$Fate34[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "NC"]) / (sum(Eggs$Fate3456[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "NC"]))	# 46% 	NC



}

	{# Pbdurlong effect
modPairsOkFate34outof3456Pbdurlong <- glmer(Fate34 ~ FassPbdurlong+MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456Pbdurlong)

}
}


{# EggFate 3 out of 3456		ns
# MIDFIDSoc has to belong to MIDFIDOk: EPY and dumped eggs included in the subset

modPairsOkFate3outof3456 <- glmer(Fate3 ~ poly(Day,2)*Season+ HatchOrder + ClutchNo+ EggVolume + FassPbdurlong + TempHatch  + MTrt+ (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate3outof3456)	# p = 0.22

modPairsOkFate3outof3456 <- glmer(Fate3 ~ MTrt+poly(Day,2)*Season+ (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate3outof3456)	# p = 0.33




modPairsOkFate3outof3456 <- glmer(Fate3 ~ -1+MTrt+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate3outof3456) # p = 0.32831


invlogit(-1.8990)#0.1302217
invlogit(-1.4970)#0.1828734

invlogit(0.2769)#0.5687861
invlogit(0.3157)#0.578276



table(Eggs$AgeChickDied[Eggs$Fate3 == 1])
	
	

	{# model assumptions checking

	# qqplots residuals and ranef
	qqnorm(resid(modPairsOkFate3outof3456))
	qqline(resid(modPairsOkFate3outof3456))
	qqnorm(unlist(ranef(modPairsOkFate3outof3456)))
	qqline(unlist(ranef(modPairsOkFate3outof3456)))
	
	# residuals vs fitted									# !! quite awful !!	
	scatter.smooth(fitted(modPairsOkFate3outof3456), resid(modPairsOkFate3outof3456))	
	abline(h=0, lty=2)
	
	# residuals vs predictors
	scatter.smooth(Eggs$FassPbdurlong[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2], resid(modPairsOkFate3outof3456))
	abline(h=0, lty=2)
	scatter.smooth(Eggs$TempHatch[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2], resid(modPairsOkFate3outof3456))
	abline(h=0, lty=2)
	
	# data vs. fitted ?
	dat3 <- Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,]
	dat3$fitted <- fitted(modPairsOkFate3outof3456)
	scatter.smooth(dat3$fitted, jitter(dat3$Fate3, 0.05),ylim=c(0, 1))
	abline(0,1)	

	# data and fitted against all predictors
	boxplot(fitted~MTrt, dat3, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate3 probability", xlab="MTrt")
	boxplot(fitted~Season, dat3, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate3 probability", xlab="Season")
	scatter.smooth(dat3$FassPbdurlong,dat3$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate3 probability", xlab="FassPbdurlong")
	scatter.smooth(dat3$TempHatch,dat3$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate3 probability", xlab="TempHatch")

	}

	{# percentage of 3 out of 3456	> fit the model estimates ?
percentFate3outof3456forC <- 100 * sum(Eggs$Fate3[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]) / (sum(Eggs$Fate3456[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]))	# 22% 	C

percentFate3outof3456forNC <- 100 * sum(Eggs$Fate3[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]) / (sum(Eggs$Fate3456[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]))	# 27% 	NC
	}
}

{# EggFate 4 out of 456			ns
# MIDFIDSoc has to belong to MIDFIDOk: EPY and dumped eggs included in the subset

modPairsOkFate4outof456 <- glmer(Fate4 ~ poly(Day,2)*Season+ HatchOrder + ClutchNo+ EggVolume + FassPbdurlong + TempHatch  + MTrt+ (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 3,], family = "binomial")
summary(modPairsOkFate4outof456)	# p = 0.10

modPairsOkFate4outof456 <- glmer(Fate4 ~ MTrt+poly(Day,2)*Season+ HatchOrder + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 3,], family = "binomial")
summary(modPairsOkFate4outof456)	# p = 0.19
	

	{# model assumptions checking

	# qqplots residuals and ranef
	qqnorm(resid(modPairsOkFate4outof456))
	qqline(resid(modPairsOkFate4outof456))
	qqnorm(unlist(ranef(modPairsOkFate4outof456)))
	qqline(unlist(ranef(modPairsOkFate4outof456)))
	
	# residuals vs fitted									# !! quite awful !!	
	scatter.smooth(fitted(modPairsOkFate4outof456), resid(modPairsOkFate4outof456))	
	abline(h=0, lty=2)
	
	# residuals vs predictors
	scatter.smooth(Eggs$FassPbdurlong[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 3], resid(modPairsOkFate4outof456))
	abline(h=0, lty=2)
	scatter.smooth(Eggs$TempHatch[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 3], resid(modPairsOkFate4outof456))
	abline(h=0, lty=2)
	
	# data vs. fitted ?
	dat4 <- Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 3,]
	dat4$fitted <- fitted(modPairsOkFate4outof456)
	scatter.smooth(dat4$fitted, jitter(dat4$Fate4, 0.05),ylim=c(0, 1))
	abline(0,1)	

	# data and fitted against all predictors
	boxplot(fitted~MTrt, dat4, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate4 probability", xlab="MTrt")
	boxplot(fitted~Season, dat4, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate4 probability", xlab="Season")
	scatter.smooth(dat4$FassPbdurlong,dat4$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate4 probability", xlab="FassPbdurlong")
	scatter.smooth(dat4$TempHatch,dat4$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate4 probability", xlab="TempHatch")

	}

	{# percentage of 4 out of 456	> fit the model estimates ?
	percentFate4outof456forC <- 100 * sum(Eggs$Fate4[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]) / (sum(Eggs$Fate456[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]))	# 18.4% 	C

	percentFate4outof456forNC <- 100 * sum(Eggs$Fate4[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]) / (sum(Eggs$Fate456[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]))	# 28.6% 	NC
	}
}



{# EggFate d8 or FL out of 3456
# MIDFIDSoc has to belong to MIDFIDOk: EPY and dumped eggs included in the subset

modPairsOkFated8doutof3456 <- glmer(Fated8YN ~ MTrt+scale(Season, scale=FALSE)+ poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFated8doutof3456)	# p = 0.10526

modPairsOkFLoutof3456 <- glmer(FLYN ~ MTrt+scale(Season, scale=FALSE)+ poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFLoutof3456)	# p = 0.0374 *

invlogit()#
invlogit()#

	{# percentage of d8 out of 3456	> fit the model estimates ?
length(Eggs$Mass8dChick[!(is.na(Eggs$Mass8dChick))])	#513
}
}



{# EggFate 2 out of 23456		ns											!! assumptions violated !!
# eggs without MGen are not included, MIDFIDGen has to belong to MIDFIDOk: EPY removed from the subset

modPairsOkFate2outof23456 <- glmer(Fate2 ~ MGenTrt + poly(Day,2)*scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456)	# p = 0.69

invlogit(-1.40468)	# 20% C
invlogit( -1.27239)	# 22% NC





modPairsOkFate2outof23456 <- glmer(Fate2 ~ MGenTrt +scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456)	# p = 0.6756 	(p =  0.93660  if mongamous only)

invlogit(-1.39574)# 0.198493
(invlogit(-1.39574+0.22832)-invlogit(-1.39574)+invlogit(-1.39574)-invlogit(-1.39574-0.22832))/2	# 0.03633797
invlogit(-1.25521)# 0.2217996
(invlogit(-1.25521+0.25967)-invlogit(-1.25521)+invlogit(-1.25521)-invlogit(-1.25521-0.25967))/2	# 0.04480126


# dataset T1-5
Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,c('EggID','ClutchAss','MIDFIDGen','MGen','FGen','Fate2','MGenTrt','Season','EggNoClutchAss','FassPbdurlong')]



modPairsOkFate2outof23456withoutDumpedEggs <- glmer(Fate2 ~ MGenTrt + scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1 & Eggs$DumpedEgg == 0,], family = "binomial")
summary(modPairsOkFate2outof23456withoutDumpedEggs)	# p = 0.4351

invlogit(-1.57129)# 0.1720326
(invlogit(-1.57129+0.24770)-invlogit(-1.57129)+invlogit(-1.57129)-invlogit(-1.57129-0.24770))/2	# 0.03533326
invlogit(-1.29159)# 0.2155838
(invlogit(-1.29159+0.27464)-invlogit(-1.29159)+invlogit(-1.29159)-invlogit(-1.29159-0.27464))/2	# 0.04643371







modPairsOkFate2outof23456 <- glmer(Fate2 ~ MGenTrt+ FGenStarvedYN + scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456)	# p = 




modPairsOkFate2outof23456Soc <- glmer(Fate2 ~ -1+MTrt + poly(Day,2)*scale(Season, scale=FALSE) + scale(EggNoClutch, scale=FALSE) +(1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID), data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456Soc)

invlogit(-1.54037)	# 18% C
invlogit( -1.17803)	# 24% NC

modPairsOkFate2outof23456 <- glmmPQL(Fate2 ~ MGenTrt + poly(Day,2)*scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) , random = ~ 1|FGen, data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456)

modPairsOkFate2outof23456 <- glmmPQL(Fate2 ~ MGenTrt + poly(Day,2)*scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) , random = ~ 1|FGen/ClutchAss, data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456)

# not working
modPairsOkFate2outof23456 <- glmmPQL(Fate2 ~ MGenTrt + poly(Day,2)*scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) , data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], random = pdBlocked(list(pdSymm(~ FGen-1), pdSymm(~ MGen-1))), family='binomial')
summary(modPairsOkFate2outof23456)

		
	{# model assumptions checking
	
	mean(unlist(ranef(modPairsOkFate2outof23456)$ClutchAss))
	mean(unlist(ranef(modPairsOkFate2outof23456)$MIDFIDGen))
	mean(unlist(ranef(modPairsOkFate2outof23456)$MGen))
	mean(unlist(ranef(modPairsOkFate2outof23456)$FGen))
	
	
	# qqplots residuals and ranef				# ! AWFUL !
	qqnorm(resid(modPairsOkFate2outof23456 ))
	qqline(resid(modPairsOkFate2outof23456 ))
	

	
		#? qqnorm(unlist(ranef(modPairsOkFate2outof23456)))
		#? qqline(unlist(ranef(modPairsOkFate2outof23456)))	
	qqnorm(unlist(ranef(modPairsOkFate2outof23456)$ClutchAss))
	qqline(unlist(ranef(modPairsOkFate2outof23456)$ClutchAss))
	qqnorm(unlist(ranef(modPairsOkFate2outof23456)$MIDFIDGen))
	qqline(unlist(ranef(modPairsOkFate2outof23456)$MIDFIDGen))
	qqnorm(unlist(ranef(modPairsOkFate2outof23456)$MGen))
	qqline(unlist(ranef(modPairsOkFate2outof23456)$MGen))
	qqnorm(unlist(ranef(modPairsOkFate2outof23456)$FGen))
	qqline(unlist(ranef(modPairsOkFate2outof23456)$FGen))
	
	# residuals vs fitted	
	scatter.smooth(fitted(modPairsOkFate2outof23456 ), resid(modPairsOkFate2outof23456 ))
	abline(h=0, lty=2)
	
	# residuals vs predictors
	scatter.smooth(Eggs$FassPbdurlong[Eggs$MIDFIDass%in%MIDFIDOk & (is.na(Eggs$EPY) | Eggs$EPY == "0" ) & Eggs$EggFate > 1 & !(is.na(Eggs$FGen))], resid(modPairsOkFate2outof23456 ), ylab="Resid modfate2", xlab="FassPbdurlong")
	abline(h=0, lty=2)
	scatter.smooth(Eggs$Day[Eggs$MIDFIDGen%in%MIDFIDOk & Eggs$EggFate > 1], resid(modPairsOkFate2outof23456 ), ylab="Resid modfate2", xlab="FassPbdurlong")
	abline(h=0, lty=2)
	
	
	# data vs. fitted ?
	dat2 <- Eggs[Eggs$MIDFIDass%in%MIDFIDOk & (is.na(Eggs$EPY) | Eggs$EPY == "0" ) & Eggs$EggFate > 1 & !(is.na(Eggs$FGen)),]
	dat2$fitted <- fitted(modPairsOkFate2outof23456)
	scatter.smooth(dat2$fitted, jitter(dat2$Fate2/(dat2$Fate2+dat2$Fate3456), 0.05),ylim=c(0, 1))
	abline(0,1)	
	
	# data and fitted against all predictors
	boxplot(fitted~MGenTrt, dat2, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate2 probability", xlab="MGenTrt")
	boxplot(fitted~Season, dat2, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate2 probability", xlab="Season")
	scatter.smooth(dat2$FassPbdurlong,dat2$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate2 probability", xlab="FassPbdurlong")
	}

	{# percentage of 2 out of 23456	> fit the model estimates ?
sum(Eggs$Fate2[Eggs$MIDFIDGen%in%MIDFIDOk])	#167
	
percentFate2outof23456forC <- sum(Eggs$Fate2[Eggs$MIDFIDGen%in%MIDFIDOk & Eggs$MGenTrt == "C"]) / (sum(Eggs$Fate23456[Eggs$MIDFIDGen%in%MIDFIDOk & Eggs$MGenTrt == "C"]))	# 23.5% 	C N=425

percentFate2outof23456forNC <- sum(Eggs$Fate2[Eggs$MIDFIDGen%in%MIDFIDOk & Eggs$MGenTrt == "NC"]) / (sum(Eggs$Fate23456[Eggs$MIDFIDGen%in%MIDFIDOk & Eggs$MGenTrt == "NC"]))	# 23.7% 	NC N=282

sum(Eggs$Fate2[Eggs$MIDFIDSoc%in%MIDFIDOk])	#194
	
percentFate2outof23456forCSoc <- sum(Eggs$Fate2[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]) / (sum(Eggs$Fate23456[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"]))	# 24% 	C

percentFate2outof23456forNCSoc <- sum(Eggs$Fate2[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]) / (sum(Eggs$Fate23456[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"]))	# 26% 	C
}

	{# Pbdurlong effect

modPairsOkFate2outof23456Pbdurlong <- glmer(Fate2 ~ FassPbdurlong+MGenTrt + scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456Pbdurlong)
}
}


{# EggFate 2 out of 23456		explain by EP/WP status ?
# eggs without MGen are not included, MIDFIDGen has to belong to MIDFIDOk: EPY removed from the subset

summary(Eggs$EPY)

Eggs$EPYF <-as.factor(Eggs$EPY)

modPairsOkFate2outof23456withEPY <- glmer(Fate2 ~ EPYF + scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDSoc)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkFate2outof23456withEPY)	# p = 0.8374

invlogit(-1.445201)# WP 0.1907412
(invlogit(-1.445201+0.183492)-invlogit(-1.445201)+invlogit(-1.445201)-invlogit(-1.445201-0.183492))/2	# 0.02833518
invlogit(-1.375273)# EP 0.2017692
(invlogit(-1.375273+0.359215)-invlogit(-1.375273)+invlogit(-1.375273)-invlogit(-1.375273-0.359215))/2	# 0.05789078




	{# percentage of 2 out of 23456	> fit the model estimates ?
sum(Eggs$Fate2[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$EPY)) & Eggs$EPY == 1])	#19
sum(Eggs$Fate2[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$EPY)) & Eggs$EPY == 0])	#168
	
percentFate2outof23456EP <- sum(Eggs$Fate2[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$EPY)) & Eggs$EPY == 1]) / (sum(Eggs$Fate23456[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$EPY))& Eggs$EPY == 1]))	# 0.296875

percentFate2outof23456WP <- sum(Eggs$Fate2[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$EPY)) & Eggs$EPY == 0]) / (sum(Eggs$Fate23456[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$EPY)) & Eggs$EPY == 0]))	# 0.2352941
}



}


{# EggFate 1 out of 0123456	

modPairsOkFate1 <- glmer(Fate1 ~ MTrt+poly(Day,2)*scale(Season,scale=FALSE) + scale(EggNoClutch,scale=FALSE)+(1|ClutchID)+(1|MIDFIDSoc)+(1|MID)+ (1|FID), data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkFate1)	# p = 0.12	
	
invlogit(-1.94315)	#13%	C
invlogit(-1.50728)	#18%	NC



modPairsOkFate1 <- glmer(Fate1 ~ -1+MTrt+scale(Season,scale=FALSE) + scale(EggNoClutch,scale=FALSE)+(1|ClutchID)+(1|MIDFIDSoc)+(1|MID)+ (1|FID), data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkFate1)	# p =  0.06747 . 	(p = 0.06480 .  if mongamous only)

invlogit(-2.03135)#0.1159505
(invlogit(-2.03135+0.21968)-invlogit(-2.03135)+invlogit(-2.03135)-invlogit(-2.03135-0.21968))/2	# 0.02258788
invlogit(-1.45723)# 0.1888914
invlogit(0.22582)# 0.5562163
(invlogit(-1.45723+0.22582)-invlogit(-1.45723)+invlogit(-1.45723)-invlogit(-1.45723-0.22582))/2	# 0.03462136


# dataset T1-4
Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,c('EggID','ClutchID','MIDFIDSoc','MID','FID','Fate1','MTrt','Season','EggNoClutch','FassPbdurlong')]


modPairsOkFate1Ass <- glmer(Fate1 ~ MassTrt+poly(Day,2)*scale(Season,scale=FALSE) + scale(EggNoClutchAss,scale=FALSE)+(1|ClutchAss)+(1|MIDFIDass)+(1|Mass)+ (1|Fass), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkFate1Ass)	# p = 0.17	

invlogit(-1.73114)	#15%	C
invlogit(-1.32861)	#21%	NC

modPairsOkFate1 <- glmmPQL(Fate1 ~ MTrt+poly(Day,2)*scale(Season,scale=FALSE) + scale(EggNoClutch,scale=FALSE), random= ~1|MIDFIDSoc/ClutchID, data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkFate1)	# p = 0.2253

modPairsOkFate1 <- glmmPQL(Fate1 ~ MTrt+scale(Season,scale=FALSE) + scale(EggNoClutch,scale=FALSE), random= ~1|MIDFIDSoc/ClutchID, data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkFate1)	# p = 0.1023
	
	{# model assumptions checking
	
	mean(unlist(ranef(modPairsOkFate1)$ClutchID))
	mean(unlist(ranef(modPairsOkFate1)$MIDFIDSoc))
	mean(unlist(ranef(modPairsOkFate1)$MID))
	mean(unlist(ranef(modPairsOkFate1)$FID))
	
	
	# qqplots residuals and ranef	
	qqnorm(resid(modPairsOkFate1))
	qqline(resid(modPairsOkFate1))
	qqnorm(unlist(ranef(modPairsOkFate1)$ClutchID))
	qqline(unlist(ranef(modPairsOkFate1)$ClutchID))
	qqnorm(unlist(ranef(modPairsOkFate1)$MIDFIDSoc))
	qqline(unlist(ranef(modPairsOkFate1)$MIDFIDSoc))
	qqnorm(unlist(ranef(modPairsOkFate1)$MID))
	qqline(unlist(ranef(modPairsOkFate1)$MID))	
	qqnorm(unlist(ranef(modPairsOkFate1)$FID))
	qqline(unlist(ranef(modPairsOkFate1)$FID))	
	
	# residuals vs fitted
	scatter.smooth(fitted(modPairsOkFate1), resid(modPairsOkFate1))
	abline(h=0, lty=2)
	
	# residuals vs predictors	
	scatter.smooth(Eggs$FassPbdurlong[Eggs$MIDFIDass%in%MIDFIDOk], resid(modPairsOkFate1))
	abline(h=0, lty=2)
	
	# data vs. fitted ?
	dat1 <- Eggs[Eggs$MIDFIDass%in%MIDFIDOk,]
	dat1$fitted <- fitted(modPairsOkFate1)
	scatter.smooth(dat1$fitted, jitter(dat1$Fate1/(dat1$Fate1+dat1$Fate23456), 0.05),ylim=c(0, 1))
	abline(0,1)	
	
	# data and fitted against all predictors
	boxplot(fitted~MassTrt, dat1, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate1 probability", xlab="MassTrt")
	boxplot(fitted~Season, dat1, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate1 probability", xlab="Season")
	scatter.smooth(dat1$FassPbdurlong,dat1$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate1 probability", xlab="FassPbdurlong")
	scatter.smooth(dat1$TempInc,dat1$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate1 probability", xlab="TempInc")

	}

	{# percentage of 1 out of 0123456 > fit the model estimates ?

sum(Eggs$Fate1[Eggs$MIDFIDSoc%in%MIDFIDOk])	#320

percentFate1forC <- sum(Eggs$Fate1[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"] ) / length(Eggs$Fate1[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "C"] )	# 21% 	C

percentFate1forNC <- sum(Eggs$Fate1[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"] ) / length(Eggs$Fate1[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == "NC"] )	# 34% 	NC

sum(Eggs$Fate1[Eggs$MIDFIDass%in%MIDFIDOk])	#295

nrow(Eggs[Eggs$EggFate == 1 & Eggs$MIDFIDass%in%MIDFIDOk & is.na(Eggs$FID),])#33
nrow(Eggs[Eggs$EggFate == 1 &Eggs$EPY == 1 & !(Eggs$MIDFIDass%in%MIDFIDOk) & is.na(Eggs$FID),])#25

percentFate1forCass <- sum(Eggs$Fate1[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "C"] ) / length(Eggs$Fate1[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "C"] )	# 23% 	C

percentFate1forNCass <- sum(Eggs$Fate1[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "NC"] ) / length(Eggs$Fate1[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "NC"] )	# 32% 	NC
}	
	
	{# Pbdurlong effect
	
modPairsOkFate1Pbdurlong <- glmer(Fate1 ~ FassPbdurlong+ MTrt+scale(Season,scale=FALSE) + scale(EggNoClutch,scale=FALSE)+(1|ClutchID)+(1|MIDFIDSoc)+(1|MID)+ (1|FID), data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk,], family = "binomial")
summary(modPairsOkFate1Pbdurlong)
}

}

{# EggFate 0 out of 023456		?											!! assumptions violated !!
# MIDFIDass has to belong to MIDFIDOk: EPY removed from the subset

modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt+poly(Day,2)*scale(Season, scale=FALSE)+scale(EggNoClutchAss, scale=FALSE) + (1|ClutchAss)+(1|MIDFIDass)+(1|Mass)+(1|Fass), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.215 

modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt+scale(Season, scale=FALSE)+scale(EggNoClutchAss, scale=FALSE) + (1|ClutchAss)+(1|MIDFIDass)+(1|Mass)+(1|Fass), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.3339 

invlogit(-7.9233)# 0.0003620739 C
invlogit(-6.2460)# 0.001934442 NC


modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt+scale(Season, scale=FALSE)+scale(EggNoClutchAss, scale=FALSE) + (1|ClutchAss)+(1|MIDFIDass), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =   0.3339 

modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt+poly(Day,2)*scale(Season, scale=FALSE)+scale(EggNoClutchAss, scale=FALSE) + (1|ClutchAss)+(1|MIDFIDass), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.330


modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt + scale(EggNoClutchAss, scale=FALSE) + (1|ClutchAss)+(1|MIDFIDass), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.342 

modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt + scale(EggNoClutchAss, scale=FALSE) + (1|MIDFIDass), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =   0.00494 **

modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt + scale(EggNoClutchAss, scale=FALSE) + (1|ClutchAss), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.3216 

head(Eggs[Eggs$EggFate == 0,],20)
tail(Eggs[Eggs$EggFate == 0 & Eggs$MIDFIDass%in%MIDFIDOk,],30)


modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt + (1|ClutchAss), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =   0.303




for (i in 1:nrow(Eggs)){
if (Eggs$ClutchNo[i] == 1 & Eggs$Season[i] == 2012){Eggs$firstclutchYN[i] <- 1} else {Eggs$firstclutchYN[i] <- 0}}

modPairsOkFate0outof023456 <- glmer(Fate0 ~ MassTrt+scale(Season, scale=FALSE)+ scale(EggNoClutchAss, scale=FALSE)  + firstclutchYN+(1|ClutchAss)+(1|MIDFIDass), data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.2879  



modPairsOkFate0outof023456 <- glmmPQL(Fate0 ~ MassTrt+poly(Day,2)*scale(Season, scale=FALSE)+scale(EggNoClutchAss, scale=FALSE), random=~1|MIDFIDass/ClutchAss, data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.0041 *

modPairsOkFate0outof023456 <- glmmPQL(Fate0 ~ MassTrt+scale(Season, scale=FALSE)+scale(EggNoClutchAss, scale=FALSE), random=~1|MIDFIDass/ClutchAss, data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.0040 *

invlogit(-4.831609) # 0.8% C
invlogit(-3.153254)	# 4.1% NC

modPairsOkFate0outof023456 <- glmmPQL(Fate0 ~ MassTrt+scale(Season, scale=FALSE), random=~1|MIDFIDass/ClutchAss, data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =  0.0041 *

modPairsOkFate0outof023456 <- glmmPQL(Fate0 ~ MassTrt+scale(Season, scale=FALSE), random=~1|ClutchAss, data = Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,] , family = "binomial")
summary(modPairsOkFate0outof023456)	# p =   0.0001 **


	{# model assumptions checking
	
	mean(unlist(ranef(modPairsOkFate0outof023456)$ClutchAss))
	mean(unlist(ranef(modPairsOkFate0outof023456)$MIDFIDass))	
	
	# qqplots residuals and ranef				# ! AWFUL !
	qqnorm(resid(modPairsOkFate0outof023456))
	qqline(resid(modPairsOkFate0outof023456))
	qqnorm(unlist(ranef(modPairsOkFate0outof023456)))
	qqline(unlist(ranef(modPairsOkFate0outof023456)))
	qqnorm(unlist(ranef(modPairsOkFate0outof023456)$ClutchAss))
	qqline(unlist(ranef(modPairsOkFate0outof023456)$ClutchAss))
	
	# residuals vs fitted						# !! AWFUL !!!
	scatter.smooth(fitted(modPairsOkFate0outof023456), resid(modPairsOkFate0outof023456))
	abline(h=0, lty=2)
	
	# residuals vs predictors		
	scatter.smooth(Eggs$FassPbdurlong[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1], resid(modPairsOkFate0outof023456))
	abline(h=0, lty=2)
	
	# data vs. fitted ?							# !! AWFUL !!!	
	dat0 <- Eggs[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1,]
	dat0$fitted <- fitted(modPairsOkFate0outof023456)
	scatter.smooth(dat0$fitted, jitter(dat0$Fate1/(dat0$Fate0+dat0$Fate23456), 0.05),ylim=c(0, 1))
	abline(0,1)	
	
	# data and fitted against all predictors
	boxplot(fitted~MassTrt, dat0, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate0 probability", xlab="MassTrt")
	boxplot(fitted~Season, dat0, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate0 probability", xlab="Season")
	scatter.smooth(dat0$FassPbdurlong,dat0$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="Fate0 probability", xlab="FassPbdurlong")
	}

	{# percentage of 0 out of 023456 > fit the model estimates ?

sum(Eggs$Fate0[Eggs$MIDFIDass%in%MIDFIDOk])	#63

percentFate0forC <- sum(Eggs$Fate0[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "C"] ) / length(Eggs$Fate0[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1  & Eggs$MassTrt == "C"] )	# 2.9% 	C

percentFate0forNC <- sum(Eggs$Fate0[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$MassTrt == "NC"] ) / length(Eggs$Fate0[Eggs$MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1  & Eggs$MassTrt == "NC"] )	# 14.8% 	NC


}
}



{# Female EPY out of Female EPY+WPY	

	#modEPYMalesOk <- glmer(EPY ~ MGenTrt + (1|MGen)  , data = Eggs[Eggs$MGenYear%in%MIDYearOk,], family = "binomial")
	#summary(modEPYMalesOk )

modEPYFemalesOk <- glmer(EPY ~ FGenTrt +scale(Season, scale=FALSE) +FassPbdurlong+ + scale(EggNoClutchAss, scale=FALSE)+(1|FGen) +(1|ClutchAss), data = Eggs[Eggs$FGenYear%in%FIDYearOk,], family = "binomial")
summary(modEPYFemalesOk )	# p = 0.869

invlogit(-8.941880)	#0.0001307778	C
invlogit(-8.264977) #0.0002573086	NC

modEPYFemalesOkwithPoly <- glmer(EPY ~ -1+FGenTrt +poly(Day,2)*scale(Season, scale=FALSE)+ scale(EggNoClutchAss, scale=FALSE) + (1|FGen) +(1|ClutchAss), data = Eggs[Eggs$FGenYear%in%FIDYearOk,], family = "binomial")
summary(modEPYFemalesOkwithPoly)

invlogit(-10.3066)	# 3.341073e-05	C
invlogit(-9.2377)	# 9.729166e-05	NC

	{# model assumptions checking
	
	# qqplots residuals and ranef			# !! AWFUL !!
	qqnorm(resid(modEPYFemalesOk))
	qqline(resid(modEPYFemalesOk))
	qqnorm(unlist(ranef(modEPYFemalesOk)))	
	qqline(unlist(ranef(modEPYFemalesOk)))
	
	# residuals vs fitted					# !! AWFUL !!
	scatter.smooth(fitted(modEPYFemalesOk), resid(modEPYFemalesOk))
	abline(h=0, lty=2)
	
	# residuals vs predictors		
	scatter.smooth(Eggs$FassPbdurlong[Eggs$FGenYear%in%FIDYearOk], resid(modEPYFemalesOk))
	abline(h=0, lty=2)
	
	# data vs. fitted ?							# !! AWFUL !!!	
	datEPY <- Eggs[Eggs$FGenYear%in%FIDYearOk,]
	datEPY$fitted <- fitted(modEPYFemalesOk)
	scatter.smooth(datEPY$fitted, jitter(datEPY$EPY/1, 0.05),ylim=c(0, 1))
	abline(0,1)	
	
	# data and fitted against all predictors
	boxplot(fitted~FGenTrt, datEPY, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability", xlab="FGenTrt")
		#boxplot(fitted~Season, datEPY, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability", xlab="Season")
	scatter.smooth(datEPY$FassPbdurlong,datEPY$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability", xlab="FassPbdurlong")	
	
	}

	{# percentage of EPY out of all Genotyped Eggs > fit the model estimates ?

sum(Eggs$EPY[Eggs$FGenYear%in%FIDYearOk])	#78

percentEPYforFemaleTrtOk <- sum(Eggs$EPY[Eggs$FGenYear%in%FIDYearOk]) / length(Eggs$EggID[Eggs$FGenYear%in%FIDYearOk] )	# 0.08955224

percentEPYforC <- sum(Eggs$EPY[Eggs$FGenYear%in%FIDYearOk & Eggs$FGenTrt == "C"] ) / length(Eggs$EggID[Eggs$FGenYear%in%FIDYearOk & Eggs$FGenTrt == "C" ] )	# 7.0% 	C

percentEPYforNC <- sum(Eggs$EPY[Eggs$FGenYear%in%FIDYearOk & Eggs$FGenTrt == "NC"]) / length(Eggs$EggID[Eggs$FGenYear%in%FIDYearOk & Eggs$FGenTrt == "NC" ] )	# 11.6% 	NC
}
}


{# Mass of chicks at day 8

Massd8data <- Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$HatchOrderSurv)),]

modPairsOkMassDay8 <- lmer(Mass8dChick ~ MTrt+scale(Season, scale=FALSE)+ poly(HatchOrderSurv,2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Massd8data)
summary(modPairsOkMassDay8)

#MTrtC  6.1365
#MTrtNC  6.0026

modPairsOkMassDay8withoutTrt <- lmer(Mass8dChick ~ scale(Season, scale=FALSE)+ poly(HatchOrderSurv,2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Massd8data)
summary(modPairsOkMassDay8withoutTrt)

anova(modPairsOkMassDay8,modPairsOkMassDay8withoutTrt)	# p = 0.5078 (id if only monogamous pairs because 1119011187 didn't get any chick day 8)

# dataset T1 - 7
Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$HatchOrderSurv)),c('EggID','ClutchID','MIDFIDSoc','MID','FID','Mass8dChick','Season','HatchOrderSurv','FassPbdurlong')]




modPairsOkMassDay8 <- lmer(Mass8dChick ~ MTrt+ poly(HatchOrderSurv,2)+scale(Season, scale=FALSE)+ scale(BroodSize,scale=FALSE)  + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Massd8data)
summary(modPairsOkMassDay8)	# t value -0.82



	{# Model assumpion checking
	qqnorm(resid(modPairsOkMassDay8)) 
	qqline(resid(modPairsOkMassDay8))
	qqnorm(unlist(ranef(modPairsOkMassDay8)$MIDFIDSoc))
	qqline(unlist(ranef(modPairsOkMassDay8)$MIDFIDSoc))	
	qqnorm(unlist(ranef(modPairsOkMassDay8)$ClutchID))
	qqline(unlist(ranef(modPairsOkMassDay8)$ClutchID))		
	qqnorm(unlist(ranef(modPairsOkMassDay8)$FID))
	qqline(unlist(ranef(modPairsOkMassDay8)$FID))
	qqnorm(unlist(ranef(modPairsOkMassDay8)$MID))
	qqline(unlist(ranef(modPairsOkMassDay8)$MID))
	plot(fitted(modPairsOkMassDay8), resid(modPairsOkMassDay8))
	abline(h=0)
	scatter.smooth(Eggs$HatchOrderSurv[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$Mass8dChick))],resid(modPairsOkMassDay8))
	boxplot(resid(modPairsOkMassDay8)~Eggs$Season[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$Mass8dChick))])	
	boxplot(resid(modPairsOkMassDay8)~Eggs$MTrt[Eggs$MIDFIDSoc%in%MIDFIDOk & !(is.na(Eggs$Mass8dChick))])	
}

	{# mean Massday8 > fit model estimates ?
mean(Eggs$Mass8dChick[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'C'], na.rm=TRUE)	# 6.073643 C
mean(Eggs$Mass8dChick[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$MTrt == 'NC'], na.rm=TRUE)	#6.143558 NC
}

{	# pbdurlong effect

modPairsOkMassDay8Pbdurlong <- lmer(Mass8dChick ~ FassPbdurlong+MTrt+scale(Season, scale=FALSE)+ poly(HatchOrderSurv,2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Massd8data)
summary(modPairsOkMassDay8Pbdurlong)

modPairsOkMassDay8withoutPbdurlong <- lmer(Mass8dChick ~ MTrt+scale(Season, scale=FALSE)+ poly(HatchOrderSurv,2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Massd8data)
summary(modPairsOkMassDay8withoutPbdurlong)

anova(modPairsOkMassDay8Pbdurlong,modPairsOkMassDay8withoutPbdurlong)
}

}

{# brood size
head(TableClutchSocFated8)


# TableClutchSocFated8[TableClutchSocFated8$FID == 11187 ,] = 3 clutches
# TableClutchSocFated8 <- TableClutchSocFated8[TableClutchSocFated8$ClutchID != 369 & TableClutchSocFated8$ClutchID != 537 & TableClutchSocFated8$ClutchID != 580,]

modPairsOkBroodSize <- lmer(BroodSize ~ -1+MTrt+scale(Season, scale=FALSE)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID)  , data = TableClutchSocFated8)
summary(modPairsOkBroodSize)

#MTrtC   2.58512
#MTrtNC  2.03406

modPairsOkBroodSizewithoutTrt <- lmer(BroodSize ~ scale(Season, scale=FALSE)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID)  , data = TableClutchSocFated8)
summary(modPairsOkBroodSizewithoutTrt)

anova(modPairsOkBroodSize,modPairsOkBroodSizewithoutTrt)	# p  0.06849 .	(p = 0.1333 if secondary female 11187 excluded)

mean(TableClutchSocFated8$BroodSize[TableClutchSocFated8$MTrt == 'C'])	# 2.544554 C
mean(TableClutchSocFated8$BroodSize[TableClutchSocFated8$MTrt == 'NC'])	# 2.0375 NC

{	# pbdurlong effect

modPairsOkBroodSizePbdur <- lmer(BroodSize ~ Pbdur+MTrt+scale(Season, scale=FALSE)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID)  , data = TableClutchSocFated8)
summary(modPairsOkBroodSizePbdur)

modPairsOkBroodSizewithoutPbdur <- lmer(BroodSize ~ scale(Season, scale=FALSE)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID)  , data = TableClutchSocFated8)
summary(modPairsOkBroodSizewithoutPbdur)

anova(modPairsOkBroodSizePbdur,modPairsOkBroodSizewithoutPbdur)		
}


}

{# FL size
head(TableClutchSocFL)

modPairsOkFLSize <- lmer(FLSize ~ MTrt+scale(Season, scale=FALSE)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID)  , data = TableClutchSocFL)
summary(modPairsOkFLSize)

#MTrtC   2.58493
#MTrtNC  2.04574

modPairsOkFLSizewithoutTrt <- lmer(FLSize ~ scale(Season, scale=FALSE)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID)  , data = TableClutchSocFL)
summary(modPairsOkFLSizewithoutTrt)

anova(modPairsOkFLSize,modPairsOkFLSizewithoutTrt)	# p  0.0514 .

mean(TableClutchSocFL$FLSize[TableClutchSocFL$MTrt == 'C'])		# 2.485149 C
mean(TableClutchSocFL$FLSize[TableClutchSocFL$MTrt == 'NC'])	# 1.9375 NC

}


{# egg volume
# genotyped eggs, when female kept the trt

modPairsOkEggVolume <- lmer(EggVolume ~ FGenTrt + scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$FGenYear%in%FIDYearOk,])
summary(modPairsOkEggVolume)	

}
}


{### GRAPH FATE2 and FATE34 DIFFERENCE for paper


modPairsOkFate2outof23456 <- glmer(Fate2 ~ -1+MGenTrt + scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456)	# p = 0.6756

estimatesGenetCompat <- coef(summary(modPairsOkFate2outof23456))

modPairsOkFate34outof3456 <- glmer(Fate34 ~ -1+MTrt+scale(Season, scale=FALSE)+ poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# p = 0.02917 * 
estimatesBehavCompat <- coef(summary(modPairsOkFate34outof3456))


par(mfrow=c(1,2))

{# 1t panel

par(mar=c(4,3.6,1,0.5))
plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(10,60), 
	yaxt = "n",		
	ylab = "", xlab = "")

mtext("A", side =3, line=-0.5, at=-0.8,cex = 1.5,font=2)
axis(2,at = c(10,20,30,40,50,60),tick = TRUE,cex.axis=1 , las=1, padj = 0.3, hadj=0.7)
mtext("Embryo mortality (% of eggs)",side =2, line=2,cex = 1.5,font=2)


axis(1,at = 0.65, labels="")	
axis(1,at = 0.65,tick = FALSE,line = 1.5, labels = "Chosen
pairs", cex.axis=1.5, font.axis = 2)
axis(1,at = 2.35, labels="")	
axis(1,at = 2.35,tick = FALSE,line = 1.5, labels = "Non-chosen
pairs", cex.axis=1.5, font.axis = 2)

arrows(0.65,100*invlogit(estimatesGenetCompat[1,1]+estimatesGenetCompat[1,2]), 0.65,100*invlogit(estimatesGenetCompat[1,1]-estimatesGenetCompat[1,2]),angle=90, code=3, length=0.05, col = "black", lwd=3)
arrows(2.35,100*invlogit(estimatesGenetCompat[2,1]+estimatesGenetCompat[2,2]), 2.35,100*invlogit(estimatesGenetCompat[2,1]-estimatesGenetCompat[2,2]),angle=90, code=3, length=0.05, col =  "black", lwd=3)

points(0.65, 100*invlogit(estimatesGenetCompat[1,1]), col = "black", pch=19, cex=1.5)
points(2.35, 100*invlogit(estimatesGenetCompat[2,1]), col = "black", pch=19, cex=1.5)

#text(1.5,60,"P = 0.68", cex=1.2)
text(0.65,10,"    = 425", cex=1.2)
text(2.25,10,"      = 282", cex=1.2)
text(0.34,9.85,"n",font=4, cex=1.2)
text(2,9.85,"n",font=4, cex=1.2)
}

{# 2nd panel

par(mar=c(3.8,3.6,1,0.7))
plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(10,60), 
	yaxt = "n",
	ylab = "",	
	xlab = "")

mtext("B", side =3, line=-0.5, at=-0.8,cex = 1.5,font=2)
axis(2,at = c(10,20,30,40,50,60),tick = TRUE,cex.axis=1 , las=1, padj = 0.3, hadj=0.7)
mtext("Offsrping mortality (% of hatchlings)",side =2, line=2,cex = 1.5,font=2)

axis(1,at = 0.65, labels="")	
axis(1,at = 0.65,tick = FALSE,line = 1.5, labels = "Chosen
pairs", cex.axis=1.5, font.axis = 2)
axis(1,at = 2.35, labels="")	
axis(1,at = 2.35,tick = FALSE,line = 1.5, labels = "Non-chosen
pairs", cex.axis=1.5, font.axis = 2)

arrows(0.65,100*invlogit(estimatesBehavCompat[1,1]+estimatesBehavCompat[1,2]), 0.65,100*invlogit(estimatesBehavCompat[1,1]-estimatesBehavCompat[1,2]),angle=90, code=3, length=0.05, col = "black", lwd=3)
arrows(2.35,100*invlogit(estimatesBehavCompat[2,1]+estimatesBehavCompat[2,2]), 2.35,100*invlogit(estimatesBehavCompat[2,1]-estimatesBehavCompat[2,2]),angle=90, code=3, length=0.05, col =  "black", lwd=3)

points(0.65, 100*invlogit(estimatesBehavCompat[1,1]), col = "black", pch=19, cex=1.5)
points(2.35, 100*invlogit(estimatesBehavCompat[2,1]), col = "black", pch=19, cex=1.5)

#text(1.5,60,"P = 0.03", cex=1.2)
text(0.65,10,"    = 349", cex=1.2)
text(2.25,10,"      = 245", cex=1.2)
text(0.34,9.85,"n",font=4, cex=1.2)
text(2,9.85,"n",font=4, cex=1.2)
}

# pdf(file='combinedgraph.pdf', width = 3.4, height = 3.4)
# dev.off()

}

{### GRAPH FATE2 and FATE34 DIFFERENCE for poster version yellow


modPairsOkFate2outof23456 <- glmer(Fate2 ~ -1+MGenTrt + scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$MIDFIDGen%in%MIDFIDOk  & Eggs$EggFate > 1,], family = "binomial")
summary(modPairsOkFate2outof23456)	# p = 0.6756

estimatesGenetCompat <- coef(summary(modPairsOkFate2outof23456))

modPairsOkFate34outof3456 <- glmer(Fate34 ~ -1+MTrt+scale(Season, scale=FALSE)+ poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$MIDFIDSoc%in%MIDFIDOk & Eggs$EggFate > 2,], family = "binomial")
summary(modPairsOkFate34outof3456)	# p = 0.02917 * 
estimatesBehavCompat <- coef(summary(modPairsOkFate34outof3456))

plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(10,60), 	
	ylab = "", xlab = "",cex.lab = 1.2,font.lab=4 )
axis(1, at = 0.75,cex.axis=1.2, font.axis = 2,labels="")
axis(1, at = 2.25, cex.axis=1.2, font.axis = 2, labels="")
axis(1,at = 0.75,tick = FALSE,line = 1, labels = "", cex.axis=1.2, font.axis = 2)
axis(1, at = 2.25, tick = FALSE,line = 1, labels = "", cex.axis=1.2, font.axis = 2)

arrows(0.5,100*invlogit(estimatesGenetCompat[1,1]+estimatesGenetCompat[1,2]), 0.5,100*invlogit(estimatesGenetCompat[1,1]-estimatesGenetCompat[1,2]),angle=90, code=3, length=0.05, col =  colors()[555], lwd=3)
arrows(1,100*invlogit(estimatesGenetCompat[2,1]+estimatesGenetCompat[2,2]), 1,100*invlogit(estimatesGenetCompat[2,1]-estimatesGenetCompat[2,2]),angle=90, code=3, length=0.05, col =  colors()[76], lwd=3)
arrows(2,100*invlogit(estimatesBehavCompat[1,1]+estimatesBehavCompat[1,2]), 2,100*invlogit(estimatesBehavCompat[1,1]-estimatesBehavCompat[1,2]),angle=90, code=3, length=0.05, col =  colors()[555], lwd=3)
arrows(2.5,100*invlogit(estimatesBehavCompat[2,1]+estimatesBehavCompat[2,2]), 2.5,100*invlogit(estimatesBehavCompat[2,1]-estimatesBehavCompat[2,2]),angle=90, code=3, length=0.05, col =  colors()[76], lwd=3)

points(0.5, 100*invlogit(estimatesGenetCompat[1,1]), col = "white", pch=19, cex = 1.5)
points(0.5, 100*invlogit(estimatesGenetCompat[1,1]), col = colors()[555], pch=1, cex =1.5)
points(1, 100*invlogit(estimatesGenetCompat[2,1]), col =  "white", pch=19, cex = 1.5)
points(1, 100*invlogit(estimatesGenetCompat[2,1]), col = colors()[76], pch=1, cex = 1.5)
points(2, 100*invlogit(estimatesBehavCompat[1,1]), col = "white", pch=19, cex = 1.5)
points(2, 100*invlogit(estimatesBehavCompat[1,1]), col = colors()[555], pch=1, cex = 1.5)
points(2.5, 100*invlogit(estimatesBehavCompat[2,1]), col =  "white", pch=19, cex = 1.5)
points(2.5, 100*invlogit(estimatesBehavCompat[2,1]), col = colors()[76], pch=1, cex = 1.5)

arrows(0.5,30,1,30, length=0, lwd=1)
arrows(2,22,2.5,22, length=0, lwd=1)
text(0.75,32,"p = 0.68", cex=1)
text(2.25,20,"p = 0.03", cex=1)


abline(v=1.5, lty=3)
}



	##################################################
	## 	      GLMER Models on tables Clutches       ##			
	##################################################						



{### cbind for each fate and tests for Pairs (Ass or Soc) that kept the Trt

{# Fate0 : MIDFIDass%in%MIDFIDOk & Eggs$EggFate != 1

head(TableClutchAssFate0)

modPairsOkFate0vs23456 <- glmer(cbind(IF,nonIF) ~ MassTrt+scale(Season, scale=FALSE)+(1|MIDFIDass)+(1|Mass)+(1|Fass), data = TableClutchAssFate0 , family = "binomial")
summary(modPairsOkFate0vs23456)	# p =  0.00467 ** 

invlogit(-4.2294) # 0.01435214 C
invlogit(-2.6145) # 0.06821104 NC


modPairsOkFate0vs23456over <- glmer(cbind(IF,nonIF) ~ MassTrt+scale(Season, scale=FALSE)+(1|ClutchAss)+(1|MIDFIDass)+(1|Mass)+(1|Fass), data = TableClutchAssFate0 , family = "binomial")
summary(modPairsOkFate0vs23456over)	# p =  0.394

invlogit(-7.9582) # 0.0003496599 C
invlogit(-6.3513) # 0.00174144 NC

anova(modPairsOkFate0vs23456,modPairsOkFate0vs23456over)	# overdispersion parameter:0.006018 **

mean(unlist(ranef(modPairsOkFate0vs23456over)$Fass))
mean(unlist(ranef(modPairsOkFate0vs23456over)$Mass))
mean(unlist(ranef(modPairsOkFate0vs23456over)$MIDFIDass))
mean(unlist(ranef(modPairsOkFate0vs23456over)$ClutchAss))

}

{# Fate1 : MIDFIDSoc%in%MIDFIDOk

head(TableClutchSocFate1)

modPairsOkFate1vs023456 <- glmer(cbind(Fate1,Fate023456) ~ MTrt+scale(Season, scale=FALSE)+(1|MIDFIDSoc)+(1|MID)+(1|FID), data = TableClutchSocFate1 , family = "binomial")
summary(modPairsOkFate1vs023456)	# p =  0.0471 *

invlogit(-1.4389) # 0.1917157  C
invlogit(-0.9636) # 0.276158   NC

modPairsOkFate1vs023456over <- glmer(cbind(Fate1,Fate023456) ~ -1+MTrt+scale(Season, scale=FALSE)+(1|ClutchID) +(1|MIDFIDSoc)+(1|MID)+(1|FID), data = TableClutchSocFate1 , family = "binomial")
summary(modPairsOkFate1vs023456over)	# p =  0.0921 .

invlogit(-1.9107) # 0.1289022  C
invlogit(-1.3984) # 0.1980701   NC

anova(modPairsOkFate1vs023456,modPairsOkFate1vs023456over)	# p  < 2.2e-16 ***

mean(unlist(ranef(modPairsOkFate1vs023456)$MIDFIDSoc))
mean(unlist(ranef(modPairsOkFate1vs023456)$MID))
mean(unlist(ranef(modPairsOkFate1vs023456)$FID))
}

{# Fate2 : MIDFIDGen%in%MIDFIDOk

head(TableClutchGenFate2)

modPairsOkFate2vs3456 <- glmer(cbind(Fate2,Fate3456) ~ MGenTrt+scale(Season, scale=FALSE)+(1|MIDFIDGen)+(1|MGen)+(1|FGen), data = TableClutchGenFate2 , family = "binomial")
summary(modPairsOkFate2vs3456)	# p =  0.66106 

invlogit(-1.3837) # 0.2004154 C
invlogit(-1.2364) # 0.2250632 NC

modPairsOkFate2vs3456over <- glmer(cbind(Fate2,Fate3456) ~ MGenTrt+scale(Season, scale=FALSE)+(1|ClutchGen)+(1|MIDFIDGen)+(1|MGen)+(1|FGen), data = TableClutchGenFate2 , family = "binomial")
summary(modPairsOkFate2vs3456over)	# p =  0.66321

invlogit(-1.3837) # 0.2004154 C
invlogit(-1.2364) # 0.2250632 NC

anova(modPairsOkFate2vs3456,modPairsOkFate2vs3456over)	# 0.9477

mean(unlist(ranef(modPairsOkFate2vs3456)$MIDFIDGen))
mean(unlist(ranef(modPairsOkFate2vs3456)$MGen))
mean(unlist(ranef(modPairsOkFate2vs3456)$FGen))
}

{# Fate34 : MIDFIDSoc%in%MIDFIDOk

head(TableClutchSocFate34)

modPairsOkFate34vs56 <- glmer(cbind(Fate34,Fate56) ~ MTrt+scale(Season, scale=FALSE)+(1|MIDFIDSoc)+(1|MID)+(1|FID), data = TableClutchSocFate34 , family = "binomial")
summary(modPairsOkFate34vs56)	# p =   0.036853 *

invlogit(-0.66621) 	 #  0.339346   C
invlogit(-0.07908)   # 0.4802403   NC

modPairsOkFate34vs56over <- glmer(cbind(Fate34,Fate56) ~ -1+MTrt+scale(Season, scale=FALSE)+(1|ClutchID)+(1|MIDFIDSoc)+(1|MID)+(1|FID), data = TableClutchSocFate34 , family = "binomial")
summary(modPairsOkFate34vs56over)	# p =   0.02928 *

invlogit(-0.7680750)  #  0.3168957 C
invlogit(0.0004339)   # 0.5001085   NC

anova(modPairsOkFate34vs56,modPairsOkFate34vs56over)	#  2.868e-08 ***

mean(unlist(ranef(modPairsOkFate34vs56)$FID))
mean(unlist(ranef(modPairsOkFate34vs56)$MIDFID))
mean(unlist(ranef(modPairsOkFate34vs56)$MID))
}

{# Fate56 Soc : MIDFIDSoc%in%MIDFIDOk

head(TableClutchSocFate56)

modPairsOkFate56vs01234 <- glmer(cbind(Fate56,Fate01234) ~ MTrt+scale(Season, scale=FALSE)+(1|MIDFIDSoc)+(1|MID)+(1|FID), data = TableClutchSocFate56 , family = "binomial")
summary(modPairsOkFate56vs01234)	# p =  0.02628 * 

invlogit(-0.6090) 	 #  0.3522873   C
invlogit(-1.2575)   # 0.2214046   NC

modPairsOkFate56vs01234over <- glmer(cbind(Fate56,Fate01234) ~ -1+MTrt+scale(Season, scale=FALSE)+(1|ClutchID)+(1|MIDFIDSoc)+(1|MID)+(1|FID), data = TableClutchSocFate56 , family = "binomial")
summary(modPairsOkFate56vs01234over)	# p =  0.01239 *

invlogit(-0.7289) 	# 0.3254362   C
invlogit(-1.5811)   # 0.1706398   NC

anova(modPairsOkFate56vs01234,modPairsOkFate56vs01234over)	# p = 1.151e-11 ***

mean(unlist(ranef(modPairsOkFate56vs01234)$FID))
mean(unlist(ranef(modPairsOkFate56vs01234)$MIDFID))
mean(unlist(ranef(modPairsOkFate56vs01234)$MID))
}

{# Fate56 Ass : MIDFIDass%in%MIDFIDOk

head(TableClutchAssFate56)

modPairsOkFate56vs01234Ass <- glmer(cbind(Fate56,Fate01234) ~ MassTrt+scale(Season, scale=FALSE)+(1|MIDFIDass)+(1|Mass)+(1|Fass), data = TableClutchAssFate56 , family = "binomial")
summary(modPairsOkFate56vs01234Ass)	# p =  0.062119 .

invlogit(-0.7014) 	 #  0.3315019  C
invlogit(-1.2112)   # 0.2294888   NC

modPairsOkFate56vs01234Assover <- glmer(cbind(Fate56,Fate01234) ~ -1+MassTrt+scale(Season, scale=FALSE)+(1|ClutchAss)+(1|MIDFIDass)+(1|Mass)+(1|Fass), data = TableClutchAssFate56 , family = "binomial")
summary(modPairsOkFate56vs01234Assover)	# p =  0.073 .

invlogit(-0.9382) 	# 0.2812641  C
invlogit(-1.5192)   # 0.1795794   NC

anova(modPairsOkFate56vs01234Ass,modPairsOkFate56vs01234Assover)	# p = 1.144e-13 ***

mean(unlist(ranef(modPairsOkFate56vs01234Ass)$Fass))
mean(unlist(ranef(modPairsOkFate56vs01234Ass)$MIDFIDass))
mean(unlist(ranef(modPairsOkFate56vs01234Ass)$Mass))
}

{# EPY : FGenYear%in%FIDYearOk
head(TableClutchGenEPY)

modPairsOkGenEPYvsWPY <- glmer(cbind(EPY,WPY) ~ FGenTrt+scale(Season, scale=FALSE)+(1|FGen), data = TableClutchGenEPY , family = "binomial")
summary(modPairsOkGenEPYvsWPY)	# p =  0.00994 ** 

invlogit(-4.4754) #  0.01125749 C
invlogit(-2.9193) #  0.0512077 NC

modPairsOkGenEPYvsWPYover <- glmer(cbind(EPY,WPY) ~ -1+FGenTrt+scale(Season, scale=FALSE)+(1|FGen)+(1|ClutchGen), data = TableClutchGenEPY , family = "binomial")
summary(modPairsOkGenEPYvsWPYover)	# p =  0.742 

invlogit(-9.7839) #  5.634842e-05 C
invlogit(-8.7326) #  0.000161216 NC

mean(unlist(ranef(modPairsOkGenEPYvsWPY)$FGen))
}

{# dumped : FIDYear%in%FIDYearOk 

# for clutches with non dumped genotyped eggs
head(TableClutchSocDumpedYN)

modPairsOkSocDumpedYN <- glmer(cbind(DumpedY,DumpedN) ~ -1+FTrt+scale(Season, scale=FALSE)+(1|FID) + (1|ClutchID), data = TableClutchSocDumpedYN , family = "binomial")
summary(modPairsOkSocDumpedYN)	# p =  0.5578

invlogit(-3.1334) #  0.04175037 C
invlogit(-3.3662) #  0.03336866 NC

mean(unlist(ranef(modPairsOkSocDumpedYN)$FID))

# including clutches with only dumped genotyped eggs
head(TableClutchSocDumped)

modPairsOkSocDumped <- glmer(cbind(DumpedY,DumpedN) ~ FTrt+scale(Season, scale=FALSE)+(1|FID) + (1|ClutchID), data = TableClutchSocDumped , family = "binomial")
summary(modPairsOkSocDumped)	# p = 0.96567	 (Season: p = 0.00997 **)

}
}

{### YN for fate0 for Pairs Ass that kept the Trt

{# Fate0YN : MIDFIDass%in%MIDFIDOk

head(TableClutchAssFate0YN)

# TableClutchAssFate0YN[TableClutchAssFate0YN$Mass == 11190 & TableClutchAssFate0YN$Season == 2012,] = 3 clutches
# TableClutchAssFate0YN <- TableClutchAssFate0YN[TableClutchAssFate0YN$ClutchAss != 129 & TableClutchAssFate0YN$ClutchAss != 131 & TableClutchAssFate0YN$ClutchAss != 132,]

modPairsOkFate0vs23456YN <- glmer(IFYN ~ MassTrt+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE) +(1|MIDFIDass)+(1|Mass)+(1|Fass), data = TableClutchAssFate0YN , family = "binomial")
summary(modPairsOkFate0vs23456YN)	# p =   0.0088 **  ( p = 0.00671 **  if only monogmaous pairs)

invlogit(-2.3874 ) #  0.08413857C
(invlogit(-2.3874+0.3542)-invlogit(-2.3874)+invlogit(-2.3874)-invlogit(-2.3874-0.3542))/2	# 0.02759908
invlogit(-1.1917 ) #  0.232955 NC
(invlogit(-1.1917+0.2969)-invlogit(-1.1917)+invlogit(-1.1917)-invlogit(-1.1917-0.2969))/2	# 0.05299416



sum(TableClutchAssFate0YN$IFYN[TableClutchAssFate0YN$MassTrt == 'C'])/length(TableClutchAssFate0YN$IFYN[TableClutchAssFate0YN$MassTrt == 'C'])# 0.1092437 (13)
sum(TableClutchAssFate0YN$IFYN[TableClutchAssFate0YN$MassTrt == 'NC']) /length(TableClutchAssFate0YN$IFYN[TableClutchAssFate0YN$MassTrt == 'NC'])# 0.2680412 (26)

mean(unlist(ranef(modPairsOkFate0vs23456YN)$MIDFIDass))
mean(unlist(ranef(modPairsOkFate0vs23456YN)$Fass))
mean(unlist(ranef(modPairsOkFate0vs23456YN)$Mass))

modPairsOkFate0vs23456YN <- glmmPQL(IFYN ~ MassTrt+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE),random=~1|Fass/MIDFIDass, data = TableClutchAssFate0YN , family = "binomial")
summary(modPairsOkFate0vs23456YN)	# p = 0.0271 *

{# pbdurlong effect

modPairsOkFate0vs23456YNPbdurlong <- glmer(IFYN ~ FassPbdurlong+MassTrt+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE) +(1|MIDFIDass)+(1|Mass)+(1|Fass), data = TableClutchAssFate0YN , family = "binomial")
summary(modPairsOkFate0vs23456YNPbdurlong)	
}

}

}

{### Brood Mass for Soc Pair that kept the Trt

head(TableClutchSocBroodMass)

modPairsOkBroodMass<- lmer(BroodMass ~ -1+MTrt+scale(Season, scale=FALSE)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID)  , data = TableClutchSocBroodMass)
summary(modPairsOkBroodMass)

#MTrtC   16.010
#MTrtNC  12.356

modPairsOkBroodMasswithoutTrt <- lmer(BroodMass ~ scale(Season, scale=FALSE)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID)  , data = TableClutchSocBroodMass)
summary(modPairsOkBroodMasswithoutTrt)

anova(modPairsOkBroodMass,modPairsOkBroodMasswithoutTrt)	# p = 0.0572 .

mean(TableClutchSocBroodMass$BroodMass[TableClutchSocBroodMass$MTrt == 'C'])	# 15.51485 C
mean(TableClutchSocBroodMass$BroodMass[TableClutchSocBroodMass$MTrt == 'NC'])	# 12.5175 NC
}



	##################################################
	## 	     GLMER Models on tables allbirds 	    ##			        ( > include individuals with count of 0  
	##################################################						and relalitve fitness per aviary )

head(allbirds,10)

{# as.factor
#allbirds$Season <- as.factor(allbirds$Season)
allbirds$Season <- as.numeric(as.character(allbirds$Season))
allbirds$Ind_ID <-as.factor(allbirds$Ind_ID )
allbirds$Treatment <-as.factor(allbirds$Treatment)
allbirds$PartnerID <-as.factor(allbirds$PartnerID)
allbirds$MIDFID <-as.factor(allbirds$MIDFID)
}

{# hist
hist(allbirds$Pbdurlong[allbirds$Treatment=="C"])
hist(allbirds$Pbdurlong[allbirds$Treatment=="NC"], xlim = c(0,700))
require(ggplot2)
dev.new()
qplot(allbirds$Pbdurlong[allbirds$Polystatus != 'unpaired'], colour=allbirds$Treatment[allbirds$Polystatus != 'unpaired'])
dev.new()
qplot(allbirds$Pbdurlong[allbirds$Treatment=="NC"], xlim = c(0,700) )
dev.new()
qplot(allbirds$Pbdurlong[allbirds$Treatment=="C"], )
dev.new()
qplot(allbirds$Pbdurlong,allbirds$Treatment)
dev.new()
qplot(pairs1213$Pbdurlong[pairs1213$MIDFID%in%MIDFIDOk], colour=pairs1213$MTrt[pairs1213$MIDFID%in%MIDFIDOk])
dev.new()
qplot(allbirds$Pbdurlong[allbirds$Divorced ==1], colour=allbirds$Treatment[allbirds$Divorced ==1])
qplot(allbirds$Pbdurlong[allbirds$Divorced ==1 &allbirds$Polystatus != 'unpaired'], colour=allbirds$Treatment[allbirds$Divorced ==1&allbirds$Polystatus != 'unpaired'])
dev.new()
qplot(pairs1213$Pbdurlong, colour=pairs1213$MTrt)
dev.new()
qplot(pairs1213$Pbdurlong, colour=pairs1213$FTrt)

hist(allbirds$EPYYes[allbirds$Divorce == 0 &allbirds$Sex == 1])
hist(allbirds$EPYYes[allbirds$Sex == 1])
hist(allbirds$EPYYes[allbirds$Sex == 0])
qplot(allbirds$EPYYes[allbirds$Sex == 0], colour = allbirds$Treatment[allbirds$Sex == 0])
qplot(allbirds$EPYYes[allbirds$Sex == 1], colour = allbirds$Treatment[allbirds$Sex == 1])
qplot(allbirds$EPYYes[allbirds$Divorce == 0 &allbirds$Sex == 1], colour = allbirds$Treatment[allbirds$Divorce == 0 &allbirds$Sex == 1])
qplot(allbirds$EPYYes[allbirds$Divorce == 0 &allbirds$Sex == 0], colour = allbirds$Treatment[allbirds$Divorce == 0 &allbirds$Sex == 0])
}


{### Real fitness of genetic parents

{# Males Trt Ok Relative fitness ~ treatment ?

modRelfitnessMaleTrtOk <- lmer(RelfitnessTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessMaleTrtOk)

#FitC 1.1633
#FitNC 0.8037 

modRelfitnessMaleTrtOkwithoutTrt <- lmer(RelfitnessTrtOk ~ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessMaleTrtOkwithoutTrt)

anova(modRelfitnessMaleTrtOk,modRelfitnessMaleTrtOkwithoutTrt)	# p =  0.02778 *	 	!! to bootstrap !!


# dataset T1-1
allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1, c('RelfitnessTrtOk', 'Ind_ID','PartnerID', 'MIDFID','Treatment', 'Pbdurlong' )]



	{# model assumptions checking
	
	mean(unlist(ranef(modRelfitnessMaleTrtOk)$Ind_ID))
	mean(unlist(ranef(modRelfitnessMaleTrtOk)$PartnerID))
	mean(unlist(ranef(modRelfitnessMaleTrtOk)$MIDFID))	
	
	scatter.smooth(fitted(modRelfitnessMaleTrtOk),resid(modRelfitnessMaleTrtOk))
	abline(h=0) 	# !!!!!!!!!!!!
	
	qqnorm(resid(modRelfitnessMaleTrtOk))
	qqline(resid(modRelfitnessMaleTrtOk))
	qqnorm(unlist(ranef(modRelfitnessMaleTrtOk)))
	qqline(unlist(ranef(modRelfitnessMaleTrtOk)))
	plot(sqrt(abs(resid(modRelfitnessMaleTrtOk))),fitted(modRelfitnessMaleTrtOk)) 	# !! heteroscedasticity !!
	plot(resid(modRelfitnessMaleTrtOk),allbirds$Pbdurlong[allbirds$Divorce == 0 & allbirds$Sex == 1])
	plot(resid(modRelfitnessMaleTrtOk),allbirds$Season[allbirds$Divorce == 0 & allbirds$Sex == 1])
	plot(resid(modRelfitnessMaleTrtOk),allbirds$Treatment[allbirds$Divorce == 0 & allbirds$Sex == 1])
	xyplot(allbirds$Relfitness[allbirds$Divorce == 0 & allbirds$Sex == 1]~allbirds$Treatment[allbirds$Divorce == 0 & allbirds$Sex == 1]|allbirds$MIDFID[allbirds$Divorce == 0 & allbirds$Sex == 1])
	xyplot(allbirds$Relfitness[allbirds$Divorce == 0 & allbirds$Sex == 1]~allbirds$Season[allbirds$Divorce == 0 & allbirds$Sex == 1]|allbirds$Ind_ID[allbirds$Divorce == 0 & allbirds$Sex == 1])

allbirds$colgraph <- NA	
	for (i in 1:nrow(allbirds))
	{
	if(allbirds$Ind_ID[i]%in%(unique(allbirds$Ind_ID[allbirds$Season == 2012 & allbirds$MIDFID%in%allbirds$MIDFID[allbirds$Season == 2013]]))) {allbirds$colgraph[i] <- "green"}
	else if(allbirds$Divorced[i] == 1) {allbirds$colgraph[i] <- "red"} 
	else {allbirds$colgraph[i] <- "black"}
	}

	nrow(allbirds[allbirds$colgraph == 'blue',])
	
	allbirds2012 <- allbirds[allbirds$Season == 2012,]
	allbirds2013 <- allbirds[allbirds$Season == 2013,]	
	
	for (i in 1:nrow(allbirds2013))
	{
	allbirds2013$Relfitness12[i] <- allbirds2012$Relfitness[allbirds2013$Ind_ID[i] == allbirds2012$Ind_ID]
	allbirds2013$Divorced12[i] <- allbirds2012$Divorced[allbirds2013$Ind_ID[i] == allbirds2012$Ind_ID]
	allbirds2013$colgraph12[i]<- allbirds2012$colgraph[allbirds2013$Ind_ID[i] == allbirds2012$Ind_ID]
	}
	
	allbirds2013[allbirds2013$colgraph == 'blue',]
	
	par(mfrow=c(1,2)) 
	males2013 <- allbirds2013[allbirds2013$Sex == 1,]
	males2013$colgraph12[males2013$Ind_ID == 11133 | males2013$Ind_ID == 11250] <- "orange"
	males2013[males2013$colgraph == 'blue',]
	plot(males2013$Relfitness12,males2013$Relfitness,col=males2013$colgraph12, pch = 16)
	abline(0,1)

	females2013 <- allbirds2013[allbirds2013$Sex == 0,]
	females2013[females2013$colgraph == 'blue',]
	females2013$colgraph12[females2013$Ind_ID == 11046 | females2013$Ind_ID == 11145] <- "orange"	
	plot(females2013$Relfitness12,females2013$Relfitness,col=females2013$colgraph12, pch = 16)
	abline(0,1)

	}

	{# average of RelfitnessTrtOk for males
mean(allbirds$RelfitnessTrtOk[allbirds$Sex == 1 & allbirds$Treatment == 'C' & allbirds$Divorced == 0])	#1.14
mean(allbirds$RelfitnessTrtOk[allbirds$Sex == 1 & allbirds$Treatment == 'NC'& allbirds$Divorced == 0])	# 0.8302632
nrow(allbirds[allbirds$Sex == 1 & allbirds$Treatment == 'C' & allbirds$Divorced == 0,])	#46
nrow(allbirds[allbirds$Sex == 1 & allbirds$Treatment == 'NC' & allbirds$Divorced == 0,])	#38
length(unique(allbirds$Ind_ID[allbirds$Sex == 1 & allbirds$Divorced == 0]))	#54

}

{# sumFate56Gen excluding polygynous male 11190
allmalesmonog <- allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1& allbirds$Ind_ID != 11190,]

modRelfitnessmonogMaleTrtOk <- lmer(RelfitnessmonogTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allmalesmonog)
summary(modRelfitnessmonogMaleTrtOk)

#FitC 1.1605
#FitNC 0.7944

modRelfitnessmonogMaleTrtOkwithoutTrt <- lmer(RelfitnessmonogTrtOk ~ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allmalesmonog)
summary(modRelfitnessmonogMaleTrtOkwithoutTrt)

anova(modRelfitnessmonogMaleTrtOk,modRelfitnessmonogMaleTrtOkwithoutTrt)	# p =  0.02916 *
}

{# sumFate56Gen only WP and not EP

modRelfitnessWPMaleTrtOk <- lmer(RelfitnessWPTrtOk ~ Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessWPMaleTrtOk)

#FitC 1.1570
#FitNC 0.8069

modRelfitnessWPMaleTrtOkwithoutTrt <- lmer(RelfitnessWPTrtOk ~ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessWPMaleTrtOkwithoutTrt)

anova(modRelfitnessWPMaleTrtOk,modRelfitnessWPMaleTrtOkwithoutTrt)	# p =  0.02605 *
}

{# sumFate56Gen only WP and not EP excluding polygynous male 11190

modRelfitnessWPmonogMaleTrtOk <- lmer(RelfitnessWPTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allmalesmonog)
summary(modRelfitnessWPmonogMaleTrtOk)

#FitC 1.1559
#FitNC 0.7933

modRelfitnessWPmonogMaleTrtOkwithoutTrt <- lmer(RelfitnessWPTrtOk ~ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allmalesmonog)
summary(modRelfitnessWPmonogMaleTrtOkwithoutTrt)

anova(modRelfitnessWPmonogMaleTrtOk,modRelfitnessWPmonogMaleTrtOkwithoutTrt)	# p =  0.02502 *

}


{# effect sizes per year

# 2012
modRelfitnessMale2012TrtOk <- lm(RelfitnessTrtOk ~ Treatment, data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1 & allbirds$Season == 2012,])
summary(modRelfitnessMale2012TrtOk)	#TreatmentNC  -0.3895     0.2157  -1.805    0.078 .  

# 2013
modRelfitnessMale2013TrtOk <- lm(RelfitnessTrtOk ~ Treatment, data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1 & allbirds$Season == 2013,])
summary(modRelfitnessMale2013TrtOk)	# TreatmentNC  -0.2227     0.1994  -1.117    0.271
}


{# Pbdurlong effect

modRelfitnessMaleTrtOkPbdurlong <- lmer(RelfitnessTrtOk ~ -1+Pbdurlong + Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessMaleTrtOkPbdurlong)

modRelfitnessMaleTrtOkwithoutPbdurlong <- lmer(RelfitnessTrtOk ~ Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessMaleTrtOkwithoutPbdurlong)

anova(modRelfitnessMaleTrtOkPbdurlong,modRelfitnessMaleTrtOkwithoutPbdurlong)
}
}

{# Females Trt Ok Relative fitness ~ treatment ?
modRelfitnessFemaleTrtOk <- lmer(RelfitnessTrtOk ~ -1+Treatment +(1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessFemaleTrtOk)

#FitC 1.0878
#FitNC  0.8433

modRelfitnessFemaleTrtOkwithoutTrt <- lmer(RelfitnessTrtOk ~ (1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessFemaleTrtOkwithoutTrt)

anova(modRelfitnessFemaleTrtOk,modRelfitnessFemaleTrtOkwithoutTrt)	# p = 0.1159	 	!! to bootstrap !!


# dataset T1-2
allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0, c('RelfitnessTrtOk', 'Ind_ID','PartnerID', 'MIDFID', 'Treatment','Pbdurlong' )]



	{# model assumptions checking
	
	mean(unlist(ranef(modRelfitnessFemaleTrtOk)$Ind_ID))
	
	scatter.smooth(fitted(modRelfitnessFemaleTrtOk),resid(modRelfitnessFemaleTrtOk))
	abline(h=0) 																	# !!!!!!!!!!!!
	qqnorm(resid(modRelfitnessFemaleTrtOk))
	qqline(resid(modRelfitnessFemaleTrtOk))
	qqnorm(unlist(ranef(modRelfitnessFemaleTrtOk)))
	qqline(unlist(ranef(modRelfitnessFemaleTrtOk)))
	plot(sqrt(abs(resid(modRelfitnessFemaleTrtOk))),fitted(modRelfitnessFemaleTrtOk)) 	# !! heteroscedasticity !!
	plot(resid(modRelfitnessFemaleTrtOk),allbirds$Pbdurlong[allbirds$Divorce == 0 & allbirds$Sex == 0])
	plot(resid(modRelfitnessFemaleTrtOk),allbirds$Season[allbirds$Divorce == 0 & allbirds$Sex == 0])
	boxplot(resid(modRelfitnessFemaleTrtOk)~allbirds$Treatment[allbirds$Divorce == 0 & allbirds$Sex == 0])
	}

	{# average of RelfitnessTrtOk for females
mean(allbirds$RelfitnessTrtOk[allbirds$Sex == 0 & allbirds$Treatment == 'C' & allbirds$Divorced == 0])	# 1.08087
mean(allbirds$RelfitnessTrtOk[allbirds$Sex == 0 & allbirds$Treatment == 'NC'& allbirds$Divorced == 0])	#  0.8542105
nrow(allbirds[allbirds$Sex == 0 & allbirds$Treatment == 'C' & allbirds$Divorced == 0,])	#46
nrow(allbirds[allbirds$Sex == 0 & allbirds$Treatment == 'NC' & allbirds$Divorced == 0,])	#38
length(unique(allbirds$Ind_ID[allbirds$Sex == 0 & allbirds$Divorced == 0]))	#55
}

{# sumFate56Gen excluding secondary female 11187

allfemalesmonog <- allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0 & allbirds$Ind_ID != 11187,]

modRelfitnessmonogFemaleTrtOk <- lmer(RelfitnessmonogTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allfemalesmonog)
summary(modRelfitnessmonogFemaleTrtOk)

#FitC 1.0880
#FitNC 0.8608

modRelfitnessmonogFemaleTrtOkwithoutTrt <- lmer(RelfitnessmonogTrtOk ~ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allfemalesmonog)
summary(modRelfitnessmonogFemaleTrtOkwithoutTrt)

anova(modRelfitnessmonogFemaleTrtOk,modRelfitnessmonogFemaleTrtOkwithoutTrt)	# p =   0.1458
}

{# sumFate56Gen only WP and not EP

modRelfitnessWPFemaleTrtOk <- lmer(RelfitnessWPTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessWPFemaleTrtOk)

#FitC 1.1542
#FitNC 0.7755

modRelfitnessWPFemaleTrtOkwithoutTrt <- lmer(RelfitnessWPTrtOk ~ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessWPFemaleTrtOkwithoutTrt)

anova(modRelfitnessWPFemaleTrtOk,modRelfitnessWPFemaleTrtOkwithoutTrt)	# p =  0.01692 *
}

{# sumFate56Gen only WP and not EP excluding secondary female 11187

modRelfitnessWPmonogFemaleTrtOk <- lmer(RelfitnessWPTrtOk ~ Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allfemalesmonog)
summary(modRelfitnessWPmonogFemaleTrtOk)

#FitC 1.1560
#FitNC 0.7986

modRelfitnessWPmonogFemaleTrtOkwithoutTrt <- lmer(RelfitnessWPTrtOk ~ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allfemalesmonog)
summary(modRelfitnessWPmonogFemaleTrtOkwithoutTrt)

anova(modRelfitnessWPmonogFemaleTrtOk,modRelfitnessWPmonogFemaleTrtOkwithoutTrt)	# p =  0.02473 *

}


{# effect sizes per year

# 2012
modRelfitnessFemale2012TrtOk <- lm(RelfitnessTrtOk ~ Treatment, data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0 & allbirds$Season == 2012,])
summary(modRelfitnessFemale2012TrtOk)	#TreatmentNC  -0.2459     0.2023  -1.216    0.231 

# 2013
modRelfitnessFemale2013TrtOk <- lm(RelfitnessTrtOk ~ Treatment, data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0 & allbirds$Season == 2013,])
summary(modRelfitnessFemale2013TrtOk)	# TreatmentNC  -0.2138     0.1934  -1.105    0.276
}

{# Pbdurlong effect

modRelfitnessFemaleTrtOkPbdurlong <- lmer(RelfitnessTrtOk ~ -1+Pbdurlong + Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessFemaleTrtOkPbdurlong)

modRelfitnessFemaleTrtOkwithoutPbdurlong <- lmer(RelfitnessTrtOk ~ Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessFemaleTrtOkwithoutPbdurlong)

anova(modRelfitnessFemaleTrtOkPbdurlong,modRelfitnessFemaleTrtOkwithoutPbdurlong)
}

}


# With all decimals from the models:
# Average C: (1.1633+ 1.0878)/2 = 1.12555

# Average NC: (0.8037+ 0.8433)/2 = 0.8235

# Difference: = 1.12555-0.8235=0.30205
# =0.30205*100/0.8235= 36.67881 %



{# Interaction Sex*Trt for birds that kept the Trt
modRelfitnessBirdsTrtOk <- lmer(RelfitnessTrtOk ~ Treatment*Sex +(1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0,])
summary(modRelfitnessBirdsTrtOk) # TreatmentNC:Sex  t = -0.907

modRelfitnessBirdsTrtOkwithoutTrt <- lmer(RelfitnessTrtOk ~ Treatment + Sex + (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0,])
summary(modRelfitnessBirdsTrtOkwithoutTrt)

anova(modRelfitnessBirdsTrtOk,modRelfitnessBirdsTrtOkwithoutTrt)	# p =  0.3606
}

{# Interaction Sex*Trt for birds that kept the Trt excluding polygynous male and secondary female 11190 and 11187

allmonogbirds <- allbirds[allbirds$Divorce == 0 & allbirds$Ind_ID != 11190 &allbirds$Ind_ID != 11187 ,]

modRelfitnessBirdsTrtOk <- lmer(RelfitnessTrtOk ~ Treatment*Sex +(1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allmonogbirds)
summary(modRelfitnessBirdsTrtOk) # TreatmentNC:Sex  t = -1.074

modRelfitnessBirdsTrtOkwithoutTrt <- lmer(RelfitnessTrtOk ~ Treatment+ Sex + (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allmonogbirds)
summary(modRelfitnessBirdsTrtOkwithoutTrt)

anova(modRelfitnessBirdsTrtOk,modRelfitnessBirdsTrtOkwithoutTrt)	# p =  0.279
}

}

{### nb of eggs laid by assigned females ~ treatment ?	

{# Female Trt Ok

modSumEggIDFemaleTrtOk <- lmer(sumEggIDass ~ -1+Treatment +scale(Season, scale=FALSE)+ (1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modSumEggIDFemaleTrtOk)

#  13.5219 C
#  14.3981 NC

modSumEggIDFemaleTrtOkwithoutTrt <- lmer(sumEggIDass ~ scale(Season, scale=FALSE) + (1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modSumEggIDFemaleTrtOkwithoutTrt)

anova(modSumEggIDFemaleTrtOk,modSumEggIDFemaleTrtOkwithoutTrt)	# p = 0.5563


# T1 - 3
allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,c('Ind_ID','PartnerID','MIDFID','Treatment','Season','sumEggIDass','Pbdurlong')]




	{# model assumption checking
	scatter.smooth(fitted(modSumEggIDFemaleTrtOk2),resid(modSumEggIDFemaleTrtOk2))
	abline(h=0) 																	# !!!!!!!!!!!!
	qqnorm(resid(modSumEggIDFemaleTrtOk2))
	qqline(resid(modSumEggIDFemaleTrtOk2))
	qqnorm(unlist(ranef(modSumEggIDFemaleTrtOk2)))
	qqline(unlist(ranef(modSumEggIDFemaleTrtOk2)))
	plot(sqrt(abs(resid(modSumEggIDFemaleTrtOk2))),fitted(modSumEggIDFemaleTrtOk2)) 
	boxplot(resid(modSumEggIDFemaleTrtOk2)~allbirds$Season[allbirds$Divorce == 0 & allbirds$Sex == 0])
	boxplot(resid(modSumEggIDFemaleTrtOk2)~allbirds$Treatment[allbirds$Divorce == 0 & allbirds$Sex == 0])
	boxplot(fitted(modSumEggIDFemaleTrtOk2)~allbirds$Season[allbirds$Divorce == 0 & allbirds$Sex == 0])
	boxplot(fitted(modSumEggIDFemaleTrtOk2)~allbirds$Treatment[allbirds$Divorce == 0 & allbirds$Sex == 0])
}

	{# average of sumEggID ass for FTrtOk
mean(allbirds$sumEggIDass[allbirds$Sex == 0 & allbirds$Treatment == 'C' & allbirds$Divorced == 0])	#13.28
mean(allbirds$sumEggIDass[allbirds$Sex == 0 & allbirds$Treatment == 'NC'& allbirds$Divorced == 0])	#14.26
nrow(allbirds[allbirds$Sex == 0 & allbirds$Treatment == 'C' & allbirds$Divorced == 0,])	#46
nrow(allbirds[allbirds$Sex == 0 & allbirds$Treatment == 'NC' & allbirds$Divorced == 0,])	#38
}

{# Females Trt ok excluding secondary female 11187

head(allfemalesmonog)

modSumEggIDFemalemonogTrtOk <- lmer(sumEggIDass ~ Treatment +scale(Season)+ (1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allfemalesmonog)
summary(modSumEggIDFemalemonogTrtOk)

modSumEggIDFemalemonogTrtOkwithoutTrt <- lmer(sumEggIDass ~ Season + (1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allfemalesmonog)
summary(modSumEggIDFemalemonogTrtOkwithoutTrt)

anova(modSumEggIDFemalemonogTrtOk,modSumEggIDFemalemonogTrtOkwithoutTrt)	# p = 0.5889
}

{# PbDurlong effect
modSumEggIDFemaleTrtOkPbdurlong <- lmer(sumEggIDass ~ Pbdurlong+Treatment +scale(Season, scale=FALSE)+ (1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modSumEggIDFemaleTrtOkPbdurlong)


modSumEggIDFemaleTrtOkwithoutPbdurlong <- lmer(sumEggIDass ~ Treatment +scale(Season, scale=FALSE) + (1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modSumEggIDFemaleTrtOkwithoutPbdurlong)

anova(modSumEggIDFemaleTrtOkPbdurlong,modSumEggIDFemaleTrtOkwithoutPbdurlong)	
}


}

}

{### nb of eggs laid by genetic females ~ treatment ?	

{# Female Trt Ok
modSumEggIDGenFemaleTrtOk <- lmer(sumEggIDGen ~ Treatment + Season + Pbdurlong +(1|Ind_ID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modSumEggIDGenFemaleTrtOk)

modSumEggIDGenFemaleTrtOkwithoutTrt <- lmer(sumEggIDGen ~ Season + Pbdurlong +(1|Ind_ID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modSumEggIDGenFemaleTrtOkwithoutTrt)

anova(modSumEggIDGenFemaleTrtOk,modSumEggIDGenFemaleTrtOkwithoutTrt)	# p = 0.19
}
}


{### mean mass of chicks at day 8 for social parents

{# all Males/Females Trt Ok
bla <- allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1 & allbirds$MIDFID != '1119011187',]
modMeanMass8dChicksocMaleTrtOk <- lmer(MeanMass8dChicksoc ~ Treatment + Season + Pbdurlong +(1|Ind_ID) + (1|MIDFID), data = bla)
summary(modMeanMass8dChicksocMaleTrtOk)

modMeanMass8dChicksocMaleTrtOkwithoutTrt <- lmer(MeanMass8dChicksoc ~ Season + Pbdurlong + (1|Ind_ID) + (1|MIDFID), data = bla)
summary(modMeanMass8dChicksocMaleTrtOkwithoutTrt)

anova(modMeanMass8dChicksocMaleTrtOk,modMeanMass8dChicksocMaleTrtOkwithoutTrt)	# p = 0.1227

	aaa <- allbirds[allbirds$Divorced == 0, c("MIDFID","MeanMass8dChicksoc")]
	aaa[order(aaa$MIDFID),]
	allbirds[allbirds$MIDFID == 1119011187,]
	
	
modMeanMass8dChicksocMaleTrtOk2 <- lmer(MeanMass8dChicksoc ~ Treatment + Season +(1|Ind_ID) + (1|MIDFID), data = bla)
summary(modMeanMass8dChicksocMaleTrtOk2)

modMeanMass8dChicksocMaleTrtOkwithoutTrt2 <- lmer(MeanMass8dChicksoc ~ Season  + (1|Ind_ID) + (1|MIDFID), data = bla)
summary(modMeanMass8dChicksocMaleTrtOkwithoutTrt2)

anova(modMeanMass8dChicksocMaleTrtOk2,modMeanMass8dChicksocMaleTrtOkwithoutTrt2)	# p = 0.24

}

}

{### EPY

# Females Trt Ok
EPYFemalesTrtOk <- cbind(allbirds$EPYYes[allbirds$Divorce == 0 &allbirds$Sex == 0],allbirds$EPYNo[allbirds$Divorce == 0 &allbirds$Sex == 0])

modEPYFemalesTrtOk <- glmer (EPYFemalesTrtOk  ~ Treatment + Pbdurlong + Season + (1|Ind_ID) , family = "binomial", data = allbirds[allbirds$Divorce == 0 &allbirds$Sex == 0,])
summary(modEPYFemalesTrtOk)	

modEPYFemalesTrtOk2 <- glmer (EPYFemalesTrtOk  ~ Treatment + Pbdurlong + (1|Ind_ID) , family = "binomial", data = allbirds[allbirds$Divorce == 0 &allbirds$Sex == 0,])
summary(modEPYFemalesTrtOk2)	

	{# model assumptions checking
	
	# check for overdispersion				!! OVERDISPERSED !!
	allbirds$id[allbirds$Divorce == 0 &allbirds$Sex == 0] <- factor(1:nrow(allbirds[allbirds$Divorce == 0 &allbirds$Sex == 0,]))
	modEPYFemalesTrtOkOverdisp  <- glmer (EPYFemalesTrtOk  ~ Treatment + Pbdurlong + Season + (1|Ind_ID) +(1|id), family = "binomial", data = allbirds[allbirds$Divorce == 0 &allbirds$Sex == 0,])
	summary(modEPYFemalesTrtOkOverdisp)
	anova(modEPYFemalesTrtOkOverdisp,modEPYFemalesTrtOk)
	
	# qqplots residuals and ranef
	qqnorm(resid(modEPYFemalesTrtOk))
	qqline(resid(modEPYFemalesTrtOk))
	qqnorm(unlist(ranef(modEPYFemalesTrtOk)))	
	qqline(unlist(ranef(modEPYFemalesTrtOk)))
	
	# residuals vs fitted					# !! AWFUL !!
	scatter.smooth(fitted(modEPYFemalesTrtOk), resid(modEPYFemalesTrtOk))
	abline(h=0, lty=2)
	
	# residuals vs predictors		
	scatter.smooth(allbirds$Pbdurlong[allbirds$Divorce == 0 &allbirds$Sex == 0], resid(modEPYFemalesTrtOk))
	abline(h=0, lty=2)
	
	# data vs. fitted ?							# !! AWFUL !!!	
	datEPYFemalesTrtOk <- allbirds[allbirds$Divorce == 0 &allbirds$Sex == 0,]
	datEPYFemalesTrtOk$fitted <- fitted(modEPYFemalesTrtOk)
	scatter.smooth(datEPYFemalesTrtOk$fitted, jitter(datEPYFemalesTrtOk$EPYYes/(datEPYFemalesTrtOk$EPYYes+datEPYFemalesTrtOk$EPYNo), 0.05),ylim=c(0, 1))
	abline(0,1)	
	
	# data and fitted against all predictors
	boxplot(fitted~Treatment, datEPYFemalesTrtOk , ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability in Female", xlab="Trt")
	points(jitter(as.numeric(datEPYFemalesTrtOk$Treatment)), datEPYFemalesTrtOk$EPYYes/(datEPYFemalesTrtOk$EPYYes+datEPYFemalesTrtOk$EPYNo), col="orange", lwd=2)
	boxplot(fitted~Season, datEPYFemalesTrtOk, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability in Females", xlab="Season")
	points(jitter(as.numeric(datEPYFemalesTrtOk$Season)), datEPYFemalesTrtOk$EPYYes/(datEPYFemalesTrtOk$EPYYes+datEPYFemalesTrtOk$EPYNo), col="orange", lwd=2)
	scatter.smooth(datEPYFemalesTrtOk$Pbdurlong,datEPYFemalesTrtOk$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability in Females", xlab="Pbdurlong")	
	points(jitter(datEPYFemalesTrtOk$Pbdurlong), datEPYFemalesTrtOk$EPYYes/(datEPYFemalesTrtOk$EPYYes+datEPYFemalesTrtOk$EPYNo), col="orange", lwd=2)
	}

require(pscl)
EPYFemalesTrtOkZinfl <- zeroinfl(EPYYes ~ Treatment | 1 , data = allbirds[allbirds$Divorce == 0 &allbirds$Sex == 0,])
summary(EPYFemalesTrtOkZinfl)


{# Males Trt Ok
EPYMalesTrtOk <- cbind(allbirds$EPYYes[allbirds$Divorce == 0 &allbirds$Sex == 1],allbirds$EPYNo[allbirds$Divorce == 0 &allbirds$Sex == 1])

modEPYMalesTrtOk <- glmer (EPYMalesTrtOk  ~ Treatment + Pbdurlong + Season + (1|Ind_ID) , family = "binomial", data = allbirds[allbirds$Divorce == 0 &allbirds$Sex == 1,])
summary(modEPYMalesTrtOk)	

	{# model assumptions checking
	
	# check for overdispersion				!! OVERDISPERSED !!
	allbirds$id[allbirds$Divorce == 0 &allbirds$Sex == 1] <- factor(1:nrow(allbirds[allbirds$Divorce == 0 &allbirds$Sex == 1,]))
	modEPYMalesTrtOkOverdisp  <- glmer (EPYMalesTrtOk  ~ Treatment + Pbdurlong + Season + (1|Ind_ID) +(1|id), family = "binomial", data = allbirds[allbirds$Divorce == 0 &allbirds$Sex == 1,])
	summary(modEPYMalesTrtOkOverdisp)
	anova(modEPYMalesTrtOkOverdisp,modEPYMalesTrtOk)
	
	# qqplots residuals and ranef
	qqnorm(resid(modEPYMalesTrtOk))
	qqline(resid(modEPYMalesTrtOk))
	qqnorm(unlist(ranef(modEPYMalesTrtOk)))	
	qqline(unlist(ranef(modEPYMalesTrtOk)))
	
	# residuals vs fitted					# !! AWFUL !!
	scatter.smooth(fitted(modEPYMalesTrtOk), resid(modEPYMalesTrtOk))
	abline(h=0, lty=2)
	
	# residuals vs predictors		
	scatter.smooth(allbirds$Pbdurlong[allbirds$Divorce == 0 &allbirds$Sex == 1], resid(modEPYMalesTrtOk))
	abline(h=0, lty=2)
	
	# data vs. fitted ?							# !! AWFUL !!!	
	datEPYMalesTrtOk <- allbirds[allbirds$Divorce == 0 &allbirds$Sex == 1,]
	datEPYMalesTrtOk$fitted <- fitted(modEPYMalesTrtOk)
	scatter.smooth(datEPYMalesTrtOk$fitted, jitter(datEPYMalesTrtOk$EPYYes/(datEPYMalesTrtOk$EPYYes+datEPYMalesTrtOk$EPYNo), 0.05),ylim=c(0, 1))
	abline(0,1)	
	
	# data and fitted against all predictors
	boxplot(fitted~Treatment, datEPYMalesTrtOk , ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability in male", xlab="Trt")
	points(jitter(as.numeric(datEPYMalesTrtOk$Treatment)), datEPYMalesTrtOk$EPYYes/(datEPYMalesTrtOk$EPYYes+datEPYMalesTrtOk$EPYNo), col="orange", lwd=2)
	boxplot(fitted~Season, datEPYMalesTrtOk, ylim=c(0, 1), las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability in males", xlab="Season")
	points(jitter(as.numeric(datEPYMalesTrtOk$Season)), datEPYMalesTrtOk$EPYYes/(datEPYMalesTrtOk$EPYYes+datEPYMalesTrtOk$EPYNo), col="orange", lwd=2)
	scatter.smooth(datEPYMalesTrtOk$Pbdurlong,datEPYMalesTrtOk$fitted,  las=1, cex.lab=1.4, cex.axis=1.2, ylab="EPY probability in males", xlab="Pbdurlong")	
	points(jitter(datEPYMalesTrtOk$Pbdurlong), datEPYMalesTrtOk$EPYYes/(datEPYMalesTrtOk$EPYYes+datEPYMalesTrtOk$EPYNo), col="orange", lwd=2)
	}

require(pscl)
EPYMalesTrtOkZinfl <- zeroinfl(EPYYes ~ Treatment | 1 , data = allbirds[allbirds$Divorce == 0 &allbirds$Sex == 1,])
summary(EPYMalesTrtOkZinfl)
}
}



{### YN for EPY or dumped for Individual Gen that kept the Trt

{# EPY : FGenYear%in%FIDYearOk

head(TableClutchGenEPYYN)

# TableClutchGenEPYYN[TableClutchGenEPYYN$FGen == 11187 ,] = 4 clutches
# TableClutchGenEPYYN <- TableClutchGenEPYYN[TableClutchGenEPYYN$ClutchGen != 129 & TableClutchGenEPYYN$ClutchGen != 130 & TableClutchGenEPYYN$ClutchGen != 131 & TableClutchGenEPYYN$ClutchGen != 132,]

TableClutchGenEPYYN$FGenTrt <- as.factor(TableClutchGenEPYYN$FGenTrt)

modPairsOkGenEPYYN <- glmer(EPYYN ~ -1+FGenTrt+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE)+(1|FGen), data = TableClutchGenEPYYN , family = "binomial")
summary(modPairsOkGenEPYYN)	# p =  0.0418*		(p = 0.0855 . if exclude secondary female 11187)

invlogit(-2.81909)  # 0.05630126 C
(invlogit(-2.81909+0.45914)-invlogit(-2.81909)+invlogit(-2.81909)-invlogit(-2.81909-0.45914))/2	# 0.02497625
invlogit(-1.60855) # 0.16679 NC
(invlogit(-1.60855+0.41906)-invlogit(-1.60855)+invlogit(-1.60855)-invlogit(-1.60855-0.41906))/2	# 0.05850789


sum(TableClutchGenEPYYN$EPYYN[TableClutchGenEPYYN$FGenTrt == 'C'])/length(TableClutchGenEPYYN$EPYYN[TableClutchGenEPYYN$FGenTrt == 'C'])# 0.125 (17)

sum(TableClutchGenEPYYN$EPYYN[TableClutchGenEPYYN$FGenTrt == 'NC']) /length(TableClutchGenEPYYN$EPYYN[TableClutchGenEPYYN$FGenTrt == 'NC'])# 0.2477064 (27)


sum(TableClutchGenEPYYN$EPYYN) #44



mean(unlist(ranef(modPairsOkGenEPYYN)$FGen))

modPairsOkGenEPYYN <- glmmPQL(EPYYN ~ FGenTrt+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE), random=~1|FGen, data = TableClutchGenEPYYN , family = "binomial")
summary(modPairsOkGenEPYYN)	# p = 0.0403 *

mean(unlist(ranef(modPairsOkGenEPYYN)))

sum(Eggs$EPY[Eggs$FGenYear%in%FIDYearOk & Eggs$FGenTrt == 'C'])	 #36
sum(Eggs$EPY[Eggs$FGenYear%in%FIDYearOk & Eggs$FGenTrt == 'NC']) #42

TableClutchGenEPYYN$FGenSeason <- paste(TableClutchGenEPYYN$FGen, TableClutchGenEPYYN$Season, sep='')
length(unique(TableClutchGenEPYYN$FGenSeason[TableClutchGenEPYYN$EPYYN == 1]))#25

{# Pbdurlong effect >> the one in Table S2 NOW


modPairsOkGenEPYYNPbdurlong <- glmer(EPYYN ~ -1+FGenTrt+FassPbdurlong+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE)+(1|FGen), data = TableClutchGenEPYYN , family = "binomial")
summary(modPairsOkGenEPYYNPbdurlong)

invlogit(-1.445729)  # 0.1906597 C
(invlogit(-1.445729+0.929302)-invlogit(-1.445729)+invlogit(-1.445729)-invlogit(-1.445729-0.929302))/2	# 0.1442957
invlogit(-0.844642) # 0.300558 NC
(invlogit(-0.844642+0.616360)-invlogit(-0.844642)+invlogit(-0.844642)-invlogit(-0.844642-0.616360))/2	# 0.127431


modPairsOkGenEPYYNPbdurlong <- glmer(EPYYN ~ FGenTrt+scale(FassPbdurlong, scale=FALSE)+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE)+(1|FGen), data = TableClutchGenEPYYN , family = "binomial")
summary(modPairsOkGenEPYYNPbdurlong)

invlogit(-2.700223)  # 0.0629602 C
(invlogit(-2.700223+0.475977)-invlogit(-2.700223)+invlogit(-2.700223)-invlogit(-2.700223-0.475977))/2	# 0.02876149
invlogit(-2.099135) # 0.1091809 NC
(invlogit(-2.099135+0.501765)-invlogit(-2.099135)+invlogit(-2.099135)-invlogit(-2.099135-0.501765))/2	# 0.0496345



}

}

{# EPY : MGenYear%in%MIDYearOk

head(TableMGenEPYYN)

{ #without the 3 male-Yr without genetic eggs
# TableMGenEPYYN[TableMGenEPYYN$MGenYear == 111902012,] = 1
# TableMGenEPYYN <- TableMGenEPYYN[TableMGenEPYYN$MGenYear != 111902012,]


TableMGenEPYYN$MGenTrt <- as.factor(TableMGenEPYYN$MGenTrt)

modMGenOkEPYYN <- glmer(EPYYN ~ MGenTrt+scale(Season, scale=FALSE)+ (1|MGen), data = TableMGenEPYYN , family = "binomial")
summary(modMGenOkEPYYN)	# p =  0.2168	(p = 0.2531 if polygynous male excluded)

invlogit(-0.6984)  #  0.3321671 C
(invlogit(-0.6984+0.3598)-invlogit(-0.6984)+invlogit(-0.6984)-invlogit(-0.6984-0.3598))/2	#  0.079248
invlogit(-1.4123) # 0.1958715 NC
(invlogit(-1.4123+0.4624)-invlogit(-1.4123)+invlogit(-1.4123)-invlogit(-1.4123-0.4624))/2	# 0.07295305




mean(unlist(ranef(modMGenOkEPYYN)$MGen))

modMGenOkEPYYN <- glmmPQL(EPYYN ~ MGenTrt+scale(Season, scale=FALSE), random=~1|MGen, data = TableMGenEPYYN , family = "binomial")
summary(modMGenOkEPYYN)

mean(unlist(ranef(modMGenOkEPYYN)))

sum(Eggs$EPY[Eggs$MGenYear%in%MIDYearOk & Eggs$MGenTrt == 'C'])	 #56
sum(Eggs$EPY[Eggs$MGenYear%in%MIDYearOk & Eggs$MGenTrt == 'NC']) #22

sum (TableMGenEPYYN$EPYYN)#25
}

# add the 3 male-seasons without genetic eggs

length(MIDYearOk)
length(TableMGenEPYYN$MGenYear)
MIDYearOk[!(MIDYearOk%in%TableMGenEPYYN$MGenYear)]# 111472012 112532013 112302013

allbirds[allbirds$IDYear == 111472012 | allbirds$IDYear == 112532013 | allbirds$IDYear == 112302013 ,c('IDYear','EPYYes','EPYNo','Ind_ID','Treatment','Season','Pbdurlong')]

MaleSeasonsNOPaternity <-allbirds[allbirds$IDYear == 111472012 | allbirds$IDYear == 112532013 | allbirds$IDYear == 112302013 ,c('IDYear','EPYYes','Ind_ID','Treatment','Season','Pbdurlong')]
colnames(MaleSeasonsNOPaternity) <-colnames(TableMGenEPYYN)
MaleSeasonsNOPaternity$MGenYear <-as.factor(MaleSeasonsNOPaternity$MGenYear)
TableMGenEPYYNwithallmales <- rbind(TableMGenEPYYN, MaleSeasonsNOPaternity)



modALLMGenOkEPYYN <- glmer(EPYYN ~ -1+MGenTrt+scale(Season, scale=FALSE)+ (1|MGen), data = TableMGenEPYYNwithallmales , family = "binomial")
summary(modALLMGenOkEPYYN)	# p =  0.1639

invlogit(-0.7348)  #  0.3241423 C
(invlogit(-0.7348+0.3720)-invlogit(-0.7348)+invlogit(-0.7348)-invlogit(-0.7348-0.3720))/2	# 0.08090699
invlogit(-1.5570) # 0.1740775 NC
(invlogit(-1.5570+0.4713)-invlogit(-1.5570)+invlogit(-1.5570)-invlogit(-1.5570-0.4713))/2	# 0.06808269


# Pbdur effect

modALLMGenOkEPYYNPbdurlong <- glmer(EPYYN ~ Pbdurlong+MGenTrt+scale(Season, scale=FALSE)+ (1|MGen), data = TableMGenEPYYNwithallmales , family = "binomial")
summary(modALLMGenOkEPYYNPbdurlong)



}

{# dumped : FIDYear%in%FIDYearOk  & !(is.na(Eggs$FGen))

# for clutches with social and genotyped eggs
head(TableClutchSocYNDumped)

# TableClutchSocYNDumped[TableClutchSocYNDumped$FID == 11187 ,] = 3 clutches
# TableClutchSocYNDumped <- TableClutchSocYNDumped[TableClutchSocYNDumped$ClutchID != 369 & TableClutchSocYNDumped$ClutchID != 537 & TableClutchSocYNDumped$ClutchID != 580,]


modPairsOkSocYNDumped <- glmer(DumpedYN ~ FTrt+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE)+(1|FID), data = TableClutchSocYNDumped , family = "binomial")
summary(modPairsOkSocYNDumped)	# p =  0.58920



mean(unlist(ranef(modPairsOkSocYNDumped)$FID))


modPairsOkSocYNDumped <- glmer(DumpedYN ~ FTrt+scale(Season, scale=FALSE)+(1|FID), data = TableClutchSocYNDumped , family = "binomial")
summary(modPairsOkSocYNDumped)	# p =  0.3605 	(p = 0.3597 if secondary female 11187 excluded)
# 0.4100 (02/06/2014)

invlogit(-1.0862) #  0.2523345 C
invlogit(-1.4348) #  0.1923519 NC
	
	# on 02/06/2014
invlogit(-1.0259) #  0.2638797 C
(invlogit(-1.0259+0.2586)-invlogit(-1.0259)+invlogit(-1.0259)-invlogit(-1.0259-0.2586))/2	#  0.05013913
invlogit(-1.3431) #   0.2070007 NC
(invlogit(-1.3431+0.2934)-invlogit(-1.3431)+invlogit(-1.3431)-invlogit(-1.3431-0.2934))/2	#  0.04817042




sum(TableClutchSocYNDumped$DumpedYN[TableClutchSocYNDumped$FTrt == 'C'])/length(TableClutchSocYNDumped$DumpedYN[TableClutchSocYNDumped$FTrt == 'C'])#  0.2711864 (32)

sum(TableClutchSocYNDumped$DumpedYN[TableClutchSocYNDumped$FTrt == 'NC'])/length(TableClutchSocYNDumped$DumpedYN[TableClutchSocYNDumped$FTrt == 'NC'])#  0.2211538 (23)


{# Pbdur effect


 ## on 19/03/2015: 6 FassPbDur are now missing (before were incorrect) because clutch entirely dumped (no egg from social FID)
 ## if needed they could be figured out
modPairsOkSocYNDumpedPbdur <- glmer(DumpedYN ~ FassPbdur+FTrt+scale(Season, scale=FALSE)+(1|FID), data = TableClutchSocYNDumped , family = "binomial")
summary(modPairsOkSocYNDumpedPbdur)	
}


}
}




{### Relative Fitness ~ discriminant score

{## males

#2012 discrim for year 2012
modRelfitnessMalediscrim2012 <- lm(Relfitness ~ Treatment + discrim2012 , data = allbirds[allbirds$Sex == 1 & allbirds$Season == 2012,])
summary(modRelfitnessMalediscrim2012)

#2013 discrim for year 2013
modRelfitnessMalediscrim2013 <- lm(Relfitness ~ Treatment  + discrim2013 , data = allbirds[allbirds$Sex == 1 & allbirds$Season == 2013,])
summary(modRelfitnessMalediscrim2013)

#mean discrim for both years
modRelfitnessMalediscrimMean <- lmer(Relfitness ~ Treatment  + MeanMdiscrim +(1|Ind_ID), data = allbirds[allbirds$Sex == 1,])
summary(modRelfitnessMalediscrimMean)
}

{## females

#2013 discrim for year 2013
modRelfitnessFemalediscrim2013 <- lm(Relfitness ~ Treatment + discrim2013 , data = allbirds[allbirds$Sex == 0 & allbirds$Season == 2013,])
summary(modRelfitnessFemalediscrim2013)

#2013 discrim for both years
modRelfitnessFemalediscrim2013bothseason <- lmer(Relfitness ~ Treatment  + discrim2013 + (1|Ind_ID), data = allbirds[allbirds$Sex == 0,])
summary(modRelfitnessFemalediscrim2013bothseason)

#Massd45 for both years
modRelfitnessFemaleMassd45 <- lmer(Relfitness ~ Treatment  + Massd45 + (1|Ind_ID), data = allbirds[allbirds$Sex == 0,])
summary(modRelfitnessFemaleMassd45)
}
}


{### Relative fitness ~ stay/new

head(allbirds)
pairsStay
allbirds[allbirds$Season == 2013  & allbirds$StayYN == 'stay',]
nrow(allbirds[allbirds$Season == 2013  & allbirds$StayYN == 'stay',])
nrow(allbirds[allbirds$Season == 2013  & allbirds$StayYN == 'stay' & allbirds$Sex == 1 & allbirds$Treatment == 'C' ,])#7


## males
Males13Ok <- allbirds[allbirds$Season == 2013 & allbirds$Sex == 1 & allbirds$Divorced == 0,]

modRelfitnessMale13TrtOkStayYN <- lm(RelfitnessTrtOk ~ Treatment+StayYN, data = Males13Ok)
summary(modRelfitnessMale13TrtOkStayYN )	# p = 0.937


## females
Females13Ok <- allbirds[allbirds$Season == 2013 & allbirds$Sex == 0 & allbirds$Divorced == 0,]

modRelfitnessFemale13TrtOkStayYN <- lm(RelfitnessTrtOk ~ Treatment+StayYN, data = Females13Ok)
summary(modRelfitnessFemale13TrtOkStayYN )	# p = 0.831
}


{### Relative fitness ~ kept the trt / divorce
library(effects)	# error bars = CI

{### fitness in 'allbirds'

allbirds$TrtDiv <- as.character(allbirds$Treatment)
for (i in 1:nrow(allbirds)) {if (allbirds$Divorced[i] == '1'){allbirds$TrtDiv[i] <- 'Div'}}
head(allbirds)

allbirds[allbirds$Polystatus == 'unpaired',]
allbirds[allbirds$Divorced == 1,]
nrow(allbirds[allbirds$Divorced == 1,])
nrow(allbirds[allbirds$Sex == 1,])

# paired males
modRelfitnessMales <- lmer(Relfitness ~ -1+TrtDiv +(1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Sex == 1 & allbirds$Polystatus != 'unpaired',])
summary(modRelfitnessMales)
plot(effect('TrtDiv', modRelfitnessMales))

# paired females
modRelfitnessFemales <- lmer(Relfitness ~ -1+TrtDiv +(1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Sex == 0 & allbirds$Polystatus != 'unpaired',])
summary(modRelfitnessFemales)
plot(effect('TrtDiv', modRelfitnessFemales))


# all males
modRelfitnessAllMales <- lmer(Relfitness ~ -1+TrtDiv +(1|Ind_ID) +(1|MIDFID), data = allbirds[allbirds$Sex == 1,])
summary(modRelfitnessAllMales)
plot(effect('TrtDiv', modRelfitnessAllMales))

# all females
modRelfitnessAllFemales <- lmer(Relfitness ~ -1+TrtDiv +(1|Ind_ID) + (1|MIDFID), data = allbirds[allbirds$Sex == 0,])
summary(modRelfitnessAllFemales)
plot(effect('TrtDiv', modRelfitnessAllFemales))
}

{### initiators of divorce in 2012 > higher fitness in 2012 and 2013 ?
listbirdsinidivorce2012 <- allbirds$Ind_ID[!(is.na(allbirds$IniDivorce)) & allbirds$IniDivorce == 1 & allbirds$Season == 2012] # 12

allbirds[allbirds$Ind_ID%in%listbirdsinidivorce2012,]
unpaired2012 <- allbirds$Ind_ID[allbirds$Polystatus=='unpaired']
allbirds[allbirds$Polystatus=='unpaired',]
allbirds[allbirds$Ind_ID%in%unpaired2012 & allbirds$Season == 2013,]


for (i in 1: nrow(allbirds))
{if (allbirds$Ind_ID[i]%in%listbirdsinidivorce2012)
{allbirds$iniDiv2012[i] <- 1}
else{allbirds$iniDiv2012[i] <- 0}
}


# males
# 2012 + 2013
modRelfitnessMalesDivorce <- lm(Relfitness ~ IniDivorce, data = allbirds[allbirds$Sex == 1 & allbirds$TrtDiv == 'Div' ,])
summary(modRelfitnessMalesDivorce)

#2013 (for those that divorced in 2012)
modRelfitnessMales2013Divorce <- lm(Relfitness ~ TrtDiv + iniDiv2012, data = allbirds[allbirds$Sex == 1 & allbirds$Polystatus != 'unpaired' & allbirds$Season == 2013,])
summary(modRelfitnessMales2013Divorce)


# females
# 2012
modRelfitnessFemalesDivorce <- lm(Relfitness ~ IniDivorce, data = allbirds[allbirds$Sex == 0 & allbirds$TrtDiv == 'Div' ,])
summary(modRelfitnessFemalesDivorce)

# 2013
modRelfitnessFemales2013Divorce <- lm(Relfitness ~ Treatment + iniDiv2012, data = allbirds[allbirds$Sex == 0 & allbirds$Polystatus != 'unpaired' & allbirds$Season == 2013,])
summary(modRelfitnessFemales2013Divorce)

}

{### Fitness components in 'Eggs'
head(Eggs)
head(allbirds)


# social pair TrtDiv
for (i in 1:nrow(Eggs))
{if(Eggs$MIDFIDSoc[i]%in%MIDFIDOk)
{Eggs$PairTrtDiv[i] <- as.character(Eggs$MTrt[i])}
else{Eggs$PairTrtDiv[i] <- 'Div'}
}

# genetic pair TrtDiv
for (i in 1:nrow(Eggs))
{if((!is.na(Eggs$EPY[i])) & Eggs$EPY[i] == 0)
	{
	if(Eggs$MIDFIDGen[i]%in%MIDFIDOk)
	{Eggs$GenPairTrtDiv[i] <- as.character(Eggs$FGenTrt[i])}
	else{Eggs$GenPairTrtDiv[i] <- 'Div'}
	}
else{Eggs$GenPairTrtDiv[i] <- NA}
}

## Fate 34 - dead chicks

modAllPairsFate34outof3456 <- glmer(Fate34 ~ -1+PairTrtDiv+scale(Season, scale=FALSE)+poly(HatchOrder, 2) + (1|ClutchID)+ (1|MIDFIDSoc)+(1|MID)+ (1|FID) , data = Eggs[Eggs$EggFate > 2,], family = "binomial")
summary(modAllPairsFate34outof3456)
plot(effect('PairTrtDiv', modAllPairsFate34outof3456))



## Fate 2 - dead embryos

modAllPairsFate2outof23456 <- glmer(Fate2 ~ -1 + GenPairTrtDiv + scale(Season, scale=FALSE) + scale(EggNoClutchAss, scale=FALSE) +(1|ClutchAss)+ (1|MIDFIDGen)+(1|MGen)+ (1|FGen), data = Eggs[Eggs$EggFate > 1,], family = "binomial")
summary(modAllPairsFate2outof23456)
plot(effect('GenPairTrtDiv', modAllPairsFate2outof23456))



head(Eggs[!(is.na(Eggs$GenPairTrtDiv )) & Eggs$GenPairTrtDiv == 'Div',])


## Fate 1 - invalid

modAllPairsFate1 <- glmer(Fate1 ~ -1+PairTrtDiv+scale(Season,scale=FALSE) + scale(EggNoClutch,scale=FALSE)+(1|ClutchID)+(1|MIDFIDSoc)+(1|MID)+ (1|FID), data = Eggs, family = "binomial")
summary(modAllPairsFate1)
plot(effect('PairTrtDiv', modAllPairsFate1))


## Fate 56 - independent offsrping

modAllPairsSoc <- glmer(Fate56 ~ -1+PairTrtDiv+scale(Season, scale=FALSE)+scale(EggNoClutch, scale=FALSE) +(1|MIDFIDSoc)+(1|ClutchID) +(1|FID) +(1|MID) , data = Eggs, family = "binomial")
summary(modAllPairsSoc)
plot(effect('PairTrtDiv', modAllPairsSoc))

}

{### Fitness components in 'clutches'

{# create new clutches tables

{## add data Eggs in table Clutch as YN for each fate for ALL Pairs (Ass or Soc) 

{# Fate0YN : AllMIDFIDass
Eggs_listperAllClutchAssFate0YN <- split(Eggs[Eggs$EggFate != 1 & (is.na(Eggs$EPY) | Eggs$EPY == 0),], Eggs$ClutchAss[Eggs$EggFate != 1 & (is.na(Eggs$EPY) | Eggs$EPY == 0)])
x<-Eggs_listperAllClutchAssFate0YN[[1]]

Eggs_listperAllClutchAssFate0YN_fun = function(x)  {
if (nrow(x[x$EggFate == 0,]) == 0) {return (c(0, nrow(x)))} else{return(c(1, nrow(x)))}
}

Eggs_listperAllClutchAssFate0YN_out1 <- lapply(Eggs_listperAllClutchAssFate0YN, FUN=Eggs_listperAllClutchAssFate0YN_fun)
Eggs_listperAllClutchAssFate0YN_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperAllClutchAssFate0YN_out1)),do.call(rbind, Eggs_listperAllClutchAssFate0YN_out1))

nrow(Eggs_listperAllClutchAssFate0YN_out2)	# 253 (before 216)
rownames(Eggs_listperAllClutchAssFate0YN_out2) <- NULL
colnames(Eggs_listperAllClutchAssFate0YN_out2) <- c('ClutchAss', 'IFYN','ClutchSize')

Eggs$MassTrt <- as.factor(Eggs$MassTrt)

TableAllClutchAssFate0YN <- merge(x=Eggs_listperAllClutchAssFate0YN_out2, y = unique(Eggs[Eggs$EggFate != 1 & is.na(Eggs$EPY) | Eggs$EPY == 0,c('ClutchAss','MassTrt','MIDFIDass','Mass','Fass','Season')]), by.y = 'ClutchAss', by.x = "ClutchAss", all.x=TRUE)

head(TableAllClutchAssFate0YN)
nrow(TableAllClutchAssFate0YN) # 253

sum(TableAllClutchAssFate0YN$IFYN) # 47 (before 39)

}

{# EPY : AllFGenYear

Eggs_listperAllClutchGenEPYYN <- split(Eggs[!is.na(Eggs$FGenYear),], Eggs$ClutchAss[!is.na(Eggs$FGenYear)])
Eggs_listperAllClutchGenEPYYN [[32]]

Eggs_listperAllClutchGenEPYYN_fun = function(x)  {
if (nrow(x[x$EPY == 1,]) == 0) {return (c(0, nrow(x)))} else{return(c(1, nrow(x)))}
}

Eggs_listperAllClutchGenEPYYN_out1 <- lapply(Eggs_listperAllClutchGenEPYYN, FUN=Eggs_listperAllClutchGenEPYYN_fun)
Eggs_listperAllClutchGenEPYYN_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperAllClutchGenEPYYN_out1)),do.call(rbind, Eggs_listperAllClutchGenEPYYN_out1))

nrow(Eggs_listperAllClutchGenEPYYN_out2)	# 289 (before 245)
rownames(Eggs_listperAllClutchGenEPYYN_out2) <- NULL
colnames(Eggs_listperAllClutchGenEPYYN_out2) <- c('ClutchGen', 'EPYYN', 'ClutchSize')

TableAllClutchGenEPYYN <- merge(x=Eggs_listperAllClutchGenEPYYN_out2, y = unique(Eggs[!is.na(Eggs$FGenYear),c('ClutchAss','FGenTrt','FGen','Season')]), by.y = 'ClutchAss', by.x = "ClutchGen", all.x=TRUE)

TableAllClutchGenEPYYN <- TableAllClutchGenEPYYN[!(is.na(TableAllClutchGenEPYYN$FGen)),]

head(TableAllClutchGenEPYYN)
nrow(TableAllClutchGenEPYYN) # 289

sum(TableAllClutchGenEPYYN$EPYYN) # 52 (before 44)

sum(TableAllClutchGenEPYYN$EPYYN[TableAllClutchGenEPYYN$FGenTrt == 'C'])/length(TableAllClutchGenEPYYN$EPYYN[TableAllClutchGenEPYYN$FGenTrt == 'C'])# 0.1180556 (before 0.125 (17))

sum(TableAllClutchGenEPYYN$EPYYN[TableAllClutchGenEPYYN$FGenTrt == 'NC']) /length(TableAllClutchGenEPYYN$EPYYN[TableAllClutchGenEPYYN$FGenTrt == 'NC'])# 0.2413793 (before 0.2477064 (27))
}

{# EPY : AllMGenYear

Eggs_listperAllMGenEPYYN <- split(Eggs[!is.na(Eggs$MGenYear),], Eggs$MGenYear[!is.na(Eggs$MGenYear)])
Eggs_listperAllMGenEPYYN [[1]]

Eggs_listperAllMGenEPYYN_fun = function(x)  {
if (nrow(x[x$EPY == 1,]) == 0) {return (0)} else{return(1)}
}

Eggs_listperAllMGenEPYYN_out1 <- lapply(Eggs_listperAllMGenEPYYN, FUN=Eggs_listperAllMGenEPYYN_fun)
Eggs_listperAllMGenEPYYN_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperAllMGenEPYYN_out1)),do.call(rbind, Eggs_listperAllMGenEPYYN_out1))

nrow(Eggs_listperAllMGenEPYYN_out2)	# 96
rownames(Eggs_listperAllMGenEPYYN_out2) <- NULL
colnames(Eggs_listperAllMGenEPYYN_out2) <- c('MGenYear', 'EPYYN')

TableAllMGenEPYYN <- merge(x=Eggs_listperAllMGenEPYYN_out2, y = unique(Eggs[!is.na(Eggs$MGenYear),c('MGenYear','MGen','MGenTrt','Season')]), by.y = 'MGenYear', by.x = "MGenYear", all.x=TRUE)

head(TableAllMGenEPYYN)
nrow(TableAllMGenEPYYN) # 96

sum(TableAllMGenEPYYN$EPYYN) # 30

sum(TableAllMGenEPYYN$EPYYN[TableAllMGenEPYYN$MGenTrt == 'C'])/length(TableAllMGenEPYYN$EPYYN[TableAllMGenEPYYN$MGenTrt == 'C'])# 0.39 (before 0.3695652 (17))

sum(TableAllMGenEPYYN$EPYYN[TableAllMGenEPYYN$MGenTrt == 'NC']) /length(TableAllMGenEPYYN$EPYYN[TableAllMGenEPYYN$MGenTrt == 'NC'])# 0.23 (before 0.2285714 (8))
}

{# Dumped : AllFIDYear

Eggs_listperAllClutchSocDumpedYN <- split(Eggs[!(is.na(Eggs$FID)) &!(is.na(Eggs$FGen)),], Eggs$ClutchID[!(is.na(Eggs$FID)) &!(is.na(Eggs$FGen))])
Eggs_listperAllClutchSocDumpedYN[[1]]

Eggs_listperAllClutchSocDumpedYN_fun = function(x)  {
if (nrow(x[x$DumpedEgg == 1,]) == 0) {return (c(0, nrow(x)))} else{return(c(1, nrow(x)))}
}

Eggs_listperAllClutchSocDumpedYN_out1 <- lapply(Eggs_listperAllClutchSocDumpedYN, FUN=Eggs_listperAllClutchSocDumpedYN_fun)
Eggs_listperAllClutchSocDumpedYN_out2 <- data.frame(rownames(do.call(rbind,Eggs_listperAllClutchSocDumpedYN_out1)),do.call(rbind, Eggs_listperAllClutchSocDumpedYN_out1))

nrow(Eggs_listperAllClutchSocDumpedYN_out2)	# 244
rownames(Eggs_listperAllClutchSocDumpedYN_out2) <- NULL
colnames(Eggs_listperAllClutchSocDumpedYN_out2) <- c('ClutchID', 'DumpedYN','ClutchSize')

TableAllClutchSocYNDumped <- merge(x=Eggs_listperAllClutchSocDumpedYN_out2, y = unique(Eggs[!(is.na(Eggs$FID)) &!(is.na(Eggs$FGen)),c('ClutchID','FTrt','FID','Season')]), by.y = 'ClutchID', by.x = "ClutchID", all.x=TRUE)

TableAllClutchSocYNDumped <- TableAllClutchSocYNDumped[!(is.na(TableAllClutchSocYNDumped$FID)),]

nrow(TableAllClutchSocYNDumped) # 244
sum(TableAllClutchSocYNDumped$DumpedYN) # 63 (before 55)

}

}

{## add TrtDiv to those tables

# TableAllClutchAssFate0YN
for (i in 1:nrow(TableAllClutchAssFate0YN))
{if(TableAllClutchAssFate0YN$MIDFIDass[i]%in%MIDFIDOk)
{TableAllClutchAssFate0YN$PairTrtDiv[i] <- as.character(TableAllClutchAssFate0YN$MassTrt[i])}
else{TableAllClutchAssFate0YN$PairTrtDiv[i] <- 'Div'}
}

# TableAllClutchGenEPYYN
TableAllClutchGenEPYYN$FGenYear <- paste(TableAllClutchGenEPYYN$FGen,TableAllClutchGenEPYYN$Season, sep="")

for (i in 1:nrow(TableAllClutchGenEPYYN))
{if(TableAllClutchGenEPYYN$FGenYear[i]%in%FIDYearOk)
{TableAllClutchGenEPYYN$FTrtDiv[i] <- as.character(TableAllClutchGenEPYYN$FGenTrt[i])}
else{TableAllClutchGenEPYYN$FTrtDiv[i] <- 'Div'}
}

# TableAllMGenEPYYN
TableAllMGenEPYYN$MGenYear <- paste(TableAllMGenEPYYN$MGen,TableAllMGenEPYYN$Season, sep="")

for (i in 1:nrow(TableAllMGenEPYYN))
{if(TableAllMGenEPYYN$MGenYear[i]%in%MIDYearOk)
{TableAllMGenEPYYN$MTrtDiv[i] <- as.character(TableAllMGenEPYYN$MGenTrt[i])}
else{TableAllMGenEPYYN$MTrtDiv[i] <- 'Div'}
}

# TableAllClutchSocYNDumped
TableAllClutchSocYNDumped$FIDYear <- paste(TableAllClutchSocYNDumped$FID,TableAllClutchSocYNDumped$Season, sep="")

for (i in 1:nrow(TableAllClutchSocYNDumped))
{if(TableAllClutchSocYNDumped$FIDYear[i]%in%FIDYearOk)
{TableAllClutchSocYNDumped$FTrtDiv[i] <- as.character(TableAllClutchSocYNDumped$FTrt[i])}
else{TableAllClutchSocYNDumped$FTrtDiv[i] <- 'Div'}
}
}

}

head(TableAllClutchAssFate0YN)
head(TableAllClutchGenEPYYN)
head(TableAllMGenEPYYN)
head(TableAllClutchSocYNDumped)


{# Fate0YN : AllMIDFID

modAllPairsFate0vs23456YN <- glmer(IFYN ~ -1+PairTrtDiv+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE) +(1|MIDFIDass)+(1|Mass)+(1|Fass), data = TableAllClutchAssFate0YN , family = "binomial")
summary(modAllPairsFate0vs23456YN)	 
plot(effect('PairTrtDiv', modAllPairsFate0vs23456YN))

}

{# EPY : AllFGen

modAllFGenEPYYN <- glmer(EPYYN ~ -1+FTrtDiv+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE)+(1|FGen), data = TableAllClutchGenEPYYN , family = "binomial")
summary(modAllFGenEPYYN)
plot(effect('FTrtDiv', modAllFGenEPYYN))


}

{# EPY : AllMGenYear

modAllMGenEPYYN <- glmer(EPYYN ~ -1+MTrtDiv+scale(Season, scale=FALSE)+ (1|MGen), data = TableAllMGenEPYYN , family = "binomial")
summary(modAllMGenEPYYN)
plot(effect('MTrtDiv', modAllMGenEPYYN))



# add the 4 male-seasons without genetic eggs

length(TableAllMGenEPYYN$MGenYear) # 96
length(allbirds$Ind_ID[allbirds$Sex == 1]) #100
allbirds$IDYear[allbirds$Sex == 1 & !(allbirds$IDYear%in%TableAllMGenEPYYN$MGenYear)] # 111632012 111472012 112532013 112302013

MaleYearNOPaternity <-allbirds[allbirds$IDYear == 111632012 | allbirds$IDYear == 111472012 | allbirds$IDYear == 112532013 | allbirds$IDYear == 112302013 ,c('IDYear','EPYYes','Ind_ID','Treatment','Season')]
colnames(MaleYearNOPaternity) <-colnames(TableMGenEPYYN)
MaleYearNOPaternity$MGenYear <-as.factor(MaleYearNOPaternity$MGenYear)
TableAllMGenEPYYNwithallmales <- rbind(TableMGenEPYYN, MaleYearNOPaternity)

for (i in 1:nrow(TableAllMGenEPYYNwithallmales))
{if(TableAllMGenEPYYNwithallmales$MGenYear[i]%in%MIDYearOk)
{TableAllMGenEPYYNwithallmales$MTrtDiv[i] <- as.character(TableAllMGenEPYYNwithallmales$MGenTrt[i])}
else{TableAllMGenEPYYNwithallmales$MTrtDiv[i] <- 'Div'}
}


modALLMGenALLEPYYN <- glmer(EPYYN ~ -1+MTrtDiv+scale(Season, scale=FALSE)+ (1|MGen), data = TableAllMGenEPYYNwithallmales , family = "binomial")
summary(modALLMGenALLEPYYN)	
plot(effect('MTrtDiv', modALLMGenALLEPYYN))




}

{# dumped : FIDYear%in%FIDYearOk  & !(is.na(Eggs$FGen))

# for clutches with social and genotyped eggs
head(TableClutchSocYNDumped)

# TableClutchSocYNDumped[TableClutchSocYNDumped$FID == 11187 ,] = 3 clutches
# TableClutchSocYNDumped <- TableClutchSocYNDumped[TableClutchSocYNDumped$ClutchID != 369 & TableClutchSocYNDumped$ClutchID != 537 & TableClutchSocYNDumped$ClutchID != 580,]


modPairsOkSocYNDumped <- glmer(DumpedYN ~ FTrt+scale(Season, scale=FALSE)+ scale(ClutchSize,scale=FALSE)+(1|FID), data = TableClutchSocYNDumped , family = "binomial")
summary(modPairsOkSocYNDumped)	# p =  0.58920



mean(unlist(ranef(modPairsOkSocYNDumped)$FID))


modPairsOkSocYNDumped <- glmer(DumpedYN ~ FTrt+scale(Season, scale=FALSE)+(1|FID), data = TableClutchSocYNDumped , family = "binomial")
summary(modPairsOkSocYNDumped)	# p =  0.3605 	(p = 0.3597 if secondary female 11187 excluded)
# 0.4100 (02/06/2014)

invlogit(-1.0862) #  0.2523345 C
invlogit(-1.4348) #  0.1923519 NC
	
	# on 02/06/2014
invlogit(-1.0259) #  0.2638797 C
(invlogit(-1.0259+0.2586)-invlogit(-1.0259)+invlogit(-1.0259)-invlogit(-1.0259-0.2586))/2	#  0.05013913
invlogit(-1.3431) #   0.2070007 NC
(invlogit(-1.3431+0.2934)-invlogit(-1.3431)+invlogit(-1.3431)-invlogit(-1.3431-0.2934))/2	#  0.04817042




sum(TableClutchSocYNDumped$DumpedYN[TableClutchSocYNDumped$FTrt == 'C'])/length(TableClutchSocYNDumped$DumpedYN[TableClutchSocYNDumped$FTrt == 'C'])#  0.2711864 (32)

sum(TableClutchSocYNDumped$DumpedYN[TableClutchSocYNDumped$FTrt == 'NC'])/length(TableClutchSocYNDumped$DumpedYN[TableClutchSocYNDumped$FTrt == 'NC'])#  0.2211538 (23)

}

}

}


{### Relative fitness ~ nb of trauma

head(allbirds)

birdsNC2012 <- allbirds$Ind_ID[allbirds$Season == 2012 &  allbirds$Treatment == 'NC']
birdsC2012 <- allbirds$Ind_ID[allbirds$Season == 2012 &  allbirds$Treatment == 'C']

for (i in 1:nrow(allbirds))
{
if (allbirds$Season[i] == 2012)
	{
	if ( allbirds$Treatment[i] == 'NC') {allbirds$nTrauma[i] <-  1}
	if ( allbirds$Treatment[i] == 'C') {allbirds$nTrauma[i] <- 0}
	}

if (allbirds$Season[i] == 2013)
	{
	if (allbirds$StayYN[i] == 'stay')
		{
		if ( allbirds$Treatment[i] == 'NC') {allbirds$nTrauma[i] <-  1}	
		if ( allbirds$Treatment[i] == 'C') {allbirds$nTrauma[i] <-  0}	
		}
	
	if (allbirds$StayYN[i] == 'new')
		{
		if ( allbirds$Treatment[i] == 'C') 
			if (allbirds$Ind_ID[i]%in%birdsNC2012) {allbirds$nTrauma[i] <-  2}
			if (allbirds$Ind_ID[i]%in%birdsC2012)  {allbirds$nTrauma[i] <-  1}
			
		if ( allbirds$Treatment[i] == 'NC')
			if (allbirds$Ind_ID[i]%in%birdsNC2012) {allbirds$nTrauma[i] <-  3}
			if (allbirds$Ind_ID[i]%in%birdsC2012)  {allbirds$nTrauma[i] <-  2}
		}
	}
}


modRelfitnessMalenbtrauma <- lmer(RelfitnessTrtOk ~ nTrauma+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessMalenbtrauma)

modRelfitnessMalenbtraumawithoutTrauma <- lmer(RelfitnessTrtOk ~ Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
anova(modRelfitnessMalenbtrauma, modRelfitnessMalenbtraumawithoutTrauma)

modRelfitnessMalenbtraumawithoutTrt <- lmer(RelfitnessTrtOk ~ nTrauma+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
anova(modRelfitnessMalenbtrauma, modRelfitnessMalenbtraumawithoutTrt)




modRelfitnessFemalenbtrauma <- lmer(RelfitnessTrtOk ~ nTrauma+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessFemalenbtrauma)


modRelfitnessFealenbtraumawithoutTrauma <- lmer(RelfitnessTrtOk ~ Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
anova(modRelfitnessFemalenbtrauma, modRelfitnessFealenbtraumawithoutTrauma)

modRelfitnessFealenbtraumawithoutTrt <- lmer(RelfitnessTrtOk ~ nTrauma+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
anova(modRelfitnessFemalenbtrauma, modRelfitnessFealenbtraumawithoutTrt)


}




{### GRAPH FITNESS DIFFERENCE

# par(mfrow=c(1,2))  
 
{# real fitness of individuals
modRelfitnessMaleTrtOk <- lmer(RelfitnessTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessMaleTrtOk)	# p =  0.02778
estimatesMales <- coef(summary(modRelfitnessMaleTrtOk))

modRelfitnessFemaleTrtOk <- lmer(RelfitnessTrtOk ~ -1+Treatment +(1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessFemaleTrtOk)	# p = 0.1159
estimatesFemales <- coef(summary(modRelfitnessFemaleTrtOk))

# eMale <- effect('Treatment', modRelfitnessMaleTrtOk)
# edMale <- data.frame(e)
# plot(effect('Treatment', modRelfitnessMaleTrtOk))

par(mar=c(2.5,4.5,1,1))
plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(0.6,1.4), 	
	xlab = "", cex.axis=1.5,
	ylab = "Relative Fitness", cex.lab = 1.5,font.lab=4 )
axis(1, at = 0.75, labels = "Chosen pairs",cex.axis=1.5, font.axis = 2, tick=FALSE)
axis(1, at = 2.25, labels = "Non-Chosen pairs", cex.axis=1.5, font.axis = 2, col.axis="gray48", tick=FALSE)

segments(0.5,estimatesMales[1,1]+estimatesMales[1,2], 0.5,estimatesMales[1,1]-estimatesMales[1,2], col =  "black", lwd=3)
segments(0.45,estimatesMales[1,1]+estimatesMales[1,2], 0.55, estimatesMales[1,1]+estimatesMales[1,2], col =  "black", lwd=3)
segments(0.45,estimatesMales[1,1]-estimatesMales[1,2], 0.55, estimatesMales[1,1]-estimatesMales[1,2], col =  "black", lwd=3)

segments(2,estimatesMales[2,1]+estimatesMales[2,2], 2,estimatesMales[2,1]-estimatesMales[2,2], col = "gray48", lwd=3)
segments(1.95,estimatesMales[2,1]+estimatesMales[2,2], 2.05, estimatesMales[2,1]+estimatesMales[2,2], col =  "gray48", lwd=3)
segments(1.95,estimatesMales[2,1]-estimatesMales[2,2], 2.05, estimatesMales[2,1]-estimatesMales[2,2], col =  "gray48", lwd=3)

segments(1,estimatesFemales[1,1]+estimatesFemales[1,2], 1,estimatesFemales[1,1]-estimatesFemales[1,2],col =  "black", lty=2, lwd=3)
segments(0.95,estimatesFemales[1,1]+estimatesFemales[1,2], 1.05, estimatesFemales[1,1]+estimatesFemales[1,2], col =  "black", lwd=3)
segments(0.95,estimatesFemales[1,1]-estimatesFemales[1,2], 1.05, estimatesFemales[1,1]-estimatesFemales[1,2], col =  "black", lwd=3)

segments(2.5,estimatesFemales[2,1]+estimatesFemales[2,2], 2.5,estimatesFemales[2,1]-estimatesFemales[2,2], col = "gray48",lty=2, lwd=3)
segments(2.45,estimatesFemales[2,1]+estimatesFemales[2,2], 2.55, estimatesFemales[2,1]+estimatesFemales[2,2], col =  "gray48", lwd=3)
segments(2.45,estimatesFemales[2,1]-estimatesFemales[2,2], 2.55, estimatesFemales[2,1]-estimatesFemales[2,2], col =  "gray48", lwd=3)


# arrows(0.5,estimatesMales[1,1]+estimatesMales[1,2], 0.5,estimatesMales[1,1]-estimatesMales[1,2],angle=90, code=3, length=0.05, col =  "black", lwd=2)
# arrows(2,estimatesMales[2,1]+estimatesMales[2,2], 2,estimatesMales[2,1]-estimatesMales[2,2],angle=90, code=3, length=0.05, col = "gray48", lwd=2)
# arrows(1,estimatesFemales[1,1]+estimatesFemales[1,2], 1,estimatesFemales[1,1]-estimatesFemales[1,2],angle=90, code=3, length=0.05, col =  "black", lty=2, lwd=2)
# arrows(2.5,estimatesFemales[2,1]+estimatesFemales[2,2], 2.5,estimatesFemales[2,1]-estimatesFemales[2,2],angle=90, code=3, length=0.05, col = "gray48",lty=2, lwd=2)

points(0.5, estimatesMales[1,1], col = "black", pch=19, cex=2)
points(2, estimatesMales[2,1], col = "gray48", pch=19, cex=2)
points(1, estimatesFemales[1,1], col = "black", pch=19, cex=2)
points(2.5, estimatesFemales[2,1], col = "gray48", pch=19, cex=2)


# points(0.5, estimatesMales[1,1], col = "white", pch=19, cex=2)
# points(0.5, estimatesMales[1,1], col = "black", pch=1, cex=2)
# points(2, estimatesMales[2,1], col =  "white", pch=19, cex=2)
# points(2, estimatesMales[2,1], col = "gray48", pch=1, cex=2)
# points(1, estimatesFemales[1,1], col = "white", pch=19, cex=2)
# points(1, estimatesFemales[1,1], col = "black", pch=1, cex=2)
# points(2.5, estimatesFemales[2,1], col =  "white", pch=19, cex=2)
# points(2.5, estimatesFemales[2,1], col = "gray48", pch=1, cex=2)

arrows(0.5,1.35,2,1.35, length=0, lwd=2)
arrows(1,1.30,2.5,1.3, length=0, lwd=2,lty=2)

text(1.25,1.37,"Males p = 0.03", cex=1.2)
text(1.75,1.28,"Females p = 0.12", cex=1.2)


# text(1.25,1.37,"p = 0.03", cex=1.2)
# text(1.75,1.32,"p = 0.12", cex=1.2)
# text(0.25,1.36,"Males", cex=1.5)
# text(2.80,1.31,"Females", cex=1.5)

abline(1,0, lty=3)



# to create pdf
# pdf(file='fitnessgraphMalika.pdf', width = 3.4, height = 3.4)
# dev.off()
}


{# real fitness of individuals BLACK VERSION
modRelfitnessMaleTrtOk <- lmer(RelfitnessTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessMaleTrtOk)	# p =  0.02778
estimatesMales <- coef(summary(modRelfitnessMaleTrtOk))

modRelfitnessFemaleTrtOk <- lmer(RelfitnessTrtOk ~ -1+Treatment +(1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessFemaleTrtOk)	# p = 0.1159
estimatesFemales <- coef(summary(modRelfitnessFemaleTrtOk))

nrow(allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1 & allbirds$Treatment == 'C',])
nrow(allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1 & allbirds$Treatment == 'NC',])

par(mar=c(2.5,4.5,1,1))
plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(0.6,1.4), 	
	xlab = "", cex.axis=1.5,
	ylab = "Relative fitness", cex.lab = 1.5,font.lab=2 )
axis(1,at = 0.75, labels="")
axis(1, at = 0.75, labels = "Chosen pairs",cex.axis=1.5, font.axis = 2, tick=FALSE)
axis(1,at = 2.25, labels="")
axis(1, at = 2.25, labels = "Non-chosen pairs", cex.axis=1.5, font.axis = 2, col.axis="black", tick=FALSE)

segments(0.5,estimatesMales[1,1]+estimatesMales[1,2], 0.5,estimatesMales[1,1]-estimatesMales[1,2], col =  "black", lwd=3)
segments(0.45,estimatesMales[1,1]+estimatesMales[1,2], 0.55, estimatesMales[1,1]+estimatesMales[1,2], col =  "black", lwd=3)
segments(0.45,estimatesMales[1,1]-estimatesMales[1,2], 0.55, estimatesMales[1,1]-estimatesMales[1,2], col =  "black", lwd=3)

segments(2,estimatesMales[2,1]+estimatesMales[2,2], 2,estimatesMales[2,1]-estimatesMales[2,2], col = "black", lwd=3)
segments(1.95,estimatesMales[2,1]+estimatesMales[2,2], 2.05, estimatesMales[2,1]+estimatesMales[2,2], col =  "black", lwd=3)
segments(1.95,estimatesMales[2,1]-estimatesMales[2,2], 2.05, estimatesMales[2,1]-estimatesMales[2,2], col =  "black", lwd=3)

segments(1,estimatesFemales[1,1]+estimatesFemales[1,2], 1,estimatesFemales[1,1]-estimatesFemales[1,2],col =  "black", lty=2, lwd=3)
segments(0.95,estimatesFemales[1,1]+estimatesFemales[1,2], 1.05, estimatesFemales[1,1]+estimatesFemales[1,2], col =  "black", lwd=3)
segments(0.95,estimatesFemales[1,1]-estimatesFemales[1,2], 1.05, estimatesFemales[1,1]-estimatesFemales[1,2], col =  "black", lwd=3)

segments(2.5,estimatesFemales[2,1]+estimatesFemales[2,2], 2.5,estimatesFemales[2,1]-estimatesFemales[2,2], col = "black",lty=2, lwd=3)
segments(2.45,estimatesFemales[2,1]+estimatesFemales[2,2], 2.55, estimatesFemales[2,1]+estimatesFemales[2,2], col =  "black", lwd=3)
segments(2.45,estimatesFemales[2,1]-estimatesFemales[2,2], 2.55, estimatesFemales[2,1]-estimatesFemales[2,2], col =  "black", lwd=3)

points(0.5, estimatesMales[1,1], col = "black", pch=19, cex=2)
points(2, estimatesMales[2,1], col = "black", pch=19, cex=2)
points(1, estimatesFemales[1,1], col = "white", pch=19, cex=2)
points(1, estimatesFemales[1,1], col = "black", pch=1, cex=2)
points(2.5, estimatesFemales[2,1], col = "white", pch=19, cex=2)
points(2.5, estimatesFemales[2,1], col = "black", pch=1, cex=2)

#arrows(0.5,1.35,2,1.35, length=0, lwd=2)
#arrows(1,1.30,2.5,1.3, length=0, lwd=2,lty=2)

#text(1.25,1.37,"P = 0.03", cex=1.2)
#text(1.75,1.32,"P = 0.12", cex=1.2)
#text(0.25,1.36,"Males", cex=1.5)
#text(2.80,1.31,"Females", cex=1.5)
text(0.75,0.6,"  = 46", cex=1.2)
text(2.25,0.6,"  = 38", cex=1.2)
text(0.6,0.598,"n",font=4, cex=1.2)
text(2.1,0.598,"n",font=4, cex=1.2)

#arrows(0.2,0.8,0.3,0.8, length=0, lwd=2)
#arrows(0.2,0.75,0.3,0.75, length=0, lwd=2,lty=2)
#text(0.35,0.8,"Males", cex=1.5, pos=4)
#text(0.35,0.75,"Females", cex=1.5, pos=4)
points(2, 1.36, col = "black", pch=19, cex=2)
points(2, 1.31, col = "white", pch=19, cex=2)
points(2, 1.31, col = "black", pch=1, cex=2)
text(2.1,1.36,"Males", cex=1.5, pos=4)
text(2.1,1.31,"Females", cex=1.5, pos=4)

abline(1,0, lty=3)



# to create pdf
# pdf(file='fitnessgraphMalika.pdf', width = 3.4, height = 3.4)
# dev.off()
}


{# real fitness of monogamous individuals (excluding polygyous male 11190 and his secondary female 11187)
modRelfitnessmonogMaleTrtOk <- lmer(RelfitnessmonogTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allmalesmonog)
summary(modRelfitnessmonogMaleTrtOk)	# p =  0.02916 *
estimatesmonogMales <- coef(summary(modRelfitnessmonogMaleTrtOk))

modRelfitnessmonogFemaleTrtOk <- lmer(RelfitnessmonogTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allfemalesmonog)
summary(modRelfitnessmonogFemaleTrtOk)	# p = 0.1458
estimatesmonogFemales <- coef(summary(modRelfitnessmonogFemaleTrtOk))

plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(0.6,1.4), 	
	xlab = "Treatment",
	ylab = "Relative Fitness", cex.lab = 1.2,font.lab=4 )
axis(1, at = 0.75, labels = "Chosen pairs",cex.axis=1.2, font.axis = 2)
axis(1, at = 2.25, labels = "Non-Chosen pairs", cex.axis=1.2, font.axis = 2, col.axis="gray48")

arrows(0.5,estimatesmonogMales[1,1]+estimatesmonogMales[1,2], 0.5,estimatesmonogMales[1,1]-estimatesmonogMales[1,2],angle=90, code=3, length=0.05, col =  "black", lwd=2)
arrows(2,estimatesmonogMales[2,1]+estimatesmonogMales[2,2], 2,estimatesmonogMales[2,1]-estimatesmonogMales[2,2],angle=90, code=3, length=0.05, col = "gray48", lwd=2)
arrows(1,estimatesmonogFemales[1,1]+estimatesmonogFemales[1,2], 1,estimatesmonogFemales[1,1]-estimatesmonogFemales[1,2],angle=90, code=3, length=0.05, col =  "black", lty=2, lwd=2)
arrows(2.5,estimatesmonogFemales[2,1]+estimatesmonogFemales[2,2], 2.5,estimatesmonogFemales[2,1]-estimatesmonogFemales[2,2],angle=90, code=3, length=0.05, col = "gray48",lty=2, lwd=2)

points(0.5, estimatesmonogMales[1,1], col = "white", pch=19)
points(0.5, estimatesmonogMales[1,1], col = "black", pch=1)
points(2, estimatesmonogMales[2,1], col =  "white", pch=19)
points(2, estimatesmonogMales[2,1], col = "gray48", pch=1)
points(1, estimatesmonogFemales[1,1], col = "white", pch=19)
points(1, estimatesmonogFemales[1,1], col = "black", pch=1)
points(2.5, estimatesmonogFemales[2,1], col =  "white", pch=19)
points(2.5, estimatesmonogFemales[2,1], col = "gray48", pch=1)

arrows(0.5,1.35,2,1.35, length=0, lwd=1)
arrows(1,1.30,2.5,1.3, length=0, lwd=1,lty=2)
text(1.25,1.37,"p = 0.02916", cex=1)
text(1.75,1.32,"p = 0.1458", cex=1)
text(0.3,1.36,"Males", cex=1)
text(2.7,1.31,"Females", cex=1)
abline(1,0, lty=3)
}

{# only WP fitness of individuals
modRelfitnessWPMaleTrtOk <- lmer(RelfitnessWPTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessWPMaleTrtOk)	# p =  0.02605 *
estimatesWPMales <- coef(summary(modRelfitnessWPMaleTrtOk))

modRelfitnessWPFemaleTrtOk <- lmer(RelfitnessWPTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessWPFemaleTrtOk)	# p =  0.01692 *
estimatesWPFemales <- coef(summary(modRelfitnessWPFemaleTrtOk))

plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(0.6,1.4), 	
	xlab = "Treatment",
	ylab = "Relative WP Fitness", cex.lab = 1.2,font.lab=4 )
axis(1, at = 0.75, labels = "Chosen pairs",cex.axis=1.2, font.axis = 2)
axis(1, at = 2.25, labels = "Non-Chosen pairs", cex.axis=1.2, font.axis = 2, col.axis="gray48")

arrows(0.5,estimatesWPMales[1,1]+estimatesWPMales[1,2], 0.5,estimatesWPMales[1,1]-estimatesWPMales[1,2],angle=90, code=3, length=0.05, col =  "black", lwd=2)
arrows(2,estimatesWPMales[2,1]+estimatesWPMales[2,2], 2,estimatesWPMales[2,1]-estimatesWPMales[2,2],angle=90, code=3, length=0.05, col = "gray48", lwd=2)
arrows(1,estimatesWPFemales[1,1]+estimatesWPFemales[1,2], 1,estimatesWPFemales[1,1]-estimatesWPFemales[1,2],angle=90, code=3, length=0.05, col =  "black", lty=2, lwd=2)
arrows(2.5,estimatesWPFemales[2,1]+estimatesWPFemales[2,2], 2.5,estimatesWPFemales[2,1]-estimatesWPFemales[2,2],angle=90, code=3, length=0.05, col = "gray48",lty=2, lwd=2)

points(0.5, estimatesWPMales[1,1], col = "white", pch=19)
points(0.5, estimatesWPMales[1,1], col = "black", pch=1)
points(2, estimatesWPMales[2,1], col =  "white", pch=19)
points(2, estimatesWPMales[2,1], col = "gray48", pch=1)
points(1, estimatesWPFemales[1,1], col = "white", pch=19)
points(1, estimatesWPFemales[1,1], col = "black", pch=1)
points(2.5, estimatesWPFemales[2,1], col =  "white", pch=19)
points(2.5, estimatesWPFemales[2,1], col = "gray48", pch=1)

arrows(0.5,1.35,2,1.35, length=0, lwd=1)
arrows(1,1.30,2.5,1.3, length=0, lwd=1,lty=2)
text(1.25,1.37,"p = 0.026", cex=1)
text(1.75,1.32,"p = 0.017", cex=1)
text(0.3,1.36,"Males", cex=1)
text(2.7,1.31,"Females", cex=1)
abline(1,0, lty=3)
}

{# only WP fitness of monogamous individuals (excluding polygyous male 11190 and his secondary female 11187)
modRelfitnessWPmonogMaleTrtOk <- lmer(RelfitnessWPTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allmalesmonog)
summary(modRelfitnessWPmonogMaleTrtOk)
estimatesWPmonogMales <- coef(summary(modRelfitnessWPmonogMaleTrtOk))

modRelfitnessWPmonogFemaleTrtOk <- lmer(RelfitnessWPTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allfemalesmonog)
summary(modRelfitnessWPmonogFemaleTrtOk)
estimatesWPmonogFemales <- coef(summary(modRelfitnessWPmonogFemaleTrtOk))

plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(0.6,1.4), 	
	xlab = "Treatment",
	ylab = "Relative WP Fitness", cex.lab = 1.2,font.lab=4 )
axis(1, at = 0.75, labels = "Chosen pairs",cex.axis=1.2, font.axis = 2)
axis(1, at = 2.25, labels = "Non-Chosen pairs", cex.axis=1.2, font.axis = 2, col.axis="gray48")

arrows(0.5,estimatesWPmonogMales[1,1]+estimatesWPmonogMales[1,2], 0.5,estimatesWPmonogMales[1,1]-estimatesWPmonogMales[1,2],angle=90, code=3, length=0.05, col =  "black", lwd=2)
arrows(2,estimatesWPmonogMales[2,1]+estimatesWPmonogMales[2,2], 2,estimatesWPmonogMales[2,1]-estimatesWPmonogMales[2,2],angle=90, code=3, length=0.05, col = "gray48", lwd=2)
arrows(1,estimatesWPmonogFemales[1,1]+estimatesWPmonogFemales[1,2], 1,estimatesWPmonogFemales[1,1]-estimatesWPmonogFemales[1,2],angle=90, code=3, length=0.05, col =  "black", lty=2, lwd=2)
arrows(2.5,estimatesWPmonogFemales[2,1]+estimatesWPmonogFemales[2,2], 2.5,estimatesWPmonogFemales[2,1]-estimatesWPmonogFemales[2,2],angle=90, code=3, length=0.05, col = "gray48",lty=2, lwd=2)

points(0.5, estimatesWPmonogMales[1,1], col = "white", pch=19)
points(0.5, estimatesWPmonogMales[1,1], col = "black", pch=1)
points(2, estimatesWPmonogMales[2,1], col =  "white", pch=19)
points(2, estimatesWPmonogMales[2,1], col = "gray48", pch=1)
points(1, estimatesWPmonogFemales[1,1], col = "white", pch=19)
points(1, estimatesWPmonogFemales[1,1], col = "black", pch=1)
points(2.5, estimatesWPmonogFemales[2,1], col =  "white", pch=19)
points(2.5, estimatesWPmonogFemales[2,1], col = "gray48", pch=1)

arrows(0.5,1.35,2,1.35, length=0, lwd=1)
arrows(1,1.30,2.5,1.3, length=0, lwd=1,lty=2)
text(1.25,1.37,"p = 0.02502", cex=1)
text(1.75,1.32,"p = 0.02473", cex=1)
text(0.3,1.36,"Males", cex=1)
text(2.7,1.31,"Females", cex=1)
abline(1,0, lty=3)
}


}

{### GRAPH FITNESS DIFFERENCE for poster version yellow

# real fitness of individuals
modRelfitnessMaleTrtOk <- lmer(RelfitnessTrtOk ~ -1+Treatment+ (1|Ind_ID) + (1|PartnerID)+ (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 1,])
summary(modRelfitnessMaleTrtOk)	# p =  0.02778
estimatesMales <- coef(summary(modRelfitnessMaleTrtOk))

modRelfitnessFemaleTrtOk <- lmer(RelfitnessTrtOk ~ -1+Treatment +(1|Ind_ID)+ (1|PartnerID) + (1|MIDFID), data = allbirds[allbirds$Divorce == 0 & allbirds$Sex == 0,])
summary(modRelfitnessFemaleTrtOk)	# p = 0.1159
estimatesFemales <- coef(summary(modRelfitnessFemaleTrtOk))

# eMale <- effect('Treatment', modRelfitnessMaleTrtOk)
# edMale <- data.frame(e)
# plot(effect('Treatment', modRelfitnessMaleTrtOk))

plot(NULL,
	xlim = c(0,3),
	xaxt = "n",	
	ylim = c(0.6,1.4), 	
	xlab = "",
	ylab = "", cex.lab = 1.2,font.lab=4 )
axis(1, at = 0.75, labels = "",cex.axis=1.2, font.axis = 2)
axis(1, at = 2.25, labels = "", cex.axis=1.2, font.axis = 2)

arrows(0.5,estimatesMales[1,1]+estimatesMales[1,2], 0.5,estimatesMales[1,1]-estimatesMales[1,2],angle=90, code=3, length=0.05, col =  colors()[555], lwd=3)
arrows(2,estimatesMales[2,1]+estimatesMales[2,2], 2,estimatesMales[2,1]-estimatesMales[2,2],angle=90, code=3, length=0.05, col = colors()[76], lwd=3)
arrows(1,estimatesFemales[1,1]+estimatesFemales[1,2], 1,estimatesFemales[1,1]-estimatesFemales[1,2],angle=90, code=3, length=0.05, col =  colors()[555], lty=2, lwd=3)
arrows(2.5,estimatesFemales[2,1]+estimatesFemales[2,2], 2.5,estimatesFemales[2,1]-estimatesFemales[2,2],angle=90, code=3, length=0.05, col = colors()[76],lty=2, lwd=3)

points(0.5, estimatesMales[1,1], col = "white", pch=19, cex=1.5)
points(0.5, estimatesMales[1,1], col = colors()[555], pch=1, cex=1.5)
points(2, estimatesMales[2,1], col =  "white", pch=19, cex=1.5)
points(2, estimatesMales[2,1], col = colors()[76], pch=1, cex=1.5)
points(1, estimatesFemales[1,1], col = "white", pch=19, cex=1.5)
points(1, estimatesFemales[1,1], col = colors()[555], pch=1, cex=1.5)
points(2.5, estimatesFemales[2,1], col =  "white", pch=19, cex=1.5)
points(2.5, estimatesFemales[2,1], col = colors()[76], pch=1, cex=1.5)

arrows(0.5,1.35,2,1.35, length=0, lwd=1)
arrows(1,1.30,2.5,1.3, length=0, lwd=1,lty=2)
text(1.25,1.37,"p = 0.028", cex=1)
text(1.75,1.32,"p = 0.116", cex=1)
abline(1,0, lty=3)
}




	##################################################
	## 	     GLMER Models on tables pairs1213 	    ##			        ( > include only breeding pairs) 
	##################################################

head(pairs1213)	
	
{# infertility - EPP
pairs1213forsunflowerplot <- pairs1213[complete.cases(pairs1213[, c("percFate0outof023456","percFassEP" )]),]
sunflowerplot(pairs1213forsunflowerplot$percFate0outof023456,pairs1213forsunflowerplot$percFassEP)
head(Eggs[complete.cases(Eggs$FTrt)& Eggs$FTrt == 'stay',])
cor.test(pairs1213$percFate0outof023456,pairs1213$percFassEP,method = "spearman")
hist(pairs1213$percFate0outof023456)
hist(pairs1213$percFassEP)
mean(pairs1213$percFate0outof023456, na.rm=T)
mean(pairs1213$percFassEP, na.rm=T)

infertilitycbind <- cbind(pairs1213$sumFate0MIDFIDass,pairs1213$sumFate23456WP)
EPPcbind <- cbind(pairs1213$sumFate23456FassEP,pairs1213$sumFate23456WP) 
modInfertilityEPP <- glm(infertilitycbind~EPPcbind, family='binomial')
summary(modInfertilityEPP)


for (i in 1:nrow(pairs1213)){
if(pairs1213$sumFate23456FassEP[i] > 0) {pairs1213$FassEPYN[i] <- 1}
else {pairs1213$FassEPYN[i] <- 0}
}

breedingpairs1213 <- pairs1213[pairs1213$sumFate0MIDFIDass != 0 | pairs1213$sumFate23456WP != 0 | pairs1213$sumFate23456FassEP!=0,]
nrow(breedingpairs1213)
infertilitycbind <- cbind(breedingpairs1213$sumFate0MIDFIDass,breedingpairs1213$sumFate23456WP)

modInfertilityEPPYN <- glm(infertilitycbind~FassEPYN, data= breedingpairs1213, family='binomial')
summary(modInfertilityEPPYN)	# p = 0.223


pairs1213TrtOk <- pairs1213[pairs1213$FIDYear%in%FIDYearOk & (pairs1213$sumFate0MIDFIDass != 0 | pairs1213$sumFate23456WP != 0 | pairs1213$sumFate23456FassEP!=0),]
nrow(pairs1213TrtOk)
infertilitycbind <- cbind(pairs1213TrtOk$sumFate0MIDFIDass,pairs1213TrtOk$sumFate23456WP)

modInfertilityEPPYN <- glm(infertilitycbind~FassEPYN, data= pairs1213TrtOk, family='binomial')
summary(modInfertilityEPPYN)	# p = 0.144 

pairs1213[pairs1213$FIDYear%in%FIDYearOk & pairs1213$sumFate23456WP == 0,]


}


head(TableChickMortalityvsEPPYN)

{# Chick Mortality in Social clutch vs EPP YN in Genetic Clutch (exclude clutches with only dumped eggs)

chickmortalitycbind <- cbind(TableChickMortalityvsEPPYN$Fate34, TableChickMortalityvsEPPYN$Fate56)
TableChickMortalityvsEPPYN$EPYYN <- as.factor(TableChickMortalityvsEPPYN$EPYYN)

modChickMortalityEPPYN <- glmer(chickmortalitycbind~ -1+EPYYN+MTrt+scale(Season, scale=FALSE)+ (1|ClutchAss)+(1|MIDFIDSoc) + (1|MID) + (1|FID), data= TableChickMortalityvsEPPYN, family='binomial')
summary(modChickMortalityEPPYN)	# p = 0.56153   #on 22/05/2015: p = 0.33 ????????????????????????????

invlogit(-0.4924)	# EPY No 0.3793284
invlogit(-0.7514)	# EPY Yes 0.3205163

#on 22/05/2005 ????????????????????????????
invlogit(-0.7671)	# EPY No 0.3171068
invlogit(-0.3019)	# EPY Yes 0.4250931

}






	##################################################
	## 			LMER Models on AllCourt             ##				> only video courtships: Resp ~ Male discriminant score     
{	##################################################

head(AllCourt)	
	
{# as.factor
AllCourt$FID <- factor(AllCourt$FID)
AllCourt$MID <- factor(AllCourt$MID)
AllCourt$FIDMID <- factor(AllCourt$FIDMID)
AllCourt$FWEU <- factor(AllCourt$FWEU)
#AllCourt$Year <- factor(AllCourt$Year)
AllCourt$Year <- as.numeric(AllCourt$Year)
AllCourt$FTrt <- as.factor(AllCourt$FTrt)
AllCourt$MTrt <- as.factor(AllCourt$MTrt)
#?  AllCourt$RespPos <- as.factor(AllCourt$RespPos)
}

{# hist
hist(AllCourt$Fdayspaired)
hist(AllCourt$RespPos)
hist(AllCourt$Resp)

nrow(AllCourt)
nrow(AllCourt[AllCourt$FWEU == 'WP',])#2195
nrow(AllCourt[AllCourt$FWEU == 'EP',])#2400
}


{### Resp ~ Male discriminant score

{# discrimant score of males

modMDiscrim2012 <-lmer(Resp~ FWEU + RelDayMod + scale(RelTime)+ nEggsLayedLast5Days + Fdayspaired + Year + Mdiscrim2012 + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourt, na.action=na.exclude,REML=FALSE) 
summary(modMDiscrim2012)

modMDiscrim2013 <-lmer(Resp~ FWEU + RelDayMod + scale(RelTime)+ nEggsLayedLast5Days + Fdayspaired + Year + Mdiscrim2013 + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourt, na.action=na.exclude,REML=FALSE)   
summary(modMDiscrim2013)

modmeanDiscrim <-lmer(Resp~ FWEU + RelDayMod + scale(RelTime)+ nEggsLayedLast5Days + Fdayspaired + Year + MeanMdiscrim + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourt, na.action=na.exclude,REML=FALSE) 
summary(modmeanDiscrim)
}

{# repeatability male attractiveness in the two years. ranefMID in the model Resp

AllCourt2012 <- subset(AllCourt, AllCourt$Year == 2012)
nrow(AllCourt2012)
AllCourt2012[AllCourt2012$FWEU == 'UP',]

m12012MDiscrim2012 <-lmer(Resp~ FWEU + RelDayMod + scale(RelTime)+ nEggsLayedLast5Days + Fdayspaired +(1|MID)+(1|FID)+(1|FIDMID),data= AllCourt2012, na.action=na.exclude,REML=FALSE)
summary(m12012MDiscrim2012)
ranef(m12012MDiscrim2012)

AllCourt2013 <- subset(AllCourt, AllCourt$Year == 2013)
nrow(AllCourt2013)

m12013MDiscrim2012 <-lmer(Resp~FWEU + RelDayMod + scale(RelTime)+ nEggsLayedLast5Days + Fdayspaired +(1|MID)+(1|FID)+(1|FIDMID),data= AllCourt2013, na.action=na.exclude,REML=FALSE)
summary(m12013MDiscrim2012)
ranef(m12013MDiscrim2012)

sd(unlist(ranef(m12012MDiscrim2012)$MID))	# 0.04699127
sd(unlist(ranef(m12013MDiscrim2012)$MID))	# 0.03284994

males2012 <- as.data.frame(sort(unique(AllCourt$MID[AllCourt$Year == 2012])))
ranef2012 <- as.data.frame(unlist(ranef(m12012MDiscrim2012)$MID))
tableranefs2012 <- cbind (males2012, ranef2012)
colnames(tableranefs2012)[1] <- "males2012"
colnames(tableranefs2012)[2] <- "ranef2012"

males2013 <- as.data.frame(sort(unique(AllCourt$MID[AllCourt$Year == 2013])))
ranef2013 <- as.data.frame(unlist(ranef(m12013MDiscrim2012)$MID))
tableranefs2013 <- cbind (males2013, ranef2013)
colnames(tableranefs2013)[1] <- "males2013"
colnames(tableranefs2013)[2] <- "ranef2013"

for (i in 1:nrow(tableranefs2012)){
if (tableranefs2012$males2012[i]%in%tableranefs2013$males2013) {tableranefs2012$ranef2013[i] <- tableranefs2013$ranef2013[tableranefs2013$males2013 == tableranefs2012$males2012[i]]}
else {tableranefs2012$ranef2013[i] <- NA}
}

tableranefs2012

plot(tableranefs2012$ranef2012, tableranefs2012$ranef2013)
abline(0,1, lty = 4)
abline(lm(tableranefs2012$ranef2013 ~ tableranefs2012$ranef2012), col = "red")
cor.test(tableranefs2012$ranef2012, tableranefs2012$ranef2013)
}

{# Female discrimination at the unpaired stage

nrow(AllCourt[AllCourt$FWEU == "UP",])	#323
nrow(AllCourt[AllCourt$FWEU == "UP" & !is.na(AllCourt$Mdiscrim2013),])	#250

AllCourtFUP <- subset(AllCourt, AllCourt$FWEU == "UP" & !is.na(AllCourt$Mdiscrim2013))
nrow(AllCourtFUP)

modFUPMdiscrim2012 <-lmer(Resp~ RelDayMod + scale(RelTime)+ nEggsLayedLast5Days + Year + Mdiscrim2012 +(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFUP, na.action=na.exclude,REML=FALSE)   
summary(modFUPMdiscrim2012)

modFUPMdiscrim2013 <-lmer(Resp~ RelDayMod + scale(RelTime)+ nEggsLayedLast5Days + Year + Mdiscrim2013 +(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFUP, na.action=na.exclude,REML=FALSE)   
summary(modFUPMdiscrim2013)

modFUPmeanMDiscrim <-lmer(Resp~ RelDayMod + scale(RelTime)+ nEggsLayedLast5Days  + Year +MeanMdiscrim+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFUP, na.action=na.exclude,REML=FALSE)   
summary(modFUPmeanMDiscrim)
}

}

{### Resp ~ Trt
	
{# Females that kept the Trt, WP

AllCourtFemaleTrtOkWP <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP")
nrow(AllCourt)	#4918
nrow(AllCourtFemaleTrtOkWP)	#1942

modRespFemaleTrtOkWP <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkWP,REML=FALSE)   
summary(modRespFemaleTrtOkWP)

# 2.026e-01 C
# 3.440e-02 NC

modRespFemaleTrtOkWPwithoutTrt <-lmer(Resp~scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) +(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkWP,REML=FALSE)     
summary(modRespFemaleTrtOkWPwithoutTrt)

anova(modRespFemaleTrtOkWP,modRespFemaleTrtOkWPwithoutTrt)	# p = 0.01462 *


	{# model assumptions checking
	qqnorm(resid(modRespFemaleTrtOkWP)) 
	qqline(resid(modRespFemaleTrtOkWP))
	qqnorm(unlist(ranef(modRespFemaleTrtOkWP)))
	qqline(unlist(ranef(modRespFemaleTrtOkWP)))
	plot(fitted(modRespFemaleTrtOkWP), resid(modRespFemaleTrtOkWP))
	abline(h=0)
	scatter.smooth(AllCourtFemaleTrtOkWP$RelDayMod, resid(modRespFemaleTrtOkWP))
	scatter.smooth(AllCourtFemaleTrtOkWP$RelTime,resid(modRespFemaleTrtOkWP))
	plot(AllCourtFemaleTrtOkWP$nEggsLayedLast5Days,resid(modRespFemaleTrtOkWP))
	scatter.smooth(AllCourtFemaleTrtOkWP$Fdayspaired,resid(modRespFemaleTrtOkWP))
	plot(AllCourtFemaleTrtOkWP$Year,resid(modRespFemaleTrtOkWP))	
	plot(AllCourtFemaleTrtOkWP$FTrt,resid(modRespFemaleTrtOkWP))
}

	{# average resp WP Female Trt Ok
	mean(AllCourtFemaleTrtOkWP$Resp[AllCourtFemaleTrtOkWP$FTrt == 'C'])# 0.1683519
	mean(AllCourtFemaleTrtOkWP$Resp[AllCourtFemaleTrtOkWP$FTrt == 'NC'])# 0.04512067
}

{# limited to the fertile period

AllCourtFemaleTrtOkWPFertile <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP" & RelDayMod <5)
nrow(AllCourtFemaleTrtOkWPFertile)	# 1204

modRespFemaleTrtOkWPFertile <-lmer(Resp~ -1+FTrt + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkWPFertile,REML=FALSE)   
summary(modRespFemaleTrtOkWPFertile)

# 2.058e-01 C
# 3.053e-03 NC

modRespFemaleTrtOkWPFertilewithoutTrt <-lmer(Resp~ scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkWPFertile,REML=FALSE)   
summary(modRespFemaleTrtOkWPFertilewithoutTrt)

anova(modRespFemaleTrtOkWPFertile,modRespFemaleTrtOkWPFertilewithoutTrt)	# p = 0.006717 **
}

{# excluding secondary female 11187

# AllCourt[AllCourt$FID == 11187 & AllCourt$FWEU =="EP",]
AllCourtFemalemonogTrtOkWP <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP" & AllCourt$FID != 11187 )
nrow(AllCourtFemalemonogTrtOkWP)	#1937

modRespFemalemonogTrtOkWP <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemalemonogTrtOkWP,REML=FALSE)   
summary(modRespFemalemonogTrtOkWP)

modRespFemalemonogTrtOkWPwithoutTrt <-lmer(Resp~scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) +(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemalemonogTrtOkWP,REML=FALSE)     
summary(modRespFemalemonogTrtOkWPwithoutTrt)

anova(modRespFemalemonogTrtOkWP,modRespFemalemonogTrtOkWPwithoutTrt)	# p =  0.007388 **
}

{# limited to the fertile period and excluding secondary female 11187

AllCourtFemalemonogTrtOkWPFertile <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP" & RelDayMod <5 & AllCourt$FID != 11187)
nrow(AllCourtFemalemonogTrtOkWPFertile)	# 1201

modRespFemalemonogTrtOkWPFertile <-lmer(Resp~ -1+FTrt + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemalemonogTrtOkWPFertile,REML=FALSE)   
summary(modRespFemalemonogTrtOkWPFertile)

modRespFemalemonogTrtOkWPFertilewithoutTrt <-lmer(Resp~ scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemalemonogTrtOkWPFertile,REML=FALSE)   
summary(modRespFemalemonogTrtOkWPFertilewithoutTrt)

anova(modRespFemalemonogTrtOkWPFertile,modRespFemalemonogTrtOkWPFertilewithoutTrt)	# p = 0.004327 **
}

}

{# Females that kept the Trt, EP
AllCourtFemaleTrtOkEP <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="EP")
nrow(AllCourt)	#4918
nrow(AllCourtFemaleTrtOkEP)	#2023

modRespFemaleTrtOkEP <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkEP,REML=FALSE)   
summary(modRespFemaleTrtOkEP)

#-5.062e-01 C
#-4.956e-01 NC

modRespFemaleTrtOkEPwithoutTrt <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkEP, na.action=na.exclude,REML=FALSE)   
summary(modRespFemaleTrtOkEPwithoutTrt)

anova(modRespFemaleTrtOkEP ,modRespFemaleTrtOkEPwithoutTrt )	# p = 0.6828



modRespFemaleTrtOkEPwithMTrt <-lmer(Resp~ FTrt * MTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkEP,REML=FALSE)   
summary(modRespFemaleTrtOkEPwithMTrt)


	{# model assumptions checking
	qqnorm(resid(modRespFemaleTrtOkEP)) # !! AWFUL !!
	qqline(resid(modRespFemaleTrtOkEP))
	qqnorm(unlist(ranef(modRespFemaleTrtOkEP)))
	qqline(unlist(ranef(modRespFemaleTrtOkEP)))
	plot(fitted(modRespFemaleTrtOkEP), resid(modRespFemaleTrtOkEP)) # !! AWFUL !!
	abline(h=0)
	scatter.smooth(AllCourtFemaleTrtOkEP$RelDayMod, resid(modRespFemaleTrtOkEP))
	scatter.smooth(AllCourtFemaleTrtOkEP$RelTime,resid(modRespFemaleTrtOkEP))
	plot(AllCourtFemaleTrtOkEP$nEggsLayedLast5Days,resid(modRespFemaleTrtOkEP))
	scatter.smooth(AllCourtFemaleTrtOkEP$Fdayspaired,resid(modRespFemaleTrtOkEP))
	plot(AllCourtFemaleTrtOkEP$Year,resid(modRespFemaleTrtOkEP))	
	plot(AllCourtFemaleTrtOkEP$FTrt,resid(modRespFemaleTrtOkEP))
}

	{# average resp EP Female Trt Ok
	mean(AllCourtFemaleTrtOkEP$Resp[AllCourtFemaleTrtOkEP$FTrt == 'C'])#  -0.5154968
	mean(AllCourtFemaleTrtOkEP$Resp[AllCourtFemaleTrtOkEP$FTrt == 'NC'])# -0.4573434
}

{# excluding secondary female 11187

AllCourtFemalemonogTrtOkEP <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="EP" & AllCourt$FID != 11187 )
nrow(AllCourtFemalemonogTrtOkEP)	#1978

modRespFemalemonogTrtOkEP <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemalemonogTrtOkEP,REML=FALSE)   
summary(modRespFemalemonogTrtOkEP)

modRespFemalemonogTrtOkEPwithoutTrt <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemalemonogTrtOkEP, na.action=na.exclude,REML=FALSE)   
summary(modRespFemalemonogTrtOkEPwithoutTrt)

anova(modRespFemalemonogTrtOkEP ,modRespFemalemonogTrtOkEPwithoutTrt )	# p = 0.6648

}
}
}

{### Successful WPCop ~ Trt

{# Females Trt ok
AllCourtFemaleTrtOkWP <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP")

modWPCopFTrtOk <-glmer(succYN~ FTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE)+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkWP, family = "binomial")   
summary(modWPCopFTrtOk)	# p = 0.10472

invlogit( -1.224) # 23% C
invlogit(-1.608) # 17 % NC

	{# model assumptions checking
	qqnorm(resid(modWPCopFTrtOk )) # !! AWFUL !!
	qqline(resid(modWPCopFTrtOk ))
	qqnorm(unlist(ranef(modWPCopFTrtOk ))) 
	qqline(unlist(ranef(modWPCopFTrtOk )))
	plot(fitted(modWPCopFTrtOk ), resid(modWPCopFTrtOk )) # !! AWFUL !!
	abline(h=0)
	scatter.smooth(AllCourtFemaleTrtOkWP$RelDayMod, resid(modWPCopFTrtOk ))
	scatter.smooth(AllCourtFemaleTrtOkWP$RelTime,resid(modWPCopFTrtOk ))
	plot(AllCourtFemaleTrtOkWP$nEggsLayedLast5Days,resid(modWPCopFTrtOk ))
	scatter.smooth(AllCourtFemaleTrtOkWP$Fdayspaired,resid(modWPCopFTrtOk ))
	plot(AllCourtFemaleTrtOkWP$Year,resid(modWPCopFTrtOk ))	
	plot(AllCourtFemaleTrtOkWP$FTrt,resid(modWPCopFTrtOk ))
}

	{# percentage succYN Female Trt Ok
	sum(AllCourtFemaleTrtOkWP$succYN)# 407

	sum(AllCourtFemaleTrtOkWP$succYN[AllCourtFemaleTrtOkWP$FTrt == 'C'])/length(AllCourtFemaleTrtOkWP$succYN[AllCourtFemaleTrtOkWP$FTrt == 'C'])# 24% C
	
	sum(AllCourtFemaleTrtOkWP$succYN[AllCourtFemaleTrtOkWP$FTrt == 'NC'])/length(AllCourtFemaleTrtOkWP$succYN[AllCourtFemaleTrtOkWP$FTrt == 'NC'])# 18% NC
}

{# excluding secondary female 11187
AllCourtFemalemonogTrtOkWP <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP"& AllCourt$FID != 11187 )

modWPCopFmonogTrtOk <-glmer(succYN~ FTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE)+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemalemonogTrtOkWP, family = "binomial")   
summary(modWPCopFmonogTrtOk)	# p = 0.06605 .

}
}
}

{### Successful WPCop when fertile ~ Trt

{# Females Trt ok
AllCourtFemaleTrtOkWPFert <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP" & AllCourt$RelDayMod != 5)

modWPCopFTrtOkFert <-glmer(succYN~ -1+FTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE)+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemaleTrtOkWPFert, family = "binomial")   
summary(modWPCopFTrtOkFert)	# p = 0.0455 *

invlogit(-1.154) # 24% C
invlogit(-1.702) # 15 % NC

	{# percentage succYN Female Trt Ok when fertile
	sum(AllCourtFemaleTrtOkWPFert$succYN)# 260

	sum(AllCourtFemaleTrtOkWPFert$succYN[AllCourtFemaleTrtOkWPFert$FTrt == 'C'])/length(AllCourtFemaleTrtOkWPFert$succYN[AllCourtFemaleTrtOkWPFert$FTrt == 'C'])# 25% C
	
	sum(AllCourtFemaleTrtOkWPFert$succYN[AllCourtFemaleTrtOkWPFert$FTrt == 'NC'])/length(AllCourtFemaleTrtOkWPFert$succYN[AllCourtFemaleTrtOkWPFert$FTrt == 'NC'])# 17% NC
}


unique(AllCourtFemaleTrtOkWP$FIDMID)[!(unique(AllCourtFemaleTrtOkWP$FIDMID)%in%(unique(AllCourtFemaleTrtOkWPFert$FIDMID)))]
#  "1116511147" "1122011202" "1116511253"

AllCourt[AllCourt$FIDMID == 1116511147,]	# C
AllCourt[AllCourt$FIDMID == 1116511253,]	# NC		>>>> female hopps on the back of the male *6
AllCourt[AllCourt$FIDMID == 1122011202,]	# C

{# excluding secondary female 11187
AllCourtFemalemonogTrtOkWPFert <- subset (AllCourt, AllCourt$FDivorced == 0 & AllCourt$FWEU =="WP" & AllCourt$RelDayMod != 5& AllCourt$FID != 11187)

modWPCopFmonogTrtOkFert <-glmer(succYN~ FTrt + scale(RelDayMod,scale=FALSE) + scale(RelTime,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE)+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtFemalemonogTrtOkWPFert, family = "binomial")   
summary(modWPCopFmonogTrtOkFert)	# p = 0.03306 *
}
}
}

{### Successful EPCop for each ID ~ Trt

{# Females Trt Ok


head(TableFemaleTrtOkSuccEPperfemale)

# TableFemaleTrtOkSuccEPperfemale <- TableFemaleTrtOkSuccEPperfemale[TableFemaleTrtOkSuccEPperfemale$FIDyr != 111872012,]

modEPCopYNFTrtOkperfemale <-glmer(succYN~ FTrt + scale(Year,scale=FALSE) +scale(NbCourt, scale=FALSE)+(1|FID),data= TableFemaleTrtOkSuccEPperfemale, family = "binomial")   
summary(modEPCopYNFTrtOkperfemale)	# p = 0.1520 	(for NbCourt: p = 0.0228 *)		( p = 0.2360 if secondary female 11187 excluded)

invlogit(-2.63540) # 0.06689459 C
invlogit(-1.62420) # 0.1646265 NC

	{# percentage FIDMIDsuccYN Female Trt Ok
	sum(TableFemaleTrtOkSuccEPperfemale$succYN)# 11

	sum(TableFemaleTrtOkSuccEPperfemale$succYN[TableFemaleTrtOkSuccEPperfemale$FTrt == 'C'])/length(TableFemaleTrtOkSuccEPperfemale$succYN[TableFemaleTrtOkSuccEPperfemale$FTrt == 'C'])# 0.08695652(4)
	
	sum(TableFemaleTrtOkSuccEPperfemale$succYN[TableFemaleTrtOkSuccEPperfemale$FTrt == 'NC'])/length(TableFemaleTrtOkSuccEPperfemale$succYN[TableFemaleTrtOkSuccEPperfemale$FTrt == 'NC'])# 0.1842105 NC (7)
}

}

{# Males Trt Ok

head(TableMaleTrtOkSuccEPperMale)

# TableMaleTrtOkSuccEPperMale <- TableMaleTrtOkSuccEPperMale[TableMaleTrtOkSuccEPperMale$MIDyr != 111902012,]


modEPCopYNMTrtOkperMale <-glmer(succYN~ MTrt + scale(Year,scale=FALSE) +scale(NbCourt, scale=FALSE)+(1|MID),data= TableMaleTrtOkSuccEPperMale, family = "binomial")   
summary(modEPCopYNMTrtOkperMale)	# p = 0.675102	(p = 0.518982 if polygynous male 11190 excluded)

invlogit(-1.63782) # 0.1627619 C
invlogit(-1.91100) # 0.1288685 NC

	{# percentage FIDMIDsuccYN Female Trt Ok
	sum(TableMaleTrtOkSuccEPperMale$succYN)# 15

	sum(TableMaleTrtOkSuccEPperMale$succYN[TableMaleTrtOkSuccEPperMale$MTrt == 'C'])/length(TableMaleTrtOkSuccEPperMale$succYN[TableMaleTrtOkSuccEPperMale$MTrt == 'C'])# 0.1956522(9)
	
	sum(TableMaleTrtOkSuccEPperMale$succYN[TableMaleTrtOkSuccEPperMale$MTrt == 'NC'])/length(TableMaleTrtOkSuccEPperMale$succYN[TableMaleTrtOkSuccEPperMale$MTrt == 'NC'])#  0.1578947 NC (6)
}
}

}
}




	##################################################
	## 			LMER Models on AllCourtships        ##			     
	##################################################

head(AllCourtships)	

{# as.factor
AllCourt$FID <- factor(AllCourt$FID)
AllCourt$MID <- factor(AllCourt$MID)
AllCourt$FIDMID <- factor(AllCourt$FIDMID)
AllCourt$FWEU <- factor(AllCourt$FWEU)
AllCourt$Year <- as.numeric(AllCourt$Year)
AllCourt$FTrt <- as.factor(AllCourt$FTrt)
AllCourt$MTrt <- as.factor(AllCourt$MTrt)
}

{### Resp ~ Trt
	
{# Females that kept the Trt, WP

AllCourtshipsFemaleTrtOkWP <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="WP")
nrow(AllCourtships)	#6451
nrow(AllCourtshipsFemaleTrtOkWP) #2555

modRespAllCourtshipsFemaleTrtOkWP <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkWP,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkWP)

# 0.2038071 C
# 0.0492675 NC

modRespAllCourtshipsFemaleTrtOkWPwithoutTrt <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkWP,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkWPwithoutTrt)	
anova(modRespAllCourtshipsFemaleTrtOkWP,modRespAllCourtshipsFemaleTrtOkWPwithoutTrt) # p = 0.01252 *


# dataset T1-15
AllCourtshipsFemaleTrtOkWP[,c('Resp','MID','FID','FIDMID','FTrt','Year','RelDayMod','LogRelTimeMinute','nEggsLayedLast5Days','Fdayspaired')]
#write.table(AllCourtshipsFemaleTrtOkWP[,c('Resp','MID','FID','FIDMID','FTrt','Year','RelDayMod','LogRelTimeMinute','nEggsLayedLast5Days','Fdayspaired')], file = "R_AllCourtshipsFemaleTrtOkWP.xls", sep="\t", col.names=TRUE)


	{# model assumptions checking
	# qqnorm(resid(modRespFemaleTrtOkWP)) 
	# qqline(resid(modRespFemaleTrtOkWP))
	# qqnorm(unlist(ranef(modRespFemaleTrtOkWP)))
	# qqline(unlist(ranef(modRespFemaleTrtOkWP)))
	# plot(fitted(modRespFemaleTrtOkWP), resid(modRespFemaleTrtOkWP))
	# abline(h=0)
	# scatter.smooth(AllCourtFemaleTrtOkWP$RelDayMod, resid(modRespFemaleTrtOkWP))
	# scatter.smooth(AllCourtFemaleTrtOkWP$RelTime,resid(modRespFemaleTrtOkWP))
	# plot(AllCourtFemaleTrtOkWP$nEggsLayedLast5Days,resid(modRespFemaleTrtOkWP))
	# scatter.smooth(AllCourtFemaleTrtOkWP$Fdayspaired,resid(modRespFemaleTrtOkWP))
	# plot(AllCourtFemaleTrtOkWP$Year,resid(modRespFemaleTrtOkWP))	
	# plot(AllCourtFemaleTrtOkWP$FTrt,resid(modRespFemaleTrtOkWP))
}

	{# average resp WP Female Trt Ok
	mean(AllCourtshipsFemaleTrtOkWP$Resp[AllCourtshipsFemaleTrtOkWP$FTrt == 'C'], na.rm = T)# 0.1601438
	mean(AllCourtshipsFemaleTrtOkWP$Resp[AllCourtshipsFemaleTrtOkWP$FTrt == 'NC'], na.rm = T)# 0.04716227
}

{# limited to the fertile period

AllCourtshipsFemaleTrtOkWPFertile <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="WP" & RelDayMod <5)
nrow(AllCourtshipsFemaleTrtOkWPFertile)	# 1555

modRespAllCourtshipsFemaleTrtOkWPFertile <-lmer(Resp~ FTrt + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkWPFertile,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkWPFertile)

# 0.1918190 C
# 0.0174676 NC

modRespAllCourtshipsFemaleTrtOkWPFertilewithoutTrt <-lmer(Resp~ scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkWPFertile,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkWPFertilewithoutTrt)

anova(modRespAllCourtshipsFemaleTrtOkWPFertile,modRespAllCourtshipsFemaleTrtOkWPFertilewithoutTrt)	# p = 0.01066 *


	mean(AllCourtshipsFemaleTrtOkWPFertile$Resp[AllCourtshipsFemaleTrtOkWPFertile$FTrt == 'C'], na.rm = T)# 0.1611675
	mean(AllCourtshipsFemaleTrtOkWPFertile$Resp[AllCourtshipsFemaleTrtOkWPFertile$FTrt == 'NC'], na.rm = T)# 0.01628223

}

{# excluding secondary female 11187

# AllCourtships[AllCourtships$FID == 11187 & AllCourtships$FWEU =="EP",]
AllCourtshipsFemalemonogTrtOkWP <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="WP" & AllCourtships$FID != 11187 )
nrow(AllCourtshipsFemalemonogTrtOkWP)	#2550

modRespAllCourtshipsFemalemonogTrtOkWP <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemalemonogTrtOkWP,REML=FALSE)   
summary(modRespAllCourtshipsFemalemonogTrtOkWP)

modRespAllCourtshipsFemalemonogTrtOkWPwithoutTrt <-lmer(Resp~scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) +(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemalemonogTrtOkWP,REML=FALSE)     
summary(modRespAllCourtshipsFemalemonogTrtOkWPwithoutTrt)

anova(modRespAllCourtshipsFemalemonogTrtOkWP,modRespAllCourtshipsFemalemonogTrtOkWPwithoutTrt)	# p =  0.006267 **
}

{# limited to the fertile period and excluding secondary female 11187

AllCourtshipsFemalemonogTrtOkWPFertile <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="WP" & AllCourtships$RelDayMod <5 & AllCourtships$FID != 11187)
nrow(AllCourtshipsFemalemonogTrtOkWPFertile)	# 1552

modRespAllCourtshipsFemalemonogTrtOkWPFertile <-lmer(Resp~ FTrt + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemalemonogTrtOkWPFertile,REML=FALSE)   
summary(modRespAllCourtshipsFemalemonogTrtOkWPFertile)

modRespAllCourtshipsFemalemonogTrtOkWPFertilewithoutTrt <-lmer(Resp~ scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemalemonogTrtOkWPFertile,REML=FALSE)   
summary(modRespAllCourtshipsFemalemonogTrtOkWPFertilewithoutTrt)

anova(modRespAllCourtshipsFemalemonogTrtOkWPFertile,modRespAllCourtshipsFemalemonogTrtOkWPFertilewithoutTrt)	# p = 0.007414 **
}

{# Pbdur effect

modRespAllCourtshipsFemaleTrtOkWPwithoutPbDur <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE)  + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkWP,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkWPwithoutPbDur)

anova(modRespAllCourtshipsFemaleTrtOkWP,modRespAllCourtshipsFemaleTrtOkWPwithoutPbDur)
}
}

{# Females that kept the Trt, EP
AllCourtshipsFemaleTrtOkEP <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="EP")
nrow(AllCourtships)	#6451
nrow(AllCourtshipsFemaleTrtOkEP)	#2769

modRespAllCourtshipsFemaleTrtOkEP <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkEP,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkEP)

#-5.339e-01 C
#-5.124e-01 NC

modRespAllCourtshipsFemaleTrtOkEPwithoutTrt <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkEP, na.action=na.exclude,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkEPwithoutTrt)

anova(modRespAllCourtshipsFemaleTrtOkEP ,modRespAllCourtshipsFemaleTrtOkEPwithoutTrt )	# p = 0.387



modRespAllCourtshipsFemaleTrtOkEPwithMTrt <-lmer(Resp~ FTrt * MTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkEP,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkEPwithMTrt)


# dataset T1-15
AllCourtshipsFemaleTrtOkEP[,c('Resp','MID','FID','FIDMID','FTrt','Year','RelDayMod','LogRelTimeMinute','nEggsLayedLast5Days','Fdayspaired')]
write.table(AllCourtshipsFemaleTrtOkEP[,c('Resp','MID','FID','FIDMID','FTrt','Year','RelDayMod','LogRelTimeMinute','nEggsLayedLast5Days','Fdayspaired')], file = "R_AllCourtshipsFemaleTrtOkEP.xls", sep="\t", col.names=TRUE)



	{# model assumptions checking
	# qqnorm(resid(modRespFemaleTrtOkEP)) # !! AWFUL !!
	# qqline(resid(modRespFemaleTrtOkEP))
	# qqnorm(unlist(ranef(modRespFemaleTrtOkEP)))
	# qqline(unlist(ranef(modRespFemaleTrtOkEP)))
	# plot(fitted(modRespFemaleTrtOkEP), resid(modRespFemaleTrtOkEP)) # !! AWFUL !!
	# abline(h=0)
	# scatter.smooth(AllCourtFemaleTrtOkEP$RelDayMod, resid(modRespFemaleTrtOkEP))
	# scatter.smooth(AllCourtFemaleTrtOkEP$RelTime,resid(modRespFemaleTrtOkEP))
	# plot(AllCourtFemaleTrtOkEP$nEggsLayedLast5Days,resid(modRespFemaleTrtOkEP))
	# scatter.smooth(AllCourtFemaleTrtOkEP$Fdayspaired,resid(modRespFemaleTrtOkEP))
	# plot(AllCourtFemaleTrtOkEP$Year,resid(modRespFemaleTrtOkEP))	
	# plot(AllCourtFemaleTrtOkEP$FTrt,resid(modRespFemaleTrtOkEP))
}

	{# average resp EP Female Trt Ok
	mean(AllCourtshipsFemaleTrtOkEP$Resp[AllCourtshipsFemaleTrtOkEP$FTrt == 'C'], na.rm = T)#  -0.5277962
	mean(AllCourtshipsFemaleTrtOkEP$Resp[AllCourtshipsFemaleTrtOkEP$FTrt == 'NC'], na.rm = T)# -0.4846898
}

{# excluding secondary female 11187

AllCourtshipsFemalemonogTrtOkEP <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="EP" & AllCourtships$FID != 11187 )
nrow(AllCourtshipsFemalemonogTrtOkEP)	#2718

modRespAllCourtshipsFemalemonogTrtOkEP <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemalemonogTrtOkEP,REML=FALSE)   
summary(modRespAllCourtshipsFemalemonogTrtOkEP)

modRespAllCourtshipsFemalemonogTrtOkEPwithoutTrt <-lmer(Resp~ scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemalemonogTrtOkEP, na.action=na.exclude,REML=FALSE)   
summary(modRespAllCourtshipsFemalemonogTrtOkEPwithoutTrt)

anova(modRespAllCourtshipsFemalemonogTrtOkEP ,modRespAllCourtshipsFemalemonogTrtOkEPwithoutTrt )	# p = 0.3752

}

# pb dur effect
modRespAllCourtshipsFemaleTrtOkEPwithoutPbdur <-lmer(Resp~ FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Year,scale=FALSE) + (1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkEP,REML=FALSE)   
summary(modRespAllCourtshipsFemaleTrtOkEPwithoutPbdur)

anova(modRespAllCourtshipsFemaleTrtOkEP,modRespAllCourtshipsFemaleTrtOkEPwithoutPbdur) # p = 0.004982 **


}
}

{### Successful WPCop ~ Trt

{# Females Trt ok
AllCourtshipsFemaleTrtOkWP <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="WP")

modWPCopAllCourtshipsFTrtOk <-glmer(succYN~ -1+FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE)+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkWP, family = "binomial")   
summary(modWPCopAllCourtshipsFTrtOk)	# p = 0.27743

invlogit(-1.3953599) # 20% C 0.1985535
(invlogit(-1.3953599+0.1585648)-invlogit(-1.3953599)+invlogit(-1.3953599)-invlogit(-1.3953599-0.1585648))/2	# 0.0252371
invlogit(-1.6507884) # 16 % NC 0.1610024
(invlogit(-1.6507884+0.1670100)-invlogit(-1.6507884)+invlogit(-1.6507884)-invlogit(-1.6507884-0.1670100))/2	#  0.02257957

# dataset T1-17
AllCourtshipsFemaleTrtOkWP[,c('succYN','MID','FID','FIDMID','FTrt','Year','RelDayMod','LogRelTimeMinute','nEggsLayedLast5Days','Fdayspaired')]
#write.table(AllCourtshipsFemaleTrtOkWP[,c('succYN','MID','FID','FIDMID','FTrt','Year','RelDayMod','LogRelTimeMinute','nEggsLayedLast5Days','Fdayspaired')], file = "R_AllCourtshipsFemaleTrtOkWP.xls", sep="\t", col.names=TRUE)


	{# model assumptions checking
	# qqnorm(resid(modWPCopFTrtOk )) # !! AWFUL !!
	# qqline(resid(modWPCopFTrtOk ))
	# qqnorm(unlist(ranef(modWPCopFTrtOk ))) 
	# qqline(unlist(ranef(modWPCopFTrtOk )))
	# plot(fitted(modWPCopFTrtOk ), resid(modWPCopFTrtOk )) # !! AWFUL !!
	# abline(h=0)
	# scatter.smooth(AllCourtFemaleTrtOkWP$RelDayMod, resid(modWPCopFTrtOk ))
	# scatter.smooth(AllCourtFemaleTrtOkWP$RelTime,resid(modWPCopFTrtOk ))
	# plot(AllCourtFemaleTrtOkWP$nEggsLayedLast5Days,resid(modWPCopFTrtOk ))
	# scatter.smooth(AllCourtFemaleTrtOkWP$Fdayspaired,resid(modWPCopFTrtOk ))
	# plot(AllCourtFemaleTrtOkWP$Year,resid(modWPCopFTrtOk ))	
	# plot(AllCourtFemaleTrtOkWP$FTrt,resid(modWPCopFTrtOk ))
}

	{# percentage succYN Female Trt Ok
	sum(AllCourtshipsFemaleTrtOkWP$succYN)# 492

	sum(AllCourtshipsFemaleTrtOkWP$succYN[AllCourtshipsFemaleTrtOkWP$FTrt == 'C'])/length(AllCourtshipsFemaleTrtOkWP$succYN[AllCourtshipsFemaleTrtOkWP$FTrt == 'C'])# 21% C 0.2125
	
	sum(AllCourtshipsFemaleTrtOkWP$succYN[AllCourtshipsFemaleTrtOkWP$FTrt == 'NC'])/length(AllCourtshipsFemaleTrtOkWP$succYN[AllCourtshipsFemaleTrtOkWP$FTrt == 'NC'])# 17% NC 0.172549
}

{# excluding secondary female 11187
AllCourtshipsFemalemonogTrtOkWP <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="WP"& AllCourtships$FID != 11187 )

modWPCopAllCourtshipsFmonogTrtOk <-glmer(succYN~ FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE)+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemalemonogTrtOkWP, family = "binomial")   
summary(modWPCopAllCourtshipsFmonogTrtOk)	# p = 0.20003

}

}
}

{### Successful WPCop when fertile ~ Trt	> those results which were significant (borderline) become NS

{# Females Trt ok
AllCourtshipsFemaleTrtOkWPFert <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="WP" & AllCourtships$RelDayMod != 5)

modWPCopAllCourtshipsFTrtOkFert <-glmer(succYN~ -1+FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE)+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemaleTrtOkWPFert, family = "binomial")   
summary(modWPCopAllCourtshipsFTrtOkFert)	# p = 0.103404	> with only video, was significant ! (though 4.5%)

invlogit(-1.2951372) # 21% C
invlogit(-1.7144858) # 15 % NC

	{# percentage succYN Female Trt Ok when fertile
	sum(AllCourtshipsFemaleTrtOkWPFert$succYN)# 315

	sum(AllCourtshipsFemaleTrtOkWPFert$succYN[AllCourtshipsFemaleTrtOkWPFert$FTrt == 'C'])/length(AllCourtshipsFemaleTrtOkWPFert$succYN[AllCourtshipsFemaleTrtOkWPFert$FTrt == 'C'])# 23% C
	
	sum(AllCourtshipsFemaleTrtOkWPFert$succYN[AllCourtshipsFemaleTrtOkWPFert$FTrt == 'NC'])/length(AllCourtshipsFemaleTrtOkWPFert$succYN[AllCourtshipsFemaleTrtOkWPFert$FTrt == 'NC'])# 17% NC
}


unique(AllCourtshipsFemaleTrtOkWP$FIDMID)[!(unique(AllCourtshipsFemaleTrtOkWP$FIDMID)%in%(unique(AllCourtshipsFemaleTrtOkWPFert$FIDMID)))]
#  "1116511147" "1122011202" "1116511253"

AllCourtships[AllCourtships$FIDMID == 1116511147,]	# C
AllCourtships[AllCourtships$FIDMID == 1116511253,]	# NC		>>>> female hopps on the back of the male *6
AllCourtships[AllCourtships$FIDMID == 1122011202,]	# C

{# excluding secondary female 11187
AllCourtshipsFemalemonogTrtOkWPFert <- subset (AllCourtships, AllCourtships$FIDyr%in%FIDYearOk & AllCourtships$FWEU =="WP" & AllCourtships$RelDayMod != 5& AllCourtships$FID != 11187)

modWPCopAllCourtshipsFmonogTrtOkFert <-glmer(succYN~ FTrt + scale(RelDayMod,scale=FALSE) + scale(LogRelTimeMinute,scale=FALSE)+ scale(nEggsLayedLast5Days,scale=FALSE) + scale(Fdayspaired,scale=FALSE) + scale(Year,scale=FALSE)+(1|MID)+(1|FID)+(1|FIDMID),data= AllCourtshipsFemalemonogTrtOkWPFert, family = "binomial")   
summary(modWPCopAllCourtshipsFmonogTrtOkFert)	# p = 0.080315 .	> with only video, was significant !
}
}
}

{### Successful EPCop for each ID ~ Trt

{# Females Trt Ok


head(TableFemaleTrtOkSuccEPperfemale)

modEPCopYNFTrtOkperfemale <-glmer(succYN~ -1+FTrt + scale(Year,scale=FALSE) +scale(NbCourt, scale=FALSE)+(1|FID),data= TableFemaleTrtOkSuccEPperfemale, family = "binomial")   
summary(modEPCopYNFTrtOkperfemale)	# p = 0.1341 	(for NbCourt: p = 0.0215 *)		

invlogit(-2.688602) # 0.06364929 C
(invlogit(-2.688602+0.598975)-invlogit(-2.688602)+invlogit(-2.688602)-invlogit(-2.688602-0.598975))/2	#  0.03705464
invlogit(-1.622438) # 0.1648689 NC
(invlogit(-1.622438+0.463041)-invlogit(-1.622438)+invlogit(-1.622438)-invlogit(-1.622438-0.463041))/2	#  0.06413033



	{# percentage FIDMIDsuccYN Female Trt Ok
	sum(TableFemaleTrtOkSuccEPperfemale$succYN)# 11

	sum(TableFemaleTrtOkSuccEPperfemale$succYN[TableFemaleTrtOkSuccEPperfemale$FTrt == 'C'])/length(TableFemaleTrtOkSuccEPperfemale$succYN[TableFemaleTrtOkSuccEPperfemale$FTrt == 'C'])# 0.08695652(4)
	
	sum(TableFemaleTrtOkSuccEPperfemale$succYN[TableFemaleTrtOkSuccEPperfemale$FTrt == 'NC'])/length(TableFemaleTrtOkSuccEPperfemale$succYN[TableFemaleTrtOkSuccEPperfemale$FTrt == 'NC'])# 0.1842105 NC (7)
}

{# excluding 11187

TableMonogFemaleTrtOkSuccEPperfemale <- TableFemaleTrtOkSuccEPperfemale[TableFemaleTrtOkSuccEPperfemale$FIDyr != 111872012,]
modEPCopYNFMonogTrtOkperfemale <-glmer(succYN~ FTrt + scale(Year,scale=FALSE) +scale(NbCourt, scale=FALSE)+(1|FID),data= TableMonogFemaleTrtOkSuccEPperfemale, family = "binomial")   
summary(modEPCopYNFMonogTrtOkperfemale)	# p = 0.2135
}

{# Pbdureffect
TableFemaleTrtOkSuccEPperfemale2 <- merge(x=TableFemaleTrtOkSuccEPperfemale, y=allbirds[,c('Pbdurlong','IDYear')], by.x='FIDyr', by.y='IDYear', all.x=TRUE)

modEPCopYNFTrtOkperfemalePbdur <-glmer(succYN~ Pbdurlong+FTrt + scale(Year,scale=FALSE) +scale(NbCourt, scale=FALSE)+(1|FID),data= TableFemaleTrtOkSuccEPperfemale2, family = "binomial")   
summary(modEPCopYNFTrtOkperfemalePbdur)		
}

}

{# Males Trt Ok

head(TableMaleTrtOkSuccEPperMale)

# TableMaleTrtOkSuccEPperMale <- TableMaleTrtOkSuccEPperMale[TableMaleTrtOkSuccEPperMale$MIDyr != 111902012,]


modEPCopYNMTrtOkperMale <-glmer(succYN~ MTrt + scale(Year,scale=FALSE) +scale(NbCourt, scale=FALSE)+(1|MID),data= TableMaleTrtOkSuccEPperMale, family = "binomial")   
summary(modEPCopYNMTrtOkperMale)	# p = 0.636939	(p = 0.501132 if polygynous male 11190 excluded)

invlogit(-1.59382) # 0.1688471 C
(invlogit(-1.59382+0.41870)-invlogit(-1.59382)+invlogit(-1.59382)-invlogit(-1.59382-0.41870))/2	#  0.05901806
invlogit(-1.89847) # 0.1302817 NC
(invlogit(-1.89847+0.51043)-invlogit(-1.89847)+invlogit(-1.89847)-invlogit(-1.89847-0.51043))/2	#  0.05861215



	{# percentage FIDMIDsuccYN Female Trt Ok
	sum(TableMaleTrtOkSuccEPperMale$succYN)# 15

	sum(TableMaleTrtOkSuccEPperMale$succYN[TableMaleTrtOkSuccEPperMale$MTrt == 'C'])/length(TableMaleTrtOkSuccEPperMale$succYN[TableMaleTrtOkSuccEPperMale$MTrt == 'C'])# 0.1956522(9)
	
	sum(TableMaleTrtOkSuccEPperMale$succYN[TableMaleTrtOkSuccEPperMale$MTrt == 'NC'])/length(TableMaleTrtOkSuccEPperMale$succYN[TableMaleTrtOkSuccEPperMale$MTrt == 'NC'])#  0.1578947 NC (6)
}

{# Pbdureffect
TableMaleTrtOkSuccEPperMale2 <- merge(x=TableMaleTrtOkSuccEPperMale, y=allbirds[,c('Pbdurlong','IDYear')], by.x='MIDyr', by.y='IDYear', all.x=TRUE)

modEPCopYNFTrtOkperMalePbdur <-glmer(succYN~ Pbdurlong+MTrt + scale(Year,scale=FALSE) +scale(NbCourt, scale=FALSE)+(1|MID),data= TableMaleTrtOkSuccEPperMale2, family = "binomial")   
summary(modEPCopYNFTrtOkperMalePbdur)		
}

}

}





	##################################################
	## 		LMER Models on Courtship rates          ##			     
	##################################################

head(allmales)	
head(allfemales)	
head(allmalesFertile)

{# as.factor
allmales$Treatment <- factor(allmales$Treatment)
allfemales$Treatment <- factor(allfemales$Treatment)
}

{# hist
hist(allmales$SumRateWP)
hist(sqrt(allmales$SumRateWP))
shapiro.test(allmales$SumRateWP)
shapiro.test(sqrt(allmales$SumRateWP))
qqnorm(allmales$SumRateWP)
hist(allmales$SumRateEP)	
hist(allmales$RatioWERatePaired)	
hist(sqrt(allmales$SumRateEP))
}


{# for males that kept the Trt

allmalesMaleTrtOk <- subset(allmales, allmales$Divorced == 0)

{# SumRateWP



# allmalesMaleTrtOk <- allmales[allmales$Divorced == 0 & allmales$IDYear != 111902012,]

modWPCourtMaleTrtOk <- lmer(sqrt(SumRateWP) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleTrtOk)

#0.68924  C	 0.68932 with 11190 changed WP/EP
#0.72940  NC	0.72345

# on 02/06/2014
# 0.68932 C > back transformed 0.4751621
(0.68932+0.03127)^2 # 0.5192499
(0.68932-0.03127)^2 # 0.4330298
(0.68932+0.03127)^2-(0.68932)^2 #0.04408789
(0.68932)^2-(0.68932-0.03127)^2	# 0.04213226
((0.68932+0.03127)^2-(0.68932)^2 + (0.68932)^2-(0.68932-0.03127)^2)/2	# 0.04311007
# 0.72345 NC > 0.5233799
((0.72345+0.03442)^2-(0.72345)^2 + (0.72345)^2-(0.72345-0.03442)^2)/2	#0.0498023



modWPCourtMaleTrtOkwithoutTrt <- lmer(sqrt(SumRateWP) ~ scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleTrtOkwithoutTrt)

anova(modWPCourtMaleTrtOk,modWPCourtMaleTrtOkwithoutTrt)	#  p = 0.3809	( p = 0.3716 if plogynous male 11190 excluded)	0.4639 with 11190 changed
# on 02/06/2014:  p = 0.4639


# dataset T1-20
allmalesMaleTrtOk[,c('SumRateWP','Ind_ID','Treatment','Season','Pbdurlong')]



	{# model assumption checking
qqnorm(resid(modWPCourtMaleTrtOk))
qqline(resid(modWPCourtMaleTrtOk))
qqnorm(unlist(ranef(modWPCourtMaleTrtOk)))
qqline(unlist(ranef(modWPCourtMaleTrtOk)))
}

	{# average SumRateWP
mean(allmalesMaleTrtOk$SumRateWP[allmalesMaleTrtOk$Treatment == 'C'])	# 0.5050526 C
mean(allmalesMaleTrtOk$SumRateWP[allmalesMaleTrtOk$Treatment == 'NC'])	# 0.5903355 NC
}

{# pb dur effect

modWPCourtMaleTrtOkwithPbDur <- lmer(sqrt(SumRateWP) ~ Pbdurlong+ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleTrtOkwithPbDur)

modWPCourtMaleTrtOkwithoutPbDur <- lmer(sqrt(SumRateWP) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleTrtOkwithoutPbDur)

anova(modWPCourtMaleTrtOkwithPbDur,modWPCourtMaleTrtOkwithoutPbDur)

head(allmalesMaleTrtOk)
plot(allmalesMaleTrtOk$SumRateEP, allmalesMaleTrtOk$Pbdurlong)

allmalesMaleTrtOk[allmalesMaleTrtOk$Pbdurlong > 400,]


}
}

{# SumRateEP

modEPCourtMaleTrtOk <- lmer(sqrt(SumRateEP) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleTrtOk)

#  0.71148 C	# 0.5062038	# 0.71143 > back transformed 0.5061326
#  0.71473 NC	# 0.510839	# 0.71814 > back transformed 0.5157251

# 0.044371
# 0.04843

((0.71143+0.044371)^2-(0.71143)^2 + (0.71143)^2-(0.71143-0.044371)^2)/2	#0.06313372
((0.71814+0.04843)^2-(0.71814)^2 + (0.71814)^2-(0.71814-0.04843)^2)/2	# 0.06955904



modEPCourtMaleTrtOkwithoutTrt <- lmer(sqrt(SumRateEP) ~ scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleTrtOkwithoutTrt)

anova(modEPCourtMaleTrtOk,modEPCourtMaleTrtOkwithoutTrt)	# p = 0.9571	( p = 0.9498 if plogynous male 11190 excluded)	#  0.9116

# dataset T1-22
allmalesMaleTrtOk[,c('SumRateEP','Ind_ID','Treatment','Season','Pbdurlong')]



	{# model assumption checking
qqnorm(resid(modEPCourtMaleTrtOk))
qqline(resid(modEPCourtMaleTrtOk))
qqnorm(unlist(ranef(modEPCourtMaleTrtOk)))
qqline(unlist(ranef(modEPCourtMaleTrtOk)))
}
}

	{# average SumRateEP
mean(allmalesMaleTrtOk$SumRateEP[allmalesMaleTrtOk$Treatment == 'C'])	# 0.5530396 C
mean(allmalesMaleTrtOk$SumRateEP[allmalesMaleTrtOk$Treatment == 'NC'])	# 0.6406251 NC
}

{# pb dur effect > NOW in TABLES S2

modEPCourtMaleTrtOkwithPbDur <- lmer(sqrt(SumRateEP) ~  Treatment + Pbdurlong+scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleTrtOkwithPbDur)

(0.44984840)^2 # C 0.2023636
(0.5808583)^2  # NC 0.3373964

((0.44984840+0.0801968)^2-(0.44984840)^2 + (0.44984840)^2-(0.44984840-0.0801968)^2)/2	#  0.0721528
((0.5808583+0.0579392)^2-(0.5808583)^2 + (0.5808583)^2-(0.5808583-0.0579392)^2)/2	# 0.06730893




modEPCourtMaleTrtOkwithoutPbDur <- lmer(sqrt(SumRateEP) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleTrtOkwithoutPbDur)

anova(modEPCourtMaleTrtOkwithPbDur,modEPCourtMaleTrtOkwithoutPbDur)	# p = 0.0002934 ***



modEPCourtMaleTrtOkwithPbDurwithoutTrt <- lmer(sqrt(SumRateEP) ~ Pbdurlong+ scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleTrtOkwithPbDurwithoutTrt)

anova(modEPCourtMaleTrtOkwithPbDur,modEPCourtMaleTrtOkwithPbDurwithoutTrt)	# p = 0.046 *



}
}

{# for females that kept the Trt
allfemalesFemaleTrtOk <- subset(allfemales, allfemales$Divorced == 0)

{# SumRateWP

# allfemalesFemaleTrtOk <- allfemales[allfemales$Divorced == 0 & allfemales$IDYear != 111872012,]

modWPCourtFemaleTrtOk <- lmer(sqrt(RateWP) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtFemaleTrtOk)

#0.48685  C
#0.50973  NC

modWPCourtFemaleTrtOkwithoutTrt <- lmer(sqrt(RateWP) ~ scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtFemaleTrtOkwithoutTrt)

anova(modWPCourtFemaleTrtOk,modWPCourtFemaleTrtOkwithoutTrt)	#  p = 0.4774	(p = 0.3621 if secondary female 11187 excluded)

	{# model assumption checking
qqnorm(resid(modWPCourtFemaleTrtOk))
qqline(resid(modWPCourtFemaleTrtOk))
qqnorm(unlist(ranef(modWPCourtFemaleTrtOk)))	# SUPER WEIRD
qqline(unlist(ranef(modWPCourtFemaleTrtOk)))
}

	{# average RateWP
mean(allfemalesFemaleTrtOk$RateWP[allfemalesFemaleTrtOk$Treatment == 'C'])	#  0.2518837 C
mean(allfemalesFemaleTrtOk$RateWP[allfemalesFemaleTrtOk$Treatment == 'NC'])	# 0.2928888 NC
}
}

{# SumRateEP

modEPCourtFemaleTrtOk <- lmer(sqrt(RateEP) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtFemaleTrtOk)

# 0.44737 C > back transformed: 0.2001399
# 0.49705 NC > back transformed: 0.2470587


((0.44737+0.03937)^2-(0.44737)^2 + (0.44737)^2-(0.44737-0.03937)^2)/2	#0.03522591
((0.49705+0.04160)^2-(0.49705)^2 + (0.49705)^2-(0.49705-0.04160)^2)/2	# 0.04135456


modEPCourtFemaleTrtOkwithoutTrt <- lmer(sqrt(RateEP) ~ scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtFemaleTrtOkwithoutTrt)

anova(modEPCourtFemaleTrtOk,modEPCourtFemaleTrtOkwithoutTrt)	# p = 0.3572	(p = 0.4555 if secondary female 11187 excluded)

# dataset T1-21
allfemalesFemaleTrtOk[,c('RateEP','Ind_ID','Treatment','Season','Pbdurlong')]



	{# model assumption checking
qqnorm(resid(modEPCourtFemaleTrtOk))
qqline(resid(modEPCourtFemaleTrtOk))
qqnorm(unlist(ranef(modEPCourtFemaleTrtOk)))
qqline(unlist(ranef(modEPCourtFemaleTrtOk)))
}

{# pb dur effect >> NOW in TABLE S2
modEPCourtFemaleTrtOkpbdur <- lmer(sqrt(RateEP) ~  -1+Treatment+ Pbdurlong+ scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtFemaleTrtOkpbdur)

(0.5974243)^2  # C  0.3569158
(0.5785876)^2  # NC 0.3347636


((0.5974243+0.0697392)^2-(0.5974243)^2 + (0.5974243)^2-(0.5974243-0.0697392)^2)/2	# 0.08332779
((0.5785876+0.0511592)^2-(0.5785876)^2 + (0.5785876)^2-(0.5785876-0.0511592)^2)/2	# 0.05920016



modEPCourtFemaleTrtOkwithoutpbdur <- lmer(sqrt(RateEP) ~  Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtFemaleTrtOkwithoutpbdur)

anova(modEPCourtFemaleTrtOkpbdur,modEPCourtFemaleTrtOkwithoutpbdur)


modEPCourtFemaleTrtOkpbdurwithoutTrt <- lmer(sqrt(RateEP) ~  Pbdurlong+ scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtFemaleTrtOkpbdurwithoutTrt)

anova(modEPCourtFemaleTrtOkpbdur,modEPCourtFemaleTrtOkpbdurwithoutTrt)



}
}

	{# average SumRateEP
mean(allfemalesFemaleTrtOk$RateEP[allfemalesFemaleTrtOk$Treatment == 'C'])	# 0.2782096C
mean(allfemalesFemaleTrtOk$RateEP[allfemalesFemaleTrtOk$Treatment == 'NC'])	# 0.2803501C
}
}

{# for males that kept the Trt, during the fertile period of their female

{# SumRateWP

allmalesMaleFertileTrtOk <- subset(allmalesFertile, allmales$Divorced == 0)

modWPCourtMaleFertileTrtOk <- lmer(sqrt(SumRateWPFertile) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleFertileTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleFertileTrtOk)	# t = 0.167

# 0.53999  C	0.2915892	# 0.54003
# 0.54683  NC	0.299023	# 0.54248

modWPCourtMaleFertileTrtOkwithoutTrt <- lmer(sqrt(SumRateWPFertile) ~ scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleFertileTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleFertileTrtOkwithoutTrt)

anova(modWPCourtMaleFertileTrtOk,modWPCourtMaleFertileTrtOkwithoutTrt)	#  p = 0.8681	# 0.9528 with 1190 changed WP/EP


	{# average SumRateWPFertile
mean(allmalesMaleFertileTrtOk$SumRateWPFertile[allmalesMaleFertileTrtOk$Treatment == 'C'])	# 0.3178965 C
mean(allmalesMaleFertileTrtOk$SumRateWPFertile[allmalesMaleFertileTrtOk$Treatment == 'NC'])	# 0.3492032 NC
}
}

}






	##################################################
	## 		LMER Models on AllCourtshipRates        ##			     
	##################################################

head(AllCourtshipRates)	
head(allfemales)	
head(allmalesFertile)

{# as.factor
allmales$Treatment <- factor(allmales$Treatment)
allfemales$Treatment <- factor(allfemales$Treatment)
}

{# hist
hist(allmales$SumRateWP)
hist(sqrt(allmales$SumRateWP))
shapiro.test(allmales$SumRateWP)
shapiro.test(sqrt(allmales$SumRateWP))
qqnorm(allmales$SumRateWP)
hist(allmales$SumRateEP)	
hist(allmales$RatioWERatePaired)	
hist(sqrt(allmales$SumRateEP))
}


{# for males that kept the Trt

{# WP

modWPCourtMaleTrtOk <- lmer(ALLMeanZsqrtWPRates ~ MTrt + scale(Season, scale=FALSE) +(1|MID),data= AllCourtshipRates, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleTrtOk)

#-0.09915  C	 
#0.12002  NC	

modWPCourtMaleTrtOkwithoutTrt <- lmer(ALLMeanZsqrtWPRates ~ scale(Season, scale=FALSE) +(1|MID),data= AllCourtshipRates, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleTrtOkwithoutTrt)

anova(modWPCourtMaleTrtOk,modWPCourtMaleTrtOkwithoutTrt)	#  p = 0.2304	


	{# model assumption checking
qqnorm(resid(modWPCourtMaleTrtOk))
qqline(resid(modWPCourtMaleTrtOk))
qqnorm(unlist(ranef(modWPCourtMaleTrtOk)))
qqline(unlist(ranef(modWPCourtMaleTrtOk)))
}

	{# average Rate WP
mean(AllCourtshipRates$ALLMeanZsqrtWPRates[AllCourtshipRates$MTrt == 'C'])	# -0.09872585 C
mean(AllCourtshipRates$ALLMeanZsqrtWPRates[AllCourtshipRates$MTrt == 'NC'])	# 0.1195102 NC

mean(AllCourtshipRates$ALLMeanZsqrtWPRates)
sd(AllCourtshipRates$ALLMeanZsqrtWPRates)


AllCourtshipRates$ALLZSqrtWPRateLive[i] <-  (sqrt(AllCourtshipRates$RateWPLive[i]*60) - mean(sqrt(AllCourtshipRates$RateWPLive[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$RateWPLive[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$ALLZSqrtWPRateVideo[i] <- (sqrt(AllCourtshipRates$SumRateWP[i]*60) - mean(sqrt(AllCourtshipRates$SumRateWP[AllCourtshipRates$Season == 2013]*60))) / sd(sqrt(AllCourtshipRates$SumRateWP[AllCourtshipRates$Season == 2013]*60))
AllCourtshipRates$ALLMeanZsqrtWPRates[i] <- mean(c(AllCourtshipRates$ALLZSqrtWPRateLive[i],AllCourtshipRates$ALLZSqrtWPRateVideo[i]))
}

{# if polygynous 11190 excluded

AllCourtshipRatesMonog <- AllCourtshipRates[AllCourtshipRates$MIDyr != 111902012,]

modWPCourtMaleMonogTrtOk <- lmer(ALLMeanZsqrtWPRates ~ MTrt + scale(Season, scale=FALSE) +(1|MID),data= AllCourtshipRatesMonog, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleMonogTrtOk)

modWPCourtMaleMonogTrtOkwithoutTrt <- lmer(ALLMeanZsqrtWPRates ~ scale(Season, scale=FALSE) +(1|MID),data= AllCourtshipRatesMonog, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleMonogTrtOkwithoutTrt)

anova(modWPCourtMaleMonogTrtOk,modWPCourtMaleMonogTrtOkwithoutTrt)	#  p = 0.1479 if plogynous male 11190 excluded
}

}

{# EP

modEPCourtMaleTrtOk <- lmer(ALLMeanZsqrtEPRates ~ MTrt + scale(Season, scale=FALSE) +(1|MID),data= AllCourtshipRates, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleTrtOk)

#-4.071e-02
#9.195e-05

modEPCourtMaleTrtOkwithoutTrt <- lmer(ALLMeanZsqrtEPRates ~ scale(Season, scale=FALSE) +(1|MID),data= AllCourtshipRates, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleTrtOkwithoutTrt)

anova(modEPCourtMaleTrtOk,modEPCourtMaleTrtOkwithoutTrt)	# p = 0.8417	( p = 0.9498 if plogynous male 11190 excluded)	#  0.9116

	{# model assumption checking
qqnorm(resid(modEPCourtMaleTrtOk))
qqline(resid(modEPCourtMaleTrtOk))
qqnorm(unlist(ranef(modEPCourtMaleTrtOk)))
qqline(unlist(ranef(modEPCourtMaleTrtOk)))
}
}

{# if polygynous 11190 excluded
AllCourtshipRatesMonog <- AllCourtshipRates[AllCourtshipRates$MIDyr != 111902012,]

modEPCourtMaleMonogTrtOk <- lmer(ALLMeanZsqrtEPRates ~ MTrt + scale(Season, scale=FALSE) +(1|MID),data= AllCourtshipRatesMonog, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleMonogTrtOk)

modEPCourtMaleMonogTrtOkwithoutTrt <- lmer(ALLMeanZsqrtEPRates ~ scale(Season, scale=FALSE) +(1|MID),data= AllCourtshipRatesMonog, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtMaleMonogTrtOkwithoutTrt)

anova(modEPCourtMaleMonogTrtOk,modEPCourtMaleMonogTrtOkwithoutTrt)	# p = 0.8626  if plogynous male 11190 excluded
}

	{# average EP
mean(AllCourtshipRates$ALLMeanZsqrtEPRates[AllCourtshipRates$MTrt == 'C'])	# -0.07956784 C
mean(AllCourtshipRates$ALLMeanZsqrtEPRates[AllCourtshipRates$MTrt == 'NC'])	# 0.09631897 NC
}
}

{# for females that kept the Trt

{# SumRateWP

allfemalesFemaleTrtOk <- subset(allfemales, allfemales$Divorced == 0)
# allfemalesFemaleTrtOk <- allfemales[allfemales$Divorced == 0 & allfemales$IDYear != 111872012,]

modWPCourtFemaleTrtOk <- lmer(sqrt(RateWP) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtFemaleTrtOk)

#0.48685  C
#0.50973  NC

modWPCourtFemaleTrtOkwithoutTrt <- lmer(sqrt(RateWP) ~ scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtFemaleTrtOkwithoutTrt)

anova(modWPCourtFemaleTrtOk,modWPCourtFemaleTrtOkwithoutTrt)	#  p = 0.4774	(p = 0.3621 if secondary female 11187 excluded)

	{# model assumption checking
qqnorm(resid(modWPCourtFemaleTrtOk))
qqline(resid(modWPCourtFemaleTrtOk))
qqnorm(unlist(ranef(modWPCourtFemaleTrtOk)))	# SUPER WEIRD
qqline(unlist(ranef(modWPCourtFemaleTrtOk)))
}

	{# average RateWP
mean(allfemalesFemaleTrtOk$RateWP[allfemalesFemaleTrtOk$Treatment == 'C'])	#  0.2518837 C
mean(allfemalesFemaleTrtOk$RateWP[allfemalesFemaleTrtOk$Treatment == 'NC'])	# 0.2928888 NC
}
}

{# SumRateEP

modEPCourtFemaleTrtOk <- lmer(sqrt(RateEP) ~ -1+Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtFemaleTrtOk)

# 0.44737 C
# 0.49705 NC

modEPCourtFemaleTrtOkwithoutTrt <- lmer(sqrt(RateEP) ~ scale(Season, scale=FALSE) +(1|Ind_ID),data= allfemalesFemaleTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modEPCourtFemaleTrtOkwithoutTrt)

anova(modEPCourtFemaleTrtOk,modEPCourtFemaleTrtOkwithoutTrt)	# p = 0.3572	(p = 0.4555 if secondary female 11187 excluded)

	{# model assumption checking
qqnorm(resid(modEPCourtFemaleTrtOk))
qqline(resid(modEPCourtFemaleTrtOk))
qqnorm(unlist(ranef(modEPCourtFemaleTrtOk)))
qqline(unlist(ranef(modEPCourtFemaleTrtOk)))
}
}

	{# average SumRateEP
mean(allfemalesFemaleTrtOk$RateEP[allfemalesFemaleTrtOk$Treatment == 'C'])	# 0.2782096C
mean(allfemalesFemaleTrtOk$RateEP[allfemalesFemaleTrtOk$Treatment == 'NC'])	# 0.2803501C
}
}

{# for males that kept the Trt, during the fertile period of their female

{# SumRateWP

allmalesMaleFertileTrtOk <- subset(allmalesFertile, allmales$Divorced == 0)

modWPCourtMaleFertileTrtOk <- lmer(sqrt(SumRateWPFertile) ~ Treatment + scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleFertileTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleFertileTrtOk)	# t = 0.167

# 0.53999  C	0.2915892	# 0.54003
# 0.54683  NC	0.299023	# 0.54248

modWPCourtMaleFertileTrtOkwithoutTrt <- lmer(sqrt(SumRateWPFertile) ~ scale(Season, scale=FALSE) +(1|Ind_ID),data= allmalesMaleFertileTrtOk, na.action=na.exclude,REML=FALSE) 
summary(modWPCourtMaleFertileTrtOkwithoutTrt)

anova(modWPCourtMaleFertileTrtOk,modWPCourtMaleFertileTrtOkwithoutTrt)	#  p = 0.8681	# 0.9528 with 1190 changed WP/EP


	{# average SumRateWPFertile
mean(allmalesMaleFertileTrtOk$SumRateWPFertile[allmalesMaleFertileTrtOk$Treatment == 'C'])	# 0.3178965 C
mean(allmalesMaleFertileTrtOk$SumRateWPFertile[allmalesMaleFertileTrtOk$Treatment == 'NC'])	# 0.3492032 NC
}
}

}







	##################################################
	## 		LMER Models on NestCheck Data           ##			     
	##################################################

head(NestCheck)

{# hist+ creation table for graph suplemental material attendance (F, M or both) ~ day of clutch
par(mfrow=c(2,1)) 

{# for all birds
alldays <- data.frame(table(NestCheck$DayClutch))

table(NestCheck$Attendence3YN[NestCheck$Attendence3YN==1],NestCheck$DayClutch[NestCheck$Attendence3YN==1])
Att3Freq <-data.frame(table(NestCheck$DayClutch[NestCheck$Attendence3YN==1],NestCheck$Attendence3YN[NestCheck$Attendence3YN==1]))
plot(Att3Freq$Var1,Att3Freq$Freq, xlim = c(1,58))

hist(NestCheck$AttendenceData)


table(NestCheck$Attendence23YN[NestCheck$Attendence23YN==1],NestCheck$DayClutch[NestCheck$Attendence23YN==1])
Att23Freq <-data.frame(table(NestCheck$DayClutch[NestCheck$Attendence23YN==1],NestCheck$Attendence23YN[NestCheck$Attendence23YN==1]))
plot(Att23Freq$Var1,Att23Freq$Freq,xlim = c(1,58))


Att13Freq <-data.frame(table(NestCheck$DayClutch[NestCheck$Attendence13YN==1],NestCheck$Attendence13YN[NestCheck$Attendence13YN==1]))
plot(Att13Freq$Var1,Att13Freq$Freq,xlim = c(1,58))

table(NestCheck$Attendence3YN[NestCheck$Attendence3YN==1],NestCheck$DayBrood[NestCheck$Attendence3YN==1])
table(NestCheck$Attendence23YN[NestCheck$Attendence23YN==1],NestCheck$DayBrood[NestCheck$Attendence23YN==1])
table(NestCheck$Attendence13YN[NestCheck$Attendence13YN==1],NestCheck$DayBrood[NestCheck$Attendence13YN==1])

Att3Freq$Var1 <- as.numeric(as.character(Att3Freq$Var1))
Att23Freq$Var1 <- as.numeric(as.character(Att23Freq$Var1))
Att13Freq$Var1 <- as.numeric(as.character(Att13Freq$Var1))




DayClutch <- seq(1:35)
AllAttendence <- data.frame(DayClutch)

AllAttendence <- merge(x=AllAttendence , y = Att3Freq[,c('Var1','Freq')], by.x = 'DayClutch', by.y = 'Var1', all.x = TRUE)
colnames(AllAttendence) <-c('DayClutch','Att3')
AllAttendence <- merge(x=AllAttendence , y = Att23Freq[,c('Var1','Freq')], by.x = 'DayClutch', by.y = 'Var1', all.x = TRUE)
colnames(AllAttendence) <-c('DayClutch','Att3','Att23')
AllAttendence <- merge(x=AllAttendence , y = Att13Freq[,c('Var1','Freq')], by.x = 'DayClutch', by.y = 'Var1', all.x = TRUE)
colnames(AllAttendence) <- c('DayClutch','Att3', 'Att23', 'Att13')
AllAttendence <- merge(x=AllAttendence , y = alldays[,c('Var1','Freq')], by.x = 'DayClutch', by.y = 'Var1', all.x = TRUE)
colnames(AllAttendence) <- c('DayClutch','Att3', 'Att23', 'Att13','n')
AllAttendence$Att3[is.na(AllAttendence$Att3)] <- 0
AllAttendence$Att23[is.na(AllAttendence$Att23)] <- 0
AllAttendence$propmale <- AllAttendence$Att23/AllAttendence$n
AllAttendence$propfemale <- AllAttendence$Att13/AllAttendence$n
AllAttendence$propboth <- AllAttendence$Att3/AllAttendence$n



plot(AllAttendence$DayClutch, AllAttendence$propfemale, xlim = c(1,35), ylim = c(0, 0.6), col ='red',pch=19,xlab = "Day of the clutch", ylab = "Probability of nest attendence", cex.lab=1.5,font.lab = 2)
par(new = TRUE)
plot(AllAttendence$DayClutch, AllAttendence$propmale, xlim = c(1,35), ylim = c(0, 0.6), col ='blue',pch=19,axes = FALSE, xlab = "", ylab = "")
par(new = TRUE)
plot(AllAttendence$DayClutch, AllAttendence$propboth, xlim = c(1,35), ylim = c(0, 0.6), col ='purple',pch=19,axes = FALSE, xlab = "", ylab = "")
rect(12,-5,17,1, col="#0000ff22", border='transparent')
text(0,0.55,"Females",col='red',cex=1.2, pos=4)
text(0,0.30,"Males",col='blue',cex=1.2, pos=4)
text(0,0.12,"Both",col='purple',cex=1.2, pos=4)
text(14.5,0.57,"Hatching 
period", col='darkblue',cex=1.2)
}

{# for birds that kept the treatment

NestCheck$FIDyr <- paste(NestCheck$F_ID, NestCheck$Year, sep='')

alldays <- data.frame(table(NestCheck$DayClutch[NestCheck$FIDyr%in%FIDYearOk] ))

Att3Freq <-data.frame(table(NestCheck$DayClutch[NestCheck$Attendence3YN==1& NestCheck$FIDyr%in%FIDYearOk],NestCheck$Attendence3YN[NestCheck$Attendence3YN==1& NestCheck$FIDyr%in%FIDYearOk]))

Att23Freq <-data.frame(table(NestCheck$DayClutch[NestCheck$Attendence23YN==1& NestCheck$FIDyr%in%FIDYearOk],NestCheck$Attendence23YN[NestCheck$Attendence23YN==1& NestCheck$FIDyr%in%FIDYearOk]))

Att13Freq <-data.frame(table(NestCheck$DayClutch[NestCheck$Attendence13YN==1& NestCheck$FIDyr%in%FIDYearOk],NestCheck$Attendence13YN[NestCheck$Attendence13YN==1& NestCheck$FIDyr%in%FIDYearOk]))

Att3Freq$Var1 <- as.numeric(as.character(Att3Freq$Var1))
Att23Freq$Var1 <- as.numeric(as.character(Att23Freq$Var1))
Att13Freq$Var1 <- as.numeric(as.character(Att13Freq$Var1))


DayClutch <- seq(1:35)
AllAttendence <- data.frame(DayClutch)

AllAttendence <- merge(x=AllAttendence , y = Att3Freq[,c('Var1','Freq')], by.x = 'DayClutch', by.y = 'Var1', all.x = TRUE)
colnames(AllAttendence) <-c('DayClutch','Att3')
AllAttendence <- merge(x=AllAttendence , y = Att23Freq[,c('Var1','Freq')], by.x = 'DayClutch', by.y = 'Var1', all.x = TRUE)
colnames(AllAttendence) <-c('DayClutch','Att3','Att23')
AllAttendence <- merge(x=AllAttendence , y = Att13Freq[,c('Var1','Freq')], by.x = 'DayClutch', by.y = 'Var1', all.x = TRUE)
colnames(AllAttendence) <- c('DayClutch','Att3', 'Att23', 'Att13')
AllAttendence <- merge(x=AllAttendence , y = alldays[,c('Var1','Freq')], by.x = 'DayClutch', by.y = 'Var1', all.x = TRUE)
colnames(AllAttendence) <- c('DayClutch','Att3', 'Att23', 'Att13','n')
AllAttendence$Att3[is.na(AllAttendence$Att3)] <- 0
AllAttendence$Att23[is.na(AllAttendence$Att23)] <- 0
AllAttendence$propmale <- AllAttendence$Att23/AllAttendence$n
AllAttendence$propfemale <- AllAttendence$Att13/AllAttendence$n
AllAttendence$propboth <- AllAttendence$Att3/AllAttendence$n


par(mar=c(5,5,2,2))
plot(AllAttendence$DayClutch, AllAttendence$propfemale, xlim = c(1,35), ylim = c(0, 0.6), col ='red',pch=19,xlab = "Day of the clutch", ylab = "Probability of nest attendence", cex.lab=1.5,font.lab = 2)
par(new = TRUE)
plot(AllAttendence$DayClutch, AllAttendence$propmale, xlim = c(1,35), ylim = c(0, 0.6), col ='blue',pch=19,axes = FALSE, xlab = "", ylab = "")
par(new = TRUE)
plot(AllAttendence$DayClutch, AllAttendence$propboth, xlim = c(1,35), ylim = c(0, 0.6), col ='purple',pch=19,axes = FALSE, xlab = "", ylab = "")
rect(12,-5,17,1, col="#0000ff22", border='transparent')
text(0,0.55,"Females",col='red',cex=1.2, pos=4)
text(0,0.30,"Males",col='blue',cex=1.2, pos=4)
text(0,0.12,"Both",col='purple',cex=1.2, pos=4)
text(14.5,0.57,"Hatching 
period", col='darkblue',cex=1.2)

}

# frequencies of attendence for the first 4 days with chicks
table(NestCheck$AttendenceData[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60))], NestCheck$Treatments[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60))])

# frequencies of attendence for all days with chicks
table(NestCheck$AttendenceData[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0], NestCheck$Treatments[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0])



modAttendenceWholeClutch <- glmer(AttendenceYN ~ Treatments + poly(DayClutch,2)+ scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|ClutchID)+ (1|M_ID) + (1|F_ID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$DayClutch < 36 ,])
summary(modAttendenceWholeClutch )



}


{# Attendence 1 2 3 YN for Social pairs that kept the Trt

{# Attendence when hatch

modAttendenceYNWhenHatch <- lmer(AttendenceYN ~ Treatments + ClutchNo + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Date >= NestCheck$MinHatchDate & NestCheck$Date <= NestCheck$MaxHatchDate,])
summary(modAttendenceYNWhenHatch)	# t = -0.292   ClutchNo :  t =  -3.315

modAttendence13WhenHatch <- glmer(Attendence13YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Date >= NestCheck$MinHatchDate & NestCheck$Date <= NestCheck$MaxHatchDate,])
summary(modAttendence13WhenHatch)	# p = 0.832

invlogit(-0.049254)	# 0.487689 C
invlogit(-0.096245)	# 0.4759573 NC




modAttendence23WhenHatch <- glmer(Attendence23YN ~ -1+Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Date >= NestCheck$MinHatchDate & NestCheck$Date <= NestCheck$MaxHatchDate,])
summary(modAttendence23WhenHatch)	# p = 0.0340 * (p =  0.0352 * with subset NestCheckData without duplicates FIDDate)


invlogit(-0.34047)	# 0.4156953 C
(invlogit(-0.34047+0.15610)-invlogit(-0.34047)+invlogit(-0.34047)-invlogit(-0.34047-0.15610))/2	# 0.03784528

invlogit(-0.86252)	# 0.2968131 NC
(invlogit(-0.86252+0.19245)-invlogit(-0.86252)+invlogit(-0.86252)-invlogit(-0.86252-0.19245))/2	#  0.04010465




nrow(NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Date >= NestCheck$MinHatchDate & NestCheck$Date <= NestCheck$MaxHatchDate & NestCheck$Attendence23YN == 1,])#215 

#dataset T1-14
NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Date >= NestCheck$MinHatchDate & NestCheck$Date <= NestCheck$MaxHatchDate ,c('Attendence23YN','ClutchID','MIDFID','M_ID','F_ID','Treatments','DayBrood','NumChicks','MIDPbdurlong')]




modAttendence3WhenHatch <- glmer(Attendence3YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Date >= NestCheck$MinHatchDate & NestCheck$Date <= NestCheck$MaxHatchDate,])
summary(modAttendence3WhenHatch)	# p = 0.0134 * (p =  0.0145 * with subset NestCheckData without duplicates FIDDate)

# pb dur effect
modAttendence23WhenHatchpbdur <- glmer(Attendence23YN ~ MIDPbdurlong+Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Date >= NestCheck$MinHatchDate & NestCheck$Date <= NestCheck$MaxHatchDate,])
summary(modAttendence23WhenHatchpbdur)	# p = 0.0340 * (p =  0.0352 * with subset NestCheckData without duplicates FIDDate)





}

{# Attendence first 4 days with chicks

modAttendencefirst4days <- glmer(AttendenceYN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60)),])
summary(modAttendencefirst4days)	# p =  0.875 with subset NestCheckData without duplicates FIDDate


modAttendence13first4days <- glmer(Attendence13YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60)),])
summary(modAttendence13first4days)	# p = 0.898 with subset NestCheckData without duplicates FIDDate

modAttendence23first4days <- glmer(Attendence23YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60)),])
summary(modAttendence23first4days)	# p = 0.17757 with subset NestCheckData without duplicates FIDDate

modAttendence3first4days <- glmer(Attendence3YN ~ Treatments + scale(NumChicks, scale=FALSE)+ (1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60)),])
summary(modAttendence3first4days)	# p = 0.0175 * with subset NestCheckData without duplicates FIDDate


invlogit(-2.64682) # 0.06618528 C
invlogit(-3.75747) # 0.02281027 NC

}

{# Attendence first 3 days with chicks

modAttendencefirst3days <- glmer(AttendenceYN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +3*24*60*60)),])
summary(modAttendencefirst3days)	# p =  0.819 with subset NestCheckData without duplicates FIDDate


modAttendence13first3days <- glmer(Attendence13YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +3*24*60*60)),])
summary(modAttendence13first3days)	# p = 0.661 with subset NestCheckData without duplicates FIDDate



modAttendence23first3days <- glmer(Attendence23YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +3*24*60*60)),])
summary(modAttendence23first3days)	# p = 0.1199 with subset NestCheckData without duplicates FIDDate




modAttendence3first3days <- glmer(Attendence3YN ~ -1+Treatments + scale(NumChicks, scale=FALSE)+ (1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +3*24*60*60)),])
summary(modAttendence3first3days)	# p = 0.00945 ** with subset NestCheckData without duplicates FIDDate


invlogit(-2.29476) # 0.09155787 C
invlogit(-3.44803) # 0.03082766 NC

}

{# Attendence first 2 days with chicks

modAttendencefirst2days <- glmer(AttendenceYN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +2*24*60*60)),])
summary(modAttendencefirst2days)	# p =   0.7908 with subset NestCheckData without duplicates FIDDate


modAttendence13first2days <- glmer(Attendence13YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +2*24*60*60)),])
summary(modAttendence13first2days)	# p = 0.545 with subset NestCheckData without duplicates FIDDate



modAttendence23first2days <- glmer(Attendence23YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +2*24*60*60)),])
summary(modAttendence23first2days)	# p = 0.2616 with subset NestCheckData without duplicates FIDDate


modAttendence3first2days <- glmer(Attendence3YN ~ Treatments + scale(NumChicks, scale=FALSE)+ (1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +2*24*60*60)),])
summary(modAttendence3first2days)	# p = 0.0104 * with subset NestCheckData without duplicates FIDDate




head(NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +2*24*60*60)),])

table(NestCheck$DayBrood[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +2*24*60*60))])


modAttendence23first2days <- glmer(Attendence23YN ~ Treatments + scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0  & (NestCheck$Date <= ( NestCheck$MinHatchDate +2*24*60*60)) & NestCheck$DayBrood <=3,])
summary(modAttendence23first2days)	# p = 0.2605 with subset NestCheckData without duplicates FIDDate





}


{# Attendence when chicks

modAttendenceWhenChicks <- glmer(AttendenceYN ~ Treatments + DayBrood+ scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|ClutchID)+ (1|M_ID) + (1|F_ID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0,])
summary(modAttendenceWhenChicks)


modAttendence13WhenChick <- glmer(Attendence13YN ~ Treatments + DayBrood+ scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 ,])
summary(modAttendence13WhenChick)	# p = 0.960

invlogit(0.241508)	# 0.5600852 C
invlogit(0.230434)	# 0.5573549 NC



# TO GET ESTIMATES: DO NOT FORGET TO SCALE DAYBROOD !!!!!!!!!!!!!!!
modAttendence23WhenChick <- glmer(Attendence23YN ~ Treatments +scale(DayBrood, scale=FALSE)+ scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 ,])
summary(modAttendence23WhenChick)	# p = 0.242 z= -1.169

invlogit(-1.27100)	# 0.2190861 +- 0.13072
(invlogit(-1.27100+0.13072)-invlogit(-1.27100)+invlogit(-1.27100)-invlogit(-1.27100-0.13072))/2	#  0.02236282

invlogit(-1.50227)	# 0.1820872 +- 0.15172
(invlogit(-1.27100+0.15172)-invlogit(-1.27100)+invlogit(-1.27100)-invlogit(-1.27100-0.15172))/2	#  0.02595467

nrow(NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Attendence23YN == 1,])#532 

}

# pbdurlong effect
modAttendence23WhenChickPbdurlong <- glmer(Attendence23YN ~ MIDPbdurlong+Treatments +scale(DayBrood, scale=FALSE)+ scale(NumChicks, scale=FALSE)+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), family = 'binomial', data = NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 ,])
summary(modAttendence23WhenChickPbdurlong)

#dataset T1-13
NestCheck[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 ,c('Attendence23YN','ClutchID','MIDFID','M_ID','F_ID','Treatments','DayBrood','NumChicks','MIDPbdurlong')]


{# nb pairs having chicks
length(unique(NestCheck$MIDFID[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'C']))	# 35 pairs C
length(unique(NestCheck$MIDFID[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'NC'])) # 28 pairs NC
}

{# percentages of Attendence3YN

# firt 4 days if chicks
sum(NestCheck$Attendence3YN[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'C'& (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60))])/ length((NestCheck$Attendence3YN[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'C'& (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60))]))	# 0.1291759 C

sum(NestCheck$Attendence3YN[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'NC'& (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60))])/ length((NestCheck$Attendence3YN[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'NC'& (NestCheck$Date <= ( NestCheck$MinHatchDate +4*24*60*60))]))	#  0.05084746 NC


# all days with chicks
sum(NestCheck$Attendence3YN[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'C'])/ length((NestCheck$Attendence3YN[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'C']))	# 0.06440958 C

sum(NestCheck$Attendence3YN[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'NC'])/ length((NestCheck$Attendence3YN[NestCheck$MIDFID%in%MIDFIDOk & !(is.na(NestCheck$NumChicks)) & NestCheck$NumChicks != 0 & NestCheck$Treatments == 'NC']))	# 0.02924634 NC
}

}




	##################################################
	## 		LMER Models on Breeding Rate            ##			     
	##################################################

head(BreedingRate)

{# hist
hist(BreedingRate$Delay)
hist(BreedingRate$Delay[BreedingRate$ClutchNo != 1])
hist(BreedingRate$Delay[BreedingRate$ClutchNo != 1 & BreedingRate$prevBroodSize >1])
}

{# interval between clutches

BreedingRate$ClutchNoF <- as.factor(BreedingRate$ClutchNo)

# modDelayClutchF <- lmer (Delay ~ Treatments + prevBroodSize + ClutchNoF + scale(Year, scale=FALSE) + (1|MIDFID), data = BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk,])
# summary(modDelayClutchF)

modDelayClutchFWithoutClutch1 <- lmer (Delay ~ Treatments + prevBroodSize + ClutchNoF + scale(Year, scale=FALSE) + (1|MIDFID), data = BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo != 1,])
summary(modDelayClutchFWithoutClutch1)


# modDelayClutchCov <- lmer (Delay ~ Treatments + prevBroodSize + ClutchNo + scale(Year, scale=FALSE) + (1|MIDFID), data = BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk,])
# summary(modDelayClutchCov)






databreedingrate <- BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo != 1,]

modDelayClutchCovWithoutClutch1 <- lmer (Delay ~ -1+Treatments + prevBroodSize + ClutchNo + scale(Year, scale=FALSE) + (1|MIDFID), data = databreedingrate)
summary(modDelayClutchCovWithoutClutch1)

modDelayClutchCovWithoutClutch1withoutTrt <- lmer (Delay ~ prevBroodSize + ClutchNo + scale(Year, scale=FALSE) + (1|MIDFID), data = databreedingrate)
summary(modDelayClutchCovWithoutClutch1withoutTrt)


anova(modDelayClutchCovWithoutClutch1,modDelayClutchCovWithoutClutch1withoutTrt)	# p = 0.5743	(p = 0.5106 if pair 1119011187 excluded)



modDelayClutchCovWithoutClutch1 <- lmer (Delay ~ Treatments + scale(prevBroodSize, scale=FALSE) + scale(ClutchNo, scale=FALSE) + scale(Year, scale=FALSE) + (1|MIDFID), data = databreedingrate)
summary(modDelayClutchCovWithoutClutch1)
# 34.1975 +-  1.3581
# 33.0918 +- 1.4534

modDelayClutchCovWithoutClutch1withoutTrt <- lmer (Delay ~ scale(prevBroodSize, scale=FALSE) + scale(ClutchNo, scale=FALSE) + scale(Year, scale=FALSE) + (1|MIDFID), data = databreedingrate)
summary(modDelayClutchCovWithoutClutch1withoutTrt)


anova(modDelayClutchCovWithoutClutch1,modDelayClutchCovWithoutClutch1withoutTrt)

# dataset T1-12
databreedingrate[,c('Delay','MIDFID','Year','prevBroodSize','ClutchNo','FIDPbdurlong')]






modDelayClutchCovWithoutClutch1withoutBroodSize0 <- lmer (Delay ~ Treatments + prevBroodSize + ClutchNo + scale(Year, scale=FALSE) + (1|MIDFID), data = BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo != 1 & BreedingRate$prevBroodSize !=0 ,])
summary(modDelayClutchCovWithoutClutch1withoutBroodSize0)


modDelayClutchFWithoutClutch1withoutBroodSize0 <- lmer (Delay ~ Treatments + prevBroodSize + ClutchNoF + scale(Year, scale=FALSE) + (1|MIDFID), data = BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo != 1 & BreedingRate$prevBroodSize !=0 ,])
summary(modDelayClutchFWithoutClutch1withoutBroodSize0)


modDelayClutchFWithoutClutch1withoutBroodSize0withFL <- lmer (Delay ~ Treatments + prevFLSize + ClutchNoF + scale(Year, scale=FALSE) + (1|MIDFID), data = BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo != 1 & BreedingRate$prevBroodSize !=0 ,])
summary(modDelayClutchFWithoutClutch1withoutBroodSize0withFL)


modDelayClutchFWithoutClutch1withoutBroodSize0withJuv <- lmer (Delay ~ Treatments + prevJuvSize + ClutchNoF + scale(Year, scale=FALSE) + (1|MIDFID), data = BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo != 1 & BreedingRate$prevBroodSize !=0 ,])
summary(modDelayClutchFWithoutClutch1withoutBroodSize0withJuv)

modDelayClutchFWithoutClutch1withoutJuvSize0withJuv <- lmer (Delay ~ Treatments + prevJuvSize + scale(Year, scale=FALSE) + (1|MIDFID), data = BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo != 1 & BreedingRate$ClutchNo == 3 ,])
summary(modDelayClutchFWithoutClutch1withoutJuvSize0withJuv)

{# percentages
BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo != 1,c('ClutchNo','MIDFID','Treatments','Year','nbFL','nbJuvOut','prevBroodSize','prevFLSize','prevJuvSize','Delay')]

BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$ClutchNo ==5,c('ClutchNo','MIDFID','Treatments','Year','nbFL','nbJuvOut','prevBroodSize','prevFLSize','prevJuvSize','Delay')]

nrow(BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$Treatments == 'C',c('ClutchNo','MIDFID','Treatments','Year','nbFL','nbJuvOut','prevBroodSize','prevFLSize','prevJuvSize','Delay')])	#117

nrow(BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$Treatments == 'NC',c('ClutchNo','MIDFID','Treatments','Year','nbFL','nbJuvOut','prevBroodSize','prevFLSize','prevJuvSize','Delay')])	#100


nrow(BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$Treatments == 'C' & BreedingRate$BroodSize !=0,c('ClutchNo','MIDFID','Treatments','Year','nbFL','nbJuvOut','prevBroodSize','prevFLSize','prevJuvSize','Delay')])	#87

length(unique(BreedingRate$MIDFID[BreedingRate$MIDFIDyr%in%MIDFIDYearOk & BreedingRate$Treatments == 'C' & BreedingRate$BroodSize !=0]))	#34

# 2.558824 clutches with at least 1 chick day 8 for C pairs


nrow(BreedingRate[BreedingRate$MIDFID%in%MIDFIDOk & BreedingRate$Treatments == 'NC' & BreedingRate$BroodSize !=0 ,c('ClutchNo','MIDFID','Treatments','Year','nbFL','nbJuvOut','prevBroodSize','prevFLSize','prevJuvSize','Delay')])	#62

length(unique(BreedingRate$MIDFID[BreedingRate$MIDFIDyr%in%MIDFIDYearOk & BreedingRate$Treatments == 'NC' & BreedingRate$BroodSize !=0]))	#25

# 2.48 clutches with at least 1 chick day 8 for NC pairs
}

{# Pbdur effect

modDelayClutchCovWithoutClutch1withPbdurlong <- lmer (Delay ~ FIDPbdurlong+ Treatments + scale(prevBroodSize, scale=FALSE) + scale(ClutchNo, scale=FALSE) + scale(Year, scale=FALSE) + (1|MIDFID), data = databreedingrate)
summary(modDelayClutchCovWithoutClutch1withPbdurlong)


modDelayClutchCovWithoutClutch1withoutPbdurlong <- lmer (Delay ~ Treatments +scale(prevBroodSize, scale=FALSE) + scale(ClutchNo, scale=FALSE) + scale(Year, scale=FALSE) + (1|MIDFID), data = databreedingrate)
summary(modDelayClutchCovWithoutClutch1withoutPbdurlong)


anova(modDelayClutchCovWithoutClutch1withPbdurlong,modDelayClutchCovWithoutClutch1withoutPbdurlong)
}


}










	##################################################
	## 	           PCA live observations            ##
	##################################################	
	
names(Pairs)
head(Pairs)	
require(psych) # for "principal"

{# as.numeric(as.character(var pca))
Pairs$w1Maggr <- as.numeric(as.character(Pairs$w1Maggr))
Pairs$w1Faggr <- as.numeric(as.character(Pairs$w1Faggr))
Pairs$w1PairAggr <- as.numeric(as.character(Pairs$w1PairAggr))
Pairs$w1Mallo <- as.numeric(as.character(Pairs$w1Mallo))
Pairs$w1Fallo <- as.numeric(as.character(Pairs$w1Fallo))
Pairs$w1PairAllo <- as.numeric(as.character(Pairs$w1PairAllo))
Pairs$w1Mus <- as.numeric(as.character(Pairs$w1Mus))
Pairs$w1MeanDist <- as.numeric(as.character(Pairs$w1MeanDist))
Pairs$w1Synchrony <- as.numeric(as.character(Pairs$w1Synchrony))
Pairs$w1PropBack <- as.numeric(as.character(Pairs$w1PropBack))
Pairs$w1Mateguarding <- as.numeric(as.character(Pairs$w1Mateguarding))
Pairs$w1AbsMateguarding <- as.numeric(as.character(Pairs$w1AbsMateguarding))
Pairs$w1MeanZsqrtWPRates <- as.numeric(as.character(Pairs$w1MeanZsqrtWPRates))
Pairs$w1MeanZsqrtEPRates <- as.numeric(as.character(Pairs$w1MeanZsqrtEPRates))
Pairs$ranefWPResp_w1 <- as.numeric(as.character(Pairs$ranefWPResp_w1))
Pairs$ranefEPResp_w1 <- as.numeric(as.character(Pairs$ranefEPResp_w1))
Pairs$w1ZSynchrony <- as.numeric(as.character(Pairs$w1ZSynchrony))

Pairs$breedingFocal <- as.numeric(as.character(Pairs$breedingFocal))
Pairs$breedingMaggr <- as.numeric(as.character(Pairs$breedingMaggr))
Pairs$breedingFaggr <- as.numeric(as.character(Pairs$breedingFaggr))
Pairs$breedingPairAggr <- as.numeric(as.character(Pairs$breedingPairAggr))
Pairs$breedingMallo <- as.numeric(as.character(Pairs$breedingMallo))
Pairs$breedingFallo <- as.numeric(as.character(Pairs$breedingFallo))
Pairs$breedingPairAllo <- as.numeric(as.character(Pairs$breedingPairAllo))
Pairs$breedingMus <- as.numeric(as.character(Pairs$breedingMus))
Pairs$breedingMeanDist <- as.numeric(as.character(Pairs$breedingMeanDist))
Pairs$breedingSynchrony <- as.numeric(as.character(Pairs$breedingSynchrony))
Pairs$breedingPropBack <- as.numeric(as.character(Pairs$breedingPropBack ))
Pairs$breedingMateguarding <- as.numeric(as.character(Pairs$breedingMateguarding))
Pairs$breedingAbsMateguarding <- as.numeric(as.character(Pairs$breedingAbsMateguarding))
Pairs$breedingMeanZsqrtWPRate <- as.numeric(as.character(Pairs$breedingMeanZsqrtWPRate))
Pairs$breedingMeanZsqrtEPRate <- as.numeric(as.character(Pairs$breedingMeanZsqrtEPRate))
Pairs$ranefWPResp_breeding <- as.numeric(as.character(Pairs$ranefWPResp_breeding))
Pairs$ranefEPResp_breeding <- as.numeric(as.character(Pairs$ranefEPResp_breeding))
Pairs$breedingZSynchrony <- as.numeric(as.character(Pairs$breedingZSynchrony))

Pairs$nbALLFocal <- as.numeric(as.character(Pairs$nbALLFocal))
Pairs$ALLMaggr <- as.numeric(as.character(Pairs$ALLMaggr))
Pairs$ALLFaggr <- as.numeric(as.character(Pairs$ALLFaggr))
Pairs$ALLPairAggr <- as.numeric(as.character(Pairs$ALLPairAggr))
Pairs$ALLMallo <- as.numeric(as.character(Pairs$ALLMallo))
Pairs$ALLFallo <- as.numeric(as.character(Pairs$ALLFallo))
Pairs$ALLPairAllo <- as.numeric(as.character(Pairs$ALLPairAllo))
Pairs$ALLMus <- as.numeric(as.character(Pairs$ALLMus))
Pairs$ALLMeanDist <- as.numeric(as.character(Pairs$ALLMeanDist))
Pairs$ALLSynchrony <- as.numeric(as.character(Pairs$ALLSynchrony))
Pairs$ALLPropBack <- as.numeric(as.character(Pairs$ALLPropBack))
Pairs$ALLMateguarding <- as.numeric(as.character(Pairs$ALLMateguarding))
Pairs$ALLAbsMateguarding <- as.numeric(as.character(Pairs$ALLAbsMateguarding))
Pairs$ALLMeanZsqrtWPRate <- as.numeric(as.character(Pairs$ALLMeanZsqrtWPRate))
Pairs$ALLMeanZsqrtEPRate <- as.numeric(as.character(Pairs$ALLMeanZsqrtEPRate))
Pairs$ranefWPResp_ALL <- as.numeric(as.character(Pairs$ranefWPResp_ALL))
Pairs$ranefEPResp_ALL <- as.numeric(as.character(Pairs$ranefEPResp_ALL))
Pairs$ALLZSynchrony <- as.numeric(as.character(Pairs$ALLZSynchrony))
}

{# hist & descriptive stats 
	
{# nb of Focal pair watches for pairs that kept the Trt

# ALL
nbobsvt <- data.frame(table(AllFocal$MIDFIDyr[AllFocal$MIDFIDyr%in%MIDFIDYearOk], AllFocal$Season[AllFocal$MIDFIDyr%in%MIDFIDYearOk]))
colnames(nbobsvt) <- c('MIDFIDyr','Year','Freq')

median(nbobsvt$Freq[nbobsvt$Year == 2012 & nbobsvt$Freq != 0])	# in 2012: between 46 and 50 focal pair watches, median = 49
min(nbobsvt$Freq[nbobsvt$Year == 2012 & nbobsvt$Freq != 0]) 
max(nbobsvt$Freq[nbobsvt$Year == 2012 & nbobsvt$Freq != 0])
median(nbobsvt$Freq[nbobsvt$Year == 2013 & nbobsvt$Freq != 0])	# in 2013: between 85 and 91 focal pair watches, median = 90
min(nbobsvt$Freq[nbobsvt$Year == 2013 & nbobsvt$Freq != 0]) 
max(nbobsvt$Freq[nbobsvt$Year == 2013 & nbobsvt$Freq != 0])
sum(nbobsvt$Freq)	#5700*3

# w1
nbobsvtw1 <- data.frame(table(AllFocal$MIDFIDyr[AllFocal$MIDFIDyr%in%MIDFIDYearOk & AllFocal$Period == 'w1'], AllFocal$Season[AllFocal$MIDFIDyr%in%MIDFIDYearOk & AllFocal$Period == 'w1']))
colnames(nbobsvtw1) <- c('MIDFIDyr','Year','Freq')

median(nbobsvtw1$Freq[nbobsvtw1$Year == 2012 & nbobsvtw1$Freq != 0])	# in 2012: between 9 and 13 focal pair watches, median = 11
min(nbobsvtw1$Freq[nbobsvtw1$Year == 2012 & nbobsvtw1$Freq != 0]) 
max(nbobsvtw1$Freq[nbobsvtw1$Year == 2012 & nbobsvtw1$Freq != 0])
median(nbobsvtw1$Freq[nbobsvtw1$Year == 2013 & nbobsvtw1$Freq != 0])	# in 2013: between 16 and 21 focal pair watches, median = 21
min(nbobsvtw1$Freq[nbobsvtw1$Year == 2013 & nbobsvtw1$Freq != 0]) 
max(nbobsvtw1$Freq[nbobsvtw1$Year == 2013 & nbobsvtw1$Freq != 0])


# breeding
nbobsvtbreeding <- data.frame(table(AllFocal$MIDFIDyr[AllFocal$MIDFIDyr%in%MIDFIDYearOk & AllFocal$Period == 'breeding'], AllFocal$Season[AllFocal$MIDFIDyr%in%MIDFIDYearOk & AllFocal$Period == 'breeding']))
colnames(nbobsvtbreeding) <- c('MIDFIDyr','Year','Freq')

median(nbobsvtbreeding$Freq[nbobsvtbreeding$Year == 2012 & nbobsvtbreeding$Freq != 0])	# in 2012: between 37 and 39 focal pair watches, median = 38
min(nbobsvtbreeding$Freq[nbobsvtbreeding$Year == 2012 & nbobsvtbreeding$Freq != 0]) 
max(nbobsvtbreeding$Freq[nbobsvtbreeding$Year == 2012 & nbobsvtbreeding$Freq != 0])
median(nbobsvtbreeding$Freq[nbobsvtbreeding$Year == 2013 & nbobsvtbreeding$Freq != 0])	# in 2013: between 68 and 70 focal pair watches, median = 69
min(nbobsvtbreeding$Freq[nbobsvtbreeding$Year == 2013 & nbobsvtbreeding$Freq != 0]) 
max(nbobsvtbreeding$Freq[nbobsvtbreeding$Year == 2013 & nbobsvtbreeding$Freq != 0])



}

{# is AllFocal$Mateguarding repeatable per pairs in "ALL" ?
hist(AllFocal$Mateguarding)
modMateguardingALL <- lm(AllFocal$Mateguarding ~ AllFocal$MIDFIDyr)
summary(modMateguardingALL)
modMateguardingALL2 <- lm(AllFocal$Mateguarding ~ 1 )
summary(modMateguardingALL2)
anova(modMateguardingALL, modMateguardingALL2)	# p < 2.2e-16 ***


Mateguardingdata <- AllFocal[,c("MIDFIDyr","Mateguarding")]
meansMateguarding <- aggregate(Mateguarding ~ MIDFIDyr, Mateguardingdata, FUN=mean)
SDsMateguarding <- aggregate(Mateguarding ~ MIDFIDyr, Mateguardingdata, FUN=sd)
CMateguarding <- aggregate(Mateguarding ~ MIDFIDyr, Mateguardingdata, FUN=c)
Mateguardingdatabind <- cbind(meansMateguarding,SDsMateguarding[,2])
hist(meansMateguarding[,2])

hist(AllFocal$AbsMateguarding)
modAbsMateguardingALL <- lm(AllFocal$AbsMateguarding ~ AllFocal$MIDFIDyr)
summary(modAbsMateguardingALL)
modAbsMateguardingALL2 <- lm(AllFocal$AbsMateguarding ~ 1 )
summary(modAbsMateguardingALL2)
anova(modAbsMateguardingALL, modAbsMateguardingALL2)	# p < 2.2e-16 ***

}

{# plots Trt agains parameters live obsvt "ALL"

plot(Pairs$MTrt,as.numeric(Pairs$ALLMaggr))	# *
plot(Pairs$MTrt,as.numeric(Pairs$ALLFaggr))
plot(Pairs$MTrt,as.numeric(Pairs$ALLMallo))
plot(Pairs$MTrt,as.numeric(Pairs$ALLFallo))
plot(Pairs$MTrt,as.numeric(Pairs$ALLMus))
plot(Pairs$MTrt,as.numeric(Pairs$ALLMeanDist))
plot(Pairs$MTrt,as.numeric(Pairs$ALLSynchrony))
plot(Pairs$MTrt,as.numeric(Pairs$ALLPropBack))
plot(Pairs$MTrt,as.numeric(Pairs$ALLZsqrtMeanWPRate))
plot(Pairs$MTrt,as.numeric(Pairs$ALLZsqrtMeanMEPRate))
plot(Pairs$MTrt,as.numeric(Pairs$ranefWPResp_ALL))
plot(Pairs$MTrt,as.numeric(Pairs$ranefEPResp_ALL))

plot(Pairs$MTrt,as.numeric(Pairs$w1Maggr))
plot(Pairs$MTrt,as.numeric(Pairs$w1Faggr))
plot(Pairs$MTrt,as.numeric(Pairs$w1Mallo))
plot(Pairs$MTrt,as.numeric(Pairs$w1Fallo))
plot(Pairs$MTrt,as.numeric(Pairs$w1Mus))	# * opposite direction
plot(Pairs$MTrt,as.numeric(Pairs$w1MeanDist))	# **
t.test(as.numeric(as.character(Pairs$w1MeanDist[Pairs$MTrt == 'C'])),as.numeric(as.character(Pairs$w1MeanDist[Pairs$MTrt == 'NC'])), na.action =na.omit)	#p = 0.002919
plot(Pairs$MTrt,as.numeric(Pairs$w1Synchrony))	# *
t.test(as.numeric(as.character(Pairs$w1Synchrony[Pairs$MTrt == 'C'])),as.numeric(as.character(Pairs$w1Synchrony[Pairs$MTrt == 'NC'])), na.action =na.omit)	#p = 0.02813
plot(Pairs$MTrt,as.numeric(Pairs$w1PropBack))
plot(Pairs$MTrt,as.numeric(Pairs$w1ZsqrtMeanWPRate))
plot(Pairs$MTrt,as.numeric(Pairs$w1ZsqrtMeanMEPRate))	# *
t.test(as.numeric(as.character(Pairs$w1ZsqrtMeanMEPRate[Pairs$MTrt == 'C'])),as.numeric(as.character(Pairs$w1ZsqrtMeanMEPRate[Pairs$MTrt == 'NC'])), na.action =na.omit)	#p = 0.023
plot(Pairs$MTrt,as.numeric(Pairs$ranefWPResp_w1))
plot(Pairs$MTrt,as.numeric(Pairs$ranefEPResp_w1))
}

{# correlation between sexes on aggr and allo 	> create variable PairAggr and PairAllo ?
cor.test(Pairs$w1Mallo,Pairs$w1Fallo)							# r = 0.1619215		p = 0.1411
cor.test(Pairs$ALLMallo,Pairs$ALLFallo)							# r = 0.3298735		p = 0.002182 ***
cor.test(Pairs$ALLMaggr,Pairs$ALLFaggr)							# r = 0.1565854		p = 0.1549
cor.test(Pairs$w1Maggr,Pairs$w1Faggr)							# r = 0.1641351		p = 0.1357
}

{# Correlations w1 - breeding

head(Pairs)
cor.test(Pairs$w1Maggr, Pairs$breedingMaggr)						# r = -0.08722125	p = 0.4302
cor.test(Pairs$w1Faggr, Pairs$breedingFaggr)						# r = -0.07728405	p = 0.4847
cor.test(Pairs$w1Mallo, Pairs$breedingMallo)						# r = 0.2785308		p = 0.0103 *
cor.test(Pairs$w1Fallo, Pairs$breedingFallo)						# r = -0.00049837	p = 0.9964
cor.test(Pairs$w1Mus, Pairs$breedingMus)							# r = 0.3361497		p = 0.001771 **
cor.test(Pairs$w1MeanDist, Pairs$breedingMeanDist)					# r = -0.05037967	p = 0.649
cor.test(Pairs$w1Synchrony, Pairs$breedingSynchrony)				# r = 0.235924		p = 0.03074 *
cor.test(Pairs$w1PropBack, Pairs$breedingPropBack)					# r = 0.08554319	p = 0.4391
cor.test(Pairs$w1Mateguarding, Pairs$breedingMateguarding)			# r = 0.3454277		p = 0.00129 **
cor.test(Pairs$w1ZsqrtMeanWPRate, Pairs$breedingZsqrtMeanWPRate)	# r = 0.1817587		p = 0.09799
cor.test(Pairs$w1ZsqrtMeanMEPRate, Pairs$breedingZsqrtMeanMEPRate)	# r = 0.4693989		p = 6.663e-06 ***
cor.test(Pairs$ranefWPResp_w1, Pairs$ranefWPResp_breeding)			# r = 0.4051279		p = 0.000132 ***
cor.test(Pairs$ranefEPResp_w1, Pairs$ranefEPResp_breeding)			# r = 0.2613777		p = 0.01632 *
}

{# t.tests difference in pca variables between season 
# WP and EP courtship rate > Z transform (Live: change of focus, video: inclusion of short courtships)

head(Pairs)
head(AllCourtshipRates)

{# Courtships rates videos
t.test(AllCourtshipRates$w1SumRateWP[AllCourtshipRates$Season == 2012], AllCourtshipRates$w1SumRateWP[AllCourtshipRates$Season == 2013])	#   0.01603776 0.02923206  p = 0.0003455 **
t.test(AllCourtshipRates$breedingSumRateWP[AllCourtshipRates$Season == 2012], AllCourtshipRates$breedingSumRateWP[AllCourtshipRates$Season == 2013])	#   0.007258315 0.007887527  p = 0.5516

t.test(AllCourtshipRates$w1SumRateEP[AllCourtshipRates$Season == 2012], AllCourtshipRates$w1SumRateEP[AllCourtshipRates$Season == 2013])	#   0.00395215 0.01053267  p = 0.02429 *
t.test(AllCourtshipRates$breedingSumRateEP[AllCourtshipRates$Season == 2012], AllCourtshipRates$breedingSumRateEP[AllCourtshipRates$Season == 2013])	#   0.008152131 0.011196920  p = 0.07104
}

{# Courtships rates live
t.test(AllCourtshipRates$w1RateWPLive[AllCourtshipRates$Season == 2012], AllCourtshipRates$w1RateWPLive[AllCourtshipRates$Season == 2013])	#   0.007518682 0.013723545 p = 0.001415 **
t.test(AllCourtshipRates$breedingRateWPLive[AllCourtshipRates$Season == 2012], AllCourtshipRates$breedingRateWPLive[AllCourtshipRates$Season == 2013])	#   0.002349248 0.006029709  p = 7.331e-05 ***

t.test(AllCourtshipRates$w1RateEPLive[AllCourtshipRates$Season == 2012], AllCourtshipRates$w1RateEPLive[AllCourtshipRates$Season == 2013])	#   0.001864322 0.004273504 p = 0.06223
t.test(AllCourtshipRates$breedingRateEPLive[AllCourtshipRates$Season == 2012], AllCourtshipRates$breedingRateEPLive[AllCourtshipRates$Season == 2013])	#  0.003680957 0.010703880  p = 1.4e-07 ***
}

{# Courtship rate duration in videos

head(AllCourt)

t.test(AllCourt$DisplaySec[AllCourt$Year == 2012 & AllCourt$FWEU == 'WP'], AllCourt$DisplaySec[AllCourt$Year == 2013 & AllCourt$FWEU == 'WP'])	
# 9.715931  8.470945 p = 7.142e-07 ***
t.test(AllCourt$DisplaySec[AllCourt$Year == 2012 & AllCourt$FWEU == 'EP'], AllCourt$DisplaySec[AllCourt$Year == 2013 & AllCourt$FWEU == 'EP'])	
# 6.061338  4.848943 p = 7.837e-10 ***
}

{# t- tests
t.test(Pairs$w1PairAggr[Pairs$Season == 2012], Pairs$w1PairAggr[Pairs$Season == 2013])	# 0.01562635 0.02930403 ; p = 0.1101
t.test(Pairs$w1PairAllo[Pairs$Season == 2012], Pairs$w1PairAllo[Pairs$Season == 2013])	# 0.3337823 0.2845849 ; p = 0.1831
t.test(Pairs$w1Maggr[Pairs$Season == 2012], Pairs$w1Maggr[Pairs$Season == 2013])	# 0.01175430 0.01343101; p = 0.8054
t.test(Pairs$w1Mallo[Pairs$Season == 2012], Pairs$w1Mallo[Pairs$Season == 2013])	#  0.2396659 0.2174298 ; p = 0.4937
t.test(Pairs$w1Faggr[Pairs$Season == 2012], Pairs$w1Faggr[Pairs$Season == 2013])	#   0.007744108 0.017094017  ; p = 0.1585
t.test(Pairs$w1Fallo[Pairs$Season == 2012], Pairs$w1Fallo[Pairs$Season == 2013])	#  0.1505051 0.1136142 ; p = 0.1571
t.test(Pairs$w1MeanDist[Pairs$Season == 2012], Pairs$w1MeanDist[Pairs$Season == 2013])	#  45.06465  49.06393  ; p = 0.3935
t.test(Pairs$w1Synchrony[Pairs$Season == 2012], Pairs$w1Synchrony[Pairs$Season == 2013])	#    78.60672  68.86778 ; p = 4.966e-09 ***
t.test(Pairs$w1Mateguarding[Pairs$Season == 2012], Pairs$w1Mateguarding[Pairs$Season == 2013])	#   0.7706553 0.5099206; p = 0.1486
t.test(Pairs$w1PropBack[Pairs$Season == 2012], Pairs$w1PropBack[Pairs$Season == 2013])	#   0.8954566 0.8765328 ; p = 0.3667
t.test(Pairs$w1MeanZsqrtWPRate[Pairs$Season == 2012], Pairs$w1MeanZsqrtWPRate[Pairs$Season == 2013])	# -3.096867e-16  1.139802e-17 ; p = 1
t.test(Pairs$w1MeanZsqrtEPRate[Pairs$Season == 2012], Pairs$w1MeanZsqrtEPRate[Pairs$Season == 2013])	#  -1.227510e-16 -4.051646e-16  ; p = 1
t.test(Pairs$w1Mus[Pairs$Season == 2012], Pairs$w1Mus[Pairs$Season == 2013])	# 0.1571182 0.1124542  ; p = 0.05965
t.test(Pairs$w1ZSynchrony[Pairs$Season == 2012], Pairs$w1ZSynchrony[Pairs$Season == 2013])	# 9.893861e-17 7.796303e-16  ; p = 1


t.test(Pairs$breedingPairAggr[Pairs$Season == 2012], Pairs$breedingPairAggr[Pairs$Season == 2013])	# 0.005264779 0.001858045 ; p = 0.1785
t.test(Pairs$breedingPairAllo[Pairs$Season == 2012], Pairs$breedingPairAllo[Pairs$Season == 2013])	# 0.11272649 0.09247804 ; p = 0.2492
t.test(Pairs$breedingMaggr[Pairs$Season == 2012], Pairs$breedingMaggr[Pairs$Season == 2013])	# 0.003525388 0.001114827; p = 0.2135
t.test(Pairs$breedingMallo[Pairs$Season == 2012], Pairs$breedingMallo[Pairs$Season == 2013])	# 0.08521720 0.07056357 ; p = 0.3269
t.test(Pairs$breedingFaggr[Pairs$Season == 2012], Pairs$breedingFaggr[Pairs$Season == 2013])	#  0.0017393912 0.0007432181 ; p = 0.4208
t.test(Pairs$breedingFallo[Pairs$Season == 2012], Pairs$breedingFallo[Pairs$Season == 2013])	#  0.05789919 0.03789382 ; p = 0.1199
t.test(Pairs$breedingMeanDist[Pairs$Season == 2012], Pairs$breedingMeanDist[Pairs$Season == 2013])	# 118.4627  127.9005 ; p = 0.1247
t.test(Pairs$breedingSynchrony[Pairs$Season == 2012], Pairs$breedingSynchrony[Pairs$Season == 2013])	#  43.15420  37.93061 ; p = 0.01566**
t.test(Pairs$breedingMateguarding[Pairs$Season == 2012], Pairs$breedingMateguarding[Pairs$Season == 2013])	# 0.1799929 0.0990232; p = 0.3299
t.test(Pairs$breedingPropBack[Pairs$Season == 2012], Pairs$breedingPropBack[Pairs$Season == 2013])	# 0.8041769 0.8342617 ; p = 0.05877
t.test(Pairs$breedingMeanZsqrtWPRate[Pairs$Season == 2012], Pairs$breedingMeanZsqrtWPRate[Pairs$Season == 2013])# -1.207380e-18 -1.108708e-16; p = 1
t.test(Pairs$breedingMeanZsqrtEPRate[Pairs$Season == 2012], Pairs$breedingMeanZsqrtEPRate[Pairs$Season == 2013])# 3.401010e-16 -1.871013e-17; p = 1
t.test(Pairs$breedingMus[Pairs$Season == 2012], Pairs$breedingMus[Pairs$Season == 2013])	# 0.1697965 0.1794730  ; p = 0.5396
t.test(Pairs$breedingZSynchrony[Pairs$Season == 2012], Pairs$breedingZSynchrony[Pairs$Season == 2013])	#  5.196316e-16 -2.113749e-16  ; p = 1

}

}

{# mean AllFocal synchrony per author per period

mean(AllFocal$Synchrony[AllFocal$Author == 'TA'& AllFocal$Season == 2012 ])#51.84022
mean(AllFocal$Synchrony[AllFocal$Author == 'MI' & AllFocal$Season == 2012 ])#46.99391
mean(AllFocal$Synchrony[AllFocal$Author == 'JS'& AllFocal$Season == 2012 ])# 52.40683

mean(AllFocal$Synchrony[AllFocal$Author == 'TA'& AllFocal$Season == 2013 ])#62.18434
mean(AllFocal$Synchrony[AllFocal$Author == 'MI' & AllFocal$Season == 2013 ])#40.52823
mean(AllFocal$Synchrony[AllFocal$Author == 'AE'& AllFocal$Season == 2013 ])# 43.28417


mean(AllFocal$Synchrony[AllFocal$Author == 'TA'& AllFocal$Season == 2012 & AllFocal$Period == 'w1' ])#78.6808
mean(AllFocal$Synchrony[AllFocal$Author == 'MI' & AllFocal$Season == 2012 & AllFocal$Period == 'w1' ])#73.9899
mean(AllFocal$Synchrony[AllFocal$Author == 'JS'& AllFocal$Season == 2012 & AllFocal$Period == 'w1' ])#79.65517

mean(AllFocal$Synchrony[AllFocal$Author == 'TA'& AllFocal$Season == 2013 & AllFocal$Period == 'w1' ])#73.71324
mean(AllFocal$Synchrony[AllFocal$Author == 'MI' & AllFocal$Season == 2013 & AllFocal$Period == 'w1' ])#59.5679
mean(AllFocal$Synchrony[AllFocal$Author == 'AE'& AllFocal$Season == 2013 & AllFocal$Period == 'w1' ])#73.43173


mean(AllFocal$Synchrony[AllFocal$Author == 'TA'& AllFocal$Season == 2012 & AllFocal$Period == 'breeding' ])#42.69956
mean(AllFocal$Synchrony[AllFocal$Author == 'MI' & AllFocal$Season == 2012 & AllFocal$Period == 'breeding' ])#42.2043
mean(AllFocal$Synchrony[AllFocal$Author == 'JS'& AllFocal$Season == 2012 & AllFocal$Period == 'breeding' ])#44.48898

mean(AllFocal$Synchrony[AllFocal$Author == 'TA'& AllFocal$Season == 2013 & AllFocal$Period == 'breeding' ])#49.9349
mean(AllFocal$Synchrony[AllFocal$Author == 'MI' & AllFocal$Season == 2013 & AllFocal$Period == 'breeding' ])#35.44346
mean(AllFocal$Synchrony[AllFocal$Author == 'AE'& AllFocal$Season == 2013 & AllFocal$Period == 'breeding' ])#37.54682





}

}



{### PCA w1

{# PCA w1 _ 8  all variables with Ztransformed per year WPRate, EPRate, Synchrony without w1Mus
pcaw1_8 <- Pairs[,c("w1Maggr","w1Faggr","w1Mallo","w1Fallo","w1MeanDist","w1ZSynchrony","w1PropBack","w1MeanZsqrtWPRates","w1MeanZsqrtEPRates","ranefWPResp_w1","ranefEPResp_w1","w1Mateguarding")]

modpcaw1_8  <- prcomp(pcaw1_8, scale=T)
biplot(modpcaw1_8 )

modpcaw1_8 <- principal(pcaw1_8,nfactors=1, rotate="varimax", scores=TRUE)
modpcaw1_8
modpcaw1_8$scores

}

{# PCA w1 _ 9   all variables with Ztransformed per year WPRate, EPRate, Synchrony without ranef resp
pcaw1_9 <- Pairs[,c("w1Maggr","w1Faggr","w1Mallo","w1Fallo","w1Mus","w1MeanDist","w1ZSynchrony","w1PropBack","w1MeanZsqrtWPRate","w1MeanZsqrtEPRate","w1Mateguarding")]

modpcaw1_9  <- prcomp(pcaw1_9, scale=T)
biplot(modpcaw1_9 )

modpcaw1_9 <- principal(pcaw1_9,nfactors=1, rotate="varimax", scores=TRUE)
modpcaw1_9
modpcaw1_9$scores

}

# index scores pcaw1x to Pairs
Pairs <- cbind(Pairs,as.data.frame(as.vector(modpcaw1_8$scores)))
colnames(Pairs)[colnames(Pairs) == 'as.vector(modpcaw1_8$scores)'] <- 'pcaw1'
head(Pairs)

{# does Trt predict pcaw1 ?								> **
modPairTrt <- lm(Pairs$pcaw1 ~ Pairs$MTrt)
summary(modPairTrt)	# p = 0.00696 ** (pcaw1_8)	# without Mus p = 0.0143 *
t.test(Pairs$pcaw1[Pairs$MTrt=="NC"],Pairs$pcaw1[Pairs$MTrt=="C"])	# p = 0.008866 **	# without Mus p-value = 0.01672
t.test(Pairs$pcaw1[Pairs$MTrt=="NC"],Pairs$pcaw1[Pairs$MTrt=="C"], var.equal = T)	# p = 0.006965 ** 	# without Mus p-value = 0.01428
plot(Pairs$pcaw1 ~ Pairs$MTrt)
}

{# does pcaw1 + Trt predict pair fitness?				> pcaw1 trendy?		> Trt *
modPairfit <- lm(Pairs$RelfitnessWPTrtOk ~ Pairs$pcaw1 + Pairs$MTrt)
summary(modPairfit)	
# pcaw1: p = 0.2979 ; Trt: p = 0.0453 * (pcaw1_8)


summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$pcaw1))	# p = 0.0926 .   # without Mus: p =  0.11

plot(Pairs$RelfitnessWPTrtOk ~ Pairs$pcaw1, col = Pairs$MTrt)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$pcaw1))

cor.test(Pairs$RelfitnessWPTrtOk ,Pairs$pcaw1)

}

}

# data set live observation pre breeding period
Pairs[,c('MIDFID','RelfitnessWPTrtOk','pcaw1', "w1Maggr","w1Faggr","w1Mallo","w1Fallo","w1MeanDist","w1ZSynchrony","w1PropBack","w1MeanZsqrtWPRates","w1MeanZsqrtEPRates","ranefWPResp_w1","ranefEPResp_w1","w1Mateguarding")]
#write.table(Pairs[,c('MIDFID','RelfitnessWPTrtOk','pcaw1', "w1Maggr","w1Faggr","w1Mallo","w1Fallo","w1MeanDist","w1ZSynchrony","w1PropBack","w1MeanZsqrtWPRates","w1MeanZsqrtEPRates","ranefWPResp_w1","ranefEPResp_w1","w1Mateguarding")], file = "R_LivePre.xls", sep="\t", col.names=TRUE)



{### PCA breeding

{# PCA breeding all variables (but Mus)

pcabreeding <- Pairs[,c("breedingMaggr","breedingFaggr","breedingMallo","breedingFallo","breedingMeanDist","breedingZSynchrony","breedingPropBack","breedingMeanZsqrtWPRate","breedingMeanZsqrtEPRate","ranefWPResp_breeding","ranefEPResp_breeding","breedingMateguarding")]

modpcabreeding <- prcomp(pcabreeding, scale=T)
print(modpcabreeding)
biplot(modpcabreeding)

Modpcabreeding <- principal(pcabreeding,nfactors=1, rotate="varimax", scores=TRUE) # the most similar to Wolfgang in SPSS
Modpcabreeding
Modpcabreeding$scores
}

# index scores pcabreedingx to Pairs
Pairs <- cbind(Pairs,as.data.frame(as.vector(Modpcabreeding$scores)))
colnames(Pairs)[colnames(Pairs) == 'as.vector(Modpcabreeding$scores)'] <- 'pcabreeding'
head(Pairs)

{# does Trt predict pcabreeding ?							> NS
modPairTrt <- lm(Pairs$pcabreeding ~ Pairs$MTrt)
summary(modPairTrt)	# p = 0.963 # without Mus: 0.909
t.test(Pairs$pcabreeding[Pairs$MTrt=="NC"],Pairs$pcabreeding[Pairs$MTrt=="C"])	# p = 0.9628
t.test(Pairs$pcabreeding[Pairs$MTrt=="NC"],Pairs$pcabreeding[Pairs$MTrt=="C"], var.equal = T)
plot(Pairs$pcabreeding ~ Pairs$MTrt)
}

{# does pcabreeding + Trt predict pair fitness?				> pcabreeding **		> Trt *
modPairfit <- lm(Pairs$RelfitnessWPTrtOk ~ Pairs$pcabreeding + Pairs$MTrt)
summary(modPairfit)	
# pcabreeding: p = 0.00109 ** ; Trt: p = 0.01093 * 

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$pcabreeding))	# p = 0.00149 **  # without Mus: 0.00218 ** 
plot(Pairs$RelfitnessWPTrtOk ~ Pairs$pcabreeding, col = Pairs$MTrt)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$pcabreeding))


}

}

# data set live observation during breeding period
Pairs[,c('pcabreeding', 'RelfitnessWPTrtOk', 'MIDFID',"breedingMaggr","breedingFaggr","breedingMallo","breedingFallo","breedingMeanDist","breedingZSynchrony","breedingPropBack","breedingMeanZsqrtWPRate","breedingMeanZsqrtEPRate","ranefWPResp_breeding","ranefEPResp_breeding","breedingMateguarding")]
#write.table(Pairs[,c('pcabreeding', 'RelfitnessWPTrtOk', 'MIDFID',"breedingMaggr","breedingFaggr","breedingMallo","breedingFallo","breedingMeanDist","breedingZSynchrony","breedingPropBack","breedingMeanZsqrtWPRate","breedingMeanZsqrtEPRate","ranefWPResp_breeding","ranefEPResp_breeding","breedingMateguarding")], file = "R_LiveBreeding.xls", sep="\t", col.names=TRUE)



{### correlation variables (w1-breeding-ALL) with fitness or Trt

{# does any variable 'w1' predict pair fitness?			>  . PairAggr(wrong), Maggr(wrong), MeanDist, PropBack

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1PairAggr))	# . (wrong direction)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1PairAllo))

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1Maggr))	# . (wrong direction)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1Mallo))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1Faggr))	
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1Fallo))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1MeanDist))	# . (right direction)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1ZSynchrony))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1Mateguarding))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1PropBack))	# . (right direction)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1MeanZsqrtWPRate))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1MeanZsqrtEPRate))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ranefWPResp_w1))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ranefEPResp_w1))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$w1Mus))
}

{# does any variable 'breeding' predict pair fitness?	> * (-)	for PairAggr,PairAllo,Mallo,Fallo,Faggr,WPRate,EPResp ; . (-) Maggr,ZSynchro ; . (+) Dist

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAggr))	# * (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAllo))	# ** (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMaggr))	# . (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMallo))	# ** (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingFaggr))	# * (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingFallo))	# * (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMeanDist))	# . (+)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingSynchrony))	# * (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingZSynchrony))	# . (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMateguarding))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPropBack))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMeanZsqrtWPRate))	# ** (-_
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMeanZsqrtEPRate))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ranefWPResp_breeding))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ranefEPResp_breeding))	# * (-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMus))


plot((Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAggr), col = Pairs$MTrt)	# * (-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAggr))			# 6 pairs (low fitness, high aggr)

plot((Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAllo), col = Pairs$MTrt)	# **  (-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAllo))			# 12 pairs (low fitness, high allo)

plot((Pairs$RelfitnessWPTrtOk ~ Pairs$breedingZSynchrony), col = Pairs$MTrt)	# . (-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingZSynchrony))			# 14 pairs (low fitness, high sync)

plot((Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMeanZsqrtWPRate), col = Pairs$MTrt)	# *	(-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMeanZsqrtWPRate))			# 11 pairs (low fitness, high WP rate)

plot((Pairs$RelfitnessWPTrtOk ~ Pairs$ranefEPResp_breeding), col = Pairs$MTrt)	# * (-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ranefEPResp_breeding))		# 3 pairs (low fitness, high EP resp) (but 3 pairs, with opposite)

}

{# does any variable 'ALL' predict pair fitness?		> * (-) for WPRate ; . for Mallo,ZSynchro,EPResp

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLPairAggr))	
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLPairAllo))	
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLMaggr))	
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLMallo))	# .
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLFaggr))	
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLFallo))	
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLMeanDist))	
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLSynchrony))	# .
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLZSynchrony))	# .
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLMateguarding))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLPropBack))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLMeanZsqrtWPRate))	# *	(-)
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ALLMeanZsqrtEPRate))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ranefWPResp_ALL))
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ranefEPResp_ALL))	# . (-)

}


{# does any variable 'w1' predict Trt?				NC	> ** (+) distance, * (-) Synchr, * (+) EPRate

summary(lm(Pairs$w1PairAggr ~ Pairs$MTrt))	
summary(lm(Pairs$w1PairAllo ~ Pairs$MTrt))

summary(lm(Pairs$w1Maggr ~ Pairs$MTrt))	
summary(lm(Pairs$w1Maggr ~ -1+Pairs$MTrt))

summary(lm(Pairs$w1Mallo ~ Pairs$MTrt))
summary(lm(Pairs$w1Mallo ~ -1+Pairs$MTrt))

summary(lm(Pairs$w1Faggr ~ Pairs$MTrt))	
summary(lm(Pairs$w1Faggr ~ -1+Pairs$MTrt))	

summary(lm(Pairs$w1Fallo ~ Pairs$MTrt))
summary(lm(Pairs$w1Fallo ~ -1+Pairs$MTrt))

summary(lm(Pairs$w1MeanDist ~ Pairs$MTrt))	# ** (bad)
summary(lm(Pairs$w1MeanDist ~ -1+Pairs$MTrt))	

summary(lm(Pairs$w1ZSynchrony ~ Pairs$MTrt))	# * (good)
summary(lm(Pairs$w1ZSynchrony ~ -1+Pairs$MTrt))

summary(lm(Pairs$w1Mateguarding ~ Pairs$MTrt))
summary(lm(Pairs$w1Mateguarding ~ -1+Pairs$MTrt))

summary(lm(Pairs$w1PropBack ~ Pairs$MTrt))	
summary(lm(Pairs$w1PropBack ~ -1+Pairs$MTrt))

summary(lm(Pairs$w1MeanZsqrtWPRate ~ Pairs$MTrt))
summary(lm(Pairs$w1MeanZsqrtWPRate ~ -1+Pairs$MTrt))

summary(lm(Pairs$w1MeanZsqrtEPRate ~ Pairs$MTrt))	# *
summary(lm(Pairs$w1MeanZsqrtEPRate ~ -1+Pairs$MTrt))

summary(lm(Pairs$ranefWPResp_w1 ~ Pairs$MTrt))
summary(lm(Pairs$ranefWPResp_w1 ~ -1+Pairs$MTrt))

summary(lm(Pairs$ranefEPResp_w1 ~ Pairs$MTrt))
summary(lm(Pairs$ranefEPResp_w1 ~ -1+Pairs$MTrt))

summary(lm(Pairs$w1Mus ~ Pairs$MTrt))

}

{# does any variable 'breeding' predict Trt?		NC	> none

summary(lm(Pairs$breedingPairAggr ~ Pairs$MTrt))
summary(lm(Pairs$breedingPairAllo ~ Pairs$MTrt))

summary(lm(Pairs$breedingMaggr ~ Pairs$MTrt))	
summary(lm(Pairs$breedingMaggr ~ -1+Pairs$MTrt))

summary(lm(Pairs$breedingMallo ~ Pairs$MTrt))
summary(lm(Pairs$breedingMallo ~ -1+Pairs$MTrt))

summary(lm(Pairs$breedingFaggr ~ Pairs$MTrt))	
summary(lm(Pairs$breedingFaggr ~ -1+Pairs$MTrt))	

summary(lm(Pairs$breedingFallo ~ Pairs$MTrt))
summary(lm(Pairs$breedingFallo ~ -1+Pairs$MTrt))

summary(lm(Pairs$breedingMeanDist ~Pairs$MTrt))	
summary(lm(Pairs$breedingMeanDist ~-1+Pairs$MTrt))	

summary(lm(Pairs$breedingZSynchrony ~ Pairs$MTrt))	
summary(lm(Pairs$breedingZSynchrony ~ -1+Pairs$MTrt))	

summary(lm(Pairs$breedingMateguarding ~ Pairs$MTrt))
summary(lm(Pairs$breedingMateguarding ~ -1+Pairs$MTrt))

summary(lm(Pairs$breedingPropBack ~ Pairs$MTrt))
summary(lm(Pairs$breedingPropBack ~ -1+Pairs$MTrt))
	
summary(lm(Pairs$breedingMeanZsqrtWPRate ~ Pairs$MTrt))
summary(lm(Pairs$breedingMeanZsqrtWPRate ~ -1+Pairs$MTrt))

summary(lm(Pairs$breedingMeanZsqrtEPRate ~ Pairs$MTrt))	
summary(lm(Pairs$breedingMeanZsqrtEPRate ~ -1+Pairs$MTrt))	

summary(lm(Pairs$ranefWPResp_breeding ~ Pairs$MTrt))
summary(lm(Pairs$ranefWPResp_breeding ~ -1+Pairs$MTrt))

summary(lm(Pairs$ranefEPResp_breeding ~ Pairs$MTrt))
summary(lm(Pairs$ranefEPResp_breeding ~ -1+Pairs$MTrt))

summary(lm(Pairs$breedingMus ~ Pairs$MTrt))	

}

{# does any variable 'ALL' predict Trt?				NC 	> * (-) WPResp

summary(lm(Pairs$ALLPairAggr ~ Pairs$MTrt))
summary(lm(Pairs$ALLPairAllo ~ Pairs$MTrt))
summary(lm(Pairs$ALLMaggr ~ Pairs$MTrt))	
summary(lm(Pairs$ALLMallo ~ Pairs$MTrt))
summary(lm(Pairs$ALLFaggr ~ Pairs$MTrt))	
summary(lm(Pairs$ALLFallo ~ Pairs$MTrt))
summary(lm(Pairs$ALLMeanDist ~ Pairs$MTrt))	
summary(lm(Pairs$ALLSynchrony ~ Pairs$MTrt))
summary(lm(Pairs$ALLZSynchrony ~ Pairs$MTrt))
summary(lm(Pairs$ALLMateguarding ~ Pairs$MTrt))
summary(lm(Pairs$ALLPropBack ~ Pairs$MTrt))	
summary(lm(Pairs$ALLMeanZsqrtWPRate ~ Pairs$MTrt))
summary(lm(Pairs$ALLMeanZsqrtEPRate ~ Pairs$MTrt))	
summary(lm(Pairs$ranefWPResp_ALL ~ Pairs$MTrt))	# * (-)
summary(lm(Pairs$ranefEPResp_ALL ~ Pairs$MTrt))
summary(lm(Pairs$ALLMus ~ Pairs$MTrt))	

}

}


{### in Pairs13Stay, does Trt predict pcaw1 ?				> NS

pairsStay
pairsStay$MIDFID2013 <- paste(pairsStay$MIDFID, '2013', sep='')

Pairs13 <- Pairs[Pairs$Season == 2013,]

for (i in 1: nrow(Pairs13))
{
if(Pairs13$MIDFIDyr[i]%in%pairsStay$MIDFID2013)
{Pairs13$StayYN[i] <- 1}
else {Pairs13$StayYN[i] <- 0}
}

Pairs13Stay <- Pairs13[Pairs13$StayYN == 1,]

modPairs13StayTrt <- lm(Pairs13Stay$pcaw1 ~ Pairs13Stay$MTrt)
summary(modPairs13StayTrt )	# p = 0.292
t.test(Pairs13Stay$pcaw1[Pairs13Stay$MTrt=="NC"],Pairs13Stay$pcaw1[Pairs13Stay$MTrt=="C"])	# p = 0.2934
plot(Pairs13Stay$pcaw1 ~ Pairs13Stay$MTrt)

}

{### in Pairs12Stay, does Trt predict pcaw1 ?				> *

pairsStay
Pairs12 <- Pairs[Pairs$Season == 2012,]

for (i in 1: nrow(Pairs12))
{
if(Pairs12$MIDFIDyr[i]%in%pairsStay$MIDFIDyr)
{Pairs12$StayYN[i] <- 1}
else {Pairs12$StayYN[i] <- 0}
}

Pairs12Stay <- Pairs13[Pairs12$StayYN == 1,]

modPairs12StayTrt <- lm(Pairs12Stay$pcaw1 ~ Pairs12Stay$MTrt)
summary(modPairs12StayTrt )	# p = 0.0187 *
t.test(Pairs12Stay$pcaw1[Pairs12Stay$MTrt=="NC"],Pairs12Stay$pcaw1[Pairs12Stay$MTrt=="C"])	# p = 0.06624
plot(Pairs12Stay$pcaw1 ~ Pairs12Stay$MTrt)

}


{## exploration link between fitness and breeding_variables : is it because some pairs are not busy with breeding ?

head(NestCheck)
NestCheck$MIDFIDyr <- paste (NestCheck$MIDFID, NestCheck$Year, sep='')

NestCheck_listperMIDFIDyr <- split(NestCheck, NestCheck$MIDFIDyr)
x <- NestCheck_listperMIDFIDyr[[1]]

NestCheck_listperMIDFIDyr_fun <- function(x) {
return(c(
nrow(x[!is.na(x$NumEggs) & x$NumEggs != 0 & !is.na(x$NumChicks) & x$NumChicks == 0,]), # nbDayswithEggs
nrow(x[!is.na(x$NumEggs) & x$NumEggs != 0 & !is.na(x$NumChicks) & x$NumChicks == 0 & x$Incubated > 0,]), # nbDayswithEggsInc
nrow(x[is.na(x$NumChicks) | x$NumChicks != 0,])  # nbDayswithChicks
))
}

NestCheck_listperMIDFIDyr_out1 <- lapply(NestCheck_listperMIDFIDyr, FUN=NestCheck_listperMIDFIDyr_fun)
NestCheck_listperMIDFIDyr_out2 <- data.frame(rownames(do.call(rbind, NestCheck_listperMIDFIDyr_out1)),do.call(rbind, NestCheck_listperMIDFIDyr_out1))
rownames(NestCheck_listperMIDFIDyr_out2) <- NULL
colnames(NestCheck_listperMIDFIDyr_out2) <- c('MIDFIDyr','nbDayswithEggs','nbDayswithEggsInc','nbDayswithChicks')

Pairs <- merge(y = NestCheck_listperMIDFIDyr_out2[,c('MIDFIDyr','nbDayswithEggs','nbDayswithEggsInc','nbDayswithChicks')], x = Pairs, by.y = 'MIDFIDyr', by.x = "MIDFIDyr", all.x=TRUE)
head(Pairs)

{# check if extreme pairs appear extreme several times
plot(Pairs$pcabreeding ~ Pairs$nbDayswithEggs)
plot(Pairs$pcabreeding ~ Pairs$nbDayswithEggsInc)
plot(Pairs$pcabreeding ~ Pairs$nbDayswithChicks)

plot(Pairs$RelfitnessWPTrtOk ~ Pairs$nbDayswithEggs)
plot(Pairs$RelfitnessWPTrtOk ~ Pairs$nbDayswithEggsInc)
plot(Pairs$RelfitnessWPTrtOk ~ Pairs$nbDayswithChicks)

# > * (-)	for PairAggr,PairAllo,Mallo,Fallo,Faggr,WPRate,EPResp ; . (-) Maggr,ZSynchro ; . (+) Dist

plot((Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAggr), col = Pairs$MTrt)	# * (-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAggr))			# 10 pairs (low fitness, high aggr)
Z <- as.data.frame(Pairs$MIDFIDyr[Pairs$breedingPairAggr > 0.01])
colnames(Z) <- 'MIDFIDyr'

plot(Pairs$breedingPairAggr ~ Pairs$nbDayswithEggs)
plot(Pairs$breedingPairAggr ~ Pairs$nbDayswithEggsInc)
plot(Pairs$breedingPairAggr ~ Pairs$nbDayswithChicks)


plot((Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAllo), col = Pairs$MTrt)	# **  (-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingPairAllo))			# 8 pairs (low fitness, high allo)
Z1 <- as.data.frame(Pairs$MIDFIDyr[Pairs$breedingPairAllo > 0.2])
colnames(Z1) <- 'MIDFIDyr'

plot(Pairs$breedingPairAllo ~ Pairs$nbDayswithEggs)
plot(Pairs$breedingPairAllo ~ Pairs$nbDayswithEggsInc)
plot(Pairs$breedingPairAllo ~ Pairs$nbDayswithChicks)


plot((Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMeanZsqrtWPRate), col = Pairs$MTrt)	# *	(-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$breedingMeanZsqrtWPRate))			# 10 pairs (low fitness, high WP rate)
Z2 <- as.data.frame(Pairs$MIDFIDyr[Pairs$breedingMeanZsqrtWPRate > 1])
colnames(Z2) <- 'MIDFIDyr'

plot(Pairs$breedingMeanZsqrtWPRate ~ Pairs$nbDayswithEggs)
plot(Pairs$breedingMeanZsqrtWPRate ~ Pairs$nbDayswithEggsInc)
plot(Pairs$breedingMeanZsqrtWPRate ~ Pairs$nbDayswithChicks)


plot((Pairs$RelfitnessWPTrtOk ~ Pairs$ranefEPResp_breeding), col = Pairs$MTrt)	# * (-)
abline(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$ranefEPResp_breeding))		# 4 pairs (low fitness, high EP resp) (but 3 pairs, with opposite)
Z3 <- as.data.frame(Pairs$MIDFIDyr[Pairs$ranefEPResp_breeding > 0.05])
colnames(Z3) <- 'MIDFIDyr'

plot(Pairs$ranefEPResp_breeding ~ Pairs$nbDayswithEggs)
plot(Pairs$ranefEPResp_breeding ~ Pairs$nbDayswithEggsInc)
plot(Pairs$ranefEPResp_breeding ~ Pairs$nbDayswithChicks)


ZALL <- rbind(Z, Z1)
ZALL <- rbind(ZALL, Z2)
ZALL <- rbind(ZALL, Z3)
z <- as.data.frame(table(ZALL))
z <- z[z$Freq > 1,]

z <- merge (x = z, y = Pairs[,c('MIDFIDyr','RelfitnessWPTrtOk','nbDayswithEggs','nbDayswithEggsInc','nbDayswithChicks','MTrt')], by.x = 'ZALL', by.y = 'MIDFIDyr', all.x = TRUE)
z

}

mean(Pairs$nbDayswithEggs, na.rm = T) # 35.12048
mean(Pairs$nbDayswithEggsInc, na.rm = T) # 32.25301
mean(Pairs$nbDayswithChicks, na.rm = T) # 35.27711
mean(Pairs$RelfitnessWPTrtOk, na.rm = T) # 0.9865476

for (i in 1:nrow(Pairs))
{
Pairs$SumDaysEggsIncOrChicks[i] <- Pairs$nbDayswithEggsInc[i]+ Pairs$nbDayswithChicks[i]
}

Pairs$SumDaysEggsIncOrChicks[Pairs$FIDYear == '112202012'] <- 0

require(QuantPsyc)

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks + Pairs$breedingPairAggr))	# pPairAggr = 0.0174 *
summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks + Pairs$breedingPairAllo))

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMaggr))
cor.test(Pairs$RelfitnessWPTrtOk , Pairs$breedingMaggr)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMaggr))

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMallo))	
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingMallo)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMallo))

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingFaggr))	# *
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingFaggr)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingFaggr))

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingFallo))
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingFallo)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingFallo))

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMeanDist))
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingMeanDist)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMeanDist))

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingSynchrony))	

summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingZSynchrony))	
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingZSynchrony)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingZSynchrony))


summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMateguarding))
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingMateguarding)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMateguarding))


summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingPropBack))
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingPropBack)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingPropBack))


summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMeanZsqrtWPRate))	
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingMeanZsqrtWPRate)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMeanZsqrtWPRate))


summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMeanZsqrtEPRate))
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$breedingMeanZsqrtEPRate)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$breedingMeanZsqrtEPRate))


summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$ranefWPResp_breeding))
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$ranefWPResp_breeding)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$ranefWPResp_breeding))


summary(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$ranefEPResp_breeding))	# *
cor.test(Pairs$RelfitnessWPTrtOk,Pairs$ranefEPResp_breeding)
lm.beta(lm(Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks +Pairs$ranefEPResp_breeding))




summary(lm (Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks + Pairs$breedingMeanZsqrtWPRate))


summary(lm (Pairs$RelfitnessWPTrtOk ~ Pairs$SumDaysEggsIncOrChicks + Pairs$ranefEPResp_breeding))	# pEPResp = 0.00581 ** 


modPairfit <- lm(Pairs$RelfitnessWPTrtOk ~ Pairs$pcabreeding)
summary(modPairfit)	# p = 0.00218 ** 

modPairfitcovar <- lm(Pairs$RelfitnessWPTrtOk ~ Pairs$pcabreeding + Pairs$SumDaysEggsIncOrChicks)
summary(modPairfitcovar)	# p = 0.93010
cor.test(Pairs$pcabreeding,Pairs$RelfitnessWPTrtOk)
lm.beta(modPairfitcovar)

}

{# correlation between covariate (nb of days actively breeding) and explanatory variable to fitness

cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingMaggr)	# p-value = 0.522
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingMallo)	# p-value = 1.699e-09 ***, cor =-0.599409 (-)
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingFaggr)	# p-value = 0.3855
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingFallo)	# p-value = 2.37e-06 ***, cor =-0.4889365 (-)
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingMeanDist)	# p-value = 9.209e-10 ***, cor =0.6071311 (+)
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingZSynchrony)	# p-value = 3.03e-09 ***, cor =-0.5919245 (-)
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingMateguarding)	# p-value = 0.04265 *, cor =-0.2217391 (-)
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingPropBack)	# p-value = 0.1144
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingMeanZsqrtWPRate)	# p-value = 7.563e-10 ***, cor =-0.6095698 (-)
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$breedingMeanZsqrtEPRate)	# p-value = 0.7293
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$ranefWPResp_breeding)	# p-value = 0.7067
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$ranefEPResp_breeding)	# p-value = 0.4392
cor.test(Pairs$SumDaysEggsIncOrChicks,Pairs$pcabreeding)	# p-value = 4.239e-16 ***, cor = -0.7453646 (-)
}




head(NestChecksubsetforNestActivity,40)

{## Nest activity ~ Trt



modNestActivityBoth <- glmer(NestBothYN ~ Treatments + ClutchNo + DayClutch +(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), data = NestChecksubsetforNestActivity, family='binomial')
summary(modNestActivityBoth)

modNestActivityM <- glmer(NestMYN ~ Treatments + ClutchNo + DayClutch+(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), data = NestChecksubsetforNestActivity,family='binomial')
summary(modNestActivityM)

modNestActivityF <- glmer(NestFYN ~ Treatments + ClutchNo + DayClutch +(1|MIDFID) + (1|M_ID) + (1|F_ID) +(1|ClutchID), data = NestChecksubsetforNestActivity,family='binomial')
summary(modNestActivityF)










}






	#######################################################################################
	## Analyses of tables Fitness from thirds breeding season, the so called Divorce exp ##
	#######################################################################################
	
{# import summary fitness tables from excel file in parentage assignment folder 	
	
Female2014 <- read.table("FemaleFitness2014.txt", header=TRUE, sep='\t')
Male2014 <- read.table("MaleFitness2014.txt", header=TRUE, sep='\t')
}

Female2014
Male2014

{# test significance of slopes

plot(Female2014$RelFit~Female2014$FTRT)
abline(lm(Female2014$RelFit~Female2014$FTRT))
summary(lm(Female2014$RelFit~Female2014$FTRT))

# 1.08 CC
# 1.0762-0.1923 = 0.8839 NCNC


plot(Male2014$RelFit~Male2014$MTRT)
abline(lm(Male2014$RelFit~Male2014$MTRT))
summary(lm(Male2014$RelFit~Male2014$MTRT))

# 1.0956 CC
# 1.0956-0.1916 = 0.904 NCNC
}




















































{################################### Model assumption checking rules ##############################################################


# for lm
anova(mod)
drop1(mod, test="F")	#Each term is tested as it was the last entering the model-> After correcting for all the other predictors, does the term reduce the residual variance?
plot(mod)
qqnorm(resid(mod))
qqline(resid(mod))
#model comparison anova mod with and without the Trt

#for lmer
xyplot(y~treatment|nest)
qqnorm(resid(mod))
qqline(resid(mod))
qqnorm(unlist(ranef(mod)))
qqline(unlist(ranef(mod)))
# no p value
#-> give confidence intervals instead of p-values
#-> give credible intervals (Bayesian method)
#-> if you cannot do without p-values use likelihood ratio
#	tests and bootstrap the test statistics


# for glm
#Terms added sequentially (first to last)
par(mfrow=c(2,2))   
plot(modSurviveVSHatchedMalesOnlyTrt)
#model comparison anova mod with and without the Trt
#overdispersion is present if dispersion parameter(residual deviance/residual df ) is > 1
qqnorm(resid(mod))
qqline(resid(mod))
drop1(mod, test='Chi')
predict.glm(mod)
# if quasipoisson, quasibinomial: drop1 (modquasi, test='F')


# for glmer
qqnorm(resid(mod))
qqline(resid(mod))
qqnorm(unlist(ranef(mod)))
qqline(unlist(ranef(mod)))
plot(fitted(mod), resid(mod))
abline(h=0)
scatter.smooth(fitted(mod), resid(mod))
abline(h=0, lty=2)
scatter.smooth(Data$[,1], resid(mod))
abline(h=0, lty=2)

# for bernouilli glmer: no need to care about overdispersion


# overdispersion: deviance and residual df (between nb obs rand fact 1 and nb obs rand factor 2) should be in balance

#REML gives unbiased estimates for the variance components
#but are biased in the variance of the fixed effects
#ML ( variance component (within; between) biased,
#fixed effect variance non biased
#is needed for likelihood ratio tests and model comparison
#by AIC-like criteria 
#1.use REML to analyse the random model structure (based on the maximal fixed effect model)
#2. switch to ML to finde the most appropriate fixed effect model
}


