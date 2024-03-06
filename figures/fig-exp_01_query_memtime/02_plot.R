#!/usr/bin/env Rscript

library(tidyverse)
library(ggsci)

h <- 7
w <- 14 ## 7.5 w/o legend
u <- "cm"


theme_set(theme_bw() +
              theme(
                  axis.text.x = element_text(
                      size = 10,
                      angle = 0,
                      hjust = 0.5,
                      vjust = 0.1

                  ),
                  panel.grid.major.x = element_blank()
              ))

scfill <- scale_fill_npg


# Longer format -----------------------------------------------------------

df0 <- read_tsv("data.tsv", na = "na")
df1 <- df0 %>%
    mutate(genome = str_replace(genome, "sars-cov-2_pangenome_k32", "SARS-CoV-2")) %>%
    mutate(genome = str_replace(genome, "spneumo_pangenome_k32", "S.Pneumoniae")) %>%
    mutate(genome = str_replace(genome, "escherichia_coli.k32", "E.Coli")) %>%
    mutate(Q_time_per_query_ms = 1000*Q_time_s / num_queries) %>%
    mutate(SIalg = paste(I_alg, "-", S_alg)) %>%
    mutate (alg = case_when(
                SIalg == "sbwt - none" ~ as.character(d+2), # (index with RCs)", # d = 0 or 1 for SBWT
                SIalg == "cbl - none" ~ as.character(4),
                SIalg == "bwa - prophasm" ~ as.character(1),
                SIalg == "prophex - prophasm" ~ as.character(0),
                SIalg == "fmsi - local" ~ as.character(d+5),
                SIalg == "fmsi - global" ~ as.character(5),
                          )) %>%
    mutate (algorithm = case_when(
                SIalg == "sbwt - none" & d == 0 ~ "SBWT", # (index with RCs)", # d = 0 or 1 for SBWT
                SIalg == "sbwt - none" & d == 1 ~ "SBWT (index w/o RCs)", # d = 0 or 1 for SBWT
                SIalg == "cbl - none" ~ "CBL",
                SIalg == "bwa - prophasm" ~ "BWA (on ProphAsm output)",
                SIalg == "prophex - prophasm" ~ "ProPhex (on ProphAsm output)",
                SIalg == "fmsi - local" ~ paste("FMSI (on kmercamel's local with d=", d, ")", sep=""),
                SIalg == "fmsi - global" ~ "FMSI (on kmercamel's global)",
                          )) %>%
    mutate (qTypeLabel = case_when(
                qType == "Pos" ~ "+",
                qType == "Neg" ~ "-",
                qType == "0" ~ "", # not used now
                          ))

                          
# FILTER OUT SOME ALGS.
df <- df1 %>%
	filter(SIalg != "prophex - prophasm") %>% # no ProPhex, just BWA
	filter(SIalg != "sbwt - none" | d == 0) %>% # for now, SBWT just with RCs
	filter(SIalg != "fmsi - local" | d == 1) %>% # # camel's local only with d == 1
	filter(qType != "0") # FILTERING OUT original queries (random mix of positive and negative, based on subsampling rate)

options(tibble.width = Inf, width = 300) # for printing
show(df)

for (g in c("SARS-CoV-2",  "S.Pneumoniae", "E.Coli")) { # setup with legend
    for (kk in c(15, 23, 31)) {
        for (rr in c(0.01, 0.1, 0.5, 1.0)) {
#for (g in c("E.Coli")) { # setup w/o legend
#    for (kk in c(23)) {
#        for (rr in c(0.1, 1.0)) {
			if(rr == 0.5 & g == "E.Coli") # no data for E.coli with r = 0.5
				next
            ########################################################################
            ########################################################################
            #################### index size vs. query time #########################
            ########################################################################
            ########################################################################
            df_filtered <- df %>%
                filter(rate == rr) %>%
                filter(k == kk)%>%
                filter(genome == g)

            ggplot(df_filtered) +
                aes(x = Q_mem_kb * 1000 * 8 / kmer_count,
                    y = Q_time_per_query_ms,
                    shape = algorithm,
                    color = algorithm,
                    label = qTypeLabel) +
                scfill() +
                geom_point() +
                geom_text(hjust=-0.45,vjust=0.4,size = 6/.pt,colour="black") +
                geom_line(aes(group = algorithm)) +
                scale_x_continuous(
                    name = 'query RAM usage bits / kmer',
                    trans='log2'
                ) +
                scale_y_continuous(
                    name = 'time per query in ms',
                    trans='log10',
                    #breaks = seq(1, 2, 0.2),
                    #lim = c(1.0, 2.05),
                    #expand = c(0, 0)
                ) +
                guides(fill = guide_legend(title = "Algorithm", title.position = "top"),label=none) +
                #scale_fill_manual(values = alg, labels = algorithm) +
                theme(plot.margin = margin(0.1, 0.25, 0, 0, "cm")) #, legend.position = "none") # for hiding the legend

            ggsave(
                paste("query_RAM_bits_per_kmer_vs_query_ms.g_", g, ".r_", rr, ".k_", kk, "-woLegend.pdf", sep=""),
                height = h,
                width = w,
                unit = u
            )
        }
    }
}


