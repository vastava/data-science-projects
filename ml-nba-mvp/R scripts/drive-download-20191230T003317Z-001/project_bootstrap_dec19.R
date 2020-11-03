library(boot)

boot_osr <- function(data, index) {
  labels <- data$label[index]
  predictions <- data$prediction[index]
  SSE <-  sum((labels - predictions)^2)
  SST = sum((labels - mean_obs)^2)
  return(1 - SSE/SST)
}

boot_mae <- function(data, index) {
  labels <- data$label[index]
  predictions <- data$prediction[index]
  return(mean(abs(labels-predictions)))
}

boot_rmse <- function(data, index) {
  labels <- data$label[index]
  predictions <- data$prediction[index]
  return(sqrt(mean((labels-predictions)^2)))
}

boot_all_metrics <- function(data, index) {
  osr = boot_osr(data, index)
  mae = boot_mae(data, index)
  rmse = boot_rmse(data, index)
  return(c(osr, mae, rmse))
}

big_B = 10000

##baseline model
mean_obs <- mean(nba_csv.train$award_share) #0.1550612
predict.baseline = rep(mean_obs, nrow(nba_csv.test))
baseline_df = data.frame(labels = nba_csv.test$award_share, predictions = predict.baseline)
set.seed(6829)
Baseline_boot = boot(baseline_df, boot_all_metrics, R = big_B)
Baseline_boot
boot.ci(Baseline_boot, index = 1, type = "basic")
boot.ci(Baseline_boot, index = 2, type = "basic")
boot.ci(Baseline_boot, index = 3, type = "basic")

##naive lin reg
lin_df = data.frame(labels = nba_csv.test$award_share, predictions =  predictions_testlm)
set.seed(342)
Lin_boot = boot(lin_df, boot_all_metrics, R = big_B)
Lin_boot
boot.ci(Lin_boot, index = 1, type = "basic")
boot.ci(Lin_boot, index = 2, type = "basic")
boot.ci(Lin_boot, index = 3, type = "basic")

##stepwise lin reg
stepwise_df = data.frame(labels = nba_csv.test$award_share, predictions =  pred.bswr)
set.seed(342)
Step_boot = boot(stepwise_df, boot_all_metrics, R = big_B)
Step_boot
boot.ci(Step_boot, index = 1, type = "basic")
boot.ci(Step_boot, index = 2, type = "basic")
boot.ci(Step_boot, index = 3, type = "basic")

##random forest
rf_df = data.frame(labels = nba_csv.test$award_share, predictions = pred.best.rf)
set.seed(6722)
RF_boot = boot(rf_df, boot_all_metrics, R = big_B)
RF_boot
boot.ci(RF_boot, index = 1, type = "basic")
boot.ci(RF_boot, index = 2, type = "basic")
boot.ci(RF_boot, index = 3, type = "basic")

##boosting
boost_df = data.frame(labels = nba_csv.test$award_share, predictions = pred.best.boost)
set.seed(9391)
Boost_boot = boot(boost_df, boot_all_metrics, R = big_B)
Boost_boot
boot.ci(Boost_boot, index = 1, type = "basic")
boot.ci(Boost_boot, index = 2, type = "basic")
boot.ci(Boost_boot, index = 3, type = "basic")

