# 前言

[“Data Organization in Spreadsheets” by Karl Broman and Kara Woo](https://doi.org/10.1080/00031305.2017.1375989)

一篇实践性的论文，介绍R操作电子表格的方法。

sheet其实是excel中的工作表，spreadsheet中文翻译是电子表格。这一章节介绍的是R导入excel和google格式的表格文件。（之前都是纯粹的csv）

# Excel

## 准备

```R
library(readxl)
library(tidyverse)
library(writexl)
```

tidyverse包本身是没有包括readxl和writexl的函数的，但是一起下载了过来，提前加载好就完事了。

主要的函数就是

1. `read_xls()`：这个函数用于读取格式为.xls的Excel文件。
2. `read_xlsx()`：这个函数用于读取格式为.xlsx的Excel文件。
3. `read_excel()`：这个函数可以读取两种格式的Excel文件，即.xls和.xlsx。它能够根据输入的文件自动判断文件的格式。

语法就和前面的`read_csv()`差不多。

## 读取excel表格

先下载下来（肯定需要翻墙）

https://docs.google.com/spreadsheets/d/1V1nPp1tzOuutXFLb3G9Eyxi3qxeEhnOXUzL5_BcCQ0w/

最简单的使用方式就是直接读取

```r
students <- read_excel("data/students.xlsx")
students
#> # A tibble: 6 × 5
#>   `Student ID` `Full Name`      favourite.food     mealPlan            AGE  
#>          <dbl> <chr>            <chr>              <chr>               <chr>
#> 1            1 Sunil Huffmann   Strawberry yoghurt Lunch only          4    
#> 2            2 Barclay Lynn     French fries       Lunch only          5    
#> 3            3 Jayendra Lyne    N/A                Breakfast and lunch 7    
#> 4            4 Leon Rossini     Anchovies          Lunch only          <NA> 
#> 5            5 Chidiegwu Dunkel Pizza              Breakfast and lunch five 
#> 6            6 Güvenç Attila    Ice cream          Lunch only          6
```

但是可以看到列名当中含有空格，不是很tidy。可以通过设置列名向量的方式。（建议符合驼峰原则）

```R
read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age")
)
#> # A tibble: 7 × 5
#>   student_id full_name        favourite_food     meal_plan           age  
#>   <chr>      <chr>            <chr>              <chr>               <chr>
#> 1 Student ID Full Name        favourite.food     mealPlan            AGE  
#> 2 1          Sunil Huffmann   Strawberry yoghurt Lunch only          4    
#> 3 2          Barclay Lynn     French fries       Lunch only          5    
#> 4 3          Jayendra Lyne    N/A                Breakfast and lunch 7    
#> 5 4          Leon Rossini     Anchovies          Lunch only          <NA> 
#> 6 5          Chidiegwu Dunkel Pizza              Breakfast and lunch five 
#> 7 6          Güvenç Attila    Ice cream          Lunch only          6
```

但是这样第一行默认就不是列名了，而是一行记录。（并且列的类型也都变成字符了）这就不得不跳过第一行了。

```R
read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1
)
#> # A tibble: 6 × 5
#>   student_id full_name        favourite_food     meal_plan           age  
#>        <dbl> <chr>            <chr>              <chr>               <chr>
#> 1          1 Sunil Huffmann   Strawberry yoghurt Lunch only          4    
#> 2          2 Barclay Lynn     French fries       Lunch only          5    
#> 3          3 Jayendra Lyne    N/A                Breakfast and lunch 7    
#> 4          4 Leon Rossini     Anchovies          Lunch only          <NA> 
#> 5          5 Chidiegwu Dunkel Pizza              Breakfast and lunch five 
#> 6          6 Güvenç Attila    Ice cream          Lunch only          6
```

又恢复正常了。

> ```R
> janitor::clean_names(students)
> ```
>
> 复习一下，这个也可以实现相同的效果。

但是又看到了有些缺失值没有全部被识别出来，因为默认空字符串是NA，就需要设置一下。

```R
read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A")
)
#> # A tibble: 6 × 5
#>   student_id full_name        favourite_food     meal_plan           age  
#>        <dbl> <chr>            <chr>              <chr>               <chr>
#> 1          1 Sunil Huffmann   Strawberry yoghurt Lunch only          4    
#> 2          2 Barclay Lynn     French fries       Lunch only          5    
#> 3          3 Jayendra Lyne    <NA>               Breakfast and lunch 7    
#> 4          4 Leon Rossini     Anchovies          Lunch only          <NA> 
#> 5          5 Chidiegwu Dunkel Pizza              Breakfast and lunch five 
#> 6          6 Güvenç Attila    Ice cream          Lunch only          6
```

虽然到现在还是一个函数，但是和数据清理关系很大。可以看到age被识别为字符，那是因为age里面有一个是five这个单词。

```R
read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = c("numeric", "text", "text", "text", "numeric")
)
# A tibble: 6 x 5
  student_id full_name        favourite_food     meal_plan             age
       <dbl> <chr>            <chr>              <chr>               <dbl>
1          1 Sunil Huffmann   Strawberry yoghurt Lunch only              4
2          2 Barclay Lynn     French fries       Lunch only              5
3          3 Jayendra Lyne    NA                 Breakfast and lunch     7
4          4 Leon Rossini     Anchovies          Lunch only             NA
5          5 Chidiegwu Dunkel Pizza              Breakfast and lunch    NA
6          6 G¨¹ven<U+00E7> Attila    Ice cream          Lunch only              6
Warning message:
Expecting numeric in E6 / R6C5: got 'five' 
```


> `"skip"`, `"guess"`, `"logical"`, `"numeric"`, `"date"`, `"text"` or `"list"`可以作为参数的值填进去。

报警了，把five用NA替代了。但是这样就丢失了5这个数据了。那么tidyverse提供的思路就是先读取为字符，然后条件向量转为字符5，再用`parse_number()`获取数字。（感觉有点复杂，base好像反而还简单一点。）。需要注意的就是，一定得是字符5，不然就会报错。

```R
students <- read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = c("numeric", "text", "text", "text", "text")
)

students <- students |>
  mutate(
    age = if_else(age == "five", "5", age),
    age = parse_number(age)
  )

students
#> # A tibble: 6 × 5
#>   student_id full_name        favourite_food     meal_plan             age
#>        <dbl> <chr>            <chr>              <chr>               <dbl>
#> 1          1 Sunil Huffmann   Strawberry yoghurt Lunch only              4
#> 2          2 Barclay Lynn     French fries       Lunch only              5
#> 3          3 Jayendra Lyne    <NA>               Breakfast and lunch     7
#> 4          4 Leon Rossini     Anchovies          Lunch only             NA
#> 5          5 Chidiegwu Dunkel Pizza              Breakfast and lunch     5
#> 6          6 Güvenç Attila    Ice cream          Lunch only              6
```

baseR里面应该是这么写的

```R
students[students == "five"] <- "5"
students$age <- as.numeric(students$age)
students
```

excel可以作为数据分析的软件，但是作为一个更偏向于商业性质的应用，很多时候格式是非常不tidy的，所以上面的实践有的时候还是很模拟现实情况的。

另外本书作者还建议打开看看是可以的，但是对于R操作电子表格的时候，最好还是先建立一个副本，防止对原始数据产生不必要的无法回复的修改。

## 读取工作表

电子表格和csv这种普通表格的一个区别就是可以由很多个工作表组成（是立体的）

再来下载一下https://docs.google.com/spreadsheets/d/1aFu8lnD_g0yjF5O-K6SFgSEWiHPpgvFCF0NY9D6LXnY/

![A look at the deaths spreadsheet in Excel. The spreadsheet has four rows on top that contain non-data information; the text 'For the same of consistency in the data layout, which is really a beautiful thing, I will keep making notes up here.' is spread across cells in these top four rows. Then, there is a data frame that includes information on deaths of 10 famous people, including their names, professions, ages, whether they have kids or not, date of birth and death. At the bottom, there are four more rows of non-data information; the text 'This has been really fun, but we're signing off now!' is spread across cells in these bottom four rows.](./0520 电子表格spreadsheet.assets/import-spreadsheets-deaths.png)

这个好像就是之前的ggplot初识的企鹅数据哦，只不过把三个岛屿分到了三个工作表当中。

如果不设置的话，默认都是第一张工作表。写不写，写工作表名，写编号都是一样的。

```R
read_excel("data/penguins.xlsx", sheet = "Torgersen Island")
#> # A tibble: 52 × 8
#>   species island    bill_length_mm     bill_depth_mm      flipper_length_mm
#>   <chr>   <chr>     <chr>              <chr>              <chr>            
#> 1 Adelie  Torgersen 39.1               18.7               181              
#> 2 Adelie  Torgersen 39.5               17.399999999999999 186              
#> 3 Adelie  Torgersen 40.299999999999997 18                 195              
#> 4 Adelie  Torgersen NA                 NA                 NA               
#> 5 Adelie  Torgersen 36.700000000000003 19.3               193              
#> 6 Adelie  Torgersen 39.299999999999997 20.6               190              
#> # ℹ 46 more rows
#> # ℹ 3 more variables: body_mass_g <chr>, sex <chr>, year <dbl>
```

我这里好像看不出来，据说NA不会被识别为NA，可以是字符串“NA”。

```R
penguins_torgersen <- read_excel("data/penguins.xlsx", sheet = "Torgersen Island", na = "NA")

penguins_torgersen
#> # A tibble: 52 × 8
#>   species island    bill_length_mm bill_depth_mm flipper_length_mm
#>   <chr>   <chr>              <dbl>         <dbl>             <dbl>
#> 1 Adelie  Torgersen           39.1          18.7               181
#> 2 Adelie  Torgersen           39.5          17.4               186
#> 3 Adelie  Torgersen           40.3          18                 195
#> 4 Adelie  Torgersen           NA            NA                  NA
#> 5 Adelie  Torgersen           36.7          19.3               193
#> 6 Adelie  Torgersen           39.3          20.6               190
#> # ℹ 46 more rows
#> # ℹ 3 more variables: body_mass_g <dbl>, sex <chr>, year <dbl>
```

这样NA在radian里面就变红了，列类型也变成双精度了。

那我要是想知道别的工作表呢，难道还要一个个打开excel吗，那就不方便了。用这个函数。`excel_sheet()`

```R
excel_sheets("data/penguins.xlsx")
#> [1] "Torgersen Island" "Biscoe Island"    "Dream Island"
penguins_biscoe <- read_excel("data/penguins.xlsx", sheet = "Biscoe Island", na = "NA")
penguins_dream  <- read_excel("data/penguins.xlsx", sheet = "Dream Island", na = "NA")
```

```R
dim(penguins_torgersen)
#> [1] 52  8
dim(penguins_biscoe)
#> [1] 168   8
dim(penguins_dream)
#> [1] 124   8
```

这似乎还是这本书第一次出现这个函数`dim()`，也是非常常用的看矩阵维度的。可以看到，这三个工作表列的数量是一样的，只是记录数不一样。（我们都知道这些数据是哪里来的）那恢复成原本第一个表格，也就是行合并的操作。在dplyr里面是`bind_rows()`函数。

```R
penguins <- bind_rows(penguins_torgersen, penguins_biscoe, penguins_dream)
penguins
#> # A tibble: 344 × 8
#>   species island    bill_length_mm bill_depth_mm flipper_length_mm
#>   <chr>   <chr>              <dbl>         <dbl>             <dbl>
#> 1 Adelie  Torgersen           39.1          18.7               181
#> 2 Adelie  Torgersen           39.5          17.4               186
#> 3 Adelie  Torgersen           40.3          18                 195
#> 4 Adelie  Torgersen           NA            NA                  NA
#> 5 Adelie  Torgersen           36.7          19.3               193
#> 6 Adelie  Torgersen           39.3          20.6               190
#> # ℹ 338 more rows
#> # ℹ 3 more variables: body_mass_g <dbl>, sex <chr>, year <dbl>
```

话说`rbind()`函数似乎只能两两合并，怪不得这里要用`bind_rows()`函数。

## 读取表的一部分

因为很多电子表格为了方便自己处理，很多操作都在一张表上，实际有意义的表格，可能还是在表的一部分。

![A look at the deaths spreadsheet in Excel. The spreadsheet has four rows on top that contain non-data information; the text 'For the same of consistency in the data layout, which is really a beautiful thing, I will keep making notes up here.' is spread across cells in these top four rows. Then, there is a data frame that includes information on deaths of 10 famous people, including their names, professions, ages, whether they have kids or not, date of birth and death. At the bottom, there are four more rows of non-data information; the text 'This has been really fun, but we're signing off now!' is spread across cells in these bottom four rows.](./0520 电子表格spreadsheet.assets/import-spreadsheets-deaths-1726123994398-3.png)这里用的就是一个内置的实例数据了。

```R
deaths_path <- readxl_example("deaths.xlsx")
deaths <- read_excel(deaths_path)
#> New names:
#> • `` -> `...2`
#> • `` -> `...3`
#> • `` -> `...4`
#> • `` -> `...5`
#> • `` -> `...6`
deaths
#> # A tibble: 18 × 6
#>   `Lots of people`    ...2       ...3  ...4     ...5          ...6           
#>   <chr>               <chr>      <chr> <chr>    <chr>         <chr>          
#> 1 simply cannot resi… <NA>       <NA>  <NA>     <NA>          some notes     
#> 2 at                  the        top   <NA>     of            their spreadsh…
#> 3 or                  merging    <NA>  <NA>     <NA>          cells          
#> 4 Name                Profession Age   Has kids Date of birth Date of death  
#> 5 David Bowie         musician   69    TRUE     17175         42379          
#> 6 Carrie Fisher       actor      60    TRUE     20749         42731          
#> # ℹ 12 more rows
```

可以看到多了很多的NA，因为前面4行和后面4行是故意的，没有数据的。

可以用`skip`和`n_max`这样的参数进行提出。但是也可以像Excel一样，通过单元格的坐标进行框选。那么用的就是`range`参数（后面跟的是字符串）。

```R
read_excel(deaths_path, range = "A5:F15")
#> # A tibble: 10 × 6
#>   Name          Profession   Age `Has kids` `Date of birth`    
#>   <chr>         <chr>      <dbl> <lgl>      <dttm>             
#> 1 David Bowie   musician      69 TRUE       1947-01-08 00:00:00
#> 2 Carrie Fisher actor         60 TRUE       1956-10-21 00:00:00
#> 3 Chuck Berry   musician      90 TRUE       1926-10-18 00:00:00
#> 4 Bill Paxton   actor         61 TRUE       1955-05-17 00:00:00
#> 5 Prince        musician      57 TRUE       1958-06-07 00:00:00
#> 6 Alan Rickman  actor         69 FALSE      1946-02-21 00:00:00
#> # ℹ 4 more rows
#> # ℹ 1 more variable: `Date of death` <dttm>
```

## 数据类型

对于普通csv表格来说，其实也就是txt，但是xlsx就不是了，有一个东西就是设置单元格格式。所以每个单元格都有自己的数据类型。那么在这里的导入函数都是默认会猜的。

但是有的时候一列里面的单元格有多种形式，可以试试list类型。

> [tidyxl包](https://nacnudus.github.io/tidyxl/)支持更多表格的操作。比如单元格颜色，字体的加粗等信息。

## 保存为excel的格式

```R
bake_sale <- tibble(
  item = factor(c("brownie", "cupcake", "cookie")),
  quantity = c(10, 5, 8)
)
bake_sale
write_xlsx(bake_sale, "./bake-sale.xlsx")
```

基本写法差不多，不过为了凸显excel的文本格式，默认列名是加粗且居中的。

![Bake sale data frame created earlier in Excel.](./0520 电子表格spreadsheet.assets/import-spreadsheets-bake-sale-1726125203696-8.png)

```R
read_xlsx("./bake-sale.xlsx")
#> # A tibble: 3 × 2
#>   item    quantity
#>   <chr>      <dbl>
#> 1 brownie       10
#> 2 cupcake        5
#> 3 cookie         8
```

反过来还能读取。

## 格式化输出

writexl只是一个初级的格式化输出的包，要进阶版的就得用openxlsx包了

https://ycphs.github.io/openxlsx/

> 但是我觉得医学类的可能对excel这样的格式化表格输出没有特别的要求，但是对于一些三线表，森林图还是有需求的，这也算是一种格式化的输出。

但是这个包不属于tidy的流派，所以很多不通用。就得从头学习了。

## 练习

> ![A spreadsheet with 3 columns (group, subgroup, and id) and 12 rows. The group column has two values: 1 (spanning 7 merged rows) and 2 (spanning 5 merged rows). The subgroup column has four values: A (spanning 3 merged rows), B (spanning 4 merged rows), A (spanning 2 merged rows), and B (spanning 3 merged rows). The id column has twelve values, numbers 1 through 12.](./0520 电子表格spreadsheet.assets/import-spreadsheets-survey.png)
>
> 读取成这样
>
> ```R
> #> # A tibble: 6 × 2
> #>   survey_id n_pets
> #>   <chr>      <dbl>
> #> 1 1              0
> #> 2 2              1
> #> 3 3             NA
> #> 4 4              2
> #> 5 5              2
> #> 6 6             NA
> ```

一样的操作

```R
survey <- read_excel("./survey.xlsx", na = c("", "N/A"))
survey <- survey %>%
  mutate(
    n_pets = if_else(n_pets == "two", "2", n_pets),
    n_pets = parse_number(n_pets)
  )
survey
```

> 
>
> ![A spreadsheet with 3 columns (group, subgroup, and id) and 12 rows. The group column has two values: 1 (spanning 7 merged rows) and 2 (spanning 5 merged rows). The subgroup column has four values: A (spanning 3 merged rows), B (spanning 4 merged rows), A (spanning 2 merged rows), and B (spanning 3 merged rows). The id column has twelve values, numbers 1 through 12.](./0520 电子表格spreadsheet.assets/import-spreadsheets-roster.png)
>
> 读取成这样
>
> ```R
> #> # A tibble: 12 × 3
> #>    group subgroup    id
> #>    <dbl> <chr>    <dbl>
> #>  1     1 A            1
> #>  2     1 A            2
> #>  3     1 A            3
> #>  4     1 B            4
> #>  5     1 B            5
> #>  6     1 B            6
> #>  7     1 B            7
> #>  8     2 A            8
> #>  9     2 A            9
> #> 10     2 B           10
> #> 11     2 B           11
> #> 12     2 B           12
> ```

这个不就是之前缺失值的处理嘛，用的是LOCF原则。

```R
roster <- read_excel("./roster.xlsx")
roster %>%
  fill(everything())
```



> ![A spreadsheet with 2 columns and 13 rows. The first two rows have text containing information about the sheet. Row 1 says "This file contains information on sales". Row 2 says "Data are organized by brand name, and for each brand, we have the ID number for the item sold, and how many are sold.". Then there are two empty rows, and then 9 rows of data.](./0520 电子表格spreadsheet.assets/import-spreadsheets-sales.png)
>
> 读取成这样
>
> ```R
> #> # A tibble: 9 × 2
> #>   id      n    
> #>   <chr>   <chr>
> #> 1 Brand 1 n    
> #> 2 1234    8    
> #> 3 8721    2    
> #> 4 1822    3    
> #> 5 Brand 2 n    
> #> 6 3333    1    
> #> 7 2156    3    
> #> 8 3987    6    
> #> 9 3216    5
> ```

跳过前两行并设置列名就完事了

```R
sales <- read_excel("./sales.xlsx", skip = 2, col_names = c("id", "n"))
sales
```

> 调整成这样
>
> ```R
> #> # A tibble: 7 × 3
> #>   brand      id     n
> #>   <chr>   <dbl> <dbl>
> #> 1 Brand 1  1234     8
> #> 2 Brand 1  8721     2
> #> 3 Brand 1  1822     3
> #> 4 Brand 2  3333     1
> #> 5 Brand 2  2156     3
> #> 6 Brand 2  3987     6
> #> 7 Brand 2  3216     5
> ```

```R
sales <- read_excel("./sales.xlsx", skip = 2, col_names = c("id", "n"))
sales
sales %>%
  mutate(brand = if_else(n == "n", id, NA)) %>%
  fill(brand) %>%
  filter(!n == "n") %>%
  relocate(brand) %>%
  mutate(
    id = parse_number(id),
    n = parse_number(n)
  )
```

写的有点长，但是我目前只能想到这个了，不然base肯定要for循环了。

> Recreate the `bake_sale` data frame, write it out to an Excel file using the `write.xlsx()` function from the openxlsx package.

```R
library(openxlsx)
write.xlsx(bake_sale, "bake-sale2.xlsx")
bake_sale
```

> In [Chapter 7](https://r4ds.hadley.nz/data-import) you learned about the `janitor::clean_names()` function to turn column names into snake case. Read the `students.xlsx` file that we introduced earlier in this section and use this function to “clean” the column names.

这个我做过了。

> What happens if you try to read in a file with `.xlsx` extension with `read_xls()`?

会报错，会乱码

```R
read_xls("./roster.xlsx")
Error:
  filepath: D:\Data\ÖªÊ¶¿â\RÓïÑÔ»ù´¡\R4DSÑ§Ï°±Ê¼Ç\0520 µç×Ó±í¸ñspreadsheet.assets\roster.xlsx
  libxls error: Unable to open file
```

# 谷歌表格

这个咱们就不玩了，国内真的是玩不了，基本没人用谷歌表格，因为需要翻墙的环境。

# 总结

所以这一章到这里就结束了。说到底其实也就是只有一个读取的函数最重要。下一章是数据库，虽然也是没什么人用，但是我觉得还是要比谷歌表格要重要得多。