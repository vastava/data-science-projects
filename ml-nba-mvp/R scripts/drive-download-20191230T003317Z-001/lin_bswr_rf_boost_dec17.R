library(rpart)
library(rpart.plot)
library(caret)
library(randomForest)
library(gbm)
library(caTools)
library(dplyr)
library(ggplot2)
library(GGally)
set.seed(679)

#import data
nba_csv <- read.csv("mvp_votings_1981-2020.csv")
summary(nba_csv)

#variable selection
nba_csv <- select(nba_csv, fg_pct, fg3_pct, ft_pct, 
                  trb_per_g, ast_per_g, stl_per_g, blk_per_g, 
                  per, ts_pct, usg_pct, ws, bpm, vorp, season, 
                  age, award_share, win_pct, pts_per_g)

#separate to training vs. testing set
nba_csv.train <- filter(nba_csv, season != "2018-19")
nba_csv.test <- filter(nba_csv, season == "2018-19")

nba_csv.train <- select(nba_csv.train, -season)
nba_csv.test <- select(nba_csv.test, -season)

##linear regression model
testlm <- lm(award_share ~ ., data = nba_csv.train)
summary(testlm)
testlm$coefficients
testlm$fitted.values

#I think we can delete these
#testlm2 <- lm(award_share ~ . - points_won - points_max - votes_first - season - player, data = nba_csv.train)
#alias(testlm)
#alias(testlm2)
#summary(testlm2)
#vif(testlm2)

##evaluate predictions 
testlm2$xlevels[["season"]] <- union(testlm2$xlevels[["season"]], levels(nba_csv.test$season))
testlm2$xlevels[["player"]] <- union(testlm2$xlevels[["player"]], levels(nba_csv.test$player))
# ANJALI whatever this is doesn't work 

predictions_testlm <- predict(testlm, newdata=nba_csv.test)
predictions_testlm
nba_csv.test

SSE <-  sum((nba_csv.test$award_share - predictions_testlm)^2)
SST = sum((nba_csv.test$award_share - mean(nba_csv.train$award_share))^2)
OSR2 = 1 - SSE/SST
OSR2 #0.5684896

# backwards stepwise regression --------------------------------------------
# nba_csv <- read.csv("NBAStats (1).csv")
set.seed(679)

# training model 
step.model <- train(award_share ~., data = nba_csv.train,
                    method = "leapBackward", 
                    tuneGrid = data.frame(nvmax = 1:17),
                    trControl = trainControl(method = "cv", number = 10)
)
step.model$results
step.model$bestTune

summary(step.model$finalModel) # tells us which variables to include 
coef(step.model$finalModel, id = 9)
 
#building final linear model 
bswr.mod <- lm(award_share ~ fg_pct +  trb_per_g + ast_per_g + stl_per_g + 
                 ts_pct + ws + bpm + win_pct + pts_per_g, 
               data = nba_csv.train)
summary(bswr.mod)

# testing for OSR2 
pred.bswr <- predict(bswr.mod, newdata=nba_csv.test)
pred.bswr
nba_csv.test$award_share

SSE <-  sum((nba_csv.test$award_share - pred.bswr)^2)
SST = sum((nba_csv.test$award_share - mean(nba_csv.train$award_share))^2)
OSR2 = 1 - SSE/SST
OSR2 # 0.5691312 # slight improvement! 

# -----------------------------------------------------

##basic random forest model
set.seed(144)
mod.rf <- randomForest(award_share ~ ., data = nba_csv.train, mtry = 5, nodesize = 5, ntree = 500)
pred.rf <- predict(mod.rf, newdata = nba_csv.test) # just to illustrate

importance(mod.rf) #most important features: ws, vorp, win_pct, bpm

#cross validation on mtry
set.seed(849)
train.rf <- train(award_share ~ .,
                  data = nba_csv.train,
                  method = "rf",
                  tuneGrid = data.frame(mtry=1:16),
                  trControl = trainControl(method="cv",
                                           number=5, verboseIter = TRUE),
                  metric = "RMSE")
train.rf$results
train.rf #mtry=12
best.rf <- train.rf$finalModel
pred.best.rf <- predict(best.rf, newdata = nba_csv.test) # can use same model matrix

ggplot(train.rf$results, aes(x = mtry, y = Rsquared)) + geom_point(size = 3) + 
  ylab("CV Rsquared") + theme_bw() + theme(axis.title=element_text(size=18), axis.text=element_text(size=18))

SSE = sum((nba_csv.test$award_share - pred.best.rf)^2)
SST = sum((nba_csv.test$award_share - mean(nba_csv.train$award_share))^2)
OSR2 = 1 - SSE/SST
OSR2 #0.7677164

##boosting model
mod.boost <- gbm(award_share ~ .,
                 data = nba_csv.train,
                 distribution = "gaussian",
                 n.trees = 1000,
                 shrinkage = 0.001,
                 interaction.depth = 2)

pred.boost <- predict(mod.boost, newdata = nba_csv.test, n.trees=1000)

pred.boost.earlier <- predict(mod.boost, newdata = nba_csv.test, n.trees=330)

summary(mod.boost) #most influential features are ws, vorp, per, win_pct

#cross validation on n.trees and interaction depth
tGrid = expand.grid(n.trees = (1:75)*500, interaction.depth = c(1,2,4,6,8,10),
                    shrinkage = 0.001, n.minobsinnode = 10)

set.seed(849)
train.boost <- train(award_share ~ .,
                     data = nba_csv.train,
                     method = "gbm",
                     tuneGrid = tGrid,
                     trControl = trainControl(method="cv", number=5, 
                                              verboseIter = TRUE),
                     metric = "RMSE",
                     distribution = "gaussian")
train.boost #ntrees=4000,interaction.depth=4
best.boost <- train.boost$finalModel
pred.best.boost <- predict(best.boost, newdata = nba_csv.test, n.trees = 4000) # can use same model matrix

ggplot(train.boost$results, aes(x = n.trees, y = Rsquared, colour = as.factor(interaction.depth))) + geom_line() + 
  ylab("CV Rsquared") + theme_bw() + theme(axis.title=element_text(size=18), axis.text=element_text(size=18)) + 
  scale_color_discrete(name = "interaction.depth")

SSE = sum((nba_csv.test$award_share - pred.best.boost)^2)
SST = sum((nba_csv.test$award_share - mean(nba_csv.train$award_share))^2)
OSR2 = 1 - SSE/SST
OSR2 #0.8231889



