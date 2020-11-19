library(dplyr)
library(forcats)
library(ggplot2)
library(jsonlite)
library(magrittr)
library(purrr)
library(readr)
library(stringr)
library(tibble)

read_pod_resources <- function(result_file) {
  pods_list <- result_file %>%
    read_json() %>%
    extract2("items")
  
  path_names <- str_split(result_file, .Platform$file.sep) %>%
    unlist()
  
  iteration <- tail(path_names, 1) %>%
    str_split("(-|\\.)") %>%
    unlist() %>%
    extract(3) %>%
    as.integer()
  
  stage <- tail(path_names, 3)[1] %>%
    str_split("-") %>%
    unlist() %>%
    extract(2) %>%
    as.integer()
  
  scenario <- tail(path_names, 4)[1] %>%
    str_split("-") %>%
    unlist() %>%
    extract(2) %>%
    as.integer()
  
  pod_status <- pods_list %>%
    map_df(~ tibble(status = .$status$phase), .id = "pod_id")
  
  pod_resources <- pods_list %>%
    map_df(~ unlist(.$spec$containers), .id = "pod_id") 
  
  if (nrow(pod_resources) > 0) {
    pod_resources <- pod_resources %>%
      transmute(
        file = result_file,
        scenario,
        scenario_str = paste("scenario", scenario),
        stage,
        stage_str = paste("stage", stage),
        iteration,
        pod_id,
        cpu_request = parse_number(resources.requests.cpu),
        cpu_limit = parse_number(resources.limits.cpu),
        mem_request = resources.requests.memory,
        mem_limit = resources.limits.memory
      ) %>%
      group_by(scenario) %>%
      arrange(stage, iteration) %>%
      mutate(time = iteration * stage_duration)
    
    if (nrow(pod_status) > 0) {
      pod_resources <- left_join(pod_resources, pod_status, by = "pod_id")
    }
  }
  return(pod_resources)
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

results_dir <- file.path("results", "vpa-5")
service_time <- 175 # ms
stage_duration <- 2 # minutes
initial_req <- 150

pod_files <- Sys.glob(file.path(results_dir, "scenario-*", "stage-*", "pods-requests", "*.log"))

pods <- pod_files %>%
  map_df(read_pod_resources) %>%
  left_join(request_rates) %>%
  mutate(scenario_str = factor(scenario_str),
         cpu_estimated = rate * service_time,
         pod_id = fct_inorder(pod_id),
         time = (iteration + max(iteration) * (stage - 1)) / 6
  )

p <- ggplot(pods, aes(time, cpu_request, fill = fct_rev(pod_id))) +
  geom_col(position = "stack", col = "white", lwd = 0.2, alpha = 0.8) +
  geom_hline(aes(yintercept = cpu_estimated), lty = 2) +
  facet_grid(scenario_str ~ stage_str, scales = "free_x") +
  scale_x_continuous(breaks = seq(0, max(pods$time), 1), expand = c(0, 0.05)) +
  scale_y_continuous(breaks = seq(0, max(pods$cpu_estimated) * 1.5, initial_req * 2)) +
  labs(x = "Tempo (minutos)", y = "CPU request", fill = "n pods") +
  theme_bw() +
  theme(panel.spacing = unit(0.1, "lines"))
p
ggsave(file.path(results_dir, "cpu_requests_running.png"), p, width = 10, height = 5)
