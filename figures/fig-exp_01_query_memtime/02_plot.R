#!/usr/bin/env Rscript

library(tidyverse)
library(ggsci)

h <- 7
w <-  7.5 
u <- "cm"


theme_set(theme_bw() +
              theme(
                  axis.text.x = element_text(
                      size = 10,
                      angle = 0,
                      hjust = 0.5,
                      vjust = 0.1

                  ),
                  panel.grid.minor.x = element_blank()
              ))

scfill <- scale_fill_npg


# Longer format -----------------------------------------------------------

df0 <- read_tsv("data.tsv", na = "na")
df1 <- df0 %>%
    mutate(genome = str_replace(genome, "sars-cov-2_pangenome_k32", "SARS-CoV-2")) %>%
    mutate(genome = str_replace(genome, "spneumo_pangenome_k32", "S.Pneumoniae-pangenome")) %>%
    mutate(genome = str_replace(genome, "spneumoniae", "S.Pneumoniae-genome")) %>%
    mutate(genome = str_replace(genome, "escherichia_coli.k32", "E.Coli")) %>%
    mutate(Q_time_per_query_ms = 1000*1000*Q_time_s / num_queries) %>%
    mutate(SIalg = paste(I_alg, "-", S_alg)) %>%
    mutate (alg = case_when(
                SIalg == "sbwt - none" ~ as.character(d+3), # (index with RCs)", # d \in [0,2] for SBWT
                SIalg == "cbl - none" ~ as.character(6),
                SIalg == "SSHash - prophasm" ~ as.character(2),
                SIalg == "bwa - prophasm" ~ as.character(1),
                SIalg == "prophex - prophasm" ~ as.character(0),
                SIalg == "fmsi - local" ~ as.character(d+7),
                SIalg == "fmsi - global" ~ as.character(7),
                SIalg == "FMSIv02 - global" ~ as.character(13),
                SIalg == "FMSIv02 - local" ~ as.character(d+13),
                          )) %>%
    mutate (algorithm = case_when(
                SIalg == "sbwt - none" & d == 0 ~ "SBWT (plain-matrix)", # (index with RCs)", the default varinat
                SIalg == "sbwt - none" & d == 1 ~ "SBWT (plain-matrix, index w/o RCs)", # default variant
                SIalg == "sbwt - none" & d == 2 ~ "SBWT (rrr-split)", # memory-efficient variant, with RCs
                SIalg == "cbl - none" ~ "CBL",
                SIalg == "SSHash - prophasm" ~ "SSHash (on ProphAsm output)",
                SIalg == "bwa - prophasm" ~ "BWA (on ProphAsm output)",
                SIalg == "prophex - prophasm" ~ "ProPhex (on ProphAsm output)",
                SIalg == "fmsi - local" ~ paste("FMSI (on kmercamel's local with d=", d, ")", sep=""),
                SIalg == "fmsi - global" ~ "FMSI (on kmercamel's global)",
                SIalg == "FMSIv02 - local" ~ paste("FMSI v0.2 (on kmercamel's local with d=", d, ")", sep=""),
                SIalg == "FMSIv02 - global" ~ "FMSI v0.2 (on kmercamel's global)",
                          )) %>%
    mutate (qTypeLabel = case_when(
                qType == "Pos" ~ "+",
                qType == "Neg" ~ "-",
                qType == "0" ~ "", # not used now
                          ))

                          
# FILTER OUT SOME ALGS.
df <- df1 %>%
	filter(SIalg != "prophex - prophasm") %>% # no ProPhex, just BWA
	#filter(SIalg != "sbwt - none" | d == 0 | d == 2) %>% # for now, SBWT just with RCs
	filter(SIalg != "fmsi - local" | d == 1) %>% # # camel's local only with d == 1
  filter(SIalg != "fmsi - local") %>% ## FMSI of only v0.2
  filter(SIalg != "fmsi - global") %>% ## FMSI of only v0.2
	filter(SIalg != "FMSIv02 - local" | d == 1) %>% # # camel's local only with d == 1
    filter(SIalg != "sbwt - none" | d == 1) %>% # only the default SBWT variant
	filter(qType != "0") # FILTERING OUT original queries (random mix of positive and negative, based on subsampling rate)

options(tibble.width = Inf, width = 300) # for printing
show(df)

for (g in c("SARS-CoV-2",  "S.Pneumoniae-pangenome", "E.Coli", "S.Pneumoniae-genome")) { # setup with legend
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
                filter(k == kk | (kk == 23 & k == 31))%>%
                filter(genome == g) %>%
                mutate(ka = paste(k, algorithm))

            ggplot(df_filtered) +
                aes(x = Q_mem_kb * 1000 * 8 / kmer_count,
                    y = Q_time_per_query_ms,
                    shape = algorithm,
                    color = algorithm,
                    label = qTypeLabel,
                    alpha = 1 - (k - 23) / 8,
                    ) +
                scfill() +
                geom_point() +
                geom_text(hjust=-0.45,vjust=0.4,size = 6/.pt,colour="black") +
                geom_line(aes(group = ka)) +
                scale_x_continuous(
                    name = 'query RAM usage bits / kmer',
                    trans='log2',
                    breaks = c(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048),
                ) +
                scale_y_continuous(
                    name = expression(paste('time per query in ', mu, 's')),
                    trans='log10',
                    #lim = c(1, 22.25) --- UNCOMMENT TO GET THE FIGURES USED IN THE PAPER
                ) +
                guides(fill = guide_legend(title = "Algorithm", title.position = "top"),label=none) +
                #scale_fill_manual(values = alg, labels = algorithm) +
                theme(plot.margin = margin(0.1, 0.25, 0, 0, "cm"), legend.position = "none") # for hiding the legend

            ggsave(
                paste("query_RAM_bits_per_kmer_vs_query_ms.g_", g, ".r_", rr, ".k_", kk, ".pdf", sep=""),
                height = h,
                width = w,
                unit = u
            )
        }
    }
}


