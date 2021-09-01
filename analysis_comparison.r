devtools::load_all("E:\\estimateR\\estimateR")
library(rjson)
library(bdskytools)

## data.json was obtained by parsing the fasta file, and creating a table 
# that counts the number of cases sequenced per every day in the time 
# period of the analysis
case_incidence <- fromJSON(file = "data.json")

## The estimateR analysis
#########################
shape_delay = 4.2 
scale_delay = 1.6
delay <- list(name="gamma", shape = shape_incubation, scale = scale_incubation)

Re_estimates <- estimate_Re_from_noisy_delayed_incidence(
  case_incidence$cases,
  smoothing_method = "LOESS",
  deconvolution_method = "Richardson-Lucy delay distribution",
  estimation_method = "EpiEstim piecewise constant",
  delay = list(delay),
  ref_date = as.Date("01/10/2017", "%d/%m/%y"),
  time_step = "day",
  output_Re_only = FALSE,
  output_HPD = TRUE,
  interval_length = round(length(case_incidence$cases)/5),
  mean_serial_interval = 3.6,
  std_serial_interval = 1.6
)

ggplot(Re_estimates, aes(x = as.Date(date, "%m/%d/%y"), y = Re_estimate)) +
  geom_line(lwd=  1.1) +
  geom_ribbon(aes(x = date, ymax = Re_highHPD, ymin = Re_lowHPD), alpha = 0.45, colour = NA) +
  scale_x_date(date_breaks = "1 month", 
               date_labels = '%b') +
  ylab("Reproductive number - estimateR") +
  coord_cartesian(ylim = c(0, 1.75)) +
  xlab("") +
  theme_bw()


## The BDSKY analysis
#########################
fname <- "combined.log"   
lf    <- readLogfile(fname, burnin=0)

Re_sky    <- getSkylineSubset(lf, "reproductiveNumber")
Re_hpd    <- getMatrixHPD(Re_sky)

Re_estimates_BDSKY <- list(
    "Re_estimate" = c(),
    "Re_highHPD" = c(),
    "Re_lowHPD" = c(),
    "date" = c()
)

interval_length = round(length(case_incidence$cases)/5)

Re_estimates_BDSKY$date <- Re_estimates$date[1:240]
for (i in 1:5) {
   Re_estimates_BDSKY$Re_estimate <- c(Re_estimates_BDSKY$Re_estimate, rep(Re_hpd[2,i], interval_length))
   Re_estimates_BDSKY$Re_highHPD <- c(Re_estimates_BDSKY$Re_highHPD, rep(Re_hpd[3,i], interval_length))
   Re_estimates_BDSKY$Re_lowHPD <- c(Re_estimates_BDSKY$Re_lowHPD, rep(Re_hpd[1,i], interval_length))
}

Re_estimates_BDSKY <- data.frame(Re_estimates_BDSKY)

ggplot(Re_estimates_BDSKY, aes(x = as.Date(date, "%m/%d/%y"), y = Re_estimate)) +
  geom_line(lwd=  1.1) +
  geom_ribbon(aes(x = date, ymax = Re_highHPD, ymin = Re_lowHPD), alpha = 0.45, colour = NA) +
  scale_x_date(date_breaks = "1 month", 
               date_labels = '%b') +
  ylab("Reproductive number - BDSKY") +
  coord_cartesian(ylim = c(0, 1.75)) +
  xlab("") +
  theme_bw()
