#!/usr/bin/env Rscript

library(tidyverse)

options(tibble.width = Inf, width = 300) # for printing

# merge size and memtime stats ---------------------------------------------------------------

df.size_stats <- read_tsv("size_stats.kamenac.tsv")
    
# first for FMSI -----------------------------------------------------------

df.camel_memtime <- read_tsv("camel_memtime.kamenac.tsv") %>%
    mutate(S_time_s = `user(s)`+`sys(s)`) %>%
    mutate(S_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, S_time_s, S_mem_kb)
#print(df.camel_memtime)
df.fmsi_memtime <- read_tsv("fmsi_memtime.kamenac.tsv") %>%
    mutate(I_time_s = `user(s)`+`sys(s)`) %>%
    mutate(I_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, I_time_s, I_mem_kb)
df.fmsi_query_memtime <- read_tsv("fmsi_query_memtime.kamenac.tsv") %>%
    mutate(Q_time_s = `user(s)`+`sys(s)`) %>%
    mutate(Q_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, Q_time_s, Q_mem_kb, qType)

df.fmsi_stats0 <- df.size_stats %>%
    filter(I_alg == "fmsi") %>%
    full_join(df.camel_memtime) %>%
    full_join(df.fmsi_memtime) %>%
    full_join(df.fmsi_query_memtime)
    
df.fmsi_stats <- df.fmsi_stats0 %>%
    mutate(SI_time_s = S_time_s + I_time_s) %>%
    mutate(SI_mem_kb = apply( df.fmsi_stats0[c('S_mem_kb', 'I_mem_kb')], 1, max )) %>%
    arrange(genome, rate, k, S_alg, d, qType) 
#show(df.fmsi_stats)

# second for ProPhex -----------------------------------------------------------

df.prophasm_memtime <- read_tsv("prophasm_memtime.kamenac.tsv") %>%
    mutate(S_time_s = `user(s)`+`sys(s)`) %>%
    mutate(S_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, S_time_s, S_mem_kb)
#print(df.prophasm_memtime)
df.prophex_memtime <- read_tsv("prophex_memtime.kamenac.tsv") %>%
    mutate(I_time_s = `user(s)`+`sys(s)`) %>%
    mutate(I_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, I_time_s, I_mem_kb)
df.prophex_query_memtime <- read_tsv("prophex_query_memtime.kamenac.tsv") %>%
    mutate(Q_time_s = `user(s)`+`sys(s)`) %>%
    mutate(Q_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, Q_time_s, Q_mem_kb, qType)
 # obsolete: for MULTITHREADED computation, use (`user(s)`+`sys(s)`) / (as.numeric(sub("%", "",percent_CPU,fixed=TRUE))/100)

df.prophex_stats0 <- df.size_stats %>%
    filter(I_alg == "prophex") %>%
    full_join(df.prophasm_memtime) %>%
    full_join(df.prophex_memtime) %>%
    full_join(df.prophex_query_memtime)
    
df.prophex_stats <- df.prophex_stats0 %>%
    mutate(SI_time_s = S_time_s + I_time_s) %>%
    mutate(SI_mem_kb = apply( df.prophex_stats0[c('S_mem_kb', 'I_mem_kb')], 1, max )) %>%
    arrange(genome, rate, k, S_alg, d, qType) 
show(df.prophex_stats)

# new second for BWA -----------------------------------------------------------

df.bwa_memtime <- read_tsv("bwa_memtime.kamenac.tsv") %>%
    mutate(I_time_s = `user(s)`+`sys(s)`) %>%
    mutate(I_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, I_time_s, I_mem_kb)
df.bwa_query_memtime <- read_tsv("bwa_query_memtime.kamenac.tsv") %>%
    mutate(Q_time_s = `user(s)`+`sys(s)`) %>%
    mutate(Q_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, Q_time_s, Q_mem_kb, qType)
 # obsolete: for MULTITHREADED computation, use (`user(s)`+`sys(s)`) / (as.numeric(sub("%", "",percent_CPU,fixed=TRUE))/100)

df.bwa_stats0 <- df.size_stats %>%
    filter(I_alg == "bwa") %>%
    full_join(df.prophasm_memtime) %>%
    full_join(df.bwa_memtime) %>%
    full_join(df.bwa_query_memtime)
    
df.bwa_stats <- df.bwa_stats0 %>%
    mutate(SI_time_s = S_time_s + I_time_s) %>%
    mutate(SI_mem_kb = apply( df.bwa_stats0[c('S_mem_kb', 'I_mem_kb')], 1, max )) %>%
    arrange(genome, rate, k, S_alg, d, qType) 

show(df.bwa_stats)


# third for SBWT -----------------------------------------------------------
df.sbwt_memtime <- read_tsv("sbwt_memtime.kamenac.tsv") %>%
    mutate(SI_time_s = `user(s)`+`sys(s)`) %>%
    mutate(SI_mem_kb = `max_RAM(kb)`) %>%
    mutate(d = as.character(d)) %>%
    select(genome, rate, S_alg, k, d, SI_time_s, SI_mem_kb)

df.sbwt_query_memtime <- read_tsv("sbwt_query_memtime.kamenac.tsv") %>%
    mutate(Q_time_s = `user(s)`+`sys(s)`) %>%
    mutate(Q_mem_kb = `max_RAM(kb)`) %>%
    mutate(d = as.character(d)) %>%
    select(genome, rate, S_alg, k, d, Q_time_s, Q_mem_kb, qType)


df.sbwt_stats <- df.size_stats %>%
    filter(I_alg == "sbwt") %>%
    full_join(df.sbwt_memtime) %>%
    full_join(df.sbwt_query_memtime)%>%
    arrange(genome, rate, k, S_alg, d, qType)
    
show(df.sbwt_stats)


# 4th for CBL -----------------------------------------------------------
df.cbl_memtime <- read_tsv("cbl_memtime.kamenac.tsv") %>%
    mutate(SI_time_s = `user(s)`+`sys(s)`) %>%
    mutate(SI_mem_kb = `max_RAM(kb)`) %>%
    mutate(d = as.character(d)) %>%
    select(genome, rate, S_alg, k, d, SI_time_s, SI_mem_kb)

df.cbl_query_memtime <- read_tsv("cbl_query_memtime.kamenac.tsv") %>%
    mutate(Q_time_s = `user(s)`+`sys(s)`) %>%
    mutate(Q_mem_kb = `max_RAM(kb)`) %>%
    mutate(d = as.character(d)) %>%
    select(genome, rate, S_alg, k, d, Q_time_s, Q_mem_kb, qType)


df.cbl_stats <- df.size_stats %>%
    filter(I_alg == "cbl") %>%
    full_join(df.cbl_memtime) %>%
    full_join(df.cbl_query_memtime)%>%
    arrange(genome, rate, k, S_alg, d, qType)
    
#show(df.cbl_stats)

df.stats <- df.fmsi_stats %>%
    bind_rows(df.prophex_stats)%>%
    bind_rows(df.bwa_stats)%>%
    bind_rows(df.sbwt_stats)%>%
    bind_rows(df.cbl_stats)%>%
    select(-S_time_s)%>%
    select(-S_mem_kb)%>%
    select(-I_time_s)%>%
    select(-I_mem_kb)%>%
    arrange(genome, rate, k, I_alg, S_alg, d, qType)
    
df.stats %>% 
    write_tsv("exp_01_build_index_results.tsv",  na = "na")
