###network diagram test
library(tidyverse)
library(igraph)
library(networkD3)
library(ggnetwork)
library(sna)
library(ggiraph)
library(intergraph)
library(stringr)

nodes <- read.csv("research_node.csv") %>%
  select(ID, Year, Citation, Data.Science, Local.Government, Budgeting,Peer.Reviewed,
         Books..Encyclopedia.Chapters..Book.Chapters..Book.Reviews..and.Professional.Articles,
         Applied.Research,Type,Status,Weight, Titles)
edges <- read.csv("reseach_edges.csv")

net <- graph_from_data_frame(d=edges, vertices=nodes, directed=F)

net2 <- asNetwork(net)

net3 <- ggnetwork(net2, cell.jitter = 1)

#V(net)$color <- V(net)$Type

plot(net)

gg_point_1 <- 
  ggplot(net3, aes(x = x, y = y, xend=xend, yend=yend, 
                 tooltip = Citation) )  +
  geom_edges() +
  geom_nodes() +
  theme_blank() +
  geom_nodelabel(data = subset(net3, Titles != ""), aes(label = str_wrap(Titles)), fontface = "bold")+
  geom_point_interactive(data=subset(net3, Titles==""), aes(color=Type), size = 5) + 
  scale_colour_discrete("Research Product", labels =  function(x) str_wrap(x, width = 30)) #this make the node interactive

gg_point_1

ggiraph(code = {print(gg_point_1)}, width = 7, height = 6) 