options(width=100, userFancyQuotes=FALSE)
rm(list=ls())
#install.packages("ggrepel_0.9.1") 
#install.packages("semPlot_1.1.6") 
#install.packages("lavaan_0.6-12") 
#install.packages("corrplot_0.92") 
#install.packages("stargazer_5.2.3") 
#install.packages("progress_1.2.2") 
#install.packages("xtable_1.8-4") 
#install.packages("dplyr_1.0.10") 
#install.packages("vars_1.5-6") 
#install.packages("lmtest_0.9-40") 
#install.packages("urca_1.3-3") 
#install.packages("strucchange_1.5-3")
#install.packages("sandwich_3.0-2") 
#install.packages("MASS_7.3-57") 
#install.packages("reshape2_1.4.4") 
#install.packages("ggplot2_3.3.6") 
#install.packages("pheatmap_1.0.12") 
#install.packages("ranger_0.14.1") 
#install.packages("glmnet_4.1-4") 
#install.packages("gtrendsR_1.5.1") 
#install.packages("yuima_1.15.15") 
#install.packages("mvtnorm_1.1-3") 
#install.packages("cubature_2.0.4.4") 
#install.packages("expm_0.999-6") 
#install.packages("data.table_1.14.2") 
#install.packages("quantmod_0.4.20") 
#install.packages("TTR_0.24.3") 
#install.packages("xts_0.12.1") 
#install.packages("zoo_1.8-10") 
#install.packages("Matrix_1.4-1")
Rm(list=ls())
library(xts)
library(quantmod)
library(data.table)
library(yuima)
library(gtrendsR)
library(glmnet)
library(ranger) 
library(pheatmap) 
library(ggplot2) 
library(reshape2) 
library(vars) 
library(dplyr)
library(xtable) 
library(progress) 
library(stargazer) 
library(corrplot) 
library(lavaan) 
library(semPlot) 
library(ggrepel) 

start.date <- "2018-01-01" 
start.period <- "2018-01-01/"
full.period <- "2018-01-01/2018-12-31"

#eigen data laden
Sentimentdata= read_xlsl("data/data2018.xlsx")
head(data2018)
attach(data2018)


# colors
makeColorRampPalette <- function(colors, cutoff.fraction, num.colors.in.palette)
{
  stopifnot(length(colors) == 4)
  ramp1 <- colorRampPalette(colors[1:2])(num.colors.in.palette * cutoff.fraction)
  ramp2 <- colorRampPalette(colors[3:4])(num.colors.in.palette * (1 - cutoff.fraction))
  return(c(ramp1, ramp2))
}
cutoff.distance <- 0.5 
cols <- makeColorRampPalette(c("white", "steelblue", # distances 0 to 3 colored from white to red
                                      "steelblue", "red"), # distances 3 to max(distmat) colored from green to black
                                      cutoff.distance ,
                             100)



# Download the data locally (moeet nog vervangen worden)
load("iData.rda")



var.ita <- c("swbi", "iDeaths", "iCases",
             "FTSEMIB", "iCoronaVirus", "iCoronaVirusNews",
             "iCovid", "iCovidNews", "iRt", "iUnemployment",
             "iUnemploymentNews", "iEconomy", "iEconomyNews", 
             "iGDP", "iGDPNews", "iStress", "iDepression",
             "iHealth", "iSolitude", "iInsomnia", "iResidential",
             "iWorkplace",
             "ipm25", "itemperature", "iWuhan", "iAdultContent",
             "ilockdown",
             "iFB.CLI","iFB.ILI","iFB.MC","iFB.DC","iFB.HF")



# progressive
itmpL <- cbind(itmp, stats::lag(itmp[,"swbi"],1)) 
colnames(itmpL)[ncol(itmpL)] <- "swbiLag"
var.itaL <- c(var.ita,"swbiLag")

dati <- data.frame(na.approx(itmpL["/2018-12-31",var.itaL],rule=2))
dati <- data.frame( scale( dati ))

iperiods <- c("2018-01",
              "2018-02",
              "2018-03",
              "2018-04",
              "2018-05",
              "2018-06",
              "2018-07",
              "2018-08",
              "2018-09",
              "2018-10",
              "2018-11",
              "2018-01/2018-11"
)

incc <- length(var.itaL)-1
inpp <- length(iperiods)
iPV <- matrix(NA, inpp,incc)
iCC <- matrix(NA, inpp,incc)
ik <- 0
for(iper in iperiods){
  ik <- ik+1
  iSub <- data.frame(na.approx(itmpL[iper,var.itaL],rule=2))
  for(i in 1:ncol(iSub)){
    ux <- which(is.na(iSub[,i]))
    if(length(ux)>0){
      iSub[ux,i] <- 0
    }
  } 
  for(j in 1:incc){
    itmpc <- na.omit(cbind(iSub[,1],iSub[,j+1]))
    ict <- cor.test(itmpc[,1],itmpc[,2],method = "spearman")
    iCC[ik,j] <- ict$estimate
    iPV[ik,j] <- ict$p.value
  }
}
iCC[is.na(iCC)] <- 0
iPV[is.na(iPV)] <- 1
iCC[iPV>0.05] <- 0


rownames(iCC) <- rownames(iPV) <- 
  c("Jan 2018", "Feb 2018", "Mar 2018", "Apr 2018",
    "Mei 2018", "Jun 2018", "Jul 2018", "Aug 2018",
    "Sep 2018", "Oct 2018", "Nov2018", "Year 2018")
colnames(iCC) <- colnames(iPV) <- colnames(iSub)[-1]
corcol <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
iCr <- iCC[,-grep("swb",colnames(iCC))]

icol.order <- try(hclust(dist(t(iCr)))$order, TRUE)


# Monthly correlation plots (IT)
corrplot(iCr[,icol.order],col=corcol(100),tl.col="black", tl.srt=45)
pdf("corItaly.pdf",width=9,height=6)
corrplot(iCr[,icol.order],col=corcol(100),tl.col="black", tl.srt=45)
dev.off()

# DynENET (IT)
idates <- rownames(dati)
lambda <- seq(1e-6,1,length=250)
imsem <- NULL
imse1 <- NULL
imsear <- NULL
intercepti <- FALSE
#for(ialpha in c(0,0.5,1)){
for(ialpha in c(0.5)){
  icf1 <- NULL
  icfm <- NULL
  ircf1 <- NULL
  ircfm <- NULL
  ip1 <- NULL
  ipm <- NULL
  il1 <- NULL
  ilm <- NULL
  iar <- NULL
  ni <- nrow(dati)
  ioffset <- 31
  pb <- progress_bar$new(total = ni-ioffset)
  for(i in ioffset:(ni-1)){
    pb$tick()
    rg <- (i-ioffset+1):i
    y <- dati$swbi[rg]
    tmp.iar <- try(as.numeric(predict(arima(y,order=c(1,0,1)),n.ahead = 1)$pred), TRUE)
    if(class(tmp.iar)[1]!="try-error"){
      iar <- c(iar,tmp.iar)
    } else {
      iar <- c(iar,as.numeric(NA))
    }
    x <- as.matrix(dati[rg,colnames(dati)!="swbi"])
    x.new <- as.matrix(dati[i+1,colnames(dati)!="swbi"],nrow=1)
    set.seed(123)
    cvi <- cv.glmnet(x=x, y=y, alpha=ialpha, intercept=intercepti, lambda=lambda, grouped=FALSE)
    set.seed(123)
    inet <- glmnet(x=x, y=y, alpha=ialpha, intercept=intercepti, lambda=lambda)
    icf.1se <- coef(inet, s=cvi$lambda.1se)
    icf.min <- coef(inet, s=cvi$lambda.min)
    t1 <- data.frame(date=idates[i], t(as.matrix(icf.1se)))
    colnames(t1)[2] <- "Intercept"
    t2 <- data.frame(date=idates[i], t(as.matrix(icf.min)))
    colnames(t2)[2] <- "Intercept"
    icf1 <- rbind(icf1, t1)
    icfm <- rbind(icfm, t2)
    ip1 <- c(ip1, predict(inet, newx = x.new,s = cvi$lambda.1se))
    ipm <- c(ipm, predict(inet, newx = x.new,s = cvi$lambda.min))
    il1 <- c(il1, cvi$lambda.1se)
    ilm <- c(ilm, cvi$lambda.min)
    
    vv <- c("swbi",colnames(x)[which(as.numeric(icf.1se)!=0) -1])
    if(length(vv)>1){
      set.seed(123)
      rang <- ranger(swbi~., data=dati[rg,vv], importance="impurity",num.trees = 2500)
      imp <- sort(importance(rang), decreasing = TRUE)
      rank <- (length(imp):1)/length(imp)
      names(rank) <- names(imp)
      tmprank <- t1[,-2]
      tmprank[1,-1] <- 0
      tmprank[1, names(rank)] <- rank
      ircf1 <- rbind(ircf1, tmprank)
    }
    vv <- c("swbi",colnames(x)[which(as.numeric(icf.min)!=0) -1])
    if(length(vv)>1){
      set.seed(123)
      rang <- ranger(swbi~., data=dati[rg,vv], importance="impurity")
      imp <- sort(importance(rang), decreasing = TRUE)
      rank <- (length(imp):1)/length(imp)
      names(rank) <- names(imp)
      tmprank <- t2[,-2]
      tmprank[1,-1] <- 0
      tmprank[1, names(rank)] <- rank
      ircfm <- rbind(ircfm, tmprank)
    }
  }
  ipt <- dati$swbi[(ioffset+1):ni]
  id <- data.frame(true=ipt,p1=ip1,pm=ipm,ar=iar)
  imse1 <- c(imse1, mean((ipt-ip1)^2))
  imsem <- c(imsem, mean((ipt-ipm)^2))
  imsear <- c(imsear, mean((ipt-iar)^2,na.rm=TRUE))
  print(cor(id,use="pairwise"))
}
imse1
imsem
imsear
imse1/imsear

dati <- data.frame(na.approx(itmpL["/2020-10-11",var.itaL],rule=2))
dati <- data.frame( scale( dati ))
iyear <- year(as.Date(rownames(dati)))
imonth <- month(as.Date(rownames(dati)))
imod <- list()
k <- 0
for(iy in 2020){
  for(im in 1:9){
    idx <- which(iyear==iy & imonth==im)
    if(length(idx)>0){
      print(c(iy,im))
      k <- k+1
      isub <- dati[idx,]
      mod <- step(lm(swbi~ -1 + ., data=isub))
      imod[[k]] <- list(year=iy,mod=mod, month=im)
    }
  }
}

imodFull <- step(lm(swbi~ -1 + ., data=dati[iyear==2020 & imonth<=10,]))

mi1 <- imodFull 
mi2 <- imod[[1]]$mod
mi3 <- imod[[2]]$mod
mi4 <- imod[[3]]$mod
mi5 <- imod[[4]]$mod
mi6 <- imod[[5]]$mod
mi7 <- imod[[6]]$mod
mi8 <- imod[[7]]$mod
mi9 <- imod[[8]]$mod

IM <- stargazer::stargazer(
  mi1,mi2,mi3,mi4,mi5,
  mi6,mi7,mi8,mi9,
  no.space=TRUE, align=TRUE,
  omit.stat=c("LL","ser","f"),
  column.labels=c("Jan-Sep",
                  "Jan", "Feb", "Mar", "Apr", "May",
                  "Jun", "Jul", "Aug", "Sep"
  ),
  model.numbers=FALSE,digits = 2, dep.var.labels="SWB-I")


