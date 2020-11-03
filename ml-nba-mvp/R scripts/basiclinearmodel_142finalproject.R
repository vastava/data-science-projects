library(dplyr)
library(ggplot2)
library(GGally)
library(car)

nba_csv <- read.csv("mvp_votings_1981-2020.csv")
View(nba_csv)

#Part A
nba_csv.train <- filter(nba_csv, season != "2018-19")
nba_csv.test <- filter(nba_csv, season == "2018-19")

View(nba_csv.train)
View(nba_csv.test)

##linear regression model
testlm <- lm(award_share ~ ., data = nba_csv.train)
summary(testlm)
testlm$coefficients
testlm$fitted.values

testlm2 <- lm(award_share ~ . - points_won - points_max - votes_first - season - player, data = nba_csv.train)
alias(testlm)
alias(testlm2)
summary(testlm2)
vif(testlm2)

##evaluate predictions
testlm2$xlevels[["season"]] <- union(testlm2$xlevels[["season"]], levels(nba_csv.test$season))
testlm2$xlevels[["player"]] <- union(testlm2$xlevels[["player"]], levels(nba_csv.test$player))

predictions_testlm <- predict(testlm2, newdata=nba_csv.test)
predictions_testlm
nba_csv.test

SSE = sum((nba_csv.test$award_share - predictions_testlm)^2)
SST = sum((nba_csv.test$award_share - mean(nba_csv.train$award_share))^2)
OSR2 = 1 - SSE/SST
OSR2

