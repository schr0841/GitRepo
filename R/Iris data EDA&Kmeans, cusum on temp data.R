######################
###  ISYE6501 HW2  ###
######################

# Include packages
library(magrittr)
library(dplyr)
library(ggplot2)
library(outliers)
library(corrplot)
library(knitr)
library(qcc)

# Code for multiplot (code source referenced at end of pdf):
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}



# Question 4.2 - first visualization
data(iris)

ggplot(iris, aes(Petal.Length, Petal.Width, color = iris$Species)) + 
  geom_point(alpha = 0.4, size = 2) + geom_point() + 
  scale_color_manual(values = c('blue', 'red', 'green'))

#Create scaled data set for elbow method testing:
iris.scaled <- scale(iris[, -5])

# Question 4.2 - second visualization
corrplot(cor(iris.scaled))

# Question 4.2 - third visualization (each subset of 6 predictors)
p1 <- ggplot(iris, aes(Petal.Length, Petal.Width, color=Species)) + geom_point()
p2 <- ggplot(iris, aes(Petal.Length, Sepal.Width, color=Species)) + geom_point()
p3 <- ggplot(iris, aes(Petal.Length, Sepal.Length, color=Species)) + geom_point()
p4 <- ggplot(iris, aes(Petal.Width, Sepal.Width, color=Species)) + geom_point()
p5 <- ggplot(iris, aes(Petal.Width, Sepal.Length, color=Species)) + geom_point()
p6 <- ggplot(iris, aes(Sepal.Width, Sepal.Length, color=Species)) + geom_point()

multiplot(p1,p2,p3,p4,p5,p6, cols=2)



# Question 4.2 - plot of elbow method using scaled data

set.seed(123)
# Compute and plot wss for k = 2 to k = 15
k.max <- 15 # Maximal number of clusters
data <- iris.scaled
wss<-rep(0,11)

wss <- sapply(1:k.max, 
              function(k){kmeans(data, k, nstart=10 )$tot.withinss})

#Generate plot for each entry of wss
plot(1:k.max, wss,
     type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")
abline(v = 3, lty =2)


##############################################
# Question 4.2 - Model with all 4 predictors #

test_model <-  iris %>% 
  select(1:4) %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

sum(tc == iris$Species)/nrow(iris)


# Question 4.2 - Model with each individual predictor
set.seed(22)
accuracy=rep(0,4)
for (i in 1:4){
  test_model <-  iris[,i] %>% 
    kmeans(., 3)
  
  # accuracy  
  tc <- test_model$cluster
  species <- tc %>% unique
  
  tc[which(tc == species[1])] <- "setosa"
  tc[which(tc == species[2])] <- "versicolor"
  tc[which(tc == species[3])] <- "virginica"
  
  accuracy[i]=sum(tc == iris$Species)/nrow(iris)
}

#Getting the best predictor/accuracy combination
which.max(accuracy)
accuracy[which.max(accuracy)]



#################################################################
# Question 4.2 - testing the 6 subsets of 2 predictor variables #

set.seed(22)
accuracy=rep(0,6)

#Model 1 : for Petal.Length, Petal.Width
test_model <-  iris[,c(3,4)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[1]=sum(tc == iris$Species)/nrow(iris)

#Model 2 : for Petal.Length, Sepal.Length
test_model <-  iris[,c(1,3)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[2]=sum(tc == iris$Species)/nrow(iris)

#Model 3 : for Petal.Length, Sepal.Width
test_model <-  iris[,c(2,3)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[3]=sum(tc == iris$Species)/nrow(iris)

#Model 4 : for Petal.Width, Sepal.Width
test_model <-  iris[,c(2,4)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[4]=sum(tc == iris$Species)/nrow(iris)

#Model 5 : for Petal.Width, Sepal.Length
test_model <-  iris[,c(1,4)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[5]=sum(tc == iris$Species)/nrow(iris)

#Model 6 : for Sepal.Width, Sepal.Length
test_model <-  iris[,c(1,2)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[6]=sum(tc == iris$Species)/nrow(iris)


#Getting the best predictor/accuracy combination for 2 predictors:
which.max(accuracy)
accuracy[which.max(accuracy)]

#########################################################
# Question 4.2 - Testing the 4 models with 3 predictors #


set.seed(22)
accuracy=rep(0,4)

#Model 1 : for Petal.Length, Sepal.Width, Sepal.Length
test_model <-  iris[,c(1,2,3)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[1]=sum(tc == iris$Species)/nrow(iris)

#Model 2 : for Petal.Width, Sepal.Width, Sepal.Length
test_model <-  iris[,c(1,2,4)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[2]=sum(tc == iris$Species)/nrow(iris)

#Model 3 : for Petal.Width, Petal.Length,Sepal.Length
test_model <-  iris[,c(1,3,4)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[3]=sum(tc == iris$Species)/nrow(iris)

#Model 4 : for Petal.Width, Petal.Length,Sepal.Width
test_model <-  iris[,c(2,3,4)] %>% 
  kmeans(., 3)

# accuracy  
tc <- test_model$cluster
species <- tc %>% unique

tc[which(tc == species[1])] <- "setosa"
tc[which(tc == species[2])] <- "versicolor"
tc[which(tc == species[3])] <- "virginica"

accuracy[4]=sum(tc == iris$Species)/nrow(iris)


#Getting the best predictor/accuracy combination for 2 predictors:
which.max(accuracy)
accuracy[which.max(accuracy)]


################
# QUESTION 5.2 #
################


crime=read.csv("http://www.statsci.org/data/general/uscrime.txt",stringsAsFactors = FALSE, header=TRUE, sep='\t')



summary(crime$Crime)

#Basic plot of the Crime column. 
boxplot(crime$Crime)

#Which state (numeric) has max value of crime
which.max(crime$Crime)

#Numeric value for the max crime
crime[which.max(crime$Crime),]

#Performing Grubbs test for one outlier
grubbs.test(crime$Crime, type=10)



################
# QUESTION 6.2 #
################

temps=read.csv("https://prod-edxapp.edx-cdn.org/assets/courseware/v1/592f3be3e90d2bdfe6a69f62374a1250/asset-v1:GTx+ISYE6501x+2T2018+type@asset+block/6.2tempsSummer2018.txt",stringsAsFactors = FALSE, header=TRUE, sep='\t')

july_mean_1996 <- mean(temps[2:32,2])
july_sd_1996 <- sd(temps[2:32,2])

#The value of se.shift corresponds to C, and se.interval corresponds to T, from what I can tell!
cusum(temps[,2],center=july_mean_1996,std.dev=july_sd_1996, se.shift=july_sd_1996, decision.interval = 2*july_sd_1996)




