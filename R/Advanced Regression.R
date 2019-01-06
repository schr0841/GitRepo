#################
# ISYE 6501 HW5 #
#################

#Load relevant libraries
library(glmnet)
library(DAAG)
library(FrF2)

################
# Problem 11.1 #
################

# Part 1 - Stepwise#

#Load crime dataset
crime<-read.csv("5.1uscrimeSummer2018.txt", stringsAsFactors = FALSE, 
                header=TRUE, sep='\t')

#Backwards stepwise
model_1 <- lm(Crime ~ ., data=crime)
step(model_1, direction="backward")

#Forward stepwise
model_2 <- lm(Crime ~ 1, data=crime)
step(model_2, scope=formula(lm(Crime ~ ., data=crime)), direction="forward")

#Both stepwise
model_3 <- lm(Crime ~ ., data=crime)
step(model_3, scope=list(lower=formula(lm(Crime ~ 1, data=crime)), 
                         upper=formula(lm(Crime ~ ., data=crime))), direction="both")


# Part 2 - Lasso #

#Standardize data and convert to matrix format
#Removing columns 2 and 16:
Crime <- crime[,16]
So <- crime[,2]
crime<-crime[,-16]
crime<-crime[,-2]

#Scaling with relevant variables removed
scaledCrime <- scale(crime)

#Adding the variables back:
scaledCrime <- cbind(scaledCrime, So, Crime)

#Convert to a matrix
matrixCrime <- as.matrix(scaledCrime)

# Implement Lasso
set.seed(42)
#Run cv.glmnet with alpha=1 to obtain optimal lambda
cvlasso <- cv.glmnet(x=matrixCrime[,1:15],y=matrixCrime[,16], 
                     type.measure="mse", standardize=FALSE, family="gaussian", 
                     alpha=1)

#Run lasso
lasso<-glmnet(matrixCrime[,1:15],matrixCrime[,16], 
              lambda = cvlasso$lambda.1se, standardize=FALSE, family="gaussian",
              alpha=1)

#Extract coefficients of this model
coef(lasso)

#Plot mse vs lambda
plot(cvlasso)

#Minimum lambda found
cvlasso$lambda.min



# Part 3 - Elastic Net #

#Set a range of alpha values to search over
a <- seq(0.001, 0.999, 0.005)

#Elastic net implementation
search <- foreach(i = a, .combine = rbind) %do% {
  cv <- cv.glmnet(matrixCrime[,1:15], matrixCrime[,16], family = "gaussian", 
                  standardize=FALSE, nfold = 10, type.measure = "deviance", alpha = i)
  data.frame(cvm = cv$cvm[cv$lambda == cv$lambda.1se], lambda.1se = cv$lambda.1se, alpha = i)
}
cv3 <- search[search$cvm == min(search$cvm), ]
md3 <- glmnet(matrixCrime[,1:15], matrixCrime[,16], family = "gaussian", 
              standardize=FALSE, lambda = cv3$lambda.1se, alpha = cv3$alpha)

#Print optimal lambda and alpha value:
#Lambda
cv3$lambda.1se

#alpha
cv3$alpha

#Model coefficients
coef(md3)

#Final models obtained from these techniques
forwardStep <- lm(formula = Crime ~ Po1 + Ineq + Ed + M + Prob + U2, data = crime)
backwardStep <- lm(formula = Crime ~ M + Ed + Po1 + M.F + U1 + U2 + Ineq + Prob, data=crime)
bothStep <- lm(formula = Crime ~ M + Ed + Po1 + M.F + U1 + U2 + Ineq + Prob, data=crime)
lassoModel <- lm(Crime ~ M + Po1 +M.F + Ineq + Prob, data=crime)
eNetModel <- lm(Crime ~  M + Ed + Po1+ Po2 + M.F + NW + U2 + Ineq + Prob, data=crime)

summary(forwardStep)
summary(backwardStep) #M.F not significant
summary(bothStep) #M.F not significant
summary(lassoModel)
summary(eNetModel) #Po2, M.F, NW not significant

#5-fold Cross validation of models (bothStep and backwardStep had the same model):
forwardcv <- cv.lm(data=crime, form.lm=forwardStep, m=5, dots=FALSE, seed=42, plotit=FALSE)
bothcv <- cv.lm(data=crime, form.lm=bothStep, m=5, dots=FALSE, seed=42, plotit=FALSE)
lassocv <- cv.lm(data=crime, form.lm=lassoModel, m=5, dots=FALSE, seed=42, plotit=FALSE)
eNetcv <- cv.lm(data=crime, form.lm=eNetModel, m=5, dots=FALSE, seed=42, plotit=FALSE)


#Getting relevant data to calculate R^2 adjusted
mse_1 <- attr(forwardcv, "ms")
mse_2 <- attr(bothcv, "ms")
mse_3 <- attr(lassocv, "ms")
mse_4 <- attr(eNetcv, "ms")

# N = nrow(crime)
N = 47

#Compute Sum of Squared Regression
SSR_1 <- mse_1 * N
SSR_2 <- mse_2 * N
SSR_3 <- mse_3 * N
SSR_4 <- mse_4 * N

crime<-read.csv("5.1uscrimeSummer2018.txt", stringsAsFactors = FALSE, 
                header=TRUE, sep='\t')

#Total sum of squares
SST <- sum((crime$Crime-mean(crime$Crime))^2)


#Computing R^2 = 1 - SSR/SST
R2_1 <- 1-SSR_1/SST
R2_2 <- 1-SSR_2/SST
R2_3 <- 1-SSR_3/SST
R2_4 <- 1-SSR_4/SST

#Calculate adjusted R^2 for each model
#R^2_adj = 1-[(1-R^2)(n-1)]/[n-k-1]

#for model 1, k=6
AdjR2_1 <- 1-((1-R2_1)*(N-1))/(N-6-1)
AdjR2_1 

#for model 2, k=8
AdjR2_2 <- 1-((1-R2_2)*(N-1))/(N-8-1)
AdjR2_2 

#for model 2, k=5
AdjR2_3 <- 1-((1-R2_3)*(N-1))/(N-5-1)
AdjR2_3 

#for model 2, k=9
AdjR2_4 <- 1-((1-R2_4)*(N-1))/(N-9-1)
AdjR2_4 



################
# Problem 12.2 #
################

set.seed(42)

#nruns=16 nfactors=10
FrF2(nruns=16, nfactors=10)

