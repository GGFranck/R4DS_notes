# 前言

之前从CSV到了数据库，但是接下来要遇到的就是大数据。这里介绍的是parquet格式，这是一种基于开放标准、广泛用于大数据系统的格式。

https://parquet.apache.org/

> 确实是完全没有接触过。

[Apache Arrow](https://arrow.apache.org/)是一个多语言工具包，用来分析和传输大数据，R语言的arrow包就可以使用这个玩意儿。

arrow和dbplyr都有dplyr的后端。那就会遇到取舍的问题，如果原本就是parquet那就arrow，如果原本就是数据库，那就db呗。如果一开始CSV那就视情况而定了。

做好准备吧，这一章要比较dbplyr和arrow，所以都加载进来。

```R
library(tidyverse)
library(arrow)
library(dbplyr)
library(duckdb)
```

# 获取数据

既然是大数据，肯定就是很大的文件了。咱们下载之后，练完了就可以删除了。

https://data.seattle.gov/Community/Checkouts-by-Title/tmmm-ytt6

似乎还得翻墙才能加载完啊。那咱们也可以试试作者提供的下载方式看看。他应该是存在了亚马逊的云盘上了。9GB，下载起来还是比较慢的。没想到还是一个csv文件呢。不过肯定不能用excel打开，我一般会用sublime打开看看。

```R
dir.create("data", showWarnings = FALSE)

curl::multi_download(
  "https://r4ds.s3.us-west-2.amazonaws.com/seattle-library-checkouts.csv",
  "data/seattle-library-checkouts.csv",
  resume = TRUE
)
```

用`curl::multi_download()`可以下载大型文件，并提供一个进度条。并且中断之后可以重新开始。（话说我记得Rstudio是有可以后台运行的，但是不知道VS code怎么搞）

> 这个数据集包含 41,389,465 行数据，告诉你从 2005 年 4 月到 2022 年 10 月，每本书每个月被借阅了多少次。

# 打开数据

一般看到csv的文件直接`read_csv()`了。（但是我知道可以用data.table的`fread`，这本书似乎不教这个包我猜。那就只有以后再接触了）

那就得用arrow的方式打开文件了。`open_dataset()`

```R
seattle_csv <- open_dataset(
  sources = "data/seattle-library-checkouts.csv", 
  col_types = schema(ISBN = string()),
  format = "csv"
)
```

source指定文件路径，col_types之所以特别定义ISBN，是因为前几千行都是空白的，但是arrow会读取前几千行来猜测数据结构，不说可能不太好。最后就是format指定文件格式。这个函数不会真的读取所有数据，只是看看大致的结构，除非真的要求才会读取更多的行。

但是需要注意的是还得加`schema`函数，这个好像就和读取csv一个`c`就够了。看来这样的大数据需要提取出其中的列作为一个对象吗。（schema函数也能创建一个）

打开之后就可以你看看元数据，第一行就说明在硬盘上，不在内存里；剩下的都是列与对应的类型。

```R
seattle_csv
#> FileSystemDataset with 1 csv file
#> UsageClass: string
#> CheckoutType: string
#> MaterialType: string
#> CheckoutYear: int64
#> CheckoutMonth: int64
#> Checkouts: int64
#> Title: string
#> ISBN: string
#> Creator: string
#> Subjects: string
#> Publisher: string
#> PublicationYear: string
```

也可以用`glimpse()`函数大致看看数据的一些部分的汇总内容。这和一般的CSV没什么差别。

```R
seattle_csv |> glimpse()
#> FileSystemDataset with 1 csv file
#> 41,389,465 rows x 12 columns
#> $ UsageClass      <string> "Physical", "Physical", "Digital", "Physical", "Ph…
#> $ CheckoutType    <string> "Horizon", "Horizon", "OverDrive", "Horizon", "Hor…
#> $ MaterialType    <string> "BOOK", "BOOK", "EBOOK", "BOOK", "SOUNDDISC", "BOO…
#> $ CheckoutYear     <int64> 2016, 2016, 2016, 2016, 2016, 2016, 2016, 2016, 20…
#> $ CheckoutMonth    <int64> 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,…
#> $ Checkouts        <int64> 1, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 2, 3, 2, 1, 3, 2,…
#> $ Title           <string> "Super rich : a guide to having it all / Russell S…
#> $ ISBN            <string> "", "", "", "", "", "", "", "", "", "", "", "", ""…
#> $ Creator         <string> "Simmons, Russell", "Barclay, James, 1965-", "Tim …
#> $ Subjects        <string> "Self realization, Conduct of life, Attitude Psych…
#> $ Publisher       <string> "Gotham Books,", "Pyr,", "Random House, Inc.", "Di…
#> $ PublicationYear <string> "c2011.", "2010.", "2015", "2005.", "c2004.", "c20…
```

并且已经可以开始用dplyr操作数据了。再复习一下`collect`可以将结果输出变为tibble格式强制计算和返回了。

```R
seattle_csv |> 
  group_by(CheckoutYear) |> 
  summarise(Checkouts = sum(Checkouts)) |> 
  arrange(CheckoutYear) |> 
  collect()
#> # A tibble: 18 × 2
#>   CheckoutYear Checkouts
#>          <int>     <int>
#> 1         2005   3798685
#> 2         2006   6599318
#> 3         2007   7126627
#> 4         2008   8438486
#> 5         2009   9135167
#> 6         2010   8608966
#> # ℹ 12 more rows
```

我试了，不管是打开还是读取还是操作，确实都还挺慢的。但是这个据说还能更快，那就是parquet格式。

# Parquet格式

## parquet格式的优势

parquet不是木地板的意思嘛，感觉似乎是指向了数据格式的示意图。虽然和CSV一样可以（用文本编辑器）直接打开，但是确实一种为大数据的自定义二进制格式。那么就有一些优点了。

1. **文件大小和压缩**：Parquet文件通常比同等的CSV文件小。这是因为Parquet文件依赖于高效的编码方式来减小文件大小，并且支持文件压缩。这种压缩使得Parquet文件在处理时速度更快，因为从磁盘到内存传输的数据量减少了。
2. **丰富的类型系统**：Parquet文件具有丰富的类型系统。与CSV文件不同，CSV文件不提供任何关于列类型的信息，例如，CSV文件的读取器必须猜测"08-10-2022"应该被解析为字符串还是日期。相比之下，Parquet文件以一种记录数据类型与数据本身的方式存储数据。
3. **列式存储**：Parquet文件是“列式”的，这意味着它们是按列组织的，类似于R语言中的数据框。这通常会导致在数据分析任务中比按行组织的CSV文件有更好的性能。
4. **分块**：Parquet文件是“分块”的，这使得可以同时处理文件的不同部分，并且如果幸运的话，可以完全跳过某些块。这种分块机制提高了数据处理的灵活性和效率。

唯一的缺点就是人不能读啊

> human readable 人可读
>
> `readr::read_file()` 查看 Parquet 文件，你只会看到一堆乱码。

## 分割

这个部分也没有实操。之所以要分割大数据，是因为都存在一个文件当中比较麻烦，大数据分割到多个文件当中可以使得性能提升，因为很多分析只需要一部分文件。arrow建议把文集爱你分割为20MB到2GB的文件，然后文件也不能多余10000个。但是怎么分割这个小节还没有说。

## 改写西雅图图书馆数据

既然parquet格式这么好，分割数据也不错，那么就把西雅图数据分割成parquet格式好了。

```R
pq_path <- "data/seattle-library-checkouts"
seattle_csv |>
  group_by(CheckoutYear) |>
  write_dataset(path = pq_path, format = "parquet")
```

这个改写的过程也是花了一些些的时间，但是作者说这个时间的重写是很值得，这会为咱们后面提高效率。其实用法和write_csv差不多，但是这里输入的竟然是带有分组信息的tibble数据。然后这个路径原本是不存在的，既然没有，也可以新建一个。看看在这个新的文件夹里面都保存了什么。我看了竟然是新的文件夹里包括了18个新小的文件夹，每个文件夹里面有一个parquet文件。（估计要是一个parquet描述不了一年的话，可能这个小文件夹里还会有更多的parquet，就不只是part-0了。

```R
tibble(
  files = list.files(pq_path, recursive = TRUE),
  size_MB = file.size(file.path(pq_path, files)) / 1024^2
)
#> # A tibble: 18 × 2
#>   files                            size_MB
#>   <chr>                              <dbl>
#> 1 CheckoutYear=2005/part-0.parquet    109.
#> 2 CheckoutYear=2006/part-0.parquet    164.
#> 3 CheckoutYear=2007/part-0.parquet    178.
#> 4 CheckoutYear=2008/part-0.parquet    195.
#> 5 CheckoutYear=2009/part-0.parquet    214.
#> 6 CheckoutYear=2010/part-0.parquet    222.
#> # ℹ 12 more rows
```

原来是按照年份分割，每个年份的数据也就是一百到三百的MB大小。

> 这里就得看看一些文件的操作了，比如读取一个路径下所有文件名`list.files`，那么recursive这个参数应该就是对其中的文件夹是否进行递归了。
>
> `file.size()`看来是看文件大小的，只不过似乎还是B为单位吧，所以要除以两次才能得到MB量纲的数值。
>
> `file.path()`有什么用吗？有点像paste向量和单个使用，只不过有斜杠，循环生成的是路径。我之前似乎用的都是paste哦。

至于文件命名的规则，则是由Apache Hive的协议。并且最终总共的大小也就是4GB，简直少了一半，果然parquet是更高效的格式（难道把空缺的给稀疏化了嘛，不太了解）。果然原来提高效率这里就是一个意思了。

# 在arrow下用dplyr

现在再来打开这个大数据，不过这次是打开一整个文件夹，里面有许多拆开来的parquet文件。

```R
seattle_pq <- open_dataset(pq_path)
```

居然不花时间就打开了。看来是没有加载到内存当中，只是映射了一个磁盘地址。而且这次这个函数给了一个文件夹即可，也没有指定文件格式（估计默认就是parquet），然后也没有指定类型（估计parquet本身就带有类型的说明）。

来写一段dplyr的指令

```R
query <- seattle_pq %>%
  filter(CheckoutYear >= 2018, MaterialType == "BOOK") %>%
  group_by(CheckoutYear, CheckoutMonth) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(CheckoutYear, CheckoutMonth)
query
#> FileSystemDataset (query)
#> CheckoutYear: int32
#> CheckoutMonth: int64
#> TotalCheckouts: int64
#> 
#> * Grouped by CheckoutYear
#> * Sorted by CheckoutYear [asc], CheckoutMonth [asc]
#> See $.data for the source Arrow object
```

原理也是一样的，据说会把写出来的dplyr函数翻译为Apache Arrow C++库的查询语句。虽然dbplyr也会展示数据，`showquery()`才展示查询步骤。但是感觉这个arrow更懒，直接也只展示元信息。除非也是用`collect()`强制执行生成tibble数据。

```R
query |> collect()
#> # A tibble: 58 × 3
#> # Groups:   CheckoutYear [5]
#>   CheckoutYear CheckoutMonth TotalCheckouts
#>          <int>         <int>          <int>
#> 1         2018             1         355101
#> 2         2018             2         309813
#> 3         2018             3         344487
#> 4         2018             4         330988
#> 5         2018             5         318049
#> 6         2018             6         341825
#> # ℹ 52 more rows
```

但是毕竟有个翻译的过程，所以arrow也只能用一部分的dplyr函数。

```R
?acero
```

查询arrow支持的dplyr函数。（这个库正在完善当中，虽然本身就已经很广泛了。肯定是满足日常使用了。）

## 性能比较

这个小节来比较csv和parquet的性能，也就是处理文件的速度。那么这里就要用到一个`system.time`函数，这可不是`Sys.time`函数，查看当前时间，而是计算运行表达式所需要的时间吧。不过都是base的就是了。

> 当然，我也可以前面写一个，后面写一个时间，然后减一减就是所花费的时间了。

```R
seattle_csv %>%
  filter(CheckoutYear == 2021, MaterialType == "BOOK") %>%
  group_by(CheckoutMonth) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(desc(CheckoutMonth)) %>%
  collect() %>%
  system.time()

   user  system elapsed 
   6.03    1.44   14.08
```

我的电脑是这个速度。看看parquet的速度吧。

```R
seattle_pq %>%
      filter(CheckoutYear == 2021, MaterialType == "BOOK") %>%
      group_by(CheckoutMonth) %>%
      summarise(TotalCheckouts = sum(Checkouts)) %>%
      arrange(desc(CheckoutMonth)) %>%
      collect() %>%
      system.time()
   user  system elapsed
   0.08    0.03    0.15
```

我的电脑是这个速度，果真是100倍的差距。不过看上去我的电脑的确比Hadley的要满，估计人家是台式机哈哈哈。我这个新电脑计算速度果真还是不行。下面还分析了提速的原因。

- 分区：因为查询2021的，那么只要2021那个片区就好了。
- 格式：二进制直接读入内存提高性能。而且本身就是列式存储，这里也的确只使用到了实际参与的四个列。

> 那还挺牛的嘛。这就是为什么咱们需要把csv转换为parquet文件。
>
> 统一一下，就是用到什么拿什么。这不就是硕博学习的方法嘛。
>
> 话说那些基因数据也都是这么大的，怎么没见人家进行arrow转换。（可能是我还没有完整跟过那些大型图谱的分析，看来道阻且长啊）

## 在arrow下使用duckdb

说是这么说，其实这两小节用的都是dplyr的语法。还记得吗，duckdb是一个进程内数据库，然后得先连接，然后再放进去数据，再拿出一个建立tbl，再开始使用dbplyr的函数。

但是arrow的最后一个要讲的优势就是一个函数`to_duckdb()`转换为数据库管理系统的形式。

```R
seattle_pq |> 
  to_duckdb() |>
  filter(CheckoutYear >= 2018, MaterialType == "BOOK") |>
  group_by(CheckoutYear) |>
  summarize(TotalCheckouts = sum(Checkouts)) |>
  arrange(desc(CheckoutYear)) |>
  collect()
#> Warning: Missing values are always removed in SQL aggregation functions.
#> Use `na.rm = TRUE` to silence this warning
#> This warning is displayed once every 8 hours.
#> # A tibble: 5 × 2
#>   CheckoutYear TotalCheckouts
#>          <int>          <dbl>
#> 1         2022        2431502
#> 2         2021        2266438
#> 3         2020        1241999
#> 4         2019        3931688
#> 5         2018        3987569
```

> 我试过了，这个其实是转换为tbl的格式。（话说tbl只属于duckdb还是别的DBMS都可以？）
>
> 而且我也试过了，这个速度也就是0.73秒，反正比csv快多了。虽然没有arrow快。果真是专人干专事啊。

而且这样做的好处就是，也不需要多保存为一个数据库，可以直接转换环境
$$
\text{大数据}\rightarrow\text{数据库}\\
\text{arrow}\rightarrow\text{dbplyr}
$$

## 练习

> Figure out the most popular book each year.

不过这些东西都没有一个准确的答案的。

```R
seattle_pq %>%
  filter(MaterialType == "BOOK") %>%
  filter(!str_detect(Title, "^<|^Unc")) %>%
  group_by(CheckoutYear, Title) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(CheckoutYear, desc(TotalCheckouts)) %>%
  collect() %>%
  slice_head(n = 1)
```

你比如说，很多书都是没有名字，或者丢了封面的。所以不得不舍去，显然这些丢了封面的书不是同一本书。然后这些后端函数都是没有slice这个操作的，那就只能collect之后再slice。

> Which author has the most books in the Seattle library system?

```R
seattle_pq %>%
  filter(MaterialType == "BOOK") %>%
  filter(!str_detect(Title, "^<|^Unc")) %>%
  filter(Creator != "") %>%
  distinct(Title, Creator) %>%
  count(Creator, sort = TRUE) %>%
  head(10) %>%
  collect()
```

是1947年出生的詹姆斯·帕特森，美国惊悚推理小说之王，新作一经问世，就能登顶纽约时报畅销书排行榜首，被誉为“从不失手的男人”。可以呀。

> How has checkouts of books vs ebooks changed over the last 10 years?

```r
type_var <- seattle_pq %>%
  filter(MaterialType %in% c("BOOK", "EBOOK")) %>%
  group_by(CheckoutYear, MaterialType) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(CheckoutYear, MaterialType) %>%
  collect()
type_var %>%
  ggplot(aes(x = CheckoutYear, y = TotalCheckouts, color = MaterialType)) +
  geom_line() +
  scale_x_continuous(breaks = seq(2005, 2022, 1))
```

![纸质书和电子书10年借阅变化](<./0522 arrow处理大数据.assets/纸质书和电子书10年借阅变化.png>)

是这样吗，感觉还是蛮奇怪的，2019年因为口罩，纸质书借阅减少，但是20年之后电子书也开始减少，纸质书20年之后反而回温，这怎么说呢，只能说是正常。只能说是疫情加多了电子书，疫情之后恢复一部分回来。但是总体趋势还是一样的，电子书在不断上升。只是疫情期间上升过头了。

# 总结

这一章其实也没教多少内容，只是转换一下。我觉得蛮好，像这几章的内容确实可以做到一填两

数据库也学了，大数据也学了。接下来就是非矩形数据了。tidyr包是干这个的。JSON文件我们也是很熟悉了，在高中就接触过，appinventor和arduino有的时候就是用这个接收API数据的。至于这个怎么好那就下一章再说吧。