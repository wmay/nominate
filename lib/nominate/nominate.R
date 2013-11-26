if( require("wnominate") == FALSE ) {
  print("The R 'wnominate' package is not installed.")
  print("Please follow the instructions to install wnominate.")
  install.packages("wnominate", repos='http://cran.us.r-project.org')
  if( require("wnominate") ) {
    print("wnominate is now installed.")
  } else {
    stop("Did not install wnominate.")
  }
}

# performing W-NOMINATE analysis
data <- read.csv("votes.csv", header=F, sep="|", check.names = F, stringsAsFactors=F,
                 quote="", row.names = NULL)
names <- data[, 1]
legData <- matrix(data[, 2], length(data[, 2]), 1)
colnames(legData) <- "party"
data <- data[, -c(1, 2)]
rc <- rollcall(data, yea = c("Y"), nay = c("N"), missing = c('r'),
               notInLegis = c("M"), legis.names = names, legis.data = legData,
               desc = "NA", source = "NA")
result <- wnominate(rc, polarity = c(1, 1))

write.table(result$legislators, file = "legislators.csv", sep = "|", quote = F)
write.table(result$rollcalls, file = "rollcalls.csv", sep = "|", quote = F)
write.table(result$dimensions, file = "dimensions.csv", sep = "|", quote = F)
write.table(result$eigenvalues, file = "eigenvalues.csv", sep = "|", quote = F)
write.table(result$beta, file = "beta.csv", sep = "|", quote = F)
write.table(result$weights, file = "weights.csv", sep = "|", quote = F)
write.table(result$fits, file = "fits.csv", sep = "|", quote = F)

# png('result.png', width=700, height=500, res=100)
plot(result)
# dev.off()