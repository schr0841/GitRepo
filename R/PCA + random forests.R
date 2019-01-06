################
# ISYE6501 HW4 #
################

#Load libraries
library(mdatools)
library(tree)
library(rpart)
library(InformationValue)
library(randomForest)

################
# Question 9.1 #
################

#Set seed so results are reproducible
set.seed(1)

#Read in data
crime<-read.csv("http://www.statsci.org/data/general/uscrime.txt",
                stringsAsFactors = FALSE, header=TRUE, sep='\t')

#Get eigenvalues / eigenvectors
matrixCrime<-as.matrix(crime)

XTX<-t(matrixCrime)%*%matrixCrime
eig<-eigen(XTX)

#Run PCA on matrix of scaled data
pca <- prcomp(crime[,1:15], scale=TRUE)
summary(pca)
pca$x

#Need to decide how many variables - 6, based on summary(pca) output
#Make regression model based on the pca to predict crime
PCcrime <- cbind(pca$x[,1:6],crime[,16])

#Make regression model
lm1 <- lm(PCcrime[,7] ~ ., data=as.data.frame(PCcrime[,1:6]))

#View summary output
summary(lm1)


#Specify your new model in terms of the original variables (not the PC's) and compare to your solution from 8.2.
#Translate coefficients
coef <- lm1$coefficients[2:length(lm1$coefficients)]%*%t(pca$rotation[,1:(length(lm1$coefficients)-1)])

#Unscale coefficients and intercept
intercept <- lm1$coefficients[1]-sum(coef*sapply(crime[,1:15],mean)/sapply(crime[,1:15],sd))
coef <- coef/sapply(crime[,1:15],sd)

#Compare estimates and actuals
estimates <- as.matrix(crime[,1:15])%*%t(coef)+intercept
t(estimates)

crime[,16]

sum(estimates-crime[,16])

#Model estimates times new data should yield the prediction for the Crime value:

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

#Dot product to get prediction for new city
as.matrix(coef)%*%t(as.matrix(newobs))


#EXTRA: perform cross validation and evaluate a larger number or all of the PCA models

#Cross-validated pca with 3&4 fold cv
pca_cv_3 <- pca(as.matrix(crime[,1:15]), scale=TRUE, cv=3)
#pca_cv_4 <- pca(as.matrix(crime[,1:15]), scale=TRUE, cv=4)

#Setting the model to select the first 6 components
model<-selectCompNum(pca_cv_3,6)

#Summary output of these models
summary(pca_cv_3)
#summary(pca_cv_4)

#Cross-validation results for folds=3&4
plot(pca_cv_3)
#plot(pca_cv_4)



####################
# Question 10.1(a) #
####################

#Read in data
crime<-read.csv("http://www.statsci.org/data/general/uscrime.txt",
                stringsAsFactors = FALSE, header=TRUE, sep='\t')

tree.data<-tree(Crime ~ ., data=crime)

summary(tree.data)

#Notice that only 4 predictors were used in the construction of this tree

# More information about the way the tree was split
tree.data$frame

# Plot the regression tree
plot(tree.data)
text(tree.data)

#Calculate R^2 
yhat <- predict(tree.data)
SSres <- sum((yhat-crime$Crime)^2)
SStot <- sum((crime$Crime-mean(crime$Crime))^2)
R2tree <- 1-SSres/SStot

#Print value of R^2 obtained using this tree
R2tree

#Determine if pruning the tree will improve performance through cross-validation
# by looking at the deviance of trees with a different number of terminal nodes
# Deviance is a quality-of-fit statistic.

cv.data <- cv.tree(tree.data)
plot(cv.data$size, cv.data$dev, type="b")
cv.data$dev

#Consider pruning tree
k=4
prune.data <- prune.tree(tree.data, best=k)




####################
# Question 10.1(b) #
####################

#Grow the random tree and set the number of predictors that we 
# want to consider at each split of the tree (npred)

numpred <- 4
rf.data <- randomForest(Crime ~ ., data=crime, mtry=numpred, importance=TRUE)
rf.data

#Calculate R^2
yhat.rf <- predict(rf.data)
SSres <- sum((yhat.rf-crime$Crime)^2)
SStot <- sum((crime$Crime - mean(crime$Crime))^2)
R2 <- 1 - SSres/SStot

#More detailed solution: try Leave One Out CV in an analogous way to the 1st hw
#Compare results from part a

#We can't see a real model because there are many different trees, but we can see
#which variables are most important to the branching overall

importance(rf.data)

#Plot these importance measures
varImpPlot(rf.data)





##########################
# Question 10.3 (part 1) #
##########################

german<-read.table("http://archive.ics.uci.edu/ml/machine-learning-databases/statlog/german/german.data", 
                   sep=" ", stringsAsFactors = FALSE, header=FALSE)

#Convert response variable to 0-1
german$V21[german$V21==1]<-0
german$V21[german$V21==2]<-1

#70/30 train/test split
set.seed(99)
ind<-sample(1:nrow(german), size=round(0.3*nrow(german)))
test = german[ind,]
train = german[-ind,]


#Part 1

log_reg_1 <- glm(V21 ~ ., family=binomial(link="logit"), data=train)

summary(log_reg_1)

#Now use automated variable selection process to determine best subset of predictors 
#Backwards selection -output suppressed
backwards <- step(log_reg_1, trace=0)

#Formula of highest AIC model:
formula(backwards)

#Running a second model with the chosen predictors:
log_reg_2 <- glm(V21 ~ V1 + V2 + V3 + V4 + V5 + V6 + V8 + V9 + V10 + V13 +
                   V14 + V15 + V19 + V20, family=binomial(link="logit"), data=train)
#Summary of new model
summary(log_reg_2)



##########################
# Question 10.3 (part 2) #
##########################


#Part 2
#You need to use the trained model to get predictions on the training/validation sets
# Then you calculate the loss based on the confusion matrix and what your model predicts
# one cost will be multiplied by 5 and the other by 1

#predictions
pred<-predict(log_reg_2,test, type="response")

# Borrowed from piazza post @348
# Optimal threshold probability
t_hold <- optimalCutoff(test$V21, pred)[1]
t_hold

#mis-classification error rate
misClassError(test$V21, pred, threshold = t_hold)

# Sensitivity
sensitivity(test$V21, pred, threshold = t_hold)

#specificity
specificity(test$V21, pred, threshold = t_hold)

#confusion matrix. Cost can be calculated from this matrix . See lesson video for detail
cm<-confusionMatrix(test$V21, pred, threshold = t_hold)
cm

#Calculate cost
cost<-cm[1,2]*1+cm[2,1]*5
cost
