# 简介

其实之前展示方式是html，然后存Rstudio内部展示，那么想要其他的输出格式，应该怎么做呢？

永久的方法，那就是在YAML头部写一个format的选项

```yaml
---
title: "Diamond sizes"
format: html
---
```

如果是临时的，那就写这个函数好了`quarto::quarto_render()`，并且支持一下输出多个类型的。

```R
quarto::quarto_render("diamond-sizes.qmd", output_format = "docx")
quarto::quarto_render("diamond-sizes.qmd", output_format = c("docx", "pdf"))
```

就用这个试试多种输出格式吧

> 但是默认是没有quarto这个包的
>
> ```r
> install.packages("quarto")
> ```

但是我的电脑是没有texlive的环境的，所以是不能自主生成pdf的。（这让我不禁好奇，typora是如何生成pdf的）

# 输出选项

https://quarto.org/docs/output-formats/all-formats.html

更多的输出格式，可以参考这个网页，许多格式都有各自的选项。

```yaml
format:
  html:
    toc: true
    toc_float: true
```

这个表示生成一个目录，且目录是浮动的。

（看到了没有，之前只有html的时候和format写一行，但是html后面也跟着的话就灵气一行了。

但是说实话我没有看出来float这一行加进去的差别，并且在官方文档当中也没有看到还有这个选项。估计是没有且默认了吧。

并且在YAML头部还可以设置多个输出。

```R
format:
  html:
    toc: true
    toc_float: true
  pdf: default
  docx: default
```

再加上render的函数，参数设置为all，就可以一次性全部输出了。

```R
quarto::quarto_render("diamond-sizes.qmd", output_format = "all")
```

> 不过似乎默认就是all的。不加后面这个也可以了。

# 文档

除了html之外，还有这些文档

- pdf，但是需要tex环境
- docx，word对吧
- odt，开放文档格式，据说是一种基于XML的文件格式（word也可以打开吗）
- rtf，富文本格式，以前附件中的写字板就能打开，据说是一个稍微偏大，兼容性比较好的文件格式。
- gfm是github风格的md文件，这种格式的文档在GitHub上特别流行，因为它支持一些额外的Markdown语法。
- ipynb，不多说了是jupyter notebook的格式

在生成一些用于word格式，建议是设置全局隐藏代码。

```YAML
execute:
  echo: false
```

html文档，也可以设置code选项，默认隐藏，点击可见。这也是一个不错的隐藏代码，整洁显示的方案。

```R
format:
  html:
    code-fold: true
```

> hadley估计是写错了，或者更新了，反正现在不叫code，是叫code-fold。

# 演示

常见的演示工具就是Keynote和PPT了吧，Quarto竟然也能生成。就不需要一张张自己做了。Quarto支持以下演示格式。

1. **revealjs**: 这是一个基于HTML的演示文稿工具，使用reveal.js框架来创建幻灯片。它允许你制作动态的、带有动画效果的演示文稿，并且可以在网页浏览器中直接展示。
2. **pptx**: 这是Microsoft PowerPoint的文件格式，用于创建和保存PowerPoint演示文稿。PowerPoint是一个广泛使用的演示文稿软件，它允许用户设计幻灯片，添加文本、图片、图表和其他多媒体元素。
3. **beamer**: 这是一个基于LaTeX的文档类，用于创建PDF格式的演示文稿。LaTeX是一个排版系统，特别适用于生成科学和数学文档。使用Beamer，你可以制作结构化的演示文稿，并且可以利用LaTeX的强大功能来设计文档的外观和布局。

> 我知道latex可以做ppt的，但是从来没尝试过。至于网页的演示，只在高中看到过那个铁人三项的计算机老师搞过。

[https://quarto.org/docs/presentations](https://quarto.org/docs/presentations/)

当格式设置为revealjs之后，html文件就变成演示了。但是说实话，有的地方控制起来也挺麻烦，不知道这些层级关系是怎么样的。

```YAML
---
title: "0729-learn"
author: "me"
format: 
  revealjs: default
  pptx: default
---
```

```R
quarto::quarto_render("0729 learn.qmd")
```

# 交互

quarto生成的html也可以包含交互组件，实现这个方式有两种，一个是htmlwidgets，还有一个shiny。（第一次知道quarto还能和shiny联动）

## htmlwidgets

作者提供了一个例子

```R
library(leaflet)
leaflet() |>
  setView(174.764, -36.877, zoom = 16) |> 
  addTiles() |>
  addMarkers(174.764, -36.877, popup = "Maungawhau") 
```

就产生了一个类似于地图的东西

这样不需要了解html或者js也能创建动态的网页了（这个函数似乎是自带的，但是在R script里面是呈现不了的）

其他支持htmlwidgets的包

1. **dygraphs**：这是一个用于创建交互式时间序列图表的库。时间序列数据通常包含随时间变化的数据点，dygraphs可以帮助用户通过缩放、平移和鼠标悬停等操作来探索这些数据。
2. **DT**：这通常指的是DataTables库，它是一个用于创建交互式表格的JavaScript插件。它允许用户对表格数据进行搜索、排序和分页，从而提高表格数据的可读性和易用性。
3. **three.js**：这是一个用于创建和显示3D图形的JavaScript库。它提供了一个简单的API来处理3D图形的渲染，可以用来创建交互式的3D图表和可视化。
4. **DiagrammeR**：这是一个R语言的包，用于创建图表，如流程图和简单的节点-链接图。它允许用户通过R代码来生成图表，并且可以导出为多种格式，以便于分享和展示。

[https://www.htmlwidgets.org](https://www.htmlwidgets.org/)

更多就参考官网吧。

## Shiny

html提供的是浏览器的交互，和R没有关系。（估计是js实现的）

但是要想实现R代码的交互，就得用shiny了。

```YAML
title: "Shiny Web App"
format: html
server: shiny
```

```R
library(shiny)

textInput("name", "What is your name?")
numericInput("age", "How old are you?", NA, min = 0, max = 150)
```

但是这个例子似乎是运行不起来的，因为需要一个server。

想要运行起来，hadley还有一本书就是精通shiny

[https://mastering-shiny.org](https://mastering-shiny.org/)

这就是shiny的优势和劣势了。（需要运行，但是可以用R）

> 但是我记得应该是有本地运行shiny的方法的。

# 网站和书

其实就是一系列qmd组成一个综合体。我们试试能不能做到。感觉比较麻烦，我暂时真的没有这方面的需求

https://quarto.org/docs/websites

https://quarto.org/docs/books

不过quarto官网的指导很详细了，包括rstudio和VS code都有。

# 其他格式

quarto撰写期刊文章：https://quarto.org/docs/journals/templates.html

jupyter notebook：https://quarto.org/docs/reference/formats/ipynb.html

更多的格式：https://quarto.org/docs/output-formats/all-formats.html

# 总结

这一章其实没啥多说的，就是让你见见世面罢了

[*Presentation Patterns*](https://presentationpatterns.com/) 提高你的演讲水平

[*Leek group guide to giving talks*](https://github.com/jtleek/talkguide) 学术演讲指南

https://www.coursera.org/learn/public-speaking 公共发言课程

[*Information Dashboard Design: The Effective Visual Communication of Data*](https://www.amazon.com/Information-Dashboard-Design-Effective-Communication/dp/0596100167) 仪表板的设计

[*The Non-Designer’s Design Book*](https://www.amazon.com/Non-Designers-Design-Book-4th/dp/0133966151) 平面设计的书

这个Hadley真是太全面了。
