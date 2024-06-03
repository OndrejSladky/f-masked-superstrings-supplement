#!/usr/bin/env Rscript

library(tidyverse)

options(tibble.width = Inf, width = 300) # for printing

# merge size and memtime stats ---------------------------------------------------------------

# FIXME: kamenac should be specified on input
get_hostname <- function(){ 
    return(as.character(Sys.info()["nodename"])) 
} 
filesuffix=paste(".", get_hostname(), ".tsv", sep="")

df.size_stats <- read_tsv(paste("size_stats", filesuffix, sep=""))
    
# first for FMSI -----------------------------------------------------------

df.camel_memtime <- read_tsv(paste("camel_memtime", filesuffix, sep="")) %>%
    mutate(S_time_s = `user(s)`+`sys(s)`) %>%
    mutate(S_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, S_time_s, S_mem_kb)
#print(df.camel_memtime)
df.fmsi_memtime <- read_tsv(paste("fmsi_memtime", filesuffix, sep="")) %>%
    mutate(I_time_s = `user(s)`+`sys(s)`) %>%
    mutate(I_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, I_time_s, I_mem_kb)
df.fmsi_query_memtime <- read_tsv(paste("fmsi_query_memtime", filesuffix, sep="")) %>%
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
    
# FMSI v 0.2 -----------------------------------------------------------

df.FMSIv02_memtime <- read_tsv(paste("FMSIv02_memtime", filesuffix, sep="")) %>%
    mutate(I_time_s = `user(s)`+`sys(s)`) %>%
    mutate(I_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, I_time_s, I_mem_kb)
df.FMSIv02_query_memtime <- read_tsv(paste("FMSIv02_query_memtime", filesuffix, sep="")) %>%
    mutate(Q_time_s = `user(s)`+`sys(s)`) %>%
    mutate(Q_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, Q_time_s, Q_mem_kb, qType)

df.FMSIv02_stats0 <- df.size_stats %>%
    filter(I_alg == "FMSIv02") %>%
    full_join(df.camel_memtime) %>%
    full_join(df.FMSIv02_memtime) %>%
    full_join(df.FMSIv02_query_memtime)
    
df.FMSIv02_stats <- df.FMSIv02_stats0 %>%
    mutate(SI_time_s = S_time_s + I_time_s) %>%
    mutate(SI_mem_kb = apply( df.FMSIv02_stats0[c('S_mem_kb', 'I_mem_kb')], 1, max )) %>%
    arrange(genome, rate, k, S_alg, d, qType) 
#show(df.FMSIv02_stats)

# ProphAsm -----------------------------------------------------------

df.prophasm_memtime <- read_tsv(paste("prophasm_memtime", filesuffix, sep="")) %>%
    mutate(S_time_s = `user(s)`+`sys(s)`) %>%
    mutate(S_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, S_time_s, S_mem_kb)

# second for ProPhex -----------------------------------------------------------
#print(df.prophasm_memtime)
# df.prophex_memtime <- read_tsv(paste("prophex_memtime", filesuffix, sep="")) %>%
#     mutate(I_time_s = `user(s)`+`sys(s)`) %>%
#     mutate(I_mem_kb = `max_RAM(kb)`) %>%
#     select(genome, rate, S_alg, k, d, I_time_s, I_mem_kb)
# df.prophex_query_memtime <- read_tsv(paste("prophex_query_memtime", filesuffix, sep="")) %>%
#     mutate(Q_time_s = `user(s)`+`sys(s)`) %>%
#     mutate(Q_mem_kb = `max_RAM(kb)`) %>%
#     select(genome, rate, S_alg, k, d, Q_time_s, Q_mem_kb, qType)
#  # obsolete: for MULTITHREADED computation, use (`user(s)`+`sys(s)`) / (as.numeric(sub("%", "",percent_CPU,fixed=TRUE))/100)

# df.prophex_stats0 <- df.size_stats %>%
#     filter(I_alg == "prophex") %>%
#     full_join(df.prophasm_memtime) %>%
#     full_join(df.prophex_memtime) %>%
#     full_join(df.prophex_query_memtime)
    
# df.prophex_stats <- df.prophex_stats0 %>%
#     mutate(SI_time_s = S_time_s + I_time_s) %>%
#     mutate(SI_mem_kb = apply( df.prophex_stats0[c('S_mem_kb', 'I_mem_kb')], 1, max )) %>%
#     arrange(genome, rate, k, S_alg, d, qType) 
# show(df.prophex_stats)

# second for BWA -----------------------------------------------------------

df.bwa_memtime <- read_tsv(paste("bwa_memtime", filesuffix, sep="")) %>%
    mutate(I_time_s = `user(s)`+`sys(s)`) %>%
    mutate(I_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, I_time_s, I_mem_kb)
df.bwa_query_memtime <- read_tsv(paste("bwa_query_memtime", filesuffix, sep="")) %>%
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

#show(df.bwa_stats)


# SSHash -----------------------------------------------------------

df.sshash_memtime <- read_tsv(paste("sshash_memtime", filesuffix, sep="")) %>%
    mutate(I_time_s = `user(s)`+`sys(s)`) %>%
    mutate(I_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, I_time_s, I_mem_kb)
df.sshash_query_memtime <- read_tsv(paste("sshash_query_memtime", filesuffix, sep="")) %>%
    mutate(Q_time_s = `user(s)`+`sys(s)`) %>%
    mutate(Q_mem_kb = `max_RAM(kb)`) %>%
    select(genome, rate, S_alg, k, d, Q_time_s, Q_mem_kb, qType)

df.sshash_stats0 <- df.size_stats %>%
    filter(I_alg == "SSHash") %>%
    full_join(df.prophasm_memtime) %>%
    full_join(df.sshash_memtime) %>%
    full_join(df.sshash_query_memtime)
    
df.sshash_stats <- df.sshash_stats0 %>%
    mutate(SI_time_s = S_time_s + I_time_s) %>%
    mutate(SI_mem_kb = apply( df.sshash_stats0[c('S_mem_kb', 'I_mem_kb')], 1, max )) %>%
    arrange(genome, rate, k, S_alg, d, qType) 

#show(df.sshash_stats)


# third for SBWT -----------------------------------------------------------
df.sbwt_memtime <- read_tsv(paste("sbwt_memtime", filesuffix, sep="")) %>%
    mutate(SI_time_s = `user(s)`+`sys(s)`) %>%
    mutate(SI_mem_kb = `max_RAM(kb)`) %>%
    mutate(d = as.character(d)) %>%
    select(genome, rate, S_alg, k, d, SI_time_s, SI_mem_kb)

df.sbwt_query_memtime <- read_tsv(paste("sbwt_query_memtime", filesuffix, sep="")) %>%
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
df.cbl_memtime <- read_tsv(paste("cbl_memtime", filesuffix, sep="")) %>%
    mutate(SI_time_s = `user(s)`+`sys(s)`) %>%
    mutate(SI_mem_kb = `max_RAM(kb)`) %>%
    mutate(d = as.character(d)) %>%
    select(genome, rate, S_alg, k, d, SI_time_s, SI_mem_kb)

df.cbl_query_memtime <- read_tsv(paste("cbl_query_memtime", filesuffix, sep="")) %>%
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
    bind_rows(df.FMSIv02_stats)%>%
    #bind_rows(df.prophex_stats)%>%
    bind_rows(df.bwa_stats)%>%
    bind_rows(df.sshash_stats)%>%
    bind_rows(df.sbwt_stats)%>%
    bind_rows(df.cbl_stats)%>%
    select(-S_time_s)%>%
    select(-S_mem_kb)%>%
    select(-I_time_s)%>%
    select(-I_mem_kb)%>%
    arrange(genome, rate, k, I_alg, S_alg, d, qType)
    
df.stats %>% 
    write_tsv(paste("exp_01_build_index_results", filesuffix, sep=""),  na = "na")
