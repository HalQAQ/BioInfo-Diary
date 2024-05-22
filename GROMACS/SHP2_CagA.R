# Plots to evaluate the GROMACS pipeline
library(ggplot2)
setwd("D:/DeskTop/Courses/CBSB3/MiniProject")
setwd("./D_Nter_test3")

# Energy minimization
# Receives potential.xvg
potential <- read.table("potential.xvg", sep = "" , header = FALSE , skip = 24, na.strings = "",
                        stringsAsFactors = FALSE)
ggplot(data = potential, aes(x = V1, y = V2)) +
  geom_line() +
  geom_point() +
  ylim(min(potential$V2), 0) +
  labs(x = "Energy Minimization Step", y = bquote("Potential Energy (kJ "*~mol^-1*')')) +
  ggtitle("Energy Minimization, Steepest Descent") +
  theme_bw() +
  theme(plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("potential.png")

# Temperature equilibration
# Receives temperature.xvg
temperature <- read.table("temperature.xvg", sep = "" , header = FALSE , skip = 24, na.strings = "",
                          stringsAsFactors = FALSE)
temperature$average10ps <- NA
temperature$average10ps[10:nrow(temperature)] <- sapply(10:nrow(temperature), function(x){mean(temperature$V2[(x-9):x])})
ggplot(data = temperature, aes(x = V1, y = V2)) +
  geom_line() +
  geom_point() +
  geom_line(aes(y = average10ps, col = "Running average 10 ps")) +
  labs(x = "Time (ps)", y = "Temperature (K)") +
  ggtitle("Temperature, NVT equilibration") +
  theme_bw() +
  theme(legend.position = c(0.80, 0.9),
        legend.title = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("temperature.png")

# Pressure equilibration
# Receives pressure.xvg
pressure <- read.table("pressure.xvg", sep = "" , header = FALSE , skip = 24, na.strings = "",
                       stringsAsFactors = FALSE)
pressure$average10ps <- NA
pressure$average10ps[10:nrow(pressure)] <- sapply(10:nrow(pressure), function(x){mean(pressure$V2[(x-9):x])})
ggplot(data = pressure, aes(x = V1, y = V2)) +
  geom_line() +
  geom_point() +
  geom_line(aes(y = average10ps, col = "Running average 10 ps")) +
  labs(x = "Time (ps)", y = "Pressure (bar)") +
  ggtitle("Pressure, NPT equilibration") +
  theme_bw() +
  theme(legend.position = c(0.80, 0.9),
        legend.title = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("pressure.png")

# Density equilibration
# Receives density.xvg
density <- read.table("density.xvg", sep = "" , header = FALSE , skip = 24, na.strings = "",
                      stringsAsFactors = FALSE)
density$average10ps <- NA
density$average10ps[10:nrow(density)] <- sapply(10:nrow(density), function(x){mean(density$V2[(x-9):x])})
ggplot(data = density, aes(x = V1, y = V2)) +
  geom_line() +
  geom_point() +
  geom_line(aes(y = average10ps, col = "Running average 10 ps")) +
  labs(x = "Time (ps)", y = bquote("Density (kg "*~m^-3*')')) +
  ggtitle("Density, NPT equilibration") +
  theme_bw() +
  theme(legend.position = c(0.80, 0.2),
        legend.title = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("density.png")

groups <- c('D_Nter_test6', 'D_Nter_unphos_test4', 'D_Cter_test6', 'C_Nter_test4', 'C_Cter_test4')
for (group in groups) {
  setwd(paste('../', group, sep = ''))
  # RMSD, backbone
  # Receives rmsd.xvg and rmsd_xtal.xvg
  rmsd_equilibrated <- read.table("rmsd.xvg", sep = "" , header = FALSE , skip = 18, na.strings = "",
                        stringsAsFactors = FALSE)
  rmsd_xtal <- read.table("rmsd_xtal.xvg", sep = "" , header = FALSE , skip = 18, na.strings = "",
                                  stringsAsFactors = FALSE)
  rmsd <- rmsd_equilibrated
  names(rmsd) <- c("time", "equilibrated")
  rmsd$xtal <- rmsd_xtal$V2
  ggplot(data = rmsd, aes(x = time)) +
    geom_line(aes(y = equilibrated, col = "Ref: Equilibrated")) +
    geom_line(aes(y = xtal, col = "Ref: Original") ) +
    labs(x = "Time (ns)", y = "RMSD (nm)") +
    ggtitle("RMSD, backbone") +
    theme_bw() +
    theme(legend.position = c(0.80, 0.2),
          legend.title = element_blank(),
          plot.title = element_text(size = rel(1.5), face = "bold"))
  ggsave("RMSD.png")
  
  # Radius of gyration
  # Receives gyrate.xvg
  gyration <- read.table("gyrate.xvg", sep = "" , header = FALSE , skip = 27, na.strings = "",
                          stringsAsFactors = FALSE)
  ggplot(data = gyration, aes(x = V1/1000, y = V2)) +
    geom_line() +
    geom_point() +
  #  ylim(1.3, 1.50) +
    labs(x = "Time (ns)", y = bquote(~R[g]*" (nm)")) +
    ggtitle("Radius of gyration, Unrestrained MD") +
    theme_bw() +
    theme(plot.title = element_text(size = rel(1.5), face = "bold"))
  ggsave("gyrate.png")
}

# Coefficient of dispersion to represent data fluctuation
groups <- c('D_Nter_test3', 'D_Cter_test3', 'C_Nter_test1', 'C_Cter_test1', 
            'D_Nter_unphos_test1', 'D_Cter_unphos_test1', 'C_Nter_unphos_test1', 'C_Cter_unphos_test1')
cods_rmsd <- c()
cods_gyration <- c()
thresholds_rmsd <- c(2, 1, 2, 2.5, 1, 1, 1, 2)
means_rmsd_stable <- c()
diffs_gyration <- c()
for (i in 1:8) {
  setwd(paste('../', groups[i], sep = ''))
  rmsd_equilibrated <- read.table("rmsd.xvg", sep = "" , header = FALSE , skip = 18, na.strings = "",
                                  stringsAsFactors = FALSE)
  cod_rmsd = sd(rmsd_equilibrated$V2)/mean(rmsd_equilibrated$V2)
  cods_rmsd <- c(cods_rmsd, cod_rmsd)
  gyration <- read.table("gyrate.xvg", sep = "" , header = FALSE , skip = 27, na.strings = "",
                         stringsAsFactors = FALSE)
  cod_gyration <- sd(gyration$V2)/mean(gyration$V2)
  cods_gyration <- c(cods_gyration, cod_gyration)
  rmsd_stable <- rmsd_equilibrated$V2[which(rmsd_equilibrated$V1 > thresholds_rmsd[i])]
  means_rmsd_stable <- c(means_rmsd_stable, mean(rmsd_stable))
  gyration_pre <- gyration$V2[which(gyration$V1 <= 1)]
  gyration_post <- gyration$V2[which(gyration$V1 > 1)]
  diff_gyration <- gyration_post - gyration_pre
  diffs_gyration <- c(diffs_gyration, diff_gyration)
}

# Statistical tests
# Load data
rmsd_D_Nter <- data.frame('time' = rep(NA, 401))
gyration_D_Nter <- data.frame('time' = rep(NA, 401))
cods_gyration_D_Nter <- c()
for (i in 3:6) {
  setwd(paste('../D_Nter_test', i, sep = ''))
  rmsd <- read.table("rmsd.xvg", sep = "" , header = FALSE , skip = 18, na.strings = "",
                     stringsAsFactors = FALSE)
  gyration <- read.table("gyrate.xvg", sep = "" , header = FALSE , skip = 27, na.strings = "",
                         stringsAsFactors = FALSE)
  if (i == 3) {
    rmsd_D_Nter['time'] <- rmsd$V1
    gyration_D_Nter['time'] <- gyration$V1
  }
  rmsd_D_Nter[paste('sim', i-2, sep = '')] <- rmsd$V2
  gyration_D_Nter[paste('sim', i-2, sep = '')] <- gyration$V2
  cod_gyration <- sd(gyration$V2)/mean(gyration$V2)
  cods_gyration_D_Nter <- c(cods_gyration_D_Nter, cod_gyration)
}
rmsd_D_Nter['mean'] <- rowMeans(rmsd_D_Nter[-1])
gyration_D_Nter['mean'] <- rowMeans(gyration_D_Nter[-1])

rmsd_D_Nter_unphos <- data.frame('time' = rep(NA, 401))
gyration_D_Nter_unphos <- data.frame('time' = rep(NA, 401))
cods_gyration_D_Nter_unphos <- c()
for (i in 1:4) {
  setwd(paste('../D_Nter_unphos_test', i, sep = ''))
  rmsd <- read.table("rmsd.xvg", sep = "" , header = FALSE , skip = 18, na.strings = "",
                     stringsAsFactors = FALSE)
  gyration <- read.table("gyrate.xvg", sep = "" , header = FALSE , skip = 27, na.strings = "",
                         stringsAsFactors = FALSE)
  if (i == 1) {
    rmsd_D_Nter_unphos['time'] <- rmsd$V1
    gyration_D_Nter_unphos['time'] <- gyration$V1
  }
  rmsd_D_Nter_unphos[paste('sim', i, sep = '')] <- rmsd$V2
  gyration_D_Nter_unphos[paste('sim', i, sep = '')] <- gyration$V2
  cod_gyration <- sd(gyration$V2)/mean(gyration$V2)
  cods_gyration_D_Nter_unphos <- c(cods_gyration_D_Nter_unphos, cod_gyration)
}
rmsd_D_Nter_unphos['mean'] <- rowMeans(rmsd_D_Nter_unphos[-1])
gyration_D_Nter_unphos['mean'] <- rowMeans(gyration_D_Nter_unphos[-1])

rmsd_D_Cter <- data.frame('time' = rep(NA, 401))
gyration_D_Cter <- data.frame('time' = rep(NA, 401))
cods_gyration_D_Cter <- c()
for (i in 3:6) {
  setwd(paste('../D_Cter_test', i, sep = ''))
  rmsd <- read.table("rmsd.xvg", sep = "" , header = FALSE , skip = 18, na.strings = "",
                     stringsAsFactors = FALSE)
  gyration <- read.table("gyrate.xvg", sep = "" , header = FALSE , skip = 27, na.strings = "",
                         stringsAsFactors = FALSE)
  if (i == 3) {
    rmsd_D_Cter['time'] <- rmsd$V1
    gyration_D_Cter['time'] <- gyration$V1
  }
  rmsd_D_Cter[paste('sim', i-2, sep = '')] <- rmsd$V2
  gyration_D_Cter[paste('sim', i-2, sep = '')] <- gyration$V2
  cod_gyration <- sd(gyration$V2)/mean(gyration$V2)
  cods_gyration_D_Cter <- c(cods_gyration_D_Cter, cod_gyration)
}
rmsd_D_Cter['mean'] <- rowMeans(rmsd_D_Cter[-1])
gyration_D_Cter['mean'] <- rowMeans(gyration_D_Cter[-1])

rmsd_C_Nter <- data.frame('time' = rep(NA, 1001))
gyration_C_Nter <- data.frame('time' = rep(NA, 1001))
cods_gyration_C_Nter <- c()
for (i in 2:4) {
  setwd(paste('../C_Nter_test', i, sep = ''))
  rmsd <- read.table("rmsd.xvg", sep = "" , header = FALSE , skip = 18, na.strings = "",
                     stringsAsFactors = FALSE)
  gyration <- read.table("gyrate.xvg", sep = "" , header = FALSE , skip = 27, na.strings = "",
                         stringsAsFactors = FALSE)
  if (i == 2) {
    rmsd_C_Nter['time'] <- rmsd$V1
    gyration_C_Nter['time'] <- gyration$V1
  }
  rmsd_C_Nter[paste('sim', i-1, sep = '')] <- rmsd$V2
  gyration_C_Nter[paste('sim', i-1, sep = '')] <- gyration$V2
  cod_gyration <- sd(gyration$V2)/mean(gyration$V2)
  cods_gyration_C_Nter <- c(cods_gyration_C_Nter, cod_gyration)
}
rmsd_C_Nter['mean'] <- rowMeans(rmsd_C_Nter[-1])
gyration_C_Nter['mean'] <- rowMeans(gyration_C_Nter[-1])

rmsd_C_Cter <- data.frame('time' = rep(NA, 1001))
gyration_C_Cter <- data.frame('time' = rep(NA, 1001))
cods_gyration_C_Cter <- c()
for (i in 2:4) {
  setwd(paste('../C_Cter_test', i, sep = ''))
  rmsd <- read.table("rmsd.xvg", sep = "" , header = FALSE , skip = 18, na.strings = "",
                     stringsAsFactors = FALSE)
  if (i == 2) {
    rmsd_C_Cter['time'] <- rmsd$V1
    gyration_C_Cter['time'] <- gyration$V1
  }
  rmsd_C_Cter[paste('sim', i-1, sep = '')] <- rmsd$V2
  gyration_C_Cter[paste('sim', i-1, sep = '')] <- gyration$V2
  cod_gyration <- sd(gyration$V2)/mean(gyration$V2)
  cods_gyration_C_Cter <- c(cods_gyration_C_Cter, cod_gyration)
}
rmsd_C_Cter['mean'] <- rowMeans(rmsd_C_Cter[-1])
gyration_C_Cter['mean'] <- rowMeans(gyration_C_Cter[-1])


setwd('../Figures')
# Validate D_Nter and D_Nter_unphos: positive and negative control
rmsd_pi <- data.frame(time = rmsd_D_Nter$time, Pi = rmsd_D_Nter$mean, no_Pi = rmsd_D_Nter_unphos$mean)
ggplot(data = rmsd_pi, aes(x = time)) +
  geom_line(aes(y = Pi, col = "Phosphorylated")) +
  geom_line(aes(y = no_Pi, col = "Unphosphorylated") ) +
  labs(x = "Time (ns)", y = "RMSD (nm)") +
  ggtitle("RMSD, N_SH2 with EPIYA_D") +
  theme_bw() +
  theme(legend.position = c(0.80, 0.2),
        legend.title = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("RMSD_phosphorylation.png")
t.test(rmsd_D_Nter$mean, rmsd_D_Nter_unphos$mean, alternative = 'l')

# Validate EPIpYA_D binds more stably than EPIpYA_C
rmsd_total <- data.frame(time = rmsd_D_Nter$time, D_Nter = rmsd_D_Nter$mean, D_Cter = rmsd_D_Cter$mean, 
                         C_Nter = rmsd_C_Nter$mean[1:401], C_Cter = rmsd_C_Cter$mean[1:401])
# For Nter
ggplot(data = rmsd_total, aes(x = time)) +
  geom_line(aes(y = D_Nter, col = "EPIpYA_D")) +
  geom_line(aes(y = C_Nter, col = "EPIpYA_C") ) +
  labs(x = "Time (ns)", y = "RMSD (nm)") +
  ggtitle("RMSD, N_SH2 with EPIpYA type D and C") +
  theme_bw() +
  theme(legend.position = c(0.80, 0.2),
        legend.title = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("RMSD_CagA_Nter.png")
t.test(rmsd_D_Nter$mean, rmsd_C_Nter$mean, alternative = 'l')
# For Cter
ggplot(data = rmsd_total, aes(x = time)) +
  geom_line(aes(y = D_Cter, col = "EPIpYA_D")) +
  geom_line(aes(y = C_Cter, col = "EPIpYA_C") ) +
  labs(x = "Time (ns)", y = "RMSD (nm)") +
  ggtitle("RMSD, C_SH2 with EPIpYA type D and C") +
  theme_bw() +
  theme(legend.position = c(0.80, 0.2),
        legend.title = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("RMSD_CagA_Cter.png")
t.test(rmsd_D_Cter$mean, rmsd_C_Cter$mean, alternative = 'l')

# Explore Nter is more stable than Cter with EPIpYA
# For EPIpYA_D
ggplot(data = rmsd_total, aes(x = time)) +
  geom_line(aes(y = D_Nter, col = "N_SH2")) +
  geom_line(aes(y = D_Cter, col = "C_SH2") ) +
  labs(x = "Time (ns)", y = "RMSD (nm)") +
  ggtitle("RMSD, EPIpYA_D with SH2 domains") +
  theme_bw() +
  theme(legend.position = c(0.80, 0.2),
        legend.title = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("RMSD_SH2_D.png")
t.test(rmsd_D_Nter$mean, rmsd_D_Cter$mean, alternative = 'l')
# For EPIpYA_C
ggplot(data = rmsd_total, aes(x = time)) +
  geom_line(aes(y = C_Nter, col = "N_SH2")) +
  geom_line(aes(y = C_Cter, col = "C_SH2") ) +
  labs(x = "Time (ns)", y = "RMSD (nm)") +
  ggtitle("RMSD, EPIpYA_C with SH2 domains") +
  theme_bw() +
  theme(legend.position = c(0.80, 0.2),
        legend.title = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold"))
ggsave("RMSD_SH2_C.png")
t.test(rmsd_C_Nter$mean, rmsd_C_Cter$mean, alternative = 'l')

# Gyration
# means
t.test(gyration_D_Nter$mean, gyration_D_Nter_unphos$mean, alternative = 'l')  # yes
t.test(gyration_D_Nter$mean, gyration_C_Nter$mean, alternative = 'l')  # no
t.test(gyration_D_Cter$mean, gyration_C_Cter$mean, alternative = 'l')  # no
t.test(gyration_D_Nter$mean, gyration_D_Cter$mean, alternative = 'l')  # yes
t.test(gyration_C_Nter$mean, gyration_C_Cter$mean, alternative = 'l')  # no
# cods
cods_gyration <- data.frame('group' = c(rep('D_Nter', 4), rep('D_Nter_unphos', 4), rep('D_Cter', 4), rep('C_Nter', 3), rep('C_Cter', 3)), 
                            'sim' = c(rep(c('sim1', 'sim2', 'sim3', 'sim4'), 3), rep(c('sim1', 'sim2', 'sim3'), 2)), 
                            'value' = c(cods_gyration_D_Nter, cods_gyration_D_Nter_unphos, cods_gyration_D_Cter, cods_gyration_C_Nter, cods_gyration_C_Cter))
ggplot(data = cods_gyration, aes(x = group, y = value,fill=sim)) +
  geom_bar(stat="identity",position=position_dodge(0.75)) +
  labs(x = 'Group', y = 'Value') +
  ggtitle('Coefficient of Dispersion of RG')
ggsave('COD_RG.png', width = 6, height = 4)
t.test(cods_gyration_D_Nter, cods_gyration_D_Nter_unphos, alternative = 'l')  # yes
t.test(cods_gyration_D_Nter, cods_gyration_C_Nter, alternative = 'l')  # no
t.test(cods_gyration_D_Cter, cods_gyration_C_Cter, alternative = 'l')  # no
t.test(cods_gyration_D_Nter, cods_gyration_D_Cter, alternative = 'l')  # yes
t.test(cods_gyration_C_Nter, cods_gyration_C_Cter, alternative = 'l')  # no


