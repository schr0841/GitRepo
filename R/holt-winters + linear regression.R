##############
# ISYE  6501 #
# HOMEWORK 3 #
##############

#Load Packages
library(olsrr)
require(graphics)
library(DAAG)
library(xlsx)

################
# Question 7.2 #
################

#Read in temperature data
temps=read.table("https://prod-edxapp.edx-cdn.org/assets/courseware/v1/592f3be3e90d2bdfe6a69f62374a1250/asset-v1:GTx+ISYE6501x+2T2018+type@asset+block/6.2tempsSummer2018.txt",stringsAsFactors = FALSE, header=TRUE, sep='\t')

#Convert temperature dataframe to a time series

data <- as.vector(unlist(temps[,2:ncol(temps)]))
# convert to time series 
time_series = ts(data, start=1996, frequency = 123)

#Apply Holt-Winters to this time series
temps_HW <- HoltWinters(time_series, alpha=NULL, beta=NULL, gamma=NULL, seasonal="multiplicative")
temps_HW

#Convert to a matrix
temps_HW_matrix <- matrix(temps_HW$fitted[,4],nrow=123)

#Make sure file is in your working directory! :)
file <- "solution_6.2.xls"

wb <- loadWorkbook(file)
sheets <- getSheets(wb)
sheet <- sheets[[1]]

addDataFrame(temps_HW_matrix, sheet, col.names =FALSE, row.names=FALSE, startRow=2, startColumn = 3)

saveWorkbook(wb,file)



################
# Question 8.2 #
################

#Read in dataset
crime=read.csv("http://www.statsci.org/data/general/uscrime.txt",stringsAsFactors = FALSE, header=TRUE, sep='\t')

#Create dataframe for new data point
newobs=data.frame(M = 14.0,
                  So = 0,
                  Ed = 10.0,
                  Po1 = 12.0,
                  Po2 = 15.5,
                  LF = 0.640,
                  M.F = 94.0,
                  Pop = 150,
                  NW = 1.1,
                  U1 = 0.120,
                  U2 = 3.6,
                  Wealth = 3200,
                  Ineq = 20.1,
                  Prob = 0.04,
                  Time = 39.0)

#QQplot on Crime variable - checking suitability of data for linReg

qqplot(crime$Crime, crime$Pop)


#Bartlett test for Heteroskedasticity in Crime and Pop

ols_test_bartlett(crime, Crime, Pop)

#Regress Crime as a function of all other variables

lm1<-lm(Crime ~., data=crime)

#Summary statistics including R squared and adjusted R squared
summary(lm1)

predict(lm1,newdata=newobs)

#Compute best predictors in stepwise fashion
#Warning - takes approx 15 minutes on an Intel i7-7700k
k<-ols_step_all_possible(lm1)

#model parameters that yielded best fit - criterion: maximum Adjusted R^2

which.max(k[,5])

k[16384,]

#This process yields the following simpler model with 8 predictors:

lm2<-lm(Crime ~ M + Ed + Po1 + M.F +U1 + U2 + Ineq + Prob, data=crime)

summary(lm2)


#Assess quality of model with all predictors

model_1_cv <- cv.lm(crime, lm1, m=5, seed=42)


#Assess quality of new model

model_2_cv <- cv.lm(crime, lm2, m=5, seed=42)

#Getting relevant data to calculate R^2 adjusted

mse_1 <- attr(model_1_cv, "ms")
mse_2 <- attr(model_2_cv, "ms")

# N = nrow(crime)
N = nrow(crime)

#Compute Sum of Squared Regression
SSR_1 <- mse_1 * N
SSR_2 <- mse_2 * N

#Total sum of squares
SST <- sum((crime$Crime-mean(crime$Crime))^2)


#Computing R^2 = 1 - SSR/SST
R2_1 <- 1-SSR_1/SST
R2_1
R2_2 <- 1-SSR_2/SST
R2_2

#Calculate adjusted R^2 for each model
#R^2_adj = 1-[(1-R^2)(n-1)]/[n-k-1]

#for model 1, k=15
AdjR2_1 <- 1-((1-R2_1)*(N-1))/(N-15-1)
AdjR2_1 

#for model 2, k=8
AdjR2_2 <- 1-((1-R2_2)*(N-1))/(N-8-1)
AdjR2_2 

#The final computation has us compute the prediction for the newdata using lm2:
predict(lm2,newdata=newobs)
