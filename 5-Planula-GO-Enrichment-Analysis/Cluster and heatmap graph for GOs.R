
################ Clustering + heatmap of GO terms ##########################

#csv file with Go terms list
f_gene_groups=c('5-Planula-GO-Enrichment-Analysis/Output/GO.05.clust.csv')

#output directory
outidx=c('5-Planula-GO-Enrichment-Analysis/Output/Clusters.graph')

f_gene_groups_sep=","
gene_groups_ids='genes'
gene_groups_direction='percentDEInCat' #calculated as (numDEInCat/numInCat)*100 _this is the percentage of differentially expressed 
                                       #genes in each term. It will be used to set the color in the heatmap
gene_groups_term='term'                 
gene_groups_experiment='experiment' #pH comparison

############################
# functions:

dist_funct=function(v,func){
  n=length(v)
  m=matrix(data=NA,nrow=n,ncol=n)
  for(j in 1:n){
    if(j<n){
      for(k in (j+1):n){
        dist = func(v[j],v[k])
        m[j,k]= dist
        m[k,j]= dist
      }
    }
  }
  return(m)
}

dist_overlap=function(x,y){
  x=strsplit(x,';')[[1]]
  y=strsplit(y,';')[[1]]
  z=length(intersect(x,y))
  return(1-(z/min(length(x),length(y))))
}

pairwise_dists=function(ids,dist_mat_){
  dist_mat=as.matrix(dist_mat_)
  ids_hash=list()
  rownames0=rownames(dist_mat_)
  for(j in 1:length(rownames0)){ids_hash[[rownames0[j]]]=j}
  dists=c()
  n=length(ids)
  for(j in 1:n){
    if(j<n){
      for(k in (j+1):n){
        dists=c(dists,dist_mat[ids_hash[[ids[j]]],ids_hash[[ids[k]]]])
      }
    }
  }
  return(dists)
}

##########################################

library(ggplot2)
library(dendextend)
library(plyr)
library(circlize)
library(gridExtra)
library(data.table)
library(stringdist)
library(tidytree)

#if (!requireNamespace("BiocManager", quietly = TRUE))
#install.packages("BiocManager")

#BiocManager::install("ggtree")

library(treeio)
library(ggtree)

colors1=c('black','blue','brown','burlywood4','cadetblue','chartreuse4','chocolate3','chocolate4','coral3',
          'blue4','blueviolet','brown1','darkgoldenrod4','deepskyblue4','firebrick4','darkslategrey','purple','red',
          'green','gray',rainbow(n=100))
max1=7

for(i in 1:length(f_gene_groups)){
  #geneGroups1 = read.csv(f_gene_groups[i],sep=f_gene_groups_sep,stringsAsFactors=F)
  geneGroups1 = fread(f_gene_groups[i],sep=f_gene_groups_sep,stringsAsFactors=F)
  cols=c(gene_groups_ids,gene_groups_direction,gene_groups_term,gene_groups_experiment)
  geneGroups1 = geneGroups1[,..cols,with=F]
  names(geneGroups1) = c('ids','score','term','experiment')
  geneGroups2 = geneGroups1[,.(nonredudnatIDs = paste(unique(strsplit(gsub("\\s+","",paste(ids,collapse=';'),perl=T)[[1]],";")[[1]]),collapse=";")),by=term]
  geneGroups3 = as.data.frame(geneGroups2)
  d = dist_funct(geneGroups3[,'nonredudnatIDs'],dist_overlap)
  colnames(d)=geneGroups3[,'term']
  rownames(d)=geneGroups3[,'term']
  hc = hclust(as.dist(d),method="ward.D2") #hclust_method)
  hcd = as.dendrogram(hc)
  hc[['tip.label']] = hc[['labels']]
  
  cuts0=1:max1
  cutr1=list()
  cutr_clusters1=list()
  for(u in 1:length(cuts0)){
    cat(u,"\n")
    cutr1[[u]] = cutree(tree=hc,k=cuts0[u])
    cutr_freqs = as.data.frame(table(cutr1[[u]]))
    cutr_clusters1[[u]]=data.frame(term_name=names(cutr1[[u]]),cluster=cutr1[[u]])
    cutr_clusters1[[u]]=cutr_clusters1[[u]][order(cutr_clusters1[[u]]$cluster),]
  }
  
  idx0 = as.integer(max1)
  cutr=cutr1[[idx0]]
  cuts=cuts0[idx0]
  cutr_clusters=cutr_clusters1[[idx0]]
  cutr_tightClusters=cutr_clusters1[[length(cutr_clusters1)]]
  names(cutr_tightClusters) = c('term','cluster')
  
  gg1 = ggtree(hc,layout='rectangular') %<+% cutr_tightClusters 
  gg1 = gg1 + geom_tippoint(aes(color = as.factor(cluster)), shape = "triangle", size = 2)
  gg1 = gg1 + scale_colour_manual(values =  colors1)
  gg1 = gg1 + geom_tiplab(offset=0.1, size=2.75) #,aes(color=as.factor(cluster))) 
  gg1 = gg1 + xlim(0, 5.0)
  #gg1 = gg1 + guides(color = FALSE, size = FALSE)
  pdf(paste0(outidx[i],'_tree.pdf'))
  print(gg1)
  dev.off()
  
  
  scores1 = as.data.frame(dcast(geneGroups1[,.(term,score,experiment)], term ~ experiment,value.var='score',mean),stringsAsFactors=F)
  scores2 = scores1[,c(2:ncol(scores1))]
  rownames(scores2) = scores1[,1]
  pdf(paste0(outidx[i],'_tree_scores_.pdf'), height = 14, width = 8)
  par(mar = c(1.1, 4.1, 4.1, 1.1))
  gheatmap(gg1, scores2,offset=2.75, width=0.5,colnames_angle=-30,font.size=3,hjust=0.75) + #,low='darkblue',high='steelblue1')
  #gg2 = gg2 + viridis::scale_fill_viridis(na.value=NA)
  viridis::scale_fill_viridis(na.value=NA, option = "inferno")
  dev.off()
  #pdf(paste0(outidx[i],'_tree_scores_.pdf'),width=20,height=25)
  #print(gg2)
  #dev.off()
}

#pdf(paste0(outidx,'.','.cluster.pdf'),width=20,height=9)
