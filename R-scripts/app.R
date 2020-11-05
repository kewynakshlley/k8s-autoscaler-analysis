library(dplyr)
library(purrr)
library(yaml)

#Recommendations info
firstBenchVPA = list.files(path="./vpa_experiment/first_experiment/logs/bench_0/vpa", pattern="*.log", full.names=TRUE, recursive=FALSE) %>%
  map_df(~ data.frame(t(unlist(read_yaml(.)))))

secondBenchVPA = list.files(path="./vpa_experiment/first_experiment/logs/bench_1/vpa", pattern="*.log", full.names=TRUE, recursive=FALSE) %>%
  map_df(~ data.frame(t(unlist(read_yaml(.)))))

thirdBenchVPA = list.files(path="./vpa_experiment/first_experiment/logs/bench_2/vpa", pattern="*.log", full.names=TRUE, recursive=FALSE) %>%
  map_df(~ data.frame(t(unlist(read_yaml(.)))))

fourthBenchVPA = list.files(path="./vpa_experiment/first_experiment/logs/bench_3/vpa", pattern="*.log", full.names=TRUE, recursive=FALSE) %>%
  map_df(~ data.frame(t(unlist(read_yaml(.)))))

#Pod requests info
firstBenchPD = list.files(path="./vpa_experiment/first_experiment/logs/bench_0/pod-requests", pattern="*.log", full.names=TRUE, recursive=FALSE) %>%
  map_df(~ data.frame(t(unlist(read_yaml(.)))))

secondBenchPD = list.files(path="./vpa_experiment/first_experiment/logs/bench_1/pod-requests", pattern="*.log", full.names=TRUE, recursive=FALSE) %>%
  map_df(~ data.frame(t(unlist(read_yaml(.)))))

thirdBenchPD = list.files(path="./vpa_experiment/first_experiment/logs/bench_2/pod-requests", pattern="*.log", full.names=TRUE, recursive=FALSE) %>%
  map_df(~ data.frame(t(unlist(read_yaml(.)))))

fourthBenchPD = list.files(path="./vpa_experiment/first_experiment/logs/bench_3/pod-requests", pattern="*.log", full.names=TRUE, recursive=FALSE) %>%
  map_df(~ data.frame(t(unlist(read_yaml(.)))))


