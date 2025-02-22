library(tidyverse)

# 用[]选取元素-------
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]
x[c(-1, -3, -5)]

x <- c(10, 3, NA, 5, 8, 1, NA)
x[!is.na(x)]
x[x %% 2 == 0]

x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]

df <- tibble(
  x = 1:3,
  y = c("a", "e", "f"),
  z = runif(3)
)
df[1, 2]
df[, c("x", "y")]
df[df$x > 1, ]

df1 <- data.frame(x = 1:3)
df1
df1[, "x"]
df2 <- tibble(x = 1:3)
df2[, "x"]
df1[, "x", drop = FALSE]

df <- tibble(
  x = c(2, 3, 1, 1, NA),
  y = letters[1:5],
  z = runif(5)
)
df %>% filter(x > 1)
df[df$x > 1 & !is.na(df$x), ]
df[which(df$x > 1), ]

df %>% arrange(x, y)
df[order(df$x, df$y), ]
df[order(df$x, decreasing = TRUE), ]

df %>% select(x, z)
df[, c("x", "z")]

df %>%
  filter(x > 1) %>%
  select(x, z)
subset(df, x > 1, c(y, z))

## 练习
set.seed(123)
(x <- runif(11, min = 0, max = 10) %>% round())

even_position <- function(x) {
  x[seq(2, length(x), 2)]
}
even_position(x)

drop_last <- function(x) {
  x[-length(x)]
}
drop_last(x)

all_even <- function(x) {
  x[x %% 2 == 0 & !is.na(x)]
}
all_even(x)
?which

# 用$和[[]]挑出单列----
tb <- tibble(
  x = 1:4,
  y = c(10, 4, 1, 21)
)
tb[[1]]
tb[["x"]]
tb$x

tb$z <- tb$x + tb$y
tb

max(diamonds$carat)
levels(diamonds$cut)

diamonds %>%
  pull(carat) %>%
  max()
diamonds %>%
  pull(cut) %>%
  levels()

df <- data.frame(x1 = 1:3, y = 4:6)
df$x
df$z

l <- list(
  a = 1:3,
  b = "a string",
  c = pi,
  d = list(-1, -5)
)
str(l[1:2])
str(l[1])
str(l[4])

str(l[[1]])
str(l[[4]])
str(l$a)

reprex::reprex({
  df <- data.frame(x = 1:3, y = letters[1:3])
  df["x"]
  df[, "x"]
  df[["x"]]
})
## 练习
reprex::reprex({
  x <- 1:10
  x[11]
  x[[11]]
})

# apply 家族-------
df <- tibble(a = 1, b = 2, c = "a", d = "b", e = 4)
num_cols <- sapply(df, is.numeric)
num_cols

df[, num_cols] <- lapply(df[, num_cols, drop = FALSE], \(x) x * 2)
df

vapply(df, is.numeric, logical(1))

diamonds %>%
  group_by(cut) %>%
  summarise(price = mean(price))

tapply(diamonds$price, diamonds$cut, mean)

reprex::reprex({
  m <- matrix(1:12, nrow = 3)
  apply(m, 1, sum)
  apply(m, 2, sum)
})

# for 循环-------
# 。。。。。

# 画图----
hist(diamonds$carat)
plot(diamonds$carat, diamonds$price)
