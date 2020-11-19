library(dplyr)
library(forcats)
library(ggplot2)
library(magrittr)
library(purrr)
library(readr)
library(stringr)
library(tibble)

read_response_times <- function(result_file) {
  hey_log <- result_file %>%
    read_csv(col_types = cols())
  
  path_names <- str_split(result_file, .Platform$file.sep) %>%
    unlist()
  
  stage <- tail(path_names, 2)[1] %>%
    str_split("-") %>%
    unlist() %>%
    extract(2) %>%
    as.integer()
  
  scenario <- tail(path_names, 3)[1] %>%
    str_split("-") %>%
    unlist() %>%
    extract(2) %>%
    as.integer()

  response_times <- hey_log %>%
    transmute(
      file = result_file,
      scenario,
      scenario_str = paste("scenario", scenario),
      stage,
      stage_str = paste("stage", stage),
      request_id = 1:n(),
      response_time = `response-time`,
      status_code = `status-code`
    )
  return(response_times)
}

request_rates <- tribble(
  ~scenario, ~stage, ~rate,
  1, 1, 2,
  1, 2, 2,
  1, 3, 4,
  1, 4, 6,
  1, 5, 8,
  1, 6, 6,
  1, 7, 4,
  1, 8, 2,
  1, 9, 2,
  2, 1, 2,
  2, 2, 2,
  2, 3, 8,
  2, 4, 8,
  2, 5, 8,
  2, 6, 2,
  2, 7, 2,
  2, 8, 2,
  2, 9, 2,
  3, 1, 2,
  3, 2, 2,
  3, 3, 8,
  3, 4, 8,
  3, 5, 2,
  3, 6, 2,
  3, 7, 2,
  3, 8, 2,
  3, 9, 2,
  4, 1, 2,
  4, 2, 2,
  4, 3, 8,
  4, 4, 2,
  4, 5, 8,
  4, 6, 2,
  4, 7, 8,
  4, 8, 2,
  4, 9, 2,
)

vpa_results_dir <- file.path("results", "vpa")
vpa_hey_files <- Sys.glob(file.path(vpa_results_dir, "scenario-*", "stage-*", "hey-info.csv"))

vpa_response_times <- vpa_hey_files %>%
  map_df(read_response_times) %>%
  mutate(scenario_str = factor(scenario_str),
         scaling = "vertical")

hpa_results_dir <- file.path("results", "hpa")
hpa_hey_files <- Sys.glob(file.path(hpa_results_dir, "scenario-*", "stage-*", "hey-info.csv"))

hpa_response_times <- hpa_hey_files %>%
  map_df(read_response_times) %>%
  mutate(scenario_str = factor(scenario_str),
         scaling = "horizontal")

response_times <- bind_rows(vpa_response_times, hpa_response_times)

response_times_summary <- response_times %>%
  group_by(scenario_str, stage, scaling) %>%
  summarise(response_time_median = median(response_time),
            response_time_mean = mean(response_time))

p <- ggplot(response_times, aes(stage, response_time_median, col = scaling,
                                shape = scaling)) +
  geom_hline(aes(yintercept = 0.175), lty = 2) +
  geom_line(alpha = 0.8, size = 0.5) +
  geom_point(alpha = 0.8, size = 2) +
  facet_wrap(~ scenario_str, ncol = 1) +
  scale_x_continuous(breaks = seq(1, max(response_times$stage), 1)) +
  scale_y_continuous(limits = c(0, NA), breaks = seq(0, 1, 0.175)) +
  labs(x = "Stage", y = "Tempo de resposta (segundos)") +
  theme_bw()
p
ggsave(file.path("response_times.png"), p, width = 5, height = 5)

p <- ggplot(response_times, aes(factor(stage), response_time,
                                col = scaling, shape = scaling)) +
  geom_hline(aes(yintercept = 0.175), lty = 2) +
  geom_boxplot(outlier.shape = NA, alpha = 0.8) +
  geom_point(aes(y = response_time_mean), data = response_times_summary,
             position = position_dodge(width = 0.75)) +
  facet_wrap(~ scenario_str, ncol = 1) +
  scale_y_continuous(limits = c(0.175, 1.225), breaks = seq(0, 1.5, 0.175)) +
  labs(x = "Stage", y = "Tempo de resposta (segundos)", fill = "n pods") +
  theme_bw() +
  theme(panel.spacing = unit(0.1, "lines"))
p
ggsave(file.path("response_times_boxplot.png"), p, width = 7, height = 7)

