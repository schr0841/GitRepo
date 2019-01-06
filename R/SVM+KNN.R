#Assignment 1 of ISYI6501

#Load needed libraries
library(kernlab)
library(kknn)
library(caret)

#Load dataset
data <- read.table("2.2credit_card_dataSummer2018.txt", stringsAsFactors = FALSE, header=FALSE)


################
# Question 2.2 #
################

#PART1#

#Setting up the provided model:
model <- ksvm(as.matrix(data[,1:10]),as.factor(data[,11]),type="C-svc",kernel="vanilladot",C=100,scaled=TRUE)

#Calculate a_1,...,a_m:
a<-colSums(model@xmatrix[[1]]*model@coef[[1]])
a
a0<- -model@b
a0

#Basic model predictions:
pred <- predict(model, data[,1:10])

#Basic model accuracy:
sum(pred==data[,11])/nrow(data) * 100


#Choosing C more carefully:

#Initialize vectors of C-values and accuracy placeholders:
C_vals=c(0.0000001,0.000001,0.00001,0.0001,0.001,0.01,0.1,1,10,100,1000,10000)
acc=rep(0,12)

for (i in 1:12){
  #fit model using training set
  model_scaled <- ksvm(as.matrix(data[,1:10]), as.factor(data[,11]), type='C-svc', kernel='vanilladot', C=C_vals[i], scaled=TRUE)
  
  #Compare models using the validation set
  pred <- predict(model_scaled, data[,1:10])
  acc[i] <- sum(pred == data$V11)/nrow(data)
}
cat("accuracies: ", acc, "\n")
#Find maximum accuracy and C-value associated with it
cat("Best SVM is model number ", which.max(acc[1:12]), "\n")
cat("Best C value is ", C_vals[which.max(acc[1:12])], "\n")
cat("Best validation set correctness is ", max(acc[1:12]), "\n")

#retrain the best model
model_scaled <- ksvm(as.matrix(data[,1:10]), as.factor(data[,11]), type='C-svc', kernel='vanilladot', C=C_vals[which.max(acc[1:12])], scaled=TRUE)

#test set performance
cat("Performance on test data = ", sum(predict(model_scaled, data[,1:10]) == data$V11) / nrow(data), "\n")


#The above model yields C=0.01 with an accuracy of 0.8639144. Can we do even better? 
#We check values around 0.01 even more carefully:

#Initialize vectors of C-values and accuracy placeholders:
C_vals <- seq(0.001, 0.1, by=0.00001)
acc=rep(0,length(C_vals))

for (i in 1:length(C_vals)){
  #fit model using training set
  model_scaled <- ksvm(as.matrix(data[,1:10]), as.factor(data[,11]), type='C-svc', kernel='vanilladot', C=C_vals[i], scaled=TRUE)
  
  #Compare models using the validation set
  pred <- predict(model_scaled, data[,1:10])
  acc[i] <- sum(pred == data$V11)/nrow(data)
}

#Find maximum accuracy and C-value associated with it
cat("Best SVM is model number ", which.max(acc[1:length(C_vals)]), "\n")
cat("Best C value is ", C_vals[which.max(acc[1:length(C_vals)])], "\n")
cat("Best validation set correctness is ", max(acc[1:length(C_vals)]), "\n")

#retrain the best model
model_scaled <- ksvm(as.matrix(data[,1:10]), as.factor(data[,11]), type='C-svc', kernel='vanilladot', C=C_vals[which.max(acc[1:12])], scaled=TRUE)

#test set performance
cat("Performance on test data = ", sum(predict(model_scaled, data[,1:10]) == data$V11) / nrow(data), "\n")


#This method yields C=0.00139 with a validation accuracy of 0.8440367. 



#PART2# OPTIONAL



#PART3#

#We follow TA video 3 to create loop for values of k from 1 to 100:
predicted<-rep(0,nrow(data))
accuracy<-rep(0,100)
for (kval in 1:100){
  for (i in 1:nrow(data)){
    model<-kknn(V11~., data[-i,],data[i,],k=kval,scale=TRUE) #set up knn model with k iterable
    predicted[i]<-as.integer(fitted(model)+0.5)  #calculate predictions for each row i of data
  }
  
  #Calculate fraction of correct predictions for each value of k
  accuracy[kval]<-sum(predicted==data[,11])/nrow(data)
  
}

#find optimal value of k
k_loop<-which.max(accuracy)

#find accuracy associated with this k value
acc_k<-accuracy[k_loop] 

#print results
k_loop
acc_k



################
# Question 3.1 #
################

#Part a#

#We use the CARET package and its built-in cross validation feature to choose k:

set.seed(200)

#Split data into train/test sets
indxTrain <- createDataPartition(y = data$V11,p = 0.70,list = FALSE)
training <- data[indxTrain,]
testing <- data[-indxTrain,]

#Run knn in caret:
ctrl <- trainControl(method="repeatedcv",repeats = 3)
knnFit <- train(V11 ~ ., data = training, method = "knn", trControl = ctrl, preProcess = c("center","scale"),tuneLength = 20)
knnFit

#Plot results
plot(knnFit)

#This yields k=27, and the accuracy associated with this value of $k$ is 0.8516709.



#Part b#


#Setting seed to ensure reproducible results
set.seed(1)

#Number of rows in dataset
n <- nrow(data)

#Split data into 70% training, 15% test, 15% validation
val<- sample(1:n, size=round(0.3*n), replace=FALSE)

d.train <- data[-val,] #Training data
d.split <- data[val,] #Test data to be split further

#Repeat same process to split data further into validation and test sets:
m<-nrow(d.split)

#Split d.split into 50% test, 50% validation
val2<- sample(1:m, size=round(0.5*m), replace=FALSE)

d.test <- d.split[-val2,] #Final test data
d.validate <- d.split[val2,] #Final validation data


#We choose an SVM classifier and iterate to find the correct magnitude of C (similar to Q2.1):

C_vals=c(0.0000001,0.000001,0.00001,0.0001,0.001,0.01,0.1,1,10,100,1000,10000)
acc=rep(0,12)

for (i in 1:12){
  #fit model using training set
  model_scaled <- ksvm(as.matrix(d.train[,1:10]), as.factor(d.train[,11]), type='C-svc', kernel='vanilladot', C=C_vals[i], scaled=TRUE)
  
  #Compare models using the validation set
  pred <- predict(model_scaled, d.validate[,1:10])
  acc[i] <- sum(pred == d.validate$V11)/nrow(d.validate)
}

#Find maximum accuracy and C-value associated with it
cat("Best SVM is model number ", which.max(acc[1:12]), "\n")
cat("Best C value is ", C_vals[which.max(acc[1:12])], "\n")
cat("Best validation set correctness is ", max(acc[1:12]), "\n")

#retrain the best model
model_scaled <- ksvm(as.matrix(d.train[,1:10]), as.factor(d.train[,11]), type='C-svc', kernel='vanilladot', C=C_vals[which.max(acc[1:12])], scaled=TRUE)

#test set performance
cat("Performance on test data = ", sum(predict(model_scaled, d.test[,1:10]) == d.test$V11) / nrow(d.test), "\n")

#This again yields C=0.01 with a validation accuracy of 



#As a final calculation, we again investigate the area around C=0.01 more carefully:

#Initialize vectors of C-values and accuracy placeholders:
C_vals <- seq(0.001, 0.05, by=0.00001)
acc=rep(0,length(C_vals))

for (i in 1:length(C_vals)){
  #fit model using training set
  model_scaled <- ksvm(as.matrix(d.train[,1:10]), as.factor(d.train[,11]), type='C-svc', kernel='vanilladot', C=C_vals[i], scaled=TRUE)
  
  #Compare models using the validation set
  pred <- predict(model_scaled, d.validate[,1:10])
  acc[i] <- sum(pred == d.validate$V11)/nrow(d.validate)
}
cat("accuracies: ", acc, "\n")
#Find maximum accuracy and C-value associated with it
cat("Best SVM is model number ", which.max(acc[1:length(C_vals)]), "\n")
cat("Best C value is ", C_vals[which.max(acc[1:length(C_vals)])], "\n")
cat("Best validation set correctness is ", max(acc[1:length(C_vals)]), "\n")

#retrain the best model
model_scaled <- ksvm(as.matrix(d.train[,1:10]), as.factor(d.train[,11]), type='C-svc', kernel='vanilladot', C=C_vals[which.max(acc[1:length(C_vals)])], scaled=TRUE)

#test set performance
cat("Performance on test data = ", sum(predict(model_scaled, d.test[,1:10]) == d.test$V11) / nrow(d.test), "\n")


#The final chosen value of C is 0.00196, with a re-trained test set performance of 0.8979592