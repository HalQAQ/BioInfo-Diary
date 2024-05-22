setwd("./gp_data_analysis/")
library(dplyr)
library(Seurat)
library(SingleR)
library(ggplot2)
library(pheatmap)
dir_control <- "./Control_MG_10X_Matrix/"
dir_treatment <- "./Treatment_MG_10X_Matrix/"

# Import the data
counts_control <- Read10X(data.dir = dir_control)
counts_treatment <- Read10X(data.dir = dir_treatment)

dim(counts_control)
dim(counts_treatment)

# Create Seurat objects
control <- CreateSeuratObject(counts = counts_control,project = "Control",min.cells = 3,min.features = 200)
treatment <- CreateSeuratObject(counts = counts_treatment,project = "Treatment",min.cells = 3,min.features = 200)

control@assays
treatment@assays

### Quality Control

# Add a new column 'percent.mt' for each object
control[["percent.mt"]] <- PercentageFeatureSet(control,pattern = "^mt-")
treatment[["percent.mt"]] <- PercentageFeatureSet(treatment,pattern = "^mt-")

# View the meta.data
head(control@meta.data)
head(treatment@meta.data)
# nCount_RNA: number of UMIs per cell
# nFeature_RNA: number of gene detected per cell

# Visualization by violin plots
VlnPlot(control,features = c("nCount_RNA","nFeature_RNA","percent.mt"),ncol = 3)
VlnPlot(treatment,features = c("nCount_RNA","nFeature_RNA","percent.mt"),ncol = 3)

# Correlation between nCount_RNA and percent.mt, nCount_RNA and nFeature_RNA in the control group
plot_con_cp <- FeatureScatter(control,feature1 = "nCount_RNA",feature2 = "percent.mt")
plot_con_cf <- FeatureScatter(control,feature1 = "nCount_RNA",feature2 = "nFeature_RNA")
plot_con_cp+plot_con_cf
# Correlations in the treatment group
plot_treat_cp <- FeatureScatter(treatment,feature1 = "nCount_RNA",feature2 = "percent.mt")
plot_treat_cf <- FeatureScatter(treatment,feature1 = "nCount_RNA",feature2 = "nFeature_RNA")
plot_treat_cp+plot_treat_cf

# Pick the data points that have 300<nFeatures_RNA<9000 and percent.mt<5%
control <- subset(control,subset = nFeature_RNA>300 & nFeature_RNA<9000 & percent.mt<5)
treatment <- subset(treatment,subset = nFeature_RNA>300 & nFeature_RNA<9000 & percent.mt<5)

control@assays
treatment@assays

### Normalization

# The normalized data is stored in control/treatment[["RNA"]]@data
control <- NormalizeData(control)
treatment <- NormalizeData(treatment)

# Find hypervariable genes
control <- FindVariableFeatures(control)
treatment <- FindVariableFeatures(treatment)

# Plot the top10 genes with labels
top10_con <- head(VariableFeatures(control),10)
top10_treat <- head(VariableFeatures(treatment),10)
lp_control <- LabelPoints(plot = VariableFeaturePlot(control),points = top10_con,repel = T)+
  labs(title = "control")
lp_treatment <- LabelPoints(plot = VariableFeaturePlot(treatment),points = top10_treat,repel = T)+
  labs(title = "treatment")
lp_control + lp_treatment

### Perform Integration

# Store two objects in one vector
mg.vec <- c(control,treatment)

# Select features that are repeatedly variable across datasets for integration
features <- SelectIntegrationFeatures(object.list = mg.vec)

# Create an 'integrated' data assay with anchors
mg.anchors <- FindIntegrationAnchors(object.list = mg.vec,anchor.features = features)
mg.combined <- IntegrateData(anchorset = mg.anchors)

# Specify that we will perform downstream analysis on the corrected data note that the
# original unmodified data still resides in the 'RNA' assay
DefaultAssay(mg.combined) <- "integrated"

# Run the standard workflow for visualization and clustering

### Data Scaling

# The scaled data is stored in [["RNA"]]@scale.data
mg.combined <- ScaleData(mg.combined,verbose = FALSE)

### Linear Dimensional Reduction-PCA,

# Processed data is stored in [["pca"]]
mg.combined <- RunPCA(mg.combined,npcs = 30,verbose = FALSE)
VizDimLoadings(mg.combined,dims = 1:5,reduction = "pca")
DimPlot(mg.combined,reduction = "pca")
DimHeatmap(mg.combined,dims = 1:20,cells = 500,balanced = T)

### Determine the Vital PCs

# JackStraw is not useful here, elbow plot is chosen
ElbowPlot(mg.combined)
# keep 15 PCs

### Clustering

mg.combined <- FindNeighbors(mg.combined,reduction = "pca",dims = 1:15)
mg.combined <- FindClusters(mg.combined,resolution = 1.2)

### Nonlinear Dimensional Reduction

# UMAP
mg.combined <- RunUMAP(mg.combined,reduction = "pca",dims = 1:15)

# Visualization
p1 <- DimPlot(mg.combined,reduction = "umap",group.by = "orig.ident")
p2 <- DimPlot(mg.combined,reduction = "umap",label = TRUE,repel = TRUE)
p1 + p2

# To visualize the two conditions side-by-side, we can use the split.by argument to show each condition colored by cluster.
DimPlot(mg.combined,reduction = "umap",split.by = "orig.ident")

### Cell Type Annotation

# For performing differential expression after integration, we switch back to the original data
DefaultAssay(mg.combined) <- "RNA"

# Load the mouse annotation database
load("MouseRNAseqData.RData")

# Use SingleR to annotate cell types
data <- GetAssayData(mg.combined,slot = "data")
mg.mrd <- SingleR(test = data,ref = mouseRNA,labels = mouseRNA$label.main)
mg.combined@meta.data$labels <- mg.mrd$labels
table(mg.combined@meta.data$labels)
print(DimPlot(mg.combined,group.by = c("seurat_clusters","labels"),reduction = "umap",label = T,repel = T))
DimPlot(mg.combined,group.by = "labels",split.by = "orig.ident",reduction = "umap",label = T,repel = T)
# Modification: cardiomyocytes and hepatocytes shouldn't be here

# Check the quality of annotation
# based on "scores within cells"
print(plotScoreHeatmap(mg.mrd))
# based on per cell "deltas"
plotDeltaDistribution(mg.mrd,ncol = 3)

# Compare with clusters
tab <- table(label = mg.mrd$labels,cluster = mg.combined@meta.data$seurat_clusters)
pheatmap(log10(tab + 10))

# The quality of the epithelial cells is poor, so just find the markers for basal and luminal cells directly

# Basal marker is Procr, luminal marker is Elf5
# (retrieved at CellMarker: http://xteam.xbio.top/CellMarker/)
FeaturePlot(mg.combined,features = c("Procr","Elf5"),reduction = "umap")

# Then we change the labels of the cells expressing the two genes
mg.combined@meta.data[mg.combined@meta.data$seurat_clusters==7|mg.combined@meta.data$seurat_clusters==9,]$labels <- "Basal cells"
mg.combined@meta.data[mg.combined@meta.data$seurat_clusters==5|mg.combined@meta.data$seurat_clusters==22,]$labels <- "Luminal cells"

### Cell Composition Change

DimPlot(mg.combined,group.by = "labels",split.by = "orig.ident",reduction = "umap",label = T,repel = T)

mg.combined@meta.data %>% 
  ggplot(aes(x = orig.ident,fill = labels))+
  geom_bar(position = position_fill())+ 
  scale_fill_brewer(palette = 'Set3')+
  theme_classic()+
  labs(y = 'Percent')+
  coord_flip()

### Gene Expression Alternations

# adipocytes
adipocytes <- subset(mg.combined,subset = labels=="Adipocytes")
Idents(adipocytes) <- "orig.ident"
adipocytes.markers <- FindMarkers(adipocytes,ident.1 = "Control",ident.2 =  "Treatment",min.pct = 0.25)
adipocytes_signif.markers <- row.names(adipocytes.markers[adipocytes.markers$p_val_adj<0.05,])
adipocytes_alters <- length(adipocytes_signif.markers)
adipocytes_markers.to.plot <- head(adipocytes_signif.markers,10)
DotPlot(adipocytes,features = adipocytes_markers.to.plot,cols = c("blue","red"),dot.scale = 8,split.by = "orig.ident") +
  RotatedAxis()
VlnPlot(adipocytes,features = adipocytes_markers.to.plot,split.by = "orig.ident")

# basal cells
basal_cells <- subset(mg.combined,subset = labels=="Basal cells")
Idents(basal_cells) <- "orig.ident"
basal.markers <- FindMarkers(basal_cells,ident.1 = "Control",ident.2 =  "Treatment",min.pct = 0.25)
basal_signif.markers <- row.names(basal.markers[basal.markers$p_val_adj<0.05,])
basal_alters <- length(basal_signif.markers)
basal_markers.to.plot <- head(basal_signif.markers,10)
DotPlot(basal_cells,features = basal_markers.to.plot,cols = c("blue","red"),dot.scale = 8,split.by = "orig.ident") +
  RotatedAxis()
VlnPlot(basal_cells,features = basal_markers.to.plot,split.by = "orig.ident")

# luminal cells
luminal_cells <- subset(mg.combined,subset = labels=="Luminal cells")
Idents(luminal_cells) <- "orig.ident"
luminal.markers <- FindMarkers(luminal_cells,ident.1 = "Control",ident.2 =  "Treatment",min.pct = 0.25)
luminal_signif.markers <- row.names(luminal.markers[luminal.markers$p_val_adj<0.05,])
luminal_alters <- length(luminal_signif.markers)
luminal_markers.to.plot <- head(luminal_signif.markers,10)
DotPlot(luminal_cells,features = luminal_markers.to.plot,cols = c("blue","red"),dot.scale = 8,split.by = "orig.ident") +
  RotatedAxis()
VlnPlot(luminal_cells,features = luminal_markers.to.plot,split.by = "orig.ident")

# Significant alterations of the three cell types
barplot(c(adipocytes_alters,basal_alters,luminal_alters),names.arg = c("Adipocytes","Basal cells","Luminal cells"),col = c("orangered","light green","light blue"))

#save.image("final.RData")
#load("final.RData")

########################################


### Data Scaling

genes_con <- rownames(control)
genes_treat <- rownames(treatment)

# The scaled data is stored in control/treatment[["RNA"]]@scale.data
control <- ScaleData(control,features = genes_con)
treatment <- ScaleData(treatment,features = genes_treat)

### Linear Dimensional Reduction

# PCA, stored in control/treatment[["pca"]]
control <- RunPCA(control,features = VariableFeatures(control))
treatment <- RunPCA(treatment,features = VariableFeatures(treatment))

# View the results
# control group
print(control[["pca"]],dims = 1:5,nfeatures = 5)
VizDimLoadings(control,dims = 1:5,reduction = "pca")
DimPlot(control,reduction = "pca")
DimHeatmap(control,dims = 1:20,cells = 500,balanced = T)
# treatment group
print(treatment[["pca"]],dims = 1:5,nfeatures = 5)
VizDimLoadings(treatment,dims = 1:5,reduction = "pca")
DimPlot(treatment,reduction = "pca")
DimHeatmap(treatment,dims = 1:20,cells = 500,balanced = T)

### Determine the Vital PCs

# JackStraw or Elbow plot
# control group
control <- JackStraw(control,num.replicate = 100)
control <- ScoreJackStraw(control,dims = 1:20)
JackStrawPlot(control,dims = 1:20)
ElbowPlot(control)
# treatment group
treatment <- JackStraw(treatment,num.replicate = 100)
treatment <- ScoreJackStraw(treatment,dims = 1:20)
JackStrawPlot(treatment,dims = 1:20)
ElbowPlot(treatment)
# 15 PCAs are chosen

### Clustering

# KNN algorithm
# control
control <- FindNeighbors(control,dims = 1:15)
control <- FindClusters(control,resolution = 0.5)
head(Idents(control),5)
# treatment
treatment <- FindNeighbors(treatment,dims = 1:15)
treatment <- FindClusters(treatment,resolution = 0.5)
head(Idents(treatment),5)

### Nonlinear Dimensional Reduction

# UMAP
# control
control <- RunUMAP(control,dims = 1:15)
DimPlot(control,reduction = "umap",label = T)
# treatment
treatment <- RunUMAP(treatment,dims = 1:15)
DimPlot(treatment,reduction = "umap",label = T)


### Annotate with SingleR

load("MouseRNAseqData.RData")

control_data <- GetAssayData(control,slot = "data")
treatment_data <- GetAssayData(treatment,slot = "data")

control.mrd <- SingleR(test = control_data,ref = mouseRNA,labels = mouseRNA$label.main)
treatment.mrd <- SingleR(test = treatment_data,ref = mouseRNA,labels = mouseRNA$label.main)

control@meta.data$labels <- control.mrd$labels
print(DimPlot(control,group.by = c("seurat_clusters","labels"),reduction = "umap",label = T,repel = T))
#ggsave("umap_control.png",width = 4000,height = 2000,units = "px",dpi = 300)

treatment@meta.data$labels <- treatment.mrd$labels
print(DimPlot(treatment,group.by = c("seurat_clusters","labels"),reduction = "umap",label = T,repel = T))
#ggsave("umap_treatment.png",width = 4000,height = 2000,units = "px",dpi = 300)

#save.image("separated.RData")
#load("separated.RData")
