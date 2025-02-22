# 前言

这章英文直译是baseR的野外指南。实际内容是baseR语法的快速过一下。因为真的是每一块都涉及一点最重要的地方。用这一章来结束program这一部分。

> 之所以叫野外指南，大概率就是说大部分的代码很有可能也还是以base的形式遇到的。
>
> 主要是遇到别人写的代码。
>
> 不过这些大部分我应该是会的。

倒反天罡，用tidyverse解释base R。

```R
library(tidyverse)
```

# 用`[`选取元素

一维的向量，那方括号里面就1个，二维的里面就得填两个。

## 向量的子集

**用正数表示子集**

```R
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]
#> [1] "three" "two"   "five"
```

按序号向量的顺序保留对应的元素。同样的道理，甚至能得到比输入更长的“子集”

```R
x[c(1, 1, 5, 5, 5, 2)]
#> [1] "one"  "one"  "five" "five" "five" "two"
```

**用负号表示丢掉元素**

```R
x[c(-1, -3, -5)]
#> [1] "two"  "four"
```

**全长的逻辑向量**，保留TRUE的。

```R
x <- c(10, 3, NA, 5, 8, 1, NA)

# All non-missing values of x
x[!is.na(x)]
#> [1] 10  3  5  8  1

# All even (or missing!) values of x
x[x %% 2 == 0]
#> [1] 10 NA  8 NA
```

最常用的比丢掉缺失值，或者保留偶数

> filter不会保留NA

**字符向量**，尤其用于有名字的向量

```R
x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]
#> xyz def 
#>   5   2
```

**空**，返回的是完整的向量。这个在这里用处不大。

## 数据框的子集

基本用法是`df[rows,cols]`

但是也可以空一个，那么对应的就返回所有了。`df[rows,]`  `df[,cols]`

```R
df <- tibble(
  x = 1:3, 
  y = c("a", "e", "f"), 
  z = runif(3)
)

# Select first row and second column
df[1, 2]
#> # A tibble: 1 × 1
#>   y    
#>   <chr>
#> 1 a

# Select all rows and columns x and y
df[, c("x" , "y")]
#> # A tibble: 3 × 2
#>       x y    
#>   <int> <chr>
#> 1     1 a    
#> 2     2 e    
#> 3     3 f

# Select rows where `x` is greater than 1 and all columns
df[df$x > 1, ]
#> # A tibble: 2 × 3
#>       x y         z
#>   <int> <chr> <dbl>
#> 1     2 e     0.834
#> 2     3 f     0.601
```

前面两个都差不多，但是最后一个其实也是base里的用法，用美元符选择其中一列。之所以不能直接写x，就是因为baseR没有整洁选择的能力。

一般情况下data.frame和tibble看起来差不多，但是实际用起来就会发现一个不一样，tibble总是能保留为tibble，不管里面是实际是几乘几的。但是data.frame对于选择了单列的，自动变为了向量。

```R
df1 <- data.frame(x = 1:3)
df1[, "x"]
#> [1] 1 2 3

df2 <- tibble(x = 1:3)
df2[, "x"]
#> # A tibble: 3 × 1
#>       x
#>   <int>
#> 1     1
#> 2     2
#> 3     3
```

baseR里面也可以保留，只要加个`drop = FALSE`就好了。

```R
df1[, "x" , drop = FALSE]
#>   x
#> 1 1
#> 2 2
#> 3 3
```

## dplyr的等价操作

这里就是用baseR来进行dplyr一样的操作。

**筛选行**

```R
df <- tibble(
  x = c(2, 3, 1, 1, NA), 
  y = letters[1:5], 
  z = runif(5)
)
df |> filter(x > 1)

# same as
df[!is.na(df$x) & df$x > 1, ]
df[which(df$x > 1), ]
```

另外一个方法，那就是用which函数，似乎能返回逻辑向量中TRUE的索引。（利用了它的副作用，不返回NA的）

**排序**

```R
df |> arrange(x, y)

# same as
df[order(df$x, df$y), ]
```

order函数可以返回向量对应元素的排序向量。

那要是想倒序，可以设置`decreasing = TRUE`参数。或者也可以计算`-rank(col)`，然后再`order()`顺序输出。

**筛选列**

```R
df |> select(x, z)

# same as
df[, c("x", "z")]
```

其实顺带也有relocate的作用。

baseR也有一个函数叫做`subset()`，同时带有filter和select的功能。

```R
df |> 
  filter(x > 1) |> 
  select(y, z)
#> # A tibble: 2 × 2
#>   y           z
#>   <chr>   <dbl>
#> 1 a     0.157  
#> 2 b     0.00740
# same as
df |> subset(x > 1, c(y, z))
```

据说就是这个函数启发了dplyr的大部分语法，我也说呢，这个函数这么像tidyverse的。

> 这个函数不能`select(strat_with())`这样的操作。

## 练习

写几个向量的函数

1. 返回偶数位置的元素
2. 所有元素除了最后一个
3. 所有偶数值（无缺失值）

```R
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
```

> Why is `x[-which(x > 0)]` not the same as `x[x <= 0]`? Read the documentation for `which()` and do some experiments to figure it out.

这样看来似乎第一个也会保留NA了嘛，这个我还真解释不了。

# 用`$`和`[[`选择单个元素

用`$`和`[[]]`可以从数据框中挑出单列（向量形式）

## Data frames

```R
tb <- tibble(
  x = 1:4,
  y = c(10, 4, 1, 21)
)

# by position
tb[[1]]
#> [1] 1 2 3 4

# by name
tb[["x"]]
#> [1] 1 2 3 4
tb$x
#> [1] 1 2 3 4
```

可以用名字或者索引

baseR用来实现mutate的操作是这样的，类似于赋值。

```R
tb$z <- tb$x + tb$y
tb
#> # A tibble: 4 × 3
#>       x     y     z
#>   <int> <dbl> <dbl>
#> 1     1    10    11
#> 2     2     4     6
#> 3     3     1     4
#> 4     4    21    25
```

其实baseR也有类似于简洁选择的方法，这个就涉及`transform`，`with`，`within`了。

https://gist.github.com/hadley/1986a273e384fb2d4d752c18ed71bedf

```R
data(diamonds, package = "ggplot2")

# Most straightforward
diamonds$ppc <- diamonds$price / diamonds$carat

# Avoid repeating diamonds 
diamonds$ppc <- with(diamonds, price / carat)

# The inspiration for dplyr's mutate
diamonds <- transform(diamonds, ppc = price / carat)
diamonds <- diamonds |> transform(ppc = price / carat)

# Similar to transform(), but uses assignment rather argument matching
# (can also use = here, since = is equivalent to <- outside of a function call)
diamonds <- within(diamonds, {
  ppc <- price / carat
})
diamonds <- diamonds |> within({
  ppc <- price / carat
})

# Protect against partial matching
diamonds$ppc <- diamonds[["price"]] / diamonds[["carat"]]
diamonds$ppc <- diamonds[, "price"] / diamonds[, "carat"]

# FORBIDDEN
attach(diamonds)
diamonds$ppc <- price / carat
```

with单个，within多个，返回的是向量；transform返回的是数据框。

attach相当于把列释放到全局了。

--------

单列拿出来汇总，不需要summarise了。

```R
max(diamonds$carat)
#> [1] 5.01

levels(diamonds$cut)
#> [1] "Fair"      "Good"      "Very Good" "Premium"   "Ideal"
```

dplyr其实也可以提取出向量，使用pull函数。

```R
diamonds |> pull(carat) |> max()
#> [1] 5.01

diamonds |> pull(cut) |> levels()
#> [1] "Fair"      "Good"      "Very Good" "Premium"   "Ideal"
```

> 这倒是解答了我的一个疑惑。这样就实现了tibble和data.frame互通有无了。

## Tibbles

介绍了一个tibble和data frame的区别。data frame竟然能简单的匹配前缀。

```R
df <- data.frame(x1 = 1)
df$x
#> [1] 1
df$z
#> NULL
```

但是这个性质tibble是没有的

```R
tb <- tibble(x1 = 1)

tb$x
#> Warning: Unknown or uninitialised column: `x`.
#> NULL
tb$z
#> Warning: Unknown or uninitialised column: `z`.
#> NULL
```

返回的是空值。（但是会报警）

这也是作者称tibble懒惰且不善：做得少，抱怨多。

> 但是又x1和x2的情况下，data frame 返回x的也是空。
>
> 但是我觉得这个特性其实没什么用，降低了代码的可读性。虽然增加了一定的容错。

## Lists

列表也可以进行索引

```R
l <- list(
  a = 1:3, 
  b = "a string", 
  c = pi, 
  d = list(-1, -5)
)

str(l[1:2])
#> List of 2
#>  $ a: int [1:3] 1 2 3
#>  $ b: chr "a string"

str(l[1])
#> List of 1
#>  $ a: int [1:3] 1 2 3

str(l[4])
#> List of 1
#>  $ d:List of 2
#>   ..$ : num -1
#>   ..$ : num -5
```

一个方括号就是列表的子集，返回的还是列表。要想获取单个对象的内容，得用两个括号或者美元符了。

```R
str(l[[1]])
#>  int [1:3] 1 2 3

str(l[[4]])
#> List of 2
#>  $ : num -1
#>  $ : num -5

str(l$a)
#>  int [1:3] 1 2 3
```

为了解释这个道理，作者还举了一个生动的例子，一目了然，不多解释。

![Three photos. On the left is a photo of a glass pepper shaker. Instead of the pepper shaker containing pepper, it contains a single packet of pepper. In the middle is a photo of a single packet of pepper. On the right is a photo of the contents of a packet of pepper.](./0627 base R.assets/pepper.png)

其实data frame也可以在括号里只写一个字符串。

``` r
df <- data.frame(x = 1:3, y = letters[1:3])
df["x"]
#>   x
#> 1 1
#> 2 2
#> 3 3
```

``` r
df[, "x"]
#> [1] 1 2 3
```

``` r
df[["x"]]
#> [1] 1 2 3
```

> 似乎从底层上看来，数据框是列的列表。每一列都是一个对象。

## 练习

> What happens when you use `[[` with a positive integer that’s bigger than the length of the vector? What happens when you subset with a name that doesn’t exist?

``` r
x <- 1:10
x[11]
#> [1] NA
```

``` r
x[[11]]
#> Error in x[[11]]: subscript out of bounds
```

神奇，向量也是可以用两个

> What would `pepper[[1]][1]` be? What about `pepper[[1]][[1]]`?

这个就符合结合律了，你把前面的看做一个对象，后面就随便你了。

# Apply家族

这里对应的就是across和map之类的进阶操作了。这里讲的很简略。

**lapply**与**sapply** **vapply**

其实就是list的apply，和map函数几乎一样。都是针对列表的，两者似乎可以等价替换。

对于数据框而言，across也可以和lapply对应

sapply和lapply差不多，但是会尝试简化结果。（似乎和map_vec类似）

不然lapply相当于map，返回的肯定是列表。

```R
df <- tibble(a = 1, b = 2, c = "a", d = "b", e = 4)

# First find numeric columns
num_cols <- sapply(df, is.numeric)
num_cols
#>     a     b     c     d     e 
#>  TRUE  TRUE FALSE FALSE  TRUE

# Then transform each column with lapply() then replace the original values
df[, num_cols] <- lapply(df[, num_cols, drop = FALSE], \(x) x * 2)
df
#> # A tibble: 1 × 5
#>       a     b c     d         e
#>   <dbl> <dbl> <chr> <chr> <dbl>
#> 1     2     4 a     b         8
```

看来还是我的想象力限制了我，把一个列表返回给一个数据框，居然也能成功。（这里sapply肯定不行了吧）

sapply还有一个兄弟，vapply，也是向量输出的。

```R
vapply(df, is.numeric, logical(1))
#>     a     b     c     d     e 
#>  TRUE  TRUE FALSE FALSE  TRUE
```

但是这里有一个奇怪的附加项是必备的，那就是一位的向量，`logical(1)`

----

数据汇总方面，**tapply**也很有用

```R
diamonds |> 
  group_by(cut) |> 
  summarize(price = mean(price))
#> # A tibble: 5 × 2
#>   cut       price
#>   <ord>     <dbl>
#> 1 Fair      4359.
#> 2 Good      3929.
#> 3 Very Good 3982.
#> 4 Premium   4584.
#> 5 Ideal     3458.

tapply(diamonds$price, diamonds$cut, mean)
#>      Fair      Good Very Good   Premium     Ideal 
#>  4358.758  3928.864  3981.760  4584.258  3457.542
```

用法是 数据向量，分组向量，汇总函数，simplify默认是向量输出（有名的）

```R
tapply(X, INDEX, FUN = NULL, ..., simplify = TRUE)
```

[in a gist](https://gist.github.com/hadley/c430501804349d382ce90754936ab8ec) 作者也提供了一些summarise的复现例子，都还是蛮复杂的。

--------

最后是apply函数，适用于矩阵和数组。应该是可以按行计算。（但是R本身就是向量了应该也好说吧）。据说这是一种危险操作，速度慢。

```R
m <- matrix(1:12, nrow = 3)
apply(m, 1, sum)#按行求
#> [1] 22 26 30
apply(m, 2, sum)#按列求
#> [1]  6 15 24 33
```

# for循环

> 诶，我记得R也有while吧，看来是不讲了。
>
> 原来apply和map家族背地里都是for嘛，那有什么区别呢？

用法和python不一样，似乎和js是一样的，得有括号。

```R
for (element in vector) {
  # do something with element
}
```

作者用for复现了上一章map读取文件的例子。

```R
paths <- dir("data/gapminder", pattern = "\\.xlsx$", full.names = TRUE)
files <- map(paths, readxl::read_excel)
```

```R
files <- vector("list", length(paths))#长度为5的空列表
seq_along(paths)#生成向量长度的，相当于1:length(paths)
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12
for (i in seq_along(paths)) {
  files[[i]] <- readxl::read_excel(paths[[i]])
}
```

我以前都是`1:length()`这样的写法，怪不得VScode会警告。

然后把列表里的数据框合在一起，也不需要`list_rbind()`，用`do.call`就够了。

```R
do.call(rbind, files)
#> # A tibble: 1,704 × 5
#>   country     continent lifeExp      pop gdpPercap
#>   <chr>       <chr>       <dbl>    <dbl>     <dbl>
#> 1 Afghanistan Asia         28.8  8425333      779.
#> 2 Albania     Europe       55.2  1282697     1601.
#> 3 Algeria     Africa       43.1  9279525     2449.
#> 4 Angola      Africa       30.0  4232095     3521.
#> 5 Argentina   Americas     62.5 17876956     5911.
#> 6 Australia   Oceania      69.1  8691212    10040.
#> # ℹ 1,698 more rows
```

也可以用for循环

```R
out <- NULL
for (path in paths) {
  out <- rbind(out, readxl::read_excel(path))
}
```

> 我之前确实遇到过，循环本身不慢，但是循环增长向量，rbind是很慢的。

# 画图

baseR本身也有一些画图的函数，我之前也玩过，但是现在彻底拥抱ggplot2了。

但是画一些实验性质的还是不错的，因为非常简洁。

这里也没有多讲了。

```R
# Left
hist(diamonds$carat)

# Right
plot(diamonds$carat, diamonds$price)
```

![On the left, histogram of carats of diamonds, ranging from 0 to 5 carats. The distribution is unimodal and right-skewed. On the right, scatter plot of price vs. carat of diamonds, showing a positive relationship that fans out as both price and carat increases. The scatter plot shows very few diamonds bigger than 3 carats compared to diamonds between 0 to 3 carats.](./0627 base R.assets/unnamed-chunk-38-1.png)

![On the left, histogram of carats of diamonds, ranging from 0 to 5 carats. The distribution is unimodal and right-skewed. On the right, scatter plot of price vs. carat of diamonds, showing a positive relationship that fans out as both price and carat increases. The scatter plot shows very few diamonds bigger than 3 carats compared to diamonds between 0 to 3 carats.](./0627 base R.assets/unnamed-chunk-38-2.png)

由于没有简洁选择，有的时候还是蛮繁琐的。

# 总结

baseR还是很重要滴，基于向量的操作方式在之后写R包可能会非常有用。到这里这部分基本上正文内容就结束了。肯定还有更多进阶的操作了。

下面两章应该是quarto写书的方法，我觉得大概率是用不到的。

但是从数据分析的完整性而言，quarto也是communicate的一种方式

阿不，其实也是蛮重要的，可以写成教程卖给别人，虽然我暂时没有这个想法。但是说实话后面两章内容也是蛮不少的。